--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║       LUXXY PREMIUM — Streamer + Key + Monkey Push (FIXED)   ║
    ║       Blue Sky Gradient | HWID Lock | 4 Monkey Feature       ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════
-- KONFIGURASI
-- ═══════════════════════════════════════════════════════════════
local WORKER_URL = "https://luxxys-worker.haloyypayo.workers.dev"
local ADMIN_WA = "082142293503"
local KEY_FILE = "luxxys_premium_key.txt"
local CONFIG_FILE = "luxxys_streamer_config.json"

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- WARNA
-- ═══════════════════════════════════════════════════════════════
local COLOR = {
    SkyTop      = Color3.fromRGB(135, 206, 250),
    SkyMid      = Color3.fromRGB(200, 230, 255),
    SkyBot      = Color3.fromRGB(255, 255, 255),
    White       = Color3.fromRGB(255, 255, 255),
    DarkText    = Color3.fromRGB(30, 60, 100),
    BorderBlue  = Color3.fromRGB(80, 160, 220),
    ShadowBlue  = Color3.fromRGB(40, 100, 160),
    Success     = Color3.fromRGB(60, 200, 120),
    Error       = Color3.fromRGB(220, 60, 60),
    Warning     = Color3.fromRGB(255, 200, 60),
    Purple      = Color3.fromRGB(160, 80, 220),
    Cyan        = Color3.fromRGB(0, 220, 255),
    Background  = Color3.fromRGB(8, 20, 35),
    Dark        = Color3.fromRGB(15, 32, 52),
    Darker      = Color3.fromRGB(5, 12, 22),
}

-- ═══════════════════════════════════════════════════════════════
-- CFG
-- ═══════════════════════════════════════════════════════════════
local CFG = {
    DefaultUIBind       = Enum.KeyCode.F1,
    DefaultPrisonBind   = Enum.KeyCode.P,
    DefaultPushBind     = Enum.KeyCode.G,
    DefaultPushLeftBind = Enum.KeyCode.J,
    DefaultPushRightBind= Enum.KeyCode.K,
    DefaultLightningBind= Enum.KeyCode.L,
    DefaultMonkeyBind   = Enum.KeyCode.M,

    PrisonWidth     = 12,
    PrisonHeight    = 14,
    PrisonLength    = 12,
    BarThickness    = 0.25,
    BarSpacing      = 1.2,
    PrisonStartTime = 10,
    PrisonTimeAdd   = 5,

    PushPower       = 250,
    PushUpPower     = 150,

    FlyDuration     = 1.2,
    FlyArcHeight    = 60,

    LightningSkinColor  = Color3.fromRGB(0, 0, 0),
    LightningBurnTime   = 50,
    LightningWidth      = 1.2,
    LightningSegments   = 8,
    LightningHeight     = 200,
    LightningBoltCount  = 3,
    LightningFlashDur   = 0.4,
    LightningShakeInt   = 2,
    LightningShakeDur   = 0.5,
    LightningSparkCount = 50,
    ThunderSoundId      = "rbxassetid://9114221324",
    ThunderVolume       = 2,
    ThunderPitch        = 1,

    MonkeyCount     = 4,
    MonkeyDistance  = 8,
    MonkeySize      = 3,
    MonkeyForce     = 8,
    MonkeyPushSpeed = 0.15,

    FolderName      = "LuxxysPrisonTrap",
    MonkeyFolder    = "LuxxysMonkeys",

    UIWidth         = 320,
    UIHeight        = 500,
}

-- ═══════════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════════
local State = {
    UIBind            = CFG.DefaultUIBind,
    PrisonBind        = CFG.DefaultPrisonBind,
    PushBind          = CFG.DefaultPushBind,
    PushLeftBind      = CFG.DefaultPushLeftBind,
    PushRightBind     = CFG.DefaultPushRightBind,
    LightningBind     = CFG.DefaultLightningBind,
    MonkeyBind        = CFG.DefaultMonkeyBind,
    IsPrisonActive    = false,
    PrisonTimeLeft    = 0,
    PrisonFolder      = nil,
    PrisonCenter      = Vector3.new(0, 0, 0),
    IsMonkeyActive    = false,
    Monkeys           = {},
    WaitingForBind    = nil,
    WaitingForCheckpointBind = nil,
    Checkpoints       = {},
    IsFlying          = false,
    IsStriking        = false,
    OriginalColors    = nil,
    BurnEndTime       = 0,
}

-- ═══════════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════════
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function corner(p, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end
local function stroke(p, c, t, tr) return new("UIStroke", {Color = c or COLOR.BorderBlue, Thickness = t or 1.5, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p}) end
local function grad(p, c1, c2, r) return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = r or 0, Parent = p}) end

local function tween(inst, props, time, style, dir)
    return TweenService:Create(inst, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function httpGet(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end
    local ok, resp = pcall(function()
        return req({Url = url, Method = "GET"})
    end)
    if ok and resp and resp.Body then
        local ok2, data = pcall(function()
            return HttpService:JSONDecode(resp.Body)
        end)
        if ok2 then return data end
    end
    return nil
end

local function getHWID()
    local hwid = nil
    pcall(function() if gethwid then hwid = gethwid() end end)
    if hwid then return hwid end
    pcall(function() if syn and syn.get_hwid then hwid = syn.get_hwid() end end)
    if hwid then return hwid end
    local userId = tostring(LocalPlayer.UserId)
    local clientId = "unknown"
    pcall(function() clientId = game:GetService("RbxAnalyticsService"):GetClientId() end)
    return "FB_" .. userId .. "_" .. clientId
end

local function saveKey(key)
    if not writefile then return end
    pcall(function() writefile(KEY_FILE, key) end)
end

local function loadKey()
    if not (isfile and readfile) then return nil end
    local ok, key = pcall(function()
        if isfile(KEY_FILE) then return readfile(KEY_FILE) end
    end)
    if ok and key and key ~= "" then return key end
    return nil
end

local function verifyKey(key)
    local hwid = getHWID()
    local url = WORKER_URL .. "/api/verify-key?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)
    local data = httpGet(url)
    if not data then return nil, "Gagal konek ke server" end
    if data.valid then return data, nil end
    return nil, data.error or "Key tidak valid"
end

local function saveConfig()
    if not writefile then return end
    local data = {
        UIBind = State.UIBind.Name,
        PrisonBind = State.PrisonBind.Name,
        PushBind = State.PushBind.Name,
        PushLeftBind = State.PushLeftBind.Name,
        PushRightBind = State.PushRightBind.Name,
        LightningBind = State.LightningBind.Name,
        MonkeyBind = State.MonkeyBind.Name,
        Checkpoints = State.Checkpoints,
    }
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(data)) end)
end

local function loadConfig()
    if not (isfile and readfile) then return end
    pcall(function()
        if isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            local binds = {
                {key="UIBind", state="UIBind"},
                {key="PrisonBind", state="PrisonBind"},
                {key="PushBind", state="PushBind"},
                {key="PushLeftBind", state="PushLeftBind"},
                {key="PushRightBind", state="PushRightBind"},
                {key="LightningBind", state="LightningBind"},
                {key="MonkeyBind", state="MonkeyBind"},
            }
            for _, b in ipairs(binds) do
                if data[b.key] then
                    local ok, kc = pcall(function() return Enum.KeyCode[data[b.key]] end)
                    if ok and kc then State[b.state] = kc end
                end
            end
            if data.Checkpoints and type(data.Checkpoints) == "table" then
                State.Checkpoints = data.Checkpoints
            end
        end
    end)
end

local function isTextBoxFocused()
    return UserInputService:GetFocusedTextBox() ~= nil
end

local function formatKey(kc)
    if not kc then return "?" end
    return tostring(kc.Name)
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            local vp = Camera.ViewportSize
            local sz = frame.AbsoluteSize
            frame.Position = UDim2.new(
                0, math.clamp(startPos.X.Offset + delta.X, 0, math.max(0, vp.X - sz.X)),
                0, math.clamp(startPos.Y.Offset + delta.Y, 0, math.max(0, vp.Y - sz.Y))
            )
        end
    end)
end

local function getFeetY(char)
    local lowest = math.huge
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            local bot = p.Position.Y - (p.Size.Y / 2)
            if bot < lowest then lowest = bot end
        end
    end
    if lowest == math.huge then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        lowest = hrp and (hrp.Position.Y - 3) or 0
    end
    return lowest
end

-- ═══════════════════════════════════════════════════════════════
-- CLEANUP
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    local old = CoreGui:FindFirstChild("LuxxysKeyUI")
    if old then old:Destroy() end
    local old2 = CoreGui:FindFirstChild("LuxxysStreamerUI")
    if old2 then old2:Destroy() end
    local oldJail = workspace:FindFirstChild(CFG.FolderName)
    if oldJail then oldJail:Destroy() end
    local oldMonkeys = workspace:FindFirstChild(CFG.MonkeyFolder)
    if oldMonkeys then oldMonkeys:Destroy() end
end)

loadConfig()

-- ═══════════════════════════════════════════════════════════════
-- FORWARD DECLARATION — biar bisa dipanggil dari buildKeyUI
-- ═══════════════════════════════════════════════════════════════
local buildStreamerUI = nil

-- ═══════════════════════════════════════════════════════════════
-- STREAMER UI — DIPINDAH KE ATAS DULU
-- ═══════════════════════════════════════════════════════════════
buildStreamerUI = function()
    print("[LUXXYS] Building Streamer UI...")

    local old = CoreGui:FindFirstChild("LuxxysStreamerUI")
    if old then old:Destroy() end

    local sg = new("ScreenGui", {
        Name = "LuxxysStreamerUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    -- Prison Timer
    local PrisonTimer = new("Frame", {
        Size = UDim2.new(0, 220, 0, 44),
        Position = UDim2.new(0.5, -110, 0, 90),
        BackgroundColor3 = COLOR.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = sg,
    })
    corner(PrisonTimer, 10)
    stroke(PrisonTimer, COLOR.Error, 2)
    grad(PrisonTimer, COLOR.Error, Color3.fromRGB(180, 40, 40), 45)

    local PrisonTimerLabel = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "PRISON TIME: 0s",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 51,
        Parent = PrisonTimer,
    })

    -- Burn Timer
    local BurnTimer = new("Frame", {
        Size = UDim2.new(0, 220, 0, 44),
        Position = UDim2.new(0.5, -110, 0, 40),
        BackgroundColor3 = COLOR.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = sg,
    })
    corner(BurnTimer, 10)
    stroke(BurnTimer, Color3.fromRGB(255, 140, 60), 2)
    grad(BurnTimer, Color3.fromRGB(255, 140, 60), Color3.fromRGB(180, 60, 20), 45)

    local BurnTimerLabel = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔥 BURNED: 0s",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 51,
        Parent = BurnTimer,
    })

    -- Main Panel
    local vp = Camera.ViewportSize
    local startX = math.max(10, vp.X - CFG.UIWidth - 20)
    local startY = math.max(10, (vp.Y - CFG.UIHeight) / 2)

    local Panel = new("Frame", {
        Size = UDim2.new(0, CFG.UIWidth, 0, CFG.UIHeight),
        Position = UDim2.new(0, startX, 0, startY),
        BackgroundColor3 = COLOR.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
        ZIndex = 10,
        Parent = sg,
    })
    corner(Panel, 14)
    stroke(Panel, COLOR.Cyan, 2)
    grad(Panel, Color3.fromRGB(80, 190, 255), Color3.fromRGB(200, 240, 255), 45)
    makeDraggable(Panel)

    -- Header
    local Header = new("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLOR.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = Panel,
    })
    corner(Header, 14)

    local headerGrad = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(80, 190, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = Header,
    })
    corner(headerGrad, 14)
    grad(headerGrad, Color3.fromRGB(80, 190, 255), Color3.fromRGB(0, 220, 255), 0)

    new("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = "STREAMER LUXXY",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 15,
        Parent = Header,
    })

    local CloseBtn = new("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -30, 0.5, -12),
        BackgroundColor3 = COLOR.Error,
        Text = "X",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 15,
        Parent = Header,
    })
    corner(CloseBtn, 5)

    local CyanLine = new("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = COLOR.Cyan,
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = Panel,
    })
    local cyanGrad = grad(CyanLine, COLOR.Cyan, Color3.fromRGB(80, 190, 255), 0)
    task.spawn(function()
        while cyanGrad.Parent do
            cyanGrad.Offset = Vector2.new(-1, 0)
            tween(cyanGrad, {Offset = Vector2.new(1, 0)}, 1.5, Enum.EasingStyle.Linear):Play()
            task.wait(1.5)
        end
    end)

    local BodyScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -12, 1, -94),
        Position = UDim2.new(0, 6, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLOR.Cyan,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 11,
        Parent = Panel,
    })
    new("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = BodyScroll})
    new("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6), Parent = BodyScroll})

    -- Keybind Section
    local kbSection = new("Frame", {
        Size = UDim2.new(1, 0, 0, 330),
        BackgroundColor3 = COLOR.Dark,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ZIndex = 12,
        Parent = BodyScroll,
    })
    corner(kbSection, 8)
    stroke(kbSection, Color3.fromRGB(80, 190, 255), 1)

    new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = "⌨️ KEYBIND SETTINGS",
        TextColor3 = COLOR.Cyan,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        Parent = kbSection,
    })

    local function makeKbRow(label, y, getKey, clr)
        local row = new("Frame", {
            Size = UDim2.new(1, -20, 0, 26),
            Position = UDim2.new(0, 10, 0, y),
            BackgroundTransparency = 1,
            ZIndex = 13,
            Parent = kbSection,
        })
        new("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Color3.fromRGB(200, 240, 255),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 14,
            Parent = row,
        })
        local btn = new("TextButton", {
            Size = UDim2.new(0, 80, 1, 0),
            Position = UDim2.new(1, -80, 0, 0),
            BackgroundColor3 = clr or Color3.fromRGB(80, 190, 255),
            Text = formatKey(getKey()),
            TextColor3 = COLOR.White,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            BorderSizePixel = 0,
            ZIndex = 14,
            Parent = row,
        })
        corner(btn, 5)
        return btn
    end

    local uiKbBtn = makeKbRow("Open UI", 28, function() return State.UIBind end)
    local prisonKbBtn = makeKbRow("Prison +Time", 56, function() return State.PrisonBind end, COLOR.Error)
    local pushKbBtn = makeKbRow("Push Random", 84, function() return State.PushBind end, COLOR.Purple)
    local pushLeftKbBtn = makeKbRow("Push Left", 112, function() return State.PushLeftBind end, COLOR.Purple)
    local pushRightKbBtn = makeKbRow("Push Right", 140, function() return State.PushRightBind end, COLOR.Purple)
    local lightningKbBtn = makeKbRow("Lightning Strike", 168, function() return State.LightningBind end, COLOR.Warning)
    local monkeyKbBtn = makeKbRow("Monkey Push 🐒", 196, function() return State.MonkeyBind end, Color3.fromRGB(180, 130, 70))

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.new(0, 10, 0, 228),
        BackgroundTransparency = 1,
        Text = "📍 CHECKPOINT",
        TextColor3 = COLOR.Cyan,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        Parent = kbSection,
    })

    local cpInput = new("TextBox", {
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 10, 0, 246),
        BackgroundColor3 = COLOR.Darker,
        BackgroundTransparency = 0.2,
        Text = "",
        PlaceholderText = "Nama tempat...",
        PlaceholderColor3 = Color3.fromRGB(120, 150, 180),
        TextColor3 = COLOR.White,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0,
        ZIndex = 13,
        Parent = kbSection,
    })
    corner(cpInput, 6)
    stroke(cpInput, Color3.fromRGB(80, 190, 255), 1)
    new("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = cpInput})

    local cpSaveBtn = new("TextButton", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 278),
        BackgroundColor3 = COLOR.Success,
        Text = "💾 SAVE POSITION",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 13,
        Parent = kbSection,
    })
    corner(cpSaveBtn, 6)

    -- Monkey Toggle Row
    local monkeyToggleRow = new("Frame", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 10, 0, 306),
        BackgroundTransparency = 1,
        ZIndex = 13,
        Parent = kbSection,
    })

    new("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🐒 Monkey Push:",
        TextColor3 = Color3.fromRGB(255, 220, 180),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14,
        Parent = monkeyToggleRow,
    })

    local monkeyToggleBtn = new("TextButton", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundColor3 = COLOR.Error,
        Text = "OFF",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0,
        ZIndex = 14,
        Parent = monkeyToggleRow,
    })
    corner(monkeyToggleBtn, 5)

    -- Checkpoint List Section
    local cpSection = new("Frame", {
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = COLOR.Dark,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        ZIndex = 12,
        Parent = BodyScroll,
    })
    corner(cpSection, 8)
    stroke(cpSection, Color3.fromRGB(80, 190, 255), 1)

    new("TextLabel", {
        Size = UDim2.new(1, -20, 0, 14),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = "📍 SAVED POSITIONS",
        TextColor3 = COLOR.Cyan,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
        Parent = cpSection,
    })

    local cpScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -32),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundColor3 = COLOR.Darker,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = COLOR.Cyan,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 13,
        Parent = cpSection,
    })
    corner(cpScroll, 6)
    new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = cpScroll})
    new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = cpScroll})

    -- ═══════════════════════════════════════════════════════════
    -- HELPER FUNCTIONS
    -- ═══════════════════════════════════════════════════════════
    local function flyTo(targetPos)
        if State.IsFlying then return end
        State.IsFlying = true
        local char = LocalPlayer.Character
        if not char then State.IsFlying = false return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp then State.IsFlying = false return end

        local startPos = hrp.Position
        local dist = (targetPos - startPos).Magnitude
        local dur = math.clamp(dist / 120, 0.6, CFG.FlyDuration)
        local arcH = math.clamp(dist * 0.4, 30, CFG.FlyArcHeight)

        if humanoid then
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
        end

        hrp.Velocity = Vector3.new(0, 0, 0)
        local spinA = 0
        local st = tick()

        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            local el = tick() - st
            local t = math.clamp(el / dur, 0, 1)
            local lerp = startPos:Lerp(targetPos, t)
            local arc = math.sin(t * math.pi) * arcH
            local newPos = lerp + Vector3.new(0, arc, 0)
            spinA = spinA + dt * 720
            hrp.CFrame = CFrame.new(newPos) * CFrame.Angles(0, math.rad(spinA), 0)
            hrp.Velocity = Vector3.new(0, 0, 0)
            if t >= 1 then
                conn:Disconnect()
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid.AutoRotate = true
                end
                State.IsFlying = false
            end
        end)
    end

    local function applyPush(vel)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.Velocity = vel
        local spin = Instance.new("BodyAngularVelocity")
        spin.AngularVelocity = Vector3.new(math.random(-30, 30), math.random(-30, 30), math.random(-30, 30))
        spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        spin.P = 5000
        spin.Parent = hrp
        Debris:AddItem(spin, 2)
        pcall(function()
            local blur = Instance.new("BlurEffect")
            blur.Size = 15
            blur.Parent = Camera
            TweenService:Create(blur, TweenInfo.new(1.5), {Size = 0}):Play()
            Debris:AddItem(blur, 1.6)
        end)
    end

    local function pushRandom()
        local ang = math.random() * math.pi * 2
        local p = CFG.PushPower
        applyPush(Vector3.new(math.cos(ang) * p, CFG.PushUpPower, math.sin(ang) * p))
    end

    local function pushLeft()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local d = -hrp.CFrame.RightVector
        applyPush(Vector3.new(d.X * CFG.PushPower, CFG.PushUpPower, d.Z * CFG.PushPower))
    end

    local function pushRight()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local d = hrp.CFrame.RightVector
        applyPush(Vector3.new(d.X * CFG.PushPower, CFG.PushUpPower, d.Z * CFG.PushPower))
    end

    -- LIGHTNING
    local function saveBodyColors(char)
        local saved = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                saved[p] = p.Color
            end
        end
        return saved
    end

    local function restoreBodyColors(saved)
        for p, c in pairs(saved) do
            if p and p.Parent then
                pcall(function() TweenService:Create(p, TweenInfo.new(0.5), {Color = c}):Play() end)
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("Decal") then
                    pcall(function() TweenService:Create(p, TweenInfo.new(0.5), {Transparency = 0}):Play() end)
                end
            end
        end
    end

    local function createBolt(startPos, endPos, width)
        local folder = Instance.new("Folder")
        folder.Name = "LightningBolt"
        local seg = CFG.LightningSegments
        local cur = startPos
        for i = 1, seg do
            local t = i / seg
            local tgt = startPos:Lerp(endPos, t)
            local om = 6 * (1 - t)
            local off = Vector3.new((math.random() - 0.5) * om, 0, (math.random() - 0.5) * om)
            local nxt = tgt + off
            local dist = (nxt - cur).Magnitude
            local mid = (cur + nxt) / 2
            new("Part", {
                Size = Vector3.new(width, width, dist),
                CFrame = CFrame.lookAt(mid, nxt),
                Anchored = true, CanCollide = false,
                Material = Enum.Material.Neon,
                Color = Color3.fromRGB(200, 240, 255),
                Transparency = 0.1, CastShadow = false,
                Parent = folder,
            })
            cur = nxt
        end
        new("Part", {
            Size = Vector3.new(width * 2, width * 2, width * 2),
            CFrame = CFrame.new(endPos),
            Anchored = true, CanCollide = false,
            Material = Enum.Material.Neon,
            Color = Color3.fromRGB(255, 255, 255),
            Shape = Enum.PartType.Ball,
            Parent = folder,
        })
        return folder
    end

    local function createSparks(pos)
        local att = new("Attachment", {WorldPosition = pos, Parent = workspace.Terrain})
        local em = new("ParticleEmitter", {
            Texture = "rbxassetid://243661504",
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 240, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200)),
            }),
            Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 2), NumberSequenceKeypoint.new(1, 0)}),
            Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
            Lifetime = NumberRange.new(0.4, 0.8),
            Speed = NumberRange.new(30, 60),
            SpreadAngle = Vector2.new(180, 180),
            Rate = 0, Parent = att,
        })
        em:Emit(CFG.LightningSparkCount)
        Debris:AddItem(em, 2)
        Debris:AddItem(att, 2)
    end

    local function screenFlash()
        local fsg = new("ScreenGui", {
            Name = "LuxxysFlash", ResetOnSpawn = false,
            IgnoreGuiInset = true, DisplayOrder = 999,
            Parent = LocalPlayer:WaitForChild("PlayerGui"),
        })
        local flash = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0, Parent = fsg,
        })
        TweenService:Create(flash, TweenInfo.new(CFG.LightningFlashDur), {BackgroundTransparency = 1}):Play()
        Debris:AddItem(fsg, CFG.LightningFlashDur + 0.2)
    end

    local function cameraShake()
        local orig = Camera.CFrame
        local st = tick()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if tick() - st >= CFG.LightningShakeDur then conn:Disconnect() return end
            local inten = CFG.LightningShakeInt * (1 - (tick() - st) / CFG.LightningShakeDur)
            Camera.CFrame = orig * CFrame.new(
                (math.random() - 0.5) * inten,
                (math.random() - 0.5) * inten,
                (math.random() - 0.5) * inten
            )
        end)
    end

    local function lightingFlash()
        local oa, ob = Lighting.Ambient, Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(200, 220, 255)
        Lighting.Brightness = 5
        TweenService:Create(Lighting, TweenInfo.new(CFG.LightningFlashDur), {
            Ambient = oa, Brightness = ob,
        }):Play()
    end

    local function playThunder()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local th = new("Sound", {
            SoundId = CFG.ThunderSoundId,
            Volume = CFG.ThunderVolume,
            Pitch = CFG.ThunderPitch,
            Parent = hrp,
        })
        th:Play()
        Debris:AddItem(th, 5)
        task.wait(0.3)
        local rb = new("Sound", {
            SoundId = "rbxassetid://5623569613",
            Volume = 1.2, Pitch = 0.7, Parent = hrp,
        })
        rb:Play()
        Debris:AddItem(rb, 6)
    end

    local function strikeLightning()
        if State.IsStriking then return end
        State.IsStriking = true
        local char = LocalPlayer.Character
        if not char then State.IsStriking = false return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then State.IsStriking = false return end

        if not State.OriginalColors then
            State.OriginalColors = saveBodyColors(char)
        end

        screenFlash()
        cameraShake()
        lightingFlash()

        local strikePos = hrp.Position
        local skyPos = strikePos + Vector3.new(0, CFG.LightningHeight, 0)
        local main = createBolt(skyPos, strikePos, CFG.LightningWidth)
        main.Parent = workspace

        for i = 1, CFG.LightningBoltCount do
            local off = Vector3.new((math.random() - 0.5) * 20, 0, (math.random() - 0.5) * 20)
            local br = createBolt(skyPos + off, strikePos + off, CFG.LightningWidth * 0.7)
            br.Parent = workspace
            Debris:AddItem(br, 0.5)
        end

        createSparks(strikePos)
        task.spawn(playThunder)

        task.wait(0.1)
        task.spawn(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    TweenService:Create(p, TweenInfo.new(0.3), {Color = CFG.LightningSkinColor}):Play()
                end
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("Decal") then
                    TweenService:Create(p, TweenInfo.new(0.3), {Transparency = 0.7}):Play()
                end
            end
        end)

        Debris:AddItem(main, 0.5)

        local now = tick()
        if State.BurnEndTime > now then
            State.BurnEndTime = State.BurnEndTime + CFG.LightningBurnTime
        else
            State.BurnEndTime = now + CFG.LightningBurnTime
        end

        BurnTimer.Visible = true
        BurnTimerLabel.Text = "🔥 BURNED: " .. math.floor(State.BurnEndTime - now) .. "s"

        task.spawn(function()
            while tick() < State.BurnEndTime do task.wait(0.5) end
            if State.OriginalColors then
                local c = LocalPlayer.Character
                if c then restoreBodyColors(State.OriginalColors) end
                State.OriginalColors = nil
            end
            State.BurnEndTime = 0
            BurnTimer.Visible = false
        end)

        task.wait(0.5)
        State.IsStriking = false
    end

    -- MONKEY PUSH 🐒
    local function createMonkey(pos, facing)
        local folder = Instance.new("Folder")
        folder.Name = "Monkey"
        folder.Parent = workspace:FindFirstChild(CFG.MonkeyFolder) or workspace

        local bodyColor = Color3.fromRGB(120, 80, 50)
        local faceColor = Color3.fromRGB(200, 160, 120)
        local eyeColor = Color3.fromRGB(0, 0, 0)

        local function makePart(name, size, cframe, color)
            local p = Instance.new("Part")
            p.Name = name
            p.Size = size
            p.CFrame = cframe
            p.Anchored = true
            p.CanCollide = false
            p.Material = Enum.Material.SmoothPlastic
            p.Color = color
            p.TopSurface = Enum.SurfaceType.Smooth
            p.BottomSurface = Enum.SurfaceType.Smooth
            p.Parent = folder
            return p
        end

        local sz = CFG.MonkeySize
        local cf = CFrame.new(pos, pos + facing)

        makePart("Body", Vector3.new(sz, sz * 1.2, sz * 0.8), cf, bodyColor)
        makePart("Head", Vector3.new(sz * 0.9, sz * 0.9, sz * 0.9), cf * CFrame.new(0, sz * 1.05, 0), bodyColor)
        makePart("Face", Vector3.new(sz * 0.6, sz * 0.5, sz * 0.1), cf * CFrame.new(0, sz * 1.05, sz * 0.45), faceColor)
        makePart("EyeL", Vector3.new(sz * 0.15, sz * 0.15, sz * 0.15), cf * CFrame.new(-sz * 0.2, sz * 1.15, sz * 0.5), eyeColor)
        makePart("EyeR", Vector3.new(sz * 0.15, sz * 0.15, sz * 0.15), cf * CFrame.new(sz * 0.2, sz * 1.15, sz * 0.5), eyeColor)
        makePart("ArmL", Vector3.new(sz * 0.25, sz * 1, sz * 0.25), cf * CFrame.new(-sz * 0.65, sz * 0.3, 0), bodyColor)
        makePart("ArmR", Vector3.new(sz * 0.25, sz * 1, sz * 0.25), cf * CFrame.new(sz * 0.65, sz * 0.3, 0), bodyColor)
        makePart("LegL", Vector3.new(sz * 0.3, sz * 0.8, sz * 0.3), cf * CFrame.new(-sz * 0.25, -sz * 0.9, 0), bodyColor)
        makePart("LegR", Vector3.new(sz * 0.3, sz * 0.8, sz * 0.3), cf * CFrame.new(sz * 0.25, -sz * 0.9, 0), bodyColor)

        return folder
    end

    local function startMonkeys()
        if State.IsMonkeyActive then return end
        State.IsMonkeyActive = true

        local old = workspace:FindFirstChild(CFG.MonkeyFolder)
        if old then old:Destroy() end

        local folder = Instance.new("Folder")
        folder.Name = CFG.MonkeyFolder
        folder.Parent = workspace

        State.Monkeys = {}
        local dirs = {
            Vector3.new(0, 0, 1),
            Vector3.new(0, 0, -1),
            Vector3.new(1, 0, 0),
            Vector3.new(-1, 0, 0),
        }

        task.spawn(function()
            while State.IsMonkeyActive and folder.Parent do
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local center = hrp.Position
                        local dist = CFG.MonkeyDistance

                        for i, dir in ipairs(dirs) do
                            local targetPos = center + dir * dist
                            local facing = -dir
                            if not State.Monkeys[i] or not State.Monkeys[i].Parent then
                                State.Monkeys[i] = createMonkey(targetPos, facing)
                            else
                                local cf = CFrame.new(targetPos, targetPos + facing)
                                local parts = {
                                    Body = cf,
                                    Head = cf * CFrame.new(0, CFG.MonkeySize * 1.05, 0),
                                    Face = cf * CFrame.new(0, CFG.MonkeySize * 1.05, CFG.MonkeySize * 0.45),
                                    EyeL = cf * CFrame.new(-CFG.MonkeySize * 0.2, CFG.MonkeySize * 1.15, CFG.MonkeySize * 0.5),
                                    EyeR = cf * CFrame.new(CFG.MonkeySize * 0.2, CFG.MonkeySize * 1.15, CFG.MonkeySize * 0.5),
                                    ArmL = cf * CFrame.new(-CFG.MonkeySize * 0.65, CFG.MonkeySize * 0.3, 0),
                                    ArmR = cf * CFrame.new(CFG.MonkeySize * 0.65, CFG.MonkeySize * 0.3, 0),
                                    LegL = cf * CFrame.new(-CFG.MonkeySize * 0.25, -CFG.MonkeySize * 0.9, 0),
                                    LegR = cf * CFrame.new(CFG.MonkeySize * 0.25, -CFG.MonkeySize * 0.9, 0),
                                }
                                for pname, cf2 in pairs(parts) do
                                    local p = State.Monkeys[i]:FindFirstChild(pname)
                                    if p then p.CFrame = cf2 end
                                end
                            end
                        end
                    end
                end
                task.wait(CFG.MonkeyPushSpeed)
            end
        end)

        task.spawn(function()
            while State.IsMonkeyActive and folder.Parent do
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if hrp and humanoid and humanoid.Health > 0 then
                        local center = Vector3.new(0, 0, 0)
                        local count = 0
                        for _, m in pairs(State.Monkeys) do
                            local body = m:FindFirstChild("Body")
                            if body then
                                center = center + body.Position
                                count = count + 1
                            end
                        end
                        if count > 0 then
                            center = center / count
                            local dir = (center - hrp.Position)
                            dir = Vector3.new(dir.X, 0, dir.Z)
                            if dir.Magnitude > 0.5 then
                                dir = dir.Unit * CFG.MonkeyForce
                                local curVel = hrp.Velocity
                                hrp.Velocity = Vector3.new(
                                    curVel.X * 0.7 + dir.X * 0.3,
                                    curVel.Y,
                                    curVel.Z * 0.7 + dir.Z * 0.3
                                )
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
    end

    local function stopMonkeys()
        State.IsMonkeyActive = false
        local folder = workspace:FindFirstChild(CFG.MonkeyFolder)
        if folder then folder:Destroy() end
        State.Monkeys = {}
    end

    local function toggleMonkeys()
        if State.IsMonkeyActive then
            stopMonkeys()
            monkeyToggleBtn.Text = "OFF"
            monkeyToggleBtn.BackgroundColor3 = COLOR.Error
        else
            startMonkeys()
            monkeyToggleBtn.Text = "ON"
            monkeyToggleBtn.BackgroundColor3 = COLOR.Success
        end
    end

    monkeyToggleBtn.MouseButton1Click:Connect(toggleMonkeys)

    -- PRISON
    local function buildPrison()
        if State.PrisonFolder then State.PrisonFolder:Destroy() State.PrisonFolder = nil end
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local feetY = getFeetY(char)
        local center = Vector3.new(hrp.Position.X, feetY, hrp.Position.Z)
        State.PrisonCenter = center

        local folder = Instance.new("Folder")
        folder.Name = CFG.FolderName
        folder.Parent = workspace
        State.PrisonFolder = folder

        local W, H, L, T = CFG.PrisonWidth, CFG.PrisonHeight, CFG.PrisonLength, CFG.BarThickness
        local floorY = feetY + 0.25
        local roofY = feetY + H
        local barCY = feetY + (H / 2)

        local function makePart(name, size, cf, color)
            local p = Instance.new("Part")
            p.Name = name; p.Size = size; p.CFrame = cf
            p.Anchored = true; p.CanCollide = true
            p.Material = Enum.Material.Metal; p.Color = color
            p.TopSurface = Enum.SurfaceType.Smooth
            p.BottomSurface = Enum.SurfaceType.Smooth
            p.Parent = folder
        end

        makePart("Floor", Vector3.new(W, 0.5, L), CFrame.new(center.X, floorY, center.Z), Color3.fromRGB(70, 70, 80))
        makePart("Roof", Vector3.new(W, 0.5, L), CFrame.new(center.X, roofY, center.Z), Color3.fromRGB(70, 70, 80))

        local barColor = Color3.fromRGB(120, 120, 130)
        local function barsX(base, len)
            local n = math.floor(len / CFG.BarSpacing)
            local sp = len / (n + 1)
            for i = 1, n do
                makePart("Bar", Vector3.new(T, H, T), CFrame.new(base + Vector3.new(-len/2 + i*sp, 0, 0)), barColor)
            end
        end
        local function barsZ(base, len)
            local n = math.floor(len / CFG.BarSpacing)
            local sp = len / (n + 1)
            for i = 1, n do
                makePart("Bar", Vector3.new(T, H, T), CFrame.new(base + Vector3.new(0, 0, -len/2 + i*sp)), barColor)
            end
        end
        barsX(Vector3.new(center.X, barCY, center.Z + L/2), W)
        barsX(Vector3.new(center.X, barCY, center.Z - L/2), W)
        barsZ(Vector3.new(center.X - W/2, barCY, center.Z), L)
        barsZ(Vector3.new(center.X + W/2, barCY, center.Z), L)

        local function horiz(pos, sx, sz)
            makePart("Frame", Vector3.new(sx, T, sz), CFrame.new(pos), Color3.fromRGB(140, 140, 150))
        end
        horiz(Vector3.new(center.X, roofY-0.3, center.Z+L/2), W, T)
        horiz(Vector3.new(center.X, roofY-0.3, center.Z-L/2), W, T)
        horiz(Vector3.new(center.X-W/2, roofY-0.3, center.Z), T, L)
        horiz(Vector3.new(center.X+W/2, roofY-0.3, center.Z), T, L)
        horiz(Vector3.new(center.X, floorY+0.3, center.Z+L/2), W, T)
        horiz(Vector3.new(center.X, floorY+0.3, center.Z-L/2), W, T)
        horiz(Vector3.new(center.X-W/2, floorY+0.3, center.Z), T, L)
        horiz(Vector3.new(center.X+W/2, floorY+0.3, center.Z), T, L)
        return true
    end

    local function trapChar()
        if not State.IsPrisonActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local c = State.PrisonCenter
        local maxX = CFG.PrisonWidth / 2 - 0.8
        local maxZ = CFG.PrisonLength / 2 - 0.8
        local pos = hrp.Position
        local dx = math.abs(pos.X - c.X)
        local dz = math.abs(pos.Z - c.Z)
        local feetY = c.Y
        local roofY = c.Y + CFG.PrisonHeight
        if pos.Y < feetY - 2 or pos.Y > roofY or dx > maxX or dz > maxZ then
            hrp.CFrame = CFrame.new(Vector3.new(c.X, feetY + 3, c.Z))
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end

    local function activatePrison(time)
        State.IsPrisonActive = true
        State.PrisonTimeLeft = time or CFG.PrisonStartTime
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local feetY = getFeetY(char)
            local hrp = char.HumanoidRootPart
            State.PrisonCenter = Vector3.new(hrp.Position.X, feetY, hrp.Position.Z)
        end
        buildPrison()
        PrisonTimer.Visible = true
    end

    local function deactivatePrison()
        State.IsPrisonActive = false
        State.PrisonTimeLeft = 0
        if State.PrisonFolder then State.PrisonFolder:Destroy() State.PrisonFolder = nil end
        PrisonTimer.Visible = false
    end

    task.spawn(function()
        while true do
            task.wait(1)
            if State.IsPrisonActive then
                State.PrisonTimeLeft = State.PrisonTimeLeft - 1
                if State.PrisonTimeLeft <= 0 then
                    deactivatePrison()
                else
                    PrisonTimerLabel.Text = "PRISON TIME: " .. State.PrisonTimeLeft .. "s"
                end
            end
            if BurnTimer.Visible then
                local left = math.max(0, math.floor(State.BurnEndTime - tick()))
                if left > 0 then
                    BurnTimerLabel.Text = "🔥 BURNED: " .. left .. "s"
                else
                    BurnTimer.Visible = false
                end
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        State.OriginalColors = nil
        State.BurnEndTime = 0
        BurnTimer.Visible = false
        if State.IsPrisonActive then
            task.wait(0.5)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            if hrp then
                local feetY = getFeetY(char)
                State.PrisonCenter = Vector3.new(hrp.Position.X, feetY, hrp.Position.Z)
                buildPrison()
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if State.IsPrisonActive then trapChar() end
    end)

    -- CHECKPOINT RENDER
    local function renderCheckpoints()
        for _, child in ipairs(cpScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        if #State.Checkpoints == 0 then
            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = "Belum ada checkpoint",
                TextColor3 = Color3.fromRGB(120, 150, 180),
                Font = Enum.Font.Gotham,
                TextSize = 10,
                LayoutOrder = 1,
                ZIndex = 14,
                Parent = cpScroll,
            })
            return
        end
        for i, cp in ipairs(State.Checkpoints) do
            local row = new("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = COLOR.Dark,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                LayoutOrder = i,
                ZIndex = 14,
                Parent = cpScroll,
            })
            corner(row, 5)
            stroke(row, Color3.fromRGB(80, 190, 255), 1)
            new("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = cp.name,
                TextColor3 = COLOR.White,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 15,
                Parent = row,
            })
            local bindBtn = new("TextButton", {
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -120, 0.5, -11),
                BackgroundColor3 = cp.keybind and Color3.fromRGB(80, 190, 255) or Color3.fromRGB(60, 60, 70),
                Text = cp.keybind or "SET KEY",
                TextColor3 = COLOR.White,
                Font = Enum.Font.GothamBold,
                TextSize = 9,
                BorderSizePixel = 0,
                ZIndex = 15,
                Parent = row,
            })
            corner(bindBtn, 4)
            bindBtn.MouseButton1Click:Connect(function()
                State.WaitingForCheckpointBind = i
                bindBtn.Text = "..."
                bindBtn.BackgroundColor3 = COLOR.Warning
            end)
            local delBtn = new("TextButton", {
                Size = UDim2.new(0, 22, 0, 22),
                Position = UDim2.new(1, -28, 0.5, -11),
                BackgroundColor3 = COLOR.Error,
                Text = "X",
                TextColor3 = COLOR.White,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                BorderSizePixel = 0,
                ZIndex = 15,
                Parent = row,
            })
            corner(delBtn, 4)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(State.Checkpoints, i)
                saveConfig()
                renderCheckpoints()
            end)
        end
    end

    renderCheckpoints()

    -- EVENTS
    CloseBtn.MouseButton1Click:Connect(function()
        tween(Panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.25):Play()
        task.wait(0.3)
        Panel.Visible = false
    end)

    uiKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "ui"; State.WaitingForCheckpointBind = nil
        uiKbBtn.Text = "..."; uiKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    prisonKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "prison"; State.WaitingForCheckpointBind = nil
        prisonKbBtn.Text = "..."; prisonKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    pushKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "push"; State.WaitingForCheckpointBind = nil
        pushKbBtn.Text = "..."; pushKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    pushLeftKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "pushLeft"; State.WaitingForCheckpointBind = nil
        pushLeftKbBtn.Text = "..."; pushLeftKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    pushRightKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "pushRight"; State.WaitingForCheckpointBind = nil
        pushRightKbBtn.Text = "..."; pushRightKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    lightningKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "lightning"; State.WaitingForCheckpointBind = nil
        lightningKbBtn.Text = "..."; lightningKbBtn.BackgroundColor3 = COLOR.Warning
    end)
    monkeyKbBtn.MouseButton1Click:Connect(function()
        State.WaitingForBind = "monkey"; State.WaitingForCheckpointBind = nil
        monkeyKbBtn.Text = "..."; monkeyKbBtn.BackgroundColor3 = COLOR.Warning
    end)

    cpSaveBtn.MouseButton1Click:Connect(function()
        local name = cpInput.Text
        if name == "" then name = "Checkpoint " .. (#State.Checkpoints + 1) end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        table.insert(State.Checkpoints, {
            name = name,
            position = {x = hrp.Position.X, y = hrp.Position.Y, z = hrp.Position.Z},
            keybind = nil,
        })
        cpInput.Text = ""
        saveConfig()
        renderCheckpoints()
    end)

    -- KEYBIND HANDLING
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if isTextBoxFocused() then return end

        if State.WaitingForBind then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local b = State.WaitingForBind
                if b == "ui" then
                    State.UIBind = input.KeyCode
                    uiKbBtn.Text = formatKey(input.KeyCode)
                    uiKbBtn.BackgroundColor3 = Color3.fromRGB(80, 190, 255)
                elseif b == "prison" then
                    State.PrisonBind = input.KeyCode
                    prisonKbBtn.Text = formatKey(input.KeyCode)
                    prisonKbBtn.BackgroundColor3 = COLOR.Error
                elseif b == "push" then
                    State.PushBind = input.KeyCode
                    pushKbBtn.Text = formatKey(input.KeyCode)
                    pushKbBtn.BackgroundColor3 = COLOR.Purple
                elseif b == "pushLeft" then
                    State.PushLeftBind = input.KeyCode
                    pushLeftKbBtn.Text = formatKey(input.KeyCode)
                    pushLeftKbBtn.BackgroundColor3 = COLOR.Purple
                elseif b == "pushRight" then
                    State.PushRightBind = input.KeyCode
                    pushRightKbBtn.Text = formatKey(input.KeyCode)
                    pushRightKbBtn.BackgroundColor3 = COLOR.Purple
                elseif b == "lightning" then
                    State.LightningBind = input.KeyCode
                    lightningKbBtn.Text = formatKey(input.KeyCode)
                    lightningKbBtn.BackgroundColor3 = COLOR.Warning
                elseif b == "monkey" then
                    State.MonkeyBind = input.KeyCode
                    monkeyKbBtn.Text = formatKey(input.KeyCode)
                    monkeyKbBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 70)
                end
                State.WaitingForBind = nil
                saveConfig()
            end
            return
        end

        if State.WaitingForCheckpointBind then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local idx = State.WaitingForCheckpointBind
                if State.Checkpoints[idx] then
                    State.Checkpoints[idx].keybind = input.KeyCode.Name
                    saveConfig()
                    renderCheckpoints()
                end
                State.WaitingForCheckpointBind = nil
            end
            return
        end

        if input.KeyCode == State.UIBind then
            if Panel.Visible then
                tween(Panel, {Size = UDim2.new(0, 0, 0, 0)}, 0.25):Play()
                task.wait(0.3)
                Panel.Visible = false
            else
                Panel.Visible = true
                Panel.Size = UDim2.new(0, 0, 0, 0)
                tween(Panel, {Size = UDim2.new(0, CFG.UIWidth, 0, CFG.UIHeight)}, 0.3, Enum.EasingStyle.Back):Play()
                renderCheckpoints()
            end
            return
        end

        if input.KeyCode == State.PrisonBind then
            if State.IsPrisonActive then
                State.PrisonTimeLeft = State.PrisonTimeLeft + CFG.PrisonTimeAdd
                PrisonTimerLabel.Text = "PRISON TIME: " .. State.PrisonTimeLeft .. "s"
            else
                activatePrison(CFG.PrisonTimeAdd)
            end
            return
        end

        if input.KeyCode == State.PushBind then pushRandom() return end
        if input.KeyCode == State.PushLeftBind then pushLeft() return end
        if input.KeyCode == State.PushRightBind then pushRight() return end
        if input.KeyCode == State.LightningBind then strikeLightning() return end
        if input.KeyCode == State.MonkeyBind then toggleMonkeys() return end

        for _, cp in ipairs(State.Checkpoints) do
            if cp.keybind and input.KeyCode.Name == cp.keybind then
                flyTo(Vector3.new(cp.position.x, cp.position.y, cp.position.z))
                break
            end
        end
    end)

    print("[LUXXYS] Streamer UI loaded! ✅")
end

-- ═══════════════════════════════════════════════════════════════
-- KEY UI
-- ═══════════════════════════════════════════════════════════════
local function buildKeyUI()
    print("[LUXXYS] Building Key UI...")

    local old = CoreGui:FindFirstChild("LuxxysKeyUI")
    if old then old:Destroy() end

    local sg = new("ScreenGui", {
        Name = "LuxxysKeyUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui,
    })

    local backdrop = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = sg,
    })

    local Main = new("Frame", {
        Size = UDim2.new(0, 420, 0, 340),
        Position = UDim2.new(0.5, -210, 0.5, -170),
        BackgroundColor3 = COLOR.White,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ZIndex = 10,
        Parent = sg,
    })
    corner(Main, 18)

    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLOR.SkyTop),
            ColorSequenceKeypoint.new(0.4, COLOR.SkyMid),
            ColorSequenceKeypoint.new(0.7, COLOR.White),
            ColorSequenceKeypoint.new(1, COLOR.SkyMid),
        }),
        Rotation = 135,
        Parent = Main,
    })

    stroke(Main, COLOR.BorderBlue, 3)

    local Shimmer = new("Frame", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(-0.3, 0, 0, 0),
        BackgroundColor3 = COLOR.White,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = Main,
    })
    corner(Shimmer, 18)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = Shimmer,
    })

    task.spawn(function()
        while Shimmer.Parent do
            Shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
            tween(Shimmer, {Position = UDim2.new(1.3, 0, 0, 0)}, 2.5, Enum.EasingStyle.Linear):Play()
            task.wait(3)
        end
    end)

    new("TextLabel", {
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "🔐 LUXXY PREMIUM ACCESS",
        TextColor3 = COLOR.DarkText,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 20,
        Parent = Main,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 20, 0, 62),
        BackgroundTransparency = 1,
        Text = "Masukkan key untuk akses script",
        TextColor3 = COLOR.ShadowBlue,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 20,
        Parent = Main,
    })

    new("Frame", {
        Size = UDim2.new(1, -80, 0, 1),
        Position = UDim2.new(0, 40, 0, 90),
        BackgroundColor3 = COLOR.BorderBlue,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        ZIndex = 20,
        Parent = Main,
    })

    local Input = new("TextBox", {
        Size = UDim2.new(1, -60, 0, 48),
        Position = UDim2.new(0, 30, 0, 110),
        BackgroundColor3 = COLOR.White,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Luxxy-XXXX-XXXX-XXXX",
        PlaceholderColor3 = Color3.fromRGB(150, 180, 210),
        TextColor3 = COLOR.DarkText,
        Font = Enum.Font.Code,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 20,
        Parent = Main,
    })
    corner(Input, 10)
    stroke(Input, COLOR.BorderBlue, 2)

    local Status = new("TextLabel", {
        Size = UDim2.new(1, -60, 0, 24),
        Position = UDim2.new(0, 30, 0, 168),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = COLOR.ShadowBlue,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 20,
        Parent = Main,
    })

    local VerifyBtn = new("TextButton", {
        Size = UDim2.new(1, -60, 0, 48),
        Position = UDim2.new(0, 30, 0, 200),
        BackgroundColor3 = COLOR.BorderBlue,
        BorderSizePixel = 0,
        Text = "✓ VERIFIKASI KEY",
        TextColor3 = COLOR.White,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        ZIndex = 20,
        Parent = Main,
    })
    corner(VerifyBtn, 10)

    local vGrad = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 180, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 200, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 255)),
        }),
        Parent = VerifyBtn,
    })

    task.spawn(function()
        while vGrad.Parent do
            vGrad.Offset = Vector2.new(-1, 0)
            tween(vGrad, {Offset = Vector2.new(1, 0)}, 2, Enum.EasingStyle.Linear):Play()
            task.wait(2.2)
        end
    end)

    new("TextLabel", {
        Size = UDim2.new(1, -60, 0, 40),
        Position = UDim2.new(0, 30, 0, 258),
        BackgroundTransparency = 1,
        Text = "💬 Belum punya key?\nChat Admin WhatsApp: " .. ADMIN_WA,
        TextColor3 = COLOR.DarkText,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 20,
        Parent = Main,
    })

    local function setStatus(txt, clr)
        Status.Text = txt
        Status.TextColor3 = clr
    end

    local function setBtn(state)
        if state == "loading" then
            VerifyBtn.Text = "⏳ MEMVERIFIKASI..."
            VerifyBtn.BackgroundColor3 = COLOR.Warning
            vGrad.Enabled = false
        elseif state == "valid" then
            VerifyBtn.Text = "✓ AKSES DITERIMA"
            VerifyBtn.BackgroundColor3 = COLOR.Success
        elseif state == "error" then
            VerifyBtn.Text = "✗ AKSES DITOLAK"
            VerifyBtn.BackgroundColor3 = COLOR.Error
            vGrad.Enabled = false
        else
            VerifyBtn.Text = "✓ VERIFIKASI KEY"
            VerifyBtn.BackgroundColor3 = COLOR.BorderBlue
            vGrad.Enabled = true
        end
    end

    local function doVerify()
        local key = Input.Text
        if key == "" or #key < 5 then
            setStatus("❌ Key tidak boleh kosong!", COLOR.Error)
            return
        end

        setStatus("⏳ Memverifikasi ke server...", COLOR.Warning)
        setBtn("loading")

        task.spawn(function()
            local data, err = verifyKey(key)
            if data and data.valid then
                setStatus("✅ Akses diterima! Memuat script...", COLOR.Success)
                setBtn("valid")
                saveKey(key)

                task.wait(1.5)

                tween(Main, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.5):Play()
                tween(backdrop, {BackgroundTransparency = 1}, 0.5):Play()

                task.wait(0.6)
                sg:Destroy()

                if type(buildStreamerUI) == "function" then
                    print("[LUXXYS] Loading Streamer UI...")
                    buildStreamerUI()
                else
                    print("[LUXXYS] ERROR: buildStreamerUI is not a function:", type(buildStreamerUI))
                end
            else
                setStatus("❌ " .. tostring(err), COLOR.Error)
                setBtn("error")
                task.wait(2)
                setBtn("idle")
            end
        end)
    end

    VerifyBtn.MouseButton1Click:Connect(doVerify)
    Input.FocusLost:Connect(function(enter) if enter then doVerify() end end)

    -- Auto login
    task.spawn(function()
        local savedKey = loadKey()
        if not savedKey then return end
        Input.Text = savedKey
        setStatus("⏳ Auto-login...", COLOR.Warning)
        task.wait(0.5)
        local data, err = verifyKey(savedKey)
        if data and data.valid then
            setStatus("✅ Auto-login OK", COLOR.Success)
            task.wait(0.8)
            tween(Main, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, 0.5):Play()
            tween(backdrop, {BackgroundTransparency = 1}, 0.5):Play()
            task.wait(0.6)
            sg:Destroy()
            if type(buildStreamerUI) == "function" then
                print("[LUXXYS] Auto-login → Streamer UI")
                buildStreamerUI()
            end
        else
            setStatus("❌ Key tersimpan invalid.", COLOR.Error)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- START
-- ═══════════════════════════════════════════════════════════════
buildKeyUI()

print("[LUXXY PREMIUM] Loaded! Key UI + Streamer + Monkey Push")
print("Format key: Luxxy-XXXX-XXXX-XXXX")
print("Beli key: WA 082142293503")
