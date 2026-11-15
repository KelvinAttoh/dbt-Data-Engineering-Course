# Automated Job Postings Pipeline (v1) - dbt + Duckdb

![dbt pipeline diagram](images/dbt_pipeline.png)

A public dbt plus Duckdb piepline over ~692k real job postings, rebuilt and republished automatically on every push.

- Models the raw postings into testing, documented insights marts
- Publishes the doc site and the finshed warehouse - open to anyone, no credentials
- Run itself on GitHub Actions: every push and every Monday

> **v1 of this pipeline** - everything free and locally friendly: Duckdb as the warehouse, GitHub Actions as the scheduler. [v2](../project_2/) rebuilds it production-grade on Databricks.


| What I Built | How I Implemented | Where to Look
| --- | --- | --- |
| **dbt pipeline** | sources → cleaned model → insight marts | ['analytics/models'](./analytics/models/) |
| **Data tests** | `unique` / `not_null` on every mart grain | [`schema.yml`](./analytics/models/schema.yml) |
| **Hosted dbt docs** | lineage, descriptions, column tests | [Live docs site] |
| **Public CI** | build + test + publish on every push | [Actions workflow] |
| **Environments** | local `dev` vs CI `prod` targets | [`ci/profiles.yml`](./ci/profiles.yml) |
| **Published warehouse** | one `ATTACH` queryable by anyone | [`Query it`](../dbt-duckdb-pipeline/)


## ⚙️ The dbt Pipeline

Raw postings flow through three dbt layers — declared sources → cleaned staging views → insight marts — with tests gating every build.

The DAG below is the whole flow:

![dbt dag diagram](image/dag_pipeline.png)

And the dbt features doing the work:

| dbt Feature | How to Use it |
| --- | --- |
| Declared sources (no hardcoded paths in SQL) | [`source.yml`](analytics/models/source.yml) + `source('raw' + 'job postings')` |
| Model dependencies | `ref()` everywhere downstream; dbt resolves order and parallelism |
| Materializations | project default `table`; staging override to `view` |
| Data tests | unique / not_null on mart grains in [`schema.yml`](analytics/models/schema.yml) |
| Environments | local `dev` vs CI `prod` targets [`ci/profiles.yml`](./ci/profiles.yml) |

`dbt build` compiles SQL, materializes models, and fails the run if any test fails — same command locally and in CI.


## 🚀 Production

GitHub Actions runs the whole pipeline — no laptop required: [`.github/workflows/dbt_build.yml`](../dbt-duckdb-pipeline/.github/workflows/dbt.build.yml)

| Trigger | What Happens |
| --- | --- |
| Push to `main` | Full rebuild |
| Weekly (Monday) | Scheduled rebuild — pipeline stays fresh |
| Manual (`workflow_dispatch`) | Run button in the Actions UI |


On each run, Actions:

1. Installs deps with `uv`
2. Downloads raw parquet
3. Runs `dbt build` with the committed CI profile (prod)
4. Publishes `prod.duckdb` as a GitHub Release asset

The badge at the top of this README links to the latest runs.

