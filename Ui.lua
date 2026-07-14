--[[
    Proton Menu - UI Framework v3.0
    Repositório: Proton-Ui
    Apenas interface visual, sem implementação de cheats.
    Compatível com o Proton-Loader.
--]]

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Variáveis principais (exportadas globalmente para o loader)
getgenv().ProtonMenu = {
    Open = true,
    SelectedCategory = "Aimbot",
    Options = {
        Noclip = false,
        ESPSheriff = false,
        ESPMurder = false,
        Aimbot = false,
        AimbotFOV = 100,
        ESPGun = false,
        TargetPlayer = nil
    },
    GUI = {},
    Cheats = {}, -- Será preenchido pelo loader
    FOVCircle = nil,
    FOVUpdateConnection = nil,
    Loaded = false
}

local ProtonMenu = getgenv().ProtonMenu

-- Utilitários
local function createTween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    return TweenService:Create(instance, tweenInfo, properties)
end

function ProtonMenu:Notify(text, duration)
    if not self.GUI.ScreenGui then return end
    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.Position = UDim2.new(1, -260, 0, 10)
    notif.AnchorPoint = Vector2.new(1, 0)
    notif.ZIndex = 10
    notif.Parent = self.GUI.ScreenGui

    Instance.new("UIStroke", notif).Color = Color3.fromRGB(30, 58, 95)
    Instance.new("UIStroke", notif).Thickness = 1
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel", notif)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text

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

function ProtonMenu:CreateGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProtonMenu"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = math.clamp(Camera.ViewportSize.X / 1920, 0.8, 1.2)
    uiScale.Parent = screenGui

    self.GUI.ScreenGui = screenGui

    -- Janela principal
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 600, 0, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BorderSizePixel = 0
    main.BackgroundTransparency = 1
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
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    
    local bottomLine = Instance.new("Frame", titleBar)
    bottomLine.Size = UDim2.new(1, 0, 0, 1)
    bottomLine.Position = UDim2.new(0, 0, 1, 0)
    bottomLine.BackgroundColor3 = Color3.fromRGB(30, 58, 95)
    bottomLine.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(0, 150, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Text = "Proton Menu"
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local subLabel = Instance.new("TextLabel", titleBar)
    subLabel.BackgroundTransparency = 1
    subLabel.Size = UDim2.new(0, 40, 1, 0)
    subLabel.Position = UDim2.new(0, 160, 0, 0)
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    subLabel.TextSize = 12
    subLabel.Text = "dev"
    subLabel.TextXAlignment = Enum.TextXAlignment.Left

    local minimizeBtn = Instance.new("TextButton", titleBar)
    minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    minimizeBtn.Position = UDim2.new(1, -52, 0.5, -12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 14
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
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = main
    self.GUI.ContentFrame = contentFrame

    -- Menu lateral
    local sideMenu = Instance.new("Frame")
    sideMenu.Size = UDim2.new(0, 80, 1, 0)
    sideMenu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    sideMenu.BorderSizePixel = 0
    sideMenu.Parent = contentFrame
    local sideList = Instance.new("UIListLayout", sideMenu)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    self.GUI.SideMenu = sideMenu

    -- Área principal
    local mainArea = Instance.new("Frame")
    mainArea.Size = UDim2.new(1, -80, 1, 0)
    mainArea.Position = UDim2.new(0, 80, 0, 0)
    mainArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainArea.BorderSizePixel = 0
    mainArea.Parent = contentFrame
    self.GUI.MainArea = mainArea

    -- Rodapé
    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    footer.BorderSizePixel = 0
    footer.Parent = contentFrame
    Instance.new("Frame", footer).Size = UDim2.new(1, 0, 0, 1)
    footer.Frame.BackgroundColor3 = Color3.fromRGB(30, 58, 95)

    self.GUI.UsernameLabel = Instance.new("TextLabel", footer)
    self.GUI.UsernameLabel.Size = UDim2.new(0, 100, 1, 0)
    self.GUI.UsernameLabel.Font = Enum.Font.Gotham
    self.GUI.UsernameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.UsernameLabel.TextSize = 12
    self.GUI.UsernameLabel.Text = LocalPlayer.Name
    self.GUI.UsernameLabel.BackgroundTransparency = 1

    self.GUI.FPSLabel = Instance.new("TextLabel", footer)
    self.GUI.FPSLabel.Position = UDim2.new(0, 110, 0, 0)
    self.GUI.FPSLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.FPSLabel.Font = Enum.Font.Gotham
    self.GUI.FPSLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.FPSLabel.TextSize = 12
    self.GUI.FPSLabel.Text = "FPS: 0"
    self.GUI.FPSLabel.BackgroundTransparency = 1

    self.GUI.PingLabel = Instance.new("TextLabel", footer)
    self.GUI.PingLabel.Position = UDim2.new(0, 170, 0, 0)
    self.GUI.PingLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.PingLabel.Font = Enum.Font.Gotham
    self.GUI.PingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.PingLabel.TextSize = 12
    self.GUI.PingLabel.Text = "Ping: 0"
    self.GUI.PingLabel.BackgroundTransparency = 1

    self.GUI.TimeLabel = Instance.new("TextLabel", footer)
    self.GUI.TimeLabel.Position = UDim2.new(0, 230, 0, 0)
    self.GUI.TimeLabel.Size = UDim2.new(0, 60, 1, 0)
    self.GUI.TimeLabel.Font = Enum.Font.Gotham
    self.GUI.TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    self.GUI.TimeLabel.TextSize = 12
    self.GUI.TimeLabel.Text = "00:00:00"
    self.GUI.TimeLabel.BackgroundTransparency = 1

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

    -- Fade-in
    createTween(main, {BackgroundTransparency = 0}, 0.4):Play()

    -- Criar categorias e primeira página
    self:CreateCategoryButtons()
    self:SwitchCategory("Aimbot")
    
    -- Iniciar footer updates
    self:StartFooterUpdates()
    
    -- Marcar como carregado
    self.Loaded = true
    self:Notify("UI carregada! Aguardando cheats...", 3)
end

-- ... (manter todas as funções de criação de componentes: CreateToggle, CreateSlider, CreateButton, CreatePlayerList, CreateCategoryButtons, SwitchCategory, BuildAimbotPage, BuildESPPage, BuildTeleportPage, BuildLogsPage, BuildMiscPage, StartFooterUpdates, Close)
-- NOTA: Estas funções são idênticas às versões anteriores, apenas SEM a lógica de cheat.
-- Por brevidade, não repetirei aqui, mas você deve mantê-las no arquivo Ui.lua.

-- Retornar o menu para o loader
return ProtonMenu