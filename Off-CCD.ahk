#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ==============================================================================
; 全局变量与环境初始化
; ==============================================================================
global AppName := "Off-CCD 核心分配"
global IniFile := "ProcessConfig.ini"
global TotalThreads := Integer(EnvGet("NUMBER_OF_PROCESSORS"))
global Lang := Map()
global Settings := {AutoStart: 0, Silent: 0, HideTray: 0, Language: "zh"}
global MasterProcList := [] 
global LastFilteredCount := 0 
global CustomMode := 0 

InitLanguage(l) {
    if (l == "zh") {
        Lang["AutoStart"] := "开机自启动", Lang["SilentStart"] := "静默启动", Lang["HideTray"] := "隐藏托盘图标"
        Lang["Settings"] := "设置", Lang["Lang"] := "语言", Lang["Target"] := "目标程序:"
        Lang["Core0"] := "含核心0", Lang["CCD0"] := "仅CCD0", Lang["CCD1"] := "仅CCD1"
        Lang["SMT"] := "禁用超线程", Lang["HighPri"] := "高优先级"
        Lang["GameMode"] := "竞技模式", Lang["BgLoad"] := "后台负载", Lang["Custom"] := "自定义核心", Lang["Save"] := "保存配置"
        Lang["Show"] := "显示界面", Lang["Exit"] := "退出"
    } else {
        Lang["AutoStart"] := "Start on Boot", Lang["SilentStart"] := "Silent Start", Lang["HideTray"] := "Hide Tray Icon"
        Lang["Settings"] := "Settings", Lang["Lang"] := "Language", Lang["Target"] := "Target Process:"
        Lang["Core0"] := "Incl Core0", Lang["CCD0"] := "Only CCD0", Lang["CCD1"] := "Only CCD1"
        Lang["SMT"] := "Disable SMT", Lang["HighPri"] := "High Priority"
        Lang["GameMode"] := "Gaming Mode", Lang["BgLoad"] := "Background Load", Lang["Custom"] := "Custom Cores", Lang["Save"] := "Save Config"
        Lang["Show"] := "Show UI", Lang["Exit"] := "Exit"
    }
}

InitLanguage("zh")

if FileExist(IniFile) {
    try {
        Settings.Silent := Integer(IniRead(IniFile, "Global", "Silent", 0))
        Settings.HideTray := Integer(IniRead(IniFile, "Global", "HideTray", 0))
        Settings.Language := IniRead(IniFile, "Global", "Language", "zh")
        InitLanguage(Settings.Language)
    }
}

; ==============================================================================
; GUI 构建
; ==============================================================================
MyGui := Gui("+AlwaysOnTop", AppName)
MyGui.OnEvent("Close", (*) => MyGui.Hide())

; 菜单
Menus := MenuBar()
SetMenu := Menu()
SetMenu.Add(Lang["AutoStart"], ToggleAutoStart)
try {
    RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", AppName)
    Settings.AutoStart := 1
    SetMenu.Check(Lang["AutoStart"])
} catch {
    Settings.AutoStart := 0
}

SetMenu.Add(Lang["SilentStart"], ToggleSilent)
if (Settings.Silent == 1) {
    SetMenu.Check(Lang["SilentStart"])
}
SetMenu.Add(Lang["HideTray"], ToggleTray)
if (Settings.HideTray == 1) {
    SetMenu.Check(Lang["HideTray"])
    A_IconHidden := true
}

LangMenu := Menu()
LangMenu.Add("中文", (*) => ChangeLang("zh"))
LangMenu.Add("English", (*) => ChangeLang("en"))
Menus.Add(Lang["Settings"], SetMenu)
Menus.Add(Lang["Lang"], LangMenu)
MyGui.MenuBar := Menus

MyGui.SetFont("s10", "Microsoft YaHei")
MyGui.Add("Text", "w80", Lang["Target"])

; 下拉框
MasterProcList := GetCombinedProcessList()
ProgCombo := MyGui.Add("ComboBox", "vProgName x+10 w260", MasterProcList)
ProgCombo.OnEvent("Change", HandleProgChange)

; 第一行开关：CCD选择
CheckCCD0  := MyGui.Add("Checkbox", "vCCD0 xm y+20", Lang["CCD0"])
CheckCCD1  := MyGui.Add("Checkbox", "vCCD1 x+20", Lang["CCD1"])
; 第二行开关：功能选项
CheckCore0 := MyGui.Add("Checkbox", "vCore0 x+20", Lang["Core0"])
CheckSMT   := MyGui.Add("Checkbox", "vSMT x+20", Lang["SMT"])
CheckHigh  := MyGui.Add("Checkbox", "vHigh xm y+10", Lang["HighPri"]) ; 换行显示更清晰
CustomMode := 0

for ctrl in [CheckCore0, CheckCCD0, CheckCCD1, CheckSMT] {
    ctrl.OnEvent("Click", UpdateMaskDisplay)
}

BtnGame := MyGui.Add("Button", "xm y+20 w120 h40", Lang["GameMode"])
BtnGame.OnEvent("Click", SetGamePreset)
BtnBack := MyGui.Add("Button", "x+10 w120 h40", Lang["BgLoad"])
BtnBack.OnEvent("Click", SetBgPreset)
BtnCustom := MyGui.Add("Button", "x+10 w120 h40", "低占用")
BtnCustom.OnEvent("Click", SetCustomPreset)

MyGui.SetFont("s12 Bold cBlue", "Microsoft YaHei")
MaskText := MyGui.Add("Text", "xm y+20 w380 Center", "Mask: 0xFFFFFFFF")
MyGui.SetFont("s10 Norm cDefault", "Microsoft YaHei")

BtnSave := MyGui.Add("Button", "xm y+15 w380 h45 Default", Lang["Save"])
BtnSave.OnEvent("Click", SaveConfig)

; 托盘
A_TrayMenu.Delete()
A_TrayMenu.Add(Lang["Show"], (*) => (RefreshMasterList(), MyGui.Show()))
A_TrayMenu.Add(Lang["Exit"], (*) => ExitApp())
A_TrayMenu.Default := Lang["Show"]

if (Settings.Silent == 0) {
    MyGui.Show()
}

SetTimer(ProcessMonitor, 3000)

; ==============================================================================
; 逻辑处理：筛选与交互
; ==============================================================================

HandleProgChange(GuiCtrl, *) {
    static IsProcessing := false
    if (IsProcessing)
        return
    IsProcessing := true

    userInput := GuiCtrl.Text
    uLen := StrLen(userInput)
    
    ; 1. 首字母筛选
    filtered := []
    if (userInput != "") {
        for name in MasterProcList {
            if (SubStr(name, 1, uLen) = userInput) {
                filtered.Push(name)
            }
        }
    } else {
        filtered := MasterProcList
    }
    
    global LastFilteredCount
    if (filtered.Length != LastFilteredCount) {
        GuiCtrl.Delete()
        if (filtered.Length > 0) {
            GuiCtrl.Add(filtered)
            if (!SendMessage(0x0157, 0, 0, GuiCtrl.Hwnd)) {
                SendMessage(0x014F, 1, 0, GuiCtrl.Hwnd) 
            }
        }
        LastFilteredCount := filtered.Length
    }
    
    GuiCtrl.Text := userInput 
    SendMessage(0x0142, 0, (uLen << 16) | uLen, GuiCtrl.Hwnd) 
    
    ; 2. 识别历史策略
    try {
        global CustomMode
        customMode := Integer(IniRead(IniFile, userInput, "CustomMode", 0))
        if (customMode == 1) {
            CustomMode := 1
            tMask := (1 << 0) | (1 << (TotalThreads - 1))
            MaskText.Value := "Mask: 0x" . Format("{:08X}", tMask)
            CheckCore0.Value := 0
            CheckCCD0.Value := 0
            CheckCCD1.Value := 0
            CheckSMT.Value := 0
            CheckHigh.Value := Integer(IniRead(IniFile, userInput, "High", 0))
        } else {
            CustomMode := 0
            CheckCore0.Value := Integer(IniRead(IniFile, userInput, "Core0", 1))
            CheckCCD0.Value  := Integer(IniRead(IniFile, userInput, "CCD0", 0))
            CheckCCD1.Value  := Integer(IniRead(IniFile, userInput, "CCD1", 0))
            CheckSMT.Value   := Integer(IniRead(IniFile, userInput, "SMT", 0))
            CheckHigh.Value  := Integer(IniRead(IniFile, userInput, "High", 0))
            UpdateMaskDisplay()
        }
    }
    
    UpdateMaskDisplay()
    IsProcessing := false
}

GetCombinedProcessList() {
    Combined := Map()
    try {
        secs := IniRead(IniFile)
        Loop Parse, secs, "`n" {
            if (A_LoopField != "Global" && A_LoopField != "") {
                Combined[A_LoopField] := 1
            }
        }
    }
    try {
        wmi := ComObjGet("winmgmts:")
        for proc in wmi.ExecQuery("Select Name from Win32_Process") {
            Combined[proc.Name] := 1
        }
    }
    List := []
    for name, _ in Combined {
        List.Push(name)
    }
    return List
}

RefreshMasterList() {
    global MasterProcList := GetCombinedProcessList()
    curr := ProgCombo.Text
    ProgCombo.Delete()
    ProgCombo.Add(MasterProcList)
    ProgCombo.Text := curr
}

; ==============================================================================
; 核心 Mask 运算逻辑 (更新双CCD逻辑)
; ==============================================================================

CalculateMask(c0, ccd0, ccd1, smt) {
    half := TotalThreads // 2
    mask := 0
    
    ; 1. CCD 基础选区
    if (ccd0 == 1) {
        ; 累加前半部分核心
        mask |= ((1 << half) - 1)
    }
    if (ccd1 == 1) {
        ; 累加后半部分核心
        mask |= (((1 << half) - 1) << half)
    }
    
    ; 如果都没选(或都选了导致溢出)，默认全选
    if (mask == 0) {
        mask := (1 << TotalThreads) - 1
    }
    
    ; 2. 核心0 独立控制 (最高优先级)
    if (c0 == 1) {
        mask |= 1   ; 强制点亮 Core 0
    } else {
        mask &= ~1  ; 强制熄灭 Core 0
    }
    
    ; 3. 禁用超线程 (保留偶数位)
    if (smt == 1) {
        smt_mask := 0
        Loop (TotalThreads // 2) {
            smt_mask |= (1 << ((A_Index - 1) * 2))
        }
        mask &= smt_mask
    }
    
    return (mask == 0) ? 1 : mask
}

UpdateMaskDisplay(*) {
    mask := CalculateMask(CheckCore0.Value, CheckCCD0.Value, CheckCCD1.Value, CheckSMT.Value)
    MaskText.Value := "Mask: 0x" . Format("{:08X}", mask)
}

ProcessMonitor() {
    sections := ""
    try {
        sections := IniRead(IniFile)
    } catch {
        return
    }
    if (sections == "") {
        return
    }
    
    wmi := ComObjGet("winmgmts:")
    Loop Parse, sections, "`n" {
        procName := A_LoopField
        if (procName == "Global" || procName == "") {
            continue
        }
        
        processes := wmi.ExecQuery("Select ProcessId from Win32_Process Where Name = '" . procName . "'")
        if (processes.Count > 0) {
            try {
                customMode := Integer(IniRead(IniFile, procName, "CustomMode", 0))
                hi := Integer(IniRead(IniFile, procName, "High", 0))
                if (customMode == 1) {
                    tMask := 0
                    tMask |= 1
                    tMask |= (1 << (TotalThreads - 1))
                } else {
                    c0 := Integer(IniRead(IniFile, procName, "Core0", 1))
                    cd0 := Integer(IniRead(IniFile, procName, "CCD0", 0))
                    cd1 := Integer(IniRead(IniFile, procName, "CCD1", 0))
                    sm := Integer(IniRead(IniFile, procName, "SMT", 0))
                    tMask := CalculateMask(c0, cd0, cd1, sm)
                }
                
                for proc in processes {
                    try {
                        if (customMode == 1) {
                            ProcessSetPriority("Low", proc.ProcessId)
                        } else {
                            ProcessSetPriority((hi ? "High" : "Normal"), proc.ProcessId)
                        }
                    }
                    hProc := DllCall("OpenProcess", "UInt", 0x0400 | 0x0200 | 0x0040, "Int", false, "UInt", proc.ProcessId, "Ptr")
                    if (hProc) {
                        DllCall("SetProcessAffinityMask", "Ptr", hProc, "Ptr", tMask)
                        DllCall("CloseHandle", "Ptr", hProc)
                    }
                }
            }
        }
    }
}

; ==============================================================================
; 预设与动作
; ==============================================================================

SaveConfig(*) {
    name := ProgCombo.Text
    if (name == "") {
        return
    }
    global CustomMode
    IniWrite(CheckCore0.Value, IniFile, name, "Core0")
    IniWrite(CheckCCD0.Value,  IniFile, name, "CCD0")
    IniWrite(CheckCCD1.Value,  IniFile, name, "CCD1")
    IniWrite(CheckSMT.Value,   IniFile, name, "SMT")
    IniWrite(CheckHigh.Value,  IniFile, name, "High")
    IniWrite(CustomMode, IniFile, name, "CustomMode")
    CustomMode := 0
    RefreshMasterList()
}

SetGamePreset(*) {
    ; 游戏模式：仅CCD0 + 关闭SMT + 高优先级 + (通常游戏不含核心0)
    CheckCore0.Value := 0
    CheckCCD0.Value := 1
    CheckCCD1.Value := 0
    CheckSMT.Value := 1
    CheckHigh.Value := 1
    UpdateMaskDisplay()
}

SetBgPreset(*) {
    ; 后台负载：含核心0 + 仅CCD1 + (保留SMT以增强多任务)
    CheckCore0.Value := 1
    CheckCCD0.Value := 0
    CheckCCD1.Value := 1
    CheckSMT.Value := 0
    CheckHigh.Value := 0
    UpdateMaskDisplay()
}

SetCustomPreset(*) {
    global CustomMode := 1
    mask := 0
    mask |= 1
    mask |= (1 << (TotalThreads - 1))
    MaskText.Value := "Mask: 0x" . Format("{:08X}", mask) . " (核心0 + 核心" . (TotalThreads-1) . ")"
    CheckCore0.Value := 0
    CheckCCD0.Value := 0
    CheckCCD1.Value := 0
    CheckSMT.Value := 0
    CheckHigh.Value := 0
}

; ==============================================================================
; 设置函数
; ==============================================================================

ToggleAutoStart(itemName, *) {
    path := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    if (Settings.AutoStart == 1) {
        try {
            RegDelete(path, AppName)
        }
        Settings.AutoStart := 0
        SetMenu.Uncheck(itemName)
    } else {
        try {
            RegWrite('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"', "REG_SZ", path, AppName)
            Settings.AutoStart := 1
            SetMenu.Check(itemName)
        }
    }
}

ToggleSilent(itemName, *) {
    Settings.Silent := (Settings.Silent == 1 ? 0 : 1)
    if (Settings.Silent == 1) {
        SetMenu.Check(itemName)
    } else {
        SetMenu.Uncheck(itemName)
    }
    IniWrite(Settings.Silent, IniFile, "Global", "Silent")
}

ToggleTray(itemName, *) {
    Settings.HideTray := (Settings.HideTray == 1 ? 0 : 1)
    A_IconHidden := (Settings.HideTray == 1 ? true : false)
    if (Settings.HideTray == 1) {
        SetMenu.Check(itemName)
    } else {
        SetMenu.Uncheck(itemName)
    }
    IniWrite(Settings.HideTray, IniFile, "Global", "HideTray")
}

ChangeLang(l) {
    IniWrite(l, IniFile, "Global", "Language")
    Reload()
}