## Environements

| feat  | dev                           | deployment
|-      |-                              |-
|dbt    |1.3 (env.settings)             | 1.3 (env.settings)    
|git    |feat/x (IDE interface)         | main (env.settings)
|db     |dbt_pdl (profile setting)      | analutics (env.settings)   

---

**Jobs**: sequence of dbt commands
- based on how often they need to run


## Deployment architectures

**One trunk**: `feat` branches merge driectly into `main`
- simple, but risks bad code merged into main

**Many trunk**: `feat` branches merge into a `qa` branch where env tests are made before merging into `main`


## Job types

**Standard**
- build all
- typically daily
- leverages incremental

**Full refresh**
- build all
- typically weekly
- rebuilds incrementals (for most accurate info)


**Time sensitive**
- build a subset
- several times in a day

**Fresh rebuild**
- checks if source is updated and rebuilds downstream
* dbt >= 1.1
- `dbt build -s source_status:fresher+`

---

- One pit fall is having too many specific jobs~
- You can tag models with the freq of update
- You can use exposures to update only specific models
- You can use folders as well to run specific models

### dbt commands

- `dbt build -s +m1 +m2` (runs both models with rerunning overlapping models)
- `dbt build -s +m1, +m2` (runs only shared models)