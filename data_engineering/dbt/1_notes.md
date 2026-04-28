# ELT in dbt

## Why ELT

- Loads raw data into the warehouse first and uses warehouse compute for transformations.  
- Provides faster access to raw data since loading happens before transformation.  
- Supports iterative, flexible transformation without reloading data.  
- Improves data access across teams by centralizing raw data.  
- Reduces infrastructure costs by shifting compute to the cloud.  
- dbt provides version control, testing, and automation for the transformation layer.
- dbt is idempotent (many runs, same result) and stateless
- but it stores state in `manifest.json` and `run_results.json`
    - like the `state:modified+`
    - `dbt retry` runs from the last point of failure of the alst command

---

## Best Practices

### Development Environment

- Each user should have their own schema/database for development.  
- Use `{{ doc() }}` for descriptions. Multiple docs can be defined in a single `.md` file and reused across the project.  
- Maintain one `source.yml` and one `schema.yml` per subfolder of intermediate models.  
- Always include a unique/not-null test for primary keys.  
- Add relationship tests for foreign keys.  
- Models from external sources should only have `_etl_loaded_at`.  
- Use `_macros_doc.yml` to describe functions and arguments.  
- Balance DRY principles with readable macro usage.
- Seeds should be used for small data and not frequently changing data
- `dbt clone`: if a data obj already exists in prod, you can `dbt clone` to create a copy without the data for testing

### Layer & Naming Conventions

**Layers**

- **Source**: Raw data ingested into the warehouse.  
- **Staging**: 1:1 mapping to sources; rename columns, cast types, currency conversions.  
- **Intermediate**: Business logic, joins, aggregations (avoid using sources directly).  
- **Marts**:  
  - **Facts**: Quantitative, immutable event streams (long tables).  
  - **Dims**: Qualitative, mutable, slowly changing (wide tables).

--- 
 Only for dbt cloud you can query, with core only definition and lineage

- **Semantic layer**: 
  - centralize business metric definitions: metrics folder with one yml per mart with metrics coming from it and models coming from it
  - between models and BI tools
  - **Semantic models**: defined in the schema.yml as `semantic models` in files
    - **Entities** — the keys used to join semantic models together
    - **Dimensions** — the attributes you group or filter by, either categorical or time-based
    - **Measures** — the aggregations that become the building blocks for metrics

```yaml
    semantic_models:
        - name:
          defaults:
            agg_time_dimensions: date_at
          description:
          model: ref(dim_ | fct_)
          entities:
            - name: customer
              expr: customer_id
              type: primary
          dimensions:
            - name: customer_name
              type: categorical
            - name: first_ordered_at
              type: time
              type_params:
                time_granularity: day
          measures:
            - name: customers
              expr: customer_id
              agg: count_distinct
            - name: lifetime_spend
              agg: sum
```
  - **Metrics**: defined in the schema.yml as `metrics`

```yaml
    metrics:
        - name: "customers_with_orders"
          description: "Unique count of customers placing orders"
          label: "customers"
          type: simple | cumulative
          type_params:
            measure:
                name: customers
```
--- 

**Naming**

    <model_type>_<source>__<name>
    stg_jaffle_shop__orders


---

## Subqueries

**Pros**

- Modular: break down complex logic into inner queries.  
- Improves readability by encapsulating logic.  
- Flexible: usable in SELECT, WHERE, FROM, etc.

**Cons**

- Can be inefficient, especially correlated subqueries.  
- Deeply nested subqueries can be hard to read and maintain.

---

## CTEs (Common Table Expressions)

**Pros**

- Enhance readability by breaking queries into logical, named parts.  
- Reusable within the same query.  
- Support recursion (useful for hierarchical data).

**Cons**

- Scope-limited: only exists within the query where defined.  
- Not persisted in the database; temporary constructs only.

---

## dbtfusion

- Preview CTE button available (early version).  
- Offers several IntelliSense features worth exploring.

---

## Minor Tips

- After cloning a dbt repo, run `dbt init` to create `profiles.yml`.  
- Use `dbt compile` to check model compilation and connectivity.  
- `dbt build` runs models, tests, seeds and snapshots
- Reload VS Code window if the dbt extension lags.  
- For packages from Git, set `git: <clone_url>` and `revision: <branch>` in YAML.

---

## Code Generation (Codegen)

- Add `packages.yml` at the same level as `dbt_project.yml` and run `dbt deps`.  
- Use dbt Labs GitHub documentation for terminal commands:  
  - `generate_source` for generating `source.yml`.  
  - `generate_base_model` for generating a staging model base.

---

## Macros

- **dbt-labs/dbt_utils**: `data_spine` (rows within a date range).  
- **gitlabhq/snowflake_spend**: models for Snowflake usage/costs.  
- **dbt-jinja-functions**: advanced Jinja references; can use `target` dict from profile.  
- `dbt run-operation` executes macros (`--args '{"param":"value"}'`).  
- `log()` prints inside macros.  
- `execute` variable is `true` when dbt runs models; otherwise `false`.  
- `generate_schema_name` controls default/custom schema usage.

---

## dbt_project.yml Snippets

**Configure materialization for a folder:**

```yaml
models:
  <project_name>:
    <folder_name>:
      +materialized: view
```

### Run a folder:

    dbt run -s staging

### Grants

Grants can also be configured in the `dbt_project.yml`, to models, seeds or snapshots, using:

```yaml
  config:
    grants:
      select: ['role_name'] # permission: [roles] -it revokes on any role that is not here
      +select: ['role_name'] # this does not overwrite
```

- Can also be given on a obj level

## Python models

```python
import ...

def model():
  dbt.config(materialize="table", ...)
  sql_model_df = dbt.ref('model_name').to_pandas()
  final_df = ...
  return final_df
```

## Migration Process

1. **Translate Raw Tables to Sources**  
   - Create `source.yml` files.  
   - Replace direct table references with `{{ source() }}` in models.

2. **Refactor Code**  
   - Place the final model in the desired location.  
   - Perform cosmetic cleanup (formatting, naming consistency).  
   - Organize CTEs logically:  
     - **Import CTEs** → **Logic CTEs** → **Final CTEs**  
     - Import CTEs should primarily be `SELECT *` from reusable tables.

3. **Create Staging Models**  
   - Build models directly from sources.  
   - Apply simple transformations: concatenations, numeric ordering, renaming, type casting.

4. **Create Intermediate Models**  
   - Break down complex logic into reusable components.  
   - Ensure intermediate models simplify queries and can be reused across multiple models.

5. **Finalize Marts**  
   - Build final models in the **marts layer** (dimension and fact tables).  
   - Ensure models follow business logic requirements.

6. **Auditing**  
   - Use dbt’s `audit-helper` package to validate data integrity and completeness.

---

## Definitions

- **Data object**: Any entity that can be queried or manipulated within the data platform.  
  This includes tables, views, and other database objects that store and organize data.


## External

- dbt commands: 
    - https://docs.getdbt.com/category/list-of-commands
    - https://docs.getdbt.com/reference/node-selection/syntax
