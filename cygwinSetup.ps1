$DebugPreference = "Continue"

# Configure
$setupExe = "setup-x86_64.exe"
$url = "https://cygwin.com/$setupExe"
$path = [IO.Path]::Combine($env:USERPROFILE, "Downloads", $setupExe)

# Download
$client = New-Object System.Net.WebClient
Write-Debug "Download [$url] to [$path]"
$client.DownloadFile($url, $path)

# Install
Write-Debug "Run [$command]"
$packages = $(
    alternatives,
    autoconf,
    automake,
    gcc-core,
    gcc-g++,
    git,
    libcrypt-devel,
    libxml2,
    libxml2-devel,
    make,
    mkisofs,
    ncurses,
    patch,
    openssl,
    openssl-devel,
    openssh,
    perl,
    texinfo-tex,
    texi2html,
    texlive-collection-latex,
    unzip
)
