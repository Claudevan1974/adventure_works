with source as (
    select * from {{ ref('stg_sales_creditcard') }}
),

renamed as (
    select
        credit_card_id,
        card_type,
        card_number,
        exp_month,
        exp_year,
        modified_date
    from source
)

select * from renamed