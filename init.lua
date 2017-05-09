if init_is_runned ~= nil then
    return
end
init_is_runned = 1

majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
print("NodeMCU "..majorVer.."."..minorVer.."."..devVer)
oled_str1=" NodeMCU "..majorVer.."."..minorVer.."."..devVer
oled_str2=" © Rus Selin"
oled_str3=" MAC ADDR: "
oled_str4=" "..wifi.sta.getmac()
dofile('oled.lua')

update=0 -- update flag for changing config file
def_ssid = "ZyXEL_KEE"  -- FAKE SSID for tests
--def_ssid = "ZyXEL_KEENETIC_GIGA_FBF4AE"
def_pass = "12345678"
wifi_cfg_file="wifi.config"

print('\nRunning init.lua\n')

debug=0  -- for debug output
global_work="wifi_list"
tmr_num=1

count=0
probe=100
tmr.alarm(tmr_num, 2000, 1, function()
    tmr.stop(tmr_num)
    if     global_work == "wifi_cli"  then  -- WORK: WIFI CLI
        count=0
        dofile("wificli.lua")  -- Run the WiFi Client
        print('heap:', node.heap())
        tmr.start(tmr_num)
    elseif global_work == "wifi_list" then  -- WORK: WIFI LIST
        count=0
        dofile("wifilist.lua") -- Run the List All WiFi AP
        print('heap:', node.heap())
        tmr.start(tmr_num)
    elseif global_work == "wifi_srv" then  -- WORK: WIFI AP (SRV)
        count=0
        dofile("wifisrv.lua")  -- Run the NodeMCU as WiFi Access Point
        print('heap:', node.heap())
        tmr.start(tmr_num)
    elseif global_work == "http_srv" then  -- WORK: HTTP SRV START
        count=0
        --node.compile('httpsrv.lua')
        print('heap:', node.heap())
        --dofile("httpsrv.lc")  -- Run the HTTP SRV
        dofile("httpsrv.lua")  -- Run the HTTP SRV
        tmr.start(tmr_num)
    elseif global_work == "main"      then  -- WORK: MAIN
        count=0
        dofile("main.lua")     -- Run the main file
        tmr.start(tmr_num)
    elseif global_work == "init_end"  then  -- WORK: STOP
        print("Task in init.lua is ended")
        print('heap:', node.heap())
    else
      if count < probe+1 then
        if debug == 1 then
            print("Waiting for task: "..global_work..". Probe "..count.." from "..probe)
        end
        tmr.start(tmr_num)
      else
        print("Timeout in work task: "..global_work.."\n")
        tmr.stop(tmr_num)
      end
    end
    count = count + 1
end)
