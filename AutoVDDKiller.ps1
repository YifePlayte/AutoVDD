$filePath = $($MyInvocation.MyCommand.Path)
$scriptRoot = Split-Path $filePath -Parent

# 定义可执行文件路径
$executablePath = "$scriptRoot\MttVDDApp.exe"

# 获取进程名称（不包括扩展名）
$processName = (Get-Item $executablePath).BaseName

# 终止可执行文件的运行
Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
