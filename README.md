# Off-CCD (OCCD) 🚀
#### 由Gemini编写
[**中文**](#中文说明) | [**English**](#english-description)

---

## 中文说明

**Off-CCD (OCCD)** 是一个专为 AMD 锐龙 (Ryzen) 处理器用户设计的轻量级进程管理工具，基于 **AutoHotkey v2** 编写。它能通过优化 CPU 核心分配和进程优先级，有效降低跨 CCD 延迟，提升游戏性能。

### 🌟 为什么选择 OCCD？
在多 CCD 的 AMD 处理器（如 5900X, 7950X 等）上，进程跨 CCD 访问内存会显著增加延迟。OCCD 允许你将游戏固定在性能最好的 CCD 上，并将后台杂项任务隔离到另一个 CCD，确保游戏获得最纯净的计算资源。

### ✨ 功能特性
- **AMD CCD 优化**：针对 12/16 核心处理器优化。例如在 16 线程处理器上，一键将任务绑定至 **CCD1 (核心 8-15)**，规避系统对 CCD0 的占用。
- **核心 0 (Core 0) 独立控制**：支持独立开启或屏蔽 Core 0。屏蔽 Core 0 可减少系统中断（Interrupts）带来的抖动，提升帧数稳定性。
- **禁用超线程 (SMT)**：强制进程仅在物理核心上运行，极大提升单核响应速度。
- **自动优先级管理**：自动将目标进程设为“高优先级”，确保 CPU 资源优先调度。
- **智能进程识别**：
  - **首字母过滤**：输入框支持按**首字母起始匹配**实时筛选系统中运行的进程，方便快速选择。
  - **策略记忆回填**：手动输入或下拉选中已配置的程序名，界面会自动同步该程序保存的打勾状态。
- **全自动化后台巡检**：
  - 基于 **WMI** 引擎，支持识别所有后台进程，无需目标程序拥有窗口。
  - **多实例处理**：支持同时修改同一程序的所有子进程（如 QQ.exe 的所有实例）。
- **极致轻量**：体积约 1MB，内存占用极低，绿色免安装。

### 🎮 预设模式
- **竞技模式**：一键启用 **“禁用超线程”** + **“高优先级”**（其他项自动取消）。
- **后台负载**：一键启用 **“含核心 0”** + **“绑 CCD1”**，将杂项任务隔离开。

### 🛠️ 使用方法
1. **环境**：安装 [AutoHotkey v2.0+](https://www.autohotkey.com/)。
2. **权限**：必须**以管理员身份运行**，否则无法操作其他进程。
3. **操作**：输入程序名（支持首字母筛选），配置策略后点击“保存配置”。

---

## English Description

**Off-CCD (OCCD)** is a lightweight process affinity and priority management utility specifically designed for **AMD Ryzen** users, built with **AutoHotkey v2**. It optimizes CPU core distribution to minimize cross-CCD latency penalties.

### 🌟 Why OCCD?
On multi-CCD AMD processors (e.g., 5900X, 7950X), cross-CCD communication introduces significant latency. OCCD helps you pin games to a specific CCD while isolating background tasks to the other, ensuring peak gaming performance.

### ✨ Key Features
- **AMD CCD Optimization**: Tailored for 12/16 core CPUs. For instance, on a 16-thread CPU, bind tasks to **CCD1 (Cores 8-15)** to bypass system interference on CCD0.
- **Core 0 Control**: Independent toggle to include or exclude Core 0. Excluding Core 0 helps reduce jitter caused by system interrupts.
- **Disable SMT**: Force processes to run on physical cores only for maximum single-thread responsiveness.
- **Priority Management**: Automatically sets target processes to "High Priority" for better scheduling.
- **Intelligent Recognition**:
  - **Prefix Filtering**: Real-time process filtering via "Starts-with" logic in the input box for quick selection.
  - **Policy Auto-Sync**: Automatically restores previous settings when a known process is typed or selected.
- **Automated Background Monitor**:
  - **WMI Powered**: Detects all processes including those without active windows.
  - **Multi-Instance Support**: Handles all instances/child processes of programs like QQ or Chrome simultaneously.
- **Ultra Lightweight**: Minimal footprint (~1MB EXE), portable, and no installation required.

### 🎮 Presets
- **Gaming Mode**: One-click to enable **"Disable SMT"** and **"High Priority"**.
- **Background Load**: One-click to enable **"Incl Core 0"** and **"Bind CCD1"** to isolate auxiliary tasks.

### 🛠️ Getting Started
1. **Requirement**: [AutoHotkey v2.0+](https://www.autohotkey.com/) is required.
2. **Permission**: Must **Run as Administrator** to modify other processes.
3. **Usage**: Type/select a process, check desired policies, and click "Save Config".

---

### 📄 License
This project is licensed under the **MIT License**.
