SELECT
    project,
    project_id,
    CASE
        WHEN team IS NOT NULL THEN team
        ELSE
            CASE
                WHEN (project LIKE '%-dev' OR project LIKE '%-prod') THEN SPLIT(project,'-')[SAFE_OFFSET(0)]
                ELSE NULL
                END
        END AS team,
    CASE
        WHEN tenant IS NOT NULL THEN tenant
        ELSE
            CASE
                WHEN (lower(project) = 'provetaking') THEN 'mtpilot'
                WHEN (lower(project) = 'mtpilot') THEN 'mtpilot'
                ELSE 'nav'
                END
        END AS tenant,
    CASE
        WHEN environment IS NOT NULL THEN environment
        ELSE
            CASE
                WHEN (project LIKE '%-dev') THEN 'dev'
                WHEN (project LIKE '%-prod') THEN 'prod'
                ELSE null
                END
        END AS environment
FROM `nais-io.legacy_billing.gcp_projects`