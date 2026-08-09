$logoPath = "c:\Users\ATS-L15\Desktop\Montra\montra\assets\images\logo.png"
$resDir = "c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res"

# Overwrite app_icon.png in drawable with the real colored logo
Copy-Item -Path $logoPath -Destination "$resDir\drawable\.png" -Force

# Overwrite all ic_launcher.png (the flutter default icons) with the real colored logo
$mipmapDirs = Get-ChildItem -Path $resDir -Directory -Filter "mipmap-*"
foreach ($dir in $mipmapDirs) {
    Copy-Item -Path $logoPath -Destination "$($dir.FullName)\ic_launcher.png" -Force
}
