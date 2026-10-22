with source as (
    select * from {{ ref('stg_sales_salesorderheadersalesreason') }}
),

renamed as (
    select
        sales_order_id,
        sales_reason_id,
        modified_date
    from source
)

select * from renamed