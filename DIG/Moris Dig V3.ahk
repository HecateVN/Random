#Requires AutoHotkey v2.0
#SingleInstance Force

defaultTerrainColors := Map(
    "Sand", [0x968D6F],
    "Snow", [0x7B7D85],
    "Grass", [0x3C643A],
    "Mushroom", [0x2F367A],
)

terrainColors := Map()
settingsFile := A_ScriptDir . "\settings.ini"

LoadSettings()

MyGui := Gui()
MyGui.Title := "moris dig v3"
MyGui.OnEvent("Close", OnGuiClose)

TabCtrl := MyGui.Add("Tab3", "w300 h300", ["Main", "Custom Terrain", "Debug", "Instructions", "Credits"])

TabCtrl.UseTab("Main")
MyGui.Add("Text", "Section", "Terrain:")
terrainDropdown := MyGui.Add("DropDownList", "w150 ys vSelectedTerrain", GetTerrainNames())
terrainDropdown.OnEvent("Change", UpdateTerrainType)
terrainDropdown.Value := selectedTerrainIndex

MyGui.Add("Button", "xs Section w80", "Start (F1)").OnEvent("Click", (*) => Send("{F1}"))
MyGui.Add("Button", "ys w80", "Reload (F2)").OnEvent("Click", (*) => Send("{F2}"))

MyGui.Add("CheckBox", "xs Section vRecoveryToggle", "Enable Recovery Cycle").Value := recoveryCycleEnabled
MyGui.Add("CheckBox", "xs vCycleTimeoutToggle", "Auto-restart if no cycles").Value := cycleTimeoutEnabled

MyGui.Add("Text", "xs Section", "Webhook URL:")
webhookEdit := MyGui.Add("Edit", "w200 vWebhookURL", webhookURL)
MyGui.Add("CheckBox", "xs vWebhookEnabled", "Enable Webhook").Value := webhookEnabled

TabCtrl.UseTab("Custom Terrain")
MyGui.Add("Text", "Section", "Create Custom Terrain:")
MyGui.Add("Text", "xs", "Terrain Name:")
customNameEdit := MyGui.Add("Edit", "w150 vCustomName")
MyGui.Add("Text", "xs", "Color (Hex, e.g., 0xFF0000):")
customColorEdit := MyGui.Add("Edit", "w150 vCustomColor")
MyGui.Add("Button", "xs w100", "Add Terrain").OnEvent("Click", AddCustomTerrain)

MyGui.Add("Text", "xs Section", "Existing Custom Terrains:")
customTerrainList := MyGui.Add("ListBox", "w200 h100 vCustomTerrainList")
UpdateCustomTerrainList()
MyGui.Add("Button", "ys w80", "Delete").OnEvent("Click", DeleteCustomTerrain)

TabCtrl.UseTab("Debug")
MyGui.Add("Text", "Section", "DONT CHANGE ANYTHING IF YOUR NOT SMART")
MyGui.Add("Text", "Section", "Click Delay:")
clickDelayEdit := MyGui.Add("Edit", "w40 ys", clickDelay)
clickDelayEdit.OnEvent("Change", UpdateClickDelay)
MyGui.Add("Text", "xs Section", "Scan Radius:")
scanRadiusEdit := MyGui.Add("Edit", "w40 ys", clickScanRadius)
scanRadiusEdit.OnEvent("Change", UpdateScanRadius)
MyGui.Add("Text", "xs Section", "Cooldown:")
clickCooldownEdit := MyGui.Add("Edit", "w40 ys", clickCooldown)
clickCooldownEdit.OnEvent("Change", UpdateClickCooldown)
MyGui.Add("Text", "xs Section", "Interval:")
followIntervalEdit := MyGui.Add("Edit", "w40 ys", followInterval)
followIntervalEdit.OnEvent("Change", UpdateFollowInterval)
MyGui.Add("Text", "xs Section", "Buffer:")
mouseBufferEdit := MyGui.Add("Edit", "w40 ys", mouseBuffer)
mouseBufferEdit.OnEvent("Change", UpdateMouseBuffer)
MyGui.Add("Button", "xs w80", "Apply").OnEvent("Click", ApplySettings)

TabCtrl.UseTab("Instructions")
MyGui.Add("Text",, "F1 to Start")
MyGui.Add("Text",, "F2 to Reload the Macro")
MyGui.Add("Text",, "F3 to Copy current mouse Location color to Clipboard")

TabCtrl.UseTab("Credits")
MyGui.Add("Text",, "made by moris :)")
MyGui.Add("Text",, "webhooks and rejoin by adnrealan")
DiscordBtn := MyGui.Add("Button",, "Join Discord")
DiscordBtn.OnEvent("Click", (*) => Run("https://discord.gg/2fraBuhe3m"))
DonateBtn := MyGui.Add("Button",, "Donate")
DonateBtn.OnEvent("Click", (*) => Run("https://www.roblox.com/catalog/124883742268645/katze"))

TabCtrl.UseTab()

MyGui.Show()

scanLeft := 512
scanTop := 916
scanRight := 1397
scanBottom := 926
targetColor := 0x191919 ;DO NOT CHANGE
clickColors := terrainColors["Sand"]
colorBlacklist := [0x010000, 0x3F3F43, 0x3E3F43, 0x010101, 0x020000, 0x020202, 0x030101, 0x030303, 0x040404, 0x050101, 0x050505, 0x060606, 0x070707, 0x080202, 0x080505, 0x080808, 0x090808, 0x090909, 0x0A0A0A, 0x0B0B0B, 0x0C0C0C, 0x0D0404, 0x0D0D0D, 0x0E0404, 0x0E0E0E, 0x0F0F0F, 0x101010, 0x110505, 0x111111, 0x121212, 0x131010, 0x131313, 0x141414, 0x151515, 0x160606, 0x161616, 0x171717, 0x181818, 0x1A1919, 0x1A1A1A, 0x1B1B1B, 0x1C1A1A, 0x1C1C1C, 0x1D0808, 0x1D1D1D, 0x1E0808, 0x1E1818, 0x1E1E1E, 0x1F1414, 0x1F1616, 0x1F1F1F, 0x201515, 0x202020, 0x212121, 0x222222, 0x231919, 0x232323, 0x241717, 0x242424, 0x252525, 0x261010, 0x262626, 0x272727, 0x282828, 0x292929, 0x2A2A2A, 0x2B2B2B, 0x2C1A1A, 0x2C2C2C, 0x2D2D2D, 0x2E2E2E, 0x2F2F2F, 0x303030, 0x313131, 0x323232, 0x333333, 0x343434, 0x353535, 0x363636, 0x373737, 0x383838, 0x393939, 0x3A3A3A, 0x3B3B3B, 0x3C3C3C, 0x3D3D3D, 0x3E3E3E, 0x3F3F3F, 0x404040, 0x414141, 0x424242, 0x434343, 0x444444, 0x451313, 0x454545, 0x461313, 0x464646, 0x474747, 0x481313, 0x484848, 0x494949, 0x4A4A4A, 0x4B4B4B, 0x4C1717, 0x4C4C4C, 0x4D4D4D, 0x4E4E4E, 0x4F4F4F, 0x505050, 0x511616, 0x515151, 0x592121, 0x5D5D5D, 0x5E1A1A, 0x5E5E5E, 0x5F5F5F, 0x601A1A, 0x606060, 0x612424, 0x616161, 0x636363, 0x646464, 0x652121, 0x656565, 0x666666, 0x681C1C, 0x691D1D, 0x7C7C7C, 0x7D7D7D, 0x7E7E7E, 0x7F7F7F, 0x832424, 0x852929, 0x882B2B, 0x929292, 0x932828, 0x939393, 0x942828, 0x949494, 0x959595, 0x969696, 0x979797, 0x989898, 0xA22C2C, 0xA32C2C, 0xA72D2D, 0xA72E2E, 0xAE3434, 0xAEAEAE, 0xAFAFAF, 0xB0B0B0, 0xB1B1B1, 0xB2B2B2, 0xB3B3B3, 0xB4B4B4, 0xB53131, 0xB5B5B5, 0xB6B6B6, 0xB7B7B7, 0xB9B9B9, 0xBABABA, 0xBBBBBB, 0xBCBCBC, 0xBDBDBD, 0xBE3434, 0xBEBEBE, 0xBFBFBF, 0xC0C0C0, 0xC1C1C1, 0xC2C2C2, 0xC33535, 0xC3C3C3, 0xC43838, 0xC4C4C4, 0xC53535, 0xC5C5C5, 0xC6C6C6, 0xC73636, 0xC73737, 0xC7C7C7, 0xDB3D3D, 0xE73E3E, 0xE84040, 0xEA3F3F, 0xEB4040, 0xEE4040, 0xEE4141, 0xF24242, 0xF34141, 0xF54242, 0xF74343, 0xF84343, 0xF84444, 0xFA4343, 0xFB4444, 0xFC4444, 0xFC4545, 0xFD4545, 0xFE4545, 0xFF4545]
clickColorVariation := -10
scanning := false
minX := 99999
maxX := -1
lastClickTime := 0
lastFoundX := 0
lastFoundY := 0
lastPixelFoundTime := 0
recoveryActive := false
clickLoopActive := false
recoveryCycleEnabled := true
cycleTimeoutEnabled := false
lastCycleTime := 0
webhookURL := ""
webhookEnabled := false
cycleCount := 0

LoadSettings() {
    global settingsFile, clickDelay, clickScanRadius, clickCooldown, followInterval, mouseBuffer, selectedTerrainIndex
    global recoveryCycleEnabled, cycleTimeoutEnabled, terrainColors, defaultTerrainColors, webhookURL, webhookEnabled

    clickDelay := 10
    clickScanRadius := 20
    clickCooldown := 200
    followInterval := 10
    mouseBuffer := 10
    selectedTerrainIndex := 1
    recoveryCycleEnabled := true
    cycleTimeoutEnabled := false
    webhookURL := ""
    webhookEnabled := false

    terrainColors := Map()

    if (FileExist(settingsFile)) {
        clickDelay := IniRead(settingsFile, "Settings", "ClickDelay", clickDelay)
        clickScanRadius := IniRead(settingsFile, "Settings", "ScanRadius", clickScanRadius)
        clickCooldown := IniRead(settingsFile, "Settings", "ClickCooldown", clickCooldown)
        followInterval := IniRead(settingsFile, "Settings", "FollowInterval", followInterval)
        mouseBuffer := IniRead(settingsFile, "Settings", "MouseBuffer", mouseBuffer)
        selectedTerrainIndex := IniRead(settingsFile, "Settings", "SelectedTerrain", selectedTerrainIndex)
        recoveryCycleEnabled := IniRead(settingsFile, "Settings", "RecoveryCycleEnabled", recoveryCycleEnabled)
        cycleTimeoutEnabled := IniRead(settingsFile, "Settings", "CycleTimeoutEnabled", cycleTimeoutEnabled)
        webhookURL := IniRead(settingsFile, "Settings", "WebhookURL", webhookURL)
        webhookEnabled := IniRead(settingsFile, "Settings", "WebhookEnabled", webhookEnabled)
        
        LoadAllTerrains()
    } else {
        for name, colors in defaultTerrainColors {
            terrainColors[name] := colors
        }
        SaveAllTerrains()
    }
}

LoadAllTerrains() {
    global settingsFile, terrainColors, defaultTerrainColors
    
    try {
        ; Get list of all terrains
        allTerrainNames := IniRead(settingsFile, "TerrainColors", "AllTerrains", "")
        if (allTerrainNames != "") {
            terrainList := StrSplit(allTerrainNames, "|")
            for terrainName in terrainList {
                if (terrainName != "") {
                    ; Load colors for this terrain
                    colorsString := IniRead(settingsFile, "TerrainColors", terrainName, "")
                    if (colorsString != "") {
                        if (colorsString = "EMPTY") {
                            ; Empty array for terrains with no colors
                            terrainColors[terrainName] := []
                        } else {
                            ; Parse color values
                            colorStrings := StrSplit(colorsString, ",")
                            colors := []
                            for colorString in colorStrings {
                                if (colorString != "") {
                                    colors.Push(Integer(colorString))
                                }
                            }
                            terrainColors[terrainName] := colors
                        }
                    }
                }
            }
        } else {
            ; No terrains found in settings, use defaults
            for name, colors in defaultTerrainColors {
                terrainColors[name] := colors
            }
            SaveAllTerrains()
        }
    } catch {
        ; Error loading, use defaults
        for name, colors in defaultTerrainColors {
            terrainColors[name] := colors
        }
        SaveAllTerrains()
    }
}

SaveSettings() {
    global settingsFile, clickDelay, clickScanRadius, clickCooldown, followInterval, mouseBuffer, terrainDropdown
    global recoveryCycleEnabled, cycleTimeoutEnabled, webhookURL, webhookEnabled

    currentClickDelay := Integer(clickDelayEdit.Value)
    currentScanRadius := Integer(scanRadiusEdit.Value)
    currentClickCooldown := Integer(clickCooldownEdit.Value)
    currentFollowInterval := Integer(followIntervalEdit.Value)
    currentMouseBuffer := Integer(mouseBufferEdit.Value)
    currentSelectedTerrain := terrainDropdown.Value
    guiValues := MyGui.Submit(false)
    currentRecoveryToggle := guiValues.RecoveryToggle
    currentCycleTimeoutToggle := guiValues.CycleTimeoutToggle
    currentWebhookURL := guiValues.WebhookURL
    currentWebhookEnabled := guiValues.WebhookEnabled

    ; Save basic settings
    IniWrite(currentClickDelay, settingsFile, "Settings", "ClickDelay")
    IniWrite(currentScanRadius, settingsFile, "Settings", "ScanRadius")
    IniWrite(currentClickCooldown, settingsFile, "Settings", "ClickCooldown")
    IniWrite(currentFollowInterval, settingsFile, "Settings", "FollowInterval")
    IniWrite(currentMouseBuffer, settingsFile, "Settings", "MouseBuffer")
    IniWrite(currentSelectedTerrain, settingsFile, "Settings", "SelectedTerrain")
    IniWrite(currentRecoveryToggle, settingsFile, "Settings", "RecoveryCycleEnabled")
    IniWrite(currentCycleTimeoutToggle, settingsFile, "Settings", "CycleTimeoutEnabled")
    IniWrite(currentWebhookURL, settingsFile, "Settings", "WebhookURL")
    IniWrite(currentWebhookEnabled, settingsFile, "Settings", "WebhookEnabled")
    
    ; Save all terrain colors
    SaveAllTerrains()
}

SaveAllTerrains() {
    global settingsFile, terrainColors
    
    ; Build list of all terrain names
    allTerrainNames := ""
    
    for terrainName, colors in terrainColors {
        if (allTerrainNames != "") {
            allTerrainNames .= "|"
        }
        allTerrainNames .= terrainName
        
        ; Save colors for this terrain
        if (colors.Length = 0) {
            ; Empty array - save as special marker
            IniWrite("EMPTY", settingsFile, "TerrainColors", terrainName)
        } else {
            ; Convert colors array to comma-separated string
            colorString := ""
            for color in colors {
                if (colorString != "") {
                    colorString .= ","
                }
                colorString .= color
            }
            IniWrite(colorString, settingsFile, "TerrainColors", terrainName)
        }
    }
    
    ; Save the list of all terrain names
    IniWrite(allTerrainNames, settingsFile, "TerrainColors", "AllTerrains")
}

GetTerrainNames() {
    global terrainColors
    names := []
    for name, colors in terrainColors {
        names.Push(name)
    }
    return names
}

UpdateCustomTerrainList() {
    global customTerrainList, terrainColors, defaultTerrainColors
    
    customTerrainList.Delete()
    
    for terrainName, colors in terrainColors {
        if (!defaultTerrainColors.Has(terrainName)) {
            customTerrainList.Add([terrainName])
        }
    }
}

AddCustomTerrain(*) {
    global terrainColors, terrainDropdown, customNameEdit, customColorEdit
    
    terrainName := Trim(customNameEdit.Text)
    colorHex := Trim(customColorEdit.Text)
    
    if (terrainName = "" || colorHex = "") {
        MsgBox("Please enter both terrain name and color value.")
        return
    }

    if (!RegExMatch(colorHex, "^0x[0-9A-Fa-f]{6}$")) {
        MsgBox("Invalid color format. Please use format: 0xRRGGBB from F3")
        return
    }

    if (terrainColors.Has(terrainName)) {
        result := MsgBox("Terrain '" . terrainName . "' already exists. Overwrite?", "Confirm", "YesNo")
        if (result = "No") {
            return
        }
    }

    colorValue := Integer(colorHex)
    terrainColors[terrainName] := [colorValue]

    terrainDropdown.Delete()
    terrainDropdown.Add(GetTerrainNames())

    UpdateCustomTerrainList()

    customNameEdit.Text := ""
    customColorEdit.Text := ""
    
    ToolTip("Custom terrain '" . terrainName . "' added successfully!", 10, 30)
    SetTimer(() => ToolTip(), -2000)
}

DeleteCustomTerrain(*) {
    global customTerrainList, terrainColors, terrainDropdown, defaultTerrainColors
    
    selectedIndex := customTerrainList.Value
    if (selectedIndex = 0) {
        MsgBox("Please select a terrain to delete.")
        return
    }
    
    terrainName := customTerrainList.Text
    
    result := MsgBox("Are you sure you want to delete terrain '" . terrainName . "'?", "Confirm Delete", "YesNo")
    if (result = "Yes") {
        terrainColors.Delete(terrainName)

        terrainDropdown.Delete()
        terrainDropdown.Add(GetTerrainNames())
        
        UpdateCustomTerrainList()
        
        ToolTip("Terrain '" . terrainName . "' deleted successfully!", 10, 30)
        SetTimer(() => ToolTip(), -2000)
    }
}

OnGuiClose(*) {
    SaveSettings()
    ExitApp
}

UpdateTerrainType(*) {
    global clickColors, terrainColors
    selectedTerrain := terrainDropdown.Text
    if (terrainColors.Has(selectedTerrain)) {
        clickColors := terrainColors[selectedTerrain]
    }
}

UpdateClickDelay(*) {
    global clickDelay
    clickDelay := Integer(clickDelayEdit.Value)
}

UpdateScanRadius(*) {
    global clickScanRadius
    clickScanRadius := Integer(scanRadiusEdit.Value)
}

UpdateClickCooldown(*) {
    global clickCooldown
    clickCooldown := Integer(clickCooldownEdit.Value)
}

UpdateFollowInterval(*) {
    global followInterval
    followInterval := Integer(followIntervalEdit.Value)
    if (scanning) {
        SetTimer(ScanForColor, followInterval)
    }
}

UpdateMouseBuffer(*) {
    global mouseBuffer
    mouseBuffer := Integer(mouseBufferEdit.Value)
}

ApplySettings(*) {
    global recoveryCycleEnabled, cycleTimeoutEnabled, webhookURL, webhookEnabled
    
    UpdateTerrainType()
    UpdateClickDelay()
    UpdateScanRadius()
    UpdateClickCooldown()
    UpdateFollowInterval()
    UpdateMouseBuffer()

    guiValues := MyGui.Submit(false)
    recoveryCycleEnabled := guiValues.RecoveryToggle
    cycleTimeoutEnabled := guiValues.CycleTimeoutToggle
    webhookURL := guiValues.WebhookURL
    webhookEnabled := guiValues.WebhookEnabled
    
    ToolTip("Settings applied", 10, 30)
    SetTimer(() => ToolTip(), -1000)
}

SendWebhook(message) {
    global webhookURL, webhookEnabled
    
    if (!webhookEnabled || webhookURL = "") {
        return
    }
    
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        
        jsonData := '{"content":"' . message . '"}'
        whr.Send(jsonData)
    } catch {
        ; Silently fail if webhook fails
    }
}

IsColorBlacklisted(color) {
    global colorBlacklist
    for blacklistedColor in colorBlacklist {
        if (color = blacklistedColor) {
            return true
        }
    }
    return false
}

RestartRoblox() {
    global scanning, cycleTimeoutEnabled
    
    if (!cycleTimeoutEnabled)
        return
    
    SendWebhook("No cycles for 4 minutes - Restarting Roblox")
    ToolTip("Restarting Roblox due to 4 min timeout...", 10, 10)

    ; Close any running Roblox windows
    try {
        WinClose("Roblox")
        Sleep(3000)
        WinKill("Roblox")
    }
    catch { 
    }

    scanning := false

    ; Launch the game
    gameId   := "126244816328678"
    robloxUrl := "roblox://placeId=" . gameId
    try {
        scanning := false
        SetTimer(ScanForColor,    0)
        SetTimer(CheckPixelTimeout, 0) 
        SetTimer(CheckCycleTimeout, 0)

        Run(robloxUrl)
        Sleep(20000)

        WinWait("Roblox",, 10000)
        WinActivate
        Sleep 200
        Send "{F11}"
        Sleep 100
        Click "Right"
        Sleep 100
        Send("{F1}")
        Click "Right"
    }
    catch {
    }
}

F1::
{
    global scanning, followInterval, recoveryCycleEnabled, cycleTimeoutEnabled, cycleCount, lastCycleTime

    SaveSettings()
    ApplySettings()
    
    ToolTip("Running scroll sequence", 10, 10)

    Send "{1}"
    
    if (recoveryCycleEnabled) {
        Loop 18 {
            Send "{WheelUp}"
            Sleep 50
        }
        
        Send "{WheelDown}"
        
        Click
    }
    
    scanning := !scanning
    if (scanning) {
        cycleCount := 0
        lastCycleTime := A_TickCount
        SendWebhook("Script started")
        ToolTip("Scroll sequence completed - Starting color tracking", 10, 10)
        SetTimer(ScanForColor, followInterval)
        if (recoveryCycleEnabled) {
            SetTimer(CheckPixelTimeout, 1000)
        }
        if (cycleTimeoutEnabled) {
            SetTimer(CheckCycleTimeout, 30000)
        }
    } else {
        ToolTip("Color tracking stopped", 10, 10)
        SetTimer(ScanForColor, 0)
        SetTimer(CheckPixelTimeout, 0)
        SetTimer(CheckCycleTimeout, 0)
        SetTimer(() => ToolTip(), -2000)
    }
}

F2::
{
    SaveSettings()
    ToolTip("Reloading script...", 10, 10)
    Sleep 100
    Reload
}

F3:: {
    try {
        MouseGetPos(&mouseX, &mouseY)
        pixelColor := PixelGetColor(mouseX, mouseY)
        A_Clipboard := pixelColor
        MsgBox pixelColor, "Color Copied" , 1
        SetTimer () => TrayTip(), -2000
    } catch as err {
        MsgBox "Error getting color: " err.Message
    }
}

CheckCycleTimeout() {
    global lastCycleTime, cycleTimeoutEnabled, scanning
    
    if (!scanning || !cycleTimeoutEnabled)
        return
        
    if (A_TickCount - lastCycleTime > 30000) {
        RestartRoblox()
    }
}

ScanForColor() {
    global scanLeft, scanTop, scanRight, scanBottom, targetColor, scanning
    global clickColors, clickColorVariation, clickScanRadius
    global clickDelay, clickCooldown, lastClickTime, lastFoundX, lastFoundY, mouseBuffer
    global lastPixelFoundTime, recoveryActive, clickLoopActive, recoveryCycleEnabled, cycleCount, lastCycleTime
    static searchDirection := "RightToLeft"
    static lastDirection := ""
    
    if (!scanning)
        return

    newDirection := ""
    if (lastFoundX >= scanRight - mouseBuffer) {
        newDirection := "LeftToRight"
    } 
    else if (lastFoundX <= scanLeft + mouseBuffer) {
        newDirection := "RightToLeft"
    }
    
    if (newDirection != "") {
        searchDirection := newDirection
        lastDirection := newDirection
    }

    if (searchDirection = "RightToLeft") {
        startX := scanRight
        endX := scanLeft
    } else {
        startX := scanLeft
        endX := scanRight
    }

    if (PixelSearch(&foundX, &foundY, startX, scanTop, endX, scanBottom, targetColor, 0)) {
        if (recoveryActive) {
            recoveryActive := false
            clickLoopActive := false
            Send "{Right up}"
            if (recoveryCycleEnabled) {
                Send "{WheelDown}"
            }
            cycleCount++
            lastCycleTime := A_TickCount
            if (Mod(cycleCount, 5) = 0) {
                SendWebhook("Completed " . cycleCount . " cycles")
            }
            ToolTip("Recovery mode ended - Scrolled down", 10, 50)
            SetTimer(() => ToolTip(), -2000)
        }

        lastPixelFoundTime := A_TickCount

        if (Abs(foundX - lastFoundX) > 2 || lastFoundX = 0) {
            MouseMove(foundX, foundY - 30, 0)
            lastFoundX := foundX
            lastFoundY := foundY
        }

        if ((A_TickCount - lastClickTime) >= clickCooldown) {
            mouseX := foundX
            mouseY := foundY - 30

            cLeft := Max(mouseX - clickScanRadius, 0)
            cTop := Max(mouseY - clickScanRadius, 0)
            cRight := Min(mouseX + clickScanRadius, A_ScreenWidth)
            cBottom := Min(mouseY + clickScanRadius, A_ScreenHeight)

            for color in clickColors {
                if (PixelSearch(&cX, &cY, cLeft, cTop, cRight, cBottom, color, clickColorVariation)) {
                    Click(mouseX, mouseY)
                    lastClickTime := A_TickCount
                    break
                }
            }
        }
    }
    else {
        searchDirection := (searchDirection = "RightToLeft") ? "LeftToRight" : "RightToLeft"
    }
}

CheckPixelTimeout() {
    global lastPixelFoundTime, scanning, recoveryActive, clickLoopActive, recoveryCycleEnabled
    
    if (!scanning || recoveryActive || !recoveryCycleEnabled)
        return

    if (A_TickCount - lastPixelFoundTime > 7500) {
        recoveryActive := true
        clickLoopActive := true
        Send "{WheelUp 8}"
        Sleep 100
        Send "{Right down}"
        SetTimer(RecoveryClickLoop, clickCooldown)
        ToolTip("Pixel not found - Started recovery (clicking + right arrow)", 10, 50)
    }
}

RecoveryClickLoop() {
    global recoveryActive, clickLoopActive, clickCooldown, lastPixelFoundTime, recoveryCycleEnabled
    
    if (!recoveryActive || !clickLoopActive || !recoveryCycleEnabled) {
        SetTimer(, 0)
        return
    }

    Click
    lastPixelFoundTime := A_TickCount

    if (A_TickCount - lastPixelFoundTime > 3000) {
        Send "{Right down}"
    }
}