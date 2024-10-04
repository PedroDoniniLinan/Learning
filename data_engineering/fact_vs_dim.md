# Fact vs Dim

## Fact

**Definition**
- stores quantitative data
- event like data
- central table in star or snowflake
- FK to dim
- can be large

## Dim

**Definition**
- descriptive attributes
- filter, group, and label data in fact
- fewer rows

#### Types

**Slowly Changing Dimension (SCD)**: dimensional data over time
- Type 1: Overwrites the old value with the new one
- Type 2: Creates a new row with a timestamp for the change
- Type 3: Tracks limited historical changes (e.g., keeping the old and new value in separate columns)


**Conformed**:  shared across multiple fact tables

**Junk**: low-cardinality, unrelated attributes (e.g., flags, statuses) into a single table to avoid having too many small dimension tables

**Degenerate**: transaction/order IDs (doesn’t have its own table)

**Role-Playing**: Date dimension (single  dimension table) used for both Order Date and Ship Date