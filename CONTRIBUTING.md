# Contributing to the Methods Hub

This guide is written for future contributors who want to add or update resource pages. Read it alongside `CLAUDE.md` if you are working with Claude Code; `CLAUDE.md` contains the same conventions plus instructions specific to AI-assisted editing.

---

## What the hub is and isn't

The hub is a **general-purpose resource library** — not a course companion. Resource pages should be useful to any student encountering the topic, regardless of course context. If you are writing a resource that only makes sense in the context of a specific assignment or syllabus, it does not belong here.

Course sites link *into* the hub. The hub does not link *into* course sites (except from `teaching.qmd`, which lists courses with external links).

---

## Page granularity

The default unit is **workflow-level**: one page per meaningful task or concept a student sits down to do or understand (20–40 minutes). Titles are action- or understanding-oriented:

- ✓ "Reshaping Data from Wide to Long"
- ✓ "Understanding Statistical Power"
- ✗ "Data" (too broad)
- ✗ "Introduction to R, Chapter 3" (course-specific framing)

**Short concept pages** are allowed where no workflow framing makes sense — e.g., "What is Tidy Data?" or "What is Epistemology?". Test: *can a student finish this page and have accomplished or understood one specific thing?*

---

## Front matter schema

Every resource page must include this exact front matter:

```yaml
---
title: ""
description: ""
author: "Claudius Gräbner-Radkowitsch"
date: YYYY-MM-DD
date-modified: YYYY-MM-DD
image: ../../assets/images/placeholder.png

learning-objectives:
  - "Understand what tidy data is and why it matters"
  - "Use pivot_longer() to reshape a wide dataset"

categories:
  - [at least one thematic tag]

level:
  - BA          # BA | MA | PhD — list all that apply

content-type:   # exactly one of: tutorial | video | slides | reading | exercise | concept

citation:
  type: entry
  container-title: "Methods Hub"
  editor:
    - name: "Claudius Gräbner-Radkowitsch"
  url: https://yourdomain.com/resources/[category]/[slug]
---
```

**`learning-objectives` rules:**
- 2–4 objectives; more than 4 signals the page scope is too broad
- Each objective is a concrete skill or understanding, not a description of page content
- Write from the student's perspective: "Explain X", "Apply X to Y", "Distinguish X from Y"
- ✓ "Use `pivot_longer()` to reshape a wide dataset"
- ✗ "This page covers data reshaping in R"

**`author` vs `editor`:**
- If you are a contributor writing a new page, put your name in `author`
- The `editor` field lives inside the `citation:` block and is always `Claudius Gräbner-Radkowitsch` — it reflects editorial responsibility for the hub, not who wrote the page
- Do not add a top-level `editor:` key — Quarto 1.9+ reserves that key for visual editor configuration and will reject a name string

---

## Tag taxonomy

Use existing tags. Adding a new thematic tag requires also adding it to the taxonomy in `CLAUDE.md`.

**Thematic:**
`data-cleaning`, `R`, `visualization`, `experiments`, `statistics`, `regression`, `causal-inference`, `literature-review`, `research-design`, `qualitative-methods`, `reproducibility`, `quarto`, `survey-methods`, `epistemology`, `tidyverse`

**Content type** (pick exactly one):
`tutorial`, `video`, `slides`, `reading`, `exercise`, `concept`

**Level** (list all that apply):
`BA`, `MA`, `PhD`

---

## Level differentiation

Pages are written at **BA level by default**. Two patterns are allowed for adding MA/PhD content.

### Pattern 1 — inline callout (default)

Use when the page is fundamentally the same workflow for all levels, with added depth for MA/PhD. Wrap MA/PhD-specific content in:

```markdown
::: {.callout-note .level-advanced}
## 🎓 MA / PhD
Content here.
:::
```

This renders with a muted teal left border and lighter background, visually distinct from a standard note.

### Pattern 2 — separate pages per level

Use when the conceptual treatment genuinely differs across levels — not just in depth but in framing, assumed knowledge, or purpose. Examples:
- An epistemology page introducing the concept from scratch (BA) vs. engaging with the literature (PhD)
- A statistics page using intuition and visuals (BA) vs. formal notation (PhD)

When using Pattern 2:
- Each page is a standalone `.qmd` with its own front matter
- The `level` field contains only the single applicable level
- Add a sibling-link callout at the top of each page:

```markdown
::: {.callout-tip}
## 📖 Level: BA
This page is written for BA students. There is also a version for
[MA/PhD students](../epistemology-phd.qmd).
:::
```

- File naming: `[topic]-ba.qmd`, `[topic]-ma.qmd`, `[topic]-phd.qmd`
- All sibling pages share the same thematic tags so they appear together in the listing

**Deciding:** Default to Pattern 1. Switch to Pattern 2 only when the callout block would be so large and structurally different that it dominates the page.

---

## File and folder naming

- Resource pages: `kebab-case.qmd` matching the page title closely
- Category folders: `kebab-case/` (e.g., `r-programming/`, `literature-review/`)
- Track pages: `kebab-case.qmd` in `tracks/`
- Data files: `kebab-case.csv` / `.rds` etc.
- Images: `kebab-case.png` in `assets/images/`

---

## Data files

- **In the repo:** synthetic/self-generated data, small modified external datasets, small freely redistributable datasets
- **On OSF (linked, not hosted):** large datasets, verbatim third-party data, datasets where acquisition is part of the learning
- Data files live **co-located with the resource page** in a `data/` subfolder within the category folder — never in a global `/data` folder
- R scripts go in `.qmd` code blocks by default; standalone `.R` files only when genuinely needed

Example structure:
```
resources/
  data-cleaning/
    reshaping-data-wide-to-long.qmd
    data/
      survey-responses.csv
```

---

## Relative paths

Never hardcode the domain URL in `.qmd` files. Use relative paths for all internal links. This keeps the site portable when the domain changes.

---

## Build and deploy workflow

**While writing a single page:**
```bash
quarto preview resources/[category]/[page].qmd
```

**After finishing a page:**
```bash
quarto render resources/[category]/[page].qmd
quarto render resources/index.qmd
```

**Commit and push** — always include `_site/` and `_freeze/`:
```bash
git add .
git commit -m "add: [short description]"
git push
```

Netlify serves `_site/` directly and runs no build. Never configure Netlify to run `quarto render`.
