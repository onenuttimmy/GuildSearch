-- GuildSearch.lua
-- Version: 3.1
-- Fixed: GuildPromote and GuildDemote logic for 1.12 API compatibility

local MAX_ROWS = 15
local ROW_HEIGHT = 16
local searchResults = {}

local sortCol = "level"
local sortAsc = true

local selectedName = nil

-- Main Frame
local mainFrame = CreateFrame("Frame", "GuildSearchFrame", UIParent)
mainFrame:SetWidth(460)
mainFrame:SetHeight(360)
mainFrame:SetPoint("CENTER", UIParent, "CENTER")
mainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", function() this:StartMoving() end)
mainFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
mainFrame:Hide()

-- Dropdown Menu Frame
local dropDown = CreateFrame("Frame", "GuildSearchDropDown", mainFrame, "UIDropDownMenuTemplate")

-- Title
local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", mainFrame, "TOP", 0, -15)
title:SetText("Guild Search")

-- Close Button
local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)

-- Search Box
local searchBox = CreateFrame("EditBox", "GuildSearchInput", mainFrame, "InputBoxTemplate")
searchBox:SetWidth(180)
searchBox:SetHeight(20)
searchBox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 25, -45)
searchBox:SetAutoFocus(false)
searchBox:SetFontObject("ChatFontNormal")

local searchLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
searchLabel:SetPoint("BOTTOMLEFT", searchBox, "TOPLEFT", -5, 0)
searchLabel:SetText("Search Filter:")

-- Reset Button
local resetBtn = CreateFrame("Button", "GuildSearchReset", mainFrame, "UIPanelButtonTemplate")
resetBtn:SetWidth(60)
resetBtn:SetHeight(24)
resetBtn:SetPoint("LEFT", searchBox, "RIGHT", 5, 0)
resetBtn:SetText("Reset")

-- Scroll Frame
local scrollFrame = CreateFrame("ScrollFrame", "GuildSearchScrollFrame", mainFrame, "FauxScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20, -100)
scrollFrame:SetWidth(400)
scrollFrame:SetHeight(MAX_ROWS * ROW_HEIGHT)

-- List Background
local listBg = CreateFrame("Frame", nil, mainFrame)
listBg:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", -5, 5)
listBg:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 25, -5)
listBg:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
listBg:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
listBg:SetBackdropColor(0, 0, 0, 0.5)

-- --- HELPER FUNCTION: Get Index by Name ---
local function GetGuildMemberIndex(targetName)
    local name
    for i=1, GetNumGuildMembers() do
        name = GetGuildRosterInfo(i)
        if name and string.lower(name) == string.lower(targetName) then
            return i
        end
    end
    return nil
end

-- --- DROPDOWN MENU LOGIC ---
local function GuildSearch_InitMenu()
    if not selectedName then return end

    local info = {}
    
    info.text = selectedName
    info.isTitle = 1
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "Whisper"
    info.func = function() ChatFrame_OpenChat("/w " .. selectedName .. " ") end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "Invite"
    info.func = function() InviteByName(selectedName) end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "Add Friend"
    info.func = function() AddFriend(selectedName) end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)

    info = {} 
    info.disabled = 1
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)

    -- GM: Promote
    if CanGuildPromote() then
        info = {}
        info.text = "Promote"
        info.func = function() 
            local idx = GetGuildMemberIndex(selectedName)
            if idx then
                SetGuildRosterSelection(idx)
                GuildPromote()
            end
        end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end

    -- GM: Demote
    if CanGuildDemote() then
        info = {}
        info.text = "Demote"
        info.func = function() 
            local idx = GetGuildMemberIndex(selectedName)
            if idx then
                SetGuildRosterSelection(idx)
                GuildDemote()
            end
        end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end

    -- GM: Kick
    if CanGuildRemove() then
        info = {}
        info.text = "|cffff0000Guild Kick|r"
        info.func = function() 
            StaticPopupDialogs["GUILDSEARCH_KICK_CONFIRM"] = {
                text = "Are you sure you want to kick " .. selectedName .. "?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function() GuildUninvite(selectedName) end,
                timeout = 0,
                whileDead = 1,
                hideOnEscape = 1
            }
            StaticPopup_Show("GUILDSEARCH_KICK_CONFIRM")
        end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)
    end

    info = {}
    info.text = "Cancel"
    info.func = function() end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info)
end

-- --- HEADER BUTTONS ---
local function CreateHeader(text, width, key, xOffset)
    local btn = CreateFrame("Button", nil, mainFrame)
    btn:SetWidth(width)
    btn:SetHeight(18)
    btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 20 + xOffset, -75)
    
    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    txt:SetPoint("LEFT", btn, "LEFT", 0, 0)
    txt:SetText(text)
    
    btn:SetScript("OnClick", function()
        if sortCol == key then
            sortAsc = not sortAsc
        else
            sortCol = key
            sortAsc = true
        end
        GuildSearch_UpdateList()
    end)
    return btn
end

-- Layout Configuration
local colLvl = CreateHeader("Lvl", 30, "level", 0)
local colClass = CreateHeader("Class", 70, "class", 35)
local colName = CreateHeader("Name", 90, "name", 105)
local colRank = CreateHeader("Rank", 80, "rankIndex", 195) 
local colZone = CreateHeader("Zone", 110, "zone", 280)

-- --- DATA ROWS ---
local rows = {}
local function CreateRow(i)
    local row = CreateFrame("Button", nil, mainFrame)
    row:SetWidth(420)
    row:SetHeight(ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    local function CreateCell(w, align)
        local t = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        t:SetWidth(w)
        t:SetHeight(ROW_HEIGHT)
        t:SetJustifyH(align)
        return t
    end

    row.lvl = CreateCell(30, "LEFT")
    row.lvl:SetPoint("LEFT", row, "LEFT", 0, 0)

    row.class = CreateCell(70, "LEFT")
    row.class:SetPoint("LEFT", row.lvl, "RIGHT", 5, 0)

    row.name = CreateCell(90, "LEFT")
    row.name:SetPoint("LEFT", row.class, "RIGHT", 0, 0)

    row.rank = CreateCell(80, "LEFT")
    row.rank:SetPoint("LEFT", row.name, "RIGHT", 0, 0)

    row.zone = CreateCell(110, "LEFT")
    row.zone:SetPoint("LEFT", row.rank, "RIGHT", 5, 0)

    row:SetScript("OnClick", function()
        if not this.playerName then return end
        
        if (arg1 == "RightButton") then
            selectedName = this.playerName
            UIDropDownMenu_Initialize(dropDown, GuildSearch_InitMenu, "MENU")
            ToggleDropDownMenu(1, nil, dropDown, "cursor", 0, 0)
        else
            if (IsShiftKeyDown()) then
                SendWho("n-"..this.playerName)
            else
                ChatFrame_OpenChat("/w " .. this.playerName .. " ")
            end
        end
    end)

    row:SetScript("OnEnter", function() 
        this.lvl:SetTextColor(1, 1, 0)
        this.class:SetTextColor(1, 1, 0)
        this.name:SetTextColor(1, 1, 0)
        this.rank:SetTextColor(1, 1, 0)
        this.zone:SetTextColor(1, 1, 0)
    end)
    row:SetScript("OnLeave", function() 
        local c = this.isOnline and {1,1,1} or {0.5, 0.5, 0.5}
        this.lvl:SetTextColor(c[1], c[2], c[3])
        this.class:SetTextColor(c[1], c[2], c[3])
        this.name:SetTextColor(c[1], c[2], c[3])
        this.rank:SetTextColor(c[1], c[2], c[3])
        this.zone:SetTextColor(c[1], c[2], c[3])
    end)

    return row
end

for i = 1, MAX_ROWS do
    rows[i] = CreateRow(i)
    if i == 1 then
        rows[i]:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 5, 0)
    else
        rows[i]:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT", 0, 0)
    end
end

local function SafeSearch(str, query)
    if not str then return false end
    local escapedQuery = string.gsub(query, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
    return string.find(string.lower(str), escapedQuery)
end

local function SortData()
    table.sort(searchResults, function(a, b)
        local v1, v2 = a[sortCol], b[sortCol]
        
        if sortCol == "level" or sortCol == "rankIndex" then
            v1 = tonumber(v1) or 0
            v2 = tonumber(v2) or 0
        else
            v1 = tostring(v1 or "")
            v2 = tostring(v2 or "")
            v1 = string.lower(v1)
            v2 = string.lower(v2)
        end

        if sortAsc then return v1 < v2 else return v1 > v2 end
    end)
end

function GuildSearch_UpdateList()
    local numMembers = GetNumGuildMembers()
    local query = string.lower(searchBox:GetText())
    
    searchResults = {} 
    
    local count = 0
    for i = 1, numMembers do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
        
        local match = false
        if (query == "") then
            match = true
        else
            if (SafeSearch(name, query)) then match = true end
            if (SafeSearch(class, query)) then match = true end
            if (SafeSearch(rank, query)) then match = true end 
            if (SafeSearch(zone, query)) then match = true end
            if (SafeSearch(tostring(level), query)) then match = true end
        end

        if match and name then
            count = count + 1
            table.insert(searchResults, {
                index = i,
                name = name,
                level = level,
                class = class,
                rank = rank,
                rankIndex = rankIndex,
                zone = zone or "Offline",
                online = online,
                status = status
            })
        end
    end

    SortData()

    FauxScrollFrame_Update(scrollFrame, count, MAX_ROWS, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(scrollFrame)
    
    for i = 1, MAX_ROWS do
        local index = offset + i
        if index <= count then
            local data = searchResults[index]
            if data then 
                local color = data.online and "|cffffffff" or "|cff808080"
                
                rows[i].lvl:SetText(data.level)
                rows[i].class:SetText(data.class)
                rows[i].name:SetText(data.name)
                rows[i].rank:SetText(data.rank)
                rows[i].zone:SetText(data.zone)

                local c = data.online and 1 or 0.5
                rows[i].lvl:SetTextColor(c, c, c)
                rows[i].class:SetTextColor(c, c, c)
                rows[i].name:SetTextColor(c, c, c)
                rows[i].rank:SetTextColor(c, c, c)
                rows[i].zone:SetTextColor(c, c, c)

                rows[i].playerName = data.name
                rows[i].isOnline = data.online
                rows[i]:Show()
            else
                rows[i]:Hide()
            end
        else
            rows[i]:Hide()
        end
    end
end

resetBtn:SetScript("OnClick", function()
    searchBox:SetText("")
    searchBox:ClearFocus()
    sortCol = "level"
    sortAsc = true
    GuildSearch_UpdateList()
end)

searchBox:SetScript("OnTextChanged", function() GuildSearch_UpdateList() end)
searchBox:SetScript("OnEnterPressed", function() this:ClearFocus() end)
searchBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)

scrollFrame:SetScript("OnVerticalScroll", function()
    FauxScrollFrame_OnVerticalScroll(ROW_HEIGHT, GuildSearch_UpdateList)
end)

mainFrame:SetScript("OnShow", function()
    SetGuildRosterShowOffline(true)
    GuildRoster() 
    GuildSearch_UpdateList()
end)

mainFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
mainFrame:SetScript("OnEvent", function()
    if (event == "GUILD_ROSTER_UPDATE" and mainFrame:IsVisible()) then
        GuildSearch_UpdateList()
    end
end)

SLASH_GUILDSEARCH1 = "/gs"
SLASH_GUILDSEARCH2 = "/guildsearch"
SlashCmdList["GUILDSEARCH"] = function()
    if mainFrame:IsVisible() then mainFrame:Hide() else mainFrame:Show() end
end

DEFAULT_CHAT_FRAME:AddMessage("GuildSearch 3.1 Loaded. GM Tools Fixed.", 1, 1, 0)