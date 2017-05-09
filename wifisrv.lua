if global_work ~= "wifi_srv" then
    return
end

ap_cfg      = {}
ap_cfg.ssid = "ESP_AZXSDC" -- SSID: 1-32 chars
--ap_cfg.pwd=""            -- Password: Minimum 8 Chars. Range 8-64 chars. 
ap_cfg.auth=wifi.AUTH_OPEN -- Password Authentication: AUTH_OPEN,
                           --                          AUTH_WPA_PSK,
                           --                          AUTH_WPA2_PSK,
                           --                          AUTH_WPA_WPA2_PSK
ap_cfg.channel = 6         -- Channel: Range 1-14
ap_cfg.hidden  = 0         -- Hidden Network? True: 1, False: 0
ap_cfg.max     = 4         -- Max Connections: Range 1-4
ap_cfg.beacon  = 100       -- WiFi Beacon: Range 100-60000

ap_ip_cfg         = {}
ap_ip_cfg.ip      = "192.168.10.1"
ap_ip_cfg.netmask = "255.255.255.0"
ap_ip_cfg.gateway = "192.168.10.1"

ap_dhcp_cfg       = {}
ap_dhcp_cfg.start = "192.168.10.2"

-- Set NodeMCU as WiFi Access Point
function wifi_AP()
    wifi.setmode(wifi.SOFTAP)        -- Configure ESP8266 into AP Mode
    wifi.setphymode(wifi.PHYMODE_N)  -- Configure 802.11n Standard
    wifi.ap.config(ap_cfg)           -- Configure WiFi Network Settings
    wifi.ap.setip(ap_ip_cfg)         -- Configure AP IP Address
    wifi.ap.dhcp.config(ap_dhcp_cfg) -- Configure DHCP Service
    wifi.ap.dhcp.start()             -- Start DHCP Service
end

if global_work ~= nil then  -- and global_work ~= 0
    print("mcu in working process: "..global_work)
    global_work=global_work.."_in"
end

print("\nSet NodeMCU as WiFi Access Point... ")
wifi_AP()
print("OK\n")
oled_str1="  SSID: "..ap_cfg.ssid
oled_str2="SRV IP: "..ap_ip_cfg.ip
dofile('oled.lua')

--connect_srv_count=0
--tmr.alarm(3, 1000, 1, function()
--    connect_srv_count=connect_srv_count+1
--    print("Wait conn to NodeMCU... probe "..connect_srv_count)
--    --tmr.stop(3)
--end)

wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
    print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
    if http_srv_is_run ~= nil or http_srv_is_run ~= 0 then
        global_work="http_srv"
    else
        print("http_srv_is_run: "..http_srv_is_run)
        print("and http_srv must be running!\n")
        global_work="init_end"
    end
end)
