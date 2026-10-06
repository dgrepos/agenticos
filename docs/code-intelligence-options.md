# Code intelligence for AgenticOS — the full option map (researched 2026-07-28)

Decision doc for the "graphify → RAG?" question. Current state: agentic grep + generated code map (`scripts/graphify.py`). This doc catalogs every credible upgrade path, with evidence.

## The evidence baseline

- Claude Code intentionally ships **no index**: grep/glob + iteration. The May 2026 paper "Is Grep All You Need?" (arxiv 2605.15184) found inline grep beat vector retrieval in every harness tested — though results flipped in some configs, so it's a strong default, not a law.
- Cursor's counter-data: their trained semantic search adds +12.5% retrieval accuracy, but the end-to-end gain shows up **only on 1,000+ file repos** (+0.3% overall vs +2.6% on large repos).
- Codebase-Memory paper (arxiv 2603.27277): a deterministic tree-sitter call/import graph cut tokens ~10x per structural query at slightly lower answer quality — graphs are a **cost** optimization, not a quality win.
- Consensus 2026: the winning pattern is **agent-with-tools** (grep + optional semantic/structural tool + read-and-verify), never embeddings-as-sole-retrieval.

## Options, ranked by fit to our rules (token-minimal, CLI > API > MCP, index local to repo)

| # | Option | Method | Fits rules? | When |
|---|---|---|---|---|
| 1 | **graphify (current)** | AST code map in `memory/` | Perfect | Now — already built |
| 2 | **codegraph** (colbymchenry/codegraph) | Tree-sitter code knowledge graph → local SQLite+FTS5 in `.codegraph/`, file-watcher sync; CLI (`query/impact/affected`) + optional MCP | Excellent (CLI-first, local, no API keys; claims ~59% token cut) | First upgrade, ~1k+ files. NOTE: grew very fast — vet it yourself before depending on it |
| 3 | **ChunkHound** | cAST structural chunking → local DuckDB, semantic+regex search, offline embeddings via Ollama | Very good (fully local, CLI available; smaller community ~1.4k stars) | If we want true semantic search, offline |
| 4 | **DIY sqlite-vec / pgvector** | Our own `scripts/index-codebase.py` + `ask-codebase.py`, AST chunks (reuse graphify parser), hybrid BM25+dense, nomic-embed-code (offline) or voyage-code-3 (API) | Very good (zero third-party risk; pgvector reuses our Postgres) | If we want full control / teachable code |
| 5 | **Serena** (oraios/serena) | LSP-based symbol tools, 40+ languages | Weak (MCP server, ~20 tool schemas of standing context cost) | Only at large-repo scale where precise symbols beat everything |
| 6 | **claude-context** (Zilliz) | Hybrid vector RAG, Milvus cloud | Poor (cloud DB, MCP) | Skip |
| 7 | **PageIndex** ("vectorless RAG") | LLM-reasoning tree search, no vectors | Poor **for code** — it's built for documents (PDFs, filings); an agent walking a file tree already IS vectorless retrieval | Maybe later for business docs, not code |
| 8 | **GraphRAG (Microsoft) / LLM-extracted graphs** | LLM builds entity graph | Terrible (massive LLM cost per re-index, ~57x construction time) | Skip |
| 9 | **Contextual retrieval (Anthropic recipe)** | Context-prefixed embeddings + BM25 + rerank | Good for **static docs**, killed by per-edit re-contextualization cost on live code | Use for docs/knowledge base, not code |
| 10 | **Recursive Language Models** (MIT, Dec 2025) | Context in a REPL; model recursively greps/slices it | Research-stage; the likely "new hot method" on X/HN | Watch, don't build |

## Agreed strategy (update as decided)

1. **Today**: graphify + agentic grep. Zero maintenance, strongest evidence at our size.
2. **Trigger to upgrade**: scout takes 3+ grep rounds to locate things, or repo crosses ~1,000 files / ~100k lines.
3. **First upgrade**: trial codegraph (CLI mode only, no MCP) on a branch; measure token usage before/after on 10 real questions. Fallback: ChunkHound or DIY sqlite-vec with AST chunks.
4. **Never**: cloud vector DBs, LLM-extracted graphs, or any MCP server for retrieval while a CLI works.
5. **Separate track**: business/product docs (not code) may later get contextual-retrieval RAG — different problem, different tool.

## Sources

- github.com/colbymchenry/codegraph · github.com/chunkhound/chunkhound · github.com/oraios/serena · github.com/VectifyAI/PageIndex · github.com/zilliztech/claude-context · aider.chat/docs/repomap.html (the repo-map idea graphify copies)
- arxiv.org/abs/2605.15184 (Is Grep All You Need) · arxiv.org/abs/2506.15655 (cAST chunking) · arxiv 2603.27277 (Codebase-Memory) · arxiv.org/abs/2512.24601 (Recursive LMs)
- anthropic.com/engineering/contextual-retrieval · cursor.com/blog/semsearch
