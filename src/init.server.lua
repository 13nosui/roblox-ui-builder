-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")

-- 1. プラグインタブの設定
local toolbar = plugin:CreateToolbar("UI Builder")
local toggleButton = toolbar:CreateButton("Open Editor", "UI Builderを開く", "rbxassetid://4483345998")

-- 2. ウィンドウ（DockWidget）の設定
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 600, 400, 300, 200)
local widget = plugin:CreateDockWidgetPluginGui("UIBuilderCanvas", widgetInfo)
widget.Title = "UI Builder - Canvas"

-- 3. ウィンドウ内のレイアウト構築
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
background.Parent = widget

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
topBar.BorderSizePixel = 0
topBar.Parent = background

-- ツールバーのボタンを横並びにする設定
local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 10)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.Parent = topBar

-- ツールバーの左側に少し余白を作る
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.Parent = topBar

-- ツールバーボタンを生成する便利関数
local function createToolButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 100, 0, 30)
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

-- 3つのツール追加ボタンを作成（色分けして見やすくします）
local btnFrame = createToolButton("＋ 四角形", Color3.fromRGB(0, 120, 215))
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113))
local btnButton = createToolButton("＋ ボタン", Color3.fromRGB(155, 89, 182))

local canvasArea = Instance.new("Frame")
canvasArea.Size = UDim2.new(1, 0, 1, -40)
canvasArea.Position = UDim2.new(0, 0, 0, 40)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true
canvasArea.Parent = background

-- ★ C: スケール（Scale）対応のドラッグ関数
local function makeDraggable(guiObject)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local parentSize = guiObject.Parent.AbsoluteSize

		-- エラー防止（キャンバスサイズが0の時は計算しない）
		if parentSize.X == 0 or parentSize.Y == 0 then
			return
		end

		-- ★★ 魔法の計算式：移動量（ピクセル）をキャンバスの割合（Scale）に変換 ★★
		local deltaScaleX = delta.X / parentSize.X
		local deltaScaleY = delta.Y / parentSize.Y

		-- 既存のScale位置に、移動分のScaleを足して更新（Offsetは使わない）
		guiObject.Position = UDim2.new(startPos.X.Scale + deltaScaleX, 0, startPos.Y.Scale + deltaScaleY, 0)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	guiObject.Parent.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

-- ★ B&C: キャンバスにUI要素を生成する共通関数（種類とスケール対応）
local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	local canvasSize = canvasArea.AbsoluteSize

	-- 生成時のサイズもScale（割合）で設定する（初期値は100px相当の割合）
	local widthScale = canvasSize.X > 0 and 100 / canvasSize.X or 0.2
	local heightScale = canvasSize.Y > 0 and 100 / canvasSize.Y or 0.2

	newPart.Size = UDim2.new(widthScale, 0, heightScale, 0)
	-- キャンバスの左上付近（10%の位置）にScaleで出現させる
	newPart.Position = UDim2.new(0.1, 0, 0.1, 0)
	newPart.Active = true

	-- パーツの種類に応じた初期デザイン
	if className == "Frame" then
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	elseif className == "TextLabel" then
		newPart.Text = "テキスト"
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		newPart.BackgroundTransparency = 0.5 -- 背景を少し透過
		newPart.Font = Enum.Font.BuilderSansBold
		newPart.TextScaled = true -- 枠のサイズに合わせて文字の大きさを自動調整
	elseif className == "TextButton" then
		newPart.Text = "ボタン"
		newPart.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		newPart.TextColor3 = Color3.fromRGB(255, 255, 255)
		newPart.Font = Enum.Font.BuilderSansBold
		newPart.TextScaled = true
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = newPart
	end

	-- 選択しやすくするための枠線
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Parent = newPart

	newPart.Parent = canvasArea
	makeDraggable(newPart)
end

-- 各ボタンを押した時に、対応する要素をキャンバスに追加
btnFrame.MouseButton1Click:Connect(function()
	addElementToCanvas("Frame")
end)
btnText.MouseButton1Click:Connect(function()
	addElementToCanvas("TextLabel")
end)
btnButton.MouseButton1Click:Connect(function()
	addElementToCanvas("TextButton")
end)

-- プラグインボタンの表示/非表示の切り替え
toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
