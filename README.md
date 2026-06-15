# Methods Hub

A public, citable educational resource hub for research methods — for BA, MA, and PhD students. Covers both methodological/theoretical topics (literature review, research design, experiments) and implementation topics (R, data cleaning, visualization, regression).

→ **Live site:** [euf-methodology-hub.netlify.app](https://euf-methodology-hub.netlify.app) *(update when custom domain is set)*

---

## What lives where

```
resources/    individual resource pages — the core library
tracks/       curated learning paths that sequence resources
blog/         editorial posts and updates
teaching.qmd  index of courses with links to their separate sites
assets/       styles and images
```

One rule: **resources are general, course sites are separate.** The hub links to course sites via `teaching.qmd`; it never hosts course-specific content. Course sites link into `resources/` for reusable material.

---

## Adding or updating a resource page

**1. Write or edit the `.qmd` file** in the relevant `resources/[category]/` folder.

**2. Use the full front matter schema** — see `CLAUDE.md` or `CONTRIBUTING.md` for the required fields. Every page needs `title`, `author`, `editor`, `date`, `date-modified`, `categories`, `level`, `content-type`, and a `citation` block.

**3. Preview locally:**
```bash
quarto preview resources/[category]/[page].qmd
```

**4. Render the page and update the listing:**
```bash
quarto render resources/[category]/[page].qmd
quarto render resources/index.qmd
```

**5. Commit and push — including `_site/` and `_freeze/`:**
```bash
git add .
git commit -m "add: [short description]"
git push
```
Netlify serves the new `_site/` immediately. No build runs on Netlify.

---

## Full rebuild

Only needed for structural changes (new track, new category folder, theme changes):
```bash
quarto render
git add .
git commit -m "rebuild"
git push
```

Full rebuilds are fast because `freeze: auto` skips pages whose source hasn't changed.

---

## Adding a blog post

Create a new folder under `blog/` and add an `index.qmd`:
```
blog/
  2026-06-15-my-post/
    index.qmd
```

Then render the blog listing:
```bash
quarto render blog/[post-folder]/index.qmd
quarto render blog/index.qmd
```

---

## How deployment works

- Netlify is connected to this repo but **does not run a build**
- Build command on Netlify: *(empty)*
- Publish directory on Netlify: `_site/`
- Every push updates the live site instantly from the committed `_site/`
- Never configure Netlify to run `quarto render` — build locally always

---

## Tags and conventions

See `CONTRIBUTING.md` for the full tag taxonomy, naming rules, data file policy, and level differentiation convention.

See `CLAUDE.md` for Claude Code context (same conventions, plus instructions for AI-assisted work).

---

## Citability

Every resource page auto-generates a citation block at the bottom. To cite a resource in a course outline, use the citation shown on the page. The `editor` field is always Claudius Gräbner-Radkowitsch. Future contributor pages list the contributor as `author`.

---

## Tech stack

- [Quarto](https://quarto.org) — site framework
- [Netlify](https://netlify.com) — hosting
- R + knitr — code execution in resource pages
- `freeze: auto` — caches R output so unchanged pages don't re-execute
