## **"Can you give me an example of optimizing a data model?"**

At Autodoc we're currently migrating from ClickHouse to Snowflake, and one pattern that came up frequently in the existing models was the use of paired arrays — one for keys, one for values — which is a common ClickHouse pattern but not analytics-friendly and harder to work with in Snowflake.

My first instinct on one particular model was to explode the arrays into one row per key-value pair, which would make filtering and aggregating much more intuitive downstream. I started going down that path but as I examined the data more closely I realized there were too many variations in the key-value pairs and the sheer volume of the data could be an issue.

To validate my concerns, I tested on small hour-window slices of data and even on those small windows the explode approach was already showing significant row multiplication and performance degradation — which confirmed that at full daily scale of tens of millions of rows it would be extremely expensive to run.

So instead I pivoted to leveraging Snowflake's native array manipulation functions to query directly into the arrays without exploding them. This ended up being significantly more performant and avoided the row multiplication problem entirely.

### Key

- ClickHouse → Snowflake migration
- Paired arrays (keys / values) pattern
- First instinct: explode into rows
- Problem: inconsistent keys + row multiplication
- Validated on small hour-window slices
- Even small windows showed degradation
- Pivot: Snowflake native array functions
- Query into arrays without exploding
- More performant, no row multiplication

-------------------------------------------------


## **"Can you give me an example of optimizing a data model?"**

Sometimes analytics requests come in with a query the analyst has already written containing the business logic they need. Rather than building from scratch, my approach is to break that query down into intermediate models and optimize along the way.

In one particular case, an analyst needed to compute a monthly user consent flag and wanted to query a full year of data from a very large event table which didn't even run.

My solution was to extract the consent logic into a dedicated SCD Type 2 model — instead of scanning a year of raw events every time, the SCD model tracks when each user's consent status changes over time. This way you get the full history in a much lighter structure.

To keep it performant at scale I made it incremental, loading only a day's worth of events daily. I also added clustering by event date on Snowflake to make partition pruning efficient.

On top of that I made several additional optimizations to the broader pipeline — removing unused columns that were being carried through unnecessarily, refining filters to push them earlier in the query, and tightening some joins that were broader than they needed to be.
The end result was a much lighter model that the analyst could query freely without worrying about cost or performance.

### Key

- Analytics request with existing query
- Break down into intermediate models + optimize
- Monthly consent flag from large event table
- Problem: full year scan, expensive
- Solution: dedicated SCD Type 2 for consent
- Tracks changes over time → lighter structure
- Incremental: daily load, never full scan again
- Clustering by event date → partition pruning
- Additional optimizations:
    - Remove unused columns
    - Push filters earlier
    - Tighten joins (inner over left / only on indexed columns / fixing some many-to-many joins that multiplicate rows incorrectly / incremental partitions)

-------------------------------------------------

## **"Can you give me an example of translating a business requirement into a data engineering request?"**

At Rauva, management wanted visibility into the data team's workload and delivery velocity — how many requests were coming in, how long they took to be delivered, and where bottlenecks were. The natural source for this was Jira, since all data requests came in as tickets, but at the time it wasn't integrated with the warehouse at all.

So the first thing I did was scope exactly what I needed before going to the data engineer. I mapped out the fields that would be necessary — ticket ID, reporter, assignee, creation date, status, resolution date, priority, and labels we used to categorize request types. I also defined the required update frequency as daily, since this was an operational reporting model and didn't need to be real-time.

I then opened a formal integration request ticket for the data engineer with all of this documented — the source, the specific fields, the frequency, and a brief explanation of the downstream model I intended to build on top of it and its business purpose. The idea was to make their job as easy as possible and avoid back and forth.

Once the raw data landed in the warehouse I built a mart with one row per ticket, tracking lifecycle metrics like time to first response, time to resolution, and open ticket aging — which gave management the visibility they needed and also helped the team prioritize more transparently.

### Key

- Management request: data team visibility
- Metrics: time to resolution, open ticket aging
- Source: Jira (not yet integrated)
- Scoped requirements first before requesting
- Fields: ticket ID, reporter, assignee, dates, status, priority, labels
- Frequency: daily (operational, not real-time)
- Context: downstream purpose
- Formal integration ticket to data engineer
- Meeting (optional): confirm with DE if there is any limitation and align on the final deliverable

-------------------------------------------------

## **"Can you give me an example of how you deal with a request of an analyst and getting to the model?"**

### Key

- Monthly grain: consent metrics (active, new, revoked)
- Analyst SQL = logic reference
- Reuse dbt staging + dimensions
- Problem: full scan (12 months, large events table)
- Solution: 2 layers
  - Incremental Type 2 SCD (user_id + consent_type)
  - Monthly aggregation (date_trunc month)
- Partition + clustering + optimization of query
- Tests: unique, not null (fresh usually if new source, not this case)
- Documentation: models descriptions
- Validation: iteration (not this case)
- Deployment: CI/CD

-------------------------------------------------

Example of improving dbt project infrastructure-wise

- Enabled slim CI using state-based runs, reducing build times for development and pull requests.
- Converted heavy models to incremental and introduced partitioning, reducing runtime and warehouse costs significantly.
- Macro for removing stale models