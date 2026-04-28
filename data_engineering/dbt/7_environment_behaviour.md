## Customize dbt based on env

Leverage `target` and `env` vars

### target

Accessible in any jinja block and configurable on dev and job level 

- params
    - name (default if not changed)



*Example:*

```jinja
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```
VS

```jinja
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif target.name in ['prod'] -%}
    
        {{ custom_schema_name }}
    
    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

### env vars

All need to start with `DBT_` and it can be retrieved as: 

`{{ env_var('DBT_MY_ENV', '<default_value>') }}`

Order of precedence:
1. Dev/Job level (settings)
2. dbt env level
3. project level
4. default arg in the jinja function