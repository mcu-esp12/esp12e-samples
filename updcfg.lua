--files = file.list()
--if files["wifi.config"] then
--    print("wifi.config is exists")
--end

if update == 1 then
    print(wifi_cfg_file.." removing for FORCE update settings")
    file.remove(wifi_cfg_file)
end

if file.exists(wifi_cfg_file) then
    print(wifi_cfg_file.." is exists")
else
    print(wifi_cfg_file.." NOT exists")
    file.open(wifi_cfg_file,"w+")
    temp = "SSID = \""..def_ssid.."\""
    file.writeline(temp)
    temp = "PASS = \""..def_pass.."\""
    file.writeline(temp)
    file.flush()
    temp = nil
    file.close()
    print("saving default "..wifi_cfg_file)
end
