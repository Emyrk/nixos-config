# Global Agent Instructions

## Memory

You have persistent memory via the `memory` MCP server.
Load the full `memory` skill (`agent_skill_read({ name: "memory" })`) when you
need the complete tag vocabulary, content-format examples, or deployment details.
The rules below are sufficient for day-to-day use.

### When to retrieve

- **Before answering** "how do I…", "what is…", "why do we…" questions —
  there may be a stored preference or decision that overrides general advice.
- **First mention** of an unfamiliar project name, hostname, or service —
  pull what's known before guessing.
- **Don't retrieve** on generic technical questions, chit-chat, or every turn.

### When to store (automatically — don't wait to be asked)

Store when **any** of these are true:

- The user says "remember", "don't forget", "from now on", or similar.
- The user **corrects** a wrong assumption — store the corrected fact.
- A **decision was made with rationale** that future-you would relitigate
  without this note.
- A **gotcha or lesson** bit you that you'd hit again.
- A **personal fact** is shared that the user clearly wants remembered
  (relationships, travel, dates, preferences).

**Do not store**: passing remarks, long code snippets, conversation-only state,
or duplicates (retrieve first; if a near-duplicate exists, delete-then-replace).

### How to write a memory

One **self-contained sentence**, third-person, declarative, with enough context
for semantic search to find it.

- Bad: `"port 8000"`
- Good: `"The MCP Memory add-on listens on LAN port 8000 at http://192.168.1.123:8000/."`

### How to tag

Every memory gets **at least one top-tag + one sub-tag**. Add `project/<slug>`
when it pertains to a specific repo.

| Top tag          | Use for                        | Example sub-tags                                         |
|------------------|--------------------------------|----------------------------------------------------------|
| `personal`       | User's life                    | `personal/relationships`, `personal/travel`, `personal/dates`, `personal/finance` |
| `prefs`          | Durable opinions / conventions | `prefs/code`, `prefs/tone`, `prefs/ops`, `prefs/tools`  |
| `deploy`         | Infrastructure / deployment    | `deploy/home-assistant`, `deploy/mcp-memory`, `deploy/networking` |
| `decision`       | Choices + rationale            | `decision/architecture`, `decision/library`, `decision/process` |
| `lesson`         | Gotchas to avoid               | `lesson/docker`, `lesson/api`, `lesson/git`              |
| `project/<name>` | Project-specific facts         | `project/nixos-config`, `project/mux`                    |

Rules: lowercase, kebab-case after `/`. Don't invent new **top**-tags — use new
sub-tags under existing tops. Set `memory_type` to one of: `fact`, `preference`,
`decision`, `lesson`, `personal`.
