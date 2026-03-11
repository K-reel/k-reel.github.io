---
title: "Identifying and Preventing Fraudulent Engineering Candidates: An Investigation into 80 Confirmed Cases"
short_title: "Identifying and Preventing Fraudulent Engineering Candidates"
date: 2025-09-17 12:00:00 +0000
categories: [Threat Reports]
tags: [North Korea, Wagemole, LinkedIn, Impersonation, T1585.001, T1585.002]
author: kirill_and_lauren
canonical_url: https://socket.dev/blog/fraudulent-engineering-candidates-investigation
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/69bec0d1acf1c104f5412cc0e8dc3d674f04104c-1024x1024.png
  alt: "Identifying and Preventing Fraudulent Engineering Candidates"
description: "Socket identified 80 fake candidates targeting engineering roles, including suspected North Korean operators, exposing the new reality of hiring as a security function."
---

After more than a decade in talent, one thing stays true: effective hiring requires both art and science. It's always been about getting strong signal, asking the right questions, weighing experience against potential, and knowing when to prioritize instinct over data. This philosophy now applies in ways I couldn't have imagined even 18 months ago - as a company's front-line defense system.

Today we're publishing research from our threat intelligence team on 80 confirmed fraudulent candidates identified in the past two months. They're part of a coordinated campaign that includes suspected North Korean operators, aimed at infiltrating engineering pipelines through job applications.

[Fraudulent applicants aren't new](https://www.forbes.com/councils/forbeshumanresourcescouncil/2025/08/13/fraudulent-candidates-are-on-the-rise-what-employers-need-to-know/), yet the scale and sophistication we're seeing now are unmatched. Screening for fit and skill is no longer enough. You're now screening for authenticity at the same time. Vetting processes now take twice the effort, with teams balancing thoroughness against candidate experience.

Remote work and global hiring have broadened access to incredible talent, but they have also opened doors for fraudulent candidates trying to exploit those opportunities. I've come across resumes with marquee logos stacked one after another, LinkedIn URLs that lead to nonexistent pages, and engineers claiming decade-long open source careers with no verifiable code behind them. Increasingly, we're seeing attempts to bypass safeguards with AI-generated resumes and identities built from fragments of other people's careers.

## Security Is Now a Core Function of Recruiting

The recruiting ecosystem is scrambling to catch up. Some applicant tracking systems, like [Ashby](https://www.ashbyhq.com/), are now [digital footprint checks to flag suspicious behavior](https://www.linkedin.com/posts/benjaminencz_today-im-very-excited-to-announce-the-activity-7373725298397396993-1iSB?utm_source=share&utm_medium=member_desktop&rcm=ACoAADm_lRQBZAkzQn6j3WzI56lLhtpdFlbnPQc). Others are experimenting with metadata scans to identify resume builders or stock phrasing. But most of the defense still rests with talent teams staying alert, sharing context across the interview loop, and following their instincts. If something feels off, it probably is.

Every resume that crosses my desk requires forensic-level scrutiny. Every video interview demands heightened vigilance for deepfake indicators. Reviewing a resume used to take just a few minutes but now it requires around three times as much time for evaluation, not because candidates are more complex, but because the stakes of getting it wrong have never been higher.

The traditional hiring funnel has become a security perimeter. Every touchpoint, from initial application to final offer, now requires verification protocols that would have seemed excessive just eighteen months ago. I'm looking for a variety of signals like verified government-issued IDs on LinkedIn, cross-referencing email addresses, and running back-channel references through trusted industry contacts, to name a few. These signals have gone from optional to essential for keeping the hiring process secure.

We're building the plane while flying it, developing new protocols in real-time as threat actors adapt their tactics. In-person final interviews have taken on dual purpose. Yes, we're still evaluating culture fit, i.e. how candidates interact with the team and their collaboration skills. But we're also confirming basic legitimacy: Is this the person we've been interviewing? Do they demonstrate the expertise they've claimed? Can they sustain the level of technical discussion we'd expect from their stated experience?

## The Candidate Experience Paradox

Here's what keeps me up at night: legitimate candidates are caught in this new reality too. Exceptional engineers now need to think about how they demonstrate their "realness" to future employers. They need to maintain public profiles, contribute to open source, establish verifiable digital footprints, not just to demonstrate competence, but to prove they exist. The burden of proof has shifted, and authentic candidates are caught in the crossfire.

For remote-first companies like Socket, this challenge is particularly acute. We've always believed globally distributed talent gives us an advantage and that geographic boundaries shouldn't limit our ability to build exceptional teams. But when you can't shake someone's hand, when every interaction is mediated by screens and software, verification becomes exponentially harder.

## Building Resilient Hiring Systems

Hiring will always be about finding the right people, for the right roles, at the right time, but now it's also about guarding the front door. The path forward requires fundamental changes to how we approach talent acquisition. We're implementing multi-layered verification that would have seemed like overkill two years ago but now feels like bare minimum:

- **Portfolio requirements** that can withstand scrutiny—real code, real commits, real contribution history

- **Automated enrichment** in our ATS to extract PDF metadata and flag resume-builder fingerprints

- **Behavioral analysis** during video interviews, with multiple team members trained to spot anomalies

- **Sandboxed evaluation environments** for any code submissions or technical assessments

- **Identity verification** protocols that balance security with candidate privacy

- **Cross-functional collaboration** between talent, security, and engineering teams

This isn't the future of hiring I envisioned when I started my career. But it's the reality we're operating in, and we're adapting quickly. The companies that survive this wave of fraudulent candidates will be those that treat their talent team as a security function, that invest in the tools and training necessary to identify warning signs early.

Our above the bar and multi-layered screening process has successfully caught these attempts early (none of these fraudulent candidates made it past initial stages) but the sheer volume and sophistication of attempts is still concerning.

What we're uncovering at Socket is likely just the tip of the iceberg. Our threat research team has compiled disturbing evidence of organized campaigns targeting tech companies, campaigns that align with public reporting on state-sponsored operations designed to infiltrate technology companies. The technical analysis that follows reveals the systematic nature of these attempts and the specific indicators we've identified across dozens of fraudulent applications.

*The following investigation was conducted by Socket's Threat Research Team:*

We are seeing a surge in fraudulent developer applicants, including suspected North Korean threat actors. Over the past few months we reviewed over 80 suspicious engineering resumes and profiles. Technical and OSINT review found recurring signal clusters that suggest organized attempts to infiltrate hiring pipelines: minimal or nonexistent online footprints for supposed senior engineers; claims our investigation found conflicting or false when checked against cited public profiles and repository history; impersonation-style contact details; and unverified claims of employment at marquee firms. The pattern aligns with public [reporting](https://www.cnn.com/interactive/2025/08/05/world/north-korea-it-worker-scheme-vis-intl-hnk/index.html) on North Korean IT worker operations that generate hundreds of millions of dollars annually and target tech companies using synthetic identities.

A fraudulent hire, contractor, or vendor developer gains immediate proximity to source code, credentials and sensitive data, build systems, and the project's dependency graphs. One insider can seed malware, modify build scripts, or publish weaponized code that propagate to customers.

At Socket, a developer-first company, we start with a clear baseline for authenticity: inspectable code, verifiable history, and a consistent record corroborated across the resume, public profiles, and references. When details diverge on several fronts, we scrutinize and escalate.

## Methodology

Our investigation focused on early screening signals that HR, talent, and security teams can observe. We analyzed the uploaded corpus of 80 resumes and profiles flagged as suspicious. We extracted names, emails, phones, and outbound links, resolved LinkedIn and GitHub URLs, and examined PDF metadata. We also reviewed and checked employment claims that named marquee technology firms.

We evaluated combinations of signals rather than single anomalies. Key signals included mismatches between the name and the email local part, inauthentic or nonfunctional LinkedIn and GitHub profiles, unverifiable stacking of marquee employers, impersonation-style email handles that append terms such as `dev`, `work`, `tech`, or `soft`, resume builder fingerprints in PDF metadata from platforms that offer AI features, including `Enhancv` and `FlowCV`, and explicit English proficiency claims that conflicted with performance on live calls. Each signal is weak on its own; together they indicate elevated risk. We escalated profiles with multiple independent indicators with our Threat Research team and ultimately rejected them.

## What We Observed Across 80 Resumes

Most shared the same structural tells. Many included neither a LinkedIn link nor a link to any code repository. An absent LinkedIn profile by itself is not a problem; providing a LinkedIn URL that resolves to a 404 is a clear red flag. It is also highly unusual for a senior engineer who claims more than a decade of experience, leadership, and open source contributions to provide no links to public code or projects. In several cases the email address did not match or correctly spell the candidate's name, which we later identified as likely impersonation attempts. Thirty listed two or more marquee employers in quick succession without verifiable proof.

We also ran back-channel verification with trusted industry contacts. In multiple cases, claimed employment did not hold up, including no record of the candidate at the named company and identity overlap with real employees whose start dates differed by years from the resume. These checks reinforce our assessment of synthetic personas and impersonation tactics.

![Fraudulent candidate LinkedIn 404](https://cdn.sanity.io/images/cgdhsj6q/production/d01d5d8072b244dd32693790e0f50695e08fd6f7-2048x1013.png)
_Fraudulent candidate's cited LinkedIn profile resolves to "This page doesn't exist", confirming a nonfunctional link and a strong screening red flag._

## Scraped Vacancies and AI-Assisted Resume Generation

Many resumes reused phrasing from our vacancy notices and from unrelated professionals' public profiles. The text reads smoothly, but it breaks under verification. Dates, titles, locations, and stack details drift, and identical sentences recur across submissions. Claimed projects do not map to public code, commits, issues, talks, or publications you would expect from a senior engineer.

![Enhancv resume builder homepage](https://cdn.sanity.io/images/cgdhsj6q/production/589badc141b407b2564cbc8b4a65df30c713f391-2048x1037.png)
_Enhancv resume builder homepage; PDFs exported from this platform list Enhancv in metadata fields, a fingerprint we observed across multiple fraudulent resumes._

## Case Snapshots (Anonymized)

- **Candidate A**: Claimed Senior AI and DevOps engineer. No LinkedIn or GitHub links, multiple marquee employers cited, and PDF metadata showed `Enhancv` as the producer. The email handle ended in `dev`. During screening, the candidate could not sustain a basic, coherent conversation in English, despite claiming more than a decade of U.S. experience and education.

- **Candidate B**: Claimed Principal Engineer with ten years across Facebook, Apple, Amazon, Netflix, and Google. The LinkedIn URL was malformed and no GitHub link was provided. The candidate claimed Kubernetes and Terraform leadership, yet we found no corroborating repositories, talks, issues, or public project history.

![Mock resume with screening red flags](https://cdn.sanity.io/images/cgdhsj6q/production/54479b346675d34e9b398e937789a28bcb46c4fe-2038x2012.png)
_Mock resume demonstrating combined screening red flags: name-to-email mismatch with impersonation-style handles, malformed LinkedIn and GitHub links, marquee-brand stacking, unverifiable "high-impact" claims, a resume-builder fingerprint in PDF metadata, a languages section with an English-proficiency line atypical for long-claimed U.S. tenure, "Berkeley" misspelled, and no verifiable code. Taken together, these individually minor indicators create a strong triage case._

## Identity Signals

Identity is a web of signals that should align. In developer communities, authentic engineers almost always leave traces: conference talks, issue trackers, mailing lists, package history, and repositories. In our set, senior applicants lacked a coherent trail.

We also saw impersonation and fabrication. In several cases an applicant reused a real engineer's biography, then submitted different contact details. Some created LinkedIn profiles that were newly created or verified with identification from a country that did not match the claimed residence. Each signal is weak on its own; in combination they warrant escalation.

In one case we identified a suspected sock puppet GitHub profile. At the time of writing, it contained no substantive projects, only two repositories with README text asserting employment as an engineer. The profile's outbound links returned 404s, and the supposed blog work samples either led nowhere or redirected to unrelated pages. Taken together, these signals indicate a fabricated profile created to support a fraudulent job application.

![Suspected sock puppet GitHub profile](https://cdn.sanity.io/images/cgdhsj6q/production/1f3fd2af8d38f2880ae1201c9e4e9d74db69cd6d-2048x1198.png)
_Suspected sock puppet GitHub profile with insubstantial repositories, and external links that lead nowhere._

The [Department of Justice](https://www.justice.gov/opa/pr/justice-department-announces-coordinated-nationwide-actions-combat-north-korean-remote) and the [Treasury](https://home.treasury.gov/news/press-releases/jy2790) describe a similar pattern: North Korean IT workers reuse stock material, fabricate biographies, and rely on facilitators to pass hiring gates. [Unit 42](https://unit42.paloaltonetworks.com/north-korean-synthetic-identity-creation/) and [KnowBe4](https://blog.knowbe4.com/how-a-north-korean-fake-it-worker-tried-to-infiltrate-us) have documented synthetic personas, newly created LinkedIn accounts, and real-time deepfakes used to secure roles.

## Outlook and Recommendations

The modern hiring pipeline sits next to the production line. In tech organizations, candidate code may touch your repositories before employment is finalized. Remote work widened this surface. Threat actors saw the opening. Public [advisories](https://www.ic3.gov/PSA/2025/PSA250123) and recent [cases](https://www.cnn.com/interactive/2025/08/05/world/north-korea-it-worker-scheme-vis-intl-hnk/index.html) describe North Korean threat actors who use synthetic identities, deepfakes in interviews, and long chains of facilitators to win remote roles, then channel earnings and access back to sanctioned entities.

HR, talent, and security teams should anticipate copycat efforts and tool reuse, continued pressure on tech companies, broader use of resume generators, fresher or purchased social profiles, and thin code repository footprints seeded just enough to pass a glance. Expect more polished sock puppet portfolios, take-home projects completed by third parties, and expansion into adjacent surfaces such as contractor platforms and vendor onboarding portals.

Treat talent intake as a security surface shared by HR, talent, and security teams. Use a shared checklist and train your teams. Require a portfolio you can verify, and validate public profiles. Record account age, URL validity, and timeline coherence. Automate enrichment in the applicant tracking systems (ASTs) to extract PDF metadata, and flag risk patterns. The FBI and IC3 [publish](https://www.ic3.gov/PSA/2025/PSA250123) current guidance on North Korean IT worker schemes that can further shape your process.

Raise the signal across the interview loop. Brief interviewers on what to watch for in video calls, and if signal remains thin, move on. Ask candidates to verify identity where policy allows. Share notes across the hiring team to build vigilance and a stronger recruiting culture. Track your ATS roadmap for fraud checks like IP addresses and device risk, and pilot features from vendors such as Ashby as they launch. Encourage informed intuition: if something feels off, pause and escalate.

Treat recruiting as front line defense. Screen for fraud and fit in parallel, and plan for longer vetting. Run trials with least privilege using containerized sandboxes for take home work, ephemeral repositories, temporary tokens, and read only access. Review any script that runs automatically, including lifecycle hooks, `postinstall` steps, and CI jobs. Restrict build egress by default and alert on unexpected network calls.

Adopt continuous supply chain monitoring. Use the [Socket GitHub App](https://socket.dev/features/github?utm_source=chatgpt.com) to scan pull requests in real time and block unsafe dependency changes. Run the [Socket CLI](https://socket.dev/features/cli?utm_source=chatgpt.com) during installs and in CI to fail on red flags and catch transitive issues early. Add the [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1&utm_source=chatgpt.com) to surface package risk while browsing registries, and use [Socket MCP](https://socket.dev/blog/socket-mcp?utm_source=chatgpt.com) to screen LLM suggestions for malicious or hallucinated packages. Make these checks mandatory with required PR status gates and CLI enforcement in all build and release jobs. Together, these measures reduce exposure by stopping risky code at the point of introduction.

## MITRE ATT&CK

- T1585.001 — Establish Accounts: Social Media Accounts
- T1585.002 — Establish Accounts: Email Accounts
