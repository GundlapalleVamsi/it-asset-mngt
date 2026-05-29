const cds = require('@sap/cds');
module.exports = async (srv) => {
    const { ServiceRequests, Comments, SLAConfig, Employees } = cds.entities('it.asset.service.db');

    //  BEFORE CREATE ServiceRequest
    srv.before(['CREATE'], ['ServiceRequests'], async (req) => {
        const { Priority } = req.data;
        const count = await SELECT.one`count(*) as cnt`.from(ServiceRequests);
        const seq = String(parseInt(count.cnt || 0) + 1).padStart(3, '0');
        req.data.TicketNumber = `TKT-${new Date().getFullYear()}-${seq}`;
        const sla = await SELECT.one.from(SLAConfig).where({ Priority: Priority, IsActive: true });
        if (!sla) {
            return req.error(400, `No active SLA config found for priority: ${Priority}`);
        }
        const now = new Date();
        const responseDue = new Date(now.getTime() + sla.ResponseHours * 3600000);
        const slaDeadline = new Date(now.getTime() + sla.ResolutionHours * 3600000);
        req.data.ResponseDue = responseDue.toISOString();
        req.data.SLADeadline = slaDeadline.toISOString();
        req.data.SLABreached = false;
        req.data.Status = req.data.Status || 'OPEN';
        req.data.ReopenedCount = 0;
        // Round-robin auto-assign
        const itAgents = await SELECT.from(Employees).where({ Department: { in: ['IT', 'Support'] }, IsActive: true });
        if (itAgents.length > 0) {
            const agentLoads = await Promise.all(
                itAgents.map(async (agent) => {
                    const openCount = await SELECT.one`count(*) as cnt`
                        .from(ServiceRequests)
                        .where({
                            AssignedTo_ID: agent.ID,
                            Status: { '!=': 'RESOLVED' }
                        });
                    return { agent, load: parseInt(openCount.cnt || 0) };
                })
            );
            agentLoads.sort((a, b) => a.load - b.load);
            const selectedAgent = agentLoads[0].agent;
            req.data.AssignedTo_ID = selectedAgent.ID;
            req.data.AssignedTeam = selectedAgent.Department;
        }
    });


    //  AFTER UPDATE ServiceRequest → Status = RESOLVED
    srv.after('UPDATE', 'ServiceRequests', async (data, req) => {
        if (data.Status === 'RESOLVED') {
            const now = new Date();
            const ticket = await SELECT.one.from(ServiceRequests).where({ ID: data.ID });
            if (!ticket) return;
            const slaDeadline = new Date(ticket.SLADeadline);
            const breached = now > slaDeadline;
            await UPDATE(ServiceRequests)
                .set({
                    ResolvedAt: now.toISOString(),
                    ClosedAt: now.toISOString(),
                    SLABreached: breached
                })
                .where({ ID: data.ID });
            await INSERT.into(Comments).entries({
                ServiceRequest_ID: data.ID,
                Author_ID: req.user?.id || null,
                CommentText: breached
                    ? `Ticket resolved (resolved ${Math.round((now - slaDeadline) / 60000)} mins late)`
                    : `Ticket resolved within SLA`,
                CommentType: 'SYSTEM',
                IsInternal: true
            });
        }
    });

    //  ACTION: assignTicket(ticketID, agentID)
    srv.on('assignTicket', async (req) => {
        const ticketID = req.params[0].ID;
        const { agentID } = req.data;
        const ticket = await SELECT.one.from(ServiceRequests).where({ ID: ticketID });
        if (!ticket) return req.error(404, `Ticket ${ticketID} not found`);
        const agent = await SELECT.one.from(Employees).where({ ID: agentID });
        if (!agent) return req.error(404, `Agent ${agentID} not found`);
        await UPDATE(ServiceRequests)
            .set({
                AssignedTo_ID: agentID,
                Status: 'IN_PROGRESS'
            })
            .where({ ID: ticketID });
        await INSERT.into(Comments).entries({
            ServiceRequest_ID: ticketID,
            Author_ID: req.user?.id || null,
            CommentText: `Ticket manually assigned to ${agent.FullName}`,
            CommentType: 'SYSTEM',
            IsInternal: true
        });
        req.info(`Ticket ${ticket.TicketNumber} assigned successfully`);
        return `Ticket [${ticket.TicketNumber}] assigned to ${agent.FullName}`;
    });


    //  ACTION: resolveTicket(ticketID, resolution)
    srv.on('resolveTicket', async (req) => {
        const ticketID = req.params[0].ID;
        const { resolution } = req.data;
        const ticket = await SELECT.one.from(ServiceRequests).where({ ID: ticketID });
        if (!ticket) return req.error(404, `Ticket ${ticketID} not found`);
        if (ticket.Status === 'RESOLVED' || ticket.Status === 'CLOSED') {
            return req.error(400, `Ticket is already ${ticket.Status}`);
        }
        await UPDATE(ServiceRequests)
            .set({
                Status: 'RESOLVED',
                ResolutionSummary: resolution
            })
            .where({ ID: ticketID });
        req.info(`Ticket ${ticket.TicketNumber} resolved successfully`);
        return `Ticket [${ticket.TicketNumber}] resolved successfully`;
    });

    srv.on('closeTicket', async (req) => {
        const ticketID = req.params[0].ID;
        const { feedback } = req.data;

        const ticket = await SELECT.one.from(ServiceRequests).where({ ID: ticketID });

        if (!ticket)
            return req.error(404, `Ticket ${ticketID} not found`);


        if (ticket.Status !== 'RESOLVED')
            return req.error(400, `Ticket must be RESOLVED before closing. Current status: ${ticket.Status}`);

        await UPDATE(ServiceRequests)
            .set({
                Status: 'CLOSED',
                ClosedAt: new Date().toISOString(),
                ClosureFeedback: feedback ?? 'Closed by user'
            })
            .where({ ID: ticketID });

        req.info(`Ticket ${ticket.TicketNumber} closed`);
        return `Ticket [${ticket.TicketNumber}] has been closed`;
    });

    //  ACTION: escalateTicket(ticketID, reason)
    srv.on('escalateTicket', async (req) => {
        const ticketID = req.params[0].ID;
        const { reason } = req.data;
        const ticket = await SELECT.one.from(ServiceRequests).where({ ID: ticketID });
        if (!ticket) return req.error(404, `Ticket ${ticketID} not found`);
        if (ticket.Status === 'RESOLVED' || ticket.Status === 'CLOSED') {
            return req.error(400, `Cannot escalate a ${ticket.Status} ticket`);
        }
        const seniorAgent = await SELECT.one.from(Employees)
            .where({
                Department: { in: ['IT', 'Support'] },
                IsActive: true,
                Designation: {
                    in: [
                        'Senior Engineer',
                        'System Administrator',
                        'Team Lead',
                        'Manager'
                    ]
                }
            })
            .and({ ID: { '!=': ticket.AssignedTo_ID } })
            .orderBy('Designation desc');
        if (!seniorAgent) {
            return req.error(404, 'No senior IT agent available for escalation');
        }
        const now = new Date();
        await UPDATE(ServiceRequests)
            .set({
                AssignedTo_ID: seniorAgent.ID,
                Status: 'ESCALATED',
                EscalationLevel: 'L2',
                EscalationReason: reason,
                EscalatedAt: now.toISOString()
            })
            .where({ ID: ticketID });
        await INSERT.into(Comments).entries({
            ServiceRequest_ID: ticketID,
            Author_ID: req.user?.id || null,
            CommentText: `Escalated to L2 — Assigned to: ${seniorAgent.FullName} | Reason: ${reason}`,
            CommentType: 'ESCALATION',
            IsInternal: true
        });
        req.info(`Ticket ${ticket.TicketNumber} escalated successfully`);
        return `Ticket [${ticket.TicketNumber}] escalated to ${seniorAgent.FullName} (L2)`;
    });

    //  FUNCTION: getBreachedSLAs()
    srv.on('getBreachedSLAs', async (req) => {
        const now = new Date().toISOString();
        const breachedTickets = await SELECT.from(ServiceRequests)
            .where`SLADeadline < ${now}
                and Status != ${'RESOLVED'}
                and Status != ${'CLOSED'}
                and Status != ${'CANCELLED'}`;
        if (breachedTickets.length > 0) {
            const ids = breachedTickets.map(t => t.ID);
            for (const id of ids) {
                await UPDATE(ServiceRequests)
                    .set({ SLABreached: true })
                    .where({ ID: id, SLABreached: false });
            }
        }
        req.info(`Found ${breachedTickets.length} breached SLAs`);
        console.log(breachedTickets);

        return breachedTickets;
    });



    // ── Job Scheduler Handler ─────────────────────────────────────────────────
    // This is called by BTP Job Scheduler every 30 min via POST /ticket/checkSLABreaches
    srv.on('checkSLABreaches', async (req) => {
        const now = new Date().toISOString();

        // reuses your exact getBreachedSLAs logic
        const breachedTickets = await SELECT.from(ServiceRequests)
            .where`SLADeadline < ${now}
           and Status != ${'RESOLVED'}
           and Status != ${'CLOSED'}
           and Status != ${'CANCELLED'}`;

        console.log(`[JobScheduler] ${now} — Found ${breachedTickets.length} breached tickets`);

        if (breachedTickets.length === 0) {
            return { message: 'No SLA breaches found', count: 0 };
        }

        for (const ticket of breachedTickets) {

            // mark SLABreached = true — same as your getBreachedSLAs
            await UPDATE(ServiceRequests)
                .set({ SLABreached: true })
                .where({ ID: ticket.ID, SLABreached: false });

            // auto-escalate — same as your escalateTicket logic
            if (ticket.Status !== 'ESCALATED') {

                const seniorAgent = await SELECT.one
                    .from(Employees)
                    .where({
                        Department: { in: ['IT', 'Support'] },
                        IsActive: true,
                        Designation: {
                            in: [
                                'Senior Engineer',
                                'System Administrator',
                                'Team Lead',
                                'Manager'
                            ]
                        }
                    })
                    .and({ ID: { '!=': ticket.AssignedTo_ID } })
                    .orderBy('Designation desc');

                if (seniorAgent) {
                    await UPDATE(ServiceRequests)
                        .set({
                            Status: 'ESCALATED',
                            EscalationLevel: 'L2',
                            EscalationReason: 'Auto-escalated by Job Scheduler — SLA breached',
                            EscalatedAt: now,
                            AssignedTo_ID: seniorAgent.ID
                        })
                        .where({ ID: ticket.ID });

                    // log in Comments — same as your escalateTicket
                    await INSERT.into(Comments).entries({
                        ServiceRequest_ID: ticket.ID,
                        Author_ID: null,
                        CommentText: `[AUTO-ESCALATED by Job Scheduler] SLA deadline was ${ticket.SLADeadline}. Escalated to ${seniorAgent.FullName} (L2) at ${now}`,
                        CommentType: 'ESCALATION',
                        IsInternal: true
                    });

                    console.log(`[JobScheduler] Ticket ${ticket.TicketNumber} → escalated to ${seniorAgent.FullName}`);
                }
            }
        }

        return {
            message: `Processed ${breachedTickets.length} breached tickets`,
            count: breachedTickets.length
        };
    });
};