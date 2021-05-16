function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$alpha = $false,
        [switch]$beta = $false,
        [switch]$classic = $false,
        [switch]$bcc = $false,
        [switch]$Verbose = $false
    )
    begin {
        [string] $addonsDirectory = $null

        if ($ptr -eq $true) {
            if ($bcc -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_ptr_"
            }
            elseif ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_ptr_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_ptr_"
            }
        }
        elseif ($beta -eq $true) {
            if ($bcc -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_beta_"
            }
            elseif ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_beta_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_beta_"
            }
        }
        elseif ($alpha -eq $true) {
            if ($bcc -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_alpha_"
            }
            elseif ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_alpha_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_alpha_"
            }
        }
        elseif ($bcc -eq $true) {
            $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_bc_"
        }
        elseif ($classic -eq $true) {
            $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_"
        }
        else {
            $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_retail_"
        }

        $addonsDirectory = Join-Path $addonsDirectory -ChildPath "Interface/AddOns"
    }
    process {
        $tempDir = "/tmp/wowpkg"
        $uncTempDir = "\\wsl$\Ubuntu\tmp\wowpkg"

        # copy stuff over to a temporary directory on the linux side
        # this is a workaround for cross OS filesystem  performance being slow
        # on WSL 2
        if (Test-Path $uncTempDir) {
            Remove-Item $uncTempDir -Recurse -Force
        }

        Copy-Item .\ -Destination $uncTempDir -Recurse

        # run the packager script
        if (Test-Path .\*.pkgmeta) {
            # if running bc, check for a .pkgmeta-bc file and use that
            # if it exists
            if ($bcc -eq $true) {
                if (Test-Path .\*.pkgmeta-bc) {
                    bash -c "$WOW_PACKAGER -dlz -g bcc -m .pkgmeta-bcc -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g bcc -t $tempDir"
                }
            }
            # if running classic, check for a .pkgmeta-classic file and use that
            # if it exists
            elseif ($classic -eq $true) {
                if (Test-Path .\*.pkgmeta-classic) {
                    bash -c "$WOW_PACKAGER -dlz -g classic -m .pkgmeta-classic -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g classic -t $tempDir"
                }
            }
            else {
                bash -c "$WOW_PACKAGER -dlz -t $tempDir"
            }
        }

        # once the packager script is done, copy stuff back over from the temp
        # directory over to the addons folder
        Get-ChildItem -Directory $uncTempDir\.release\ | ForEach-Object {
            $src = $_.FullName

            # purge zone identifier files, in case those come along
            # they're NFS alternate file stream stuff from downloading things
            # from the internet using Edge/IE
            if (-Not $src.endswith("Zone.Identifier")) {
                $dest = Join-Path $addonsDirectory -ChildPath $_.Name
            }

            robocopy /mir $src $dest > "$uncTempDir\.release\robocopy.log"
        }

        # cleanup the temp dir
        Remove-Item $uncTempDir -Recurse -Force
    }
}
Export-ModuleMember Publish-Addon