### ** Both can be done on DBT

# Indexing

#### Purpose: 

Improves query performance by allowing the database to find and retrieve rows more efficiently without scanning the entire table.

#### How It Works: 

An index creates a separate data structure that contains the values of the indexed column and pointers to the corresponding rows in the table. This structure is usually sorted, allowing for faster searches

Index type (e.g., B-tree, Hash, GiST)


## Types

### Clustred vs Unclustered

- Clustered: Determines the physical order of data in a table. There can be only one clustered index per table since it defines how data is stored.
-- Good for dates

- A separate structure from the data table that contains pointers to the actual data. Multiple non-clustered indexes can exist on a table.
-- Good for other columns

### Single vs Composite

- Single: index on single column
- Composite: index on multiple columns


### Unique vs Full text

- Unique: on uuid columns
- Full text: good for large text

# Partitioning

Partitioning is the process of dividing a large table into smaller, more manageable pieces called partitions. Each partition is treated as a separate table, allowing for more efficient querying and management of data.