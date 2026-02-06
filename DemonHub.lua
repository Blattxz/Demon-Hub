-- LocalScript: PremiumDemonHub.lua
-- Colocar em StarterGui ou StarterPlayerScripts

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- Configurações
local SETTINGS = {
	UI_SCALE = 0.85,
	ANIMATION_SPEED = 0.25,
	COLORS = {
		PRIMARY = Color3.fromRGB(15, 15, 15),
		SECONDARY = Color3.fromRGB(30, 30, 30),
		ACCENT = Color3.fromRGB(138, 43, 226), -- Roxo neon
		DANGER = Color3.fromRGB(178, 34, 34), -- Vermelho escuro
		TEXT = Color3.fromRGB(240, 240, 240),
		GLOW = Color3.fromRGB(147, 112, 219)
	},
	ESP = {
		ENABLED = false,
		TEAM_COLOR = true,
		BOX_COLOR = Color3.fromRGB(0, 255, 0),
		NAME_COLOR = Color3.fromRGB(255, 255, 255),
		HEALTH_BAR = true
	},
	AIM_ASSIST = {
		ENABLED = false,
		FOV = 50, -- Graus
		SMOOTHNESS = 0.2,
		TARGET = "NPC" -- "NPC", "Player", "Both"
	}
}

-- Cache de objetos
local guiObjects = {}
local espCache = {}
local aimTarget = nil

-- Criar GUI Base
local function createGUI()
	-- Tela principal
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PremiumDemonHub"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	
	-- Frame de fundo escuro (para blur effect)
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurFrame"
	blurFrame.Size = UDim2.new(1, 0, 1, 0)
	blurFrame.BackgroundTransparency = 1
	blurFrame.Visible = false
	
	-- Container principal
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(0, 450, 0, 500)
	mainContainer.Position = UDim2.new(0.5, -225, 0.5, -250)
	mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	mainContainer.BackgroundColor3 = SETTINGS.COLORS.PRIMARY
	mainContainer.BackgroundTransparency = 1
	mainContainer.Visible = false
	
	-- UIStroke elegante
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = SETTINGS.COLORS.ACCENT
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.8
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = mainContainer
	
	-- Corner radius
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainContainer
	
	-- Sombra
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0.5, -10, 0.5, -10)
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://5554236805"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.8
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Parent = mainContainer
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = SETTINGS.COLORS.SECONDARY
	header.BorderSizePixel = 0
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	-- Título
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "DEMON HUB PREMIUM"
	title.TextColor3 = SETTINGS.COLORS.ACCENT
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 24
	title.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, -40, 0, 20)
	subtitle.Position = UDim2.new(0, 20, 0, 30)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "v2.0 | BY DEVELOPER"
	subtitle.TextColor3 = SETTINGS.COLORS.TEXT
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.TextSize = 12
	subtitle.TextTransparency = 0.5
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Botão fechar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 15)
	closeBtn.BackgroundColor3 = SETTINGS.COLORS.PRIMARY
	closeBtn.Text = "×"
	closeBtn.TextColor3 = SETTINGS.COLORS.TEXT
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 20
	closeBtn.AutoButtonColor = false
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeBtn
	
	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color = SETTINGS.COLORS.DANGER
	closeStroke.Thickness = 1
	closeStroke.Parent = closeBtn
	
	-- Container de conteúdo
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -40, 1, -100)
	contentContainer.Position = UDim2.new(0, 20, 0, 80)
	contentContainer.BackgroundTransparency = 1
	
	-- Botão flutuante
	local floatingButton = Instance.new("TextButton")
	floatingButton.Name = "FloatingButton"
	floatingButton.Size = UDim2.new(0, 60, 0, 60)
	floatingButton.Position = UDim2.new(1, -80, 1, -80)
	floatingButton.AnchorPoint = Vector2.new(1, 1)
	floatingButton.BackgroundColor3 = SETTINGS.COLORS.PRIMARY
	floatingButton.Text = "😈"
	floatingButton.TextColor3 = SETTINGS.COLORS.ACCENT
	floatingButton.Font = Enum.Font.GothamBlack
	floatingButton.TextSize = 30
	floatingButton.AutoButtonColor = false
	floatingButton.ZIndex = 100
	
	local floatCorner = Instance.new("UICorner")
	floatCorner.CornerRadius = UDim.new(1, 0)
	floatCorner.Parent = floatingButton
	
	local floatStroke = Instance.new("UIStroke")
	floatStroke.Color = SETTINGS.COLORS.ACCENT
	floatStroke.Thickness = 3
	floatStroke.Parent = floatingButton
	
	-- Glow effect animado
	local glowEffect = Instance.new("Frame")
	glowEffect.Name = "GlowEffect"
	glowEffect.Size = UDim2.new(1, 10, 1, 10)
	glowEffect.Position = UDim2.new(0.5, -5, 0.5, -5)
	glowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
	glowEffect.BackgroundTransparency = 1
	
	local glowStroke = Instance.new("UIStroke")
	glowStroke.Color = SETTINGS.COLORS.GLOW
	glowStroke.Thickness = 2
	glowStroke.Transparency = 0.7
	glowStroke.Parent = glowEffect
	
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = UDim.new(1, 0)
	glowCorner.Parent = glowEffect
	
	-- Hierarquia
	glowEffect.Parent = floatingButton
	title.Parent = header
	subtitle.Parent = header
	closeBtn.Parent = header
	header.Parent = mainContainer
	contentContainer.Parent = mainContainer
	blurFrame.Parent = screenGui
	mainContainer.Parent = screenGui
	floatingButton.Parent = screenGui
	
	-- Store references
	guiObjects = {
		ScreenGui = screenGui,
		MainContainer = mainContainer,
		Header = header,
		Title = title,
		Subtitle = subtitle,
		CloseButton = closeBtn,
		ContentContainer = contentContainer,
		FloatingButton = floatingButton,
		GlowEffect = glowEffect,
		BlurFrame = blurFrame,
		Shadow = shadow,
		UIStroke = uiStroke
	}
	
	return screenGui
end

-- Criar botões de funcionalidade
local function createFeatureButtons()
	local container = guiObjects.ContentContainer
	local buttonSize = UDim2.new(1, 0, 0, 50)
	
	-- ESP Toggle
	local espButton = Instance.new("TextButton")
	espButton.Name = "ESPButton"
	espButton.Size = buttonSize
	espButton.Position = UDim2.new(0, 0, 0, 0)
	espButton.BackgroundColor3 = SETTINGS.COLORS.SECONDARY
	espButton.Text = "ESP VISUAL: OFF"
	espButton.TextColor3 = SETTINGS.COLORS.TEXT
	espButton.Font = Enum.Font.GothamMedium
	espButton.TextSize = 16
	
	local espCorner = Instance.new("UICorner")
	espCorner.CornerRadius = UDim.new(0, 8)
	espCorner.Parent = espButton
	
	local espStroke = Instance.new("UIStroke")
	espStroke.Color = SETTINGS.COLORS.ACCENT
	espStroke.Thickness = 1
	espStroke.Parent = espButton
	
	-- Aim Assist Toggle
	local aimButton = Instance.new("TextButton")
	aimButton.Name = "AimButton"
	aimButton.Size = buttonSize
	aimButton.Position = UDim2.new(0, 0, 0, 60)
	aimButton.BackgroundColor3 = SETTINGS.COLORS.SECONDARY
	aimButton.Text = "AIM ASSIST: OFF"
	aimButton.TextColor3 = SETTINGS.COLORS.TEXT
	aimButton.Font = Enum.Font.GothamMedium
	aimButton.TextSize = 16
	
	local aimCorner = Instance.new("UICorner")
	aimCorner.CornerRadius = UDim.new(0, 8)
	aimCorner.Parent = aimButton
	
	local aimStroke = Instance.new("UIStroke")
	aimStroke.Color = SETTINGS.COLORS.ACCENT
	aimStroke.Thickness = 1
	aimStroke.Parent = aimButton
	
	-- NPC Radar
	local radarButton = Instance.new("TextButton")
	radarButton.Name = "RadarButton"
	radarButton.Size = buttonSize
	radarButton.Position = UDim2.new(0, 0, 0, 120)
	radarButton.BackgroundColor3 = SETTINGS.COLORS.SECONDARY
	radarButton.Text = "NPC RADAR: OFF"
	radarButton.TextColor3 = SETTINGS.COLORS.TEXT
	radarButton.Font = Enum.Font.GothamMedium
	radarButton.TextSize = 16
	
	local radarCorner = Instance.new("UICorner")
	radarCorner.CornerRadius = UDim.new(0, 8)
	radarCorner.Parent = radarButton
	
	local radarStroke = Instance.new("UIStroke")
	radarStroke.Color = SETTINGS.COLORS.ACCENT
	radarStroke.Thickness = 1
	radarStroke.Parent = radarButton
	
	-- Separador
	local separator = Instance.new("Frame")
	separator.Name = "Separator"
	separator.Size = UDim2.new(1, 0, 0, 2)
	separator.Position = UDim2.new(0, 0, 0, 190)
	separator.BackgroundColor3 = SETTINGS.COLORS.ACCENT
	separator.BackgroundTransparency = 0.5
	separator.BorderSizePixel = 0
	
	local sepCorner = Instance.new("UICorner")
	sepCorner.CornerRadius = UDim.new(1, 0)
	sepCorner.Parent = separator
	
	-- Info display
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "InfoLabel"
	infoLabel.Size = UDim2.new(1, 0, 0, 100)
	infoLabel.Position = UDim2.new(0, 0, 0, 200)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "SISTEMA DE VISÃO ESPECIAL\n\n• ESP para NPCs/Objetos\n• Auto-aim para NPCs\n• Radar 360°\n• Somente para seu jogo"
	infoLabel.TextColor3 = SETTINGS.COLORS.TEXT
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 12
	infoLabel.TextTransparency = 0.3
	infoLabel.TextYAlignment = Enum.TextYAlignment.Top
	
	-- Adicionar à hierarquia
	espButton.Parent = container
	aimButton.Parent = container
	radarButton.Parent = container
	separator.Parent = container
	infoLabel.Parent = container
	
	-- Store references
	guiObjects.ESPButton = espButton
	guiObjects.AimButton = aimButton
	guiObjects.RadarButton = radarButton
	guiObjects.InfoLabel = infoLabel
end

-- Sistema de ESP (para NPCs e objetos do SEU jogo)
local function createESP()
	local espFolder = Instance.new("Folder")
	espFolder.Name = "ESPFolder"
	espFolder.Parent = guiObjects.ScreenGui
	
	-- Função para criar ESP para um alvo
	local function createESPForTarget(target, isNPC)
		if not target:IsA("Model") then return end
		
		local humanoid = target:FindFirstChild("Humanoid")
		local head = target:FindFirstChild("Head")
		if not humanoid or not head then return end
		
		-- Criar BillboardGui para nome
		local nameBillboard = Instance.new("BillboardGui")
		nameBillboard.Name = "ESP_Name_" .. target.Name
		nameBillboard.Adornee = head
		nameBillboard.Size = UDim2.new(0, 200, 0, 50)
		nameBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
		nameBillboard.AlwaysOnTop = true
		nameBillboard.MaxDistance = 500
		nameBillboard.Enabled = SETTINGS.ESP.ENABLED
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = target.Name
		nameLabel.TextColor3 = SETTINGS.ESP.NAME_COLOR
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Parent = nameBillboard
		
		-- Criar caixa 3D (usando SurfaceGui)
		local boxFrame = Instance.new("Frame")
		boxFrame.Name = "ESP_Box_" .. target.Name
		boxFrame.Size = UDim2.new(0, 100, 0, 200)
		boxFrame.BackgroundTransparency = 1
		boxFrame.BorderSizePixel = 0
		
		local boxStroke = Instance.new("UIStroke")
		boxStroke.Color = isNPC and Color3.fromRGB(255, 100, 100) or SETTINGS.ESP.BOX_COLOR
		boxStroke.Thickness = 2
		boxStroke.Parent = boxFrame
		
		-- Se for NPC, adicionar barra de vida
		if isNPC then
			local healthBar = Instance.new("Frame")
			healthBar.Name = "HealthBar"
			healthBar.Size = UDim2.new(0.8, 0, 0, 6)
			healthBar.Position = UDim2.new(0.1, 0, 0, -20)
			healthBar.BackgroundColor3 = SETTINGS.COLORS.DANGER
			healthBar.BorderSizePixel = 0
			
			local healthBarBG = Instance.new("Frame")
			healthBarBG.Name = "HealthBarBG"
			healthBarBG.Size = UDim2.new(1, 0, 1, 0)
			healthBarBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			healthBarBG.BorderSizePixel = 0
			healthBarBG.ZIndex = -1
			healthBarBG.Parent = healthBar
			
			healthBar.Parent = boxFrame
		end
		
		-- Store no cache
		espCache[target] = {
			NameBillboard = nameBillboard,
			BoxFrame = boxFrame,
			Humanoid = humanoid,
			Model = target,
			IsNPC = isNPC
		}
		
		nameBillboard.Parent = espFolder
	end
	
	-- Atualizar ESP
	local function updateESP()
		if not SETTINGS.ESP.ENABLED then
			for _, espData in pairs(espCache) do
				espData.NameBillboard.Enabled = false
			end
			return
		end
		
		-- Atualizar posições e visibilidade
		for target, espData in pairs(espCache) do
			if target.Parent and espData.Humanoid and espData.Humanoid.Health > 0 then
				-- Atualizar posição da caixa
				local humanoidRootPart = target:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart then
					-- Calcular tamanho da caixa baseado no modelo
					local cf = humanoidRootPart.CFrame
					local size = target:GetExtentsSize()
					
					-- Atualizar barra de vida se for NPC
					if espData.IsNPC and SETTINGS.ESP.HEALTH_BAR then
						local healthBar = espData.BoxFrame:FindFirstChild("HealthBar")
						if healthBar then
							local healthPercent = espData.Humanoid.Health / espData.Humanoid.MaxHealth
							healthBar.Size = UDim2.new(healthPercent * 0.8, 0, 0, 6)
						end
					end
					
					espData.NameBillboard.Enabled = true
				else
					espData.NameBillboard.Enabled = false
				end
			else
				espData.NameBillboard.Enabled = false
			end
		end
	end
	
	-- Procurar NPCs automaticamente (apenas modelos com Humanoid)
	local function scanForNPCs()
		while true do
			task.wait(2) -- Scan a cada 2 segundos para performance
			
			if not SETTINGS.ESP.ENABLED then continue end
			
			-- Procurar NPCs no workspace
			for _, obj in pairs(Workspace:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
					-- Verificar se é NPC (não é player)
					local isPlayer = Players:GetPlayerFromCharacter(obj)
					if not isPlayer and not espCache[obj] then
						createESPForTarget(obj, true)
					end
				end
			end
		end
	end
	
	-- Iniciar scan em thread separada
	coroutine.wrap(scanForNPCs)()
	
	-- Loop de atualização do ESP
	RunService.RenderStepped:Connect(updateESP)
	
	return {
		Toggle = function(state)
			SETTINGS.ESP.ENABLED = state
			guiObjects.ESPButton.Text = "ESP VISUAL: " .. (state and "ON" or "OFF")
			guiObjects.ESPButton.TextColor3 = state and SETTINGS.COLORS.ACCENT or SETTINGS.COLORS.TEXT
		end,
		Clear = function()
			for _, espData in pairs(espCache) do
				espData.NameBillboard:Destroy()
			end
			espCache = {}
		end
	}
end

-- Sistema de Aim Assist (para NPCs do SEU jogo)
local function createAimAssist()
	local function findBestTarget()
		local bestTarget = nil
		local bestAngle = math.rad(SETTINGS.AIM_ASSIST.FOV)
		local camera = Workspace.CurrentCamera
		local mousePos = Vector2.new(mouse.X, mouse.Y)
		
		-- Converter posição da tela para raio
		local viewportPoint = camera.ViewportSize
		local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
		
		-- Procurar NPCs
		for _, npc in pairs(Workspace:GetChildren()) do
			if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
				local humanoid = npc.Humanoid
				local head = npc:FindFirstChild("Head")
				
				-- Verificar se é NPC (não player)
				local isPlayer = Players:GetPlayerFromCharacter(npc)
				if not isPlayer and humanoid.Health > 0 and head then
					-- Verificar se está dentro do FOV
					local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
					
					if onScreen then
						-- Calcular ângulo entre mouse e NPC
						local mouseToTarget = Vector2.new(screenPos.X, screenPos.Y) - mousePos
						local angle = math.atan2(mouseToTarget.Y, mouseToTarget.X)
						
						if math.abs(angle) < bestAngle then
							bestAngle = math.abs(angle)
							bestTarget = head
						end
					end
				end
			end
		end
		
		return bestTarget
	end
	
	-- Função para suavizar movimento do mouse (SIMULAÇÃO)
	local function smoothAim(target)
		if not target then return end
		
		-- Esta é uma SIMULAÇÃO. Em um jogo real, você controlaria a câmera
		-- ou ofereceria assistência de mira através de outras mecânicas
		
		-- Para demonstração, apenas marcamos o alvo
		aimTarget = target
		
		-- Em seu jogo, você poderia:
		-- 1. Ajustar a rotação da arma do jogador
		-- 2. Oferecer um "magnetismo" de mira
		-- 3. Ajustar a sensibilidade quando perto do alvo
		
		-- Exemplo de implementação para SEU jogo:
		-- local weapon = player.Character:FindFirstChild("Weapon")
		-- if weapon then
		--     local aimPart = weapon:FindFirstChild("AimPart")
		--     if aimPart then
		--         -- Suavizar rotação em direção ao alvo
		--         local direction = (target.Position - aimPart.Position).Unit
		--         -- ... sua lógica de rotação aqui
		--     end
		-- end
	end
	
	-- Loop principal do aim assist
	local function aimAssistLoop()
		while true do
			task.wait()
			
			if not SETTINGS.AIM_ASSIST.ENABLED then
				aimTarget = nil
				continue
			end
			
			local target = findBestTarget()
			if target then
				smoothAim(target)
			else
				aimTarget = nil
			end
		end
	end
	
	-- Iniciar loop
	coroutine.wrap(aimAssistLoop)()
	
	return {
		Toggle = function(state)
			SETTINGS.AIM_ASSIST.ENABLED = state
			guiObjects.AimButton.Text = "AIM ASSIST: " .. (state and "ON" or "OFF")
			guiObjects.AimButton.TextColor3 = state and SETTINGS.COLORS.ACCENT or SETTINGS.COLORS.TEXT
			
			if not state then
				aimTarget = nil
			end
		end,
		GetTarget = function()
			return aimTarget
		end
	}
end

-- Sistema de Radar
local function createRadar()
	local radarEnabled = false
	local radarFrame = nil
	
	local function createRadarUI()
		if radarFrame then radarFrame:Destroy() end
		
		radarFrame = Instance.new("Frame")
		radarFrame.Name = "RadarFrame"
		radarFrame.Size = UDim2.new(0, 200, 0, 200)
		radarFrame.Position = UDim2.new(1, -220, 1, -220)
		radarFrame.AnchorPoint = Vector2.new(1, 1)
		radarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		radarFrame.BackgroundTransparency = 0.3
		radarFrame.Visible = radarEnabled
		
		local radarCorner = Instance.new("UICorner")
		radarCorner.CornerRadius = UDim.new(0, 12)
		radarCorner.Parent = radarFrame
		
		local radarStroke = Instance.new("UIStroke")
		radarStroke.Color = SETTINGS.COLORS.ACCENT
		radarStroke.Thickness = 2
		radarStroke.Parent = radarFrame
		
		-- Título do radar
		local radarTitle = Instance.new("TextLabel")
		radarTitle.Name = "RadarTitle"
		radarTitle.Size = UDim2.new(1, 0, 0, 30)
		radarTitle.BackgroundTransparency = 1
		radarTitle.Text = "NPC RADAR"
		radarTitle.TextColor3 = SETTINGS.COLORS.ACCENT
		radarTitle.Font = Enum.Font.GothamBold
		radarTitle.TextSize = 16
		radarTitle.Parent = radarFrame
		
		-- Container dos pontos
		local pointsContainer = Instance.new("Frame")
		pointsContainer.Name = "PointsContainer"
		pointsContainer.Size = UDim2.new(1, -20, 1, -40)
		pointsContainer.Position = UDim2.new(0, 10, 0, 35)
		pointsContainer.BackgroundTransparency = 1
		pointsContainer.Parent = radarFrame
		
		-- Cruz central
		local centerX = Instance.new("Frame")
		centerX.Name = "CenterX"
		centerX.Size = UDim2.new(1, 0, 0, 1)
		centerX.Positi
