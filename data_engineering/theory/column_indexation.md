### ** Both can be done on dbt *config*

# Indexing

#### Purpose: 

Improves query performance by allowing the database to find and retrieve rows more efficiently without scanning the entire table.

*Write slowdown on indexed columns*

#### How It Works: 

An index creates a separate data structure that contains the values of the indexed column and pointers to the corresponding rows in the table. This structure is usually sorted, allowing for faster searches

Index type (e.g., B-tree [Balanced tree], Hash, GiST)


## Types

### Clustred vs Unclustered

- Clustered: Determines the physical order of data in a table. There can be only one clustered index per table since it defines how data is stored.
-- Good for dates

- Unclustered: A separate structure from the data table that contains pointers to the actual data. Multiple non-clustered indexes can exist on a table. 
-- Good for columns frequently filtered or joined on

### Single vs Composite

- Single: index on single column
- Composite: index on multiple columns -- good when they are filtered together


### Unique vs Full text

- Unique: on uuid columns, enforces uniqueness -- speed up look up
- Full text: keyword and pattern searches w/o a full mathc -- good for large text 
- Others

# Partitioning

Partitioning is the process of dividing a large table into smaller, more manageable pieces called partitions. Each partition is treated as a separate table, allowing for more efficient querying and management of data.

Where indexing helps the database find rows faster, partitioning helps it skip entire chunks of data it doesn't need.

- Range:  splits data by a value range, most commonly a date. A query for March 2024 only touches the March partition, ignoring everything else. Best for time-series and transactional data.
- List: splits by a defined set of values, like country or region. Good when you frequently filter by a known category.
- Hash: distributes rows evenly across partitions using a hash function. Useful when there's no natural range or list — ensures balanced partition sizes.