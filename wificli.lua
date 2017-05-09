if global_work ~= "wifi_cli" then
    return
end

if global_work ~= nil then  -- and global_work ~= 0
    print("mcu in working process: "..global_work)
    global_work=global_work.."_in"
end

print("\n")

dofile("updcfg.lua")

print("reading parameters from "..wifi_cfg_file..":\n")
dofile(wifi_cfg_file)
print("SSID: "..SSID.."\n")
oled_str1="  SSID: "..SSID

--register callback
wifi.sta.eventMonReg(wifi.STA_IDLE, function()
    print("STATION_IDLE")
    if oled_str1 == nil then
        oled_str1="  Enter Strings "
    end
    oled_str2="wifi idle"
    dofile('oled.lua')
end)
--wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function()
    print("STATION_WRONG_PASSWORD")
    if oled_str1 == nil then
        oled_str1="  Enter Strings "
    end
    oled_str2="wrong password"
    dofile('oled.lua')
end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function()
    print("STATION_NO_AP_FOUND")
    if oled_str1 == nil then
        oled_str1="  Enter Strings "
    end
    oled_str2="no SSID"
    dofile('oled.lua')
end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function()
    print("STATION_CONNECT_FAIL")
    if oled_str1 == nil then
        oled_str1="  Enter Strings "
    end
    oled_str2="failed connection"
    dofile('oled.lua')
end)
wifi.sta.eventMonReg(wifi.STA_GOTIP, function()
    print("STATION_GOT_IP")
    if oled_str1 == nil then
        oled_str1="  Enter Strings "
    end
    oled_str2="  IP is set"
    dofile('oled.lua')
end)

--register callback: use previous state
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function(previous_State)
    if(previous_State==wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        if oled_str1 == nil then
            oled_str1="  Enter Strings "
        end
        oled_str2="lost connection"
        dofile('oled.lua')
    else
        print("STATION_CONNECTING")
        if oled_str1 == nil then
            oled_str1="  Enter Strings "
        end
        oled_str2="  connecting"
        dofile('oled.lua')
    end
end)

--unregister callback
--wifi.sta.eventMonReg(wifi.STA_IDLE)

--wifi.setmode(wifi.STATION)
--wifi.sta.config(station_cfg)

--ip, nm, gw=wifi.sta.getip()
--print("\nIP Info:\nIP Address: "..ip.." \nNetmask: "..nm.." \nGateway Addr: "..gw.."\n")

--station_cfg={}
----station_cfg.ssid="NODE-AABBCC"
--station_cfg.ssid="ZyXEL_KEENETIC_GIGA_FBF4AE"
--station_cfg.pwd="13579753"

--connect to Access Point (DO save config to flash)
--station_cfg.save=true

wifi.setmode(wifi.STATION)
print('set mode=STATION (mode='..wifi.getmode()..')\n')
print('MAC Address: ',wifi.sta.getmac())
print('    Chip ID: ',node.chipid())
print('  Heap Size: ',node.heap(),'\n')
-- wifi config start
wifi.sta.config(SSID,PASS)
wifi.sta.eventMonStart()
-- wifi config end

connect_count=0
connect_probe=20
tmr.alarm(0, 1000, 1, function()
   if wifi.sta.getip() == nil then
      if connect_count < connect_probe then
          print("Connecting to AP... probe "..(connect_count+1).." from "..connect_probe)
      else
          print("Stoping connecting to wifi\n")
          wifi.sta.eventMonStop()
          tmr.stop(0)
          
          --dofile("wifilist.lua") -- List All WiFi AP
          global_work = "wifi_srv" -- Set NodeMCU as WiFi Access Point
      end
      connect_count=connect_count+1
   else
      tmr.stop(0)
      ip, nm, gw=wifi.sta.getip()
      print("\nIP Info: ")
      print("    IP Address: ",ip)
      print("       Netmask: ",nm)
      print("  Gateway Addr: ",gw,'\n')
      oled_str1="  SSID: "..SSID
      oled_str2="CLI IP: "..ip
      dofile('oled.lua')
      --global_work = "init_end"
      --global_work = "wifi_list" -- List All WiFi AP
      global_work = "http_srv" -- Start HTTP Server
   end
end)
