function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$beta = $false,
        [switch]$alpha = $false,
        [switch]$retail = $false,
        [switch]$classic = $false,
        [switch]$wrath = $false
    )
    begin {
        $WOW_HOME = $env:WOW_HOME
        $PACKAGER_VERSION = "v2.1.0"
        $WORKING_DIR = "/tmp/.publish-addon"

        $gameDirs = [System.Collections.Generic.List[string]]::new()
        $all = -Not ($retail -or $classic -or $wrath)

        # the PTR is messy
        if ($ptr) {
            # 1.14.4
            if ($classic -or $all) {
                $gameDirs.Add("_ptr2_")
            }

            if ($wrath -or $all) {
                $gameDirs.Add("_classic_ptr_")
            }

            if ($retail -or $all) {
                # 10.1.0
                $gameDirs.Add("_ptr_")

                # 10.1.5
                $gameDirs.Add("_xptr_")
            }
        }
        elseif ($beta) {
            if ($wrath -or $all) {
                $gameDirs.Add("_classic_beta_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_beta_")
            }

            if ($retail -or $all) {
                $gameDirs.Add("_beta_")
            }
        }
        elseif ($alpha) {
            if ($wrath -or $all) {
                $gameDirs.Add("_classic_alpha_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_alpha_")
            }

            $gameDirs.Add("_alpha_")
        }
        else {
            if ($wrath -or $all) {
                $gameDirs.Add("_classic_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_")
            }

            if ($retail -or $all) {
                $gameDirs.Add("_retail_")
            }
        }
    }
    process {
        if (!(Test-Path $WOW_HOME)) {
            Write-Host "The WOW_HOME environment variable hasn't been set. Please set it to the location of World of Warcraft Launcher.exe"
            return;
        }

        if (!(Test-Path .\*.pkgmeta*)) {
            Write-Host "The current directory does not contain a pkgmeta file"
            return
        }

        $addonDir = "$WORKING_DIR/in"
        $releaseDir = "$WORKING_DIR/out"
        $packager = "$WORKING_DIR/release.sh"

        # 1. setup directories
        wsl -e mkdir -p "$addonDir"

        # 2. copy files over to WSL (to avoid performance issues when working via NTFS)
        Write-Host "Copying files from $pwd"
        $pwdWSL = wsl -e wslpath "$pwd"
        wsl -e rsync -rz --delete "$pwdWSL/" "$addonDir"

        # 3. grab the packager script
        wsl -e curl -s -o "$packager" "https://raw.githubusercontent.com/BigWigsMods/packager/$PACKAGER_VERSION/release.sh"
        wsl -e chmod u+x "$packager"

        # 4. construct the packager arguments
        $args = [System.Collections.Generic.List[string]]::new()
        $args.add('-dlz')
        $args.add('-t {0}' -f $addonDir)
        $args.add('-r {0}' -f $releaseDir)

        # check for flavor specific .pkgmeta files, and use those if they exist
        if ($wrath) {
            $args.add('-g wrath')

            if (Test-Path .\*.pkgmeta-wrath) {
                $args.add('-m "{0}/.pkgmeta-wrath"' -f $addonDir)
            }
        }
        elseif ($classic) {
            $args.add('-g classic')

            if (Test-Path .\*.pkgmeta-classic) {
                $args.add('-m "{0}/.pkgmeta-classic"' -f $addonDir)
            }
        }
        elseif ($retail) {
            $args.add('-g retail')

            if (Test-Path .\*.pkgmeta-retail) {
                $args.add('-m "{0}/.pkgmeta-retail"' -f $addonDir)
            }
        }
        # publish a universal addon, automatically generating flavor
        # specific TOC files
        else {
            $args.add('-S')
        }

        # 5. execute the packager
        Write-Host "Running packager"
        Invoke-Expression "wsl -e $packager $($args -Join ' ')"

        # 6. copy the output files over to the target wow directories
        $releaseDirUNC = wsl -e wslpath -w $releaseDir
        foreach ($gameDir in $gameDirs) {
            $wowAddonsDir = Join-Path $WOW_HOME $gameDir Interface AddOns

            if (Test-Path -Path $wowAddonsDir) {
                $wowAddonsDirWSL = wsl -e wslpath "$wowAddonsDir"

                Write-Host "Copying files to $wowAddonsDir"
                Get-ChildItem -Directory $releaseDirUNC | ForEach-Object {
                    $src = $_.FullName
                    $srcWSL = wsl -e wslpath "$src"
                    wsl -e rsync -r --delete "$srcWSL" "$wowAddonsDirWSL"
                }
            }
        }
    }
    end {
        # 7. cleanup
        Write-Host "Cleaning up"
        wsl -e rm -rf $WORKING_DIR
        Write-Host "Publish complete"
    }
}
Export-ModuleMember Publish-Addon
