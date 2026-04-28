- downstream external use of dbt models
- exposures folder inside models
- appears in the lineage
- you can do a `dbt run --select +exposure:exp_name` to run all models for it
    - replace `exp_name` with `*` for running to all exposures

```yaml
    exposures:
        - name:
          label:
          type: dashboard | analysis | ml | application | notebook
          maturity: low | medium | high
          url:
          description:
          depends_on:
            - ref()
            - metric()
          owner:
            name:
            email:
```