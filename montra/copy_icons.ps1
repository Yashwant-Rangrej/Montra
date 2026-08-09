$src = "c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res\drawable\ic_notification.png"
$resDir = "c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res"
$dirs = Get-ChildItem -Path $resDir -Directory -Filter "mipmap-*"

foreach ($dir in $dirs) {
    Copy-Item -Path $src -Destination "$($dir.FullName)\ic_notification.png" -Force
}
