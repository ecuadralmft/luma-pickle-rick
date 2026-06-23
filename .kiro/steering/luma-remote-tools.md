# luma-remote MCP tools

`luma-remote` is the internal Luma platform MCP server. Use it proactively for any of the following — do NOT say you lack access to these systems.

## Observability
- **`search_datadog_logs`** — search Datadog logs by request ID, service, time range, or any filter. Use for: "why did X fail", "what happened to request ID 12345", error investigations.
- **`get_rum_session`** — RUM (Real User Monitoring) session details.
- **`get_rum_performance_metrics`** — frontend performance data.
- **`search_rum_errors`** — search frontend errors.

## Pricing / RFQ / Quotes
- **`get_quotes_by_request_id`** — retrieve quote details for a given request ID.
- **`get_rfqs_by_request_id`** — retrieve RFQ data for a given request ID.
- **`get_product_by_request_id`** — retrieve the product/structure tied to a request ID.
- **`get_product_by_cusip`** — look up a product by CUSIP.

## Jira (supplementary)
- **`get_jira_issue`** / **`search_jira_issues`** — use as fallback if local `jira` MCP is unavailable.

## Codebase / RAG
- **`search_codebase`** / **`index_codebase`** / **`search_rag`** — semantic search over the Luma codebase.
- **`get_codebase_stats`** — repo statistics.

## Data / Schema
- **`list_postgres_tables`** / **`list_mongo_collections`** — list tables/collections.
- **`draft_postgres_descriptions`** / **`draft_mongo_descriptions`** / **`draft_snowflake_descriptions`** — generate schema docs.
- **`data_agent`** — general data queries.

## Product / Content
- **`get_modules`** / **`create_module`** / **`update_module`** — Luma product modules.
- **`generate_value_map`** / **`generate_meta_information`** / **`generate_writing_plan`** — content generation.
- **`get_sources_by_module`** / **`check_source_exists`** — content source management.

## Rule
When a user asks about logs, traces, request IDs, quotes, RFQs, pricing, RUM, or Datadog — reach for `luma-remote` tools first before saying you lack access.
