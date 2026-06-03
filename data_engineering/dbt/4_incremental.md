# Incremental

- **Ephemeral tables:** Do not exist in the warehouse.  
- **Incremental models:** Exist in the warehouse and only update new data.
  - `{% if is_incremental() %}` is typically used for the incremental filter, allowing `--full-refresh` when needed.
  - `{{ this }}` represents the current state of the model before the update.

---

## Paritioning

- Snowflake uses clustering keys instead of traditional partitions — it automatically micro-partitions data and clustering tells it how to organize those partitions.
```jinja
{{ config(
    materialized='table',
    cluster_by=['order_date', 'region']
) }}
```
- BigQuery has native partitioning support and dbt exposes it directly
```jinja
{{ config(
    materialized='table',
    partition_by={
      "field": "order_date",
      "data_type": "date",
      "granularity": "month"
    },
    cluster_by=['region', 'status']
) }}
```

## Incremental Strategies

### Merge (upsert / merge into)
- Performs a full table scan → requires good partitioning and a primary key.  
- Does not require a time value.

### Append (insert)
- Simply inserts new rows.

### Delete + Insert
- Useful when merge is not supported.  
- Performs a full table scan → requires good partitioning.

### Insert Overwrite (replace entire partitions)
- Similar to delete + insert but without a full scan.  
- Requires partitioning

### Microbatch
- Requires an event time; does not rely on `is_incremental`.  
- Splits data into time-unit batches (e.g., daily).  
- Executes delete + insert per batch.  
- Must not skip runs → skipped batches create data gaps.  
- `{{ config }}` typically needs:
  - `unique_key`
  - `event_time`
  - `begin` (date)
  - `batch_size` (e.g., day)  
- Can re-run failed batches using event_time start/end.

---

## Additional Notes
- Depending on the cutoff date for updates, inconsistencies may occur.  
  - Evaluate the optimal cutoff and run full-refresh periodically if needed.

---

## Good Use Cases
- Event streams (no updates).  
- Models with a reliable `updated_at`.

## Poor Use Cases
- Small tables.  
- Constantly changing datasets.  
- Transformations requiring comparisons across rows.

---

## Schema changes

- dbt_project.yml:

    ```yaml
    models:
        +on_schema_change: "<<strategy_name>>"
    ```

| | New columns | Removed columns | Type changes |
|---|---|---|---|
| `ignore` | Ignored | Fails | Ignored |
| `fail` | Fails | Fails | Fails |
| `append_new_columns` | Added (NULL history) | Kept in table | Not handled |
| `sync_all_columns` | Added | Dropped | Handled |

- Fail process (dev/CI)

```
Schema changed → fail fires
        │
        ├── Full refresh is affordable?
        │         └── Yes → --full-refresh, done
        │
        ├── Additive change only (new column)?
        │         └── flip to append_new_columns, run once, flip back to fail
        │
        └── Large table, can't full refresh, complex change?
                  └── ALTER TABLE manually + document it + ignore for one run
```

## External

https://learn.getdbt.com/learn/course/incremental-models/incremental-strategy-30min/incremental-strategy?page=11


# Strategies (full)

## Append
- Adds new rows to the target table only  
- Does not check for duplicates  
- Does not check for updates  
- **Best used for:** Truly immutable event streams  
- **SQL used:** `insert into` to add new rows  

---

## Merge
- Updates records that already exist using the primary key  
- Inserts new records based on the primary key  
- Runs a full table scan (can impact performance at scale)  
- **Best used for:**  
  - Models receiving new data **and** updates  
  - Handling duplicates that append cannot address  
  - Tables with a small number of updates per run  
- **SQL used:** `merge into` with matching on primary key  

---

## Delete + Insert
- Selects all relevant records  
- Deletes the old versions in the target table  
- Inserts new and updated records  
- Requires a full table scan (unless incremental predicates are configured)  
- **Best used for:**  
  - Models that receive new data and updates  
  - Platforms that **do not support MERGE**  
- **SQL used:** `delete from` + `insert into` with matching on primary key  

---

## Insert Overwrite
- Replaces entire partitions in the destination table  
- Does not require scanning the entire source table—only configured partitions  
- More efficient than merge on BigQuery  
- **Best used for:**  
  - Partitioned models receiving new and updated data  
  - Situations where merge is too slow or costly  
  - Most useful on BigQuery  
- **SQL used:**  
  - **BigQuery:** creates temp table → declares partitions to replace → `merge into`  
  - **Other databases:** `DELETE FROM` then `INSERT INTO`  

---

## Microbatch
- Divides data into small, time-bounded slices (e.g., daily)  
- Splits large models into multiple queries (batches)  
- dbt inserts each batch into the target table  
- **Best used for:**  
  - Very large time-series datasets  
  - Time series with regular updates  
- **SQL used:**  
  - Time-bounded `SELECT` to construct each batch  
  - Batch insertion uses insert_overwrite or delete + insert depending on the platform  

## CI example

- Trigger on PRs

- avoid full-refresh for new incremental models

- only runs modified models

- ci.yml:

    ```shell
    -- "find all incremental models that already exist in prod and are part of the modified lineage" — and clone them into your dev environment.
    dbt clone --select state:modified+, config.materialized:incrementl,state:old 

    dbt build --select state:modified+
    ```



