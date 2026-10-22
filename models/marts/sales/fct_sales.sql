with order_header as (
    select
        sales_order_id,
        customer_id,
        sales_person_id,
        territory_id,
        credit_card_id,
        bill_to_address_id,
        order_date,
        due_date,
        ship_date,
        order_status,
        online_order_flag
    from {{ ref('stg_sales_salesorderheader') }}
),

order_detail as (
    select * from {{ ref('stg_sales_salesorderdetail') }}
),

-- 1. Dados de Cartão de Crédito (Tipo de Cartão)
credit_card as (
    select
        credit_card_id,
        card_type
    from {{ ref('stg_sales_creditcard') }}
),

-- 2. Endereço, Estado e País (Cidade, Estado, País)
address as (
    select
        address_id,
        city,
        state_province_id
    from {{ ref('stg_person_address') }}
),

state_province as (
    select
        state_province_id,
        state_name,
        country_region_code
    from {{ ref('stg_person_stateprovince') }}
),

country_region as (
    select
        country_region_code,
        country_region_name as country_name
    from {{ ref('stg_person_countryregion') }}
),

-- 3. Motivo de Venda (Bridge + Reason)
sales_reason_bridge as (
    select
        sales_order_id,
        sales_reason_id
    from {{ ref('stg_sales_salesorderheadersalesreason') }}
),

sales_reason as (
    select
        sales_reason_id,
        sales_reason_name
    from {{ ref('stg_sales_salesreason') }}
),

-- Consolidação dos Motivos de Venda por Pedido (evita duplicar linhas na Fato se houver mais de 1 motivo)
order_sales_reasons as (
    select
        b.sales_order_id,
        string_agg(r.sales_reason_name, ', ') as sales_reasons
    from sales_reason_bridge b
    inner join sales_reason r on b.sales_reason_id = r.sales_reason_id
    group by b.sales_order_id
),

fct_sales as (
    select
        -- Chave primária composta da Fato
        concat(cast(d.sales_order_id as string), '-', cast(d.sales_order_detail_id as string)) as sales_order_item_sk,
        
        -- Chaves Estrangeiras / IDs
        d.sales_order_id,
        d.sales_order_detail_id,
        h.customer_id,
        d.product_id,
        h.sales_person_id,
        h.territory_id,
        h.credit_card_id,
        h.bill_to_address_id,
        
        -- Datas e Status
        h.order_date,
        h.due_date,
        h.ship_date,
        h.order_status,
        h.online_order_flag,

        -- Atributos Descritivos Solicitados
        cc.card_type,
        a.city as bill_to_city,
        sp.state_name as bill_to_state,
        cr.country_name as bill_to_country,
        coalesce(sr.sales_reasons, 'Not Specified') as sales_reason,
        
        -- Métricas Quantitativas (Quantidade e Valor Negociado)
        d.order_qty,
        d.unit_price,
        d.unit_price_discount,
        (d.order_qty * d.unit_price) as gross_revenue_amount,
        (d.order_qty * d.unit_price * (1 - d.unit_price_discount)) as net_revenue_amount
        
    from order_detail d
    left join order_header h 
        on d.sales_order_id = h.sales_order_id
    left join credit_card cc
        on h.credit_card_id = cc.credit_card_id
    left join address a
        on h.bill_to_address_id = a.address_id
    left join state_province sp
        on a.state_province_id = sp.state_province_id
    left join country_region cr
        on sp.country_region_code = cr.country_region_code
    left join order_sales_reasons sr
        on h.sales_order_id = sr.sales_order_id
)

select * from fct_sales