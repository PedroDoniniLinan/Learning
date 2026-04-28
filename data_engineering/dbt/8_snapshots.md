# Snapshots

- `dbt snapshot`
- Snapshots live in the `snapshots` folder.
- Recommended to run them in a separate schema to avoid accidental drops/updates.
- Always snapshot sources; sometimes also snapshot facts and dimensions.
  - This allows rebuilding all downstream models and comparing historical changes.
  - Good for mutable sources
  - Facilitate creating Type 2 SCD models later on
- Snapshot tables include: `valid_from`, `valid_to`, `updated_at`, and `dbt_scd_id`.
- Multiple snapshots insert only changed values into the same table (`check` strategy) or new values based on `updated_at` (`timestamp` strategy).
- Defined in YAML:

    ```yaml
    snapshots:
      - name: string
        description:                # optional
        relation: source() or ref()
        config:
          database:                 # optional
          schema:                   # optional
          alias:                    # optional
          unique_key: column/expression
          hard_deletes:             # optional
          snapshot_meta_column_names: # optional
          strategy: timestamp or check
          check_cols:
          updated_at:
    ```

## Strategies

### Timestamp
- Uses a timestamp column to identify changes in source data.
- More efficient.

### Check
- Used when there is no `updated_at` column.
- Compares defined columns to detect changes.

## Example

```yaml
snapshots:
  - name: orders_snapshot          # snapshot table name
    relation: source('jaffle_shop', 'orders')
    config:
      schema: snapshots
      database: analytics
      unique_key: id
      strategy: check
      check_cols: ['id', 'user_id', 'order_date', 'status']
      hard_deletes: ignore
      dbt_valid_to_current: "to_date('9999-12-31')"
