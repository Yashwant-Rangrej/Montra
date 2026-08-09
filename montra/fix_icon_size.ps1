Add-Type -AssemblyName System.Drawing
$sourcePath = "c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res\drawable\app_logo.png"

$img = [System.Drawing.Image]::FromFile($sourcePath)
$resized = New-Object System.Drawing.Bitmap(144, 144)
$g = [System.Drawing.Graphics]::FromImage($resized)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, 0, 0, 144, 144)
$img.Dispose()

# Save over the old file
$resized.Save($sourcePath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$resized.Dispose()
Write-Host "Resized app_logo.png to 144x144 to prevent IPC crash."
