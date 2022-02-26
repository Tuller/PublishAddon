function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$beta = $false,
        [switch]$alpha = $false,
        [switch]$retail = $false,
        [switch]$classic = $false,
        [switch]$bcc = $false,
        [switch]$Verbose = $false
    )
    begin {
        $gameDirs = [System.Collections.Generic.List[string]]::new()
        $all = -Not ($retail -or $classic -or $bcc)

        if ($ptr) {
            if ($bcc -or $all) {
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
            if ($bcc -or $all) {
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
            if ($bcc -or $all) {
                $gameDirs.Add("_classic_alpha_")
            }

            if ($classic -or $all) {
                $gameDirs.Add("_classic_era_alpha_")
            }

            $gameDirs.Add("_alpha_")
        }
        else {
            if ($bcc -or $all) {
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
        $tempDir = "/tmp/wowpkg"
        $uncTempDir = "\\wsl$\Ubuntu\tmp\wowpkg"

        # copy stuff over to a temporary directory on the linux side
        # this is a workaround for cross OS filesystem performance being slow
        # on WSL 2
        if (Test-Path $uncTempDir) {
            Remove-Item $uncTempDir -Recurse -Force
        }

        Copy-Item .\ -Destination $uncTempDir -Recurse

        # run the packager script
        if (Test-Path .\*.pkgmeta) {
            # check for flavor specific .pkgmeta files, and use those if they exist
            if ($bcc) {
                if (Test-Path .\*.pkgmeta-bc) {
                    bash -c "$WOW_PACKAGER -dlz -g bcc -m .pkgmeta-bcc -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g bcc -t $tempDir"
                }
            }
            elseif ($classic) {
                if (Test-Path .\*.pkgmeta-classic) {
                    bash -c "$WOW_PACKAGER -dlz -g classic -m .pkgmeta-classic -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g classic -t $tempDir"
                }
            }
            elseif ($retail) {
                if (Test-Path .\*.pkgmeta-retail) {
                    bash -c "$WOW_PACKAGER -dlz -g retail -m .pkgmeta-retail -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g retail -t $tempDir"
                }
            }
            # publish a universal addon, automatically generating flavor
            # specific TOC files
            else {
                bash -c "$WOW_PACKAGER -dlzS -t $tempDir"
            }
        }

        # once the packager script is done, copy stuff back over from the temp
        # directory over to the addons folder
        foreach ($gameDir in $gameDirs) {
            $addonsDir = [IO.Path]::Combine($WOW_HOME, $gameDir, 'Interface', 'AddOns')

            Get-ChildItem -Directory $uncTempDir\.release\ | ForEach-Object {
                $src = $_.FullName

                # purge zone identifier files, in case those come along
                # they're NFS alternate file stream stuff from downloading things
                # from the internet using Edge/IE
                if (-Not $src.endswith("Zone.Identifier")) {
                    $dest = Join-Path $addonsDir -ChildPath $_.Name
                }

                robocopy /mir $src $dest > "$uncTempDir\.release\robocopy.log"
            }
        }

        # cleanup the temp dir
        Remove-Item $uncTempDir -Recurse -Force
    }
}
Export-ModuleMember Publish-Addon