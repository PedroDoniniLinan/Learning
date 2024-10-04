# ETL vs ELT

### ELT (Extract, Load, Transform): 

**Definition:** Data is extracted from the source and loaded as-is into the destination (e.g., cloud data warehouse), and then transformations occur within the data warehouse.

**Pros**

- Cloud DW: faster and more efficient transformations
    - powerful cloud data warehouses (e.g., AWS Redshift, Google BigQuery, Snowflake)
- Scalability: reduce bottlenecks
    - load 1st then transforms are done in parallel
- Flexibility: reprocessing or updating transformations
    - raw data is unchanged
- Cost: cheap store cost and process on-demand
    - cloud DW optimized for storing and processing vast amounts of raw data at lower costs

### ETL (Extract, Transform, Load)

**Definition**: Data is extracted from the source, transformed in a staging environment, and then loaded into the destination (e.g., data warehouse).

**Pros**

- Compliance & Sensitive Data: ensure that transformations (like data masking or encryption) occur before loading into the warehouse.

**Staging area:**
- temporary storage
- buffer for cleansing, transformation, and validation

S3 bucket or other cloud storeage: 
- big data 
- semi or unstructured

DB:
- smaller datasets
- SQL transformations

File System or Cloud Storage