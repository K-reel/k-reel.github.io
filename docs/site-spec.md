# Site Specification: K-reel.github.io

**Version:** 1.0 (Stage 0)
**Date:** 2026-01-02
**Status:** Baseline specification for Chirpy theme migration

---

## 1. Purpose and Audience

**Site Purpose:**
- Primary writing hub for security research, tooling, and threat intelligence analysis
- Portfolio showcasing technical projects and contributions to the security community
- Professional credential for hiring managers, conference organizers, and peer practitioners

**Target Audience:**
- **Hiring managers and recruiters:** Looking for evidence of technical depth, writing ability, and domain expertise in cybersecurity
- **Security practitioners:** Seeking actionable insights, tools, and research on threat intelligence, DFIR, malware analysis, and offensive security techniques
- **Conference organizers and community leaders:** Evaluating speaking/contribution opportunities based on published work and project portfolio

---

## 2. Design/UX Baseline to Match (ForensicITGuy-like)

**Information Architecture Pattern:**
- Clean, distraction-free reading experience optimized for long-form technical content
- Core navigation: Home, Categories, Tags, Archives, About
- Sidebar: Avatar/logo, 2-3 line bio, social/contact links (GitHub, LinkedIn, Email, RSS)
- Mobile-responsive with collapsible sidebar

**Post UX Expectations:**
- Automatic table of contents (TOC) for posts >3 sections or >1500 words
- Syntax highlighting for code blocks with language labels
- Full-text search across all content
- Pinned posts concept: ability to feature "Start Here" or high-value content at top of Home page
- Reading time estimate displayed with post metadata
- Clean typography with good contrast for accessibility

**Visual Tone:**
- Professional, technical, minimal
- Dark/light mode toggle support (Chirpy default)
- Avoid excessive branding or decoration; let content lead

---

## 3. Proposed Top Navigation (Tabs)

### Core Tabs (Required, Stage 1–2)

**Home**
Landing page with recent posts (5–10 most recent), pinned posts at top, brief welcome message. Success criteria: visitor understands site purpose within 5 seconds, can immediately access featured content.

**Categories**
Hierarchical view of all content organized by 6–8 top-level categories. Success criteria: clear labels, balanced distribution of content, no orphaned or empty categories at launch.

**Tags**
Tag cloud or list showing all tags with post counts. Enables granular exploration (e.g., "ATT&CK," "Splunk," "YARA"). Success criteria: tags are reusable across posts, no single-use tags, clear naming conventions.

**Archives**
Chronological timeline of all posts, grouped by year and month. Success criteria: fast loading, easy scanning, links directly to posts.

**About**
Professional bio (200–400 words), background, expertise areas, contact information, and links to projects/GitHub. Success criteria: establishes credibility, provides context for the work, includes clear CTAs (hire me, collaborate, contact).

### Portfolio Tabs (Required, Stage 2)

**Projects**
Dedicated page showcasing 3–6 major projects (Artifactor, etc.) with descriptions, tech stack, links to repos/demos, and impact statements. Success criteria: each project has clear value proposition, technical depth, and external validation (stars, usage, etc.).

### Optional Future Tabs (Stage 4+)

**Talks**
Conference presentations, webinars, podcasts. Include slides, video links, and written summaries where available.

**Media**
Press mentions, interviews, guest posts, or notable community contributions.

**Resume**
PDF download link or embedded resume with skills matrix, certifications, work history.

**Contact**
Standalone contact form or email/social aggregation page.

---

## 4. Content Types and Templates

**Blog Post** (primary): Technical writing on security research, tools, techniques. Required sections: introduction, body, conclusion, references (if applicable). Length: 1000–3000 words typical; 3000+ requires TOC.

**Project Page**: Showcase tool/framework. Include: name/tagline, problem statement, key features (3–5 bullets), tech stack, links (repo/demo/docs), impact metrics. Length: 300–800 words.

**About Page**: Professional bio, expertise areas, notable work, contact info. Length: 200–400 words.

**Start Here** (pinned): Orient new visitors. Include: brief welcome, essential reading links (3–5), key projects (2–3), CTA. Length: 200–400 words.

---

## 5. Taxonomy: Categories and Tags

### Categories (Primary Organizational Layer)

**Maximum:** 6–8 top-level categories. Each post belongs to exactly one category.

**Proposed Categories:**

1. **Supply Chain Security**: Malicious packages, dependency analysis, OSS security, typosquatting, software provenance, build pipeline security.

2. **Threat Intelligence**: Malware analysis, threat actor research, campaign tracking, OSINT, indicator analysis.

3. **DFIR**: Digital forensics, incident response, memory/disk analysis, evidence handling.

4. **Detection Engineering**: SIEM rules, detection logic, hunting queries, analytics development.

5. **Tool Development**: Custom tools, scripts, frameworks, libraries (Artifactor, parsers, automation).

6. **Offensive Security**: Red team techniques, exploit development, adversary emulation, TTPs.

7. **Research & Analysis**: Whitepapers, vulnerability research, protocol analysis, reverse engineering.

8. **Quick Hits** _(optional)_: Brief tips, tool reviews, configuration snippets.

**Selection Rule:** Choose the category representing >60% of post focus. If post spans multiple areas, assign to primary topic.

---

### Tags (Granular, Reusable Metadata)

**Purpose:** Enable cross-category discovery and fine-grained filtering (e.g., show all posts tagged "ATT&CK" regardless of category).

**Tag Discipline Rules:**
- Use 2–6 tags per post (minimum 2, avoid tag spam beyond 6)
- Tags are lowercase, hyphenated (e.g., `mitre-attack`, `yara-rules`, `powershell`)
- Prefer specific, reusable tags over one-off descriptors (e.g., `cobalt-strike` not `cobalt-strike-analysis-march-2025`)
- Avoid synonyms: choose one canonical term (e.g., `malware-analysis` not both `malware-analysis` and `malware-research`)
- Use technology/tool names, frameworks, techniques, or specific threat actor/malware families

**Tag Examples (Starter Set):**
- **Frameworks/Standards:** `mitre-attack`, `cve`, `sigma`, `yara-rules`, `sbom`
- **Technologies/Tools:** `npm`, `pypi`, `splunk`, `ghidra`, `volatility`, `python`, `powershell`
- **Techniques/Concepts:** `typosquatting`, `dependency-confusion`, `memory-forensics`, `log-analysis`, `osint`, `process-injection`
- **Threat Actors/Malware:** `apt29`, `emotet`, `cobalt-strike`, `ransomware`

**Tag Anti-Patterns to Avoid:**
- Generic tags like "security" or "hacking" (too broad)
- Single-use tags that will never apply to another post
- Tags that duplicate the category (e.g., tagging a post in "DFIR" with "dfir")

---

### Categories vs. Tags Decision Matrix

| Use Category If...                          | Use Tag If...                              |
|---------------------------------------------|--------------------------------------------|
| It represents the primary topic/focus       | It describes a specific tool, technique, or framework |
| Content is mutually exclusive with others   | Content may overlap with multiple categories |
| Suitable for top-level navigation           | Suitable for filtering/search refinement   |
| Broad, thematic grouping                    | Granular, specific descriptor              |

---

### Example Taxonomy Applications

**Example 1:**
*Post:* "Detecting Malicious npm Packages via Dependency Confusion Patterns"
*Category:* Supply Chain Security
*Tags:* `npm`, `typosquatting`, `dependency-confusion`, `osint`

**Example 2:**
*Post:* "Memory Forensics of Emotet Loader Using Volatility 3"
*Category:* Threat Intelligence
*Tags:* `emotet`, `volatility`, `memory-forensics`, `malware-analysis`

**Example 3:**
*Post:* "Artifactor: A Reproducible Publishing Pipeline for Security Blogs"
*Category:* Tool Development
*Tags:* `python`, `jekyll`, `automation`, `ci-cd`

---

## 6. Editorial Standards

**Titles:** Clear, descriptive, technical. Include tool/technique names (e.g., "Detecting LSASS Dumps with Sysmon Event ID 10"). Avoid clickbait. Length: 40–70 characters.

**Excerpts:** Use `description` front matter field. Length: 120–160 characters. One-sentence summary of problem or finding.

**Code Blocks:** Always specify language for syntax highlighting. Add context/filename above blocks. Prefer short snippets; link to GitHub for full code. Include comments for non-obvious logic.

**Attribution:** Required when building on others' work. Include responsible disclosure timelines for vulnerabilities. Offensive content must include defensive mitigations. Link references inline or in References section.

---

## 7. Publishing Workflow Assumptions (Artifactor-Ready)

### Front Matter Contract

**Required fields:** `title`, `date`, `categories` (list with one category), `tags` (list, 2–6 tags), `description` (120–160 chars), `toc` (boolean).

**Optional fields:** `pin` (boolean), `image` (path), `author` (string).

**Canonical Example:**
```yaml
---
title: "Detecting Malicious npm Packages via Dependency Confusion"
date: 2026-01-15 14:30:00 -0500
categories: [Supply Chain Security]
tags: [npm, typosquatting, dependency-confusion, osint]
description: "Practical techniques for identifying malicious npm packages using dependency confusion patterns and OSINT analysis."
toc: true
# pin: true
# image: /assets/img/posts/detecting-npm-malware/hero.jpg
---
```

---

### File Naming and Assets

**Post files:** `YYYY-MM-DD-title-slug.md` (date must match front matter; slug is lowercase, hyphenated, 3–6 words).

**Images:** `/assets/img/posts/<post-slug>/` (use descriptive filenames, not `image1.png`).

**Other assets:** `/assets/files/<post-slug>/` or link to external repos.

**Artifactor integration (Stage 3+):** Tool will consume structured input, generate posts adhering to this contract, validate completeness.

---

## 8. Stage 0 Acceptance Criteria

Stage 0 is considered **DONE** when all of the following are true:

- [ ] `/docs/site-spec.md` exists and contains all 8 required sections
- [ ] Purpose, audience, and design baseline are clearly documented
- [ ] Top navigation structure is defined with success criteria for each tab
- [ ] Content types (Blog Post, Project Page, About, Start Here) are fully specified
- [ ] Taxonomy is defined: 6–8 categories proposed, tag discipline rules documented
- [ ] At least 3 example taxonomy applications (post → category + tags) are provided
- [ ] Editorial standards cover titles, excerpts, code blocks, and attribution
- [ ] Front matter contract is fully specified (required + optional fields)
- [ ] File naming convention and asset organization rules are documented
- [ ] `/docs/migration-checklist.md` exists with staged acceptance criteria (Stage 0 detailed, Stages 1–5 skeleton)
- [ ] No changes have been made to `_config.yml`, theme files, layouts, or posts
- [ ] All decisions are actionable and implementable without guesswork
- [ ] Specification is concise (1,500–2,500 words) and ready for Stage 1 execution

---

## Notes and Constraints

**Scope:** Specification only; no code/config changes in Stage 0. All recommendations Chirpy-compatible.

**Review:** Owner approval required before Stage 1. Document open questions in migration checklist.

**Future-proofing:** Design supports 50–100 posts, multi-author capability, RSS/SEO/social sharing.
