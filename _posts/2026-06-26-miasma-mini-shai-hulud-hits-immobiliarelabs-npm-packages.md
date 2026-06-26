---
title: "Miasma Mini Shai-Hulud Hits ImmobiliareLabs npm Packages"
date: 2026-06-26 12:00:00 +0000
categories: [Malware, npm]
tags: [Shai-Hulud, TeamPCP, Worm, Infostealer, Obfuscation, Developer Compromise, npm, JavaScript]
author: socket_research_team
canonical_url: https://socket.dev/blog/miasma-mini-shai-hulud-hits-immobiliarelabs-npm-packages
source: Socket
image:
  path: /assets/img/posts/miasma-mini-shai-hulud-hits-immobiliarelabs-npm-packages/cover.png
  alt: "Miasma Mini Shai-Hulud Hits ImmobiliareLabs npm Packages"
description: "Miasma Mini Shai-Hulud hits @immobiliarelabs Backstage plugins, targeting GitLab and LDAP auth packages on npm."
---

Socket Threat Research is tracking a fresh compromise in the [ongoing](https://socket.dev/blog/miasma-mini-shai-hulud-hits-leoplatform-npm-packages-go-ecosystem) Miasma Mini Shai-Hulud supply chain campaign. The latest activity affects legitimate npm packages published under the `@immobiliarelabs` scope, including Backstage plugins used for GitLab integration and LDAP authentication.

This appears to be a continuation of the activity we [reported](https://socket.dev/blog/miasma-mini-shai-hulud-hits-leoplatform-npm-packages-go-ecosystem) yesterday involving `LeoPlatform` and `RStreams` npm packages, GitHub Actions workflow abuse, AI-agent persistence, and the Verana Go module/source-repository compromise. The new ImmobiliareLabs activity follows the same broader campaign pattern: compromise trusted developer infrastructure, publish malicious package versions, stage JavaScript malware through Bun, steal developer and CI/CD secrets, and use the stolen access to propagate further.

The important development is not a new malware family or a materially different payload. It is the expansion of the campaign into another legitimate open source maintainer scope, this time involving Backstage plugins that sit close to internal developer portals, source-control integrations, and authentication workflows.

This remains an ongoing investigation. Socket will continue updating the campaign [tracker](https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack) as additional affected artifacts, repository indicators, and exfiltration infrastructure are confirmed.

![](https://cdn.sanity.io/images/cgdhsj6q/production/6a48e7d4fe921df17479f6d6692b4f979848d31b-2048x654.png?w=1600&q=95&fit=max&auto=format)
_Socket flags [`@immobiliarelabs/backstage-plugin-gitlab-backend@7.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/7.0.2) as part of the Miasma Mini Shai-Hulud campaign, showing that the latest release and multiple historical versions were compromised rather than a single isolated artifact._


## Publish Burst Under `@immobiliarelabs`

The malicious releases were published in a tight window on June 26, 2026. Socket identified affected artifacts across related npm packages:

1. [`@immobiliarelabs/backstage-plugin-gitlab@1.0.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/1.0.1)
1. [`@immobiliarelabs/backstage-plugin-gitlab@2.1.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/2.1.2)
1. [`@immobiliarelabs/backstage-plugin-gitlab@3.0.3`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/3.0.3)
1. [`@immobiliarelabs/backstage-plugin-gitlab@4.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/4.0.2)
1. [`@immobiliarelabs/backstage-plugin-gitlab@5.2.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/5.2.1)
1. [`@immobiliarelabs/backstage-plugin-gitlab@6.13.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/6.13.1)
1. [`@immobiliarelabs/backstage-plugin-gitlab@7.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab/overview/7.0.2)
1. [`@immobiliarelabs/backstage-plugin-gitlab-backend@3.0.3`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/3.0.3)
1. [`@immobiliarelabs/backstage-plugin-gitlab-backend@4.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/4.0.2)
1. [`@immobiliarelabs/backstage-plugin-gitlab-backend@5.2.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/5.2.1)
1. [`@immobiliarelabs/backstage-plugin-gitlab-backend@6.13.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/6.13.1)
1. [`@immobiliarelabs/backstage-plugin-gitlab-backend@7.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-gitlab-backend/overview/7.0.2)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth@1.1.4`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth/overview/1.1.4)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth@2.0.5`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth/overview/2.0.5)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth@3.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth/overview/3.0.2)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth@4.3.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth/overview/4.3.2)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth@5.2.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth/overview/5.2.1)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth-backend@1.1.3`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth-backend/overview/1.1.3)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth-backend@2.0.5`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth-backend/overview/2.0.5)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth-backend@3.0.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth-backend/overview/3.0.2)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth-backend@4.3.2`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth-backend/overview/4.3.2)
1. [`@immobiliarelabs/backstage-plugin-ldap-auth-backend@5.2.1`](https://socket.dev/npm/package/@immobiliarelabs/backstage-plugin-ldap-auth-backend/overview/5.2.1)

The publication pattern is consistent with a fast automated republish wave. Multiple historical versions were republished with malicious artifacts, suggesting the threat actor attempted to maximize exposure across users pinned to older major versions.


## ImmobiliareLabs

ImmobiliareLabs is the technology organization behind [Immobiliare.it](https://labs.immobiliare.it/), a major Italian real estate platform. Public company materials describe [Immobiliare.it](http://Immobiliare.it) as a leading property portal in Italy, with a large network of agencies, listings, and consumer traffic. ImmobiliareLabs also publicly emphasizes its use of open source, GitLab-based CI/CD, Kubernetes infrastructure, and public GitHub projects.

The compromised packages are Backstage plugins. Backstage is commonly used as an internal developer portal, where source-code metadata, service catalogs, CI/CD signals, authentication, and developer workflows converge. A compromise of packages used in that context is especially concerning because the install environment may have access to internal source-control tokens, package publishing credentials, CI/CD secrets, cloud credentials, or authentication-related configuration.

The GitLab plugin family is designed to surface GitLab project context inside Backstage. The LDAP Auth plugin family is designed to support LDAP authentication flows in Backstage deployments. The malware does not need to exploit GitLab or LDAP directly to create risk. It only needs to execute in the environment where these packages are installed or built.


## Hidden Payloads Steal Developer Credentials

Initial review of the `@immobiliarelabs/backstage-plugin-gitlab@7.0.2` tarball shows a pattern that can mislead shallow package review. The normal `dist/index.cjs.js` entrypoint appears benign, but the malicious tarball adds a root-level `index.js` that decrypts and executes a hidden payload, bootstraps Bun if needed, and runs a second-stage script.

A reviewer who only inspects the declared application entrypoint or compiled `dist` output may miss the malicious execution path added at the package root. This follows the broader Miasma trend of hiding execution outside the most obvious package metadata, moving away from simple `preinstall` or `postinstall` scripts and toward less visible package-manager, build, workflow, and developer-tool triggers.

We are not re-running the full technical analysis here because the payload behavior continues the same pattern documented in [yesterday’s coverage](https://socket.dev/blog/miasma-mini-shai-hulud-hits-leoplatform-npm-packages-go-ecosystem):

- Install-time execution via "Phantom Gyp" binding.gyp trick: node-gyp command expansion invokes `node index.js` without relying on preinstall or postinstall hooks.
- Root index.js is a single-line Caesar-shift loader followed by AES-128-GCM decryption and multi-stage payload delivery.
- Third-stage payload runs under Bun v1.3.13, downloads if absent, and executes the final malware.
- Payload steals developer and CI/CD secrets: .env files, npm/PyPI/GitHub/Slack/Twilio/AWS/Azure/GCP/Vault tokens, SSH keys, Docker credentials, Kubernetes configs.
- Abuses GitHub Actions: injects malicious workflow steps, pivots to downstream repositories.
- Plants persistence hooks in AI-coding-assistant plugins and IDE extensions.
- Exfiltrates stolen secrets via the GitHub API to attacker-controlled repositories.

The payload also preserves a distinctive campaign marker observed in prior Miasma activity: `thebeautifulsnadsoftime`. The string appears inside obfuscated payload material and is useful as a clustering indicator because of its unusual spelling and reuse across waves. The phrase may be an intentional misspelling of “the beautiful sands of time”, possibly echoing the pop-culture naming pattern seen in earlier Miasma artifacts, including prior video game-themed references.


## GitHub Actions Deployment as Initial Trigger

The ImmobiliareLabs wave also includes a GitHub Actions lead. A public run in `immobiliare/backstage-plugin-gitlab` shows a workflow named `Dependabot Updates`, triggered via deployment on June 26, 2026 at 15:00 UTC, associated with the `simonecorsi` account, and completing successfully. The workflow view shows `release.yml` configured with `on: deployment`.


## Possible upstream compromise path: `codfish/semantic-release-action`

One additional lead points to the compromised `codfish/semantic-release-action` as a possible upstream access path affecting the `simonecorsi` account and related release automation. Public GitHub code search shows repositories under the `simonecorsi` organization referencing `codfish/semantic-release-action`, a third-party GitHub Action used to run semantic-release in CI/CD release workflows.

The `codfish/semantic-release-action` was itself compromised on June 24, 2026. StepSecurity reported that an attacker force-pushed malicious commits and repointed mutable version tags, causing downstream workflows that referenced those tags to execute attacker-controlled code inside GitHub Actions runners. The malicious action converted the original Docker-based action into a composite action, installed Bun, and executed an obfuscated JavaScript payload. StepSecurity also reported that the payload targeted GitHub OIDC tokens, GitHub personal access tokens, and CI/CD secrets, and attempted follow-on repository compromise.

This provides a plausible route from a compromised third-party GitHub Action into release automation for projects that used `codfish/semantic-release-action` by mutable tag rather than immutable commit SHA. If a `simonecorsi`-controlled workflow executed the compromised action with npm publishing credentials, GitHub tokens, or deployment permissions available to the runner, the attacker could have gained the access needed to publish malicious `@immobiliarelabs` package versions or trigger follow-on GitHub Actions activity.

We do not assess this as confirmed root cause without runner logs, token-use telemetry, or maintainer confirmation. However, the timing, the use of semantic-release automation, the tag-hijacking technique, and the later ImmobiliareLabs package publish burst make `codfish/semantic-release-action` a high-priority lead for incident reconstruction.

Security researcher Adnan Khan publicly [warned](https://x.com/adnanthekhan/status/2070532262475551181) that an unpatched GitHub Actions privilege-escalation issue could allow attackers to dump Actions secrets or abuse OIDC without the `workflow` OAuth scope, and recommended blocking the technique by restricting workflow execution on the `deployment` trigger.

<blockquote class="twitter-tweet">
  <a href="https://x.com/adnanthekhan/status/2070532262475551181"></a>
</blockquote>
<script async src="//platform.twitter.com/widgets.js"></script>

Socket’s analysis of the Miasma activity aligns with the risk Khan described. GitHub’s `deployment` event is designed to run a workflow when a deployment is created in a repository. In the attack pattern referenced by Khan, an attacker does not need to make a straightforward commit that permanently modifies a workflow file on the default branch. Instead, the attacker can create temporary Git objects containing a workflow, make the commit reachable, create a deployment that targets that commit, and trigger workflow execution through the deployment event.

The `workflow` scope is intended to gate changes to GitHub Actions workflow files. A deployment-triggered path creates a different abuse primitive: workflow execution can be reached through repository and deployment APIs rather than through an obvious workflow-file update. If the targeted workflow has access to npm publishing credentials, GitHub tokens, cloud OIDC roles, or environment secrets, the attacker can turn a repository compromise into package publication, secret theft, and broader CI/CD compromise.

This provides a plausible explanation for the “Dependabot Updates” camouflage in the ImmobiliareLabs repository. A workflow name that appears to describe normal dependency maintenance can hide a deployment-triggered release path, especially if defenders only review pushes, pull requests, or direct modifications to `.github/workflows`.

GitHub recently introduced workflow execution protections in public preview, allowing organizations and repositories to restrict who can trigger workflows and which events are allowed to run them. Defenders should treat `deployment` as a high-risk workflow trigger unless it is explicitly required, tightly scoped, and protected by environment rules, branch restrictions, and actor/event allow lists.

This campaign shows why CI/CD event surfaces need to be reviewed as execution boundaries, not just automation conveniences. For Miasma, GitHub Actions is not only a place where secrets can be stolen. It is also a propagation engine: a compromised token or maintainer account can trigger release automation, publish malicious package versions, and create the next wave of infections.


## Surge in Exfiltration Repositories

Socket also observed a surge in exfiltration repositories occurring alongside the compromise of packages in the `@immobiliarelabs` scope. Miasma is designed to turn one compromise into many. Package installation can expose npm tokens, GitHub tokens, cloud credentials, and CI/CD secrets. GitHub tokens can then be used to create repositories, upload encrypted data, modify workflows, poison source repositories, or prepare additional propagation paths.

![](https://cdn.sanity.io/images/cgdhsj6q/production/111ae58e29f73a0cf97932c631dbdf7be7a3b5d0-2048x959.png?w=1600&q=95&fit=max&auto=format)
_GitHub repository activity from services-admin-pearhealthlabs shows hundreds of public repositories with randomized names and repeated campaign markers, consistent with automated repository creation used for Miasma dead-drop or exfiltration staging during the ImmobiliareLabs compromise window._

At this stage, the safest interpretation is that the ImmobiliareLabs package compromise is part of an active propagation wave, not an isolated malicious publish event. Teams should assume that any environment that installed the affected versions may have exposed credentials, even if the package’s normal Backstage functionality appears to work.


## Defensive Guidance

Teams that installed any affected ImmobiliareLabs package version should treat the installing environment as compromised until reviewed.

Recommended response:

1. Identify all developer machines, CI runners, build containers, and Backstage environments that installed or built the affected versions.
1. Remove the affected versions and restore from known-good package versions and lockfiles.
1. Rotate npm, GitHub, GitLab, cloud, Kubernetes, Docker, Vault, SSH, Slack, Twilio, and CI/CD secrets exposed to affected environments.
1. Rotate credentials from a clean machine, not from the potentially infected host.
1. Review GitHub Actions runs around June 26, 2026, especially deployment-triggered workflows, unexpected release workflows, and workflows named like routine automation.
1. Audit repositories for injected `.github` workflows, `.github/setup.js`, root-level `index.js`, `_index.js`, `.gemini/settings.json`, `.claude` hooks, `.vscode` tasks, Cursor rules, and unexplained Bun usage.
1. Inspect npm publishing workflows for broad tokens, mutable secrets, and excessive GitHub Actions permissions.
1. Revoke or rotate long-lived maintainer tokens, including tokens used by release automation such as GitHub personal access tokens and npm publishing credentials.
1. Pin GitHub Actions to immutable full-length commit SHAs where possible.
1. Restrict publishing workflows to protected branches and minimize OIDC, contents, actions, and package permissions.

## Indicators of compromise (IOCs)

The ImmobiliareLabs compromise is a new wave of the same broader Miasma Mini Shai-Hulud campaign we [reported](https://socket.dev/blog/miasma-mini-shai-hulud-hits-leoplatform-npm-packages-go-ecosystem) on yesterday. Some indicators are specific to this wave, including the affected `@immobiliarelabs` package versions and the GitHub Actions activity tied to the ImmobiliareLabs repositories. Other indicators overlap with the previous LeoPlatform, RStreams, Verana, and GitHub Actions activity, because the campaign continues to reuse the same execution patterns, staging logic, repository-poisoning techniques, AI/IDE persistence paths, and credential-theft objectives.

Defenders should therefore treat the indicators below as additive to the campaign-level IOCs published in our previous report, not as a standalone set. In particular, teams should continue hunting for Miasma’s shared markers: unexpected `binding.gyp` files in packages that should not require native builds, large obfuscated `index.js` or `_index.js` payloads, Bun download or execution activity, injected `.github` workflows, AI coding assistant configuration hooks, suspicious Dependabot- or Copilot-themed workflow names, and campaign strings such as `RevokeAndItGoesKaboom` and `Alright Lets See If This Works`.

The wave-specific indicators below focus on the ImmobiliareLabs package compromise and related GitHub Actions activity observed on June 26, 2026.


### Mini Shai-Hulud, Miasma, and Hades affected packages

- We are tracking the full campaign on a dedicated page, with all affected artifacts added as they are identified: [https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack](https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack)

### File hashes (SHA-256)

1. `@immobiliarelabs/backstage-plugin-gitlab@1.0.1`
   - tarball: dfcdec5f43cc8d127084a2ac4d66499f13bae7f49167e3291a6f1a70738772d1
   - index.js: 1e7b04a9a4a25eb7928821a5519b0a40f7afe0f6042a6860c918b62d369096ed
1. `@immobiliarelabs/backstage-plugin-gitlab@2.1.2`
   - tarball: 7a879ed69a8191df5c68535f6ac41b830577b698de943c66ff40e51482d90d79
   - index.js: 14253cd5b8acccbbacb5cd3bb0a099fb6b0aafe4d06d032e4070b3fb814677dd
1. `@immobiliarelabs/backstage-plugin-gitlab@3.0.3`
   - tarball: 2f6cbe3a79148bc247131c36cd12689c97166a9d141dd9d9466270b4c04c3e3e
   - index.js: 8a71e7d9b6b1b6d3e7bee490e98b34595ceea207160fc7ed35e47f82160febbe
1. `@immobiliarelabs/backstage-plugin-gitlab@4.0.2`
   - tarball: 9df6bda43678708605dfaad35f02be8027e85e6aa38193704cf192f842f0d186
   - index.js: 2ffed3b58bc267c438c759cd03b3e890904f25bacd015608f888c302741cad29
1. `@immobiliarelabs/backstage-plugin-gitlab@5.2.1`
   - tarball: 720571b83600cd61080a7779e7f44327e4df4974d4a01475439d2e59e11ab29f
   - index.js: 60099babe48a48831262b40d4c5c1dd623726060da10c1e2f74f191c9c4cd81d
1. `@immobiliarelabs/backstage-plugin-gitlab@6.13.1`
   - tarball: 54086c0f23710ff45cb6bde498083d0a0098112aab9b0ef48e6e869a280f1b42
   - index.js: 3b24b47a66b17d39fbdb7deccc329342b18cec6feb967adbaf80e81a70ecc609
1. `@immobiliarelabs/backstage-plugin-gitlab@7.0.2`
   - tarball: a09909e8981e17712ef38b363f94553e2f86b6c2abd6c87eada94d3d3aab937e
   - index.js: 8746d49834ad938eebeaffd380b6302c94ab0b3258268c1a8c7e57ee7d5c11e1
1. `@immobiliarelabs/backstage-plugin-gitlab-backend@3.0.3`
   - tarball: 333f2e3753063447819a3c86cfc475fe4bd3f0a76c05262a61c3d18b50438bb5
   - index.js: 99eb789284fa62e3f956e81294247ae82f596ebf481c069ae45019ac4e879927
1. `@immobiliarelabs/backstage-plugin-gitlab-backend@4.0.2`
   - tarball: 869ffe5400477ce69bbfd5f51ddd0c40eacad9a83005956fb14787a5e1e98330
   - index.js: 7cd21d65d5a085d82d07275df9a66c6dfac4e13e43ea9ef44e84a3dd14ea1b3f
1. `@immobiliarelabs/backstage-plugin-gitlab-backend@5.2.1`
   - tarball: 24c578c2573bf7a04f69c4762a36a87fd32746e9db4df16b2ad92f31fbdd0d50
   - index.js: ca89ece660251554b66f1e5e9874410d206e0f080da3039e1221f1c71d817395
1. `@immobiliarelabs/backstage-plugin-gitlab-backend@6.13.1`
   - tarball: 89c218ca407c2d92359b53a9e3b7b973a761dcf323d2fa1cc2dc12c13f27afaf
   - index.js: ef89e81be6b9d81b9d4bc41dae5f10a7a68f33b17fd76affcf7dca2f5d50a843
1. `@immobiliarelabs/backstage-plugin-gitlab-backend@7.0.2`
   - tarball: cc00c23768bee76e2f297c1766a013a681efb519888545352cff96fc5cead035
   - index.js: 9d8ea3cefb942081a1409e842ddc541ccd65fb3e66a4f8dfe562ca8548dd09d9
1. `@immobiliarelabs/backstage-plugin-ldap-auth@1.1.4`
   - tarball: d1db13a14db489531e11ccf700d7fd8701f61ad297ce02477e11acf194d3fed0
   - index.js: 8df5d46d91589e6a3ec8d87d6eea6c71fac103f9e10dff9b88c309c1e9129b07
1. `@immobiliarelabs/backstage-plugin-ldap-auth@2.0.5`
   - tarball: 3667e7080c083563f6d05118d8b08f535b391fe2a5c0f98d5bd31f96257620f7
   - index.js: 63667208bcd2d307b307e6df43bf8960ccb7058333d00ba064ed53f180ec32ea
1. `@immobiliarelabs/backstage-plugin-ldap-auth@3.0.2`
   - tarball: 3809fd3a3a912abccaa7aa201880a2cfd194ae7f9dbdc747872cd045bcb3def5
   - index.js: 0ccd7c44a6352f295f65ffea21c2472566f9e73c4dd1028fe0b9971314b18de6
1. `@immobiliarelabs/backstage-plugin-ldap-auth@4.3.2`
   - tarball: b38a73c365e5761fe0e7f25a391db3a264b1f2b4878a1c8cc127ba83d64e614c
   - index.js: 0574f0bee78294a5f3495144ea6e05848c5fe8dcda11414e35c65aea46ce953b
1. `@immobiliarelabs/backstage-plugin-ldap-auth@5.2.1`
   - tarball: 441d834d8a97b3d76bd7a9ac73174a18c1add1bf80b21319c0cb2d5737782e83
   - index.js: cf46348e7a4beacc0b9600c9ece3bee140f344641e90d99c741bc54507423443
1. `@immobiliarelabs/backstage-plugin-ldap-auth-backend@1.1.3`
   - tarball: 8284d9bd16c9141d331d3b724f9d57ae2cae265bf326055e18d5cde4bb5985b7
   - index.js: d2aa3f9057c6f3295766aabed0a71a369353d6eb665049a45fd407fd55020fdb
1. `@immobiliarelabs/backstage-plugin-ldap-auth-backend@2.0.5`
   - tarball: 7bc28ba4d33d010785a5289211ad6a0d968ec0abd56201d90d74921ad83d925d
   - index.js: 8e83e3ece1a2a764a7c6fd78dd39cfb32cb38d22b7b3d92709cb5b87fa916403
1. `@immobiliarelabs/backstage-plugin-ldap-auth-backend@3.0.2`
   - tarball: ef01e18ccf618a8992ad0aa4eb7d804bbacf9f092d43d39237f283a9a289c9b9
   - index.js: b82f5f6f1d969ba8f32937a3d81306c631defa943b7cc7529e45a0003340ece5
1. `@immobiliarelabs/backstage-plugin-ldap-auth-backend@4.3.2`
   - tarball: b4f90f5515df39cf346bf436e284f2dae28c9341c035765d83d82a76c86922b7
   - index.js: 1623787aa0de7310a4585101212b41ae02d02801ebda5812395932392400c756
1. `@immobiliarelabs/backstage-plugin-ldap-auth-backend@5.2.1`
   - tarball: a16810f972f577f129f95f147e64aa4c70977035285d357a53958496c0531223
   - index.js: cf5d79494d8b1fdcb5480507eee8beeb2fcd69bcd9afcdc7dc1bcdda7461913e
1. `binding.gyp (byte-identical across all 22 packages):`
   - ef641e956f91d501b748085996303c96a64d67f63bfeef0dda175e5aa19cca90