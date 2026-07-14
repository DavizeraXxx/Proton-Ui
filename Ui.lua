--[[
    Proton UI - Interface do Menu
    GitHub: DavizeraXxx/Proton-Ui
    Versão: 4.3
]]

local ProtonUI = {
    Open = true,
    SelectedTab = "Aimbot",
    Options = {
        Aimbot = false,
        AimbotFOV = 100,
        ShowFOV = true,
        ESPEnabled = true,
        ESPBox = true,
        ESPSkeleton = false,
        ESPName = true,
        ESPDistance = true,
        Noclip = false,
        ESPGun = false,
    },
    GUI = {},
    Callbacks = {},
    Minimized = false
}

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ======================
-- UTILITÁRIOS
-- ======================
local function tween(obj, props, dur)
    local info = TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function ProtonUI:Notify(text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Proton",
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- ======================
-- COMPONENTES
-- ======================
function ProtonUI:CreateToggle(parent, text, option, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = option and Color3.fromRGB(30, 58, 95) or Color3.fromRGB(60, 60, 60)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local knob = Instance.new("Frame", btn)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = option and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)

    local state = option
    btn.MouseButton1Click:Connect(function()
        state = not state
        if callback then callback(state) end
        local c = state and Color3.fromRGB(30, 58, 95) or Color3.fromRGB(60, 60, 60)
        local p = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        tween(btn, {BackgroundColor3 = c}, 0.2)
        tween(knob, {Position = p}, 0.2)
    end)

    return frame
end

function ProtonUI:CreateSlider(parent, text, min, max, value, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = text .. ": " .. value
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.BackgroundTransparency = 1

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local thumb = Instance.new("TextButton", bar)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.Text = ""
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -8, 0.5, -8)
        label.Text = text .. ": " .. val
        if callback then callback(val) end
    end

    thumb.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
        end 
    end)
    
    bar.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
            update(i) 
        end 
    end)
    
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(i) 
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            update(i) 
        end 
    end)

    return frame
end

function ProtonUI:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.Gotham
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    return btn
end

function ProtonUI:CreatePlayerInfo(parent, player, team, color)
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 25)
    info.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    info.Font = Enum.Font.Gotham
    info.Text = "  " .. player .. " - " .. team
    info.TextColor3 = color
    info.TextSize = 14
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = parent
    Instance.new("UICorner", info).CornerRadius = UDim.new(0, 4)
    return info
end

-- ======================
-- CONSTRUIR UI
-- ======================
function ProtonUI:CreateWindow()
    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "ProtonMenu"
    gui.Parent = CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.GUI.ScreenGui = gui

    -- Main
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 550, 0, 400)
    main.Position = UDim2.new(0.5, -275, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(30, 58, 95)
    stroke.Thickness = 1.5
    self.GUI.Main = main
    self.GUI.OriginalSize = main.Size
    self.GUI.OriginalPosition = main.Position

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(0, 150, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Proton Menu"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Botão Minimizar (-)
    local minimizeBtn = Instance.new("TextButton", titleBar)
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -60, 0, 2)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
    minimizeBtn.TextSize = 18
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)
    self.GUI.MinimizeBtn = minimizeBtn

    -- Botão Fechar (×)
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function() self:Close() end)

    -- Minimizar
    minimizeBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        local content = self.GUI.ContentContainer
        local tabs = self.GUI.TabButtons
        
        if self.Minimized then
            -- Minimizar: esconder tudo, deixar só a barra de título
            tween(main, {Size = UDim2.new(0, 550, 0, 30)}, 0.3)
            if content then content.Visible = false end
            for _, btn in pairs(tabs or {}) do
                btn.Visible = false
            end
            minimizeBtn.Text = "+"
        else
            -- Restaurar
            tween(main, {Size = self.GUI.OriginalSize}, 0.3)
            if content then content.Visible = true end
            for _, btn in pairs(tabs or {}) do
                btn.Visible = true
            end
            minimizeBtn.Text = "−"
        end
    end)

    -- Tabs
    local tabs = {"Aimbot", "ESP", "Teleport", "Logs", "Misc"}
    local tabBtns = {}
    
    for i, name in pairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 90, 0, 26)
        btn.Position = UDim2.new(0, 10 + ((i-1) * 95), 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        btn.Font = Enum.Font.Gotham
        btn.Text = name
        btn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
        btn.TextSize = 13
        btn.Parent = main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            self.SelectedTab = name
            for _, b in pairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(20, 20, 20) end
            btn.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
            self:LoadTab(name)
        end)
        
        table.insert(tabBtns, btn)
    end
    tabBtns[1].BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    self.GUI.TabButtons = tabBtns

    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -75)
    contentContainer.Position = UDim2.new(0, 10, 0, 70)
    contentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = main
    Instance.new("UICorner", contentContainer).CornerRadius = UDim.new(0, 4)
    self.GUI.ContentContainer = contentContainer

    -- ScrollingFrame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(30, 58, 95)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = contentContainer
    self.GUI.Content = content

    -- UIListLayout
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = content

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            -- Atualizar posição original para restaurar corretamente
            self.GUI.OriginalPosition = main.Position
        end
    end)

    -- Load first tab
    self:LoadTab("Aimbot")
    self:Notify("UI carregada!")
end

-- ======================
-- CARREGAR TAB
-- ======================
function ProtonUI:LoadTab(name)
    local content = self.GUI.Content
    
    for _, child in pairs(content:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end

    if name == "Aimbot" then
        self:CreateToggle(content, "Aimbot", self.Options.Aimbot, function(v)
            self.Options.Aimbot = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("Aimbot", v) end
        end)
        
        self:CreateSlider(content, "FOV", 50, 300, self.Options.AimbotFOV, function(v)
            self.Options.AimbotFOV = v
            if self.Callbacks.OnSlider then self.Callbacks:OnSlider("AimbotFOV", v) end
        end)
        
        self:CreateToggle(content, "Show FOV Circle", self.Options.ShowFOV, function(v)
            self.Options.ShowFOV = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ShowFOV", v) end
        end)
        
    elseif name == "ESP" then
        self:CreateToggle(content, "Enable ESP", self.Options.ESPEnabled, function(v)
            self.Options.ESPEnabled = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPEnabled", v) end
        end)
        
        self:CreateToggle(content, "Box ESP", self.Options.ESPBox, function(v)
            self.Options.ESPBox = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPBox", v) end
        end)
        
        self:CreateToggle(content, "Skeleton ESP", self.Options.ESPSkeleton, function(v)
            self.Options.ESPSkeleton = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPSkeleton", v) end
        end)
        
        self:CreateToggle(content, "Show Name", self.Options.ESPName, function(v)
            self.Options.ESPName = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPName", v) end
        end)
        
        self:CreateToggle(content, "Show Distance", self.Options.ESPDistance, function(v)
            self.Options.ESPDistance = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPDistance", v) end
        end)
        
    elseif name == "Teleport" then
        self:CreateButton(content, "Teleport to Gun", function()
            if self.Callbacks.OnButton then self.Callbacks:OnButton("TeleportToGun") end
        end)
        
        local divider = Instance.new("Frame", content)
        divider.Size = UDim2.new(1, -20, 0, 1)
        divider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        divider.BorderSizePixel = 0
        
        local label = Instance.new("TextLabel", content)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Font = Enum.Font.GothamBold
        label.Text = "Teleport para Jogador:"
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextSize = 12
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                self:CreateButton(content, player.Name, function()
                    if self.Callbacks.OnButton then self.Callbacks:OnButton("TeleportToPlayer", player) end
                end)
            end
        end
        
    elseif name == "Logs" then
        self:CreateButton(content, "Copy Team Logs", function()
            if self.Callbacks.OnButton then self.Callbacks:OnButton("CopyLogs") end
        end)
        
        local divider = Instance.new("Frame", content)
        divider.Size = UDim2.new(1, -20, 0, 1)
        divider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        divider.BorderSizePixel = 0
        
        local label = Instance.new("TextLabel", content)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Font = Enum.Font.GothamBold
        label.Text = "Jogadores:"
        label.TextColor3 = Color3.fromRGB(150, 150, 150)
        label.TextSize = 12
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local team, color = self:GetPlayerTeam(player)
                self:CreatePlayerInfo(content, player.Name, team, color)
            end
        end
        
    elseif name == "Misc" then
        self:CreateToggle(content, "Noclip", self.Options.Noclip, function(v)
            self.Options.Noclip = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("Noclip", v) end
        end)
        
        self:CreateToggle(content, "ESP Gun (Dropped)", self.Options.ESPGun, function(v)
            self.Options.ESPGun = v
            if self.Callbacks.OnToggle then self.Callbacks:OnToggle("ESPGun", v) end
        end)
    end
    
    -- Atualizar CanvasSize
    task.wait(0.1)
    local totalHeight = 0
    for _, child in pairs(content:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            totalHeight = totalHeight + child.Size.Y.Offset + 5
        end
    end
    content.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight + 20, content.Size.Y.Offset))
end

-- ======================
-- UTILITÁRIO PARA TEAM
-- ======================
function ProtonUI:GetPlayerTeam(player)
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    
    if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Murderer", Color3.fromRGB(255, 50, 50)
    elseif (bp and bp:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return "Sheriff", Color3.fromRGB(50, 100, 255)
    else
        return "Innocent", Color3.fromRGB(50, 255, 50)
    end
end

-- ======================
-- FECHAR
-- ======================
function ProtonUI:Close()
    if self.GUI.ScreenGui then
        self.GUI.ScreenGui:Destroy()
    end
    if self.Callbacks.OnClose then self.Callbacks:OnClose() end
end

return ProtonUI