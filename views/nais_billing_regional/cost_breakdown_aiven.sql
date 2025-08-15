WITH
  dates AS (
    SELECT
      dato
    FROM
      UNNEST (
        GENERATE_DATE_ARRAY(
          DATE(
            (
              SELECT
                CONCAT(MIN(DATE), '-01')
              FROM
                `nais-io.aiven_cost_regional.cost_items`
            )
          ),
          CURRENT_DATE(),
          INTERVAL 1 DAY
        )
      ) AS dato
  )
SELECT
  dates.dato AS dato,
  'aiven' AS project_name,
  environment AS env,
  team,
  tenant,
  CASE
    WHEN team = 'nais' THEN 'Plattform'
    ELSE 'Produktteam'
  END AS cost_category,
  c.date AS month,
  service AS service_description,
  service AS sku_id,
  service_name,
  CASE
    WHEN EXTRACT(
      MONTH
      FROM
        dates.dato
    ) = EXTRACT(
      MONTH
      FROM
        CURRENT_DATE()
    )
    AND EXTRACT(
      YEAR
      FROM
        dates.dato
    ) = EXTRACT(
      YEAR
      FROM
        CURRENT_DATE()
    ) THEN SUM(
      CAST(cost AS NUMERIC) * CAST(r.usdeur AS NUMERIC) / EXTRACT(
        DAY
        FROM
          CURRENT_DATE()
      )
    )
    ELSE SUM(
      CAST(cost AS NUMERIC) * CAST(r.usdeur AS NUMERIC) / number_of_days
    )
  END AS calculated_cost
FROM
  (
    SELECT
      DATE,
      environment,
      team,
      tenant,
      service,
      service_name,
      cost,
      number_of_days
    FROM
      `nais-io.aiven_cost_regional.cost_items`
    WHERE
      service != 'kafka'
    UNION ALL
    SELECT
      DATE,
      environment,
      team,
      tenant,
      service,
      service_name,
      cost,
      number_of_days
    FROM
      `nais-io.aiven_cost_regional.kafka_cost`
  ) AS c
  RIGHT OUTER JOIN dates ON SUBSTRING(STRING(dates.dato), 0, 7) = c.date
  INNER JOIN `aiven_cost_regional.currency_rates` r ON STRING(dates.dato) = r.date
GROUP BY
  month,
  dato,
  team,
  environment,
  service,
  service_name,
  tenant