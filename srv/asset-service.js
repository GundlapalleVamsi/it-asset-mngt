const cds = require('@sap/cds');
module.exports = async (srv) => {
    const { Assets, Employees, EmployeePortal } = cds.entities('it.asset.service.db');
    const { SLAConfig } = cds.entities('MyService2');

    srv.before('CREATE', 'EmployeePortal', async (req) => {
        if (req.data.IsActiveEntity === false) return;
        const { Priority } = req.data;
        const count = await SELECT.one
            `count(*) as cnt`
            .from('it.asset.service.db.ServiceRequests');
        const seq = String(
            parseInt(count.cnt || 0) + 1
        ).padStart(3, '0');
        req.data.TicketNumber =
            `TKT-${new Date().getFullYear()}-${seq}`;
        const sla = await SELECT.one
            .from(SLAConfig)
            .where({
                Priority,
                IsActive: true
            });
        if (!sla) {
            return req.error(
                400,
                `No active SLA config found for priority: ${Priority}`
            );
        }

        const now = new Date();
        req.data.ResponseDue = new Date(
            now.getTime() + sla.ResponseHours * 3600000
        ).toISOString();
        req.data.SLADeadline = new Date(
            now.getTime() + sla.ResolutionHours * 3600000
        ).toISOString();
        req.data.SLABreached = false;
        req.data.Status = 'OPEN';
        req.data.ReopenedCount = 0;
        req.data.AssignedTeam = 'Support';

    });

    // assignAsset(assetID: UUID, employeeID: UUID)
    srv.on('assignAsset', async (req) => {
        const { assetID, employeeID } = req.data;
        const asset = await SELECT.one.from(Assets).where({ ID: assetID });
        if (!asset) return req.error(404, `Asset ${assetID} not found`);
        if (asset.Status !== 'AVAILABLE') {
            return req.error(400, `Asset is currently ${asset.Status} — cannot assign`);
        }
        const employee = await SELECT.one.from(Employees).where({ ID: employeeID });
        if (!employee) return req.error(404, `Employee ${employeeID} not found`);
        if (!employee.IsActive) return req.error(400, `Employee is inactive`);
        await UPDATE(Assets)
            .set({
                AssignedTo_ID: employeeID,
                AssignedDate: new Date().toISOString().split('T')[0],
                Status: 'ASSIGNED'
            })
            .where({ ID: assetID });
        return `Asset [${asset.AssetTag}] successfully assigned to ${employee.FullName}`;
    });


    //returnAsset(assetID)
    srv.on('returnAsset', async (req) => {
        const { assetID } = req.data;
        const asset = await SELECT.one.from(Assets).where({ ID: assetID });
        if (!asset) return req.error(404, `Asset ${assetID} not found`);
        if (asset.Status === 'AVAILABLE') {
            return req.error(400, `Asset is already AVAILABLE — not assigned to anyone`);
        }
        await UPDATE(Assets)
            .set({
                AssignedTo_ID: null,
                AssignedDate: null,
                Status: 'AVAILABLE'
            })
            .where({ ID: assetID });
        return `Asset [${asset.AssetTag}] returned successfully and is now AVAILABLE`;
    });


    srv.on('getAssetsByEmployee', async (req) => {
        const { employeeID } = req.data;
        const employee = await SELECT.one.from(Employees).where({ ID: employeeID });
        if (!employee) return req.error(404, 'Employee not found');
        const assets = await SELECT.from(Assets).where({ AssignedTo_ID: employeeID })
        return {
            employee: {
                EmployeeCode: employee.EmployeeCode,
                FullName: employee.FullName,
                Email: employee.Email,
                Department: employee.Department,
                Designation: employee.Designation,
                ManagerName: employee.ManagerName,
                Location: employee.Location,
                WorkMode: employee.WorkMode,
                IsActive: employee.IsActive
            },
            totalAssets: assets.length,
            assets
        };
    });

};