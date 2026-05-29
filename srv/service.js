const cds = require('@sap/cds');
const JobSchedulerClient = require('@sap/jobs-client');

cds.on('served', async () => {
    try {
        const vcap = JSON.parse(process.env.VCAP_SERVICES || '{}');
        const jsBinding = vcap?.jobscheduler?.[0]?.credentials;

        if (!jsBinding) {
            console.warn('[JobScheduler] No binding found — skipping');
            return;
        }

        const appURL = process.env.APP_URL;
        if (!appURL) {
            console.error('[JobScheduler] APP_URL not set!');
            return;
        }

        // ✅ CORRECT credentials structure from your VCAP_SERVICES
        const scheduler = new JobSchedulerClient.Scheduler({
            baseURL      : jsBinding.url,           // https://jobscheduler-rest.cfapps.us10.hana.ondemand.com
            user         : jsBinding.uaa.clientid,  // sb-32edec7c....
            password     : jsBinding.uaa.clientsecret, // f38675a2-...
            tokenEndpoint: jsBinding.uaa.url        // https://2ace698ftrial.authentication.us10.hana.ondemand.com
        });

        const JOB_NAME = 'it-asset-sla-breach-checker';

        scheduler.fetchAllJobs({}, (fetchErr, result) => {
            if (fetchErr) {
                console.error('[JobScheduler] Cannot fetch jobs:', fetchErr.message);
                return;
            }

            const alreadyExists = result?.results?.some(j => j.name === JOB_NAME);
            if (alreadyExists) {
                console.log('[JobScheduler] Job already registered — skipping');
                return;
            }

            const job = {
                name       : JOB_NAME,
                description: 'Auto-escalate SLA breached tickets every 30 minutes',
                // ✅ Correct URL confirmed from your logs
                action     : `${appURL}/odata/v4/my-service2/checkSLABreaches`,
                active     : true,
                httpMethod : 'POST',
                schedules  : [{
                    description    : 'Every 30 minutes',
                    data           : '{}',
                    type           : 'recurring',
                    active         : true,
                    startTime      : { date: new Date().toISOString() },
                    repeatInterval : '*/30 * * * *'
                }]
            };

            scheduler.createJob({ data: job }, (createErr, newJob) => {
                if (createErr) {
                    console.error('[JobScheduler] Registration failed:', createErr.message);
                } else {
                    console.log(`[JobScheduler] ✅ Job registered! ID: ${newJob.id}`);
                }
            });
        });

    } catch (err) {
        console.error('[JobScheduler] Setup error:', err.message);
    }
});

module.exports = cds.server;