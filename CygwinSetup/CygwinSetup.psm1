<# 
 .Synopsis
  Installs/updates cygwin.
 
 .Description
  Installs/updates cygwin.

 .Parameter Config
  The path to a configuration file.  Defaults to $USERPROFILE\.developer\cygwin.json

 .Example
  # Load config from default location $USERPROFILE/.developer/cygwin.json
  Invoke-CygwinSetup

 .Example
  # Load config from the specified file
  Invoke-CygwinSetup -Config C:\Users\Public\.developer\cygwin.json

 .Example
  # Load config from the specified url
  Invoke-CygwinSetup -Config http://github.com/lucastheisen/cygwin-setup/Example/cygwin.json
#>
function Invoke-CygwinSetup
{
    [CmdletBinding()]
    param 
    (
        [String]
        $Config = [IO.Path]::Combine($env:USERPROFILE, ".developer", "cygwin.json"),

        [switch]
        $DryRun
    )

    $setup_exe = "setup-x86_64.exe"
    $url = "https://cygwin.com/$setup_exe"
    $path = [IO.Path]::Combine($env:USERPROFILE, "Downloads", $setup_exe)
          
    $client = New-Object Net.WebClient
    Write-Debug "Downloading [$url] to [$path]" 
    #(new-object Net.WebClient).DownloadFile($url, $path) 

    Write-Debug "Loading config from [$Config]" 
    $configHash = $client.DownloadString($config) | 
        ConvertFrom-Json | 
        ConvertTo-Hashtable

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
