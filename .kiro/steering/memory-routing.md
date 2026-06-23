# Memory routing + digest workflow

## Digest pipeline
The `luma memory digest` command processes `~/luma-memory/*/inbox/` → `notes/` using:
- **You (Kiro) as the entity extractor** — when digest runs, it calls `kiro-cli chat --no-interactive` to extract named entities from each note body. This powers the Obsidian graph connections (`_index/topics/`) and SQLite FTS5 search.
- **Backends: `file,sqlite`** — `file` builds Obsidian-compatible wikilink shards; `sqlite` indexes full note bodies with BM25. No always-on service required.
- **To trigger**: `luma memory digest` (or `luma chat` does it automatically pre/post session).
- **To query**: `memory` MCP `query` tool, or `luma memory query "term"`.

Drop new notes to `~/luma-memory/global/inbox/` (or a project inbox) and run digest. Subfolders are preserved. The Obsidian vault at `~/luma-memory` reflects the graph after each digest.

## Memory routing (two systems — route deliberately)

There are two memory stores. They are bridged: durable Luma knowledge goes to
the `luma-memory` vault; only harness/tooling facts stay in the thin auto-memory.

- **Durable Luma domain knowledge** (MSWM/UBS/Merrill workflows, PB roadmap,
  GEARS, trade investigations, pricing decisions, meeting outcomes) → write to
  the `luma-memory` vault via the `memory` MCP `write_inbox` tool
  (`vault`: `global` or a project slug like `luma`; `filename`: dated
  `YYYY-MM-DD-topic.md`; `content`: the note). Recall with `memory` MCP
  `query` / `read_note` before re-deriving.
- **Harness / tooling / CLI facts** (Kiro config, gstack runbook, repo
  clone locations) → the file-based memory tier.
- Don't double-write the same fact to both. Domain → vault; tooling → file tier.
