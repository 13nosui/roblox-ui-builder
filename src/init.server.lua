-- src/init.server.lua

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

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

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.Parent = topBar

-- ツールバーボタンを生成する関数
local function createToolButton(text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 30) -- 少し幅を調整して4つ入るようにしました
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

-- ★ ツール追加ボタン ＋ 新しい「エクスポート」ボタンを作成
local btnFrame = createToolButton("＋ 四角形", Color3.fromRGB(0, 120, 215))
local btnText = createToolButton("＋ 文字", Color3.fromRGB(46, 204, 113))
local btnButton = createToolButton("＋ ボタン", Color3.fromRGB(155, 89, 182))
local btnExport = createToolButton("📤 出力する", Color3.fromRGB(230, 126, 34)) -- オレンジ色

local canvasArea = Instance.new("Frame")
canvasArea.Size = UDim2.new(1, 0, 1, -40)
canvasArea.Position = UDim2.new(0, 0, 0, 40)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true
canvasArea.Parent = background

-- スケール（Scale）対応のドラッグ関数
local function makeDraggable(guiObject)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local parentSize = guiObject.Parent.AbsoluteSize
		if parentSize.X == 0 or parentSize.Y == 0 then
			return
		end

		local deltaScaleX = delta.X / parentSize.X
		local deltaScaleY = delta.Y / parentSize.Y

		guiObject.Position = UDim2.new(startPos.X.Scale + deltaScaleX, 0, startPos.Y.Scale + deltaScaleY, 0)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function(state)
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

-- キャンバスにUI要素を生成する共通関数
local function addElementToCanvas(className)
	local newPart = Instance.new(className)
	local canvasSize = canvasArea.AbsoluteSize
	local widthScale = canvasSize.X > 0 and 100 / canvasSize.X or 0.2
	local heightScale = canvasSize.Y > 0 and 100 / canvasSize.Y or 0.2

	newPart.Size = UDim2.new(widthScale, 0, heightScale, 0)
	newPart.Position = UDim2.new(0.1, 0, 0.1, 0)
	newPart.Active = true

	if className == "Frame" then
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	elseif className == "TextLabel" then
		newPart.Text = "テキスト"
		newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		newPart.BackgroundTransparency = 0.5
		newPart.Font = Enum.Font.BuilderSansBold
		newPart.TextScaled = true
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

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Parent = newPart

	newPart.Parent = canvasArea
	makeDraggable(newPart)
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

-- ★ 新機能：エクスポート処理
btnExport.MouseButton1Click:Connect(function()
	local starterGui = game:GetService("StarterGui")

	-- 「UIBuilderExport」というフォルダ（ScreenGui）が既に有れば中身を消す（上書き用）
	-- 無ければ新しく作成する
	local exportGui = starterGui:FindFirstChild("UIBuilderExport")
	if not exportGui then
		exportGui = Instance.new("ScreenGui")
		exportGui.Name = "UIBuilderExport"
		exportGui.Parent = starterGui
	else
		exportGui:ClearAllChildren()
	end

	-- キャンバスの中にあるパーツをすべて探して複製（Clone）する
	for _, element in ipairs(canvasArea:GetChildren()) do
		if element:IsA("GuiObject") then
			local clone = element:Clone()
			-- ドラッグ用のイベントはスクリプトで動的に付けていたので、
			-- Cloneされた側には引き継がれません（ゲームプレイ中に勝手に動かないので安全です！）
			clone.Parent = exportGui
		end
	end

	-- ボタンのテキストを一瞬変えて「成功した感」を演出する
	local originalText = btnExport.Text
	btnExport.Text = "✅ 完了！"
	btnExport.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- 緑色に光らせる

	task.delay(1.5, function()
		btnExport.Text = originalText
		btnExport.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- 元のオレンジ色に戻す
	end)
end)

-- プラグインボタンの表示/非表示の切り替え
toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
