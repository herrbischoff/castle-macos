--
-- Auto reload configuration
--
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

--
-- WiFi watcher
--
local wifiWatcher = nil
local homeSSID = "DailyNewYorker3000"
local lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == homeSSID and lastSSID ~= homeSSID then
        -- We just joined our home WiFi network
        -- hs.audiodevice.defaultOutputDevice():setVolume(25)
        -- hs.task.new("/usr/bin/sudo", function(code, stdout, stderr) print("stdout: "..stdout) ; print("stderr: "..stderr) end, {"/usr/bin/tmutil", "enable"}):start()
        hs.task.new("/usr/bin/sudo", function(code, stdout, stderr) print("stdout: "..stdout) ; print("stderr: "..stderr) end, {"/usr/sbin/scselect", "Home"}):start()
        hs.notify.new({title="Hammerspoon", informativeText="Arrived Home"}):send()
    elseif newSSID ~= homeSSID and lastSSID == homeSSID then
        -- We just departed our home WiFi network
        -- hs.audiodevice.defaultOutputDevice():setVolume(0)
        hs.task.new("/usr/bin/sudo", function(code, stdout, stderr) print("stdout: "..stdout) ; print("stderr: "..stderr) end, {"/usr/sbin/scselect", "Automatic"}):start()
        -- hs.task.new("/usr/sbin/scselect", function() end, {"Automatic"})
        hs.notify.new({title="Hammerspoon", informativeText="Being somewhere else"}):send()
    end

    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()

--
-- Defeat paste blocking
--
hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)
