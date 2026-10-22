with country_region as (
    select * 
    from {{ ref('stg_person_countryregion') }}
)

select
    country_region_code,
    country_region_name,
    modified_date
from country_region