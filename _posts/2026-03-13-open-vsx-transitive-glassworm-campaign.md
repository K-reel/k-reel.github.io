---
title: "72 Malicious Open VSX Extensions Linked to GlassWorm Campaign Now Using Transitive Dependencies"
short_title: "72 Malicious Open VSX Extensions Linked to GlassWorm"
date: 2026-03-13 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [GlassWorm, Open VSX, VS Code, Extensions, Obfuscation, Typosquatting, Russian Link, T1195.001, T1204, T1480, T1059.007, T1027.013, T1102.001]
author: socket_research_team
canonical_url: https://socket.dev/blog/open-vsx-transitive-glassworm-campaign
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/fca6ee0282eb63d1b533c29331ff4456f1d9672a-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: GlassWorm transitive dependency campaign artwork
description: "Since January 31, 2026, we identified at least 72 additional malicious Open VSX extensions, including transitive GlassWorm loader extensions targeting developers through extensionPack and extensionDependencies manifest abuse."
---

GlassWorm has not re-emerged so much as evolved, and our latest analysis shows a significant escalation in how it spreads through Open VSX. Instead of requiring every malicious listing to embed the loader directly, the threat actor is now abusing `extensionPack` and `extensionDependencies` to turn initially standalone-looking extensions into transitive delivery vehicles in later updates, allowing a benign-appearing package to begin pulling a separate GlassWorm-linked extension only after trust has already been established. We confirmed this pattern in [`otoboss.autoimport-extension`](https://socket.dev/openvsx/package/otoboss.autoimport-extension), which references [`federicanc.dotenv-syntax-highlighting`](https://socket.dev/openvsx/package/federicanc.dotenv-syntax-highlighting) and [`oigotm.my-command-palette-extension`](https://socket.dev/openvsx/package/oigotm.my-command-palette-extension), and identified additional live recursive cases such as [`twilkbilk.color-highlight-css`](https://socket.dev/openvsx/package/twilkbilk.color-highlight-css), and [`crotoapp.vscode-xml-extension`](https://socket.dev/openvsx/package/crotoapp.vscode-xml-extension). This materially expands the campaign's reach, lowers the visibility of the true malicious component, and makes one-time review of an extension's original release insufficient for risk assessment.

Technically, the campaign retains the same core GlassWorm tradecraft while improving survivability and evasion. The newer variants still use staged JavaScript execution, Russian locale/timezone geofencing, Solana transaction memos as dead drops, and in-memory follow-on code execution, but they now rotate infrastructure and loader logic more aggressively: the campaign has shifted from Solana wallet `BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC` to `6YGcuyFRJKZtcaYCCFba9fScNUvPkGXodXE1mJiSzqDJ`, continues to reuse `45[.]32[.]150[.]251` while adding `45[.]32[.]151[.]157` and `70[.]34[.]242[.]255`, uses the Solana memo program `MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr`, replaces the earlier static AES-wrapped loader with heavier RC4/base64/string-array obfuscation, and moves decryption material out of the extension and into response headers such as `ivbase64` and `secretkey`. Defenders should watch for late-version manifest changes that newly introduce `extensionPack` or `extensionDependencies`, staged `extension.js` code with Russian gating, Solana memo lookups, embedded crypto indicators such as AES key `wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz` and AES IV `c4b9a3773e9dced6015a670855fd32b`, and any extension that appears benign at first publication but becomes transitive in a later update. The primary attack surface is the Open VSX / VS Code extension install-and-update path, and the highest-risk assets are developer workstations and any local credentials, tokens, configuration data, or environment secrets reachable once the follow-on payload executes in memory.

The immediate priority is to audit extension histories, not just current code, for newly added `extensionPack` and `extensionDependencies` relationships, and to block or remove any GlassWorm-linked packages and infrastructure indicators from developer environments without waiting for additional registry takedowns.

## GlassWorm's Abuse of Extension Relationships

VS Code and compatible editors like Open VSX support these two manifest fields that allow one extension to pull in others automatically: `extensionPack` and `extensionDependencies`. Both are declared in the extension's `package.json` and reference other extensions by their `publisher.name` identifier. When a user installs an extension that declares itself as an extension pack, the editor automatically installs every extension listed in the array alongside it.

The intended use case is convenience: As the VS Code documentation describes it, extension packs let developers bundle their favorite extensions together or create curated sets for a particular scenario; for example, a "PHP Development" that bundles together a debugger and a language service so that a new PHP developer can get started quickly.

```json
{
  "extensionPack": ["xdebug.php-debug", "zobo.php-intellisense"]
}
```

> *Example of a legitimate PHP development pack [highlighted](https://code.visualstudio.com/api/references/extension-manifest#extension-packs) in the official VSCode documentation on Extension Packs.*

`extensionDependencies` works similarly but is meant for extensions that are required for the parent extension to work. In both cases, the editor installs them automatically alongside the main extension. Critically, neither mechanism requires the referenced extension to share a publisher, namespace, or any trust relationship with the parent. Any extension author can declare any other extension as a pack member or dependency.

GlassWorm is not limited to extensions that carry malicious code directly. It started to abuse these two VS Code-style manifest relationships (`extensionPack` and `extensionDependencies`) to turn one extension into an indirect installer for another. That gives the threat actor a useful transitive delivery path: an extension that appears benign on initial review can later be updated to add one of these fields and silently begin pulling a separate GlassWorm-linked package. For defenders, that means extension code alone is not enough. Manifest relationships, especially newly added `extensionPack` or `extensionDependencies` entries in later versions, must be treated as part of the attack surface because the malicious component may sit one layer beyond the extension the user knowingly installed.

## Transitive GlassWorm Activity in Open VSX

We identified a new GlassWorm delivery technique in Open VSX that abuses extension manifest relationships to distribute malware transitively. Rather than embedding the GlassWorm loader in every malicious listing, the threat actor can publish an extension that appears benign and later cause the editor to install a separate GlassWorm-linked extension through `extensionPack` or `extensionDependencies`. This shifts the campaign model in an important way: some extensions now function as indirect delivery vehicles instead of direct malware carriers.

Among confirmed examples are [`otoboss.autoimport-extension@1.5.7`](https://socket.dev/openvsx/package/otoboss.autoimport-extension/overview/1.5.7), which contains an [`extensionPack`](https://socket.dev/openvsx/package/otoboss.autoimport-extension/files/1.5.7/extension/package.json?platform=universal#L78) reference to [`oigotm.my-command-palette-extension`](https://socket.dev/openvsx/package/oigotm.my-command-palette-extension); [`otoboss.autoimport-extension@1.5.6`](https://socket.dev/openvsx/package/otoboss.autoimport-extension/overview/1.5.6), which contains an [`extensionPack`](https://socket.dev/openvsx/package/otoboss.autoimport-extension/files/1.5.6/extension/package.json#L78) reference to [`federicanc.dotenv-syntax-highlighting`](https://socket.dev/openvsx/package/federicanc.dotenv-syntax-highlighting), an extension we identified and confirmed as GlassWorm-linked. In practice, this means a user can install an extension that appears non-malicious on its own, while still receiving GlassWorm through its declared extension relationship. This lowers the visibility of the malicious component, broadens the threat actor's reach, and complicates both manual review and registry-side triage.

This behavior is not limited to a single package. Several of the extensions targeting end users displayed download counts inflated into the thousands, lending them a veneer of popularity with the goal of luring unsuspecting developers into installing them.

![Screenshot of the malicious twilkbilk.color-highlight-css Open VSX extension](https://cdn.sanity.io/images/cgdhsj6q/production/5d688ef11013e22e800748242c59d68b6645a66b-2048x1141.png)
_Screenshot of the malicious [`twilkbilk.color-highlight-css`](https://socket.dev/openvsx/package/twilkbilk.color-highlight-css) Open VSX extension, a GlassWorm-linked impersonator that mimics the legitimate [`color-highlight`](https://socket.dev/openvsx/package/naumovs.color-highlight) extension while using a namespace/publisher mismatch to appear trustworthy. The listing was still live at the time of writing and showed 3.5K reported downloads, which are likely inflated or otherwise manipulated by the threat actor to make the extension appear more established and credible._

As of March 13, Open VSX has removed the majority of the transitively malicious extensions, which is a positive operational sign. However, at the time of writing, we also identified live examples including `twilkbilk/color-highlight-css` and `crotoapp/vscode-xml-extension`, indicating that takedowns were ongoing but incomplete.

The extensions overwhelmingly impersonate widely installed developer utilities: linters and formatters like ESLint and Prettier, code runners, popular language tooling for Angular, Flutter, Python, and Vue, and common quality-of-life extensions like vscode-icons, WakaTime, and Better Comments. Notably, the campaign also targets AI developer tooling, with extensions targeting Claude Code, Codex, and Antigravity. In at least one case ([`daeumer-web.es-linter-for-vs-code`](https://socket.dev/openvsx/package/daeumer-web.es-linter-for-vs-code)), the publisher name is a direct typosquat of the legitimate ESLint publisher `dbaeumer`.

A key operational detail is that these packages do not begin as obviously transitive GlassWorm carriers. The threat actor first publishes an extension that appears standalone and does not initially declare a malicious dependency. In a later update, the threat actor adds an `extensionPack` or `extensionDependencies` reference to a separate GlassWorm loader. As a result, an extension that looked non-transitive and comparatively benign at initial publication can later become a transitive GlassWorm delivery vehicle without any change to its apparent purpose. For defenders, this materially raises the risk: reviewing the original release once is no longer sufficient, because the malicious dependency relationship may emerge only in a later update, at which point previously trusted installs can begin pulling GlassWorm indirectly through the normal extension update path.

## GlassWorm Loader Evolution

Recent analysis shows that GlassWorm has continued to evolve since our January 31, 2026 [report](/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise/). Newer variants, including `aadarkcode.one-dark-material@3.20.1`, preserve the campaign's core tradecraft while updating the components most vulnerable to exposure. The loader still uses staged JavaScript execution, Russian geofencing, Solana transaction memos as dead drops, and in-memory follow-on code execution, all of which remain strong continuity markers with the January 31, 2026 cluster. At the same time, the threat actor has rotated Solana infrastructure from `BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC` to `6YGcuyFRJKZtcaYCCFba9fScNUvPkGXodXE1mJiSzqDJ`, introduced additional C2 IPs such as `70[.]34[.]242[.]255` and `45[.]32[.]151[.]157`, expanded RPC redundancy, replaced the earlier static AES-wrapped loader with heavier RC4/base64/string-array obfuscation, and shifted decryption material from the extension itself to operator-controlled HTTP response headers. Despite these adaptations, overlapping infrastructure, including reuse of `45[.]32[.]150[.]251`, and the continued use of the same underlying execution model strongly support attribution to GlassWorm.

![Socket AI Scanner analysis of the malicious aadarkcode.one-dark-material Open VSX extension](https://cdn.sanity.io/images/cgdhsj6q/production/32b75c340b671f3e2f1227339ec95962b7d04392-567x611.png)
_Socket AI Scanner's analysis of the malicious [`aadarkcode.one-dark-material`](https://socket.dev/openvsx/package/aadarkcode.one-dark-material/overview/3.20.1?platform=universal) Open VSX extension flags a staged GlassWorm-style loader in [`extension/out/extension.js`](https://socket.dev/openvsx/package/aadarkcode.one-dark-material/files/3.20.1/extension/out/extension.js?platform=universal), highlighting heavy obfuscation, runtime retrieval and decoding of follow-on code, execution via **`eval`** and **`vm.Script`** with full Node.js primitives exposed, and locale/time-based gating consistent with selective execution and anti-analysis behavior._

## Outlook and Recommendations

GlassWorm is moving toward less visible, more resilient delivery: later-version manifest changes, transitive installation paths, heavier obfuscation, rotating Solana wallets and infrastructure, and threat actor-controlled decryption material. Defenders should expect more extensions that look benign at publication, then become malicious through updates that add `extensionPack` or `extensionDependencies`. That model is likely to spread because it hides the real malicious component behind normal extension-management behavior.

The priority now is to treat extension history, manifest diffs, and transitive relationships as first-class detection surfaces. Audit version-to-version changes for newly introduced `extensionPack` and `extensionDependencies`, review extension install/update chains rather than only current code, and hunt for GlassWorm indicators such as staged loaders, Russian locale/time gating, Solana memo lookups, and reused infrastructure. On endpoints, review developer workstations for exposed tokens, credentials, config files, and environment secrets reachable after in-memory follow-on execution.

Socket flags these exact relationships with a dedicated [**VS Code: Extension pack**](https://socket.dev/alerts/vsxExtensionPack) and [**VS Code: Extension dependency**](https://socket.dev/alerts/vsxExtensionDependency) alert, which surface on package pages whenever an extension declares transitive install relationships. This gives users and security teams visibility into whether an extension ships other extensions before they install it.

The [**Socket GitHub App**](https://socket.dev/features/github) helps catch suspicious dependency additions and risky manifest changes before merge. The [**Socket CLI**](https://socket.dev/features/cli) adds install-time visibility and policy enforcement for behaviors associated with GlassWorm-style loaders, including obfuscation, decrypt-and-execute logic, and unexpected network access. [**Socket Firewall**](https://socket.dev/blog/introducing-socket-firewall) blocks known malicious packages before fetch, including transitive dependencies, which matters when a package becomes malicious only after a later update. The [**Socket browser extension**](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) helps users spot suspicious packages while browsing, and [**Socket MCP**](https://socket.dev/blog/socket-mcp) reduces the chance that malicious or hallucinated packages enter projects through AI-assisted coding workflows.

## Indicators of Compromise (IOCs)

### Malicious Open VSX Extensions (Since Our January 31, 2026 [Report](https://socket.dev/blog/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise))

1. [`aadarkcode.one-dark-material`](https://socket.dev/openvsx/package/aadarkcode.one-dark-material)
1. [`aligntool.extension-align-professional-tool`](https://socket.dev/openvsx/package/aligntool.extension-align-professional-tool)
1. [`angular-studio.ng-angular-extension`](https://socket.dev/openvsx/package/angular-studio.ng-angular-extension)
1. [`awesome-codebase.codebase-dart-pro`](https://socket.dev/openvsx/package/awesome-codebase.codebase-dart-pro)
1. [`awesomeco.wonder-for-vscode-icons`](https://socket.dev/openvsx/package/awesomeco.wonder-for-vscode-icons)
1. [`bhbpbarn.vsce-python-indent-extension`](https://socket.dev/openvsx/package/bhbpbarn.vsce-python-indent-extension)
1. [`blockstoks.easily-gitignore-manage`](https://socket.dev/openvsx/package/blockstoks.easily-gitignore-manage)
1. [`brategmaqendaalar-studio.pro-prettyxml-formatter`](https://socket.dev/openvsx/package/brategmaqendaalar-studio.pro-prettyxml-formatter)
1. [`codbroks.compile-runnner-extension`](https://socket.dev/openvsx/package/codbroks.compile-runnner-extension)
1. [`codevunmis.csv-sql-tsv-rainbow`](https://socket.dev/openvsx/package/codevunmis.csv-sql-tsv-rainbow)
1. [`codwayexten.code-way-extension`](https://socket.dev/openvsx/package/codwayexten.code-way-extension)
1. [`cosmic-themes.sql-formatter`](https://socket.dev/openvsx/package/cosmic-themes.sql-formatter)
1. [`craz2team.vscode-todo-extension`](https://socket.dev/openvsx/package/craz2team.vscode-todo-extension)
1. [`crotoapp.vscode-xml-extension`](https://socket.dev/openvsx/package/crotoapp.vscode-xml-extension)
1. [`cudra-production.vsce-prettier-pro`](https://socket.dev/openvsx/package/cudra-production.vsce-prettier-pro)
1. [`daeumer-web.es-linter-for-vs-code`](https://socket.dev/openvsx/package/daeumer-web.es-linter-for-vs-code)
1. [`dark-code-studio.flutter-extension`](https://socket.dev/openvsx/package/dark-code-studio.flutter-extension)
1. [`densy-little-studio.wonder-for-vscode-icons`](https://socket.dev/openvsx/package/densy-little-studio.wonder-for-vscode-icons)
1. [`dep-labs-studio.dep-proffesinal-extension`](https://socket.dev/openvsx/package/dep-labs-studio.dep-proffesinal-extension)
1. [`dev-studio-sense.php-comp-tools-vscode`](https://socket.dev/openvsx/package/dev-studio-sense.php-comp-tools-vscode)
1. [`devmidu-studio.svg-better-extension`](https://socket.dev/openvsx/package/devmidu-studio.svg-better-extension)
1. [`dopbop-studio.vscode-tailwindcss-extension-toolkit`](https://socket.dev/openvsx/package/dopbop-studio.vscode-tailwindcss-extension-toolkit)
1. [`errlenscre.error-lens-finder-ex`](https://socket.dev/openvsx/package/errlenscre.error-lens-finder-ex)
1. [`exss-studio.yaml-professional-extension`](https://socket.dev/openvsx/package/exss-studio.yaml-professional-extension)
1. [`federicanc.dotenv-syntax-highlighting`](https://socket.dev/openvsx/package/federicanc.dotenv-syntax-highlighting)
1. [`flutxvs.vscode-kuberntes-extension`](https://socket.dev/openvsx/package/flutxvs.vscode-kuberntes-extension)
1. [`gvotcha.claude-code-extension`](https://socket.dev/openvsx/package/gvotcha.claude-code-extension)
1. [`gvotcha.claude-code-extensions`](https://socket.dev/openvsx/package/gvotcha.claude-code-extensions)
1. [`intellipro.extension-json-intelligence`](https://socket.dev/openvsx/package/intellipro.extension-json-intelligence)
1. [`kharizma.vscode-extension-wakatime`](https://socket.dev/openvsx/package/kharizma.vscode-extension-wakatime)
1. [`ko-zu-gun-studio.synchronization-settings-vscode`](https://socket.dev/openvsx/package/ko-zu-gun-studio.synchronization-settings-vscode)
1. [`kwitch-studio.auto-run-command-extension`](https://socket.dev/openvsx/package/kwitch-studio.auto-run-command-extension)
1. [`lavender-studio.theme-lavender-dreams`](https://socket.dev/openvsx/package/lavender-studio.theme-lavender-dreams)
1. [`littensy-studio.magical-icons`](https://socket.dev/openvsx/package/littensy-studio.magical-icons)
1. [`lyu-wen-studio-web-han.better-formatter-vscode`](https://socket.dev/openvsx/package/lyu-wen-studio-web-han.better-formatter-vscode)
1. [`markvalid.vscode-mdvalidator-extension`](https://socket.dev/openvsx/package/markvalid.vscode-mdvalidator-extension)
1. [`mecreation-studio.pyrefly-pro-extension`](https://socket.dev/openvsx/package/mecreation-studio.pyrefly-pro-extension)
1. [`mswincx.antigravity-cockpit`](https://socket.dev/openvsx/package/mswincx.antigravity-cockpit)
1. [`mswincx.antigravity-cockpit-extension`](https://socket.dev/openvsx/package/mswincx.antigravity-cockpit-extension)
1. [`namopins.prettier-pro-vscode-extension`](https://socket.dev/openvsx/package/namopins.prettier-pro-vscode-extension)
1. [`oigotm.my-command-palette-extension`](https://socket.dev/openvsx/package/oigotm.my-command-palette-extension)
1. [`otoboss.autoimport-extension`](https://socket.dev/openvsx/package/otoboss.autoimport-extension)
1. [`ovixcode.vscode-better-comments`](https://socket.dev/openvsx/package/ovixcode.vscode-better-comments)
1. [`pessa07tm.my-js-ts-auto-commands`](https://socket.dev/openvsx/package/pessa07tm.my-js-ts-auto-commands)
1. [`potstok.dotnet-runtime-extension`](https://socket.dev/openvsx/package/potstok.dotnet-runtime-extension)
1. [`pretty-studio-advisor.prettyxml-formatter`](https://socket.dev/openvsx/package/pretty-studio-advisor.prettyxml-formatter)
1. [`prismapp.prisma-vs-code-extension`](https://socket.dev/openvsx/package/prismapp.prisma-vs-code-extension)
1. [`projmanager.your-project-manager-extension`](https://socket.dev/openvsx/package/projmanager.your-project-manager-extension)
1. [`pubruncode.ccoderunner`](https://socket.dev/openvsx/package/pubruncode.ccoderunner)
1. [`pyflowpyr.py-flowpyright-extension`](https://socket.dev/openvsx/package/pyflowpyr.py-flowpyright-extension)
1. [`pyscopexte.pyscope-extension`](https://socket.dev/openvsx/package/pyscopexte.pyscope-extension)
1. [`redcapcollective.vscode-quarkus-elite-suite`](https://socket.dev/openvsx/package/redcapcollective.vscode-quarkus-elite-suite)
1. [`rubyideext.ruby-ide-extension`](https://socket.dev/openvsx/package/rubyideext.ruby-ide-extension)
1. [`runnerpost.runner-your-code`](https://socket.dev/openvsx/package/runnerpost.runner-your-code)
1. [`shinypy.shiny-extension-for-vscode`](https://socket.dev/openvsx/package/shinypy.shiny-extension-for-vscode)
1. [`sol-studio.solidity-extension`](https://socket.dev/openvsx/package/sol-studio.solidity-extension)
1. [`ssgwysc.volar-vscode`](https://socket.dev/openvsx/package/ssgwysc.volar-vscode)
1. [`studio-jjalaire-team.professional-quarto-extension`](https://socket.dev/openvsx/package/studio-jjalaire-team.professional-quarto-extension)
1. [`studio-velte-distributor.pro-svelte-extension`](https://socket.dev/openvsx/package/studio-velte-distributor.pro-svelte-extension)
1. [`sun-shine-studio.shiny-extension-for-vscode`](https://socket.dev/openvsx/package/sun-shine-studio.shiny-extension-for-vscode)
1. [`sxatvo.jinja-extension`](https://socket.dev/openvsx/package/sxatvo.jinja-extension)
1. [`tamokill12.foundry-pdf-extension`](https://socket.dev/openvsx/package/tamokill12.foundry-pdf-extension)
1. [`thing-mn.your-flow-extension-for-icons`](https://socket.dev/openvsx/package/thing-mn.your-flow-extension-for-icons)
1. [`tima-web-wang.shell-check-utils`](https://socket.dev/openvsx/package/tima-web-wang.shell-check-utils)
1. [`tokcodes.import-cost-extension`](https://socket.dev/openvsx/package/tokcodes.import-cost-extension)
1. [`toowespace.worksets-extension`](https://socket.dev/openvsx/package/toowespace.worksets-extension)
1. [`treedotree.tree-do-todoextension`](https://socket.dev/openvsx/package/treedotree.tree-do-todoextension)
1. [`tucyzirille-studio.angular-pro-tools-extension`](https://socket.dev/openvsx/package/tucyzirille-studio.angular-pro-tools-extension)
1. [`turbobase.sql-turbo-tool`](https://socket.dev/openvsx/package/turbobase.sql-turbo-tool)
1. [`twilkbilk.color-highlight-css`](https://socket.dev/openvsx/package/twilkbilk.color-highlight-css)
1. [`vce-brendan-studio-eich.js-debuger-vscode`](https://socket.dev/openvsx/package/vce-brendan-studio-eich.js-debuger-vscode)
1. [`yamaprolas.revature-labs-extension`](https://socket.dev/openvsx/package/yamaprolas.revature-labs-extension)

### Solana addresses

- `BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC`
- `6YGcuyFRJKZtcaYCCFba9fScNUvPkGXodXE1mJiSzqDJ`

### Embedded Crypto Material

- AES key: `wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz`
- AES IVs (hex): `c4b9a3773e9dced6015a670855fd32b`

### IP Addresses

- `45[.]32[.]150[.]251`
- `45[.]32[.]151[.]157`
- `70[.]34[.]242[.]255`

## MITRE ATT&CK

- T1195.001 — Supply Chain Compromise: Compromise Software Dependencies and Development Tools
- T1204 — User Execution
- T1480 — Execution Guardrails
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1102.001 — Web Service: Dead Drop Resolver
