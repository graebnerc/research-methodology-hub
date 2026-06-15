# Methods Hub — Claude Project Context

## What this project is

A public, citable educational resource hub for research methods, serving BA, MA, and PhD students. Covers both methodological/theoretical topics (literature review, research design, epistemology, experiments) and implementation topics (R, data cleaning, visualization, regression).

Built with **Quarto**, hosted on **Netlify**, deployed to a custom domain (TBD).

## Architecture — read this first

**The hub is authoritative.** Course sites link into the hub. Content flows outward, never inward.

- `resources/` — the core library of individual resource pages
- `tracks/` — curated thematic learning paths that sequence resource pages
- `blog/` — editorial commentary and updates
- `teaching.qmd` — a single page listing courses with links to their separate sites

Course sites are separate deployments and are not mirrored or reproduced here. The hub has no course-specific content. Tracks may loosely reflect course sequences but are written as general learning paths, not course companions.

## Conventions

### Resource page granularity
Default unit is **workflow-level**: one page per meaningful task or concept a student sits down to do or understand (20–40 min). Titles are action- or understanding-oriented: "Reshaping Data from Wide to Long", "Understanding Statistical Power".

Exception: short **concept pages** are allowed where no workflow framing makes sense ("What is Tidy Data?", "What is Epistemology?"). Test: *can a student finish this page and have accomplished or understood one specific thing?*

### Front matter schema
Every resource page must include this front matter exactly:

```yaml
---
title: ""
description: ""
author: "Claudius Gräbner-Radkowitsch"
date: YYYY-MM-DD
date-modified: YYYY-MM-DD
image: ../../assets/images/placeholder.png

learning-objectives:             # MANDATORY — 2–4 bullet points, each a concrete skill or understanding
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

`learning-objectives` must be concrete and action-oriented — what a student can *do or explain* after finishing the page, not a description of what the page covers. "Understand the difference between wide and long format" is acceptable. "This page covers data reshaping" is not. Aim for 2–4 objectives; more than 4 is a sign the page scope is too broad.

### Level differentiation
Pages are written at **BA level by default**. There are two sanctioned patterns for handling level differences:

**Pattern 1 — inline callout (default)**
Use this when the page is fundamentally the same workflow or concept for all levels, with added depth for MA/PhD. MA/PhD-specific content is wrapped in a custom callout:

```markdown
::: {.callout-note .level-advanced}
## 🎓 MA / PhD
Content here.
:::
```

**Pattern 2 — separate pages per level (explicit exception)**
Use this when the conceptual treatment genuinely differs across levels — not just in depth but in framing, assumed knowledge, or purpose — and merging them into one page would make both versions worse. Examples: an epistemology page for BA students introducing the concept from scratch vs. a PhD page engaging with the literature; a statistics page that uses intuition and visuals for BA vs. formal notation for PhD.

When using separate pages:
- Each page is a standalone `.qmd` with its own front matter
- The `level` field contains only the single applicable level (`BA`, `MA`, or `PhD`)
- Add a prominent callout at the top of each page flagging the intended level and linking to sibling pages:

```markdown
::: {.callout-tip}
## 📖 Level: BA
This page is written for BA students. There is also a version for
[MA/PhD students](../epistemology-phd.qmd).
:::
```

- File naming convention: `[topic]-ba.qmd`, `[topic]-ma.qmd`, `[topic]-phd.qmd`
- All sibling pages share the same thematic tags so they appear together in the resource library

**Deciding between the two patterns**
Default to Pattern 1. Switch to Pattern 2 only when you find yourself writing a callout block so large and structurally different that it dominates the page — that is the signal a separate page is warranted. If in doubt, start with Pattern 1 and split later.

### Tags
Use existing tags from the taxonomy before inventing new ones. Current tags:

**Thematic:** `data-cleaning`, `R`, `visualization`, `experiments`, `statistics`, `regression`, `causal-inference`, `literature-review`, `research-design`, `qualitative-methods`, `reproducibility`, `quarto`, `survey-methods`, `epistemology`, `tidyverse`

**Content type:** `tutorial`, `video`, `slides`, `reading`, `exercise`, `concept`

**Level:** `BA`, `MA`, `PhD`

New thematic tags may be added when genuinely needed — add them to this file.

### Data files
- **In the repo:** synthetic/self-generated data, small modified external datasets, small freely redistributable datasets
- **On OSF (linked, not hosted):** large datasets, verbatim third-party data, datasets where acquisition is part of the learning
- Data files live **co-located with the resource page** that uses them, in a `data/` subfolder within the resource's category folder
- R scripts go **in the `.qmd` file as code blocks** by default; standalone `.R` files only when genuinely needed

### File naming
- Resource pages: `kebab-case.qmd` matching the page title closely
- Data files: `kebab-case.csv` / `.rds` etc.
- Images: `kebab-case.png` in `assets/images/`
- Track pages: `kebab-case.qmd` in `tracks/`

### Tracks
Each track page has three parts:
1. Editorial intro (who it is for, what they will be able to do)
2. Manually ordered core sequence with one-sentence annotation per resource
3. Auto-generated "Related resources" listing filtered by relevant tags

### Citability
Every resource page auto-generates a citation block via Quarto's citation feature. The `editor` field is always `Claudius Gräbner-Radkowitsch`. When future contributors add pages, they appear as `author`; the editor field stays the same.

### Relative paths
**Never hardcode the domain or Netlify URL** anywhere in `.qmd` files. Always use relative paths for internal links. This ensures the custom domain migration is seamless.

## Folder structure

```
methods-hub/
├── _quarto.yml
├── index.qmd
├── about.qmd
├── teaching.qmd                  ← single page: list of courses with external links
├── CONTRIBUTING.md
├── CLAUDE.md
├── README.md
│
├── resources/
│   ├── index.qmd                 ← Quarto listing (searchable, filterable)
│   ├── data-cleaning/
│   │   ├── [resource].qmd
│   │   └── data/
│   ├── r-programming/
│   ├── visualization/
│   ├── experiments/
│   ├── statistics/
│   ├── literature-review/
│   ├── research-design/
│   └── [grow as needed]
│
├── tracks/
│   ├── index.qmd
│   └── [track-name].qmd
│
├── blog/
│   ├── index.qmd
│   └── YYYY-MM-DD-slug/
│       └── index.qmd
│
└── assets/
    ├── styles/
    │   └── custom.scss
    └── images/
```

## Deployment

**The site is built locally and `_site/` is pushed to Git. Netlify serves `_site/` directly — it never runs a build.**

Netlify configuration:
- Build command: *(empty — leave blank)*
- Publish directory: `_site/`

`_site/` is committed to the repo. `_freeze/` is also committed — it caches executed R output so unchanged pages are not re-executed on the next render.

### Daily workflow

**While writing a single page** — live preview, only that file re-renders on save:
```bash
quarto preview resources/[category]/[page].qmd
```

**After finishing a page** — render the page and update the listing:
```bash
quarto render resources/[category]/[page].qmd
quarto render resources/index.qmd
```

**Full rebuild** — only when making structural changes, adding a new track, or before a significant release:
```bash
quarto render
```

**Deploy** — commit everything including `_site/` and `_freeze/`, then push:
```bash
git add .
git commit -m "add: [description]"
git push
```
Netlify picks up the new `_site/` immediately. No build triggered.

### Keeping local builds fast

- `freeze: auto` is set in `_quarto.yml` — only pages whose source changed since last render get re-executed
- Keep R code in resource pages light — load data, produce one or two outputs, nothing more
- Heavy computation belongs in a separate script; save output as `.rds` or a plot file and read it on the page
- Use `#| cache: true` on any slow chunk that doesn't change often

## What Claude Code should never do

- Hardcode the domain URL in content files
- Create resource pages without the full front matter schema, including `learning-objectives`
- Write `learning-objectives` as page descriptions rather than concrete student-facing skills ("This page covers X" is wrong; "Explain X" or "Apply X to Y" is correct)
- Invent new tags without adding them to the taxonomy in this file
- Put data files in a global `/data` folder — always co-locate with the resource page
- Write course-specific content into resource pages — resource pages are general
- Create a `courses/` folder or any course-specific pages — course sites are separate deployments
- Duplicate content that already exists as a resource page
- Create separate pages per level without following the Pattern 2 naming convention and sibling-link callouts defined in the level differentiation section
- Add a Netlify build command or suggest configuring Netlify to run `quarto render`
- Remove `_site/` or `_freeze/` from version control
- Suggest running `quarto render` (full) when only a single page has changed
