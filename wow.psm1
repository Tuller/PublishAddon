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
        if ($classic -eq $true) {
            bash -c  "$WOW_PACKAGER -d -z -g 1.13.2"
        }
        else {
            bash -c  "$WOW_PACKAGER -d -z"
        }

        Get-ChildItem -Directory .\.release\ | ForEach-Object {
            $src = $_.FullName
            $dest = Join-Path $addonsDirectory -ChildPath $_.Name

            robocopy /mir $src $dest > .\.release\robocopy.log
        }
    }
}
Export-ModuleMember Publish-Addon