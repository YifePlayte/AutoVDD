# AutoVDD for Sunshine

此脚本项目可以使 VirtualDisplayDriver 随着 Sunshine 的串流自动启动/停止虚拟显示器，且能够自动设置虚拟显示器的分辨率和帧率

## VirtualDisplayDriver 配置

- 安装最新版 Powershell 7

- 下载 [VirtualDisplayDriver](https://github.com/VirtualDrivers/Virtual-Display-Driver) 的 v24.12.24 版本 (仅需Signed-Driver-v24.12.24-x64.zip) (其他版本未经测试，理论可行)

- 在C盘根目录新建 `VirtualDisplayDriver` 文件夹，将以上压缩包内驱动文件解压至此 (必须！不能更改为其他文件夹) (注：驱动已支持任意位置安装，但未经测试是否与此脚本兼容，若想尝试，请自行修改路径)

- 右键 `MttVDD.inf` ，安装 (注意！此处与 `VirtualDisplayDriver` 官方推荐的安装方式不同)

- 将 `AutoVDD` 文件夹 (即本脚本所在文件夹) 放在 `VirtualDisplayDriver` 文件夹内 (必须！不能更改为其他文件夹)

- 将 `AutoVDD` 文件夹内的 `vdd_settings.xml` 替换到 `VirtualDisplayDriver` 文件夹下 (必须！或者保证 `vdd_settings.xml` 内，`resolutions` 内只有一组 `resolution` ，且其内部只有一组 `refresh_rate`)

## Sunshine 配置

在 `配置 - General - 命令准备工作` 中添加一条 (需要勾选以管理员身份运行) :

启动前:

```cmd
pwsh.exe -executionpolicy bypass -WindowStyle Hidden -file "C:\VirtualDisplayDriver\AutoVDD\AutoVDDStarter.ps1"
```

启动后:

```cmd
pwsh.exe -executionpolicy bypass -WindowStyle Hidden -file "C:\VirtualDisplayDriver\AutoVDD\AutoVDDKiller.ps1"
```
