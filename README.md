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
Publish-Addon
Publish-Addon -classic
Publish-Addon -bc
Publish-Addon -ptr
Publish-Addon -beta

# you can use combinations to publish to things like the classic PTR/beta too
Publish-Addon -classic -ptr
Publish-Addon -classic -beta
```

This will package up your addon and copy it to the Interface\AddOns folder in
the targeted World of Warcraft install directory.
