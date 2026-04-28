# dbt mesh

- single dbt project doesnt scale well
    - too many models
    - upstream changes can easily/unpredictably break downstream
- dbt mesh breaks downs data structure into multiple projects
    - domain-level ownership
    - w/o compromising governance or creating silos

- **Pros**
    - **For Domain teams**
        - domain autonomy -> ship faster
        - shareable refs
        - confidence on nothing breaking
    - **For Central teams**
        - visibility of full lineage
        - not being a bottleneck

- every model can have a contract (guarantees on data shape)
- models can 
    - have private or public access
    - be grouped
    - be reused across projects
- when a contract changes in a way that is backwards incompatible it should gen a new version

## Contracts

- try to guarantee columns, datatype and even materialization strategy
- you get errors when running dbt if you change something
- similar to testing, but it doesnt check the contents, it checks the shape. It avoids "bad shape data" to get into the model

Added under the schema.yml

```yaml
    models:
        - name:
          config:
            contract:
                enforced: true
          columns:
            - name:
              data_type:
              constraints:
                - type: not_null
          
```

## Versions

- create a new model_v2.sql

```yaml
    models:
        - name:
          latest_version: 2
          config:
            contract:
                enforced: true
          columns: (old version)
            - name:
              data_type:
              constraints:
                - type: not_null
          versions:
            - v: 1
                config:
                    alias: (if you wanna change the name of a version table)
            - v: 2
              columns:
                - include: * (columns from v1 in v2)
                  exclude: [<name>, ...] (columns changed in v2) 
                - name:
                ... (changed columns)          
```

- Then you can call `{{ ref('model_name', v=2)}}` or not include v to use the lastest version
- `dbt run -s model_name` runs all versions
- `dbt run -s model_name_v2` runs v2
- `dbt run -s model_name version:latest` runs lastest version
- recommended to name the alias of v1 to just the table name

## Groups and access modifiers

- splits the huge project into modules and manges access
- groups.yml under models folder
- **Model groups**: set of related models owned by a team
```yaml
  groups:
    - name: a
      owner:
        name:
        email:
        slack:
        github:
    - name: b
      owner:
        email:
        slack:
```
- **Access modifiers**: which models can ref which
  - **public**: can be accessed by any model, project, package
  - **protected**: can be accessed by models in the same project or group (default for all)
  - **private**:can be accessed by models in the same group

- public and protected models should be ready for final use (e.g. marts)
- private models have better downstream model to be used by others

- both group a access of a model is determined in its schema.yml

```yaml
  models:
    - name:
      access:
      group:
```


## Multi-project

- when a project reach a certain scale it is to hard to find where to work on and have a view of the whole, that is when it should be split in multiple projects
- **An enterprise dbt Cloud account is required to create multiple dbt projects.**
  - with core you can import other projects repo as packages
  - with cloud you use a dependencies.yml (under project folder)
    - `{{ ref('project_name', 'model_name') }}`

```yaml
  projects:
    - name:
```

- you want to trigger jobs on downstream projects on completion of the jobs of upstream projects