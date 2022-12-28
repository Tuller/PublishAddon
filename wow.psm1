function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$beta = $false,
        [switch]$alpha = $false,
        [switch]$retail = $false,
        [switch]$classic = $false,
        [switch]$bcc = $false,
        [switch]$wrath = $false,
        [switch]$Verbose = $false
    )
    begin {
        $gameDirs = [System.Collections.Generic.List[string]]::new()
        $all = -Not ($retail -or $classic -or $bcc -or $wrath)

        if ($ptr) {
            if ($bcc -or $wrath -or $all) {
                $gameDirs.Add("_classic_ptr_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_ptr_")
            }

            if ($retail -or $all) {
                $gameDirs.Add("_ptr_")
            }
        }
        elseif ($beta) {
            if ($bcc -or $wrath -or $all) {
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
            if ($bcc -or $wrath -or $all) {
                $gameDirs.Add("_classic_alpha_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_alpha_")
            }

            $gameDirs.Add("_alpha_")
        }
        else {
            if ($bcc -or $wrath -or $all) {
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
        $tempDir = "/tmp/.wowpackager"

        # recreate directory
        # wsl -e rm -rf "$tempDir"
        # wsl -e mkdir "$tempdir"

        $pwdWSL = wsl -e wslpath "$pwd"
        $tempDirUNC = wsl -e wslpath -w "$tempDir"
        $releaseDirUNC = Join-Path -Path $tempDirUNC -ChildPath ".release"

        # copy files over to WSL (to avoid performance issues when working via NTFS)
        Write-Host "Copying files from $pwd to $tempDirUNC"
        wsl -e rsync -rz --delete "$pwdWSL/" "$tempdir"

        # run the packager script
        Write-Host "Running Packager"
        if (Test-Path .\*.pkgmeta) {
            # check for flavor specific .pkgmeta files, and use those if they exist
            if ($wrath) {
                if (Test-Path .\*.pkgmeta-bc) {
                    wsl -e "$WOW_PACKAGER" -dlz -g wrath -m .pkgmeta-wrath -t "$tempDir"
                }
                else {
                    wsl -e "$WOW_PACKAGER" -dlz -g wrath -t "$tempDir"
                }
            }
            elseif ($bcc) {
                if (Test-Path .\*.pkgmeta-bc) {
                    wsl -e "$WOW_PACKAGER" -dlz -g bcc -m .pkgmeta-bcc -t "$tempDir"
                }
                else {
                    wsl -e "$WOW_PACKAGER" -dlz -g bcc -t "$tempDir"
                }
            }
            elseif ($classic) {
                if (Test-Path .\*.pkgmeta-classic) {
                    wsl -e "$WOW_PACKAGER" -dlz -g classic -m .pkgmeta-classic -t "$tempDir"
                }
                else {
                    wsl -e "$WOW_PACKAGER" -dlz -g classic -t "$tempDir"
                }
            }
            elseif ($retail) {
                if (Test-Path .\*.pkgmeta-retail) {
                    wsl -e "$WOW_PACKAGER" -dlz -g retail -m .pkgmeta-retail -t "$tempDir"
                }
                else {
                    wsl -e "$WOW_PACKAGER" -dlz -g retail -t "$tempDir"
                }
            }
            # publish a universal addon, automatically generating flavor
            # specific TOC files
            else {
                wsl -e "$WOW_PACKAGER" -dlzS -t "$tempDir"
            }
        }

        # once the packager script is done, copy stuff back over from the temp
        # directory over to the addons folder
        foreach ($gameDir in $gameDirs) {
            $addonsDir = Join-Path $WOW_HOME $gameDir Interface AddOns

            if (Test-Path -Path $addonsDir) {
                $addonsDirWSL = wsl -e wslpath "$addonsDir"

                Write-Host "Copying files to $addonsDir"

                Get-ChildItem -Directory $releaseDirUNC | ForEach-Object {
                    $src = $_.FullName
                    $srcWSL = wsl -e wslpath "$src"
                    wsl -e rsync -r --delete "$srcWSL" "$addonsDirWSL"
                }
            }
        }

        Write-Host "Publish complete"
    }
}
Export-ModuleMember Publish-Addon
