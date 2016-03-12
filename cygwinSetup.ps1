# Must have the proper execution policy first:
# 
# To set once for all local scripts (http://stackoverflow.com/a/10638/516433):
#   set-executionpolicy remotesigned
#
# To set each time you run this script (http://stackoverflow.com/a/16141428/516433):
#   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

$setup_exe = "setup-x86_64.exe"
$url = "https://cygwin.com/$setup_exe"
$path = "$env:userprofile\Downloads\$setup_exe"
      
"Downloading [$url]`nSaving at [$path]" 
$client = new-object System.Net.WebClient 
$client.DownloadFile($url, $path) 

$packages = $(
    "autoconf",
    "cron",
    "crypt",
    "curl",
    "dos2unix",
    "gcc-core",
    "gcc-g++",
    "gettext-devel",
    "git",
    "gnupg",
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
) -join ','

$args = $(
    "--quiet-mode",
    "--upgrade-also",
    "--root", "C:\cygwin64",
    "--site", "http://cygwin.mirrors.hoobly.com"
    "--packages", $packages
)

"Running [$path $args]"

& "$path" $args

"Done!"
