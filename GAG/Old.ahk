
AutoBuyHoney:
    if (cycleCount > 0 && Mod(currentMinute, 30) = 0 && currentMinute != lastHoneyShopMinute) {
        lastHoneyShopMinute := currentMinute
        SetTimer, PushBuyHoney, -2000
    }
    if (honeyShopFailed && Mod(currentMinute, 5) = 0 && currentMinute != lastHoneyRetryMinute) {
        lastHoneyRetryMinute := currentMinute
        SendDiscordMessage(webhookURL, "**[HONEY RETRY]**")
        SetTimer, PushBuyHoney, -2000
    }
Return

PushBuyHoney: 
    actionQueue.Push("BuyHoney")
Return

BuyHoney:
    currentSection := "BuyHoney"

    if (selectedHoneyItems.Length()) {
        if (UseAlts) {
            for index, winID in windowIDs {
                WinActivate, ahk_id %winID%
                WinWaitActive, ahk_id %winID%,, 2
                Gosub, HoneyShopPath
            }
        }
        else {
            Gosub, HoneyShopPath
        } 
    } 
Return
