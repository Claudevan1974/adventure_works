with source as (
    select * from {{ ref('stg_purchasing_purchaseorderdetail') }}
),

renamed as (
    select
        purchase_order_id,
        purchase_order_detail_id,
        due_date,
        order_qty,
        product_id,
        unit_price,
        received_qty,
        rejected_qty,
        modified_date
    from source
)

select * from renamed