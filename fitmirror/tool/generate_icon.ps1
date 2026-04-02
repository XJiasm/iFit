Add-Type -AssemblyName System.Drawing

$size = 1024
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# 小红书红色 #FF2D55
$xhsRed = [System.Drawing.Color]::FromArgb(255, 45, 85)

# 填充红色背景
$redBrush = New-Object System.Drawing.SolidBrush($xhsRed)
$graphics.FillRectangle($redBrush, 0, 0, $size, $size)

# 白色画刷
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

# 绘制简约的裙子图标 (居中)
# 裙子主体 - 简单的梯形
$dressPoints = @(
    [System.Drawing.Point]::new(380, 280),
    [System.Drawing.Point]::new(644, 280),
    [System.Drawing.Point]::new(720, 700),
    [System.Drawing.Point]::new(304, 700)
)
$graphics.FillPolygon($whiteBrush, $dressPoints)

# 裙子上的斜线装饰 (简约设计感)
$linePen = New-Object System.Drawing.Pen($xhsRed, 12)
$graphics.DrawLine($linePen, 400, 350, 540, 650)
$graphics.DrawLine($linePen, 480, 350, 620, 650)

# 裙子上方的圆点 (代表上衣/领口)
$graphics.FillEllipse($whiteBrush, 480, 200, 64, 64)

# 保存主图标
$bitmap.Save("C:\Users\Buding\.local\bin\iFit\fitmirror\assets\images\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 创建 foreground 图标 (用于 adaptive icon)
$fgBitmap = New-Object System.Drawing.Bitmap($size, $size)
$fgGraphics = [System.Drawing.Graphics]::FromImage($fgBitmap)
$fgGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# 绘制裙子图标 (红色)
$redBrushFg = New-Object System.Drawing.SolidBrush($xhsRed)

# 裙子主体
$fgGraphics.FillPolygon($redBrushFg, $dressPoints)

# 裙子上的斜线装饰
$whiteLinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 12)
$fgGraphics.DrawLine($whiteLinePen, 400, 350, 540, 650)
$fgGraphics.DrawLine($whiteLinePen, 480, 350, 620, 650)

# 圆点
$fgGraphics.FillEllipse($redBrushFg, 480, 200, 64, 64)

$fgBitmap.Save("C:\Users\Buding\.local\bin\iFit\fitmirror\assets\images\app_icon_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)

# 清理
$graphics.Dispose()
$bitmap.Dispose()
$fgGraphics.Dispose()
$fgBitmap.Dispose()

Write-Host "小红书风格图标创建成功！" -ForegroundColor Green
