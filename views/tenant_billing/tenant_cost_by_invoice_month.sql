with
  all_tenants as (
    SELECT
      invoice.month,
      (
        SELECT
          value
        from
          UNNEST (project.labels)
        WHERE
          key = 'tenant'
      ) as tenant_unfiltered,
      (
        SUM(CAST(cost AS NUMERIC)) + SUM(
          IFNULL(
            (
              SELECT
                SUM(CAST(c.amount AS NUMERIC))
              FROM
                UNNEST (credits) AS c
            ),
            0
          )
        )
      ) AS total_exact
    FROM
      `nais-io.nais_billing_regional.gcp_billing_export_resource_v1_014686_D32BB4_68DF8E`
    GROUP BY
      1,
      2
    ORDER BY
      1 ASC
  )
SELECT
  month,
  case
    when tenant_unfiltered is null
    or tenant_unfiltered in (
      'nav',
      'nais',
      'dev-nais',
      'ci-nais',
      'test-nais',
      'example',
      'testing'
    ) then 'nav'
    else tenant_unfiltered
  end as tenant,
  sum(CAST(total_exact AS NUMERIC)) as total_cost
FROM
  all_tenants
GROUP BY
  month,
  tenant