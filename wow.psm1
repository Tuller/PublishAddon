function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$alpha = $false,
        [switch]$beta = $false,
        [switch]$classic = $false,
        [switch]$Verbose = $false
    )
    begin {
        [string] $addonsDirectory = $null

        if ($ptr -eq $true) {
            if ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_ptr_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_ptr_"
            }
        }
        elseif ($beta -eq $true) {
            if ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_beta_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_beta_"
            }
        }
        elseif ($alpha -eq $true) {
            if ($classic -eq $true) {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_classic_alpha_"
            }
            else {
                $addonsDirectory = Join-Path $WOW_HOME -ChildPath "_alpha_"
            }
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
        $wowClassicVersion = "1.13.5"
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
            # if running classic, check for a .pkgmeta-classic file and use that
            if ($classic -eq $true) {
                if (Test-Path .\*.pkgmeta-classic) {
                    bash -c "$WOW_PACKAGER -dlz -g $wowClassicVersion -m .pkgmeta-classic -t $tempDir"
                }
                else {
                    bash -c "$WOW_PACKAGER -dlz -g $wowClassicVersion -t $tempDir"
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
            $dest = Join-Path $addonsDirectory -ChildPath $_.Name

            robocopy /mir $src $dest > "$uncTempDir\.release\robocopy.log"
        }

        # cleanup the temp dir
        Remove-Item $uncTempDir -Recurse -Force
    }
}
Export-ModuleMember Publish-Addon