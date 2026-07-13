--[[
    Proton UI - Interface do Menu
    GitHub: DavizeraXxx/Proton-Ui
    Versão: 2.2
]]

local ProtonUI = {
    Open = true,
    SelectedCategory = "Aimbot",
    GUI = {},
    Callbacks = {},
    Options = {
        Aimbot = false,
        AimbotFOV = 100,
        ESPSheriff = false,
        ESPMurder = false,
        ESPGun = false,
        Noclip = false,
        TargetPlayer = nil
    },
    -- Armazenar referências dos elementos criados
    Elements = {}
}

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ======================
-- UTILITÁRIOS
-- ======================
local function createTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    return TweenService:Create(instance, tweenInfo, properties)
end

function ProtonUI:Notify(text, duration)
    if not self.GUI.ScreenGui then return end
    duration = duration or 3
    
    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BackgroundTransparency = 0 -- Fundo 100% opaco
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.Position = UDim2.new(1, -260, 0, 10)
    notif.AnchorPoint = Vector2.new(1, 0)
    notif.ZIndex = 10
    notif.Parent = self.GUI.ScreenGui

    Instance.new("UIStroke", notif).Color = Color3.fromRGB(30, 58, 95)
    Instance.new("UIStroke", notif).Thickness = 1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = notif

    notif.Position = UDim2.new(1, 10, 0, 10)
    local appearTween = createTween(notif, {Position = UDim2.new(1, -260, 0, 10)}, 0.3)
    appearTween:Play()

    task.delay(duration, function()
        if notif.Parent then
            local disappearTween = createTween(notif, {Position = UDim2.new(1, 10, 0, 10)}, 0.3)
            disappearTween:Play()
            disappearTween.Completed:Connect(function() notif:Destroy() end)
        end
    end)
end

-- ======================
-- COMPONENTES UI
-- ======================
function ProtonUI:CreateToggle(parent, text, default, callback, optionKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1 -- Fundo transparente
    label.Text = text

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0, 36, 0, 20)
    button.Position = UDim2.new(1, -36, 0.5, -10)
    button.BackgroundColor3 = default and Color3.fromRGB(30, 58, 95) or Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Text = ""
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    local knob = Instance.new("Frame", button)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default
    local toggleRef = {
        Button = button,
        Knob = knob,
        Label = label,
        State = state,
        SetState = function(newState)
            state = newState
            local targetColor = state and Color3.fromRGB(30, 58, 95) or Color3.fromRGB(60, 60, 60)
            local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            createTween(button, {BackgroundColor3 = targetColor}, 0.2):Play()
            createTween(knob, {Position = targetPos}, 0.2):Play()
            if callback then callback(state) end
        end
    }

    button.MouseButton1Click:Connect(function()
        toggleRef:SetState(not state)
    end)

    -- Armazenar referência para restaurar estado
    if optionKey then
        self.Elements[optionKey] = toggleRef
    end

    return frame, toggleRef
end

function ProtonUI:CreateSlider(parent, text, min, max, default, callback, optionKey)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local thumb = Instance.new("TextButton", bar)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Text = ""
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local currentValue = default
    local sliderRef = {
        SetValue = function(val)
            currentValue = val
            local relX = (val - min) / (max - min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            thumb.Position = UDim2.new(relX, -8, 0.5, -8)
            label.Text = text .. ": " .. val
            if callback then callback(val) end
        end
    }

    local function updateSlider(input)
        local pos = input.Position.X
        local barAbsPos = bar.AbsolutePosition.X
        local barWidth = bar.AbsoluteSize.X
        local relX = math.clamp((pos - barAbsPos) / barWidth, 0, 1)
        local val = math.floor(min + (max - min) * relX)
        sliderRef:SetValue(val)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    if optionKey then
        self.Elements[optionKey] = sliderRef
    end

    return frame, sliderRef
end

function ProtonUI:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Text = text
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        local origSize = btn.Size
        createTween(btn, {Size = UDim2.new(1, -20, 0, 28)}, 0.05):Play()
        task.delay(0.05, function() createTween(btn, {Size = origSize}, 0.05):Play() end)
        if callback then callback() end
    end)

    btn.MouseEnter:Connect(function() 
        createTween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2):Play() 
    end)
    btn.MouseLeave:Connect(function() 
        createTween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2):Play() 
    end)
    return btn
end

function ProtonUI:CreatePlayerList(parent, onSelect)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local searchBox = Instance.new("TextBox", frame)
    searchBox.Size = UDim2.new(1, -10, 0, 24)
    searchBox.Position = UDim2.new(0, 5, 0, 5)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.PlaceholderText = "Buscar jogador..."
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, -10, 1, -34)
    listFrame.Position = UDim2.new(0, 5, 0, 34)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(30, 58, 95)
    Instance.new("UIListLayout", listFrame).SortOrder = Enum.SortOrder.Name

    local function updateList(filter)
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and (filter == "" or player.Name:lower():find(filter:lower())) then
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.Font = Enum.Font.Gotham
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextSize = 14
                btn.Text = player.Name
                btn.MouseButton1Click:Connect(function() 
                    if onSelect then onSelect(player) end 
                end)
            end
        end
    end

    updateList("")
    searchBox.Changed:Connect(function(prop) 
        if prop == "Text" then updateList(searchBox.Text) end 
    end)
    Players.PlayerAdded:Connect(function() updateList(searchBox.Text) end)
    Players.PlayerRemoving:Connect(function() updateList(searchBox.Text) end)

    return frame
end

-- ======================
-- CONSTRUÇÃO DA INTERFACE
-- ======================
function ProtonUI:CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProtonMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = math.clamp(Camera.ViewportSize.X / 1920, 0.8, 1.2)
    uiScale.Parent = screenGui

    self.GUI.ScreenGui = screenGui

    -- Janela principal - Fundo 100% opaco
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0 -- Fundo 100% opaco
    main.BorderSizePixel = 0
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(30, 58, 95)
    mainStroke.Thickness = 1.5
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = main

    self.GUI.MainFrame = main

    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    titleBar.BackgroundTransparency = 0
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

    local bottomLine = Instance.new("Frame")
    bottomLine.Size = UDim2.new(1, 0, 0, 1)
    bottomLine.Position = UDim2.new(0, 0, 1, 0)
    bottomLine.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    bottomLine.BorderSizePixel = 0
    bottomLine.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(0, 150, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Text = "Proton Menu"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local subLabel = Instance.new("TextLabel")
    subLabel.BackgroundTransparency = 1
    subLabel.Size = UDim2.new(0, 40, 1, 0)
    subLabel.Position = UDim2.new(0, 160, 0, 0)
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    subLabel.TextSize = 12
    subLabel.Text = "dev"
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.Parent = titleBar

    -- Minimizar / Fechar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.Position = UDim2.new(1, -52, 0.5, -12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 14
    minimizeBtn.Parent = titleBar
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 4)

    local closeBtn = minimizeBtn:Clone()
    closeBtn.Position = UDim2.new(1, -24, 0.5, -12)
    closeBtn.Text = "X"
    closeBtn.Parent = titleBar

    -- Área de conteúdo
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    contentFrame.BackgroundTransparency = 0
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = main
    self.GUI.ContentFrame = contentFrame

    -- Menu lateral
    local sideMenu = Instance.new("Frame")
    sideMenu.Size = UDim2.new(0, 80, 1, 0)
    sideMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    sideMenu.BackgroundTransparency = 0
    sideMenu.BorderSizePixel = 0
    sideMenu.Parent = contentFrame
    
    local sideList = Instance.new("UIListLayout")
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList.Parent = sideMenu
    self.GUI.SideMenu = sideMenu

    -- Área principal
    local mainArea = Instance.new("Frame")
    mainArea.Size = UDim2.new(1, -80, 1, 0)
    mainArea.Position = UDim2.new(0, 80, 0, 0)
    mainArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainArea.BackgroundTransparency = 0
    mainArea.BorderSizePixel = 0
    mainArea.Parent = contentFrame
    self.GUI.MainArea = mainArea

    -- Rodapé
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    footer.BackgroundTransparency = 0
    footer.BorderSizePixel = 0
    footer.Parent = contentFrame
    
    local footerLine = Instance.new("Frame")
    footerLine.Size = UDim2.new(1, 0, 0, 1)
    footerLine.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    footerLine.BorderSizePixel = 0
    footerLine.Parent = footer

    self.GUI.UsernameLabel = Instance.new("TextLabel", footer)
    self.GUI.UsernameLabel.Size = UDim2.new(0, 100, 1, 0)
    self.GUI.UsernameLabel.Font = Enum.Font.Gotham
    self.GUI.UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.UsernameLabel.TextSize = 12
    self.GUI.UsernameLabel.BackgroundTransparency = 1
    self.GUI.UsernameLabel.Text = LocalPlayer.Name

    self.GUI.FPSLabel = Instance.new("TextLabel", footer)
    self.GUI.FPSLabel.Position = UDim2.new(0, 110, 0, 0)
    self.GUI.FPSLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.FPSLabel.Font = Enum.Font.Gotham
    self.GUI.FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.FPSLabel.TextSize = 12
    self.GUI.FPSLabel.BackgroundTransparency = 1
    self.GUI.FPSLabel.Text = "FPS: 0"

    self.GUI.PingLabel = Instance.new("TextLabel", footer)
    self.GUI.PingLabel.Position = UDim2.new(0, 170, 0, 0)
    self.GUI.PingLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.PingLabel.Font = Enum.Font.Gotham
    self.GUI.PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.PingLabel.TextSize = 12
    self.GUI.PingLabel.BackgroundTransparency = 1
    self.GUI.PingLabel.Text = "Ping: 0"

    self.GUI.TimeLabel = Instance.new("TextLabel", footer)
    self.GUI.TimeLabel.Position = UDim2.new(0, 230, 0, 0)
    self.GUI.TimeLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.TimeLabel.Font = Enum.Font.Gotham
    self.GUI.TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.TimeLabel.TextSize = 12
    self.GUI.TimeLabel.BackgroundTransparency = 1
    self.GUI.TimeLabel.Text = "00:00:00"

    -- Arrastar janela
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = main.Position
            local connection
            connection = UserInputService.InputChanged:Connect(function(input2)
                if input2 == input and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input2.Position - dragStart
                    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then connection:Disconnect() end
            end)
        end
    end)

    -- Minimizar/Restaurar
    local minimized = false
    local originalSize = main.Size
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            createTween(main, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30)}, 0.3):Play()
            contentFrame.Visible = false
        else
            createTween(main, {Size = originalSize}, 0.3):Play()
            contentFrame.Visible = true
        end
    end)

    closeBtn.MouseButton1Click:Connect(function() self:Close() end)

    -- Construir categorias e primeira página
    self:CreateCategoryButtons()
    self:SwitchCategory("Aimbot")
end

-- ======================
-- CATEGORIAS E PÁGINAS
-- ======================
function ProtonUI:CreateCategoryButtons()
    local sideMenu = self.GUI.SideMenu
    for _, child in ipairs(sideMenu:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local categories = {
        {Name = "Aimbot", Icon = "🎯"},
        {Name = "ESP", Icon = "👁️"},
        {Name = "Teleport", Icon = "🚀"},
        {Name = "Logs", Icon = "📋"},
        {Name = "Misc", Icon = "⚙️"},
    }

    for _, cat in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Name = cat.Name
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 14
        btn.Text = cat.Icon .. "  " .. cat.Name
        btn.Parent = sideMenu

        btn.MouseButton1Click:Connect(function() self:SwitchCategory(cat.Name) end)
        btn.MouseEnter:Connect(function()
            if self.SelectedCategory ~= cat.Name then
                createTween(btn, {BackgroundColor3 = Color3.fromRGB(30, 58, 95)}, 0.2):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if self.SelectedCategory ~= cat.Name then
                createTween(btn, {BackgroundColor3 = Color3.fromRGB(10, 10, 10)}, 0.2):Play()
            end
        end)
    end
end

function ProtonUI:SwitchCategory(name)
    self.SelectedCategory = name
    local mainArea = self.GUI.MainArea
    for _, child in ipairs(mainArea:GetChildren()) do
        child:Destroy()
    end

    -- Destaque no menu lateral
    for _, btn in ipairs(self.GUI.SideMenu:GetChildren()) do
        if btn:IsA("TextButton") then
            if btn.Name == name then
                btn.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
                if not btn:FindFirstChild("LeftLine") then
                    local line = Instance.new("Frame", btn)
                    line.Name = "LeftLine"
                    line.Size = UDim2.new(0, 3, 1, 0)
                    line.Position = UDim2.new(0, 0, 0, 0)
                    line.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                    line.BorderSizePixel = 0
                end
            else
                btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                local line = btn:FindFirstChild("LeftLine")
                if line then line:Destroy() end
            end
        end
    end

    -- Chamar callback se existir
    if self.Callbacks[name] then
        self.Callbacks[name]()
    end

    -- Construir páginas padrão se não houver callback
    if name == "Aimbot" then self:BuildAimbotPage()
    elseif name == "ESP" then self:BuildESPPage()
    elseif name == "Teleport" then self:BuildTeleportPage()
    elseif name == "Logs" then self:BuildLogsPage()
    elseif name == "Misc" then self:BuildMiscPage()
    end
end

-- ======================
-- PÁGINAS PADRÃO
-- ======================
function ProtonUI:BuildAimbotPage()
    local main = self.GUI.MainArea
    local y = 10

    -- Restaurar estado salvo
    local aimbotState = self.Options.Aimbot or false
    local fovValue = self.Options.AimbotFOV or 100

    local toggle, toggleRef = self:CreateToggle(main, "Aimbot (Silent)", aimbotState, function(state)
        self.Options.Aimbot = state
        if self.OnToggleChange then self:OnToggleChange("Aimbot", state) end
    end, "Aimbot")
    toggle.Position = UDim2.new(0, 0, 0, y)
    y = y + 35

    local slider, sliderRef = self:CreateSlider(main, "FOV", 10, 360, fovValue, function(val)
        self.Options.AimbotFOV = val
        if self.OnSliderChange then self:OnSliderChange("AimbotFOV", val) end
    end, "AimbotFOV")
    slider.Position = UDim2.new(0, 0, 0, y)
    y = y + 55

    local label = Instance.new("TextLabel", main)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, y)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Text = "Alvo (opcional):"
    y = y + 25

    self:CreatePlayerList(main, function(player)
        self.Options.TargetPlayer = player
        self:Notify("Alvo: " .. player.Name, 2)
        if self.OnPlayerSelect then self:OnPlayerSelect(player) end
    end).Position = UDim2.new(0, 10, 0, y)
end

function ProtonUI:BuildESPPage()
    local main = self.GUI.MainArea
    local y = 10
    
    local sheriffState = self.Options.ESPSheriff or false
    local murderState = self.Options.ESPMurder or false
    local gunState = self.Options.ESPGun or false
    
    local toggle1, ref1 = self:CreateToggle(main, "ESP Sheriff", sheriffState, function(state)
        self.Options.ESPSheriff = state
        if self.OnToggleChange then self:OnToggleChange("ESPSheriff", state) end
    end, "ESPSheriff")
    toggle1.Position = UDim2.new(0, 0, 0, y)
    y = y + 35
    
    local toggle2, ref2 = self:CreateToggle(main, "ESP Murder", murderState, function(state)
        self.Options.ESPMurder = state
        if self.OnToggleChange then self:OnToggleChange("ESPMurder", state) end
    end, "ESPMurder")
    toggle2.Position = UDim2.new(0, 0, 0, y)
    y = y + 35
    
    local toggle3, ref3 = self:CreateToggle(main, "ESP Gun", gunState, function(state)
        self.Options.ESPGun = state
        if self.OnToggleChange then self:OnToggleChange("ESPGun", state) end
    end, "ESPGun")
    toggle3.Position = UDim2.new(0, 0, 0, y)
end

function ProtonUI:BuildTeleportPage()
    self:CreateButton(self.GUI.MainArea, "Teleport Gun do Sheriff", function()
        if self.OnButtonClick then self:OnButtonClick("TeleportSheriffGun") end
    end).Position = UDim2.new(0, 10, 0, 10)
end

function ProtonUI:BuildLogsPage()
    self:CreateButton(self.GUI.MainArea, "Copiar Log (Sheriff & Murder)", function()
        if self.OnButtonClick then self:OnButtonClick("CopyLog") end
    end).Position = UDim2.new(0, 10, 0, 10)
end

function ProtonUI:BuildMiscPage()
    local main = self.GUI.MainArea
    local y = 10
    
    local noclipState = self.Options.Noclip or false
    
    local toggle, ref = self:CreateToggle(main, "Noclip", noclipState, function(state)
        self.Options.Noclip = state
        if self.OnToggleChange then self:OnToggleChange("Noclip", state) end
    end, "Noclip")
    toggle.Position = UDim2.new(0, 0, 