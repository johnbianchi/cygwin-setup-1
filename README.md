Invoke-CygwinSetup
==================

A powershell cmdlet for installing cygwin.  This cmdlet will download the latest cygwin setup executable, then build the command arguments from the configuration, and run the installer.  It will wait for the cygwin installer to complete before continuing.  

This cmdlet allows you to specify configuration as json:

```json
{
    "options": [
        {"name": "quiet-mode"},
        {"name": "upgrade-also"},
        {"name": "root", "value": "C:\\cygwin64"},
        {"name": "site", "value": "http://cygwin.mirrors.hoobly.com"}
    ],
    "packages": [
        "autoconf",
        "crypt",
        "curl",
        "dos2unix",
        "gcc-core",
        "gcc-g++",
        "gettext-devel",
        "git",
        "libarchive",
        "libarchive-devel",
        "libcrypt-devel",
        "libcurl-devel",
        "libmysqlclient-devel",
        "libxml2",
        "libxml2-devel",
        "make",
        "mysql",
        "openssh",
        "openssl",
        "patch",
        "perl",
        "pv",
        "unzip",
        "vim",
        "wget"
    ]
}
```

This json can be stored locally, or remotely, and referred to by path or url.  

```powershell
# Load config from default location $USERPROFILE/.developer/cygwin.json
Invoke-CygwinSetup

# Load config from the specified file
Invoke-CygwinSetup -Config C:\Users\Public\.developer\cygwin.json

# Load config from the specified url
Invoke-CygwinSetup -Config https://raw.githubusercontent.com/lucastheisen/cygwin-setup/master/Example/cygwin.json
```

You can also pipe in the json if you prefer:

```powershell
'{"packages": ["perl","curl"]}' | ConvertFrom-Json | Invoke-CygwinSetup
```

An additional option `-DryRun` can be used to verify the actual setup command that will be run without executing it.  This can be useful for verifying your configuration:

```powershell
'{"packages":["foo","bar"]}' | ConvertFrom-Json | Invoke-CygwinSetup -DryRun
# Write-Host: Would have run [C:\Users\ltheisen\Downloads\setup-x86_64.exe --packages foo,bar]
```

