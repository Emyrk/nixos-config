# Global Agent Instructions

## Memory

You have persistent memory via the `memory` MCP server.
**Load the `memory` skill** (`agent_skill_read({ name: "memory" })`) at the
start of every session to learn the full retrieval/storage policy, tag
vocabulary, and content-format rules.

Quick reminders (the skill has the details):

- **Retrieve before answering** "how do I…", "what is…", "why do we…" questions.
- **Store** when the user says "remember", corrects you, or a decision/lesson
  is worth keeping.
- **Tag** every memory with at least a top-tag + sub-tag from the skill's
  vocabulary.
- **One sentence per memory**, self-contained, third-person, searchable.
