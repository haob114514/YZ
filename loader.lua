print("[Loader] 注入成功，开始检测")

-- 使用字符串拼接进行简单的混淆，防止源码直接暴露完整链接
local base_url = "https://raw.githubusercontent.com/"
local path_url = "haob114514/YZ/refs/heads/main/"

local ScriptMap = {
    PlaceId = {
        ["10769552054"] = base_url .. path_url .. "urban.lua",
        ["84448037861644"] = base_url .. path_url .. "urban.lua",
        ["155615604"]   = base_url .. path_url .. "Prisonlife.lua",
    },
    JobId = {},
}

print("[Loader] PlaceId =", tostring(game.PlaceId))
print("[Loader] JobId   =", tostring(game.JobId))

if getgenv and getgenv().__YZLoaderBusy then
    warn("[Loader] 之前已执行过，跳过")
    return
end

local function getScriptUrl()
    local placeId = tostring(game.PlaceId)
    if ScriptMap.PlaceId[placeId] then
        return ScriptMap.PlaceId[placeId], "PlaceId"
    end
    if game.JobId and game.JobId ~= "" and ScriptMap.JobId[game.JobId] then
        return ScriptMap.JobId[game.JobId], "JobId"
    end
    return nil
end

local function loadScriptWithRetry(url, retries)
    retries = retries or 3
    local lastErr
    for i = 1, retries do
        local ok, res = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok then
            return true
        end
        lastErr = res
        task.wait(1)
    end
    error("加载失败: " .. tostring(lastErr))
end

local url, matchType = getScriptUrl()
if not url then
    warn(("[Loader] 不支持当前服务器，跳过。PlaceId=%s JobId=%s")
        :format(tostring(game.PlaceId), tostring(game.JobId)))
    return
end

-- 【修改点1】这里去掉了 ..url，控制台将不再显示您的 GitHub 链接
print("[Loader] 匹配成功（"..matchType.."），开始加载脚本...")

if getgenv then getgenv().__YZLoaderBusy = true end

local ok, err = pcall(function()
    loadScriptWithRetry(url)
end)

-- 【修改点2】修复了加载完成后不释放 busy 状态的 Bug，并修复了原来的 format 报错
if ok then
    print("[Loader] 加载完成")
    if getgenv then getgenv().__YZLoaderBusy = nil end -- 加载成功后重置状态，允许下次重新执行
else
    warn("[Loader] 加载失败: " .. tostring(err))
    if getgenv then getgenv().__YZLoaderBusy = nil end -- 加载失败后也要重置状态
end