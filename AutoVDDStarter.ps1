# 获取脚本路径
$filePath = $($MyInvocation.MyCommand.Path)
$scriptRoot = Split-Path $filePath -Parent

# 日志文件路径
$logFile = Join-Path $scriptRoot "script_log.txt"

# 开始日志记录
# Start-Transcript -Path $logFile -Append

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

# === 设置分辨率：内嵌 changeres-VDD 功能 ===
& {
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias("X", "HorizontalResolution")]
        [int]$xres,
        [Parameter(Mandatory, Position=1)]
        [Alias("Y", "VerticalResolution")]
        [int]$yres
    )

    Write-Output "Checking module dependencies..."

    $repo = @{ Name = "PSGallery"; Url = "https://www.powershellgallery.com/api/v2" }
    $modules = @(
        @{ Name = "DisplayConfig"; Version = "1.1.1" },
        @{ Name = "MonitorConfig"; Version = "1.0.3" }
    )

    foreach ($mod in $modules) {
        if (Get-Module -Name $mod.Name) { 
            Write-Output "$($mod.Name) is imported."
            continue
        } elseif (Get-Module -ListAvailable -Name $mod.Name) {
            Write-Output "$($mod.Name) is installed but not imported: import."
            Import-Module -Name $mod.Name -Force
        } else {
            # Check if the repository is registered
            if (-not (Get-PSRepository -Name $repo.Name -ErrorAction SilentlyContinue)) {
                Write-Host "PSRepository '$($repo.Name)' cannot be found. Make sure it is available."
                exit 0
            }

            # Trust the repository (this sets the installation policy to Trusted)
            Set-PSRepository -Name $repo.Name -InstallationPolicy Trusted `
                -InformationAction Ignore -WarningAction SilentlyContinue

            # If the module is not on disk, check if it's available in the online gallery
            if (Find-Module -Name $mod.Name -ErrorAction SilentlyContinue) {
                Write-Output "$($mod.Name) is available online, but not installed or imported: install and import."
                # Install the module (specifying the required version)
                Install-Module -Name $mod.Name -RequiredVersion $mod.Version `
                    -Force -Scope CurrentUser -AllowClobber
    
                # Import the module after installation
                Import-Module $mod.Name
            } else {
                # If the module cannot be found in the online gallery, abort the script.
                Write-Output "Module '$($mod.Name)' is not imported, not available on disk, and not found in the online gallery. Cannot run the script."
                exit 0
            }

            # Save Module for later use
            if (-not (Get-InstalledModule -Name $mod.Name -MinimumVersion $mod.Version -ErrorAction SilentlyContinue)) {
                Write-Output "Saving module $($mod.Name)."
                Save-Module -Name $mod.Name -Repository $repo.Name -RequiredVersion $mod.Version `
                    -Confirm:$false -InformationAction Ignore -WarningAction SilentlyContinue
            }
        }
    }

    $disp = Get-DisplayInfo | Where-Object { $_.DisplayName -eq "VDD by MTT" }

    if ($null -eq $disp) {
        Write-Error "No 'VDD by MTT' Found."
        exit 0
    }

    Set-DisplayResolution -DisplayId $disp.DisplayId -Width $xres -Height $yres
} -xres $width -yres $height
