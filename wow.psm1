function Publish-Addon {
    param (
        [ValidateSet("Retail", "Classic", "Wrath", "Vanilla", "All")]
        [string[]]$Flavor = @("Retail")

        [ValidateSet("Live","PTR", "Beta", "Alpha", "All")]
        [string[]]$Channel = @("Live")
    )
    begin {
        $WOW_HOME = $env:WOW_HOME
        $PACKAGER_VERSION = "v2.1.0"
        $WORKING_DIR = "/tmp/.publish-addon"
        $gameDirs = [System.Collections.Generic.List[string]]::new()

        # game flavor
        $retail = $Flavor -Contains "Retail" -or $Flavor -Contains "All"
        $wrath = $Flavor -Contains "Wrath" -or $Flavor -Contains "Classic" -or $Flavor -Contains "All"
        $vanilla = $Flavor -Contains "Vanilla" -or $Flavor -Contains "Classic" -or $Flavor -Contains "All"

        # release channel
        $live = $Channel -Contains "Live" -or $Channel -Contains "All"
        $ptr = $Channel -Contains "PTR" -or $Channel -Contains "All"
        $beta = $Channel -Contains "Beta" -or $Channel -Contains "All"
        $alpha = $Channel -Contains "Alpha" -or $Channel -Contains "All"

        if ($retail) {
            if ($live) {
                $gameDirs.Add("_retail_")
            }

            if ($ptr) {
                $gameDirs.Add("_ptr_")
                $gameDirs.Add("_xptr_")
            }

            if ($beta) {
                $gameDirs.Add("_beta_")
            }

            if ($alpha) {
                $gameDirs.Add("_alpha_")
            }
        }

        if ($wrath) {
            if ($live) {
                $gameDirs.Add("_classic_")
            }

            if ($ptr) {
                $gameDirs.Add("_classic_ptr_")
            }

            if ($beta) {
                $gameDirs.Add("_classic_beta_")
            }

            if ($alpha) {
                $gameDirs.Add("_classic_alpha_")
            }
        }

        if ($vanilla) {
            if ($live) {
                $gameDirs.Add("_classic_era_")
            }

            if ($ptr) {
                $gameDirs.Add("_classic_era_ptr_")
            }

            if ($beta) {
                $gameDirs.Add("_classic_era_beta_")
            }

            if ($alpha) {
                $gameDirs.Add("_classic_era_alpha_")
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
        $args.add('-dlzS')
        $args.add('-t {0}' -f $addonDir)
        $args.add('-r {0}' -f $releaseDir)

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
