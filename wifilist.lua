if global_work ~= "wifi_list" then
    return
end

--- AP Search Params ---
ap_list_cfg             = {}
ap_list_cfg.ssid        = nil -- Enter SSID, use nil to list all SSIDs
ap_list_cfg.bssid       = nil -- Enter BSSID, use nil to list all SSIDs
ap_list_cfg.channel     = 0   -- Enter Channel ID, use 0 to list all channels
ap_list_cfg.show_hidden = 1   -- Use 0 to skip hidden networks, use 1 to list them
--- AP Table Format ---
ap_list_table_format    = 1   -- 1 for Output table format - (BSSID : SSID, RSSI, AUTHMODE, CHANNEL)
                              -- 0 for Output table format - (SSID : AUTHMODE, RSSI, BSSID, CHANNEL)
-- Print Output AP List
function print_AP_List(ap_table)
    if(ap_table==nil) then
        return
    end
    currentAPs = ap_table

    for p,q in pairs(ap_table) do
        print(p.." : "..q)
    end

    global_work="wifi_cli"
    print("\nAll Done\n")
end

-- List All Available Access Points
function wifi_APList()
    --wifi.sta.getap(ap_list_cfg,ap_list_table_format, print_AP_List)
    wifi.setmode(wifi.STATION)
    wifi.sta.getap(print_AP_List)
    --wifi.sta.getap(function(T) for k,v in pairs(T) do print(k..":"..v) end end)
end

if global_work ~= nil then  -- and global_work ~= 0
    print("mcu in working process: "..global_work)
    global_work=global_work.."_in"
end

print("\nList All AP:\n")
wifi_APList()
