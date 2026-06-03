## TO DO


1. ~~reorg stg layer~~
- folders, names, ymls

2. ~~etl_loaded_at~~

3. ~~freshness~~

4. ~~vars~~
- docker credentials
- profiles credentials
- dev db
- srv vars

5. ~~snapshots~~

6. reorg layers marts
- ~~fct_balances~~

7. python model

8. ~~incremental~~

---
## Full list

- reorg layers
    - ~~model folders stg~~
    - ~~model names stg~~
    - ~~source and schema yml stg~~
    - model folders mart
    - model names mart
    - schema yml mart 
    - python model
- incremental
    - clustering/partitioning
    - ~~different strategies~~
    - ~~schema change~~
- governance 
    - ~~docs -> doc blocks~~
    - tests
        - generic (configs)
        - custom
        - ~~freshness~~
    - grants/roles
- macros
    - ~~functions~~
    - ~~env vars~~
    - ~~docs~~
    - running query - run operation
        - ~~hooks~~
        - clean stale
- ~~data~~
    - ~~elt_loaded_at~~
- ci/cd
    - branches
    - environment
    - slim ci
    - linter
    - pipeline/deploy
- ~~snapshots~~
- data catalog
    - semantic models
- packages
    - ~~dbtfusion~~
    - ~~codegen (dbt labs git for commands)~~
    - dbt_utils  
    - dbt-jinja-functions
    - dbt_meta_testing package
    - dbt-coverage
    - dbt_expectations
    - audit_helper
    - check-model-has-tests
- threads


AI checks
- ~~fact/dim vs layers~~
    - ~~depends, but makes sense to have them on silver and then wide models (agg and joined) on gold~~
- ~~source/int/mart naming~~
    - ~~source~~
    - ~~int~~
    - ~~mart~~
- best packages to learn
- how to deploy locally