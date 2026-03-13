-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local toolbar = plugin:CreateToolbar("UI Builder")
local toggleButton = toolbar:CreateButton("Open Editor", "UI Builderを開く", "rbxassetid://4483345998")

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 800, 500, 600, 300)
local widget = plugin:CreateDockWidgetPluginGui("UIBuilderCanvas", widgetInfo)
widget.Title = "UI Builder - Canvas"

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.Parent = widget

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
topBar.BorderSizePixel = 0
topBar.Parent = background

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 10)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = topBar

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.Parent = topBar

local function createToolButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 30)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = text
	btn.Font = Enum.Font.BuilderSansBold
	btn.TextSize = 14
	btn.Parent = topBar
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = btn
	return btn
end

local btnFrame = createToolButton("＋ 四角形", Color3.fromRGB(0, 120, 215))
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113))
local btnButton = createToolButton("＋ ボタン", Color3.fromRGB(155, 89, 182))
local btnExport = createToolButton("📤 出力する", Color3.fromRGB(230, 126, 34))

local mainArea = Instance.new("Frame")
mainArea.Size = UDim2.new(1, 0, 1, -40)
mainArea.Position = UDim2.new(0, 0, 0, 40)
mainArea.BackgroundTransparency = 1
mainArea.Parent = background

-- ★ キャンバスエリア
local canvasArea = Instance.new("Frame")
canvasArea.Size = UDim2.new(1, -200, 1, 0)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true
canvasArea.Parent = mainArea

local propertyPanel = Instance.new("Frame")
propertyPanel.Size = UDim2.new(0, 200, 1, 0)
propertyPanel.Position = UDim2.new(1, -200, 0, 0)
propertyPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
propertyPanel.BorderSizePixel = 1
propertyPanel.BorderColor3 = Color3.fromRGB(50, 50, 50)
propertyPanel.Parent = mainArea

local propLayout = Instance.new("UIListLayout")
propLayout.Padding = UDim.new(0, 10)
propLayout.Parent = propertyPanel

local propPadding = Instance.new("UIPadding")
propPadding.PaddingTop = UDim.new(0, 10)
propPadding.PaddingLeft = UDim.new(0, 10)
propPadding.PaddingRight = UDim.new(0, 10)
propPadding.Parent = propertyPanel

local propTitle = Instance.new("TextLabel")
propTitle.Size = UDim2.new(1, 0, 0, 20)
propTitle.BackgroundTransparency = 1
propTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
propTitle.Text = "選択中の要素がありません"
propTitle.Font = Enum.Font.BuilderSansBold
propTitle.TextXAlignment = Enum.TextXAlignment.Left
propTitle.Parent = propertyPanel

-- プロパティ編集UI
local textEditLabel = Instance.new("TextLabel")
textEditLabel.Size = UDim2.new(1, 0, 0, 20)
textEditLabel.BackgroundTransparency = 1
textEditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
textEditLabel.Text = "テキスト内容"
textEditLabel.Visible = false
textEditLabel.Parent = propertyPanel

local textEditBox = Instance.new("TextBox")
textEditBox.Size = UDim2.new(1, 0, 0, 30)
textEditBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
textEditBox.TextColor3 = Color3.fromRGB(255, 255, 255)
textEditBox.Visible = false
textEditBox.Parent = propertyPanel
Instance.new("UICorner", textEditBox).CornerRadius = UDim.new(0, 4)

local cornerEditLabel = Instance.new("TextLabel")
cornerEditLabel.Size = UDim2.new(1, 0, 0, 20)
cornerEditLabel.BackgroundTransparency = 1
cornerEditLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
cornerEditLabel.Text = "角丸 (px)"
cornerEditLabel.Visible = false
cornerEditLabel.Parent = propertyPanel

local cornerEditBox = Instance.new("TextBox")
cornerEditBox.Size = UDim2.new(1, 0, 0, 30)
cornerEditBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
cornerEditBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cornerEditBox.Visible = false
cornerEditBox.Parent = propertyPanel
Instance.new("UICorner", cornerEditBox).CornerRadius = UDim.new(0, 4)

local selectedElement = nil
local selectionHighlight = Instance.new("UIStroke")
selectionHighlight.Color = Color3.fromRGB(0, 162, 255)
selectionHighlight.Thickness = 3
selectionHighlight.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local function selectElement(element)
	selectedElement = element
	selectionHighlight.Parent = element
	propTitle.Text = "選択中: " .. element.ClassName

	if element:IsA("TextLabel") or element:IsA("TextButton") then
		textEditLabel.Visible = true
		textEditBox.Visible = true
		textEditBox.Text = element.Text
	else
		textEditLabel.Visible = false
		textEditBox.Visible = false
	end

	cornerEditLabel.Visible = true
	cornerEditBox.Visible = true
	local corner = element:FindFirstChildOfClass("UICorner")
	cornerEditBox.Text = corner and tostring(corner.CornerRadius.Offset) or "0"
end

textEditBox.FocusLost:Connect(function()
	if selectedElement and (selectedElement:IsA("TextLabel") or selectedElement:IsA("TextButton")) then
		selectedElement.Text = textEditBox.Text
	end
end)

cornerEditBox.FocusLost:Connect(function()
	if selectedElement then
		local num = tonumber(cornerEditBox.Text)
		if num then
			local corner = selectedElement:FindFirstChildOfClass("UICorner")
				or Instance.new("UICorner", selectedElement)
			corner.CornerRadius = UDim.new(0, num)
		end
	end
end)

-- ★ 貫通バグを防ぐためのフラグ
local isSelecting = false

canvasArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isSelecting then
			return
		end -- 要素を選択中なら何もしない
		selectedElement = nil
		selectionHighlight.Parent = nil
		propTitle.Text = "選択中の要素がありません"
		textEditLabel.Visible = false
		textEditBox.Visible = false
		cornerEditLabel.Visible = false
		cornerEditBox.Visible = false
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
				end
			end)
		end
	end)

	-- ★ widget.InputChangedを回避し、canvasAreaで安全にマウスを追いかける
	canvasArea.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local parentSize = canvasArea.AbsoluteSize
			if parentSize.X > 0 and parentSize.Y > 0 then
				guiObject.Position = UDim2.new(
					startPos.X.Scale + (delta.X / parentSize.X),
					0,
					startPos.Y.Scale + (delta.Y / parentSize.Y),
					0
				)
			end
		end
	end)
end

local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	-- ★ これらが無いとFrameやTextLabelはクリックに反応しない
	newPart.Active = true
	newPart.Selectable = true

	newPart.Size = UDim2.new(0.2, 0, 0.2, 0)
	newPart.Position = UDim2.new(0.1, 0, 0.1, 0)

	if className == "Frame" then
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	elseif className == "TextLabel" or className == "TextButton" then
		newPart.Text = className == "TextLabel" and "テキスト" or "ボタン"
		newPart.BackgroundColor3 = className == "TextLabel" and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(46, 204, 113)
		newPart.Font = Enum.Font.BuilderSansBold
		newPart.TextScaled = true
		if className == "TextButton" then
			Instance.new("UICorner", newPart).CornerRadius = UDim.new(0, 8)
		end
	end

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Parent = newPart

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
	local starterGui = game:GetService("StarterGui")
	local exportGui = starterGui:FindFirstChild("UIBuilderExport") or Instance.new("ScreenGui", starterGui)
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
