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

## Usage

From an addon directory with a .pkgmeta file, run one of the following:

```powershell
# Publishes an addon using the bigwigs packager too the Retail addons directory
Publish-Addon

# Publish to one or more release channels (Live, PTR, Beta, Alpha)
Publish-Addon -Channel Live
Publish-Addon -Channel Live, PTR

# all release channels
Publish-Addon -Channel All

# Specify one or more game flavors (Retail, Wrath, Vanilla)
Publish-Addon -Flavor Retail
Publish-Addon -Flavor Wrath, Vanilla

# classic era + classic
Publish-Addon -Flavor Classic

# all game flavors
Publish-Addon -Channel All
```
