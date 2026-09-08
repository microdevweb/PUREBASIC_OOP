param (
    [string]$ExePath = "c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\demo_canvas_mvvm.exe",
    [string]$OutputPath = "c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\screenshot_demo.png",
    [int]$WaitMs = 1500
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$proc = Start-Process -FilePath $ExePath -PassThru
Start-Sleep -Milliseconds $WaitMs

$bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$bmp = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
$bmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bmp.Dispose()

if ($proc -and -not $proc.HasExited) {
    Stop-Process -Id $proc.Id -Force
}

Write-Output "Screenshot successfully saved to: $OutputPath"
