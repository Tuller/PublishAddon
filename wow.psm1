function Publish-Addon {
    param (
        [switch]$ptr = $false,
        [switch]$beta = $false,
        [switch]$classic = $false,
        [switch]$Verbose = $false
    )
    begin {
        [string] $addonsDirectory = $null

        if ($ptr -eq $true) {
            $addonsDirectory = $WOW_PTR_HOME
        }
        elseif ($beta -eq $true) {
            $addonsDirectory = $WOW_BETA_HOME
        }
        elseif ($classic -eq $true) {
            $addonsDirectory = $WOW_CLASSIC_HOME
        }
        else {
            $addonsDirectory = $WOW_RETAIL_HOME
        }

        $addonsDirectory = Join-Path $addonsDirectory -ChildPath "Interface/AddOns"
    }
    process {
        if (Test-Path .\*.pkgmeta) {
            if ($classic -eq $true) {
                bash -c  "$WOW_PACKAGER -dlz -g 1.13.2"
            }
            else {
                bash -c  "$WOW_PACKAGER -dlz"
            }
        }
        else {
            $whitelist = @(
                "*.lua",
                "*.xml",
                "*.toc",
                "*.tga",
                "*.blp",
                "*.ttf",
                "*.txt",
                "README",
                "README.*"
                "LICENSE",
                "LICENSE.*"
            )

            Remove-Item .\.release\* -Recurse -Force

            foreach ($toc in Get-ChildItem *.toc -Recurse -Depth 1) {
                $src = $toc.Directory.FullName
                $dest = Join-Path ".\.release" -ChildPath $toc.Directory.Name

                foreach ($file in Get-ChildItem -Path $src -Include $whitelist -Recurse) {
                    $newFile =  $file.FullName.Replace($src, $dest)
                    New-Item -ItemType File -Path $newFile -Force
                    Copy-Item -Path $file -Destination $newFile
                }
            }
        }

        Get-ChildItem -Directory .\.release\ | ForEach-Object {
            $src = $_.FullName
            $dest = Join-Path $addonsDirectory -ChildPath $_.Name

            robocopy /mir $src $dest > .\.release\robocopy.log
        }
    }
}
Export-ModuleMember Publish-Addon