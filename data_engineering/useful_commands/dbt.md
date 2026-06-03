## Codegen

Generate schema and source ymls

```shell
dbt run-operation generate_source --args '{"schema_name": "bronze", "generate_columns": true}' > codegen_output.yml

dbt run-operation generate_model_yaml \
  --args '{"model_names": [""], "generate_columns": true}' \
  --no-use-colors 2>/dev/null > codegen_output.yml
```

## Incremental

### MERGE

```jinja
{%- set lookback_days = var('lookback_days', 30) -%}

{{ config(
    materialized='incremental',
    unique_key='balance_id',
    incremental_strategy='merge',
    incremental_predicates=["DBT_INTERNAL_DEST.calendar_date > (select max(calendar_date) - interval '" ~ lookback_days ~ " days' from " ~ this ~ ")"],
    tags=['refactored', 'main', 'rated']
) }}

-- OR

{%- set lookback_days = var('lookback_days', 30) -%}

{%- set config_dict = {
    'materialized': 'incremental',
    'unique_key': 'balance_id',
    'incremental_strategy': 'merge',
    'tags': ['refactored', 'categories', 'main', 'mart', 'rated']
} -%}

{%- if is_incremental() -%}
    {%- do config_dict.update({'incremental_predicates': [
        "DBT_INTERNAL_DEST.calendar_date > (select max(calendar_date) - interval '"
        ~ lookback_days ~ " days' from " ~ this ~ ")"
    ]}) -%}
{%- endif -%}

{{ config(**config_dict) }}

{%- if is_incremental() -%}
where ad.calendar_date > (select max(calendar_date) - interval '{{ lookback_days }} days' from {{ this }})
{% endif %}
{% if not loop.last %}union all{% endif %}{% endfor %}
```

### DELETE (PRE HOOK) + APPEND

```jinja
{%- set lookback_days = var('lookback_days', 30) -%}

{{ config(
    materialized='incremental',
    incremental_strategy='append',
    pre_hook=window_truncate_pre_hook('calendar_date', lookback_days),
    tags=['refactored', 'main', 'rated']
) }}

{%- if is_incremental() -%}
where ad.calendar_date > (select max(calendar_date) from {{ this }})
{% endif %}
{% if not loop.last %}union all{% endif %}{% endfor %}
```

## AI

Fill these yamls descriptions with ref for doc blocks using the same name as the column for columns and write directly on the same yml the definition of the model itself