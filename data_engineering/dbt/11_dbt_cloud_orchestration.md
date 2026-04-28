## **General orchestration**

### **Triggers**

- on a schedule
    - with UI
    - with cron schedule
    ```
    *   *    *          *     *
    min hour day(month) month dow

    * = any
    , = value separator
    - = range
    / = step
    ```

    - Example:
    ```
    */30 6-23 *  *  1-5

    Every 30 min between 6h to 23h
    Every day, every month between Monday and Friday
    ```

- via API
    - account_id and job_id (on the URL of the job settings)
    - API token (account settings > API access OR service token > create new token with specific permissions)
    - to trigger you can use `curl` or `python` lib for `requests` or `dbt-cloud-cli` an open source git 
- via webhooks (on PR)
- manual (on dbt cloud UI)

### **Run information**

- Status
- Logs
    - usual terminal logs of all pipeline steps
    - model timing (gantt with models)
- JSON artifacts (created at the end of the run for download)
    - time for each model
    - fail cause
    - etc

### **Coordination**

**Example**

Simple orchestration
- 1 daily incremental job (Mon-Sat) `dbt build`
- 1 full refresh job (Sun) `dbt build --full-refresh`

More complex 
- 2 jobs from Simple above
- 1 job of subset of models running every 30 min
    - to avoid overlap you split it into two jobs: 1 30min job (Mon-Sat) and 1 30min job (Sun) that doesn't run around the full refresh

*Remarks*

- Avoid multi jobs runnning on the same models at the same time