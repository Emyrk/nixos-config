---
name: memory
description: Persistent memory policy — when to store, what to tag, when to recall. Backed by the `memory_*` MCP tools.
---

# Memory — how to use it

You have a persistent memory store backed by the `memory_*` MCP tools (see the
`memory` server in `~/.mux/mcp.jsonc`). The store survives across workspaces,
machines, and assistants. Treat it as **the single source of truth** for things
the user has told you, decisions you've made together, and lessons learned.

This skill defines the **policy**: when to write, what to tag, when to read.
The tools themselves are obvious from their schemas — this file is here so we
get *consistent* behavior every session.

## TL;DR (do this on every relevant turn)

1. **Before answering "how do I X" or "what is Y"-style questions**, call
   `memory_retrieve_memory` with a natural-language query reflecting the user's
   ask. If anything comes back, prefer it over your assumptions.
2. **When the user states a fact, preference, decision, or "lesson"**, call
   `memory_store_memory`. Match the rules in *When to store* below.
3. **Always tag** stored memories using the vocabulary in *Tags* below.
4. **Don't dump** raw conversation. Write one short, self-contained sentence
   per memory so semantic search hits it.

## When to store

Store when **at least one** is true:

- The user says "remember…", "don't forget…", "from now on…", or similar
  explicit cues.
- The user **corrects** a wrong assumption you made (the corrected fact is now
  durable knowledge).
- A **decision was made with rationale** that future-you would relitigate
  without this note (e.g. "we use sqlite-vec instead of chroma because the HA
  addon's Alpine base can't build chroma's deps").
- A **gotcha bit you** that you'd hit again (e.g. "HA Ingress hides the addon
  panel under `/api/hassio_ingress/<token>/`; absolute URLs in dashboards
  bypass it").
- A **personal fact** is shared that the user clearly wants remembered
  (relationships, travel plans, important dates, preferences).

Do **not** store:

- Things the user said in passing without indicating they're durable.
- Code snippets longer than a sentence. Use file/repo edits instead.
- Anything that's true only "right now in this conversation". The store is for
  things that should outlive the workspace.
- Duplicates. Before storing a new memory on a familiar topic, briefly
  `memory_retrieve_memory` first; if a near-duplicate exists, prefer
  *updating* it (delete old, store new) over piling on.

## When to retrieve

- **Always retrieve** before answering questions of the form:
  - "How do I…" / "What's the way to…" — there may be a project-specific or
    user-preference answer in memory that overrides general best practice.
  - "What is X?" / "Where does Y live?" / "What's my API key for…" — the
    answer may be a fact you've been told.
  - "Why do we…" / "Why did we choose…" — likely a stored decision with
    rationale.
- **Always retrieve** the first time a new workspace mentions a project name
  or hostname you don't yet have context for (e.g. user mentions
  `home.steven.masley.com` → you should pull what's known about it).
- **Do not retrieve** on:
  - Generic technical questions with no project/personal angle.
  - Chit-chat, greetings, or pure code-formatting requests.
  - Every single turn — that's noisy and wasteful.

Prefer `memory_retrieve_memory` (semantic) for free-form queries; use
`memory_search_by_tag` when you want a strict category (e.g. "everything I
know about deployments" → tag `deploy`).

## Memory content format

Write **one self-contained sentence**, in third person, declarative, including
enough context that semantic search can find it.

Bad: `"port 8000"`
Good: `"The MCP Memory Service add-on listens on LAN port 8000 at http://192.168.1.123:8000/."`

Bad: `"don't use light option"`
Good: `"On Debian, install nginx-full (not nginx-light) when sub_filter is needed — nginx-light omits ngx_http_sub_module so sub_filter is silently ignored."`

If a memory becomes obsolete (a fact changed, a decision was reversed),
`memory_delete_memory` it by `content_hash` and store the replacement. Don't
leave contradictory entries.

## Tags (vocabulary)

Tags are **hierarchical**: use both the top category and the specific
sub-tag on every memory so broad and narrow searches both work.

| Top tag | Use for | Example sub-tags |
|---|---|---|
| `personal` | Anything about the user's life | `personal/relationships`, `personal/travel`, `personal/health`, `personal/dates`, `personal/finance` |
| `prefs` | The user's preferences (durable opinions) | `prefs/code`, `prefs/tone`, `prefs/ops`, `prefs/tools` |
| `deploy` | Infrastructure / deployment facts | `deploy/home-assistant`, `deploy/mcp-memory`, `deploy/cloudflare`, `deploy/networking` |
| `decision` | Choices made + rationale | `decision/architecture`, `decision/library`, `decision/process` |
| `lesson` | Gotchas to avoid repeating | `lesson/ingress`, `lesson/docker`, `lesson/api`, `lesson/git` |
| `project/<name>` | Project-specific facts (slug after `/`) | `project/ha-addon-mcp-memory`, `project/mux` |

Rules:

- **Always include the top tag** AND **at least one sub-tag**.
- Add a `project/<slug>` tag whenever the memory pertains to a specific repo
  or product, in addition to the topical tag(s).
- Keep tags lowercase, kebab-case after the slash.
- Don't invent new top-tags casually. If something doesn't fit, file under the
  nearest existing top-tag and reach for a new sub-tag instead. If you truly
  need a new top-tag, ask the user first.

## Memory types

Use the `memory_type` parameter on `memory_store_memory`. Pick the closest
match — the values are informational only (search doesn't use them).

- `fact` — something objectively true (URL, hostname, version pinning).
- `preference` — a user opinion or convention.
- `decision` — a choice + the reasoning.
- `lesson` — a gotcha or learned constraint.
- `personal` — anything in the `personal/*` tag space.

## Privacy & sensitivity

- The store contains personal information. Never echo memories into
  sub-agent prompts, web search queries, or external tool calls unless the
  user explicitly asks.
- API keys / tokens stored in memory should be **referenced by location**
  (e.g. "API key is at `/share/mcp-memory/api_key` on the HAOS box"), not
  pasted verbatim into a memory. If the user does want a secret stored,
  add tag `personal/secret` so retrieval is intentional.

## Quick examples (copy-paste-ready calls)

Storing a deployment fact:

```jsonc
memory_store_memory({
  content: "The MCP Memory Service add-on is installed on HAOS at slug c9fd3759_mcp_memory; its LAN endpoint is http://192.168.1.123:8000/ and MCP is at /mcp.",
  memory_type: "fact",
  tags: ["deploy", "deploy/mcp-memory", "deploy/home-assistant", "project/ha-addon-mcp-memory"]
})
```

Storing a preference:

```jsonc
memory_store_memory({
  content: "Steven prefers TypeScript with strict mode and avoids `any`; for new TS projects, prefer Vitest over Jest.",
  memory_type: "preference",
  tags: ["prefs", "prefs/code"]
})
```

Storing a lesson:

```jsonc
memory_store_memory({
  content: "nginx-light on Debian omits ngx_http_sub_module, so sub_filter directives are silently ignored. Use nginx-full when sub_filter is needed; assert at build time with `nginx -V | grep http_sub_module`.",
  memory_type: "lesson",
  tags: ["lesson", "lesson/docker", "deploy/networking"]
})
```

Retrieving before answering a "how do I" question:

```jsonc
memory_retrieve_memory({ query: "how do I deploy a custom HA add-on", limit: 5 })
```

Tag-scoped recall ("what do you know about my deployments"):

```jsonc
memory_search_by_tag({ tags: ["deploy"], operation: "OR" })
```

Time-scoped recall ("what did we work on last week"):

```jsonc
memory_recall_memory({ query: "anything from last week about home assistant", n_results: 10 })
```

## Deployments (how the memory MCP is reached)

The memory MCP server lives in a Home Assistant add-on on the HAOS box at
`192.168.1.123`. Reachability depends on where mux is running.

### Windows workstation on LAN (current default)

`~/.mux/mcp.jsonc`:

```jsonc
"memory": {
  "transport": "http",
  "url": "http://192.168.1.123:8000/mcp",
  "headers": { "X-API-Key": "<key-from-/share/mcp-memory/api_key>" }
}
```

### Laptop on home Wi-Fi

Same config as above — the LAN IP is reachable.

### Laptop off-network / any machine on the internet

Requires the Cloudflared HA add-on with a tunnel routing
`https://memory.<your-domain>/` → `http://homeassistant.local:8000/`.

```jsonc
"memory": {
  "transport": "http",
  "url": "https://memory.<your-domain>/mcp",
  "headers": { "X-API-Key": "<key>" }
}
```

### Claude Desktop / Claude Code

Same endpoint, different config file (`claude_desktop_config.json`). Claude
Desktop also supports HTTP transports for MCP servers as of late 2025.

## When the user invokes `/memory`

When the user runs `/memory <prompt>`, the prompt is usually a *request to
recall something*. Default behavior:

1. Run `memory_retrieve_memory` with the user's prompt verbatim.
2. If they explicitly ask to forget something, list candidates from
   `memory_retrieve_memory` and confirm before deleting.
3. If they explicitly ask to remember something, store it with appropriate
   tags + type per this skill.
