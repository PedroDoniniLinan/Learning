Sure! Let me give you some context first.

---

**Databricks is a data platform** that runs on cloud storage (S3, ADLS, GCS). Unlike a traditional database where data lives inside the database engine itself, in Databricks your data is just **files sitting in cloud storage**, and Databricks reads/writes those files when you query.

This is why some configs that don't exist in Snowflake or Postgres show up here — you have much more control over *how* those files are stored and managed.

---

### `file_format`
Since data is stored as files, you can choose the file format. **Delta** is Databricks' own format (built on Parquet) and the default — it adds features like ACID transactions, time travel, and schema enforcement on top of plain files. You generally always want Delta unless you have a specific reason not to.

---

### `location_root`
By default, Databricks decides where in cloud storage to put your table's files — that's a **managed table**. If you set `location_root`, you're saying "put the files *here* instead" — that becomes an **external table**. The practical difference: if you drop a managed table, the files are deleted too. If you drop an external table, the files stay. Useful when other systems also need to read those files directly.

---

### `partition_by`
Instead of storing all your data in one big file blob, partitioning physically splits the files into folders by a column's value — e.g. one folder per date. So `date=2024-01-01/`, `date=2024-01-02/`, etc. When a query filters by that column, Databricks skips all the irrelevant folders entirely and only reads the relevant ones. Big performance win on large tables, but only if you actually filter by that column often.

---

### `tblproperties`
Delta tables have internal settings you can toggle. Two common ones:

- **`delta.enableChangeDataFeed`** — makes Delta track row-level changes (inserts, updates, deletes). Useful if downstream systems need to know *what changed*, not just the current state.
- **`delta.autoOptimize.optimizeWrite`** — Delta can write many small files over time, which hurts read performance. This setting makes Databricks automatically compact them into fewer, larger files when writing.

---

### `databricks_tags`
Just metadata labels you attach to a table in the Databricks catalog (like AWS resource tags). Useful for governance — tagging tables by team, domain, PII sensitivity, cost center, etc. The catch dbt has is that once applied, they can't be removed through dbt itself.

---

### `databricks_compute`
Databricks lets you have multiple clusters or SQL warehouses running at the same time. This config lets you tell dbt "run *this specific model* on *this specific cluster*" instead of the default one. Handy when you have one small cheap warehouse for most models but a few very heavy models that need more power.

---

### `incremental_strategy` (Databricks flavour)
You already know incrementals — this just controls *how* dbt updates existing rows:
- **`merge`** — upsert: update matching rows, insert new ones. Most common.
- **`append`** — only adds new rows, never touches existing ones.
- **`insert_overwrite`** — replaces entire partitions at once instead of row-by-row. Pairs well with `partition_by` for date-partitioned tables.

---

### `merge_update_columns`
When using `merge`, by default dbt updates *all* columns on a matching row. With this you can restrict it to only update specific columns — useful when you want to preserve values like `created_at` or a manually-set flag that shouldn't be overwritten by the merge.