Here is a "cheat sheet" of Python and Pandas functions specifically curated for Analytics Engineering interviews. These focus on data transformation, cleaning, and efficient lookups.

### 1. Essential Dictionary & List Tricks
* **`.get(key, default)`**: The safest way to access a dictionary. It prevents `KeyError` if a key is missing.
    * *Example:* `mapping.get('SKU_123', 'N/A')`
* **Dictionary Comprehension**: Great for creating lookups or filtering metadata.
    * *Example:* `{k: v for k, v in data.items() if v > 0}`
* **`**kwargs` Unpacking**: Merge dictionaries or add keys to existing ones quickly.
    * *Example:* `new_dict = {**old_dict, "new_key": "value"}`
* **`zip()`**: Merging two lists (like headers and rows) into a dictionary.
    * *Example:* `dict(zip(keys_list, values_list))`

```python
transactions = [{"id": 1, "sku": "A101"}, {"id": 2, "sku": "B202"}]
sku_map = {"A101": "Electronics", "B202": "Home"}

# Mapping with a default 'Unknown' in case the SKU isn't in our map
enriched_data = [
    {**t, "category": sku_map.get(t["sku"], "Unknown")} 
    for t in transactions
]
```

### 2. Pandas "Power User" Functions

* **`.json_normalize()`** : normalize nested dict
```python
raw_data = [{'id': 1, 'info': {'name': 'Alice', 'city': 'NY'}}]
df = pd.json_normalize(raw_data)
# Result: Columns become 'id', 'info.name', 'info.city'
```

* **from list**
```python
# You must manually provide the column names
df = pd.DataFrame(data, columns=['Name', 'Age', 'City'])
```

----------------------------------------------------

#### filters

* **`df.loc`**: Use this for conditional updates. It is faster and more explicit than chained indexing.
    * *Example:* `df.loc[df['price'] < 0, 'status'] = 'Error'`
* **`np.where()`** (The "CASE WHEN" equivalent)
While you can use .loc, numpy.where is the cleanest way to create a new column based on a condition

```python
df['performance'] = np.where(df['sales'] > 250, 'High', 'Low')
```

* **logic filters**
```python
# Filter for orders that are 'shipped' AND revenue is over 100
shipped_high_value = df[(df['status'] == 'shipped') & (df['revenue'] > 100)]
# Filter for orders that are 'cancelled' OR 'returned'
flagged_orders = df[(df['status'] == 'cancelled') | (df['status'] == 'returned')]
```

* **`.isin()`**: The Pandas equivalent of SQL’s `IN (...)`.
    * *Example:* `df[df['country'].isin(['US', 'UK', 'CA'])]`


* **text filters**
```python
# Exclude internal test accounts (SQL: WHERE email NOT LIKE '%@test.com')
real_customers = df[~df['email'].str.contains('@test.com', na=False)]

# Pattern: Start(^) -> 2 Letters -> Hyphen -> 4 Digits -> End($)
pattern = r'^[A-Z]{2}-\d{4}$'
df['is_valid_sku'] = df['sku'].str.match(pattern)
# Filter for invalid ones to investigate
invalid_skus = df[df['is_valid_sku'] == False]
```

----------------------------------------------------

* **`.diff(periods=1)` and `.shift()`**: 

    - periods=1 (Default): Calculates $Row_{n} - Row_{n-1}$.
    - periods=-1: Calculates $Row_{n} - Row_{n+1}$ (Current minus the next row).
    - periods=2: Calculates $Row_{n} - Row_{n-2}$ (Skipping a row).

* **`.sort_values(['col_a', 'col_b'], ascending=[True, False])`**:

```python
df = df.sort_values(by=['user_id', 'timestamp'])
df['prev_price'] = df['price'].shift(1)  # Moves data down 1 row
df['price_delta'] = df['price'].diff()   # Current minus previous
```

#### transformation functions
* **`map()`** vs. **`apply()`**:

```python
# .map() - Fast dictionary lookup for a single column
df['status_name'] = df['status_id'].map({1: 'Active', 0: 'Inactive'})

# .apply() - Flexible logic (lambda)
df['discount_price'] = df['price'].apply(lambda x: x * 0.9 if x > 100 else x)
```

#### groupby functions

* **`.transform()`**: Unlike `.agg()`, which reduces the number of rows, `.transform()` performs a calculation and returns a result with the same length as the original DataFrame. Perfect for window functions.
```python
# SQL equivalent: SUM(sales) OVER(PARTITION BY store)
df['store_total'] = df.groupby('store')['sales'].transform('sum') # mean, max, cumsum, lambda, functions

# Now you can calculate the contribution of each row to its group
df['pct_of_store'] = df['sales'] / df['store_total']
```

* **`.agg()`**:
```python
df.groupby('store')['sales'].agg(['sum', 'mean', 'std'])
```

* **`.filter()`**:
```python
# Keep only users who have more than 5 orders in the entire dataset
loyal_customers = df.groupby('user_id').filter(lambda x: len(x) > 5)
```

----------------------------------------------------

#### datetime functions


* **`.dt` accessor**: Essential for time-based engineering.
    * `df['ts'].dt.hour`, `df['ts'].dt.date`, `df['ts'].dt.to_period('M')`

```python
# Convert to datetime object
df['date'] = pd.to_datetime(df['raw_date'])

# Extract features
df['month'] = df['date'].dt.month
df['is_weekend'] = df['date'].dt.dayofweek >= 5
```

----------------------------------------------------

#### cleaning functions

* **`.fillna()` vs `.dropna()`**: Know the difference between filling a null with a placeholder and removing the record entirely. 
* **`.astype()`**: Used for schema enforcement. Use `.astype('category')` for low-cardinality strings to save memory, or `astype(int)` to clean up IDs.
* **`.duplicated()` and `.drop_duplicates()`**: Always ask the interviewer: "Should I check for duplicate primary keys here?" It shows you care about data integrity.

```python
# Check for duplicates across specific columns
duplicates_exist = df.duplicated(subset=['user_id', 'timestamp']).any()

# Keep only the most recent entry
df_clean = df.sort_values('timestamp').drop_duplicates(subset=['user_id'], keep='last')

# Null count
df.isna().sum()
```
----------------------------------------------------

#### shape functions

* **`.melt()`** : wide to long

```python
# Wide Data: One column per year
df = pd.DataFrame({'Product': ['A'], '2022': [100], '2023': [150]})

# Melt to Long: Great for BI tools like Tableau/Looker
df_long = df.melt(id_vars='Product', var_name='Year', value_name='Sales')
```

* **`.pivot()`** : long to wide

```python
# Create a matrix of sales by Region and Category
pivot = df.pivot_table(index='Region', columns='Category', values='Sales', aggfunc='sum')
```

----------------------------------------------------

#### Other

* **`str.contains()`** vs. **`str.extract()`**:

```python
# SQL equivalent: WHERE email LIKE '%@gmail.com'
gmail_users = df[df['email'].str.contains('@gmail.com', na=False)]

# Regex: Extract numbers from a string like "Order #12345"
df['order_id'] = df['note'].str.extract(r'(\d+)')
```


* **`value_counts()`** vs. **`nunique()`**:

```python
# How many orders per status? (SQL: GROUP BY status, COUNT(*))
status_dist = df['status'].value_counts()

# How many unique customers do we have? (SQL: COUNT(DISTINCT user_id))
unique_users = df['user_id'].nunique()
```
* Other

```python

# Pattern: [^...] means "Anything NOT in this set"
# This keeps digits (0-9) and periods (.)
df['clean_price'] = df['price'].str.replace(r'[^0-9.]', '', regex=True).astype(float)
# Split by either a comma, a pipe, or a semicolon
df['tags_list'] = df['raw_tags'].str.split(r'[,|;]')

```

### 4. Logical Comparisons (The Cheat Sheet)

| Task | SQL Equivalent | Pandas/Python |
| :--- | :--- | :--- |
| **Filter Rows** | `WHERE col = 'x'` | `df[df['col'] == 'x']` |
| **Join Tables** | `JOIN table_b ON ...` | `pd.merge(df1, df2, on='id', how='left')` |
| **Concatenate** | `UNION ALL` | `pd.concat([df1, df2])` |
| **Window Func** | `RANK() OVER(...)` | `df.groupby('id')['col'].rank()` |
| **Case Statement** | `CASE WHEN... THEN` | `np.where(condition, if_true, if_false)` |

### Interview Pro-Tip: "Vectorization"
If the interviewer asks why you chose a certain Pandas function over a `for` loop, your answer should be: **"Vectorization."** Pandas operations are built on C; they perform operations on entire arrays at once. A `for` loop in Python is "element-wise" and significantly slower. Showing that you understand this performance difference is a huge green flag for engineering roles.