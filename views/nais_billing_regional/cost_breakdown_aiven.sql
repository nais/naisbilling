with dates as (
  select dato from
  UNNEST(
    GENERATE_DATE_ARRAY(DATE((select CONCAT(min(date), '-01') from `nais-io.aiven_cost_regional.cost_items`)), CURRENT_DATE(), INTERVAL 1 DAY)
) as dato)

SELECT dates.dato as dato,
       'aiven' AS project_name,
       environment as env,
       team,
       tenant,
       CASE WHEN team='nais' THEN 'Plattform' ELSE 'Produktteam' END as cost_category,
       c.date as month,
       service as service_description,
       service as sku_id,
       case 
        when extract(month from dates.dato) = extract(month from current_date()) and extract(year from dates.dato) = extract(year from current_date()) then
          sum(cast(cast(cost as float64) * 1000000 as int64) * cast(cast(r.usdeur as float64) * 1000000 as int64) / extract(day from current_date())) / (1000000 * 1000000)
        else
          sum(cast(cast(cost as float64) * 1000000 as int64) * cast(cast(r.usdeur as float64) * 1000000 as int64) / cast(number_of_days as float64)) / (1000000 * 1000000)
        end as calculated_cost
FROM `nais-io.aiven_cost_regional.cost_items` c
right outer join dates on substring(string(dates.dato), 0, 7) = c.date
inner join `aiven_cost_regional.currency_rates` r on string(dates.dato) = r.date
GROUP BY month, dato, team, environment, service, tenant