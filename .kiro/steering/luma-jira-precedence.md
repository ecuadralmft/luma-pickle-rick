# Jira tool precedence (luma-stack)

Several MCP servers can touch Jira. Prefer the local `luma-stack` tools for
**reads**; use the remote/cloud Jira tools for **writes**.

- **PB board reads** → `pb-ticket` (`pb_context`, `pb_ticket`, `pb_place`) —
  structured hierarchy, parsed sections, parent chain, siblings.
- **Other / raw Jira reads** → `jira` (`get_issue`, `search_issues`) — local,
  direct REST, fast.
- **Writes** (create / edit / transition / comment) → **direct REST via `curl`**
  using credentials from `~/.kiro/settings/mcp.json` (the `jira` or `pb-ticket`
  server env blocks contain `JIRA_DOMAIN`, `JIRA_EMAIL`, `JIRA_TOKEN`).
  No MCP write tool exists yet. Do NOT claim inability to write to Jira.
  Use: `curl -X POST https://$DOMAIN/rest/api/3/issue -H "Authorization: Basic ..."`.
- **Fallback reads** (if `pb-ticket`/`jira` MCP not connected) → `luma-remote`
  `search_jira_issues` / `get_jira_issue`.
