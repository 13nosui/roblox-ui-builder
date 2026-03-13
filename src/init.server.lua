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

local addFrameBtn = Instance.new("TextButton")
addFrameBtn.Size = UDim2.new(0, 120, 0, 30)
addFrameBtn.Position = UDim2.new(0, 10, 0, 5)
addFrameBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
addFrameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addFrameBtn.Text = "＋ 四角形を追加"
addFrameBtn.Font = Enum.Font.BuilderSansBold
addFrameBtn.TextSize = 14
addFrameBtn.Parent = topBar

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = addFrameBtn

local canvasArea = Instance.new("Frame")
canvasArea.Size = UDim2.new(1, 0, 1, -40)
canvasArea.Position = UDim2.new(0, 0, 0, 40)
canvasArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
canvasArea.BorderSizePixel = 0
canvasArea.ClipsDescendants = true
canvasArea.Parent = background

-- ★ 差し替えるドラッグ機能（プラグイン環境対応版）
local function makeDraggable(guiObject)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		-- UDim2.new(X_Scale, X_Offset, Y_Scale, Y_Offset)
		guiObject.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	-- クリックされた瞬間
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			-- クリックが離された時（マウスが四角形の外に出ても検知できるように input を監視）
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	-- マウスが動いた瞬間（四角形の上で）
	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	-- ★★ UserInputService の代わりに guiObject の親（Canvas）の InputChanged を使う ★★
	-- プラグインの Widget 内では、親要素でマウス移動を監視するのが最も確実です
	guiObject.Parent.InputChanged:Connect(function(input)
		-- ドラッグ中で、かつマウス移動イベントだった場合のみ位置を更新
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

-- 4. ボタンを押した時の処理（四角形をキャンバスに生成）
addFrameBtn.MouseButton1Click:Connect(function()
	local newPart = Instance.new("Frame")
	newPart.Size = UDim2.new(0, 100, 0, 100)
	newPart.Position = UDim2.new(0, 50, 0, 50)
	newPart.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	newPart.Active = true -- ★ クリック判定を受け付けるために必要

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 100, 100)
	stroke.Parent = newPart

	newPart.Parent = canvasArea

	-- ★ 生成した四角形にドラッグ機能を付与
	makeDraggable(newPart)
end)

-- 5. プラグインボタンの表示/非表示の切り替え
toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)
