---
title: "Monkey-Patched PyPI Packages Use Transitive Dependencies to Steal Solana Private Keys"
short_title: "Monkey-Patched PyPI Packages Steal Solana Private Keys"
date: 2025-05-29 12:00:00 +0000
categories: [Malware, PyPI]
tags: [Typosquatting, Python, Monkey Patching, Infostealer, T1195.002, T1036.005, T1573.002, T1059.006, T1608.001, T1119, T1657]
canonical_url: https://socket.dev/blog/monkey-patched-pypi-packages-steal-solana-private-keys
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/e68447aacff373f037186e1cfbbaa0a060582ea0-1024x1024.webp
  alt: "Monkey-Patched PyPI Packages Use Transitive Dependencies to Steal Solana Private Keys"
description: "Malicious PyPI package semantic-types steals Solana private keys via transitive dependency installs using monkey patching and blockchain exfiltration."
---

Socket's Threat Research Team uncovered a supply chain attack on the Python Package Index (PyPI), orchestrated by a threat actor using the alias [`cappership`](https://socket.dev/pypi/package/semantic-types/maintainers/0.1.6/tar-gz). The threat actor embedded a covert key‑stealing payload inside the Python package [`semantic‑types`](https://socket.dev/pypi/package/semantic-types/overview/0.1.6/tar-gz) and made five other packages ([`solana-keypair`](https://socket.dev/pypi/package/solana-keypair/overview/0.2.1/tar-gz), [`solana-publickey`](https://socket.dev/pypi/package/solana-publickey/overview/0.2.1/tar-gz), [`solana‑mev‑agent‑py`](https://socket.dev/pypi/package/solana-mev-agent-py/overview/0.1.0/tar-gz), [`solana‑trading‑bot`](https://socket.dev/pypi/package/solana-trading-bot/overview/0.1.0/tar-gz), and [`soltrade`](https://socket.dev/pypi/package/soltrade/overview/0.1.0/tar-gz)) depend on it. This transitive dependency means a single `pip install` for any of the other five libraries automatically fetches and executes the hidden payload.

Once imported, the malware monkey-patches Solana key-generation methods by modifying functions at runtime without altering the original source code. Each time a keypair is generated, the malware captures the private key. It then encrypts the key using a hardcoded RSA‑2048 public key and encodes the result in Base64. The encrypted key is embedded in a `spl.memo` transaction and sent to Solana Devnet, where the threat actor can retrieve and decrypt it to gain full access to the stolen wallet.

The threat actor created polished README files and linked the malicious packages to legitimate Stack Overflow posts and GitHub repositories to lend credibility and conceal malicious intent. Collectively, the six packages have been downloaded more than 25,900 times, exposing thousands of developer environments and CI pipelines to silent wallet theft. At the time of publication, the packages remain live on PyPI. We have petitioned the repository for their removal.

## How `semantic-types` Delivers the Malicious Payload Through Dependencies

When any of the five packages declare `install_requires = ["semantic-types>=0.1.2"]` (or a comparable requirement) in their setup metadata, `pip` will silently download and import `semantic‑types` whenever someone installs, upgrades, or runs those packages. That transitive pull guarantees the threat actor's code executes even if the victim never imports `semantic‑types` directly. The moment a developer types e.g. `pip install solana-keypair`, the resolver fetches `semantic‑types`, its malicious `__init__.py` runs, and every subsequent Solana `keypair` created on the infected system is exfiltrated.

![Dependency graph showing semantic-types as transitive dependency](https://cdn.sanity.io/images/cgdhsj6q/production/bce9f6d7c1c07d5240ec67ecf93f5f8249214c94-1514x864.png)
_semantic-types is the core malicious package. The five other packages (solana-keypair, solana-publickey, solana-mev-agent-py, solana-trading-bot, and soltrade) all depend directly on semantic-types. This makes them transitive carriers of the payload. Installing any of these packages causes semantic-types to be installed and executed automatically._

## Monkey Patching in Action

Monkey patching is a dynamic technique in Python that replaces functions or methods at runtime without modifying the source code on disk. It typically involves reassigning an existing method name to a new function.

In this campaign, the threat actor monkey-patched several constructor methods in the `Keypair` class from the [`solders`](https://socket.dev/pypi/package/solders) library, including:

- `Keypair.from_seed(...)`
- `Keypair.from_bytes(...)`
- `Keypair.from_base58_string(...)`

These constructors were replaced with wrapper functions that still return a valid keypair but also:

1. Convert the private key to raw bytes
1. Encrypt it using a hardcoded RSA‑2048 public key
1. Exfiltrate the ciphertext via a `spl.memo` transaction on Solana Devnet

Any time a keypair is created, the private key is silently captured and sent to the threat actor, bypassing user awareness and conventional detection mechanisms. All six malicious packages either directly import or transitively depend on `solders`, positioning it as the central entry point for runtime compromise.

## Inside the Malicious Payload

Below are [code](https://socket.dev/pypi/package/semantic-types/files/0.1.6/tar-gz/semantic_types-0.1.6/src/solana/rpc/types/__init__.py#L98) snippets of the backdoor functionality, annotated with inline comments:

The package `semantic-types` is designed to exfiltrate Solana private keys. By embedding itself into the normal key-generation process, it intercepts newly created wallet secrets at the moment of generation and forwards them to the threat actor. The stolen keys are encrypted using a hardcoded RSA-2048 public key, ensuring that only the threat actor, who holds the corresponding private key, can decrypt and misuse them. Additionally, five other packages published by the same threat actor (`solana-keypair`, `solana-publickey`, `solana-mev-agent-py`, `solana-trading-bot`, and `soltrade`) explicitly list `semantic-types` as a dependency.

Exfiltration is performed via a legitimate Solana RPC endpoint `api.devnet.solana.com` and embedded in a standard `spl.memo` transaction. This method allows the payload to bypass traditional network defenses and endpoint detection systems, which often focus on suspicious domains or outbound HTTP traffic.

Each time a project calls `Keypair.from_seed` or related methods, the monkey-patched wrapper silently spawns a background thread that transmits the 64-byte raw private key to the blockchain. Because the data is encrypted and wrapped in a memo transaction, it appears indistinguishable from routine wallet activity, making the attack both stealthy and operationally resilient.

![Socket AI Scanner analysis of semantic-types](https://cdn.sanity.io/images/cgdhsj6q/production/77ce2db15eb7bd08e7a3422aa0f8c39a21c60e30-619x669.png)
_Socket AI Scanner's analysis, including contextual details about the malicious semantic‑types package._

## Malicious Campaign Timeline

- 22 December 2024 — The benign version `semantic-types 0.1.2` is published. On the same day, the threat actor also releases `solana-trading-bot 0.1.0`, which declares `semantic-types` as a dependency. No malicious code is present yet.
- 23 December 2024 — Updates follow for `semantic-types 0.1.4`, `solana-trading-bot 0.1.1`, and `soltrade 0.1.1`. All dependencies remain benign at this stage, allowing early adopters to install a clean dependency tree and build trust.
- 26 January 2025 — Version `semantic-types 0.1.5` introduces the malicious payload, which monkey-patches `solders.keypair.Keypair` constructors to exfiltrate Solana private keys. The same day, `solana-mev-agent-py 0.1.0` and `solana-keypair 0.1.0` are published, both depending on and embedding the malicious logic, expanding the campaign's reach.
- 28 January 2025 — A minor update, `semantic-types 0.1.6`, repackages the same malicious payload. This targets users who pin versions loosely (e.g., `semantic-types~=0.1`) and ensures that the malware reaches projects that update automatically.
- 4 February 2025 — Two additional packages, `solana-keypair 0.2.1` and `solana-publickey 0.2.1`, are released. Marketed as compatibility shims (i.e. interface-matching compatibility wrappers), both import `semantic-types`, thereby transitively executing the backdoor. These additions help widen the blast radius while giving the appearance of useful tooling for Solana developers.

## Adversary Tradecraft

The threat actor behind the six malicious PyPI packages employed targeted social engineering techniques to obscure their true intent and blend into the developer ecosystem. By crafting polished README files and linking to legitimate resources, they sought to establish credibility and encourage adoption among developers working with Solana blockchain platform.

Their focus on Solana-related tooling suggests deliberate targeting of developers in the blockchain space, where compromised systems can yield access to private keys, smart contract credentials, and other high-value assets.

**1. Polished Documentation**

Each malicious package included a professionally structured README designed to mimic trusted open-source projects. These documents featured clear usage instructions, working code examples, and language aligned with best practices—conveying a sense of legitimacy to casual reviewers or automated scanners.

![solana-mev-agent-py project page](https://cdn.sanity.io/images/cgdhsj6q/production/e96547807229be3af6b036ee8d2a7916129853a5-1109x859.png)
_The solana-mev-agent-py malicious package features a polished project page and README, mimicking legitimate open source tools with structured descriptions, external links, and stylized visuals; tactics used by the threat actor to build credibility._

**2. Strategic Linking to Legitimate Resources**

The threat actor enriched package metadata with links to real Stack Overflow discussions, GitHub repositories, and official Solana documentation. For example, the `solana-keypair` package linked to a genuine Stack Overflow thread about import errors—an issue familiar to developers. This tactic reinforced the appearance of authenticity by embedding the malicious tools within realistic developer workflows.

![solana-keypair Stack Overflow link](https://cdn.sanity.io/images/cgdhsj6q/production/381609ca900665c8b294b3ab3212ff01308a80c6-739x860.png)
_The solana-keypair malicious package linked to this legitimate Stack Overflow post about a common import error, leveraging real developer pain points to enhance trust and disguise malicious intent._

**3. Imitation of Popular Tools**

Package names and descriptions were carefully chosen to resemble legitimate modules used in the Solana development community. By aligning with naming conventions from trusted packages (such as `solders.keypair`, `solana.keypair`, Solana's MEV tools and trading bots), the threat actor exploited brand familiarity to lower suspicion and increase the likelihood of adoption.

## Outlook and Recommendations

The discovery of a transitive supply chain attack leveraging `semantic‑types`, combined with the threat actor's use of monkey patching, runtime exfiltration, and blockchain based delivery mechanisms, demonstrates the ongoing evolution of stealthy, persistent attack infrastructure designed to blend into legitimate development workflows.

Security teams should anticipate copycat campaigns that adopt similar methods: delayed payload delivery, strategic use of transitive dependencies, and abuse of trusted platforms like Stack Overflow and GitHub to bolster credibility. The tactic of writing exfiltrated data to public blockchain memos may become a repeatable method for low-friction data theft, especially in cryptocurrency-adjacent developer ecosystems where such behavior appears routine.

Developers who installed or upgraded any of the six packages after January 26, 2025 must treat every Solana private key on that machine as compromised. In corporate settings where the malicious packages were incorporated into internal repositories, the tainted dependency may already reside in artifact caches, poisoning future builds. Because the `memo` is broadcast on‑chain, the threat actor can replay the ledger to collect historic keys, then sweep funds whenever a wallet balance appears on `mainnet`.

To counter this trend, defenders should prioritize deep inspection of nested dependencies, enforce stricter CI/CD pipeline controls, and implement behavioral detection tuned to post-install anomalies, such as unauthorized cryptographic operations or background threads spawned during package import. Organizations should adopt continuous dependency scanning to detect suspicious transitive relationships and runtime modification techniques. The free [**Socket GitHub app**](https://socket.dev/features/github) and [**CLI**](https://socket.dev/features/cli) can flag hidden code execution paths and monkey-patching behavior during pull requests and package installs, while the [**Socket browser extension**](https://socket.dev/features/web-extension) helps developers identify risky packages and maintainers in real time while browsing online.

## Indicators of Compromise (IOCs)

**Malicious PyPI Packages**

- `semantic‑types`
- `solana‑keypair`
- `solana‑publickey`
- `solana‑mev‑agent‑py`
- `solana‑trading‑bot`
- `soltrade`

**Threat Actor Identifiers**

- `cappership` — PyPI alias
- `cappership@proton[.]me` — PyPI registration email
- `D782zqWjgSvy4hQoqzY1ySrGrotnXm1suJeXFur8sAko` — threat actor's Solana public key
- `5a4d8480c9d1e82ba102f200258882fb9e694e8fc0343b6982c5540beccdca62` — RSA‑2048 public key fingerprint (SHA‑256)
- RSA public key (used for encrypting exfiltrated Solana private keys) `----BEGIN PUBLIC KEY----- MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArlNeyuMyZoaTDzttqND2 0RMGxtM2gUj4kQZ7bhqjNz53V3dAuyLRRLwqssqCIyyTJbOS18X6+QEZ47h4DKDw Oq2N5k1dkwSmFeJygNc2nYjJCNlgdx+AzfChc61Yzh9Nw2HT4r4DJRLDaIhkA2eH hPySRymvj7P/FS6Hnq7gbEY22wDItNb2sz8S6+o3nT7oHDVKn8bcxxZGLgYk5PVY 6tr1LmkNw+TrZLTrnAQ8ULkPSM0ww58RLx3NfmcYGoXdbIRmsWiN2svJ9EluZzv+ FOvQhdASVaD2KSVXJNPgKozUOlFnSp3vIyd1v1RAtFiGTbdPVOInRzVPnkQWDJCh OQIDAQAB -----END PUBLIC KEY-----`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading, Match legitimate name or location
- T1573.002 — Encrypted Channel: Asymmetric Cryptography
- T1059.006 — Command and Scripting Interpreter: Python
- T1608.001 — Stage Capabilities: Upload Malware
- T1119 — Automated Collection
- T1657 — Financial Theft
