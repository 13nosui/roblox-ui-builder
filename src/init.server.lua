-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService") -- ★ フレーム毎の処理用に新しく追加！

local toolbar = plugin:CreateToolbar("UI Builder Pro")
local toggleButton = toolbar:CreateButton("Open Editor", "UI Builderを開く", "rbxassetid://4483345998")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 850, 800, 600, 450)
local widget = plugin:CreateDockWidgetPluginGui("UIBuilderCanvas", widgetInfo)
widget.Title = "UI Builder - Figma Pro"

widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- --- 共通UIコンポーネント ---
local function createTextBox(parent)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.BuilderSans
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
	return box
end

local function createColorInput(parent)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local topRow = Instance.new("Frame")
	topRow.Size = UDim2.new(1, 0, 0, 28)
	topRow.BackgroundTransparency = 1
	topRow.Parent = container

	local layout = Instance.new("UIListLayout", topRow)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center

	local colorChip = Instance.new("TextButton")
	colorChip.Size = UDim2.new(0, 28, 0, 28)
	colorChip.Text = ""
	colorChip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	colorChip.Parent = topRow
	Instance.new("UICorner", colorChip).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", colorChip).Color = Color3.fromRGB(60, 60, 60)

	local hexBox = createTextBox(topRow)
	hexBox.Size = UDim2.new(0, 80, 1, 0)
	hexBox.PlaceholderText = "#FFFFFF"

	local presetRow = Instance.new("Frame")
	presetRow.Size = UDim2.new(1, 0, 0, 20)
	presetRow.Position = UDim2.new(0, 0, 0, 35)
	presetRow.BackgroundTransparency = 1
	presetRow.Parent = container

	local pLayout = Instance.new("UIListLayout", presetRow)
	pLayout.FillDirection = Enum.FillDirection.Horizontal
	pLayout.Padding = UDim.new(0, 6)

	local presetColors = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(180, 180, 180),
		Color3.fromRGB(30, 30, 30),
		Color3.fromRGB(231, 76, 60),
		Color3.fromRGB(46, 204, 113),
		Color3.fromRGB(52, 152, 219),
		Color3.fromRGB(241, 196, 15),
		Color3.fromRGB(155, 89, 182),
	}

	local presetBtns = {}
	for _, c in ipairs(presetColors) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 18, 0, 18)
		btn.BackgroundColor3 = c
		btn.Text = ""
		btn.Parent = presetRow
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		Instance.new("UIStroke", btn).Color = Color3.fromRGB(80, 80, 80)
		table.insert(presetBtns, btn)
	end

	return hexBox, colorChip, presetBtns
end

local layoutOrder = 0
local function createPropertyBlock(titleText, parent, contentHeight)
	layoutOrder = layoutOrder + 1
	local block = Instance.new("Frame")
	block.Size = UDim2.new(1, 0, 0, 25 + contentHeight)
	block.BackgroundTransparency = 1
	block.LayoutOrder = layoutOrder
	block.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(180, 180, 180)
	label.Text = titleText
	label.Font = Enum.Font.BuilderSans
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = block

	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 0, contentHeight)
	contentArea.Position = UDim2.new(0, 0, 0, 20)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = block

	return block, contentArea
end

local function toHex(color)
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end
local function fromHex(hex)
	hex = hex:gsub("#", "")
	if #hex ~= 6 then
		return nil
	end
	local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
	if r and g and b then
		return Color3.fromRGB(r, g, b)
	end
	return nil
end

-- --- 背景構築 ---
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.Parent = widget

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topBar.BorderSizePixel = 0
topBar.Parent = background

local topLayout = Instance.new("UIListLayout", topBar)
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.Padding = UDim.new(0, 12)
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", topBar).PaddingLeft = UDim.new(0, 15)

local function createToolButton(text, color)
	local btn = Instance.new("TextButton", topBar)
	btn.Size = UDim2.new(0, 100, 0, 34)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.BuilderSansBold
	btn.TextSize = 13
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local btnFrame = createToolButton("＋ 四角形", Color3.fromRGB(0, 120, 215))
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113))
local btnButton = createToolButton("＋ ボタン", Color3.fromRGB(155, 89, 182))
local btnExport = createToolButton("📤 出力", Color3.fromRGB(230, 126, 34))

local mainArea = Instance.new("Frame", background)
mainArea.Size = UDim2.new(1, 0, 1, -50)
mainArea.Position = UDim2.new(0, 0, 0, 50)
mainArea.BackgroundTransparency = 1

local canvasArea = Instance.new("Frame", mainArea)
canvasArea.Size = UDim2.new(1, -260, 1, 0)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true

local propertyPanel = Instance.new("ScrollingFrame", mainArea)
propertyPanel.Size = UDim2.new(0, 260, 1, 0)
propertyPanel.Position = UDim2.new(1, -260, 0, 0)
propertyPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
propertyPanel.BorderSizePixel = 0
propertyPanel.CanvasSize = UDim2.new(0, 0, 0, 1100)
propertyPanel.ScrollBarThickness = 2

local propLayout = Instance.new("UIListLayout", propertyPanel)
propLayout.Padding = UDim.new(0, 15)
propLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", propertyPanel).PaddingTop = UDim.new(0, 20)
Instance.new("UIPadding", propertyPanel).PaddingLeft = UDim.new(0, 15)
Instance.new("UIPadding", propertyPanel).PaddingRight = UDim.new(0, 15)

local propTitle = Instance.new("TextLabel", propertyPanel)
propTitle.Size = UDim2.new(1, 0, 0, 24)
propTitle.BackgroundTransparency = 1
propTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
propTitle.Text = "No Selection"
propTitle.Font = Enum.Font.BuilderSansBold
propTitle.TextSize = 16
propTitle.TextXAlignment = Enum.TextXAlignment.Left
propTitle.LayoutOrder = 0

-- --- プロパティ項目 ---
local blockText, areaText = createPropertyBlock("CONTENT (TEXT)", propertyPanel, 28)
local textEditBox = createTextBox(areaText)

local blockFont, areaFont = createPropertyBlock("FONT FAMILY", propertyPanel, 28)
local fontSelectBtn = Instance.new("TextButton", areaFont)
fontSelectBtn.Size = UDim2.new(1, 0, 1, 0)
fontSelectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fontSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fontSelectBtn.Font = Enum.Font.BuilderSansBold
fontSelectBtn.TextSize = 12
Instance.new("UICorner", fontSelectBtn).CornerRadius = UDim.new(0, 4)

local blockBgColor, areaBgColor = createPropertyBlock("BACKGROUND COLOR (HEX)", propertyPanel, 55)
local bgHex, bgChip, bgPresets = createColorInput(areaBgColor)

local blockTxtColor, areaTxtColor = createPropertyBlock("TEXT COLOR (HEX)", propertyPanel, 55)
local txtHex, txtChip, txtPresets = createColorInput(areaTxtColor)

local blockOutline, areaOutline = createPropertyBlock("OUTLINE THICKNESS (px)", propertyPanel, 28)
local outlineBox = createTextBox(areaOutline)

local blockGradToggle, areaGradToggle = createPropertyBlock("GRADIENT MODE", propertyPanel, 28)
local gradToggleBtn = Instance.new("TextButton", areaGradToggle)
gradToggleBtn.Size = UDim2.new(1, 0, 1, 0)
gradToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
gradToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
gradToggleBtn.Text = "OFF"
gradToggleBtn.Font = Enum.Font.BuilderSansBold
Instance.new("UICorner", gradToggleBtn).CornerRadius = UDim.new(0, 4)

local blockGradColor, areaGradColor = createPropertyBlock("GRADIENT COLOR 2 (HEX)", propertyPanel, 55)
local gr2Hex, gr2Chip, gr2Presets = createColorInput(areaGradColor)

local blockCorner, areaCorner = createPropertyBlock("CORNER RADIUS (px)", propertyPanel, 28)
local cornerEditBox = createTextBox(areaCorner)

local blockSize, areaSize = createPropertyBlock("SIZE (W, H)", propertyPanel, 28)
local sizeX = createTextBox(areaSize)
sizeX.Size = UDim2.new(0.48, 0, 1, 0)
local sizeY = createTextBox(areaSize)
sizeY.Size = UDim2.new(0.48, 0, 1, 0)
sizeY.Position = UDim2.new(0.52, 0, 0, 0)

local blockPadding, areaPadding = createPropertyBlock("PADDING (T, B, L, R)", propertyPanel, 28)
Instance.new("UIListLayout", areaPadding).FillDirection = Enum.FillDirection.Horizontal
Instance.new("UIListLayout", areaPadding).Padding = UDim.new(0, 5)
local function createPadBox()
	local b = createTextBox(areaPadding)
	b.Size = UDim2.new(0.23, 0, 1, 0)
	return b
end
local padT, padB, padL, padR = createPadBox(), createPadBox(), createPadBox(), createPadBox()

local blockAuto, areaAuto = createPropertyBlock("AUTO LAYOUT (GROW)", propertyPanel, 28)
local function createAutoBtn(text, pos)
	local b = Instance.new("TextButton", areaAuto)
	b.Size = UDim2.new(0.23, 0, 1, 0)
	b.Position = UDim2.new(pos, 0, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Text = text
	b.Font = Enum.Font.BuilderSansBold
	b.TextSize = 10
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	return b
end
local btnNone, btnX, btnY, btnXY =
	createAutoBtn("OFF", 0), createAutoBtn("↔ X", 0.25), createAutoBtn("↕ Y", 0.5), createAutoBtn("↔↕ XY", 0.75)

-- ==========================================
-- ★ 60fps ヌルヌル駆動カラーピッカー ★
-- ==========================================

local pickerBlocker = Instance.new("TextButton")
pickerBlocker.Size = UDim2.new(1, 0, 1, 0)
pickerBlocker.BackgroundTransparency = 0.5
pickerBlocker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
pickerBlocker.Text = ""
pickerBlocker.AutoButtonColor = false
pickerBlocker.ZIndex = 999
pickerBlocker.Visible = false
pickerBlocker.Parent = background

local colorPickerBase = Instance.new("TextButton")
colorPickerBase.Size = UDim2.new(0, 220, 0, 280)
colorPickerBase.Position = UDim2.new(0.5, -110, 0.5, -140)
colorPickerBase.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
colorPickerBase.BorderSizePixel = 0
colorPickerBase.Text = ""
colorPickerBase.AutoButtonColor = false
colorPickerBase.ZIndex = 1000
colorPickerBase.Visible = false
colorPickerBase.Parent = background
Instance.new("UICorner", colorPickerBase).CornerRadius = UDim.new(0, 8)
local cpShadow = Instance.new("UIStroke", colorPickerBase)
cpShadow.Color = Color3.fromRGB(20, 20, 20)
cpShadow.Thickness = 2

local cpTitleUI = Instance.new("TextLabel")
cpTitleUI.Size = UDim2.new(1, -30, 0, 30)
cpTitleUI.Position = UDim2.new(0, 10, 0, 0)
cpTitleUI.BackgroundTransparency = 1
cpTitleUI.Text = "Color Picker"
cpTitleUI.TextColor3 = Color3.fromRGB(255, 255, 255)
cpTitleUI.Font = Enum.Font.BuilderSansBold
cpTitleUI.TextSize = 14
cpTitleUI.TextXAlignment = Enum.TextXAlignment.Left
cpTitleUI.ZIndex = 1001
cpTitleUI.Parent = colorPickerBase

local closeCpBtn = Instance.new("TextButton")
closeCpBtn.Size = UDim2.new(0, 30, 0, 30)
closeCpBtn.Position = UDim2.new(1, -30, 0, 0)
closeCpBtn.BackgroundTransparency = 1
closeCpBtn.Text = "✕"
closeCpBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeCpBtn.Font = Enum.Font.BuilderSansBold
closeCpBtn.TextSize = 14
closeCpBtn.ZIndex = 1001
closeCpBtn.Parent = colorPickerBase

local svArea = Instance.new("Frame")
svArea.Size = UDim2.new(0, 180, 0, 150)
svArea.Position = UDim2.new(0, 20, 0, 40)
svArea.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
svArea.Active = true
svArea.ZIndex = 1001
svArea.Parent = colorPickerBase
Instance.new("UICorner", svArea).CornerRadius = UDim.new(0, 4)

local satOverlay = Instance.new("Frame")
satOverlay.Size = UDim2.new(1, 0, 1, 0)
satOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
satOverlay.ZIndex = 1002
satOverlay.Parent = svArea
Instance.new("UICorner", satOverlay).CornerRadius = UDim.new(0, 4)
local satGrad = Instance.new("UIGradient", satOverlay)
satGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

local valOverlay = Instance.new("Frame")
valOverlay.Size = UDim2.new(1, 0, 1, 0)
valOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
valOverlay.ZIndex = 1003
valOverlay.Parent = svArea
Instance.new("UICorner", valOverlay).CornerRadius = UDim.new(0, 4)
local valGrad = Instance.new("UIGradient", valOverlay)
valGrad.Rotation = 90
valGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

local svCursor = Instance.new("Frame")
svCursor.Size = UDim2.new(0, 12, 0, 12)
svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
svCursor.ZIndex = 1004
svCursor.Parent = svArea
Instance.new("UICorner", svCursor).CornerRadius = UDim.new(1, 0)
local svCursorStroke = Instance.new("UIStroke", svCursor)
svCursorStroke.Color = Color3.new(0, 0, 0)
svCursorStroke.Thickness = 2

local hueArea = Instance.new("Frame")
hueArea.Size = UDim2.new(0, 180, 0, 16)
hueArea.Position = UDim2.new(0, 20, 0, 205)
hueArea.BackgroundColor3 = Color3.new(1, 1, 1)
hueArea.Active = true
hueArea.ZIndex = 1001
hueArea.Parent = colorPickerBase
Instance.new("UICorner", hueArea).CornerRadius = UDim.new(0, 8)
local hueGrad = Instance.new("UIGradient", hueArea)
hueGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
	ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
	ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
	ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
	ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
	ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
})

local hueCursor = Instance.new("Frame")
hueCursor.Size = UDim2.new(0, 16, 0, 20)
hueCursor.Position = UDim2.new(0, 0, 0.5, 0)
hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
hueCursor.ZIndex = 1002
hueCursor.Parent = hueArea
Instance.new("UICorner", hueCursor).CornerRadius = UDim.new(1, 0)
local hueCursorStroke = Instance.new("UIStroke", hueCursor)
hueCursorStroke.Color = Color3.new(0, 0, 0)
hueCursorStroke.Thickness = 2

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(0, 140, 0, 30)
confirmBtn.Position = UDim2.new(0, 20, 0, 235)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmBtn.Text = "Confirm"
confirmBtn.Font = Enum.Font.BuilderSansBold
confirmBtn.TextSize = 13
confirmBtn.ZIndex = 1001
confirmBtn.Parent = colorPickerBase
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 4)

local colorPreview = Instance.new("Frame")
colorPreview.Size = UDim2.new(0, 30, 0, 30)
colorPreview.Position = UDim2.new(0, 170, 0, 235)
colorPreview.BackgroundColor3 = Color3.new(1, 1, 1)
colorPreview.ZIndex = 1001
colorPreview.Parent = colorPickerBase
Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(0, 4)
local prevStroke = Instance.new("UIStroke", colorPreview)
prevStroke.Color = Color3.fromRGB(60, 60, 60)

local currentHue, currentSat, currentVal = 0, 1, 1
local activeColorCallback = nil

-- ★ UI更新を最適化し、無駄な再描画を防ぐ
local function updateColorPickerVisuals()
	local bgHsv = Color3.fromHSV(currentHue, 1, 1)
	if svArea.BackgroundColor3 ~= bgHsv then
		svArea.BackgroundColor3 = bgHsv
	end

	local svPos = UDim2.new(currentSat, 0, 1 - currentVal, 0)
	if svCursor.Position ~= svPos then
		svCursor.Position = svPos
	end

	local hPos = UDim2.new(currentHue, 0, 0.5, 0)
	if hueCursor.Position ~= hPos then
		hueCursor.Position = hPos
	end

	local finalColor = Color3.fromHSV(currentHue, currentSat, currentVal)
	if colorPreview.BackgroundColor3 ~= finalColor then
		colorPreview.BackgroundColor3 = finalColor
	end
end

-- ★ 劇的改善：RunServiceを使って毎フレーム確実に位置を計算する最強のドラッグシステム
local function setupSlider(area, isHue)
	area.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local dragging = true

			local function update()
				-- マウスの位置を直接ウィジェットから取得 (これなら確実に最新の位置が取れます)
				local mousePos = widget:GetRelativeMousePosition()
				local relX = math.clamp(mousePos.X - area.AbsolutePosition.X, 0, area.AbsoluteSize.X)
				local relY = math.clamp(mousePos.Y - area.AbsolutePosition.Y, 0, area.AbsoluteSize.Y)

				if isHue then
					currentHue = relX / area.AbsoluteSize.X
				else
					currentSat = relX / area.AbsoluteSize.X
					currentVal = 1 - (relY / area.AbsoluteSize.Y)
				end
				updateColorPickerVisuals()
			end

			update() -- クリックした瞬間の更新

			-- 毎フレーム超高速でUIを更新
			local loopConn
			loopConn = RunService.Heartbeat:Connect(function()
				if dragging then
					update()
				else
					loopConn:Disconnect()
				end
			end)

			-- マウスを離した判定
			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					loopConn:Disconnect()
					endConn:Disconnect()
				end
			end)
		end
	end)
end

setupSlider(svArea, false)
setupSlider(hueArea, true)

local function closePicker()
	pickerBlocker.Visible = false
	colorPickerBase.Visible = false
end

local function openCustomPicker(initialColor, callback)
	activeColorCallback = callback
	currentHue, currentSat, currentVal = initialColor:ToHSV()
	updateColorPickerVisuals()
	pickerBlocker.Visible = true
	colorPickerBase.Visible = true
end

pickerBlocker.MouseButton1Click:Connect(closePicker)
closeCpBtn.MouseButton1Click:Connect(closePicker)

confirmBtn.MouseButton1Click:Connect(function()
	if activeColorCallback then
		activeColorCallback(Color3.fromHSV(currentHue, currentSat, currentVal))
	end
	closePicker()
end)
-- ==========================================

-- --- システムロジック ---
local selectedElement = nil
local selectionHighlight = Instance.new("UIStroke")
selectionHighlight.Color = Color3.fromRGB(0, 162, 255)
selectionHighlight.Thickness = 3
selectionHighlight.Name = "SelectionHighlight"

local availableFonts = {
	Enum.Font.Gotham,
	Enum.Font.GothamBold,
	Enum.Font.FredokaOne,
	Enum.Font.LuckiestGuy,
	Enum.Font.Roboto,
	Enum.Font.Arcade,
}

local function updatePanel()
	if not selectedElement then
		return
	end
	propTitle.Text = selectedElement.ClassName

	local isText = selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")
	blockText.Visible, blockFont.Visible, blockTxtColor.Visible = isText, isText, isText

	if isText then
		textEditBox.Text = selectedElement.Text
		fontSelectBtn.Text = selectedElement.Font.Name
		txtHex.Text = toHex(selectedElement.TextColor3)
		txtChip.BackgroundColor3 = selectedElement.TextColor3
	end

	bgHex.Text = toHex(selectedElement.BackgroundColor3)
	bgChip.BackgroundColor3 = selectedElement.BackgroundColor3

	local stroke = selectedElement:FindFirstChild("DesignStroke")
	outlineBox.Text = stroke and tostring(stroke.Thickness) or "0"

	local grad = selectedElement:FindFirstChildOfClass("UIGradient")
	gradToggleBtn.Text = grad and "ON" or "OFF"
	gradToggleBtn.BackgroundColor3 = grad and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(50, 50, 50)
	blockGradColor.Visible = (grad ~= nil)
	if grad then
		local color2 = grad.Color.Keypoints[2].Value
		gr2Hex.Text = toHex(color2)
		gr2Chip.BackgroundColor3 = color2
	end

	cornerEditBox.Text = selectedElement:FindFirstChildOfClass("UICorner")
			and tostring(selectedElement:FindFirstChildOfClass("UICorner").CornerRadius.Offset)
		or "0"
	sizeX.Text, sizeY.Text =
		tostring(math.floor(selectedElement.AbsoluteSize.X)), tostring(math.floor(selectedElement.AbsoluteSize.Y))
	local pad = selectedElement:FindFirstChildOfClass("UIPadding")
	if pad then
		padT.Text, padB.Text, padL.Text, padR.Text =
			tostring(pad.PaddingTop.Offset),
			tostring(pad.PaddingBottom.Offset),
			tostring(pad.PaddingLeft.Offset),
			tostring(pad.PaddingRight.Offset)
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

-- --- 反映イベント ---
local function applyHexColors()
	if selectedElement then
		local newBg = fromHex(bgHex.Text)
		if newBg then
			selectedElement.BackgroundColor3 = newBg
		end

		if selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton") then
			local newTxt = fromHex(txtHex.Text)
			if newTxt then
				selectedElement.TextColor3 = newTxt
			end
		end

		local grad = selectedElement:FindFirstChildOfClass("UIGradient")
		if grad then
			local color2 = fromHex(gr2Hex.Text) or Color3.fromRGB(255, 255, 255)
			grad.Color = ColorSequence.new(selectedElement.BackgroundColor3, color2)
		end
		updatePanel()
	end
end
bgHex.FocusLost:Connect(applyHexColors)
txtHex.FocusLost:Connect(applyHexColors)
gr2Hex.FocusLost:Connect(applyHexColors)

bgChip.MouseButton1Click:Connect(function()
	if selectedElement then
		openCustomPicker(selectedElement.BackgroundColor3, function(color)
			bgHex.Text = toHex(color)
			applyHexColors()
		end)
	end
end)
txtChip.MouseButton1Click:Connect(function()
	if selectedElement and (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) then
		openCustomPicker(selectedElement.TextColor3, function(color)
			txtHex.Text = toHex(color)
			applyHexColors()
		end)
	end
end)
gr2Chip.MouseButton1Click:Connect(function()
	local grad = selectedElement and selectedElement:FindFirstChildOfClass("UIGradient")
	if grad then
		openCustomPicker(grad.Color.Keypoints[2].Value, function(color)
			gr2Hex.Text = toHex(color)
			applyHexColors()
		end)
	end
end)

for _, btn in ipairs(bgPresets) do
	btn.MouseButton1Click:Connect(function()
		bgHex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
	end)
end
for _, btn in ipairs(txtPresets) do
	btn.MouseButton1Click:Connect(function()
		txtHex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
	end)
end
for _, btn in ipairs(gr2Presets) do
	btn.MouseButton1Click:Connect(function()
		gr2Hex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
	end)
end

outlineBox.FocusLost:Connect(function()
	if selectedElement then
		local stroke = selectedElement:FindFirstChild("DesignStroke") or Instance.new("UIStroke", selectedElement)
		stroke.Name = "DesignStroke"
		stroke.Thickness = tonumber(outlineBox.Text) or 0
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end
end)

gradToggleBtn.MouseButton1Click:Connect(function()
	if selectedElement then
		local grad = selectedElement:FindFirstChildOfClass("UIGradient")
		if grad then
			grad:Destroy()
		else
			Instance.new("UIGradient", selectedElement)
			applyHexColors()
		end
		updatePanel()
	end
end)

textEditBox.FocusLost:Connect(function()
	if selectedElement and (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) then
		selectedElement.Text = textEditBox.Text
		task.wait(0.05)
		updatePanel()
	end
end)
fontSelectBtn.MouseButton1Click:Connect(function()
	if selectedElement and (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) then
		local cf = selectedElement.Font
		local ni = 1
		for i, f in ipairs(availableFonts) do
			if f == cf then
				ni = (i % #availableFonts) + 1
				break
			end
		end
		selectedElement.Font = availableFonts[ni]
		updatePanel()
	end
end)
cornerEditBox.FocusLost:Connect(function()
	if selectedElement then
		local c = selectedElement:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", selectedElement)
		c.CornerRadius = UDim.new(0, tonumber(cornerEditBox.Text) or 0)
	end
end)
local function applySize()
	if selectedElement then
		selectedElement.AutomaticSize = Enum.AutomaticSize.None
		selectedElement.Size = UDim2.new(
			0,
			tonumber(sizeX.Text) or selectedElement.AbsoluteSize.X,
			0,
			tonumber(sizeY.Text) or selectedElement.AbsoluteSize.Y
		)
		task.wait(0.05)
		updatePanel()
	end
end
sizeX.FocusLost:Connect(applySize)
sizeY.FocusLost:Connect(applySize)
local function updatePadding()
	if selectedElement then
		local p = selectedElement:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding", selectedElement)
		p.PaddingTop = UDim.new(0, tonumber(padT.Text) or 0)
		p.PaddingBottom = UDim.new(0, tonumber(padB.Text) or 0)
		p.PaddingLeft = UDim.new(0, tonumber(padL.Text) or 0)
		p.PaddingRight = UDim.new(0, tonumber(padR.Text) or 0)
		if selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton") then
			selectedElement.Size = UDim2.new(0, 0, 0, 0)
			selectedElement.AutomaticSize = Enum.AutomaticSize.XY
			selectedElement.TextWrapped = false
		end
		task.wait(0.05)
		updatePanel()
	end
end
padT.FocusLost:Connect(updatePadding)
padB.FocusLost:Connect(updatePadding)
padL.FocusLost:Connect(updatePadding)
padR.FocusLost:Connect(updatePadding)
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

-- ドラッグ・選択ロジック
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
			guiObject.Position = UDim2.new(
				startPos.X.Scale + (delta.X / canvasArea.AbsoluteSize.X),
				0,
				startPos.Y.Scale + (delta.Y / canvasArea.AbsoluteSize.Y),
				0
			)
			updatePanel()
		end
	end)
end

local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	newPart.Active, newPart.Selectable = true, true
	newPart.Size, newPart.Position = UDim2.new(0, 150, 0, 50), UDim2.new(0.1, 0, 0.1, 0)
	if className ~= "Frame" then
		newPart.Text = "New Element"
		newPart.BackgroundColor3 = className == "TextLabel" and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(46, 204, 113)
		newPart.Font = Enum.Font.GothamBold
		newPart.TextSize = 18
		newPart.TextScaled = false
		local p = Instance.new("UIPadding", newPart)
		p.PaddingLeft, p.PaddingRight = UDim.new(0, 15), UDim.new(0, 15)
	else
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	local s = Instance.new("UIStroke", newPart)
	s.Color = Color3.fromRGB(150, 150, 150)
	s.Name = "DesignStroke"
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
			local h = clone:FindFirstChild("SelectionHighlight")
			if h then
				h:Destroy()
			end
			clone.Parent = exportGui
		end
	end
end)
toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
