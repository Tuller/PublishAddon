# Publish-Addon

This is a silly powershell module I wrote so that I can invoke the
[Bigwigs Packger](https://github.com/BigWigsMods/packager) locally when testing
addons. I wouldn't actually recommend using this, as its way more work than it
should be.

## Setup

1. Install [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
2. Import this module into a powershell file
3. Set the following environment variables:

    | Name             | Value                |
    | ---------------- | -------------------- |
    | WOW_RETAIL_HOME  | $WOW_HOME\\_retail_  |
    | WOW_PTR_HOME     | $WOW_HOME\\_ptr_     |
    | WOW_BETA_HOME    | $WOW_HOME\\_beta_    |
    | WOW_CLASSIC_HOME | $WOW_HOME\\_classic_ |
    | WOW_PACKAGER     | Wherever you installed the packager script |

## Usage

From an addon directory with a .pkgmeta file, run one of the following:

```powershell
Publish-Addon
Publish-Addon -classic
Publish-Addon -ptr
Publish-Addon -beta
```

This will package up your addon and copy it to the Interface\AddOns folder in
the targeted World of Warcraft install directory.
