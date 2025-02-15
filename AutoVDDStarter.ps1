$filePath = $($MyInvocation.MyCommand.Path)
$scriptRoot = Split-Path $filePath -Parent

# 定义可执行文件路径
$executablePath = "$scriptRoot\MttVDDApp.exe"

# 定义延迟时间（秒）
$delayInSeconds = 1

# 获取进程名称（不包括扩展名）
$processName = (Get-Item $executablePath).BaseName

# 更新 vdd_settings.xml 文件的路径
$vddSettingsFilePath = (Join-Path (Split-Path $scriptRoot -Parent) 'vdd_settings.xml')

# 解析 XML 文件
[xml]$xml = Get-Content -Path $vddSettingsFilePath

# 更新分辨率值
$width = $env:SUNSHINE_CLIENT_WIDTH
$height = $env:SUNSHINE_CLIENT_HEIGHT
$refreshRate = $env:SUNSHINE_CLIENT_FPS

# 获取 <resolution> 节点并更新值
$resolutionNode = $xml.vdd_settings.resolutions.resolution
$resolutionNode.width = $width
$resolutionNode.height = $height
$resolutionNode.refresh_rate = $refreshRate

# 保存修改后的 XML 文件
$xml.Save($vddSettingsFilePath)

# 检查可执行文件是否已经在运行
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue
if (-not $process) {
    # 如果进程不存在，则运行可执行文件
    Start-Process -FilePath $executablePath -WindowStyle Hidden
    # 等待
    Start-Sleep -Seconds $delayInSeconds
}
