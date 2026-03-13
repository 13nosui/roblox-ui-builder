-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")

local toolbar = plugin:CreateToolbar("UI Builder Pro")
local toggleButton = toolbar:CreateButton("Open Editor", "UI Builderを開く", "rbxassetid://4483345998")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 850, 650, 600, 450)
local widget = plugin:CreateDockWidgetPluginGui("UIBuilderCanvas", widgetInfo)
widget.Title = "UI Builder - Professional"

-- --- 共通UIコンポーネント ---
local function createLabel(text, parent)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(180, 180, 180)
	label.Text = text
	label.Font = Enum.Font.BuilderSans
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createTextBox(parent)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 28)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.BuilderSans
	box.TextSize = 13
	box.ClearTextOnFocus = false
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
	return box
end

-- --- 背景・レイアウト ---
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.Parent = widget

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topBar.BorderSizePixel = 0
topBar.Parent = background

local topLayout = Instance.new("UIListLayout")
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.Padding = UDim.new(0, 12)
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topLayout.Parent = topBar
Instance.new("UIPadding", topBar).PaddingLeft = UDim.new(0, 15)

local function createToolButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 34)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.BuilderSansBold
	btn.TextSize = 14
	btn.Parent = topBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local btnFrame = createToolButton("＋ 四角形", Color3.fromRGB(0, 120, 215))
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113))
local btnButton = createToolButton("＋ ボタン", Color3.fromRGB(155, 89, 182))
local btnExport = createToolButton("📤 出力", Color3.fromRGB(230, 126, 34))

local mainArea = Instance.new("Frame")
mainArea.Size = UDim2.new(1, 0, 1, -50)
mainArea.Position = UDim2.new(0, 0, 0, 50)
mainArea.BackgroundTransparency = 1
mainArea.Parent = background

local canvasArea = Instance.new("Frame")
canvasArea.Size = UDim2.new(1, -260, 1, 0)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true
canvasArea.Parent = mainArea

local propertyPanel = Instance.new("ScrollingFrame")
propertyPanel.Size = UDim2.new(0, 260, 1, 0)
propertyPanel.Position = UDim2.new(1, -260, 0, 0)
propertyPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
propertyPanel.BorderSizePixel = 0
propertyPanel.CanvasSize = UDim2.new(0, 0, 0, 800)
propertyPanel.ScrollBarThickness = 2
propertyPanel.Parent = mainArea

local propLayout = Instance.new("UIListLayout")
propLayout.Padding = UDim.new(0, 15)
propLayout.Parent = propertyPanel
Instance.new("UIPadding", propertyPanel).PaddingTop = UDim.new(0, 20)
Instance.new("UIPadding", propertyPanel).PaddingLeft = UDim.new(0, 15)
Instance.new("UIPadding", propertyPanel).PaddingRight = UDim.new(0, 15)

local propTitle = Instance.new("TextLabel")
propTitle.Size = UDim2.new(1, 0, 0, 24)
propTitle.BackgroundTransparency = 1
propTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
propTitle.Text = "No Selection"
propTitle.Font = Enum.Font.BuilderSansBold
propTitle.TextSize = 16
propTitle.TextXAlignment = Enum.TextXAlignment.Left
propTitle.Parent = propertyPanel

-- --- プロパティ項目 ---

createLabel("CONTENT (TEXT)", propertyPanel)
local textEditBox = createTextBox(propertyPanel)

createLabel("CORNER RADIUS (px)", propertyPanel)
local cornerEditBox = createTextBox(propertyPanel)

createLabel("SIZE (WIDTH, HEIGHT)", propertyPanel)
local sizeFrame = Instance.new("Frame")
sizeFrame.Size = UDim2.new(1, 0, 0, 30)
sizeFrame.BackgroundTransparency = 1
sizeFrame.Parent = propertyPanel
local sizeX = createTextBox(sizeFrame)
sizeX.Size = UDim2.new(0.48, 0, 1, 0)
local sizeY = createTextBox(sizeFrame)
sizeY.Size = UDim2.new(0.48, 0, 1, 0)
sizeY.Position = UDim2.new(0.52, 0, 0, 0)

createLabel("PADDING (T, B, L, R)", propertyPanel)
local paddingContainer = Instance.new("Frame")
paddingContainer.Size = UDim2.new(1, 0, 0, 30)
paddingContainer.BackgroundTransparency = 1
paddingContainer.Parent = propertyPanel
Instance.new("UIListLayout", paddingContainer).FillDirection = Enum.FillDirection.Horizontal
Instance.new("UIListLayout", paddingContainer).Padding = UDim.new(0, 5)

local function createPadBox()
	local b = createTextBox(paddingContainer)
	b.Size = UDim2.new(0.23, 0, 1, 0)
	b.TextSize = 11
	return b
end
local padT = createPadBox()
local padB = createPadBox()
local padL = createPadBox()
local padR = createPadBox()

createLabel("AUTO LAYOUT (GROW)", propertyPanel)
local autoSizeContainer = Instance.new("Frame")
autoSizeContainer.Size = UDim2.new(1, 0, 0, 40)
autoSizeContainer.BackgroundTransparency = 1
autoSizeContainer.Parent = propertyPanel

local function createAutoBtn(text, pos)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.23, 0, 1, 0)
	b.Position = UDim2.new(pos, 0, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Text = text
	b.Font = Enum.Font.BuilderSansBold
	b.TextSize = 11
	b.Parent = autoSizeContainer
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	return b
end
local btnNone = createAutoBtn("OFF", 0)
local btnX = createAutoBtn("↔ X", 0.25)
local btnY = createAutoBtn("↕ Y", 0.5)
local btnXY = createAutoBtn("↔↕ XY", 0.75)

-- --- システムロジック ---
local selectedElement = nil
local selectionHighlight = Instance.new("UIStroke")
selectionHighlight.Color = Color3.fromRGB(0, 162, 255)
selectionHighlight.Thickness = 3
selectionHighlight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local function updatePanel()
	if not selectedElement then
		return
	end
	propTitle.Text = selectedElement.ClassName
	textEditBox.Text = (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) and selectedElement.Text
		or "---"

	local corner = selectedElement:FindFirstChildOfClass("UICorner")
	cornerEditBox.Text = corner and tostring(corner.CornerRadius.Offset) or "0"

	sizeX.Text = tostring(math.floor(selectedElement.AbsoluteSize.X))
	sizeY.Text = tostring(math.floor(selectedElement.AbsoluteSize.Y))

	local pad = selectedElement:FindFirstChildOfClass("UIPadding")
	if pad then
		padT.Text = tostring(pad.PaddingTop.Offset)
		padB.Text = tostring(pad.PaddingBottom.Offset)
		padL.Text = tostring(pad.PaddingLeft.Offset)
		padR.Text = tostring(pad.PaddingRight.Offset)
	else
		padT.Text, padB.Text, padL.Text, padR.Text = "0", "0", "0", "0"
	end

	local current = selectedElement.AutomaticSize
	btnNone.BackgroundColor3 = current == Enum.AutomaticSize.None and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnX.BackgroundColor3 = current == Enum.AutomaticSize.X and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnY.BackgroundColor3 = current == Enum.AutomaticSize.Y and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnXY.BackgroundColor3 = current == Enum.AutomaticSize.XY and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
end

local function selectElement(element)
	selectedElement = element
	selectionHighlight.Parent = element
	updatePanel()
end

-- --- ★ 反映イベント (ここを修正・追加しました) ---

-- 1. テキスト反映
textEditBox.FocusLost:Connect(function()
	if selectedElement and (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) then
		selectedElement.Text = textEditBox.Text
		task.wait(0.05)
		updatePanel()
	end
end)

-- 2. 角丸反映
cornerEditBox.FocusLost:Connect(function()
	if selectedElement then
		local num = tonumber(cornerEditBox.Text) or 0
		local c = selectedElement:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", selectedElement)
		c.CornerRadius = UDim.new(0, num)
	end
end)

-- 3. ★ サイズ反映 (追加分)
local function applySize()
	if selectedElement then
		local nx = tonumber(sizeX.Text) or selectedElement.AbsoluteSize.X
		local ny = tonumber(sizeY.Text) or selectedElement.AbsoluteSize.Y

		-- 数値で指定したときは、自動サイズを一旦OFFにする（そうしないと数値が無視されるため）
		selectedElement.AutomaticSize = Enum.AutomaticSize.None

		-- Scaleを0にしてOffsetだけで指定する（ピクセル単位で正確にするため）
		selectedElement.Size = UDim2.new(0, nx, 0, ny)

		task.wait(0.05)
		updatePanel()
	end
end
sizeX.FocusLost:Connect(applySize)
sizeY.FocusLost:Connect(applySize)

-- --- 4. パディング反映 (内容量優先モードへの切り替え付き) ---
local function updatePadding()
	if selectedElement then
		local pad = selectedElement:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding", selectedElement)
		pad.PaddingTop = UDim.new(0, tonumber(padT.Text) or 0)
		pad.PaddingBottom = UDim.new(0, tonumber(padB.Text) or 0)
		pad.PaddingLeft = UDim.new(0, tonumber(padL.Text) or 0)
		pad.PaddingRight = UDim.new(0, tonumber(padR.Text) or 0)

		-- ★ ここがポイント！
		-- パディングをいじった＝内容量に合わせたレイアウトをしたい、と判断し、
		-- 指定サイズを (0,0) にリセットして AutomaticSize を XY に強制します。
		-- これにより、指定サイズに縛られず「中身＋パディング」のサイズに吸着します。
		if selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton") then
			selectedElement.Size = UDim2.new(0, 0, 0, 0) -- 指定サイズを最小化
			selectedElement.AutomaticSize = Enum.AutomaticSize.XY -- 内容優先モード
			selectedElement.TextWrapped = false -- 自動サイズ時は折り返しをOFFにするのが一般的
		end

		task.wait(0.05)
		updatePanel()
	end
end
padT.FocusLost:Connect(updatePadding)
padB.FocusLost:Connect(updatePadding)
padL.FocusLost:Connect(updatePadding)
padR.FocusLost:Connect(updatePadding)

-- 5. オートレイアウト設定
local function setAutoSize(mode)
	if selectedElement then
		selectedElement.AutomaticSize = mode
		if selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton") then
			selectedElement.TextWrapped = (mode == Enum.AutomaticSize.None)
		end
		updatePanel()
	end
end
btnNone.MouseButton1Click:Connect(function()
	setAutoSize(Enum.AutomaticSize.None)
end)
btnX.MouseButton1Click:Connect(function()
	setAutoSize(Enum.AutomaticSize.X)
end)
btnY.MouseButton1Click:Connect(function()
	setAutoSize(Enum.AutomaticSize.Y)
end)
btnXY.MouseButton1Click:Connect(function()
	setAutoSize(Enum.AutomaticSize.XY)
end)

-- --- ドラッグ・選択ロジック ---
local isSelecting = false
canvasArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isSelecting then
			return
		end
		selectedElement = nil
		selectionHighlight.Parent = nil
		propTitle.Text = "No Selection"
	end
end)

local function makeDraggable(guiObject)
	local dragging = false
	local dragStart, startPos
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isSelecting = true
			selectElement(guiObject)
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					isSelecting = false
					updatePanel()
				end
			end)
		end
	end)
	canvasArea.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local parentSize = canvasArea.AbsoluteSize
			-- ドラッグ中はScaleを維持
			guiObject.Position = UDim2.new(
				startPos.X.Scale + (delta.X / parentSize.X),
				0,
				startPos.Y.Scale + (delta.Y / parentSize.Y),
				0
			)
			updatePanel()
		end
	end)
end

local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	newPart.Active, newPart.Selectable = true, true
	newPart.Size = UDim2.new(0, 150, 0, 50)
	newPart.Position = UDim2.new(0.1, 0, 0.1, 0)

	if className ~= "Frame" then
		newPart.Text = "New Element"
		newPart.BackgroundColor3 = className == "TextLabel" and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(46, 204, 113)
		newPart.Font = Enum.Font.BuilderSansBold
		newPart.TextSize = 18
		newPart.TextScaled = false
		local p = Instance.new("UIPadding", newPart)
		p.PaddingLeft, p.PaddingRight = UDim.new(0, 15), UDim.new(0, 15)
	else
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end

	Instance.new("UIStroke", newPart).Color = Color3.fromRGB(150, 150, 150)
	newPart.Parent = canvasArea
	makeDraggable(newPart)
	selectElement(newPart)
end

btnFrame.MouseButton1Click:Connect(function()
	addElementToCanvas("Frame")
end)
btnText.MouseButton1Click:Connect(function()
	addElementToCanvas("TextLabel")
end)
btnButton.MouseButton1Click:Connect(function()
	addElementToCanvas("TextButton")
end)

btnExport.MouseButton1Click:Connect(function()
	local exportGui = game:GetService("StarterGui"):FindFirstChild("UIBuilderExport")
		or Instance.new("ScreenGui", game:GetService("StarterGui"))
	exportGui.Name = "UIBuilderExport"
	exportGui:ClearAllChildren()
	for _, element in ipairs(canvasArea:GetChildren()) do
		if element:IsA("GuiObject") then
			local clone = element:Clone()
			local h = clone:FindFirstChildOfClass("UIStroke")
			if h and h.Color == Color3.fromRGB(0, 162, 255) then
				h:Destroy()
			end
			clone.Parent = exportGui
		end
	end
end)

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
