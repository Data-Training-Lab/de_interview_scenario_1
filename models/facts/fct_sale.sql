{{ 
    config(
        enabled=true
        )
}}

WITH
d_client AS (
    SELECT
        _client_hk,
        _client_bk
    FROM
        {{ ref('dim_client') }}
),

d_region AS (
    SELECT
        _region_hk,
        region_name
    FROM
        {{ ref('dim_region') }}
),

sale AS (
    SELECT
        COALESCE(d_client._client_hk, '-2') AS _client_hk,
        COALESCE(d_region._region_hk, '-2') AS _region_hk,
        sale.date::DATE AS sale_date,
        SUM(sale.sale) AS sale_amount
    FROM
        {{ ref('stg_sale') }} AS sale
        LEFT JOIN d_client
            ON COALESCE(sale.client_id, '-1') = d_client._client_bk
        LEFT JOIN d_region
            ON COALESCE(sale.region, 'Unknown') = d_region.region_name
    WHERE
        1 = 1
        AND sale.dbt_valid_to IS NULL
    GROUP BY
        _client_hk,
        _employee_hk,
        _region_hk,
        sale_date
)

SELECT
    *
FROM    
    sale
