SELECT
  invoice.month as invoice_month,
  case
    when substr(invoice.month, 5, 6) in ('11', '12') then cast(
      cast(substr(invoice.month, 1, 4) as integer) + 1 as string
    )
    else substr(invoice.month, 1, 4)
  end as billing_year, -- billing year goes from november to october
  -- organization can be null for special deals such as cud, cloud armor monthly fee and support 
  IFNULL(
    (select a.display_name from unnest(project.ancestors) a where starts_with(a.resource_name, "organizations/")),
    "none"
  ) as organization,
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
  2,
  3
ORDER BY
  1 ASC