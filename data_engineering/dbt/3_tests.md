### Tests
- The `dbt_utils` package provides helpful singular tests to avoid writing custom SQL.
- Singular tests live in the `tests/` folder and do not require YAML definitions.
- You can test sources, but `dbt test` does not run freshness checks.

### Test Commands

```shell
dbt test                               # run all generic and singular tests
dbt test --select test_type:generic    # run only generic tests
dbt test --select test_type:singular   # run only singular tests
dbt build --fail-fast                  # doesnt skip failures, it stops the run
dbt build --store-failures              #  store the failed test results in the db and shows test query in the terminal so you can copy it
# stro-failures can also eb added to dbt_project.yml if you wanna save to all
```


### Freshness:

```yaml
    sources:
        - name: jaffle_shop
            database: raw
            schema: jaffle_shop
            tables:
            - name: customers 
            - name: orders
                freshness:
                warn_after:
                    count: 24
                    period: hour
                error_after: 
                    count: 48
                    period: hour
                loaded_at_field: _etl_loaded_at
```

### Generic tests

```yaml
    models:
    - name: stg_jaffle_shop__customers
        description: one unique customer per row
        columns:
        - name: customer_id
            description: the primary key
            tests:
            - unique
            - not_null

    - name: stg_jaffle_shop__orders
        columns:
        - name: order_id
            tests:
            - unique
                config:
                    where: order_date = current_date # condition when it can fail
                    limit: # limit the test query to return a subset (good for large models)~
                    store_failures: # same as the command, stores in the db so you don't need to add the flag to the command
            - not_null
              config: # so it doesnt fail the run in all cases
                severity: warn
                error_if: ">=100" 
        - name: status
            description: "{{ doc('order_status') }}"
            tests:
            - accepted_values:
                arguments:
                    values: ['placed', 'shipped', 'completed', 'returned', 'return_pending']
        - name: customer_id
            tests:
            - relationships:
                arguments:
                    to: ref('stg_jaffle_shop__customers')
                    field: customer_id
```

- you can also build a custom generic test to use in many models (using macros), then it can be added to the yaml as well

```jinja
{% test greater_than_five(model, column) %}

    select {{ column_name }}
    from {{ model }}
    where {{ column_name }} <= 5

{% endtest %}
```

- you can overwrite dbt native tests writing a custom test with the same name
- you can use test config to change test without rewriting them (these config can be added to custom tests as well)

## Advanced testing

**Good test**
- automated (low effort/repeatable)
- fast
- reliable (you should be abel to trust the result)
- informative (leaves clues to what fix)
- focused (should validate a single assumption so they can be independent)

### What to test

- assert something you assume is true (contents, constrain, grains)
    - e.g. `unique`, `not null`, `accepted_values` and `dbt_expectation.expect_column_proportion_unique_values_to_be_between`
- how models relate to each other
    - e.g. `relationships`, `dbt_utils.equality`, `dbt_expectations.expect_table_row_count_to_equal_other_table`
- business_logic
    - e.g. `sum(paymnets) >= 0` or `a + b + c = d` 
- freshness of sources
- temp tests during refactoring (e.g. `audit_helper` pack)

### Path to well tested project

| Level         | definition                                       
|---------------|--------------------------
| L1            | No tests                                         
| L2            | Primary key testing on final models
| L3            | Tests per model
| L4            | Advanced tests from packages
| L5            | High test coverage

### dbt_meta_testing package

Used in CI to guarantee all required tests exist. Defined in the `dbt_project.yml`

```yaml
models:
    project_name:
        +required_tests: {"unique.*|not_null": 2}
        marts:
            +materialized: true
```

Executed by running `dbt run-operation required_tests`

Some other packages to consider – Python
- **dbt-coverage**: Compute coverage from catalog.json and manifest.json files found in a dbt project, e.g. jaffle_shop.

- **pre-commit-dbt**: A comprehensive list of hooks to ensure the quality of your dbt projects.

- **check-model-has-tests**: Check the model has a number of tests.

- **check-source-has-tests-by-name**: Check the source has a number of tests by test name.

Some other packages to consider – dbt Packages

- **dbt_dataquality**: Access and report on the outputs from dbt source freshness (sources.json and manifest.json) and dbt test (run_results.json and manifest.json)

- **dbt-project-evaluator**: This package highlights areas of a dbt project that are misaligned with dbt Labs' best practices.

- **dbt_utils**: is a one-stop-shop for several key functions and tests that you’ll use every day in your project.

    - expression_is_true

    - cardinality_equality

    - unique_where

    - not_null_where

    - not_null_proportion

    - unique_combination_of_columns

- **dbt_expectations**: contains a large number of tests that you may not find native to dbt or dbt_utils. If you are familiar with Python’s great_expectations, this package might be for you!

    - expect_column_values_to_be_between

    - expect_row_values_to_have_data_for_every_n_datepart

    - expect_column_values_to_be_within_n_moving_stdevs

    - expect_column_median_to_be_between

    - expect_column_values_to_match_regex_list

    - expect_column_values_to_be_increasing

**audit_helper**: utilized when you are making significant changes to your models, and you want to be sure the updates do not change the resulting data. The audit helper functions will only be run in the IDE, rather than a test performed in deployment.

- compare_relations

- compare_queries

- compare_column_values

- compare_relation_columns

- compare_all_columns

- compare_column_values_verbose

### When to test

1. Developing

    develop -> `dbt build` -> (succeed -> PR / fail -> fix -> build ...)

2. Deploying

    trigger -> `dbt build` -> (succeed -> done / fail -> rollback/alert)

3. CI

    PR -> `dbt build -s state:modified` -> (succeed -> merge / fail -> reject)

4. QA branch
    - you have 3 branches: 
        - dev (where feat PRs go)
        - qa (where dev merges every x days)
        - prod (where qa merges if test in qa is successful)
