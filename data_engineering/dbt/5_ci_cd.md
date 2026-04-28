## **CI/CD**

Def.: Automated builds and tests

Main branch has a daily `dbt build` job

On a Feat branch you expect: 
1. Modifications
2. `dbt build` on dev (you'd hope everyone does this)
3. Open PR for Merge

*Solution*: job on PR (CI) that runs `dbt build` before merge on a schema only for CI not dev nor prod

#### Slim CI

Instead of running the whole DAG on PR, build only modified/affected models to save compute. Others defer from last prod run.

`dbt build -s state:modified+`

*Remark*: job on PR builds on a temp PR schema (dropped after merge), so there is no conflict between different PRs

*Remark*: on dbt cloud on the job setting you ahve an option to defer to an specific pipeline last run
