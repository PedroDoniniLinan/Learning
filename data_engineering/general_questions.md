#### Why are joins in Warehouses slower than in transactional DBs (MySQL)?

**1. Data Volume and Scale**
* **Data Warehouse**: Large data for analytical queries
* **Transactional DB**: Real-time, operational data (smaller)

**2. Indexing**
* **Data Warehouse**:
    - Not always extensive indexing
    - Joins can involve full scans which are slower on larger datasets
* **Transactional DB**:
    - Extensively uses indexing to speed up frequent, smaller transactions and joins
    - Smaller data, where indexes improve joins

**3. Data Storage Architecture**
* **Data Warehouse**:
    - **columnar storage**, optimized for aggregations, but less efficient for row-based operations (joins)
* **Transactional DB**:
    - **row-based storage**, optimized for accessing or modifying entire rows, such as joins
