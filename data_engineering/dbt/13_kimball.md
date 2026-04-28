# Key Concepts to Know

## Dimensional Modeling Basics

- Introduced by Ralph Kimball. 

- Breaks raw, normalized data into fact and dimension tables. 

- Purpose: make analytics simpler, faster, and more business-aligned. 

- Advantages: fewer joins via surrogate keys, re-usable (conformed) dimensions, better performance, business process alignment. 

## Modeling Process (with dbt)

- Define the grain of the fact table: in the example, one row per order detail. 

### Identify fact table(s) and dimension table(s):

- Fact: fct_sales with data from salesorderheader + salesorderdetail. 

- Dimensions: product, address, customer, credit card, order status, date. 

- Choose star schema over snowflake to reduce join complexity. 

### Building Dimension Tables

- Create a surrogate key for each dimension:

- Approach: hash natural keys (via dbt_utils.generate_surrogate_key(...)). 

- Select only the relevant attributes (columns) needed for business analysis. 

- Decide on materialization: dimension tables are often table or view in dbt. 

- Document and test: use .yml to define documentation and tests (e.g. not_null, unique). 

### Building the Fact Table

- Join on the correct keys to preserve the chosen grain. 

- Generate a surrogate key for fact using natural key columns (e.g. order_id + detail_id) with the generate_surrogate_key macro. 

- Generate foreign surrogate keys that reference the corresponding dimension surrogate keys (product_key, customer_key, etc.). 

- Choose materialization strategy: for large fact tables, incremental materialization is common, but in the example they use table. 

- Document and test columns in the fact table as well using .yml. 

## Best Practices & Considerations

- Surrogate keys make joins simpler for BI consumers. 

- Conformed dimensions: re-use dimensions across fact tables to avoid duplication. 

- Choosing star schema helps performance and simplicity for analytics. 

-Documentation and testing are integral — not optional. Helps ensure data quality and clarity.

- Materialization choices depend on data volume: dimension tables can often be full tables, fact tables might need incremental strategy.

## Why This Matters in an Interview

- Demonstrates you understand dimensional modeling theory (Kimball method) and practical implementation (with dbt).

- Shows you can bridge business needs and data engineering: identifying business process, translating into facts + dimensions.

- Illustrates your ability to design performant data models (star schema, surrogate keys).

- Reflects best practices around testing, documentation, and maintainability.

- Proves knowledge of dbt-specific techniques (ref, macros, materialization, seeds).