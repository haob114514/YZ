local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local guiService = game:GetService("GuiService")
local httpService = game:GetService("HttpService")

local function getDistance(p1, p2)
  if not p1.OnScreen or p1.Depth <= 0 then
    return nil
  end

  if p1.Pixels > p2.FOV or p1.Distance > p2.MaxDistance then
    return nil
  end

  if p2.WallCheck and not p1.Visible then
    return nil
  end

  return p2.Priority == "Distance" and p1.Distance or p1.Pixels
end

local function f1(team, neutral, team2, neutral2)
  return team ~= nil and team == team2 and not neutral and not neutral2
end

local function f2(smooth, p3)
  if smooth <= 0 then
    return 1
  end

  return 1 - math.exp(-math.max(p3, 0) * 60 / smooth)
end

if game.GameId ~= 10769552054 then
  warn("【YZ HUB】此脚本仅适用于 Urban Reload。")
  return
end

local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v1 = getgenv and getgenv() or _G

if v1.UrbanReloadHub then
  v1.UrbanReloadHub:Stop()
end

local WindUI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- HSV 转 RGB，用于彩虹配色
local function hsvToRgb(h, s, v)
  local i = math.floor(h / 60) % 6
  local f = (h / 60) - math.floor(h / 60)
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)

  if i == 0 then
    return Color3.new(v, t, p)
  elseif i == 1 then
    return Color3.new(q, v, p)
  elseif i == 2 then
    return Color3.new(p, v, t)
  elseif i == 3 then
    return Color3.new(p, q, v)
  elseif i == 4 then
    return Color3.new(t, p, v)
  end

  return Color3.new(v, p, q)
end

local function rainbowColor(offset, saturation, value)
  saturation = saturation or 1
  value = value or 1
  local hue = (os.clock() * 60 + (offset or 0)) % 360

  return hsvToRgb(hue, saturation, value)
end

local function rainbowSequence(offset, saturation, value, count)
  count = count or 6
  saturation = saturation or 1
  value = value or 1

  local keypoints = {}

  for i = 0, count - 1 do
    local hue = ((offset or 0) + (i / count) * 360) % 360
    local t = count > 1 and (i / (count - 1)) or 0

    keypoints[i + 1] = ColorSequenceKeypoint.new(t, hsvToRgb(hue, saturation, value))
  end

  return ColorSequence.new(keypoints)
end

local urbanReloadWindow = WindUI:CreateWindow({
  Title = "YZ HUB",
  Author = "Urban",
  Icon = "crosshair",
  Folder = "UrbanReloadCN",
  Size = UDim2.fromOffset(620, 460),
  Transparent = true,
  Theme = "Dark",
  SideBarWidth = 170,
  HideSearchBar = false,
  ScrollBarEnabled = true,
  ToggleKey = Enum.KeyCode.RightShift,
  OpenButton = {
    Title = "YZ HUB",
    Icon = "crosshair",
    CornerRadius = UDim.new(0, 8),
    StrokeThickness = 2,
    Enabled = true,
    Draggable = true,
    Scale = 0.85,
    Color = rainbowSequence(0, 1, 1, 6),
  },
})


if type(urbanReloadWindow) ~= "table" then
  warn("初始化失败，脚本已停止。")
  return
end

urbanReloadWindow:Tag({
  Title = "Urban Reload",
  Color = rainbowColor(0),
  Border = true,
})

WindUI:Notify({
  Title = "YZ HUB",
  Content = "菜单已加载，按 RightShift 显示或隐藏。",
  Icon = "check",
  Duration = 4,
})

-- 标题彩虹渐变
task.spawn(function()
  local main

  for _ = 1, 200 do
    main = urbanReloadWindow.UIElements and urbanReloadWindow.UIElements.Main

    if main then
      break
    end

    task.wait(0.1)
  end

  if not main then
    return
  end

  local titleLabel

  for _, desc in ipairs(main:GetDescendants()) do
    if desc:IsA("TextLabel") and desc.Text == "YZ HUB" then
      titleLabel = desc
      break
    end
  end

  if not titleLabel then
    return
  end

  while titleLabel.Parent do
    titleLabel.TextColor3 = rainbowColor(0, 0.75, 1)
    task.wait(0.05)
  end
end)

local options = {
  Aim = false,
  ESP = false,
  TeamCheck = true,
  WallCheck = true,
  FOV = 150,
  ShowFOV = true,
  Smooth = 0,
  HardLock = true,
  AimPart = "Head",
  MaxDistance = 1000,
  ESPDistance = 2000,
  ThroughWalls = true,
  Names = true,
  Health = true,
  Distance = true,
  Activation = "Hold RMB",
  Speed = false,
  RunSpeed = 28,
  Jump = false,
  JumpPower = 75,
  Fly = false,
  FlySpeed = 45,
  Noclip = false,
  Box = true,
  Skeleton = true,
  Outline = true,
  ZombieESP = false,
  AimPlayers = true,
  AimZombies = false,
  AutoLoot = false,
}

local silentOptions = {
  Enabled = false,
  CombineWithAim = false,
  Activation = "M1",
  AimPart = "Head",
  Priority = "Crosshair",
  FOV = 80,
  ShowFOV = true,
  Rainbow = false,
  WallCheck = true,
  TeamCheck = true,
  DistanceCheck = true,
  MaxDistance = 500,
  HealthCheck = false,
  MaxHealth = 100,
  TargetPlayers = true,
  TargetNPCs = false,
  Power = 1,
}

local urbanReloadHub = { Options = options, Window = urbanReloadWindow }
local list = {}
local map = {}
local flag = true
local flag2 = true
local v2, v3
local v4

local function f3()
  if v2 then
    v2[v3] = v4
  end

  v2 = nil
  v3 = nil
  v4 = nil
end

local urbanReloadFlight
local urbanReloadFlightAttachment

local function f4()
  if urbanReloadFlight then
    urbanReloadFlight:Destroy()
  end

  if urbanReloadFlightAttachment then
    urbanReloadFlightAttachment:Destroy()
  end

  urbanReloadFlight = nil
  urbanReloadFlightAttachment = nil
end

local map2 = {}

local function f5()
  for key, value in pairs(map2) do
    if key.Parent then
      key.CanCollide = value
    end
  end

  table.clear(map2)
end

local v5
local walkSpeed

local function f6()
  if v5 and walkSpeed then
    v5.WalkSpeed = walkSpeed
  end

  v5 = nil
  walkSpeed = nil
end

local v6 = "UrbanReloadAim_" .. httpService:GenerateGUID(false)

local urbanReloadESP = Instance.new("Folder")
urbanReloadESP.Name = "UrbanReloadESP"
urbanReloadESP.Parent = workspace

local urbanReloadOverlay = Instance.new("ScreenGui")
urbanReloadOverlay.Name = "UrbanReloadOverlay"
urbanReloadOverlay.IgnoreGuiInset = true
urbanReloadOverlay.ResetOnSpawn = false
urbanReloadOverlay.DisplayOrder = 20
urbanReloadOverlay.Parent = playerGui

local function makeFrame(name, color)
  local frame = Instance.new("Frame")
  frame.Name = name
  frame.BackgroundTransparency = 1
  frame.AnchorPoint = Vector2.new(0.5, 0.5)
  frame.Visible = false
  frame.Parent = urbanReloadOverlay

  local uiCorner = Instance.new("UICorner")
  uiCorner.CornerRadius = UDim.new(1, 0)
  uiCorner.Parent = frame

  local uiStroke = Instance.new("UIStroke")
  uiStroke.Color = color
  uiStroke.Transparency = 0.25
  uiStroke.Thickness = 1
  uiStroke.Parent = frame

  return frame, uiStroke
end

local frame2 = makeFrame("AimFOV", Color3.fromRGB(142, 232, 96))
local color2 = Color3.fromRGB(255, 120, 104)
local frame3, uiStroke2 = makeFrame("SilentFOV", color2)
local f7

local function f8()
  for key2 in pairs(map) do
    f7(key2)
  end
end

function f7(key3)
  local v7 = map[key3]

  if not v7 then
    return
  end

  v7.Highlight:Destroy()
  v7.Billboard:Destroy()
  v7.Drawing:Destroy()

  map[key3] = nil
end

local function f9()
  if not flag then
    return
  end

  flag = false
  flag2 = false
  urbanReloadHub.LockedTarget = nil
  f6()
  f3()
  f4()
  f5()

  if v1.UrbanReloadShotBridge then
    v1.UrbanReloadShotBridge.Redirect = nil
  end

  runService:UnbindFromRenderStep(v6)

  for _, value2 in ipairs(list) do
    value2:Disconnect()
  end

  table.clear(list)
  f8()
  urbanReloadESP:Destroy()
  urbanReloadOverlay:Destroy()

  if v1.UrbanReloadHub == urbanReloadHub then
    v1.UrbanReloadHub = nil
  end
end

local windUIDestroy = urbanReloadWindow.Destroy

function urbanReloadWindow:Destroy()
  f9()

  if windUIDestroy then
    pcall(windUIDestroy, self)
  end
end

function urbanReloadHub:Stop()
  urbanReloadWindow:Destroy()
end

v1.UrbanReloadHub = urbanReloadHub

local insert = table.insert

-- 菜单被销毁时自动清理全部功能
task.spawn(function()
  local main

  for _ = 1, 200 do
    main = urbanReloadWindow.UIElements and urbanReloadWindow.UIElements.Main

    if main then
      break
    end

    task.wait(0.1)
  end

  if main then
    insert(list, main.Destroying:Connect(f9))
  end
end)

local function f10(position, p4, p5, humanoid, raycastParams, p6)
  local function getIsDescendantOf(instance)
    return instance:IsDescendantOf(p5) or p6 and instance:IsDescendantOf(p6)
  end

  local raycast = workspace:Raycast(position, p4, raycastParams)

  if not raycast or getIsDescendantOf(raycast.Instance) then
    return true
  end

  local cars = workspace:FindFirstChild("Cars")
  local v8 = not cars
  local seatPart = humanoid.SeatPart

  if v8 or not seatPart or not seatPart:IsDescendantOf(cars) then
    return false
  end

  while seatPart.Parent ~= cars do
    seatPart = seatPart.Parent
  end

  if not seatPart:IsA("Model") or not raycast.Instance:IsDescendantOf(seatPart) then
    return false
  end

  local copy = table.clone(raycastParams.FilterDescendantsInstances)
  table.insert(copy, seatPart)

  local raycastParams2 = RaycastParams.new()
  raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
  raycastParams2.FilterDescendantsInstances = copy

  local raycast2 = workspace:Raycast(position, p4, raycastParams2)
  return not raycast2 or getIsDescendantOf(raycast2.Instance)
end

-- 窗口销毁监听已在上方注册（main.Destroying -> f9）
local f11

local function f12(p7)
  return f11(p7.Character)
end

function f11(instance2)
  if not instance2 or not instance2.Parent then
    return nil
  end

  local humanoid2 = instance2:FindFirstChildOfClass("Humanoid")
  local v9 = not humanoid2
  local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

  if v9 or humanoid2.Health <= 0 or not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
    return nil
  end

  return instance2, humanoid2, humanoidRootPart
end

local function f13()
  local _, v10 = f12(localPlayer)

  if not options.Speed or v10 ~= v5 then
    f6()
  end

  if not options.Speed or not v10 then
    return
  end

  if not v5 then
    local walkSpeed2 = v10.WalkSpeed
    v5 = v10
    walkSpeed = walkSpeed2
  end

  v10.WalkSpeed = options.RunSpeed
end

local v11

local function f14(p8)
  if replicatedStorage:GetAttribute("HalloweenEvent") == true then
    if not v11 then
      local farmZone = replicatedStorage:FindFirstChild("FarmZone")

      if farmZone then
        local ok, v12 = pcall(require, farmZone)

        if ok and type(v12) == "table" and type(v12.Contains) == "function" then
          v11 = v12
        end
      end
    end

    if v11 and v11.Contains(p8.Position) then
      return "僵尸"
    end
  end

  return "兜帽 NPC"
end

local function f15(lockedTarget, hoodLocal)
  if not lockedTarget or lockedTarget.Parent ~= hoodLocal or not lockedTarget:IsA("Model") then
    return
  end

  if lockedTarget:GetAttribute("Lootable") or lockedTarget:GetAttribute("HoodDowned") then
    return
  end

  local v13, v14, v15 = f11(lockedTarget)

  if v15 and v15.Position.Y > -4900 then
    return v13, v14, v15
  end
end

local function f16(lockedTarget2)
  return lockedTarget2 ~= localPlayer
    and not (options.TeamCheck
      and f1(localPlayer.Team, localPlayer.Neutral, lockedTarget2.Team, lockedTarget2.Neutral))
end

local function makeAttachment()
  f13()

  if not (options.Jump or options.Fly or options.Noclip or v2 or urbanReloadFlight or next(map2)) then
    return
  end

  local instance3, v16, v17 = f12(localPlayer)

  if instance3 and (v16.SeatPart or instance3:GetAttribute("Downed")) then
    instance3 = nil
    v17 = nil
    v16 = nil
  end

  local useJumpPower = v16
  useJumpPower = v16 and (v16.UseJumpPower and "JumpPower" or "JumpHeight")

  if not options.Jump or v16 ~= v2 or useJumpPower ~= v3 then
    f3()
  end

  if options.Jump and v16 then
    if not v2 then
      local v18 = v16[useJumpPower]
      v2 = v16
      v3 = useJumpPower
      v4 = v18
    end

    v16[useJumpPower] = useJumpPower == "JumpPower" and options.JumpPower
      or options.JumpPower ^ 2 / (2 * math.max(workspace.Gravity, 1))
  end

  for key4, value3 in pairs(map2) do
    if not options.Noclip or not instance3 or not key4:IsDescendantOf(instance3) then
      if key4.Parent then
        key4.CanCollide = value3
      end

      map2[key4] = nil
    end
  end

  if options.Noclip and instance3 then
    for _, value4 in ipairs(instance3:GetDescendants()) do
      if value4:IsA("BasePart") and value4.CanCollide then
        if map2[value4] == nil then
          map2[value4] = value4.CanCollide
        end

        value4.CanCollide = false
      end
    end
  end

  if urbanReloadFlight and (not options.Fly or not v17 or urbanReloadFlight.Parent ~= v17) then
    f4()
  end

  if not options.Fly or not v17 then
    return
  end

  if not urbanReloadFlight then
    urbanReloadFlightAttachment = Instance.new("Attachment")
    urbanReloadFlightAttachment.Name = "UrbanReloadFlightAttachment"
    urbanReloadFlightAttachment.Parent = v17

    urbanReloadFlight = Instance.new("LinearVelocity")
    urbanReloadFlight.Name = "UrbanReloadFlight"
    urbanReloadFlight.Attachment0 = urbanReloadFlightAttachment
    urbanReloadFlight.RelativeTo = Enum.ActuatorRelativeTo.World
    urbanReloadFlight.ForceLimitsEnabled = false
    urbanReloadFlight.Parent = v17
  end

  local currentCamera = workspace.CurrentCamera
  local zero = Vector3.zero

  if currentCamera and flag2 and not userInputService:GetFocusedTextBox()
    and not guiService.MenuIsOpen then
    local function f17(p9, p10)
      return (userInputService:IsKeyDown(p9) and 1 or 0)
        - (userInputService:IsKeyDown(p10) and 1 or 0)
    end

    zero = currentCamera.CFrame.LookVector * f17(Enum.KeyCode.W, Enum.KeyCode.S)
      + currentCamera.CFrame.RightVector * f17(Enum.KeyCode.D, Enum.KeyCode.A)
      + Vector3.yAxis * f17(Enum.KeyCode.Space, Enum.KeyCode.LeftControl)

    if zero.Magnitude > 1 then
      zero = zero.Unit
    end
  end

  urbanReloadFlight.VectorVelocity = zero * options.FlySpeed
end

local list2 = { "UpperTorso", "Torso", "LowerTorso", "HumanoidRootPart", "Head" }
local v19

local function getRay(p11, p12, p13)
  if not flag or not silentOptions.Enabled or not flag2 or guiService.MenuIsOpen
    or userInputService:GetFocusedTextBox() then
    return
  end

  if silentOptions.Activation == "Hold RMB"
    and not userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
    return
  end

  local instance4, v20, v21 = f12(localPlayer)

  if not instance4 or v20.SeatPart or instance4:GetAttribute("Downed") then
    return
  end

  local v22 = p11.ViewportSize / 2
  local raycastParams3

  if silentOptions.WallCheck then
    raycastParams3 = RaycastParams.new()
    raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams3.FilterDescendantsInstances = { instance4, p11, urbanReloadESP }

    local v23 = v19 and v19.folders[instance4]

    if v23 then
      raycastParams3:AddToFilter(v23)
    end
  end

  local maxDistance = silentOptions.DistanceCheck and silentOptions.MaxDistance or math.huge

  local v24 = {
    FOV = silentOptions.FOV,
    MaxDistance = maxDistance,
    WallCheck = silentOptions.WallCheck,
    Priority = silentOptions.Priority,
  }

  local isMouseButtonPressed = options.Activation == "Always"
    or userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

  local lockedCharacter = options.Aim and silentOptions.CombineWithAim and isMouseButtonPressed
    and urbanReloadHub.LockedCharacter

  local v25
  local v26

  local function f18(character)
    if not character or not character.Parent or character:FindFirstChildOfClass("ForceField") then
      return
    end

    local humanoid3 = character:FindFirstChildOfClass("Humanoid")

    if not humanoid3 or humanoid3.Health <= 0
      or silentOptions.HealthCheck and humanoid3.Health > silentOptions.MaxHealth then
      return
    end

    local upperTorso

    if silentOptions.AimPart == "Random" then
      local list3 = {}

      for _, value5 in ipairs({ "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart" }) do
        local findFirstChild = character:FindFirstChild(value5)

        if findFirstChild and findFirstChild:IsA("BasePart") then
          table.insert(list3, findFirstChild)
        end
      end

      if #list3 > 0 then
        upperTorso = list3[math.random(#list3)]
      end
    elseif silentOptions.AimPart == "Torso" then
      upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        or character:FindFirstChild("HumanoidRootPart")
    else
      upperTorso = character:FindFirstChild(silentOptions.AimPart)
        or character:FindFirstChild("HumanoidRootPart")
    end

    local v27 = character == lockedCharacter
    local instance5 = v19 and v19.folders[character]

    local function getUnit(instance6)
      if not instance6 or not instance6:IsA("BasePart") then
        return
      end

      local findFirstChild2 = instance5
      local position2 = instance6.Position

      if instance5 then
        findFirstChild2 = instance5:FindFirstChild(instance6.Name)
      end

      local instance7 = findFirstChild2

      if instance7 and instance7:IsA("BasePart") and instance7.CanQuery then
        local v28 = v19.parts[instance7]

        if v28 and v28.char == character and (instance7.Position - position2).Magnitude <= 4 then
          position2 = instance7.Position
        end
      end

      local screenPoint, onScreen = p11:WorldToViewportPoint(instance6.Position)
      local v29 = position2 - p12
      local magnitude = (Vector2.new(screenPoint.X, screenPoint.Y) - v22).Magnitude
      local magnitude2 = (v21.Position - instance6.Position).Magnitude

      if screenPoint.Z <= 0 or magnitude2 > maxDistance or v29.Magnitude < 0.001 then
        return
      end

      if not v27 and (not onScreen or magnitude > silentOptions.FOV) then
        return
      end

      local visible = not raycastParams3
        or f10(p12, v29, character, humanoid3, raycastParams3, instance5)

      if v27 then
        if visible then
          return v29.Unit, -1
        end

        return
      end

      local distance = getDistance({
        OnScreen = onScreen,
        Depth = screenPoint.Z,
        Pixels = magnitude,
        Distance = magnitude2,
        Visible = visible,
      }, v24)

      if distance then
        return v29.Unit, distance
      end
    end

    local unit, v30 = getUnit(upperTorso)

    if not unit and v27 then
      for _, value6 in ipairs(list2) do
        local findFirstChild3 = character:FindFirstChild(value6)

        if findFirstChild3 ~= upperTorso then
          unit, v30 = getUnit(findFirstChild3)

          if unit then
            break
          end
        end
      end
    end

    if v30 and (not v26 or v30 < v26) then
      v25 = unit
      v26 = v30
    end
  end

  if silentOptions.TargetPlayers then
    for _, value7 in ipairs(players:GetPlayers()) do
      if value7 ~= localPlayer
        and not (silentOptions.TeamCheck
          and f1(localPlayer.Team, localPlayer.Neutral, value7.Team, value7.Neutral)) then
        f18(value7.Character)
      end
    end
  end

  local hoodLocal2 = silentOptions.TargetNPCs and workspace:FindFirstChild("HoodLocal")

  if hoodLocal2 then
    for _, value8 in ipairs(hoodLocal2:GetChildren()) do
      local v31 = f15(value8, hoodLocal2)

      if v31 then
        f18(v31)
      end
    end
  end

  if not v25 or silentOptions.Power <= 0 then
    return
  end

  local v32 = p13.Unit * (1 - silentOptions.Power) + v25 * silentOptions.Power

  if v32.Magnitude > 0.001 then
    return Ray.new(p12, v32.Unit)
  end
end

local function f19(currentCamera2, key5, p14)
  local v33 = currentCamera2.ViewportSize / 2

  local raycastParams4 = RaycastParams.new()
  raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
  raycastParams4.FilterDescendantsInstances = { key5, currentCamera2, urbanReloadESP }

  local v34 = v19 and v19.folders[key5]

  if v34 then
    raycastParams4:AddToFilter(v34)
  end

  local function getFindFirstChild(key6, p15, p16, p17)
    if not key6 or key6:FindFirstChildOfClass("ForceField") then
      return
    end

    local findFirstChild4 = key6:FindFirstChild(options.AimPart) or p16
    local position3 = currentCamera2.CFrame.Position
    local v35 = v19 and v19.folders[key6]

    local function getMagnitude(findFirstChild5)
      if not findFirstChild5 or not findFirstChild5:IsA("BasePart") then
        return
      end

      if (p14.Position - findFirstChild5.Position).Magnitude > options.MaxDistance then
        return
      end

      local screenPoint2, onScreen2 = currentCamera2:WorldToViewportPoint(findFirstChild5.Position)
      local magnitude3 = (Vector2.new(screenPoint2.X, screenPoint2.Y) - v33).Magnitude

      if p17 and (not onScreen2 or screenPoint2.Z <= 0 or magnitude3 > options.FOV) then
        return
      end

      if not options.WallCheck
        or f10(position3, findFirstChild5.Position - position3, key6, p15, raycastParams4, v35) then
        return magnitude3
      end
    end

    local magnitude4 = getMagnitude(findFirstChild4)

    if magnitude4 then
      return findFirstChild4, magnitude4
    end

    if not p17 and silentOptions.Enabled and silentOptions.CombineWithAim then
      for _, value9 in ipairs(list2) do
        local findFirstChild6 = key6:FindFirstChild(value9)

        if findFirstChild6 ~= findFirstChild4 then
          local magnitude5 = getMagnitude(findFirstChild6)

          if magnitude5 then
            return findFirstChild6, magnitude5
          end
        end
      end
    end
  end

  local getPlayers = options.AimPlayers and players:GetPlayers() or {}
  local hoodLocal3 = options.AimZombies and workspace:FindFirstChild("HoodLocal")
  local lockedTarget3 = urbanReloadHub.LockedTarget

  if lockedTarget3 then
    local displayName, v36, v37
    local v38

    if table.find(getPlayers, lockedTarget3) and f16(lockedTarget3)
      and lockedTarget3.Character == urbanReloadHub.LockedCharacter then
      v38, v37, v36 = f12(lockedTarget3)
      displayName = lockedTarget3.DisplayName
    elseif hoodLocal3 and lockedTarget3 == urbanReloadHub.LockedCharacter then
      v38, v37, v36 = f15(lockedTarget3, hoodLocal3)

      if v36 then
        displayName = f14(v36)
      end
    end

    local findFirstChild7 = getFindFirstChild(v38, v37, v36, false)

    if findFirstChild7 then
      return findFirstChild7, displayName
    end
  end

  local v39, v40, lockedTarget4, v41, v42

  local function f20(lockedTarget5, displayName2, p18, p19, p20)
    local findFirstChild8, magnitude6 = getFindFirstChild(p18, p19, p20, true)

    if findFirstChild8 and (not v40 or magnitude6 < v40) then
      v39 = findFirstChild8
      v40 = magnitude6
      lockedTarget4 = lockedTarget5
      v41 = p18
      v42 = displayName2
    end
  end

  for _, value10 in ipairs(getPlayers) do
    if f16(value10) then
      f20(value10, value10.DisplayName, f12(value10))
    end
  end

  if hoodLocal3 then
    for _, value11 in ipairs(hoodLocal3:GetChildren()) do
      local v43, v44, v45 = f15(value11, hoodLocal3)

      if v43 then
        f20(value11, f14(v45), v43, v44, v45)
      end
    end
  end

  local lockedCharacter2 = v41

  urbanReloadHub.LockedTarget = lockedTarget4
  urbanReloadHub.LockedCharacter = lockedCharacter2

  return v39, v42
end

urbanReloadHub.SilentOptions = silentOptions
urbanReloadHub.RedirectShot = getRay

local function f21()
  local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
  local weaponClient = playerScripts and playerScripts:FindFirstChild("WeaponClient")

  if not weaponClient then
    return false, "武器模块仍在加载，请稍后重试"
  end

  if not v19 then
    local weapons = replicatedStorage:FindFirstChild("Weapons")
    local clientHitboxes = weapons and weapons:FindFirstChild("ClientHitboxes")

    if clientHitboxes then
      local ok2, v46 = pcall(require, clientHitboxes)

      if ok2 and type(v46) == "table" and type(v46.folders) == "table"
        and type(v46.parts) == "table" then
        v19 = v46
      end
    end
  end

  local urbanReloadShotBridge = v1.UrbanReloadShotBridge
  local v47

  if not urbanReloadShotBridge then
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function"
      or type(getcallingscript) ~= "function" then
      return false, "当前执行器不支持弹道重写钩子"
    end

    urbanReloadShotBridge = {}
    v47 = nil

    local ok3, v48 = pcall(hookmetamethod, game, "__namecall", function(p21, ...)
      local v49 = urbanReloadShotBridge
      local v50 = { ... }
      local redirect = v49.Redirect

      if redirect and p21 == workspace.CurrentCamera
        and getnamecallmethod() == "ViewportPointToRay"
        and getcallingscript() == urbanReloadShotBridge.Weapon then
        local v51 = v50[1]
        local v52 = v50[2]
        local viewportSize = p21.ViewportSize

        if select("#", unpack(v50)) == 2 and v51 == viewportSize.X * 0.5
          and v52 == viewportSize.Y * 0.5 then
          local v53 = v47(p21, unpack(v50))
          local ok4, result = pcall(redirect, p21, v53.Origin, v53.Direction)
          return ok4 and result or v53
        end
      end

      return v47(p21, unpack(v50))
    end)

    if not ok3 or type(v48) ~= "function" then
      return false, "无法挂载弹道重写钩子"
    end

    v47 = v48
    v1.UrbanReloadShotBridge = urbanReloadShotBridge
  end

  urbanReloadShotBridge.Weapon = weaponClient
  urbanReloadShotBridge.Redirect = getRay

  return true
end

local list4 = {
  { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" }, { "UpperTorso", "LeftUpperArm" },
  { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
  { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" },
  { "RightLowerArm", "RightHand" }, { "LowerTorso", "LeftUpperLeg" },
  { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
  { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" },
  { "RightLowerLeg", "RightFoot" }, { "Head", "Torso" }, { "Torso", "Left Arm" },
  { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}

local function makeFrame2(currentCamera3, p22, raycastParams5)
  local character2 = p22.Character
  local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
  p22.Drawing.Visible = false

  if not humanoidRootPart2 or not (options.Box or options.Skeleton or options.Health) then
    return
  end

  if raycastParams5 then
    local position4 = humanoidRootPart2.Position
    local position5 = currentCamera3.CFrame.Position

    local raycast3 = workspace:Raycast(
      currentCamera3.CFrame.Position, position4 - position5, raycastParams5
    )

    if raycast3 and not raycast3.Instance:IsDescendantOf(character2) then
      return
    end
  end

  local v54, v55 = character2:GetBoundingBox()
  local huge = math.huge
  local huge2 = math.huge
  local highest = -math.huge
  local lowest = huge2
  local highest2 = -math.huge
  local lowest2 = huge

  for i = -1, 1, 2 do
    for j = -1, 1, 2 do
      for k = -1, 1, 2 do
        local new = Vector3.new
        local x = v55.X
        local y = v55.Y

        local worldToViewportPoint = currentCamera3:WorldToViewportPoint((v54:PointToWorldSpace(new(
          i * x, j * y, k * v55.Z
        ) * 0.5)))

        if worldToViewportPoint.Z <= 0 then
          return
        end

        lowest2 = math.min(lowest2, worldToViewportPoint.X)
        lowest = math.min(lowest, worldToViewportPoint.Y)
        highest = math.max(highest, worldToViewportPoint.X)
        highest2 = math.max(highest2, worldToViewportPoint.Y)
      end
    end
  end

  local viewportSize2 = currentCamera3.ViewportSize

  if highest < 0 or highest2 < 0 or lowest2 > viewportSize2.X or lowest > viewportSize2.Y then
    return
  end

  local highest3 = math.max(1, highest2 - lowest)

  p22.Drawing.Visible = true
  p22.Box.Visible = options.Box
  p22.Box.Position = UDim2.fromOffset(lowest2, lowest)
  p22.Box.Size = UDim2.fromOffset(math.max(1, highest - lowest2), highest3)
  p22.HealthBar.Position = UDim2.fromOffset(lowest2 - 6, lowest)
  p22.HealthBar.Size = UDim2.fromOffset(3, highest3)

  for index, value12 in ipairs(list4) do
    local bone = p22.Bones[index]
    local skeleton = options.Skeleton

    local findFirstChild9 = skeleton
    findFirstChild9 = skeleton and character2:FindFirstChild(value12[1])

    local findFirstChild10 = findFirstChild9
    findFirstChild10 = findFirstChild9 and character2:FindFirstChild(value12[2])

    if findFirstChild9 and findFirstChild10 and findFirstChild9:IsA("BasePart")
      and findFirstChild10:IsA("BasePart") then
      local worldToViewportPoint2 = currentCamera3:WorldToViewportPoint(findFirstChild9.Position)
      local worldToViewportPoint3 = currentCamera3:WorldToViewportPoint(findFirstChild10.Position)
      local x2 = worldToViewportPoint3.X
      local x3 = worldToViewportPoint2.X
      local v56 = worldToViewportPoint3.Y - worldToViewportPoint2.Y
      local v57 = x2 - x3

      if not bone then
        bone = Instance.new("Frame")
        bone.Name = "Bone"
        bone.AnchorPoint = Vector2.new(0.5, 0.5)
        bone.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
        bone.BorderSizePixel = 0
        bone.Parent = p22.Drawing

        p22.Bones[index] = bone
      end

      bone.Visible = worldToViewportPoint2.Z > 0 and worldToViewportPoint3.Z > 0

      bone.Position = UDim2.fromOffset(
        worldToViewportPoint2.X + v57 * 0.5, worldToViewportPoint2.Y + v56 * 0.5
      )

      bone.Size = UDim2.fromOffset(math.sqrt(v57 * v57 + v56 * v56), 1)
      bone.Rotation = math.deg(math.atan2(v56, v57))
    elseif bone then
      bone.Visible = false
    end
  end
end

local f22

local function f23()
  if not (options.ESP or options.ZombieESP) then
    f8()
    return
  end

  local currentCamera4 = workspace.CurrentCamera

  if not currentCamera4 then
    f8()
    return
  end

  local _, _, v58 = f12(localPlayer)
  local position6 = v58 and v58.Position or currentCamera4.CFrame.Position
  local seen = {}

  local function f24(key7, p23, p24, instance8, p25, p26)
    if not instance8 then
      return
    end

    local magnitude7 = (p26.Position - position6).Magnitude

    if magnitude7 <= options.ESPDistance then
      seen[key7] = true
      local v59 = map[key7]

      if v59 and v59.Character ~= instance8 then
        f7(key7)
        v59 = nil
      end

      local v60 = v59 or f22(key7, instance8, p24)

      v60.Highlight.DepthMode = options.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded

      v60.Highlight.Enabled = options.Outline
      v60.Billboard.AlwaysOnTop = options.ThroughWalls
      v60.Billboard.Adornee = instance8:FindFirstChild("Head") or p26
      v60.Billboard.MaxDistance = options.ESPDistance

      local list5 = {}

      if options.Names then
        table.insert(list5, p23)
      end

      local clamped = p25.MaxHealth > 0 and math.clamp(p25.Health / p25.MaxHealth, 0, 1) or 0

      v60.HealthBar.Visible = options.Health
      v60.HealthFill.Size = UDim2.fromScale(1, clamped)

      v60.HealthFill.BackgroundColor3 = Color3.fromRGB(math.floor(255
        * math.min(1, (1 - clamped) * 2)), math.floor(230 * math.min(1, clamped * 2)), 60)

      if options.Distance then
        table.insert(list5, string.format("%d 格", math.floor(magnitude7)))
      end

      v60.Label.Text = table.concat(list5, "\n")
      v60.Billboard.Enabled = #list5 > 0
    end
  end

  if options.ESP then
    for _, value13 in ipairs(players:GetPlayers()) do
      if f16(value13) then
        f24(value13, value13.DisplayName .. " (@" .. value13.Name .. ")", false, f12(value13))
      end
    end
  end

  local zombieESP = options.ZombieESP

  local hoodLocal4 = zombieESP
  hoodLocal4 = zombieESP and workspace:FindFirstChild("HoodLocal")

  if hoodLocal4 then
    for _, value14 in ipairs(hoodLocal4:GetChildren()) do
      local v61, v62, v63 = f15(value14, hoodLocal4)

      if v61 then
        f24(value14, f14(v63), true, v61, v62, v63)
      end
    end
  end

  for key8 in pairs(map) do
    if not seen[key8] then
      f7(key8)
    end
  end
end

function f22(key9, p27, p28)
  local highlight = Instance.new("Highlight")
  highlight.Name = p28 and "NPC_" .. p27.Name or "Player_" .. key9.UserId
  highlight.Adornee = p27
  highlight.FillColor = Color3.fromRGB(142, 232, 96)
  highlight.OutlineColor = p28 and Color3.fromRGB(255, 157, 62) or Color3.fromRGB(100, 255, 70)
  highlight.FillTransparency = 1
  highlight.OutlineTransparency = 0
  highlight.Parent = urbanReloadESP

  local billboardGui = Instance.new("BillboardGui")
  billboardGui.Name = highlight.Name
  billboardGui.Size = UDim2.fromOffset(200, 30)
  billboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
  billboardGui.Parent = urbanReloadOverlay

  local textLabel = Instance.new("TextLabel")
  textLabel.Size = UDim2.fromScale(1, 1)
  textLabel.BackgroundTransparency = 1
  textLabel.TextColor3 = Color3.fromRGB(240, 255, 235)
  textLabel.TextStrokeTransparency = 0.2
  textLabel.TextSize = 11
  textLabel.Font = Enum.Font.GothamMedium
  textLabel.RichText = false
  textLabel.Parent = billboardGui

  local frame4 = Instance.new("Frame")
  frame4.Name = "ESP_" .. highlight.Name
  frame4.BackgroundTransparency = 1
  frame4.Size = UDim2.fromScale(1, 1)
  frame4.Visible = false
  frame4.Parent = urbanReloadOverlay

  local box = Instance.new("Frame")
  box.Name = "Box"
  box.BackgroundTransparency = 1
  box.Parent = frame4

  local uiStroke3 = Instance.new("UIStroke")
  uiStroke3.Color = Color3.fromRGB(242, 248, 241)
  uiStroke3.Thickness = 1
  uiStroke3.Parent = box

  local healthBar = Instance.new("Frame")
  healthBar.Name = "HealthBar"
  healthBar.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
  healthBar.BorderSizePixel = 0
  healthBar.ClipsDescendants = true
  healthBar.Parent = frame4

  local uiStroke4 = Instance.new("UIStroke")
  uiStroke4.Color = Color3.fromRGB(0, 0, 0)
  uiStroke4.Thickness = 1
  uiStroke4.Parent = healthBar

  local healthFill = Instance.new("Frame")
  healthFill.Name = "HealthFill"
  healthFill.AnchorPoint = Vector2.new(0, 1)
  healthFill.Position = UDim2.fromScale(0, 1)
  healthFill.BorderSizePixel = 0
  healthFill.Size = UDim2.fromScale(1, 1)
  healthFill.Parent = healthBar

  local v64 = {
    Character = p27,
    Highlight = highlight,
    Billboard = billboardGui,
    Label = textLabel,
    Drawing = frame4,
    Box = box,
    Bones = {},
    HealthBar = healthBar,
    HealthFill = healthFill,
  }

  map[key9] = v64
  return v64
end

local v65

local function f25()
  local instance9, v66 = f12(localPlayer)

  if not instance9 or v66.SeatPart or instance9:GetAttribute("Downed") then
    return
  end

  if not v65 then
    local weapons2 = replicatedStorage:FindFirstChild("Weapons")
    local clientState = weapons2 and weapons2:FindFirstChild("ClientState")

    if not clientState then
      return
    end

    local ok5, v67 = pcall(require, clientState)

    if not ok5 or type(v67) ~= "table" then
      return
    end

    v65 = v67
  end

  if type(v65.HoodLootNow) == "function" then
    v65.HoodLootNow()
  end
end

-- ======================================================================
-- 界面：WindUI 深色 + 彩虹风格，全中文
-- ======================================================================

local function rainbow(offset)
  return rainbowColor(offset, 0.85, 1)
end

-- 中文显示值 -> 脚本内部值
local activationMap = {
  ["按住右键"] = "Hold RMB",
  ["始终开启"] = "Always",
}

local shotActivationMap = {
  ["左键开火"] = "M1",
  ["按住右键"] = "Hold RMB",
}

local aimPartMap = {
  ["头部"] = "Head",
  ["躯干"] = "HumanoidRootPart",
}

local silentPartMap = {
  ["头部"] = "Head",
  ["躯干"] = "Torso",
  ["躯干根部"] = "HumanoidRootPart",
  ["随机"] = "Random",
}

local priorityMap = {
  ["准星优先"] = "Crosshair",
  ["距离优先"] = "Distance",
}

local HomeSection = urbanReloadWindow:Section({ Title = "主页" })
local CombatSection = urbanReloadWindow:Section({ Title = "战斗" })
local CharSection = urbanReloadWindow:Section({ Title = "角色" })

-- ==================== 公告 ====================
local announceTab = HomeSection:Tab({
  Title = "公告",
  Desc = "使用说明与玩家信息",
  Icon = "bell",
  IconColor = rainbow(0),
  IconShape = "Square",
  Border = true,
})

announceTab:Section({ Title = "脚本信息", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

announceTab:Paragraph({
  Title = "YZ HUB",
  Desc = "BY ：y\n"
    .. "版本：V1.0\n"
    .. "快捷键：RightShift 显示或隐藏菜单",
  ImageSize = 40,
})

announceTab:Section({ Title = "玩家信息", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

announceTab:Paragraph({
  Title = "用户名：" .. localPlayer.Name,
  Desc = "显示名称：" .. localPlayer.DisplayName .. "\n账号天数：" .. localPlayer.AccountAge .. " 天",
  ImageSize = 32,
})

announceTab:Section({ Title = "快捷操作", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

announceTab:Button({
  Title = "关闭菜单",
  Desc = "之后按 RightShift 可以重新打开",
  Icon = "panel-left-close",
  Justify = "Center",
  Color = rainbow(0),
  Callback = function()
    task.defer(function()
      pcall(function()
        urbanReloadWindow:Close()
      end)
    end)
  end,
})

-- ==================== 自瞄 ====================
local aimTab = CombatSection:Tab({
  Title = "自瞄",
  Desc = "鼠标锁定目标",
  Icon = "crosshair",
  IconColor = rainbow(0),
  IconShape = "Square",
  Border = true,
})

aimTab:Section({ Title = "使用方式", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

aimTab:Paragraph({
  Title = "操作说明",
  Desc = "按住鼠标右键锁定目标，松开右键清除锁定；再次按住会重新选择目标。",
})

aimTab:Section({ Title = "开关", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

aimTab:Toggle({
  Title = "启用自瞄",
  Desc = "按住鼠标右键时把镜头锁定到目标身上",
  Value = false,
  Callback = function(value)
    options.Aim = value
  end,
})

aimTab:Toggle({
  Title = "瞄准玩家",
  Desc = "把其他玩家作为自瞄目标",
  Value = true,
  Callback = function(value)
    options.AimPlayers = value
  end,
})

aimTab:Toggle({
  Title = "瞄准僵尸 / NPC",
  Desc = "把僵尸与兜帽 NPC 作为自瞄目标",
  Value = false,
  Callback = function(value)
    options.AimZombies = value
  end,
})

aimTab:Dropdown({
  Title = "触发方式",
  Desc = "按住右键：只有按住鼠标右键才自瞄；始终开启：启用自瞄后一直生效",
  Values = { "按住右键", "始终开启" },
  Value = 1,
  Callback = function(option)
    options.Activation = activationMap[option] or "Hold RMB"
  end,
})

local aimStatusElement = aimTab:Paragraph({
  Title = "自瞄状态",
  Desc = "自瞄：关闭",
})

local function f26(status)
  if urbanReloadHub.AimStatus ~= status then
    urbanReloadHub.AimStatus = status

    if aimStatusElement then
      pcall(function()
        aimStatusElement:SetDesc("自瞄：" .. status)
      end)
    end
  end
end

aimTab:Section({ Title = "参数", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

aimTab:Slider({
  Title = "自瞄范围（像素）",
  Desc = "目标必须出现在这个半径内才会被锁定",
  Value = { Min = 30, Max = 500, Default = 150 },
  Step = 5,
  Callback = function(value)
    options.FOV = value
  end,
})

aimTab:Dropdown({
  Title = "瞄准部位",
  Values = { "头部", "躯干" },
  Value = 1,
  Callback = function(option)
    options.AimPart = aimPartMap[option] or "Head"
  end,
})

aimTab:Slider({
  Title = "自瞄距离（格）",
  Value = { Min = 50, Max = 3000, Default = 1000 },
  Step = 50,
  Callback = function(value)
    options.MaxDistance = value
  end,
})

aimTab:Toggle({
  Title = "墙体检测",
  Desc = "只锁定能被看见的目标",
  Value = true,
  Callback = function(value)
    options.WallCheck = value
  end,
})

aimTab:Toggle({
  Title = "显示范围圈",
  Desc = "在屏幕中央显示自瞄范围",
  Value = true,
  Callback = function(value)
    options.ShowFOV = value
  end,
})

aimTab:Toggle({
  Title = "强制锁定",
  Desc = "每帧追踪当前目标，并且忽略平滑度",
  Value = true,
  Callback = function(value)
    options.HardLock = value
  end,
})

aimTab:Slider({
  Title = "平滑度",
  Desc = "仅在关闭强制锁定时生效，0 为瞬间吸附",
  Value = { Min = 0, Max = 30, Default = 0 },
  Step = 1,
  Callback = function(value)
    options.Smooth = value
  end,
})

-- ==================== 静默自瞄 ====================
local silentTab = CombatSection:Tab({
  Title = "静默自瞄",
  Desc = "开火自动修正弹道",
  Icon = "target",
  IconColor = rainbow(60),
  IconShape = "Square",
  Border = true,
})

silentTab:Section({ Title = "使用方式", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

silentTab:Paragraph({
  Title = "操作说明",
  Desc = "开启后子弹会自动飞向目标，准星不需要真的对准。勾选「与自瞄联动」可以让镜头同步跟随。",
})

silentTab:Section({ Title = "开关", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

local enableSilentToggle
local silentStatusElement

local function setSilentStatus(text)
  if silentStatusElement then
    pcall(function()
      silentStatusElement:SetDesc("静默自瞄：" .. text)
    end)
  end
end

local function f27(enable)
  if enable then
    local ok, err = f21()
    silentOptions.Enabled = ok
    setSilentStatus(ok and "就绪" or (err or "启动失败"))
    return ok, err
  end

  silentOptions.Enabled = false

  if v1.UrbanReloadShotBridge then
    v1.UrbanReloadShotBridge.Redirect = nil
  end

  setSilentStatus("关闭")
  return true
end

urbanReloadHub.SetSilentAim = f27

enableSilentToggle = silentTab:Toggle({
  Title = "启用静默自瞄",
  Desc = "开启后开火时自动把弹道修正到目标身上",
  Value = false,
  Callback = function(value)
    if not f27(value) and enableSilentToggle then
      pcall(function()
        enableSilentToggle:Set(false, true)
      end)
    end
  end,
})

silentTab:Toggle({
  Title = "与自瞄联动",
  Desc = "自瞄锁定的目标优先作为静默自瞄目标",
  Value = false,
  Callback = function(value)
    silentOptions.CombineWithAim = value
  end,
})

silentTab:Dropdown({
  Title = "开火触发",
  Desc = "左键开火：正常开枪时生效；按住右键：还需要按住鼠标右键",
  Values = { "左键开火", "按住右键" },
  Value = 1,
  Callback = function(option)
    silentOptions.Activation = shotActivationMap[option] or "M1"
  end,
})

silentStatusElement = silentTab:Paragraph({
  Title = "静默状态",
  Desc = "静默自瞄：关闭",
})

silentTab:Section({ Title = "目标选择", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

silentTab:Dropdown({
  Title = "命中部位",
  Values = { "头部", "躯干", "躯干根部", "随机" },
  Value = 1,
  Callback = function(option)
    silentOptions.AimPart = silentPartMap[option] or "Head"
  end,
})

silentTab:Dropdown({
  Title = "目标优先级",
  Desc = "准星优先：离准星最近的目标；距离优先：离你最近的目标",
  Values = { "准星优先", "距离优先" },
  Value = 1,
  Callback = function(option)
    silentOptions.Priority = priorityMap[option] or "Crosshair"
  end,
})

silentTab:Slider({
  Title = "静默范围（像素）",
  Value = { Min = 20, Max = 500, Default = 80 },
  Step = 5,
  Callback = function(value)
    silentOptions.FOV = value
  end,
})

silentTab:Slider({
  Title = "静默强度",
  Desc = "1 为完全吸附到目标，数值越小越接近原始弹道",
  Value = { Min = 0, Max = 1, Default = 1 },
  Step = 0.05,
  Callback = function(value)
    silentOptions.Power = value
  end,
})

silentTab:Section({ Title = "过滤条件", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

silentTab:Toggle({
  Title = "阵营检测",
  Desc = "跳过队友",
  Value = true,
  Callback = function(value)
    silentOptions.TeamCheck = value
  end,
})

silentTab:Toggle({
  Title = "可见性检测",
  Desc = "只锁定没有被墙挡住的目标",
  Value = true,
  Callback = function(value)
    silentOptions.WallCheck = value
  end,
})

silentTab:Toggle({
  Title = "距离检测",
  Value = true,
  Callback = function(value)
    silentOptions.DistanceCheck = value
  end,
})

silentTab:Slider({
  Title = "最大距离（格）",
  Value = { Min = 50, Max = 3000, Default = 500 },
  Step = 50,
  Callback = function(value)
    silentOptions.MaxDistance = value
  end,
})

silentTab:Toggle({
  Title = "血量检测",
  Desc = "跳过血量高于上限的目标",
  Value = false,
  Callback = function(value)
    silentOptions.HealthCheck = value
  end,
})

silentTab:Slider({
  Title = "目标最大血量",
  Value = { Min = 1, Max = 150, Default = 100 },
  Step = 1,
  Callback = function(value)
    silentOptions.MaxHealth = value
  end,
})

silentTab:Toggle({
  Title = "目标：玩家",
  Value = true,
  Callback = function(value)
    silentOptions.TargetPlayers = value
  end,
})

silentTab:Toggle({
  Title = "目标：僵尸 / NPC",
  Desc = "把僵尸与兜帽 NPC 也加入静默自瞄目标",
  Value = false,
  Callback = function(value)
    silentOptions.TargetNPCs = value
  end,
})

silentTab:Section({ Title = "显示", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

silentTab:Toggle({
  Title = "显示静默范围",
  Value = true,
  Callback = function(value)
    silentOptions.ShowFOV = value
  end,
})

silentTab:Toggle({
  Title = "彩虹范围圈",
  Desc = "静默范围圈会以彩虹色循环变色",
  Value = false,
  Callback = function(value)
    silentOptions.Rainbow = value
  end,
})

-- ==================== 透视 ====================
local espTab = CombatSection:Tab({
  Title = "透视",
  Desc = "方框 / 骨骼 / 血量",
  Icon = "eye",
  IconColor = rainbow(120),
  IconShape = "Square",
  Border = true,
})

espTab:Section({ Title = "目标", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

espTab:Toggle({
  Title = "启用玩家透视",
  Value = false,
  Callback = function(value)
    options.ESP = value

    if flag then
      f23()
    end
  end,
})

espTab:Toggle({
  Title = "僵尸 / NPC 透视",
  Value = false,
  Callback = function(value)
    options.ZombieESP = value

    if flag then
      f23()
    end
  end,
})

espTab:Toggle({
  Title = "穿墙显示",
  Desc = "被遮挡的目标依然会显示",
  Value = true,
  Callback = function(value)
    options.ThroughWalls = value
  end,
})

espTab:Section({ Title = "显示项", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

espTab:Toggle({
  Title = "显示方框",
  Value = true,
  Callback = function(value)
    options.Box = value
  end,
})

espTab:Toggle({
  Title = "显示骨骼",
  Value = true,
  Callback = function(value)
    options.Skeleton = value
  end,
})

espTab:Toggle({
  Title = "显示描边",
  Value = true,
  Callback = function(value)
    options.Outline = value
  end,
})

espTab:Toggle({
  Title = "显示名称",
  Value = true,
  Callback = function(value)
    options.Names = value
  end,
})

espTab:Toggle({
  Title = "显示血条",
  Value = true,
  Callback = function(value)
    options.Health = value
  end,
})

espTab:Toggle({
  Title = "显示距离",
  Value = true,
  Callback = function(value)
    options.Distance = value
  end,
})

espTab:Slider({
  Title = "透视距离（格）",
  Desc = "超过这个距离的目标不再绘制",
  Value = { Min = 100, Max = 5000, Default = 2000 },
  Step = 100,
  Callback = function(value)
    options.ESPDistance = value
  end,
})

espTab:Section({ Title = "过滤", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

espTab:Toggle({
  Title = "阵营检测",
  Desc = "跳过队友，中立玩家依然会显示",
  Value = true,
  Callback = function(value)
    options.TeamCheck = value
  end,
})

-- ==================== 角色 ====================
local playerTab = CharSection:Tab({
  Title = "角色功能（全部废了有时间修）",
  Desc = "速度 / 跳跃 / 飞行",
  Icon = "user",
  IconColor = rainbow(180),
  IconShape = "Square",
  Border = true,
})

playerTab:Section({ Title = "移动", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

playerTab:Toggle({
  Title = "启用加速",
  Desc = "关闭后会恢复原来的移动速度，复活后自动重新生效",
  Value = false,
  Callback = function(value)
    options.Speed = value
    f13()
  end,
})

playerTab:Slider({
  Title = "移动速度",
  Value = { Min = 18, Max = 60, Default = 28 },
  Step = 1,
  Callback = function(value)
    options.RunSpeed = value

    if options.Speed then
      f13()
    end
  end,
})

playerTab:Toggle({
  Title = "高跳",
  Value = false,
  Callback = function(value)
    options.Jump = value
    makeAttachment()
  end,
})

playerTab:Slider({
  Title = "跳跃力度",
  Value = { Min = 50, Max = 125, Default = 75 },
  Step = 1,
  Callback = function(value)
    options.JumpPower = value
  end,
})

playerTab:Toggle({
  Title = "穿墙模式",
  Desc = "关闭角色所有部件的碰撞，可以穿过墙体",
  Value = false,
  Callback = function(value)
    options.Noclip = value
    makeAttachment()
  end,
})

playerTab:Toggle({
  Title = "飞行",
  Desc = "WASD 移动，空格上升，左 Ctrl 下降",
  Value = false,
  Callback = function(value)
    options.Fly = value
    makeAttachment()
  end,
})

playerTab:Slider({
  Title = "飞行速度",
  Value = { Min = 10, Max = 100, Default = 45 },
  Step = 1,
  Callback = function(value)
    options.FlySpeed = value
  end,
})

playerTab:Section({ Title = "其他", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

playerTab:Toggle({
  Title = "自动拾取尸体",
  Desc = "在游戏的拾取范围内自动搜刮可拾取的 NPC 尸体",
  Value = false,
  Callback = function(value)
    options.AutoLoot = value
  end,
})

playerTab:Button({
  Title = "卸载脚本",
  Desc = "停止全部功能并移除菜单",
  Icon = "power",
  Justify = "Center",
  Color = Color3.fromHex("#EF4F1D"),
  Callback = function()
    task.defer(function()
      pcall(function()
        urbanReloadHub:Stop()
      end)
    end)
  end,
})

-- ==================== 传送 ====================
local tpTab = CharSection:Tab({
  Title = "传送",
  Desc = "农场 / 玩家",
  Icon = "map-pin",
  IconColor = rainbow(240),
  IconShape = "Square",
  Border = true,
})

tpTab:Section({ Title = "僵尸农场", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

local farmStatusElement = tpTab:Paragraph({
  Title = "农场状态",
  Desc = "已记录农场坐标，仅在保存过该地图时可用。",
})

tpTab:Button({
  Title = "传送到僵尸农场",
  Icon = "move-right",
  Justify = "Center",
  Color = rainbow(0),
  Callback = function()
    if game.PlaceId ~= 84448037861644 then
      farmStatusElement:SetDesc("该坐标仅在保存过的地图中可用。")
      return
    end

    local instance10, v70 = f12(localPlayer)

    if not instance10 or v70.SeatPart or instance10:GetAttribute("Downed") then
      farmStatusElement:SetDesc("必须活着、未上车且能移动才能传送。")
      return
    end

    instance10:PivotTo(CFrame.new(
      -1031.0671387, 10.2001247, 427.3442078, 0.8701015, 0, -0.4928725, 0, 1, 0, 0.4928725, 0,
      0.8701015
    ))

    farmStatusElement:SetDesc("已传送到记录的农场位置。")
  end,
})

tpTab:Section({ Title = "传送到玩家", TextSize = 16, FontWeight = Enum.FontWeight.SemiBold })

local selectedTargetName

local initialNames = {}

for _, value63 in ipairs(players:GetPlayers()) do
  if value63 ~= localPlayer then
    table.insert(initialNames, value63.Name)
  end
end

table.sort(initialNames)

local targetPlayerDropdown = tpTab:Dropdown({
  Title = "目标玩家",
  Desc = "只显示当前服务器里的其他玩家",
  Values = initialNames,
  Value = #initialNames > 0 and 1 or nil,
  Callback = function(option)
    selectedTargetName = option
  end,
})

local tpStatusElement = tpTab:Paragraph({
  Title = "传送状态",
  Desc = "请选择一名玩家，然后点击下面的按钮。",
})

local function f28(p30)
  local list6 = {}

  for _, value63 in ipairs(players:GetPlayers()) do
    if value63 ~= localPlayer and value63 ~= p30 then
      table.insert(list6, value63.Name)
    end
  end

  table.sort(list6)

  if selectedTargetName and not table.find(list6, selectedTargetName) then
    selectedTargetName = nil
  end

  pcall(function()
    targetPlayerDropdown:Refresh(list6)
  end)
end

f28()

table.insert(list, players.PlayerAdded:Connect(function() f28() end))
table.insert(list, players.PlayerRemoving:Connect(f28))

tpTab:Button({
  Title = "传送到玩家",
  Icon = "user-round-check",
  Justify = "Center",
  Color = rainbow(180),
  Callback = function()
    local instance11, v74 = f12(localPlayer)

    if not instance11 or v74.SeatPart or instance11:GetAttribute("Downed") then
      tpStatusElement:SetDesc("必须活着、未上车且能移动才能传送。")
      return
    end

    for _, value64 in ipairs(players:GetPlayers()) do
      if value64 ~= localPlayer and value64.Name == selectedTargetName then
        local _, _, v75 = f12(value64)

        if v75 then
          local position7 = v75.Position
          local rightVector = v75.CFrame.RightVector
          local vector = Vector3.new(0, 2, 0)
          instance11:PivotTo(CFrame.new(position7 + rightVector * 5 + vector))
          tpStatusElement:SetDesc("已传送到 @" .. value64.Name .. " 旁边")
          return
        end

        break
      end
    end

    tpStatusElement:SetDesc("该玩家不可用，请重新选择。")
  end,
})

table.insert(list, userInputService.WindowFocusReleased:Connect(function() flag2 = false end))
table.insert(list, userInputService.WindowFocused:Connect(function() flag2 = true end))
table.insert(list, players.PlayerRemoving:Connect(f7))
table.insert(list, runService.PreSimulation:Connect(makeAttachment))

local v76 = 0
local v77 = 0

runService:BindToRenderStep(v6, Enum.RenderPriority.Last.Value + 1, function(p31)
  if not flag then
    return
  end

  local currentCamera5 = workspace.CurrentCamera
  local enabled = silentOptions.Enabled and not silentOptions.CombineWithAim
  frame2.Visible = currentCamera5 ~= nil and options.Aim and not enabled and options.ShowFOV
  frame3.Visible = currentCamera5 ~= nil and silentOptions.Enabled and silentOptions.ShowFOV

  if currentCamera5 then
    local v78 = currentCamera5.ViewportSize / 2

    frame2.Position = UDim2.fromOffset(v78.X, v78.Y)
    frame2.Size = UDim2.fromOffset(options.FOV * 2, options.FOV * 2)

    if frame3.Visible then
      frame3.Position = UDim2.fromOffset(v78.X, v78.Y)
      frame3.Size = UDim2.fromOffset(silentOptions.FOV * 2, silentOptions.FOV * 2)

      uiStroke2.Color = silentOptions.Rainbow and Color3.fromHSV(os.clock() * 0.35 % 1, 0.8, 1)
        or color2
    end

    local v79, _, v80 = f12(localPlayer)

    local isMouseButtonPressed2 = options.Activation == "Always"
      or userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    if not options.Aim or enabled or not flag2 or userInputService:GetFocusedTextBox()
      or guiService.MenuIsOpen or not v79 or not isMouseButtonPressed2 then
      urbanReloadHub.LockedTarget = nil
      urbanReloadHub.LockedCharacter = nil
    end

    if not options.Aim then
      f26("关闭")
    elseif enabled then
      f26("被静默自瞄暂停")
    elseif not flag2 or userInputService:GetFocusedTextBox() or guiService.MenuIsOpen then
      f26("已暂停")
    elseif not v79 then
      f26("等待复活")
    elseif not isMouseButtonPressed2 then
      f26("按住鼠标右键")
    else
      local v81, v82 = f19(currentCamera5, v79, v80)

      if v81 and (v81.Position - currentCamera5.CFrame.Position).Magnitude > 0.001 then
        local cframe = CFrame.lookAt(currentCamera5.CFrame.Position, v81.Position)

        currentCamera5.CFrame = currentCamera5.CFrame:Lerp(cframe, options.HardLock and 1
          or f2(options.Smooth, p31))

        f26("已锁定：" .. v82)
      else
        f26(options.WallCheck and "视野内无可见目标（已开启墙体检测）"
          or "视野内无目标")
      end
    end
  end

  v76 = v76 + p31

  if v76 >= 0.1 then
    v76 = 0
    f23()
  end

  if options.AutoLoot then
    v77 = v77 + p31

    if v77 >= 0.4 then
      v77 = 0
      f25()
    end
  else
    v77 = 0
  end

  if currentCamera5 and next(map) then
    local raycastParams6

    if not options.ThroughWalls then
      raycastParams6 = RaycastParams.new()
      raycastParams6.FilterType = Enum.RaycastFilterType.Exclude
      raycastParams6.FilterDescendantsInstances = { currentCamera5, urbanReloadESP }

      if localPlayer.Character then
        raycastParams6:AddToFilter(localPlayer.Character)
      end
    end

    for _, value65 in pairs(map) do
      makeFrame2(currentCamera5, value65, raycastParams6)
    end
  end
end)

pcall(function()
  urbanReloadWindow:SelectTab(2)
end)

return urbanReloadHub
    