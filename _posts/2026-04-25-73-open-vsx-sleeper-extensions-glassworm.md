---
title: "73 Open VSX Sleeper Extensions Linked to GlassWorm Show New Malware Activations"
short_title: "73 Open VSX Sleeper Extensions Linked to GlassWorm"
date: 2026-04-25 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [GlassWorm, Open VSX, Extensions, VS Code, Sleeper Extensions, Impersonation, Obfuscation, VSIX, Loader, Transitive Delivery]
author: socket_research_team
canonical_url: https://socket.dev/blog/73-open-vsx-sleeper-extensions-glassworm
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/892a8fb356a67d4293885b15928c1e5b8376c2ee-1254x1254.png?w=1000&q=95&fit=max&auto=format
  alt: GlassWorm Open VSX sleeper extensions campaign artwork
description: "Socket is tracking cloned Open VSX extensions tied to GlassWorm, with several updated from benign-looking sleepers into malware delivery vehicles."
---

The GlassWorm campaign targeting Open VSX continues to escalate. Socket is now tracking a new cluster of 73 impersonation extensions connected to the same sleeper-extension activity [reported](https://socket.dev/blog/open-vsx-transitive-glassworm-campaign) in March 2026. Beginning in April 2026, and continuing as of this writing, additional cloned versions of popular code extensions have appeared on the Open VSX marketplace. These extensions did not initially contain malware, but they were published by newly created GitHub accounts with only one or two public repositories. In each case, one repository is empty and named with an eight-character string.

> _A sleeper extension or package is a threat actor-controlled imposter that is published before it is weaponized. It may appear benign at first, often to build trust, downloads, or credibility, but can later be updated to deliver malware through the normal update path._

At least six of these extensions have already been activated to deliver malware, while the remaining extensions appear to be high-confidence sleepers or related suspicious extensions. This count may change as new updates continue to appear, but the pattern is consistent with earlier GlassWorm waves: cloned or impersonating extensions are first published without an obvious payload, then later updated to deliver malware through the normal extension update path.

This activity follows Socket's previous reporting on GlassWorm's shift toward sleeper and transitive delivery techniques, including extensions that appeared benign at publication before later adding malicious dependencies or loaders. In March 2026, Socket documented [72 malicious Open VSX extensions tied to GlassWorm's abuse of extension relationships](https://socket.dev/blog/open-vsx-transitive-glassworm-campaign). That wave was followed by [another set of sleeper extensions](https://socket.dev/blog/glassworm-sleeper-extensions-activated-on-open-vsx) that activated and began pulling GitHub-hosted VSIX malware. For this latest cluster, Socket has marked the tracked extensions to protect users while analysis continues.

> We are tracking the affected extensions associated with this supply chain attack campaign on our dedicated GlassWorm v2 page: [https://socket.dev/supply-chain-attacks/glassworm-v2](https://socket.dev/supply-chain-attacks/glassworm-v2)

## Update: April 29, 2026: Activation Wave via Transitive Delivery

Since publication of this blog post, we have observed an additional activation wave leveraging the `extensionPack` transitive-delivery pattern we saw being weaponized back in March.

**Summary**

- Twenty-three new versions across 22 copycat extensions on Open VSX, all with clean prior versions, were pushed on April 29 across two clusters.
- An early pair was published at 18:15–18:16 UTC.
- A main burst of 21 version drops landed between 19:29 and 19:34 UTC.

Seventeen of the new versions declare an `extensionPack` entry pointing at `blockstoks.easily-gitignore-manage`.

The remaining five did not pull a payload and remain in a sleeper state at time of writing, but cluster with the others on publishing time, account characteristics, and naming.

`blockstoks.easily-gitignore-manage` itself, however, was already gone. Socket [disclosed `blockstoks.easily-gitignore-manage` as a GlassWorm-linked malicious extension on March 13, 2026](https://socket.dev/blog/open-vsx-transitive-glassworm-campaign). It was removed from Open VSX on April 27, 2026, approximately 52 hours before this activation wave landed, suggesting that the activated host extensions' `extensionPack` references were dead on arrival.

We thank the Eclipse Foundation for taking swift action and removing the extension before the campaign reached its activation phase.

The fact that the threat actor pushed activations referencing an extension two days after its removal is itself an operational signal: it suggests the activation pipeline is automated and does not validate puller liveness against the marketplace before publishing host updates.

### Activated Host Extensions (April 29, 2026)

1. [drobnyak.angular-auto-helper](https://socket.dev/openvsx/package/drobnyak.angular-auto-helper/overview/18.92.1)
1. [galushko.vsclassic-auto-pilot](https://socket.dev/openvsx/package/galushko.vsclassic-auto-pilot/overview/1.2.7)
1. [gusarev.mermaid-super-studio](https://socket.dev/openvsx/package/gusarev.mermaid-super-studio/overview/2.6.6)
1. [lavrentev.project-live-studio](https://socket.dev/openvsx/package/lavrentev.project-live-studio/overview/13.1.3)
1. [lesnitsky.tikbook-easy-lens](https://socket.dev/openvsx/package/lesnitsky.tikbook-easy-lens/overview/0.5.3)
1. [mashulin.vue-easy-studio](https://socket.dev/openvsx/package/mashulin.vue-easy-studio/overview/0.0.7)
1. [mitrokhin.vsc-easy-studio](https://socket.dev/openvsx/package/mitrokhin.vsc-easy-studio/overview/1.21.2)
1. [mlechevik.nunjucks-rich-pilot](https://socket.dev/openvsx/package/mlechevik.nunjucks-rich-pilot/overview/0.5.4)
1. [mokridin.material-pro-suite](https://socket.dev/openvsx/package/mokridin.material-pro-suite/overview/3.19.2)
1. [ovchinin.markdown-live-craft](https://socket.dev/openvsx/package/ovchinin.markdown-live-craft/overview/3.6.4)
1. [peschanov.dbcode-smart-suite](https://socket.dev/openvsx/package/peschanov.dbcode-smart-suite/overview/1.30.6)
1. [platarov.podmanager-pro-craft](https://socket.dev/openvsx/package/platarov.podmanager-pro-craft/overview/3.0.8)
1. [polikash.pretty-deep-kit](https://socket.dev/openvsx/package/polikash.pretty-deep-kit/overview/0.8.9)
1. [porzhnev.swiftformat-deep-hub](https://socket.dev/openvsx/package/porzhnev.swiftformat-deep-hub/overview/1.7.4)
1. [smolyak.slog-smart-studio](https://socket.dev/openvsx/package/smolyak.slog-smart-studio/overview/1.6.2)
1. [svetelin.industrious-live-hub](https://socket.dev/openvsx/package/svetelin.industrious-live-hub/overview/0.0.11)
1. [tarasenya.todo-rich-hub](https://socket.dev/openvsx/package/tarasenya.todo-rich-hub/overview/0.0.218)

### New Sleeper Extensions in the Same Wave

1. [bersenev.mc-super-pilot](https://socket.dev/openvsx/package/bersenev.mc-super-pilot/overview/4.0.4)
1. [buryagin.openapi-easy-studio](https://socket.dev/openvsx/package/buryagin.openapi-easy-studio/overview/5.4.2)
1. [skorzenko.office-deep-studio](https://socket.dev/openvsx/package/skorzenko.office-deep-studio/overview/3.5.6)
1. [yelzunik.sqltools-smart-forge](https://socket.dev/openvsx/package/yelzunik.sqltools-smart-forge/overview/0.5.8)
1. [zubarets.latex-quick-suite](https://socket.dev/openvsx/package/zubarets.latex-quick-suite/overview/10.14.3)

## Cloned Listings Designed to Look Legitimate

The impersonation pattern is visible in the way these extensions present themselves on Open VSX. One example is `Emotionkyoseparate.turkish-language-pack`, which closely mirrors the legitimate `MS-CEINTL.vscode-language-pack-tr` listing for the Turkish Language Pack for Visual Studio Code. The clone uses the same globe icon, similar naming, the same description, and copied Turkish-language README content, while swapping in a new publisher and unique identifier.

![Side-by-side comparison of cloned and legitimate Turkish Language Pack listings on Open VSX](https://cdn.sanity.io/images/cgdhsj6q/production/5b8d3d6c1d2817e53d228f3ea92cd2ec098a9d1d-2048x905.png?w=1600&q=95&fit=max&auto=format)

The difference is subtle enough that a developer browsing quickly could miss it. The legitimate extension is published under the expected `MS-CEINTL` namespace and shows 150K downloads, while the impersonation appears under a newly created publisher with far fewer downloads but otherwise familiar branding. This is the core social engineering pattern behind the latest GlassWorm cluster: cloned listings create enough visual trust to attract installs before any malware is introduced.

![Closer comparison of the impersonating publisher and the legitimate MS-CEINTL publisher](https://cdn.sanity.io/images/cgdhsj6q/production/e05ecd446f62da44e2cf50359befa52118b2510a-2048x1068.png?w=1600&q=95&fit=max&auto=format)

### Delivery Moving Beyond the Extension Source

In our [previous disclosure](https://socket.dev/blog/open-vsx-transitive-glassworm-campaign) of the latest wave of Open VSX extensions in the GlassWorm campaign, we documented a shift away from embedding the loader directly in each extension toward abusing `extensionPack` and `extensionDependencies` for transitive delivery. This allowed extensions that did not contain any malicious code on their own to install a separate malicious component, often disguised as a utility tool.

We [then observed](https://socket.dev/blog/glassworm-sleeper-extensions-activated-on-open-vsx) sleeper extensions that activate via updates and retrieve payloads from external sources, including VSIX packages hosted on GitHub. Earlier variants also used Solana transaction memos as a dead-drop channel for runtime payload retrieval, where encoded second-stage payloads were fetched and executed in memory. In those cases, the malicious behavior was still tied to code associated with a specific extension or dependency.

In this latest wave, delivery spans these approaches. Some variants rely on external payload retrieval, others rely on bundled native binaries, including reused installer components seen in prior GlassWorm activity, but the common pattern is that the extension itself acts as a thin loader. The extension's source code alone no longer reflects the behavior that ultimately runs. By shifting critical logic outside of what tools typically scan, and spreading it across multiple delivery mechanisms, the threat actor increases the likelihood of evading detection.

### Example: Native Binary Execution Path

To make this concrete, let us look at the extension's activation code in [`boulderzitunnel.vscode-buddies`](https://socket.dev/openvsx/package/boulderzitunnel.vscode-buddies/files/1.35.3/extension/out/extension/extension.js?platform=universal), which simply loads a platform-specific native module and invokes an `install()` function:

```javascript
const platforms = { win32: "./bin/win.node", darwin: "./bin/mac.node" };
const target = platforms[process.platform];
if (target) {
  const { install } = require(target);
  install();
}
```

The core logic is implemented in the bundled `.node` binary, not the JavaScript. These binaries contain embedded GitHub release URLs to `.vsix` files and include installation logic (e.g., `--install-extension`) targeting multiple IDEs such as VS Code, Cursor, and Windsurf.

## Example: Obfuscated Runtime Payload Retrieval

Other variants implement the same pattern entirely in JavaScript, without relying on bundled binaries (e.g., [`cubedivervolt.html-code-validate`](https://socket.dev/openvsx/package/cubedivervolt.html-code-validate/alerts/2.12.15?platform=universal&alert_name=malware)). In these extensions, the activation code contains heavily obfuscated code that decodes at runtime to retrieve a `.vsix` payload from a GitHub release.

The code resolves CLI paths for multiple editors, including VS Code, Cursor, Windsurf, and VSCodium, and installs the downloaded extension using commands such as `--install-extension`. Some variants also include an encrypted fallback URL that is decoded at runtime.

This approach achieves the same outcome as the binary-based variant, but keeps the delivery logic in obfuscated JavaScript. The extension acts as a loader, while the payload is retrieved and executed after activation.

## Indicators of Compromise (IOCs)

### Native Installer Binaries (SHA256)

1. `1b62b7c2ed7cc296ce821f977ef7b22bae59ef1dcdb9a34ae19467ee39bcf168`
1. `4ebfe8f66ca7e9751060b3301b5e8838d6017593cdae748541de83bfa28183bd`

### Downloaded VSIX Payload (SHA256)

1. `97c275e3406ad6576529f41604ad138c5bdc4297d195bf61b049e14f6b30adfd`

### GitHub Payload Hosting

1. `github[.]com/SquadMagistrate10/wnxtgkih`
1. `github[.]com/francesca898/dqwffqw`
1. `github[.]com/ColossusQuailPray/oiegjqde`

### Confirmed Malicious Extensions

1. [outsidestormcommand.monochromator-theme](https://socket.dev/openvsx/package/outsidestormcommand.monochromator-theme)
1. [keyacrosslaud.auto-loop-for-antigravity](https://socket.dev/openvsx/package/keyacrosslaud.auto-loop-for-antigravity)
1. [krundoven.ironplc-fast-hub](https://socket.dev/openvsx/package/krundoven.ironplc-fast-hub)
1. [boulderzitunnel.vscode-buddies](https://socket.dev/openvsx/package/boulderzitunnel.vscode-buddies)
1. [cubedivervolt.html-code-validate](https://socket.dev/openvsx/package/cubedivervolt.html-code-validate)
1. [winnerdomain17.version-lens-tool](https://socket.dev/openvsx/package/winnerdomain17.version-lens-tool)

### Sleeper Extensions

1. [peldravix.rpgiv2free-live-tool](https://socket.dev/openvsx/package/peldravix.rpgiv2free-live-tool)
1. [forkelbat.supersigil-rich-hub](https://socket.dev/openvsx/package/forkelbat.supersigil-rich-hub)
1. [fyltroven.gitchat-fast-tool](https://socket.dev/openvsx/package/fyltroven.gitchat-fast-tool)
1. [syndakove.todo4vcode-quick-suite](https://socket.dev/openvsx/package/syndakove.todo4vcode-quick-suite)
1. [vendrakos.rumdl-pro-kit](https://socket.dev/openvsx/package/vendrakos.rumdl-pro-kit)
1. [stadiumgripier.vscode-onedark-theme](https://socket.dev/openvsx/package/stadiumgripier.vscode-onedark-theme)
1. [wildlightregain.oxc-lint-format](https://socket.dev/openvsx/package/wildlightregain.oxc-lint-format)
1. [haelthorn.fractal-fast-studio](https://socket.dev/openvsx/package/haelthorn.fractal-fast-studio)
1. [gastholve.shell-pro-kit](https://socket.dev/openvsx/package/gastholve.shell-pro-kit)
1. [tossbers.browser-open-tool](https://socket.dev/openvsx/package/tossbers.browser-open-tool)
1. [pranlokev.topmodel-fast-suite](https://socket.dev/openvsx/package/pranlokev.topmodel-fast-suite)
1. [weldforick.brightscript-pro-kit](https://socket.dev/openvsx/package/weldforick.brightscript-pro-kit)
1. [stelbavik.hledger-fast-tool](https://socket.dev/openvsx/package/stelbavik.hledger-fast-tool)
1. [brixmundo.eca-easy-tool](https://socket.dev/openvsx/package/brixmundo.eca-easy-tool)
1. [shinypy.pycode-formatter](https://socket.dev/openvsx/package/shinypy.pycode-formatter)
1. [carveltstone.chatbuddy-auto-suite](https://socket.dev/openvsx/package/carveltstone.chatbuddy-auto-suite)
1. [thunderprosecutor.autopep8-formatter](https://socket.dev/openvsx/package/thunderprosecutor.autopep8-formatter)
1. [spikearshock.csv-rainbow](https://socket.dev/openvsx/package/spikearshock.csv-rainbow)
1. [countrepresent49.code-image-preview](https://socket.dev/openvsx/package/countrepresent49.code-image-preview)
1. [lairinspectortrek70.todo-highlighter](https://socket.dev/openvsx/package/lairinspectortrek70.todo-highlighter)
1. [superneentrance.peacock-colors](https://socket.dev/openvsx/package/superneentrance.peacock-colors)
1. [epichipporedeem.prettier-eslint-formatter](https://socket.dev/openvsx/package/epichipporedeem.prettier-eslint-formatter)
1. [archchainturn.twinny-ai-assist](https://socket.dev/openvsx/package/archchainturn.twinny-ai-assist)
1. [spacesalamanderhook.italian-language-pack](https://socket.dev/openvsx/package/spacesalamanderhook.italian-language-pack)
1. [closedtierenchant.vscode-awesome-icons](https://socket.dev/openvsx/package/closedtierenchant.vscode-awesome-icons)
1. [emotionkyoseparate.turkish-language-pack](https://socket.dev/openvsx/package/emotionkyoseparate.turkish-language-pack)
1. [sremuven.beautify-super-lens](https://socket.dev/openvsx/package/sremuven.beautify-super-lens)
1. [goltikov.auto-rich-forge](https://socket.dev/openvsx/package/goltikov.auto-rich-forge)
1. [karnikov.better-rich-studio](https://socket.dev/openvsx/package/karnikov.better-rich-studio)
1. [trenarin.autodocstring-auto-studio](https://socket.dev/openvsx/package/trenarin.autodocstring-auto-studio)
1. [meldarin.biome-live-tool](https://socket.dev/openvsx/package/meldarin.biome-live-tool)
1. [gronarin.auto-super-kit](https://socket.dev/openvsx/package/gronarin.auto-super-kit)
1. [keltarin.android-deep-hub](https://socket.dev/openvsx/package/keltarin.android-deep-hub)
1. [tralaven.c-easy-tool](https://socket.dev/openvsx/package/tralaven.c-easy-tool)
1. [meltovik.bookmark-rich-tool](https://socket.dev/openvsx/package/meltovik.bookmark-rich-tool)
1. [seldovik.cmake-smart-pilot](https://socket.dev/openvsx/package/seldovik.cmake-smart-pilot)
1. [veldekov.csv-pro-suite](https://socket.dev/openvsx/package/veldekov.csv-pro-suite)
1. [brenaven.cursor-rich-helper](https://socket.dev/openvsx/package/brenaven.cursor-rich-helper)
1. [karnenko.cursorless-pro-pilot](https://socket.dev/openvsx/package/karnenko.cursorless-pro-pilot)
1. [faldenko.explorer-auto-hub](https://socket.dev/openvsx/package/faldenko.explorer-auto-hub)
1. [vornovin.ionic-easy-kit](https://socket.dev/openvsx/package/vornovin.ionic-easy-kit)
1. [tormekov.htmlmustache-fast-craft](https://socket.dev/openvsx/package/tormekov.htmlmustache-fast-craft)
1. [dalsoven.intellij-live-pilot](https://socket.dev/openvsx/package/dalsoven.intellij-live-pilot)
1. [krosarin.npm-fast-studio](https://socket.dev/openvsx/package/krosarin.npm-fast-studio)
1. [meltuven.graphql-pro-tool](https://socket.dev/openvsx/package/meltuven.graphql-pro-tool)
1. [veltarik.duplicate-fast-helper](https://socket.dev/openvsx/package/veltarik.duplicate-fast-helper)
1. [tralarin.firefox-rich-lens](https://socket.dev/openvsx/package/tralarin.firefox-rich-lens)
1. [brixovik.es7-quick-hub](https://socket.dev/openvsx/package/brixovik.es7-quick-hub)
1. [krosovik.laravel-quick-pilot](https://socket.dev/openvsx/package/krosovik.laravel-quick-pilot)
1. [grisaven.markdown-live-kit](https://socket.dev/openvsx/package/grisaven.markdown-live-kit)
1. [dranaven.flask-live-craft](https://socket.dev/openvsx/package/dranaven.flask-live-craft)
1. [drovenko.data-live-suite](https://socket.dev/openvsx/package/drovenko.data-live-suite)
1. [krosaven.dot-live-forge](https://socket.dev/openvsx/package/krosaven.dot-live-forge)
1. [sremekov.javascriptsnippets-rich-craft](https://socket.dev/openvsx/package/sremekov.javascriptsnippets-rich-craft)
1. [breluven.html-smart-suite](https://socket.dev/openvsx/package/breluven.html-smart-suite)
1. [trikarin.database-super-tool](https://socket.dev/openvsx/package/trikarin.database-super-tool)
1. [sremovik.dendron-deep-hub](https://socket.dev/openvsx/package/sremovik.dendron-deep-hub)
1. [dalsovik.dbclient-quick-suite](https://socket.dev/openvsx/package/dalsovik.dbclient-quick-suite)
1. [frelovin.gitpod-deep-helper](https://socket.dev/openvsx/package/frelovin.gitpod-deep-helper)
1. [mrekelid.manpages-fast-kit](https://socket.dev/openvsx/package/mrekelid.manpages-fast-kit)
1. [kuldaran.search-smart-forge](https://socket.dev/openvsx/package/kuldaran.search-smart-forge)
1. [prednovik.php-super-pilot](https://socket.dev/openvsx/package/prednovik.php-super-pilot)
1. [tagovich.zener-pro-craft](https://socket.dev/openvsx/package/tagovich.zener-pro-craft)
1. [grozdarov.jinjahtml-easy-studio](https://socket.dev/openvsx/package/grozdarov.jinjahtml-easy-studio)
1. [shiverov.open-smart-suite](https://socket.dev/openvsx/package/shiverov.open-smart-suite/overview/0.0.49?platform=universal)
1. [draconzal.phpstan-easy-hub](https://socket.dev/openvsx/package/draconzal.phpstan-easy-hub)
1. [marabenov.graphql-super-craft](https://socket.dev/openvsx/package/marabenov.graphql-super-craft)
