### Jinja

- Variables can be values, dicts, or lists.
- You can write `{% set %}` anywhere in the code.
- Example use: pivot macro (list of values, for, and if statements).
- Control whitespace by adding a single dash on either side of the Jinja delimiter to trim whitespace.
- `env_var('env_var_name')` → useful for setting schema dynamically (e.g., using gen schema macro).

Example:

```sql
{% for payment_method in payment_methods -%}
    sum(case when payment_method = '{{ payment_method }}' then amount else 0 end) 
        as {{ payment_method }}_amount

    {%- if not loop.last -%}
        ,
    {% endif -%}
{%- endfor %}
```

### Macros

In model
```jinja
    {{ function_name("arg")}}
```

In macro file

```jinja
    {% macro function_name(arg) -%}
        logic... {{ arg }}
    {%- end %}
```

### Doc block example

```jinja
    {% docs order_status %}
        
    One of the following values: 

    | status         | definition                                       |
    |----------------|--------------------------------------------------|
    | placed         | Order placed, not yet shipped                    |
    | shipped        | Order has been shipped, not yet been delivered   |
    | completed      | Order has been received by customers             |
    | return pending | Customer indicated they want to return this item |
    | returned       | Item has been returned                           |

    {% enddocs %}
```

running query example:
```jinja

    {% macro grant_select(schema=target.schema, role=target.role) %}

    {% set sql %}
    grant usage on schema {{ schema }} to role {{ role }};
    grant select on all tables in schema {{ schema }} to role {{ role }};
    grant select on all views in schema {{ schema }} to role {{ role }};
    {% endset %}

    {{ log('Granting select on all tables and views in schema ' ~ target.schema ~ ' to role ' ~ role, info=True) }}
    {% do run_query(sql) %}
    {{ log('Privileges granted', info=True) }}

    {% endmacro %}
```

On the terminal:
```
dbt run-operation grant_select --args '{"schema": "analytics", "role": "reporter"}'
```

On dbt_project.yml:
```yml
# dbt_project.yml
models:
  your_project:
    marts:
      +post-hook: "{{ grant_select() }}"
```

On a model:
```jinja
{{ config(post_hook="{{ grant_select() }}") }}
```

union_tables_by_prefix macro code (will unite all tables with same prefix):

```jinja
    {%- macro union_tables_by_prefix(database, schema, prefix) -%}

    -- considers the execute variable
    {%- set tables = dbt_utils.get_relations_by_prefix(database=database, schema=schema, prefix=prefix) -%}

    {% for table in tables %}

        {%- if not loop.first -%}
        union all 
        {%- endif %}
            
        select * from {{ table.database }}.{{ table.schema }}.{{ table.name }}
        
    {% endfor -%}
    
    {%- endmacro -%}
```

clean_stale_models:

```jinja
    {#  
        -- let's develop a macro that 
        1. queries the information schema of a database
        2. finds objects that are > 1 week old (no longer maintained)
        3. generates automated drop statements
        4. has the ability to execute those drop statements

    #}

    {% macro clean_stale_models(database=target.database, schema=target.schema, days=7, dry_run=True) %}
        
        {% set get_drop_commands_query %}
            select
                case 
                    when table_type = 'VIEW'
                        then table_type
                    else 
                        'TABLE'
                end as drop_type, 
                'DROP ' || drop_type || ' {{ database | upper }}.' || table_schema || '.' || table_name || ';'
            from {{ database }}.information_schema.tables 
            where table_schema = upper('{{ schema }}')
            and last_altered <= current_date - {{ days }} 
        {% endset %}

        {{ log('\nGenerating cleanup queries...\n', info=True) }}
        {% set drop_queries = run_query(get_drop_commands_query).columns[1].values() %}

        {% for query in drop_queries %}
            {% if dry_run %}
                {{ log(query, info=True) }}
            {% else %}
                {{ log('Dropping object with command: ' ~ query, info=True) }}
                {% do run_query(query) %} 
            {% endif %}       
        {% endfor %}
        
    {% endmacro %}
```
