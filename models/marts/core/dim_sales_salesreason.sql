with source as (
    select * from {{ ref('stg_sales_salesreason') }}
),

renamed as (
    select
        sales_reason_id,
        sales_reason_name,
        reason_type,
        modified_date
    from source
)

select * from renamed