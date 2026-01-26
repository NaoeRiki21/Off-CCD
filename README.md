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
- 策略预设：
  - 竞技模式：禁用超线程 (SMT) + 高优先级。
  - 后台负载：含核心 0 + 绑定 CCD1，将干扰任务彻底隔离。

### 使用说明
1. 下载运行：从 Releases 下载 Off-CCD.exe。
2. 管理员权限：必须右键选择“以管理员身份运行”，否则程序无权修改其他进程的相关性。
3. 配置进程：
   - 在“目标程序”输入框开始输入，列表会根据首字母自动筛选当前运行的进程。
   - 选中目标后，勾选需要的核心策略或直接点击预设按钮。
   - 点击“保存配置”，该策略即刻生效并存入本地配置文件。
4. 后台运行：
   - 建议在菜单栏“设置”中开启“开机自启动”和“静默启动”。
   - 开启后，程序会最小化至托盘并在后台自动维护所有已保存的进程策略。

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
- Strategy Presets:
  - Gaming Mode: Disable SMT + High Priority.
  - Background Load: Include Core 0 + Bind CCD1 to isolate auxiliary tasks.

### Instructions
1. Download: Get the latest Off-CCD.exe from the Releases page.
2. Admin Rights: You must right-click and select "Run as Administrator" to grant the utility permission to modify process affinity.
3. Configure Processes:
   - Start typing in the "Target Process" box; the list will automatically filter running processes based on your input.
   - Select your target, check the desired affinity options, or use a preset button.
   - Click "Save Config" to apply the strategy and save it to the local configuration file.
4. Background Operation:
   - It is recommended to enable "Start on Boot" and "Silent Start" in the Settings menu.
   - Once configured, the app will run in the tray and automatically maintain saved policies for you.

---

## License
MIT License
