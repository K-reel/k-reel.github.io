# Migration Checklist: k-reel.github.io

**Project:** Migrate portfolio site to Chirpy theme with professional IA
**Started:** 2026-01-02
**Current Stage:** 0 (Specification)

---

## Overview

This migration is structured in 6 stages, from specification through operational polish. Each stage has explicit acceptance criteria. Stages must be completed sequentially; do not proceed to the next stage until all criteria for the current stage are met.

**Stage Summary:**
- **Stage 0:** Define target IA and taxonomy (documentation only)
- **Stage 1:** Implement theme and core structure
- **Stage 2:** Migrate content and create portfolio pages
- **Stage 3:** Integrate Artifactor publishing workflow
- **Stage 4:** Polish, optimization, and feature enhancements
- **Stage 5:** Operations, monitoring, and final launch

---

## Stage 0: Specification Complete ✓

**Goal:** Define target information architecture and taxonomy as written site specification. No code or theme changes.

**Status:** IN PROGRESS

### Acceptance Criteria

- [ ] **Specification document created:** `/docs/site-spec.md` exists with all required sections:
  - [ ] Purpose and Audience (defined)
  - [ ] Design/UX baseline (ForensicITGuy-like pattern documented)
  - [ ] Top navigation structure (core + portfolio tabs with success criteria)
  - [ ] Content types defined (Blog Post, Project Page, About, Start Here)
  - [ ] Taxonomy documented (6–8 categories, tag rules, examples)
  - [ ] Editorial standards (titles, excerpts, code, attribution)
  - [ ] Publishing workflow assumptions (front matter contract, naming, assets)
  - [ ] Stage 0 acceptance criteria (this checklist)

- [ ] **Migration checklist created:** `/docs/migration-checklist.md` exists with:
  - [ ] Stage 0 acceptance criteria (detailed, complete)
  - [ ] Stages 1–5 skeleton checklists (high-level only)
  - [ ] No implementation steps in Stage 0

- [ ] **Taxonomy is actionable:**
  - [ ] 6–8 categories proposed with clear scope definitions
  - [ ] Tag discipline rules documented (naming, reusability, anti-patterns)
  - [ ] At least 3 example posts with category + tag mappings provided

- [ ] **Front matter contract is complete:**
  - [ ] Required fields specified (title, date, categories, tags, description, toc)
  - [ ] Optional fields specified (pin, image, author)
  - [ ] File naming convention documented (`YYYY-MM-DD-title-slug.md`)
  - [ ] Asset organization rules defined (`/assets/img/posts/<slug>/`)

- [ ] **No changes outside /docs:**
  - [ ] `_config.yml` unchanged
  - [ ] No theme files edited
  - [ ] No layouts modified
  - [ ] No posts created or modified
  - [ ] No dependency changes (Gemfile, package.json, etc.)

- [ ] **Specification is implementable:**
  - [ ] All recommendations are specific and actionable (no vague guidance)
  - [ ] Success criteria for each navigation tab documented
  - [ ] Content type templates include required sections and length guidance
  - [ ] Specification is concise (1,500–2,500 words)

- [ ] **Review checkpoint:**
  - [ ] Site owner has reviewed and approved `/docs/site-spec.md`
  - [ ] Any open questions or unresolved decisions documented below

### Open Questions / Unresolved Decisions

*(Document any ambiguities, blockers, or decisions deferred to later stages)*

- None at this time (update as needed during review)

---

## Stage 1: Theme and Core Structure

**Goal:** Install Chirpy theme, configure site, and implement core navigation (Home, Categories, Tags, Archives, About).

**Status:** NOT STARTED

### Checklist

- [ ] Install Chirpy theme (fork or gem-based)
- [ ] Configure `_config.yml` with site metadata, social links
- [ ] Configure sidebar (avatar, bio, contact links)
- [ ] Implement 5 core navigation tabs (Home, Categories, Tags, Archives, About)
- [ ] Verify light/dark mode toggle and mobile responsiveness
- [ ] Test local build and GitHub Pages deployment
- [ ] Visual QA: sidebar, navigation, theme defaults functional

---

## Stage 2: Content Migration and Portfolio

**Goal:** Create portfolio pages (Projects tab), migrate or create initial blog posts, apply taxonomy.

**Status:** NOT STARTED

### Checklist

- [ ] Implement Projects navigation tab and migrate Artifactor project
- [ ] Add 1–2 additional projects matching spec template
- [ ] Create 3–5 seed blog posts with correct front matter and taxonomy
- [ ] Populate About page (bio, expertise, contact, links)
- [ ] Create and pin "Start Here" post (optional but recommended)
- [ ] Validate taxonomy: one category per post, 2–6 tags, naming conventions followed
- [ ] Verify all content renders correctly on live site

---

## Stage 3: Artifactor Workflow Integration

**Goal:** Integrate Artifactor CLI for automated post generation and publishing workflow.

**Status:** NOT STARTED

### Checklist

- [ ] Configure Artifactor for Chirpy-compatible front matter output
- [ ] Test end-to-end: input → Artifactor → `_posts/` → Jekyll build
- [ ] Set up GitHub Actions workflow for automated publishing (if applicable)
- [ ] Verify deterministic output (same input → same bytes)
- [ ] Document publishing workflow in `/docs/publishing-workflow.md`
- [ ] Publish at least 1 post via Artifactor to validate workflow

---

## Stage 4: Polish, Optimization, and Enhancements

**Goal:** Refine UX, add optional features, optimize SEO, and improve discoverability.

**Status:** NOT STARTED

### Checklist

- [ ] SEO: verify meta descriptions, add Open Graph/Twitter Card metadata, submit sitemap
- [ ] Enable and test full-text search across posts/tags/categories
- [ ] Optional features: RSS feed, comments (utterances/giscus), reading time, related posts
- [ ] Run Lighthouse audit (target >90 performance/accessibility)
- [ ] Verify WCAG AA color contrast, keyboard navigation
- [ ] Optimize images (compression, WebP if supported)
- [ ] Content polish: proofread, verify links, add alt text, check code block labels

---

## Stage 5: Operations, Monitoring, and Launch

**Goal:** Set up monitoring, analytics, backup processes, and announce public launch.

**Status:** NOT STARTED

### Checklist

- [ ] Configure analytics (Google Analytics, Plausible, or privacy-respecting alternative)
- [ ] Set up uptime monitoring and build failure alerts
- [ ] Verify all content in version control, tag release (`v1.0-launch`)
- [ ] Document backup/restore procedures in `/docs/maintenance.md`
- [ ] Announce launch on social media (Twitter, LinkedIn, Mastodon)
- [ ] Share key posts in relevant communities (Reddit, InfoSec forums)
- [ ] Update README.md and finalize documentation
- [ ] Close migration project, move to maintenance mode

---

## Notes and Maintenance

**Post-Launch:** Site moves to maintenance mode after Stage 5. Review taxonomy every 20–30 posts. Monitor analytics for content optimization.

**Future Enhancements:** Multi-author support, newsletter integration, interactive demos, Talks/Media pages.

**Review Cadence:** Owner approval required at end of each stage before proceeding.

**Definition of Done:** All checklist items complete, no regressions, changes committed, site functional/tested, documentation updated, owner sign-off.

---

## Change Log

| Date       | Stage | Change Description                  | Author |
|------------|-------|-------------------------------------|--------|
| 2026-01-02 | 0     | Initial checklist created           | Kirill |
