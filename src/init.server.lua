-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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

-- --- 背景とトップバー構築 ---
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
topLayout.Padding = UDim.new(0, 6)
topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding", topBar).PaddingLeft = UDim.new(0, 12)

local function createToolButton(text, color, width)
	local btn = Instance.new("TextButton", topBar)
	btn.Size = UDim2.new(0, width or 90, 0, 34)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.BuilderSansBold
	btn.TextSize = 13
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local btnFrame = createToolButton("＋ 四角", Color3.fromRGB(0, 120, 215), 70)
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113), 70)
local btnButton = createToolButton("＋ Btn", Color3.fromRGB(155, 89, 182), 65)

local btnSnap = createToolButton("🧲 10px", Color3.fromRGB(52, 152, 219), 75)

local btnDuplicate = createToolButton("👯", Color3.fromRGB(80, 80, 80), 35)
local btnDelete = createToolButton("🗑️", Color3.fromRGB(231, 76, 60), 35)
local btnUndo = createToolButton("↩️", Color3.fromRGB(60, 60, 60), 35)
local btnRedo = createToolButton("↪️", Color3.fromRGB(60, 60, 60), 35)

local btnExport = createToolButton("📤 出力", Color3.fromRGB(230, 126, 34), 70)

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
propertyPanel.CanvasSize = UDim2.new(0, 0, 0, 1350)
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

-- ==========================================
-- ★ 新機能：ALIGNMENT（自動整列ツール） ★
-- ==========================================
local blockAlign, areaAlign = createPropertyBlock("ALIGNMENT (ALIGN & DISTRIBUTE)", propertyPanel, 55)

local function createAlignBtn(text, parent, pos)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.31, 0, 1, 0)
	b.Position = UDim2.new(pos, 0, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Text = text
	b.Font = Enum.Font.BuilderSansBold
	b.TextSize = 10
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	return b
end

local alignRow1 = Instance.new("Frame", areaAlign)
alignRow1.Size = UDim2.new(1, 0, 0, 24)
alignRow1.BackgroundTransparency = 1
local btnAlignLeft = createAlignBtn("左揃え", alignRow1, 0)
local btnAlignCenterX = createAlignBtn("中央(横)", alignRow1, 0.345)
local btnAlignRight = createAlignBtn("右揃え", alignRow1, 0.69)

local alignRow2 = Instance.new("Frame", areaAlign)
alignRow2.Size = UDim2.new(1, 0, 0, 24)
alignRow2.Position = UDim2.new(0, 0, 0, 29)
alignRow2.BackgroundTransparency = 1
local btnAlignTop = createAlignBtn("上揃え", alignRow2, 0)
local btnAlignCenterY = createAlignBtn("中央(縦)", alignRow2, 0.345)
local btnAlignBottom = createAlignBtn("下揃え", alignRow2, 0.69)

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

local blockFontSize, areaFontSize = createPropertyBlock("FONT SIZE (px)", propertyPanel, 28)
local fontSizeBox = createTextBox(areaFontSize)
fontSizeBox.PlaceholderText = "14"

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

local blockZIndex, areaZIndex = createPropertyBlock("Z-INDEX (LAYER ORDER)", propertyPanel, 28)
local zIndexContainer = Instance.new("Frame", areaZIndex)
zIndexContainer.Size = UDim2.new(1, 0, 1, 0)
zIndexContainer.BackgroundTransparency = 1
local zLayout = Instance.new("UIListLayout", zIndexContainer)
zLayout.FillDirection = Enum.FillDirection.Horizontal
zLayout.Padding = UDim.new(0, 5)
local zIndexBox = createTextBox(zIndexContainer)
zIndexBox.Size = UDim2.new(0.45, 0, 1, 0)
local btnZDown = Instance.new("TextButton", zIndexContainer)
btnZDown.Size = UDim2.new(0.25, 0, 1, 0)
btnZDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnZDown.TextColor3 = Color3.fromRGB(200, 200, 200)
btnZDown.Text = "-1 (奥)"
btnZDown.Font = Enum.Font.BuilderSansBold
btnZDown.TextSize = 10
Instance.new("UICorner", btnZDown).CornerRadius = UDim.new(0, 4)
local btnZUp = Instance.new("TextButton", zIndexContainer)
btnZUp.Size = UDim2.new(0.25, 0, 1, 0)
btnZUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
btnZUp.TextColor3 = Color3.fromRGB(200, 200, 200)
btnZUp.Text = "+1 (手前)"
btnZUp.Font = Enum.Font.BuilderSansBold
btnZUp.TextSize = 10
Instance.new("UICorner", btnZUp).CornerRadius = UDim.new(0, 4)

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
-- ★ スナップ管理 ★
-- ==========================================
local snapSizes = { 1, 5, 10, 20 }
local currentSnapIndex = 3
local snapSize = snapSizes[currentSnapIndex]

btnSnap.MouseButton1Click:Connect(function()
	currentSnapIndex = currentSnapIndex + 1
	if currentSnapIndex > #snapSizes then
		currentSnapIndex = 1
	end
	snapSize = snapSizes[currentSnapIndex]
	if snapSize == 1 then
		btnSnap.Text = "🧲 OFF"
		btnSnap.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	else
		btnSnap.Text = "🧲 " .. snapSize .. "px"
		btnSnap.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
	end
end)

-- ==========================================
-- ★ ヒストリーエンジン (Undo/Redo) ★
-- ==========================================
local historyStack = {}
local historyIndex = 0
local maxHistory = 50

function saveState()
	for i = #historyStack, historyIndex + 1, -1 do
		historyStack[i] = nil
	end
	local state = {}
	for _, child in ipairs(canvasArea:GetChildren()) do
		if
			child:IsA("GuiObject")
			and not child.Name:match("Highlight")
			and child.Name ~= "ClickCatcher"
			and child.Name ~= "MarqueeBox"
		then
			table.insert(state, child:Clone())
		end
	end
	table.insert(historyStack, state)
	if #historyStack > maxHistory then
		table.remove(historyStack, 1)
	else
		historyIndex = historyIndex + 1
	end
end

local function loadState(index)
	if index < 1 or index > #historyStack then
		return
	end
	for _, child in ipairs(canvasArea:GetChildren()) do
		if
			child:IsA("GuiObject")
			and not child.Name:match("Highlight")
			and child.Name ~= "ClickCatcher"
			and child.Name ~= "MarqueeBox"
		then
			child:Destroy()
		end
	end
	local state = historyStack[index]
	for _, savedChild in ipairs(state) do
		local clone = savedChild:Clone()
		clone.Parent = canvasArea
	end
	if _G.clearSelection then
		_G.clearSelection()
	end
end

local function undoState()
	if historyIndex > 1 then
		historyIndex = historyIndex - 1
		loadState(historyIndex)
	end
end
local function redoState()
	if historyIndex < #historyStack then
		historyIndex = historyIndex + 1
		loadState(historyIndex)
	end
end

btnUndo.MouseButton1Click:Connect(undoState)
btnRedo.MouseButton1Click:Connect(redoState)

-- ==========================================
-- ★ 60fps カラーピッカー ★
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
local pickerOriginalColor = nil

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
	if activeColorCallback then
		activeColorCallback(finalColor)
	end
end

local function setupSlider(area, isHue)
	area.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local dragging = true
			local function update()
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
			update()
			local loopConn
			loopConn = RunService.Heartbeat:Connect(function()
				if dragging then
					update()
				else
					loopConn:Disconnect()
				end
			end)
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
	pickerOriginalColor = initialColor
	currentHue, currentSat, currentVal = initialColor:ToHSV()
	updateColorPickerVisuals()
	pickerBlocker.Visible = true
	colorPickerBase.Visible = true
end

local function cancelPicker()
	if activeColorCallback and pickerOriginalColor then
		activeColorCallback(pickerOriginalColor)
	end
	closePicker()
end
pickerBlocker.MouseButton1Click:Connect(cancelPicker)
closeCpBtn.MouseButton1Click:Connect(cancelPicker)
confirmBtn.MouseButton1Click:Connect(function()
	closePicker()
	saveState()
end)

-- ==========================================
-- ★ 新機能：複数選択（Multi-Selection）とハイライト管理 ★
-- ==========================================
local selectedElements = {}
local highlightFrames = {}
local isResizing = false

local selectionHighlight = Instance.new("Frame")
selectionHighlight.Name = "SelectionHighlight"
selectionHighlight.BackgroundTransparency = 1
selectionHighlight.Active = false
selectionHighlight.ZIndex = 9999
selectionHighlight.Visible = false
selectionHighlight.Parent = canvasArea

local shStroke = Instance.new("UIStroke", selectionHighlight)
shStroke.Color = Color3.fromRGB(0, 162, 255)
shStroke.Thickness = 2
shStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local shCorner = Instance.new("UICorner", selectionHighlight)

local resizeHandles = {}
local handleDirs = {
	TopLeft = { x = -1, y = -1 },
	Top = { x = 0, y = -1 },
	TopRight = { x = 1, y = -1 },
	Left = { x = -1, y = 0 },
	Right = { x = 1, y = 0 },
	BottomLeft = { x = -1, y = 1 },
	Bottom = { x = 0, y = 1 },
	BottomRight = { x = 1, y = 1 },
}

for name, dir in pairs(handleDirs) do
	local handle = Instance.new("TextButton")
	handle.Name = name
	handle.Size = UDim2.new(0, 8, 0, 8)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.Text = ""
	handle.AutoButtonColor = false
	handle.ZIndex = 10000
	handle.Active = true
	local hStroke = Instance.new("UIStroke", handle)
	hStroke.Color = Color3.fromRGB(0, 120, 215)
	hStroke.Thickness = 1

	if name == "TopLeft" then
		handle.Position = UDim2.new(0, 0, 0, 0)
	elseif name == "Top" then
		handle.Position = UDim2.new(0.5, 0, 0, 0)
	elseif name == "TopRight" then
		handle.Position = UDim2.new(1, 0, 0, 0)
	elseif name == "Left" then
		handle.Position = UDim2.new(0, 0, 0.5, 0)
	elseif name == "Right" then
		handle.Position = UDim2.new(1, 0, 0.5, 0)
	elseif name == "BottomLeft" then
		handle.Position = UDim2.new(0, 0, 1, 0)
	elseif name == "Bottom" then
		handle.Position = UDim2.new(0.5, 0, 1, 0)
	elseif name == "BottomRight" then
		handle.Position = UDim2.new(1, 0, 1, 0)
	end

	handle.Parent = selectionHighlight
	resizeHandles[name] = { btn = handle, dir = dir }
end

local function refreshHighlights()
	for _, h in ipairs(highlightFrames) do
		h.frame:Destroy()
	end
	highlightFrames = {}

	for _, el in ipairs(selectedElements) do
		local hl = Instance.new("Frame")
		hl.Name = "MultiHighlight"
		hl.BackgroundTransparency = 1
		hl.ZIndex = 9999
		local s = Instance.new("UIStroke", hl)
		s.Color = Color3.fromRGB(0, 162, 255)
		s.Thickness = 2
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local c = Instance.new("UICorner", hl)
		hl.Parent = canvasArea
		table.insert(highlightFrames, { frame = hl, target = el, corner = c })
	end
end

RunService.Heartbeat:Connect(function()
	for _, hd in ipairs(highlightFrames) do
		if hd.target and hd.target.Parent then
			hd.frame.Size = UDim2.new(0, hd.target.AbsoluteSize.X, 0, hd.target.AbsoluteSize.Y)
			hd.frame.Position = hd.target.Position
			local c = hd.target:FindFirstChildOfClass("UICorner")
			hd.corner.CornerRadius = c and c.CornerRadius or UDim.new(0, 0)
		end
	end

	if #selectedElements == 1 then
		local target = selectedElements[1]
		selectionHighlight.Visible = true
		if not isResizing then
			selectionHighlight.Size = UDim2.new(0, target.AbsoluteSize.X, 0, target.AbsoluteSize.Y)
			selectionHighlight.Position = target.Position
			local c = target:FindFirstChildOfClass("UICorner")
			shCorner.CornerRadius = c and c.CornerRadius or UDim.new(0, 0)
		end
	else
		selectionHighlight.Visible = false
	end
end)

local resizeLoopConn = nil
for name, data in pairs(resizeHandles) do
	data.btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if #selectedElements ~= 1 then
				return
			end
			local targetElement = selectedElements[1]

			isResizing = true
			local startMouse = widget:GetRelativeMousePosition()
			local startSize = targetElement.Size
			local startPos = targetElement.Position
			local dir = data.dir

			if resizeLoopConn then
				resizeLoopConn:Disconnect()
			end

			resizeLoopConn = RunService.Heartbeat:Connect(function()
				if isResizing and targetElement then
					local currentMouse = widget:GetRelativeMousePosition()
					local deltaX = currentMouse.X - startMouse.X
					local deltaY = currentMouse.Y - startMouse.Y

					local newSizeX = startSize.X.Offset
					local newSizeY = startSize.Y.Offset
					local newPosX = startPos.X.Offset
					local newPosY = startPos.Y.Offset

					if dir.x == 1 then
						local targetEdgeX = startPos.X.Offset + startSize.X.Offset + deltaX
						local snappedEdgeX = math.floor(targetEdgeX / snapSize + 0.5) * snapSize
						newSizeX = math.max(10, snappedEdgeX - startPos.X.Offset)
					elseif dir.x == -1 then
						local targetEdgeX = startPos.X.Offset + deltaX
						local snappedEdgeX = math.floor(targetEdgeX / snapSize + 0.5) * snapSize
						newSizeX = math.max(10, startPos.X.Offset + startSize.X.Offset - snappedEdgeX)
						newPosX = startPos.X.Offset + startSize.X.Offset - newSizeX
					end

					if dir.y == 1 then
						local targetEdgeY = startPos.Y.Offset + startSize.Y.Offset + deltaY
						local snappedEdgeY = math.floor(targetEdgeY / snapSize + 0.5) * snapSize
						newSizeY = math.max(10, snappedEdgeY - startPos.Y.Offset)
					elseif dir.y == -1 then
						local targetEdgeY = startPos.Y.Offset + deltaY
						local snappedEdgeY = math.floor(targetEdgeY / snapSize + 0.5) * snapSize
						newSizeY = math.max(10, startPos.Y.Offset + startSize.Y.Offset - snappedEdgeY)
						newPosY = startPos.Y.Offset + startSize.Y.Offset - newSizeY
					end

					targetElement.Size = UDim2.new(startSize.X.Scale, newSizeX, startSize.Y.Scale, newSizeY)
					targetElement.Position = UDim2.new(startPos.X.Scale, newPosX, startPos.Y.Scale, newPosY)

					selectionHighlight.Size = UDim2.new(0, newSizeX, 0, newSizeY)
					selectionHighlight.Position = UDim2.new(startPos.X.Scale, newPosX, startPos.Y.Scale, newPosY)

					if _G.updatePanelVisuals then
						_G.updatePanelVisuals(newSizeX, newSizeY)
					end
				end
			end)

			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if isResizing and targetElement and targetElement.Size ~= startSize then
						saveState()
					end
					isResizing = false
					if resizeLoopConn then
						resizeLoopConn:Disconnect()
					end
					endConn:Disconnect()
				end
			end)
		end
	end)
end

-- --- プロパティパネル管理 ---
local allBlocks = {
	blockAlign,
	blockText,
	blockFont,
	blockFontSize,
	blockBgColor,
	blockTxtColor,
	blockOutline,
	blockGradToggle,
	blockGradColor,
	blockCorner,
	blockSize,
	blockPadding,
	blockZIndex,
	blockAuto,
}

function _G.updatePanelVisuals(sx, sy)
	if sizeX and sizeY then
		sizeX.Text = tostring(math.floor(sx))
		sizeY.Text = tostring(math.floor(sy))
	end
end

local function updatePanel()
	if #selectedElements == 0 then
		propTitle.Text = "No Selection"
		for _, block in ipairs(allBlocks) do
			block.Visible = false
		end
		return
	elseif #selectedElements > 1 then
		propTitle.Text = "Multiple (" .. #selectedElements .. ")"
		for _, block in ipairs(allBlocks) do
			block.Visible = false
		end
		blockAlign.Visible = true -- ★ 複数選択時も整列ツールは表示する！
		return
	end

	local target = selectedElements[1]
	if not target or not target.Parent then
		return
	end

	for _, block in ipairs(allBlocks) do
		block.Visible = true
	end

	propTitle.Text = target.ClassName
	local isText = target:IsA("TextLabel") or target:IsA("TextButton")
	blockText.Visible = isText
	blockFont.Visible = isText
	blockFontSize.Visible = isText
	blockTxtColor.Visible = isText

	if isText then
		textEditBox.Text = target.Text
		fontSelectBtn.Text = target.Font.Name
		fontSizeBox.Text = tostring(target.TextSize)
		txtHex.Text = toHex(target.TextColor3)
		txtChip.BackgroundColor3 = target.TextColor3
	end

	bgHex.Text = toHex(target.BackgroundColor3)
	bgChip.BackgroundColor3 = target.BackgroundColor3
	local stroke = target:FindFirstChild("DesignStroke")
	outlineBox.Text = stroke and tostring(stroke.Thickness) or "0"

	local grad = target:FindFirstChildOfClass("UIGradient")
	gradToggleBtn.Text = grad and "ON" or "OFF"
	gradToggleBtn.BackgroundColor3 = grad and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(50, 50, 50)
	blockGradColor.Visible = (grad ~= nil)
	if grad then
		local color2 = grad.Color.Keypoints[2].Value
		gr2Hex.Text = toHex(color2)
		gr2Chip.BackgroundColor3 = color2
	end

	cornerEditBox.Text = target:FindFirstChildOfClass("UICorner")
			and tostring(target:FindFirstChildOfClass("UICorner").CornerRadius.Offset)
		or "0"
	if not isResizing then
		sizeX.Text, sizeY.Text =
			tostring(math.floor(target.AbsoluteSize.X)), tostring(math.floor(target.AbsoluteSize.Y))
	end

	local pad = target:FindFirstChildOfClass("UIPadding")
	if pad then
		padT.Text, padB.Text, padL.Text, padR.Text =
			tostring(pad.PaddingTop.Offset),
			tostring(pad.PaddingBottom.Offset),
			tostring(pad.PaddingLeft.Offset),
			tostring(pad.PaddingRight.Offset)
	else
		padT.Text, padB.Text, padL.Text, padR.Text = "0", "0", "0", "0"
	end
	zIndexBox.Text = tostring(target.ZIndex)
	local current = target.AutomaticSize
	btnNone.BackgroundColor3 = current == Enum.AutomaticSize.None and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnX.BackgroundColor3 = current == Enum.AutomaticSize.X and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnY.BackgroundColor3 = current == Enum.AutomaticSize.Y and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
	btnXY.BackgroundColor3 = current == Enum.AutomaticSize.XY and Color3.fromRGB(0, 120, 215)
		or Color3.fromRGB(50, 50, 50)
end

function _G.clearSelection()
	selectedElements = {}
	refreshHighlights()
	updatePanel()
end

-- ==========================================
-- ★ 新機能：ALIGNMENT（自動整列の実行ロジック） ★
-- ==========================================
local function alignElements(mode)
	if #selectedElements == 0 then
		return
	end

	local targetMinX, targetMaxX, targetMinY, targetMaxY
	local canvasWidth = canvasArea.AbsoluteSize.X
	local canvasHeight = canvasArea.AbsoluteSize.Y

	-- 単一選択時はキャンバス全体を基準に整列
	if #selectedElements == 1 then
		targetMinX, targetMinY = 0, 0
		targetMaxX, targetMaxY = canvasWidth, canvasHeight
	else
		-- 複数選択時は選択された要素の「一番外側の枠（バウンディングボックス）」を基準に整列
		targetMinX, targetMinY = math.huge, math.huge
		targetMaxX, targetMaxY = -math.huge, -math.huge
		for _, el in ipairs(selectedElements) do
			local ex, ey = el.Position.X.Offset, el.Position.Y.Offset
			local ew, eh = el.Size.X.Offset, el.Size.Y.Offset
			targetMinX = math.min(targetMinX, ex)
			targetMinY = math.min(targetMinY, ey)
			targetMaxX = math.max(targetMaxX, ex + ew)
			targetMaxY = math.max(targetMaxY, ey + eh)
		end
	end

	-- 一気に整列させる
	for _, el in ipairs(selectedElements) do
		local ew, eh = el.Size.X.Offset, el.Size.Y.Offset
		local newX = el.Position.X.Offset
		local newY = el.Position.Y.Offset

		if mode == "Left" then
			newX = targetMinX
		elseif mode == "CenterX" then
			newX = (targetMinX + targetMaxX) / 2 - ew / 2
		elseif mode == "Right" then
			newX = targetMaxX - ew
		elseif mode == "Top" then
			newY = targetMinY
		elseif mode == "CenterY" then
			newY = (targetMinY + targetMaxY) / 2 - eh / 2
		elseif mode == "Bottom" then
			newY = targetMaxY - eh
		end

		-- 少数を切り捨ててピタッと配置
		el.Position = UDim2.new(el.Position.X.Scale, math.floor(newX), el.Position.Y.Scale, math.floor(newY))
	end

	updatePanel()
	saveState()
end

-- 整列ボタンのイベント接続
btnAlignLeft.MouseButton1Click:Connect(function()
	alignElements("Left")
end)
btnAlignCenterX.MouseButton1Click:Connect(function()
	alignElements("CenterX")
end)
btnAlignRight.MouseButton1Click:Connect(function()
	alignElements("Right")
end)
btnAlignTop.MouseButton1Click:Connect(function()
	alignElements("Top")
end)
btnAlignCenterY.MouseButton1Click:Connect(function()
	alignElements("CenterY")
end)
btnAlignBottom.MouseButton1Click:Connect(function()
	alignElements("Bottom")
end)

-- ==========================================
-- ★ ドラッグ囲み選択 (Marquee) と 複数ドラッグ ★
-- ==========================================
local clickCatcher = Instance.new("TextButton")
clickCatcher.Name = "ClickCatcher"
clickCatcher.Size = UDim2.new(1, 0, 1, 0)
clickCatcher.BackgroundTransparency = 1
clickCatcher.Text = ""
clickCatcher.ZIndex = 9998
clickCatcher.Parent = canvasArea

local marqueeBox = Instance.new("Frame")
marqueeBox.Name = "MarqueeBox"
marqueeBox.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
marqueeBox.BackgroundTransparency = 0.8
marqueeBox.BorderSizePixel = 1
marqueeBox.BorderColor3 = Color3.fromRGB(0, 162, 255)
marqueeBox.ZIndex = 10000
marqueeBox.Visible = false
marqueeBox.Parent = canvasArea

local dragLoopConn = nil

clickCatcher.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if pickerBlocker.Visible or isResizing then
			return
		end

		local mousePos = input.Position
		local topElement = nil
		local highestZIndex = -math.huge
		local highestChildIndex = -1

		local children = canvasArea:GetChildren()
		for i, child in ipairs(children) do
			if
				child:IsA("GuiObject")
				and not child.Name:match("Highlight")
				and child.Name ~= "ClickCatcher"
				and child.Name ~= "MarqueeBox"
			then
				local pos = child.AbsolutePosition
				local size = child.AbsoluteSize
				if
					mousePos.X >= pos.X
					and mousePos.X <= (pos.X + size.X)
					and mousePos.Y >= pos.Y
					and mousePos.Y <= (pos.Y + size.Y)
				then
					if child.ZIndex > highestZIndex or (child.ZIndex == highestZIndex and i > highestChildIndex) then
						topElement = child
						highestZIndex = child.ZIndex
						highestChildIndex = i
					end
				end
			end
		end

		if topElement then
			if not table.find(selectedElements, topElement) then
				selectedElements = { topElement }
				refreshHighlights()
				updatePanel()
			end

			local dragStartMouseWidget = widget:GetRelativeMousePosition()
			local startOffsets = {}
			for _, el in ipairs(selectedElements) do
				startOffsets[el] = el.Position
			end

			local dragging = true
			if dragLoopConn then
				dragLoopConn:Disconnect()
			end
			dragLoopConn = RunService.Heartbeat:Connect(function()
				if dragging then
					local currentMouse = widget:GetRelativeMousePosition()
					local deltaX = currentMouse.X - dragStartMouseWidget.X
					local deltaY = currentMouse.Y - dragStartMouseWidget.Y

					for _, el in ipairs(selectedElements) do
						local startPos = startOffsets[el]
						if startPos then
							local rawX = startPos.X.Offset + deltaX
							local rawY = startPos.Y.Offset + deltaY
							local snappedX = math.floor(rawX / snapSize + 0.5) * snapSize
							local snappedY = math.floor(rawY / snapSize + 0.5) * snapSize
							el.Position = UDim2.new(startPos.X.Scale, snappedX, startPos.Y.Scale, snappedY)
						end
					end
					if #selectedElements == 1 then
						updatePanel()
					end
				end
			end)

			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if dragLoopConn then
						dragLoopConn:Disconnect()
					end

					local moved = false
					for _, el in ipairs(selectedElements) do
						if startOffsets[el] and el.Position ~= startOffsets[el] then
							moved = true
							break
						end
					end
					if moved then
						saveState()
					end

					endConn:Disconnect()
				end
			end)
		else
			selectedElements = {}
			refreshHighlights()
			updatePanel()

			marqueeBox.Visible = true
			local startMouseWidget = widget:GetRelativeMousePosition()
			local canvasAbsPos = canvasArea.AbsolutePosition

			local localStartX = startMouseWidget.X - canvasAbsPos.X
			local localStartY = startMouseWidget.Y - canvasAbsPos.Y

			marqueeBox.Position = UDim2.new(0, localStartX, 0, localStartY)
			marqueeBox.Size = UDim2.new(0, 0, 0, 0)

			local drawing = true
			if dragLoopConn then
				dragLoopConn:Disconnect()
			end
			dragLoopConn = RunService.Heartbeat:Connect(function()
				if drawing then
					local currentMouseWidget = widget:GetRelativeMousePosition()
					local curX = math.clamp(currentMouseWidget.X - canvasAbsPos.X, 0, canvasArea.AbsoluteSize.X)
					local curY = math.clamp(currentMouseWidget.Y - canvasAbsPos.Y, 0, canvasArea.AbsoluteSize.Y)

					local startX = math.clamp(localStartX, 0, canvasArea.AbsoluteSize.X)
					local startY = math.clamp(localStartY, 0, canvasArea.AbsoluteSize.Y)

					local minX = math.min(startX, curX)
					local minY = math.min(startY, curY)
					local width = math.abs(startX - curX)
					local height = math.abs(startY - curY)

					marqueeBox.Position = UDim2.new(0, minX, 0, minY)
					marqueeBox.Size = UDim2.new(0, width, 0, height)
				end
			end)

			local endConn
			endConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					drawing = false
					marqueeBox.Visible = false
					if dragLoopConn then
						dragLoopConn:Disconnect()
					end
					endConn:Disconnect()

					local mPos = marqueeBox.AbsolutePosition
					local mSize = marqueeBox.AbsoluteSize
					local mRect = Rect.new(mPos, mPos + mSize)

					local newSelection = {}
					for _, child in ipairs(canvasArea:GetChildren()) do
						if
							child:IsA("GuiObject")
							and not child.Name:match("Highlight")
							and child.Name ~= "ClickCatcher"
							and child.Name ~= "MarqueeBox"
						then
							local cPos = child.AbsolutePosition
							local cSize = child.AbsoluteSize
							local cRect = Rect.new(cPos, cPos + cSize)

							if
								mRect.Min.X < cRect.Max.X
								and mRect.Max.X > cRect.Min.X
								and mRect.Min.Y < cRect.Max.Y
								and mRect.Max.Y > cRect.Min.Y
							then
								table.insert(newSelection, child)
							end
						end
					end

					selectedElements = newSelection
					refreshHighlights()
					updatePanel()
				end
			end)
		end
	end
end)

-- ==========================================
-- ★ 削除・複製・ショートカット ★
-- ==========================================
local function deleteSelected()
	if #selectedElements > 0 then
		for _, el in ipairs(selectedElements) do
			el:Destroy()
		end
		_G.clearSelection()
		saveState()
	end
end

local function duplicateSelected()
	if #selectedElements > 0 then
		local newSelection = {}
		for _, el in ipairs(selectedElements) do
			local clone = el:Clone()
			clone.Parent = canvasArea
			clone.Position = UDim2.new(
				el.Position.X.Scale,
				el.Position.X.Offset + 15,
				el.Position.Y.Scale,
				el.Position.Y.Offset + 15
			)
			clone.ZIndex = clone.ZIndex + 1
			table.insert(newSelection, clone)
		end
		selectedElements = newSelection
		refreshHighlights()
		updatePanel()
		saveState()
	end
end

local function updateZIndexDirect()
	if #selectedElements == 1 then
		selectedElements[1].ZIndex = tonumber(zIndexBox.Text) or selectedElements[1].ZIndex
		task.wait(0.05)
		updatePanel()
		saveState()
	end
end

local function moveZIndex(amount)
	if #selectedElements > 0 then
		for _, el in ipairs(selectedElements) do
			el.ZIndex = el.ZIndex + amount
		end
		updatePanel()
		saveState()
	end
end

btnDelete.MouseButton1Click:Connect(deleteSelected)
btnDuplicate.MouseButton1Click:Connect(duplicateSelected)
zIndexBox.FocusLost:Connect(updateZIndexDirect)
btnZDown.MouseButton1Click:Connect(function()
	moveZIndex(-1)
end)
btnZUp.MouseButton1Click:Connect(function()
	moveZIndex(1)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end
	if not widget.Enabled then
		return
	end

	local ctrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		or UserInputService:IsKeyDown(Enum.KeyCode.LeftSuper)
		or UserInputService:IsKeyDown(Enum.KeyCode.RightSuper)

	if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
		deleteSelected()
	elseif input.KeyCode == Enum.KeyCode.D and ctrlPressed then
		duplicateSelected()
	elseif input.KeyCode == Enum.KeyCode.RightBracket and ctrlPressed then
		moveZIndex(1)
	elseif input.KeyCode == Enum.KeyCode.LeftBracket and ctrlPressed then
		moveZIndex(-1)
	elseif input.KeyCode == Enum.KeyCode.Z and ctrlPressed then
		local shiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
			or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		if shiftPressed then
			redoState()
		else
			undoState()
		end
	elseif input.KeyCode == Enum.KeyCode.Y and ctrlPressed then
		redoState()
	end
end)

-- --- プロパティの反映 ---
local function applyHexColors()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		local newBg = fromHex(bgHex.Text)
		if newBg then
			target.BackgroundColor3 = newBg
		end
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			local newTxt = fromHex(txtHex.Text)
			if newTxt then
				target.TextColor3 = newTxt
			end
		end
		local grad = target:FindFirstChildOfClass("UIGradient")
		if grad then
			local color2 = fromHex(gr2Hex.Text) or Color3.fromRGB(255, 255, 255)
			grad.Color = ColorSequence.new(target.BackgroundColor3, color2)
		end
		updatePanel()
	end
end

bgHex.FocusLost:Connect(function()
	applyHexColors()
	saveState()
end)
txtHex.FocusLost:Connect(function()
	applyHexColors()
	saveState()
end)
gr2Hex.FocusLost:Connect(function()
	applyHexColors()
	saveState()
end)

bgChip.MouseButton1Click:Connect(function()
	if #selectedElements == 1 then
		openCustomPicker(selectedElements[1].BackgroundColor3, function(color)
			bgHex.Text = toHex(color)
			applyHexColors()
		end)
	end
end)
txtChip.MouseButton1Click:Connect(function()
	if #selectedElements == 1 and (selectedElements[1]:IsA("TextLabel") or selectedElements[1]:IsA("TextButton")) then
		openCustomPicker(selectedElements[1].TextColor3, function(color)
			txtHex.Text = toHex(color)
			applyHexColors()
		end)
	end
end)
gr2Chip.MouseButton1Click:Connect(function()
	if #selectedElements == 1 then
		local grad = selectedElements[1]:FindFirstChildOfClass("UIGradient")
		if grad then
			openCustomPicker(grad.Color.Keypoints[2].Value, function(color)
				gr2Hex.Text = toHex(color)
				applyHexColors()
			end)
		end
	end
end)

for _, btn in ipairs(bgPresets) do
	btn.MouseButton1Click:Connect(function()
		bgHex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
		saveState()
	end)
end
for _, btn in ipairs(txtPresets) do
	btn.MouseButton1Click:Connect(function()
		txtHex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
		saveState()
	end)
end
for _, btn in ipairs(gr2Presets) do
	btn.MouseButton1Click:Connect(function()
		gr2Hex.Text = toHex(btn.BackgroundColor3)
		applyHexColors()
		saveState()
	end)
end

outlineBox.FocusLost:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		local stroke = target:FindFirstChild("DesignStroke") or Instance.new("UIStroke", target)
		stroke.Name = "DesignStroke"
		stroke.Thickness = tonumber(outlineBox.Text) or 0
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		saveState()
	end
end)
gradToggleBtn.MouseButton1Click:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		local grad = target:FindFirstChildOfClass("UIGradient")
		if grad then
			grad:Destroy()
		else
			Instance.new("UIGradient", target)
			applyHexColors()
		end
		updatePanel()
		saveState()
	end
end)
textEditBox.FocusLost:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			target.Text = textEditBox.Text
			task.wait(0.05)
			updatePanel()
			saveState()
		end
	end
end)
fontSelectBtn.MouseButton1Click:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			local cf = target.Font
			local ni = 1
			for i, f in ipairs(availableFonts) do
				if f == cf then
					ni = (i % #availableFonts) + 1
					break
				end
			end
			target.Font = availableFonts[ni]
			updatePanel()
			saveState()
		end
	end
end)
fontSizeBox.FocusLost:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			target.TextSize = tonumber(fontSizeBox.Text) or 14
			task.wait(0.05)
			updatePanel()
			saveState()
		end
	end
end)
cornerEditBox.FocusLost:Connect(function()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		local c = target:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", target)
		c.CornerRadius = UDim.new(0, tonumber(cornerEditBox.Text) or 0)
		saveState()
	end
end)

local function applySize()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		target.AutomaticSize = Enum.AutomaticSize.None
		target.Size = UDim2.new(
			0,
			tonumber(sizeX.Text) or target.AbsoluteSize.X,
			0,
			tonumber(sizeY.Text) or target.AbsoluteSize.Y
		)
		task.wait(0.05)
		updatePanel()
		saveState()
	end
end
sizeX.FocusLost:Connect(applySize)
sizeY.FocusLost:Connect(applySize)

local function updatePadding()
	if #selectedElements == 1 then
		local target = selectedElements[1]
		local p = target:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding", target)
		p.PaddingTop = UDim.new(0, tonumber(padT.Text) or 0)
		p.PaddingBottom = UDim.new(0, tonumber(padB.Text) or 0)
		p.PaddingLeft = UDim.new(0, tonumber(padL.Text) or 0)
		p.PaddingRight = UDim.new(0, tonumber(padR.Text) or 0)
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			target.Size = UDim2.new(0, 0, 0, 0)
			target.AutomaticSize = Enum.AutomaticSize.XY
			target.TextWrapped = false
		end
		task.wait(0.05)
		updatePanel()
		saveState()
	end
end
padT.FocusLost:Connect(updatePadding)
padB.FocusLost:Connect(updatePadding)
padL.FocusLost:Connect(updatePadding)
padR.FocusLost:Connect(updatePadding)

local function setAutoSize(mode)
	if #selectedElements == 1 then
		local target = selectedElements[1]
		target.AutomaticSize = mode
		if target:IsA("TextLabel") or target:IsA("TextButton") then
			target.TextWrapped = (mode == Enum.AutomaticSize.None)
		end
		updatePanel()
		saveState()
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

local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	newPart.Size = UDim2.new(0, 150, 0, 50)
	newPart.Position = UDim2.new(0, math.floor(50 / snapSize) * snapSize, 0, math.floor(50 / snapSize) * snapSize)
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
	local highestZ = 0
	for _, child in ipairs(canvasArea:GetChildren()) do
		if
			child:IsA("GuiObject")
			and child ~= newPart
			and not child.Name:match("Highlight")
			and child.Name ~= "ClickCatcher"
			and child.Name ~= "MarqueeBox"
		then
			if child.ZIndex > highestZ then
				highestZ = child.ZIndex
			end
		end
	end
	newPart.ZIndex = highestZ + 1

	selectedElements = { newPart }
	refreshHighlights()
	updatePanel()
	saveState()
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
		if
			element:IsA("GuiObject")
			and not element.Name:match("Highlight")
			and element.Name ~= "ClickCatcher"
			and element.Name ~= "MarqueeBox"
		then
			local clone = element:Clone()
			clone.Parent = exportGui
		end
	end
end)

-- 初期化
updatePanel()
saveState()

toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
