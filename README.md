# Off-CCD (OCCD)

This project's core code was developed with the assistance of Google Gemini.
本项目核心代码由 Google Gemini 协作编写。

[中文说明](#中文说明) | [English Description](#english-description)

---

## 中文说明

Off-CCD (OCCD) 是一款基于 AutoHotkey v2 的轻量级 CPU 相关性与优先级管理工具。它专为追求极致性能的玩家设计，特别是针对 AMD 多 CCD 架构进行了深度优化。

### 为什么选择 OCCD？
相比于功能复杂、资源占用较高的 Process Lasso，OCCD 具有以下优势：
- 极低占用：体积仅约 1MB，运行内存极低，无多余后台服务。
- 极速交互：无需繁琐规则，输入框支持首字母起始匹配，自动识别运行进程。
- 硬件优化：专为 AMD 处理器设计，一键绑定 CCD1 核心（如 16 线程处理器的核心 8-15），有效降低跨 CCD 延迟。

### 核心功能
- 智能识别：实时感知系统运行进程，支持模糊筛选，选中即自动加载历史策略。
- 自动化处理：支持处理同名多进程（如 QQ、Chrome 的所有子进程），每 3 秒循环巡检。
- 自定义预设槽位：
  - 提供 3 个类似微星 Afterburner 的预设槽位，左键读取，右键保存或重命名。
- 系统核心保护：禁止修改 explorer.exe 等关键系统进程，防止因 Windows 继承机制导致所有程序被错误限制。
- 真正静默自启：通过计划任务实现开机静默且最高权限自启，彻底告别 UAC 弹窗烦恼。

### 使用说明
1. 下载运行：从 Releases 下载 Off-CCD.exe。(报毒忽略即可)
2. 自动提权：直接双击运行即可，程序会自动请求所需的管理员权限。
3. 配置进程：
   - 在“目标程序”输入框开始输入，列表会根据首字母自动筛选当前运行的进程。
   - 选中目标后，勾选需要的核心分配策略。
   - 鼠标右键点击任意“预设”按钮可将当前配置存入槽位并可重命名；鼠标左键点击即可快速读取预设。
4. 后台运行：
   - 建议在菜单栏“设置”中开启“开机自启动”和“静默启动”。
   - 提示：如果您同时开启了“静默启动”和“隐藏托盘图标”，只需再次手动双击运行一次 `Off-CCD` 程序，即可强制呼出主界面。

### 卸载与还原
本程序为纯净绿色软件，对 CPU 核心的修改仅在内存中即时生效。如需彻底卸载：
1. 在程序的“设置”菜单中，**取消勾选“开机自启动”**（这会自动清除系统的计划任务）。
2. 在“设置”菜单中点击“退出”彻底关闭程序。
3. **重启电脑**（重启后，所有被修改过核心的程序都会自动恢复为 Windows 默认的全核心调度，不留任何后遗症）。
   - *（可选）如果您不想重启电脑，也可以右键使用 PowerShell 运行项目中提供的 `Reset-Affinity.ps1` 脚本，即可一键强制将所有运行中的程序恢复为全核心默认状态。*
4. 删除存放目录下的 `Off-CCD.exe` 和 `ProcessConfig.ini` 文件即可。

---

## English Description

Off-CCD (OCCD) is a lightweight CPU affinity and priority manager built with AutoHotkey v2. It is optimized for performance enthusiasts, featuring specialized logic for AMD multi-CCD architectures.

### Why OCCD?
Compared to the resource-heavy Process Lasso, OCCD offers:
- Ultra-Low Overhead: ~1MB executable, minimal RAM usage, no unnecessary background services.
- Faster Interaction: No complex rules required. The input box supports prefix matching to identify running processes instantly.
- Hardware Optimized: Tailored for AMD CPUs. Bind tasks to CCD1 (e.g., Cores 8-15 on 16-thread CPUs) with one click to eliminate cross-CCD latency.

### Key Features
- Smart Recognition: Real-time detection of running processes. Filters as you type and restores saved policies upon selection.
- Full Automation: Handles multi-instance programs (e.g., all child processes of QQ or Chrome) via WMI scanning every 3 seconds.
- Custom Presets (Afterburner Style):
  - 3 customizable slots. Left-click to load, Right-click to save or rename.
- System Process Protection: Prevents modifying core affinity for critical processes (like explorer.exe) to avoid unwanted inheritance to all child programs.
- True Silent Auto-Start: Uses Task Scheduler to auto-run on boot with highest privileges, bypassing UAC prompts entirely.

### Instructions
1. Download: Get the latest Off-CCD.exe from the Releases page.
2. Auto-Elevation: Double-click to run. It will automatically request administrator privileges needed to modify process affinities.
3. Configure Processes:
   - Start typing in the "Target Process" box; the list will automatically filter running processes.
   - Select your target, check the desired affinity options.
   - Right-click any Preset button to save your configuration to that slot, or Left-click to load a saved preset.
4. Background Operation:
   - Enable "Start on Boot" and "Silent Start" in the Settings menu for fully automatic background operation.
   - Tip: If you enable "Silent Start" and "Hide Tray Icon" simultaneously, simply double-click the `Off-CCD` program again to force the interface to show.

### Uninstallation & Reset
This is a portable application. CPU affinity changes are temporary and exist only in memory. To completely remove the app and revert all changes:
1. Open the app, go to the "Settings" menu, and **uncheck "Start on Boot"** (this automatically removes the Scheduled Task).
2. Click "Exit" in the "Settings" menu to completely close the program.
3. **Restart your computer** (rebooting clears the memory and resets all CPU affinities back to Windows defaults).
   - *(Optional) If you don't want to restart your computer, you can right-click and "Run with PowerShell" the included `Reset-Affinity.ps1` script to instantly reset all running programs to their default state.*
4. Delete the `Off-CCD.exe` executable and the generated `ProcessConfig.ini` configuration file.

---

## License
MIT License
