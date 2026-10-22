with source as (
    select * from {{ ref('stg_person_stateprovince') }}
),

renamed as (
    select
        state_province_id,
        state_province_code,
        country_region_code,
        is_only_state_province_flag,
        state_name,
        territory_id,
        row_guid
    from source
)

select * from renamed