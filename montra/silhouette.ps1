Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile("c:\Users\ATS-L15\Desktop\Montra\montra\assets\images\logo.png")
$bmp = New-Object System.Drawing.Bitmap($img.Width, $img.Height)
for ($y = 0; $y -lt $img.Height; $y++) {
    for ($x = 0; $x -lt $img.Width; $x++) {
        $p = $img.GetPixel($x, $y)
        if ($p.A -gt 0) {
            $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($p.A, 255, 255, 255))
        } else {
            $bmp.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}
$bmp.Save("c:\Users\ATS-L15\Desktop\Montra\montra\android\app\src\main\res\drawable\ic_notification.png", [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
$bmp.Dispose()
