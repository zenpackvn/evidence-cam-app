# Architecture Decision Records

Short records of decisions that constrain future work: tooling, CI shape,
dependencies, architecture boundaries. One file per decision,
`NNNN-short-slug.md`, numbered sequentially, never rewritten — a superseding
decision gets a new file that links back.

Check here before revisiting a settled question; add a record when making a
choice the next person would otherwise re-litigate.

Format (keep it under ~25 lines):

```markdown
# NNNN. <Decision title>

Date: YYYY-MM-DD
Status: accepted | superseded by NNNN

## Context
Why a decision was needed; the forces at play.

## Decision
What we chose.

## Consequences
What this buys us and what it costs; when to revisit.
```
