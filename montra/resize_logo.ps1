Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("c:\Users\ATS-L15\Desktop\Montra\montra\assets\images\logo.png")

# Small icon (96x96)
$small = New-Object System.Drawing.Bitmap(96, 96)
$gSmall = [System.Drawing.Graphics]::FromImage($small)
$gSmall.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gSmall.DrawImage($img, 0, 0, 96, 96)
$small.Save("c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res\drawable\logo_small.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Large icon (192x192)
$large = New-Object System.Drawing.Bitmap(192, 192)
$gLarge = [System.Drawing.Graphics]::FromImage($large)
$gLarge.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gLarge.DrawImage($img, 0, 0, 192, 192)
$large.Save("c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res\drawable\logo_large.png", [System.Drawing.Imaging.ImageFormat]::Png)

$gSmall.Dispose()
$gLarge.Dispose()
$small.Dispose()
$large.Dispose()
$img.Dispose()
