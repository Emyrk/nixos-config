---
name: memory
description: Persistent memory policy — when to store, query, and consolidate knowledge. Backed by the Honcho MCP tools.
---

# Memory — how to use it

You have persistent memory backed by the **Honcho** MCP tools (see the
`honcho` server in `~/.mux/mcp.jsonc`). Memory survives across workspaces,
machines, and assistants. Treat it as **the single source of truth** for things
the user has told you, decisions you've made together, and lessons learned.

Honcho is smarter than a key-value store. It auto-derives insights from
conversations, maintains a user model, and supports semantic search. This skill
defines the **policy** for consistent behavior — when to write, when to query,
when to consolidate.

## Core concepts

| Concept | What it is |
|---|---|
| **Peer** | A participant — human (`steven`) or agent (`mux`). |
| **Conclusion** | A fact or observation. Directional: observer → target (e.g. `mux`'s conclusion about `steven`). |
| **Peer card** | A compact list of biographical facts about a peer. Updated manually or via dreaming. |
| **Session** | A conversation thread. Peers join sessions; messages are recorded per-session. |
| **Dreaming** | Background memory consolidation — synthesizes raw conclusions into higher-level insights and updates peer cards. |

## Peers in this workspace

- **`steven`** — Steven Masley, the human user behind all sessions.
- **`mux`** — the agent (you). Observer of Steven's conclusions.

## TL;DR (do this on every relevant turn)

1. **Before answering "how do I X" or "what is Y"-style questions**, call
   `honcho_query_conclusions` or `honcho_chat` with a natural-language query.
   If anything comes back, prefer it over your assumptions.
2. **When the user states a fact, preference, decision, or "lesson"**, call
   `honcho_create_conclusions` with `peer_id: "mux"` and
   `target_peer_id: "steven"`. Match the rules in *When to store* below.
3. **Don't dump** raw conversation. Write one short, self-contained sentence
   per conclusion so semantic search hits it.
4. **Let auto-derivation do its job** — Honcho learns from conversations
   automatically. Only create conclusions manually for things that are
   important enough to guarantee they're captured.

## When to store (manually create conclusions)

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
  Auto-derivation may pick these up if they're meaningful.
- Code snippets longer than a sentence. Use file/repo edits instead.
- Anything that's true only "right now in this conversation". Conclusions
  should outlive the workspace.
- Duplicates. Before storing, briefly `honcho_query_conclusions` first; if a
  near-duplicate exists, prefer *replacing* it (delete old, create new) over
  piling on.

## When to query

- **Always query** before answering questions of the form:
  - "How do I…" / "What's the way to…" — there may be a project-specific or
    user-preference answer that overrides general best practice.
  - "What is X?" / "Where does Y live?" — the answer may be a stored fact.
  - "Why do we…" / "Why did we choose…" — likely a stored decision with
    rationale.
- **Always query** the first time a new workspace mentions a project name
  or hostname you don't yet have context for.
- **Do not query** on:
  - Generic technical questions with no project/personal angle.
  - Chit-chat, greetings, or pure code-formatting requests.
  - Every single turn — that's noisy and wasteful.

### Which query tool to use

| Tool | When to use |
|---|---|
| `honcho_chat` | Natural-language questions — "what does Steven prefer for error handling?" Honcho reasons over all knowledge and returns a synthesized answer. |
| `honcho_query_conclusions` | Targeted semantic search — returns ranked matching conclusions. Best when you want raw facts, not interpretation. |
| `honcho_get_peer_context` | Full picture — combines conclusions + peer card. Use at session start or when you need broad context. |
| `honcho_get_peer_card` | Quick bio summary. Use for a fast refresher on who someone is. |

## Conclusion content format

Write **one self-contained sentence**, in third person, declarative, including
enough context that semantic search can find it.

Bad: `"port 8000"`
Good: `"The Honcho MCP is hosted at https://mcp.honcho.dev with Bearer token auth."`

Bad: `"don't use light option"`
Good: `"On Debian, install nginx-full (not nginx-light) when sub_filter is needed — nginx-light omits ngx_http_sub_module so sub_filter is silently ignored."`

If a conclusion becomes obsolete (a fact changed, a decision was reversed),
`honcho_delete_conclusion` it by ID and create the replacement. Don't leave
contradictory entries.

## Peer card maintenance

The peer card is a compact list of biographical facts. Update it when:

- A significant new fact about the user is learned (new project, role change,
  new preference).
- An existing fact becomes wrong.
- After a dream consolidation reveals card-worthy insights.

Use `honcho_set_peer_card` — it **overwrites** the entire card, so always
`honcho_get_peer_card` first, modify the list, then set it back.

## Dreaming (memory consolidation)

`honcho_schedule_dream` runs background consolidation. Schedule a dream when:

- A long or dense conversation just finished.
- You notice many low-level conclusions that could be synthesized into
  higher-level insights.
- The user explicitly asks you to consolidate or "think about what you know."

Don't schedule dreams on every turn — they're a periodic maintenance task.
Check `honcho_get_queue_status` if you want to verify a dream completed.

## Sessions

Sessions track conversation threads. For most interactions, you don't need to
manage sessions explicitly — Honcho handles it. Create sessions explicitly
when:

- You want to scope conclusions to a particular conversation.
- You're tracking a multi-turn project discussion that should be grouped.

## Privacy & sensitivity

- Memory contains personal information. Never echo conclusions into
  sub-agent prompts, web search queries, or external tool calls unless the
  user explicitly asks.
- API keys / tokens should be **referenced by location** (e.g. "API key is
  in 1Password under 'Honcho'"), not stored as conclusions. If the user does
  want a secret stored, confirm intent first.

## Quick examples

Storing a conclusion:

```jsonc
honcho_create_conclusions({
  peer_id: "mux",
  target_peer_id: "steven",
  conclusions: [
    "Steven prefers TypeScript with strict mode and avoids `any`; for new TS projects, prefer Vitest over Jest."
  ]
})
```

Querying before answering a question:

```jsonc
honcho_query_conclusions({
  peer_id: "mux",
  query: "how does Steven deploy HA add-ons",
  target_peer_id: "steven",
  top_k: 5
})
```

Asking a natural-language question:

```jsonc
honcho_chat({
  peer_id: "mux",
  query: "What are Steven's design preferences for Chronicle?",
  reasoning_level: "medium"
})
```

Getting full context at session start:

```jsonc
honcho_get_peer_context({
  peer_id: "mux",
  target_peer_id: "steven"
})
```

Deleting an obsolete conclusion and replacing it:

```jsonc
honcho_delete_conclusion({
  peer_id: "mux",
  target_peer_id: "steven",
  conclusion_id: "<id-from-query>"
})
honcho_create_conclusions({
  peer_id: "mux",
  target_peer_id: "steven",
  conclusions: ["The corrected fact goes here."]
})
```

## Deployment

Honcho is hosted — no self-hosted infrastructure to manage.

`~/.mux/mcp.jsonc`:

```jsonc
{
  "servers": {
    "honcho": {
      "transport": "http",
      "url": "https://mcp.honcho.dev",
      "headers": {
        "Authorization": "Bearer <key>",
        "X-Honcho-User-Name": "Steven"
      }
    }
  }
}
```

## When the user invokes `/memory`

When the user runs `/memory <prompt>`, default behavior:

1. Run `honcho_query_conclusions` with the user's prompt verbatim
   (`peer_id: "mux"`, `target_peer_id: "steven"`).
2. If they explicitly ask to forget something, query for candidates,
   show them, and confirm before deleting with `honcho_delete_conclusion`.
3. If they explicitly ask to remember something, create a conclusion per
   this skill's policy.
