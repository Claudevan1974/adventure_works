with person as (
    select * 
    from {{ ref('stg_person_person') }}
)

select
    person_id,
    person_type,
    first_name,
    last_name,
    -- Concatenação do primeiro e último nome para facilitar análises
    concat(first_name, ' ', last_name) as full_name
from person