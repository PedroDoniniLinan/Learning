# Data Modeling and Data Mart Design


## Conclusion:
- Speed and simplicity for reporting => star schema.
- Storage efficiency and complex dimension hierarchies => snowflake schema.
- If you're managing large-scale data pipelines in a cloud data lake and want to build data progressively, the medallion architecture is your best choice.



### 1. Star Schema

**Definition**: A star schema is a type of database schema that consists of a central fact table surrounded by dimension tables. The fact table stores quantitative data (e.g., sales, transactions), while the dimension tables store descriptive information (e.g., date, product, customer) that provides context for the fact table's data.

**Structure**:
- Fact Table: Contains the metrics (e.g., revenue, number of orders) and foreign keys that reference the dimension tables.
- Dimension Tables: Each dimension table is connected to the fact table via a one-to-many relationship, and each contains descriptive attributes about the data (e.g., product name, customer name).

**Advantages**:
- Simple and easy to understand.
- Optimized for querying and reporting because of denormalized structure.

**Use Cases**:
- Ideal for business intelligence (BI) tools, where queries are often simple, focusing on aggregating data (e.g., sum of sales by region or product).
- Best for high-performance environments where speed is critical and complex relationships between dimensions are not needed.

Example: Sales Data Mart with fact table for sales and dimension tables for customers, products, and time.

### 2. Snowflake Schema

**Definition**: The snowflake schema is an extension of the star schema where dimension tables are normalized into multiple related tables, forming a more complex, hierarchical structure. Each dimension table is further split into sub-tables.

**Structure**: The fact table is the same as in the star schema, but dimension tables are normalized into multiple tables. For instance, in a product dimension, categories might be split into separate tables for product categories and subcategories.

**Advantages**:
- Reduces data redundancy by normalizing dimension tables.
- More efficient storage for large datasets with many repeated values.

**Disadvantages**:
- More complex queries due to multiple joins between dimension tables.
- Slightly slower query performance because of the additional joins.

**Use Cases**:
- Suitable for highly normalized systems where storage efficiency is important.
- Recommended when there are complex relationships between dimensions or when maintaining data consistency across multiple tables is essential.

*Example*: A Customer Data Mart where customer attributes (e.g., name, address, country) are split into separate normalized tables.


### Normal Forms

**1NF — First Normal Form**
Each column must hold **atomic values** (no lists or multiple values in one cell), and each row must be unique. No repeating groups.

> ❌ `phones: "912, 934"` → ✅ one phone per row

**2NF — Second Normal Form**
Must be in 1NF + every non-key column must depend on the **entire primary key**, not just part of it. Only relevant when you have a composite primary key.

> ❌ In a table keyed by `(order_id, product_id)`, storing `customer_name` which only depends on `order_id` violates 2NF

**3NF — Third Normal Form**
Must be in 2NF + no **transitive dependencies** — non-key columns must depend only on the primary key, not on other non-key columns.

> ❌ Storing both `zip_code` and `city` where `city` depends on `zip_code`, not the primary key (non-key -> non-key)

**BCNF — Boyce-Codd Normal Form**
A stricter version of 3NF. Every determinant (column that determines the value of others like a key) must be a candidate key (able to determine a row). Handles edge cases 3NF misses when there are **multiple overlapping composite keys** (e.g. when a non-key -> key determination exists).

**4NF — Fourth Normal Form**
Must be in BCNF + no **multi-valued dependencies** — a row shouldn't store two independent multi-valued facts about an entity in the same table.

> ❌ A table storing both a person's hobbies and languages spoken independently of each other

**5NF — Fifth Normal Form**
Must be in 4NF + the table cannot be decomposed into smaller tables without losing information. Eliminates **join dependencies**. Rarely applied in practice.

---

In practice, **3NF or BCNF** is the target for transactional databases, while data warehouses **intentionally denormalize** (Star Schema) for query performance.

### 4. Medallion Architecture (specific to Delta Lake/Databricks frameworks)

**Definition**: The medallion architecture is a multi-layered approach typically used in data lakes. It organizes data in stages or layers (Bronze, Silver, Gold) to progressively refine and enhance the data.

**Structure**:
- *Bronze Layer*: Raw, unfiltered data ingested from various sources, potentially containing duplicates or errors.
- *Silver Layer*: Cleaned and filtered data, often enriched with business logic, joins, and transformations. This data is used for reporting and analytics.
- *Gold Layer*: Highly curated data, often aggregated and transformed into specific data marts for business reporting or machine learning models.

**Advantages**:
- Supports incremental data processing and data refinement over multiple stages.
- Allows for data quality checks and validation at each layer.
- Facilitates historical tracking and can work well with streaming and batch data.

**Use Cases**:
- Ideal for big data environments where you want to separate raw and curated data for incremental processing.
- Useful in data lakes where you need a flexible system for building data pipelines and where data governance is essential.

*Example*: A machine learning data mart where raw event data (Bronze) is processed, cleaned, and joined with other tables (Silver) and then used for specific machine learning features (Gold).


