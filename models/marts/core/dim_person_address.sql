with address as (
    select * from {{ ref('stg_person_address') }}
),

state_province as (
    select 
        state_province_id,
        state_province_code,
        state_name as state_province_name,
        country_region_code
    from {{ ref('stg_person_stateprovince') }}
),

country_region as (
    select * from {{ ref('stg_person_countryregion') }}
)

select
    address.address_id,
    address.address_line_1,
    address.address_line_2,
    address.city,
    address.postal_code,
    -- Dados do estado/província e país enriquecidos
    state_province.state_province_code,
    state_province.state_province_name,
    country_region.country_region_name
from address
left join state_province 
    on address.state_province_id = state_province.state_province_id
left join country_region 
    on state_province.country_region_code = country_region.country_region_code