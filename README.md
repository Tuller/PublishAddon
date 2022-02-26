# Publish-Addon

This is a PowerShell module I wrote so that I can invoke the
[Bigwigs Packager](https://github.com/BigWigsMods/packager) locally when testing
addons.

## Setup

1. Install [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows)
1. Install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
1. Import this module into a PowerShell file
1. Set the following environment variables:

    | Name             | Value                |
    | ---------------- | -------------------- |
    | WOW_HOME         | Wherever you installed World of Warcraft  |
    | WOW_PACKAGER     | Wherever you installed the packager script |

## Usage

From an addon directory with a .pkgmeta file, run one of the following:

```powershell
# Deploy a version for each game flavor (Retail, BCC, Vanilla) with the live
# release channel.
Publish-Addon

# Target a specific game flavor. This will use the packager's keyword
# replacement abilities for that version and use a flavor specific .pkgmeta
# (.pkgmeta-[flavor]), if present
Publish-Addon -retail
Publish-Addon -bcc
Publish-Addon -classic

# Deploy to a specific game release channel.
Publish-Addon -ptr
Publish-Addon -beta
Publish-Addon -alpha

# Deploy to a specific flavor and release channel.
Publish-Addon -retail -ptr
Publish-Addon -bcc -beta
Publish-Addon -classic -alpha
```

This will package up your addon and copy it to the Interface\AddOns folder in
the targeted World of Warcraft install directory.
