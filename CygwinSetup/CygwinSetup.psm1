<# 
 .Synopsis
  Installs/updates cygwin.
 
 .Description
  Installs/updates cygwin.

 .Parameter Config
  The path to a configuration file.  Defaults to $USERPROFILE\.developer\cygwin.json

 .Parameter DryRun
  Write-Host the command rather than run it

 .Example
  # Load config from default location $USERPROFILE/.developer/cygwin.json
  Invoke-CygwinSetup

 .Example
  # Load config from the specified file
  Invoke-CygwinSetup -Config C:\Users\Public\.developer\cygwin.json

 .Example
  # Load config from the specified url
  Invoke-CygwinSetup -Config https://raw.githubusercontent.com/lucastheisen/cygwin-setup/master/Example/cygwin.json

 .Example
  # Pipe configuration in
  '{"packages": ["perl","curl"]}' | ConvertFrom-Json | Invoke-CygwinSetup
#>
function Invoke-CygwinSetup
{
    [CmdletBinding()]
    param 
    (
        [Parameter( ValueFromPipeline=$true)]
        $Config = [IO.Path]::Combine($env:USERPROFILE, ".developer", "cygwin.json"),

        [switch]
        $DryRun
    )

    Write-Debug "Loading config from [$Config]" 
    $configJson = $Config
    if ($Config -is [String]) 
    {
        $configJson = Get_ConfigJson($Config)
    }
    $configHash = $configJson | ConvertTo-Hashtable

    $proxy
    $args = @()
    foreach ($option in $configHash["options"]) 
    {
        $name = $option["name"]
        $args += "--$name"

        if ($option.ContainsKey("value")) 
        {
            $value = $option["value"]
            $args += $value
        }

        if ($name -eq "proxy") {
            $proxy = $option["value"]
        }
    }

    $setup_exe = "setup-x86_64.exe"
    $url = "https://cygwin.com/$setup_exe"
    $path = [IO.Path]::Combine($env:USERPROFILE, "Downloads", $setup_exe)

    if (-not $DryRun)
    {
        if ($proxy) {
            Write-Debug "Downloading [$url] over proxy [$proxy] to [$path]"
            Invoke-WebRequest -Uri $url -Proxy $proxy -OutFile $path
        }
        else {
            Write-Debug "Downloading [$url] to [$path]"
            Invoke-WebRequest -Uri $url -OutFile $path
        }
    }

    $args += "--packages"
    $args += ($configHash["packages"]) -join ","

    Write-Debug "Running [$path $args]"
    if ($DryRun)
    {
        Write-Host "Would have run [$path $args]"
    }
    else 
    {
        Start-Process $path -ArgumentList $args -Wait
    }

    Write-Debug "Done!"
}

function Get_ConfigJson 
{
    param 
    (
        [String]
        $Config
    )

    return (New-Object Net.WebClient).DownloadString($Config) | 
        ConvertFrom-Json;
}

function ConvertTo-Hashtable 
{
    param 
    (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    if ($null -eq $InputObject) { return $null }

    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
    {
        $collection = @(
            foreach ($object in $InputObject) 
            { 
                ConvertTo-Hashtable $object 
            }
        )

        Write-Output -NoEnumerate $collection
    }
    elseif ($InputObject -is [PSObject])
    {
        $hash = @{}

        foreach ($property in $InputObject.PSObject.Properties)
        {
            $hash[$property.Name] = ConvertTo-Hashtable $property.Value
        }

        $hash
    }
    else
    {
        $InputObject
    }
}

Export-ModuleMember -Function Invoke-CygwinSetup
