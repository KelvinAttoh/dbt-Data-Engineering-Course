# Automated Job Postings Pipeline (v1) - dbt + Duckdb

![dbt pipeline diagram](./dbt-duckdb-pipeline/images/dbt_pipeline.png)

A public dbt plus Duckdb piepline over ~692k real job postings, rebuilt and republished automatically on every push.

- Models the raw postings into testing, documented insights marts
- Publishes the doc site and the finshed warehouse - open to anyone, no credentials
- Run itself on GitHub Actions: every push and every Monday

> **v1 of this pipeline** - everything free and locally friendly: Duckdb as the warehouse, GitHub Actions as the scheduler. [v2](../project_2/) rebuilds it production-grade on Databricks.


| What I Built | How I Implemented | Where to Look
| --- | --- | --- |
| **dbt pipeline** | sources → cleaned model → insight marts | ['analytics/models'](./dbt-duckdb-pipeline/analytics/models/) |
| **Data tests** | `unique` / `not_null` on every mart grain | [`schema.yml`](./analytics/models/schema.yml) |
| **Hosted dbt docs** | lineage, descriptions, column tests | [Live docs site](https://kelvinattoh.github.io/dbt-Data-Engineering-Course/)|
| **Public CI** | build + test + publish on every push | [Actions workflow](https://github.com/KelvinAttoh/dbt-Data-Engineering-Course/actions) |
| **Environments** | local `dev` vs CI `prod` targets | [`ci/profiles.yml`](./ci/profiles.yml) |
| **Published warehouse** | one `ATTACH` queryable by anyone | [`Query it`](../dbt-duckdb-pipeline/)


## ⚙️ The dbt Pipeline

Raw postings flow through three dbt layers — declared sources → cleaned staging views → insight marts — with tests gating every build.

The DAG below is the whole flow:

![dbt dag diagram](./dbt-duckdb-pipeline/images/dag_pipeline.png)

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

GitHub Actions runs the whole pipeline — no laptop required: [`.github/workflows/dbt_build.yml`](.github/workflows/dbt.build.yml)

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


## 🦆 Query the published warehouse

No clone required. [`Install DuckDB`](https://duckdb.org/docs/2.0/installation?platform=macos&environment=cli) (`brew install duckdb`), then from a `duckdb` session:


```bash
INSTALL httpfs;
LOAD httpfs;

ATTACH 'https://github.com/KelvinAttoh/dbt-Data-Engineering-Course/releases/download/warehouse/prod.duckdb' AS jobs;

USE jobs;
SHOW TABLES;

SELECT * FROM top_locations;
SELECT * FROM monthly_summary;

```


## 📖 Docs
Docs are generated with `dbt docs generate` and published to GitHub Pages:

→ [kelvinattoh.github.io/dbt-Data-Engineering-Course](https://kelvinattoh.github.io/dbt-Data-Engineering-Course/)

The site shows:

- The full lineage graph (sources → models → marts)
- Model and column descriptions from the YAML
- Which columns carry tests

## 💻 Run it yourself
```bash
uv sync
uv run python scripts/download_data.py
cd analytics && uv run dbt build
```

Optional docs locally:
```bash
uv run dbt docs generate
uv run dbt docs serve
```
