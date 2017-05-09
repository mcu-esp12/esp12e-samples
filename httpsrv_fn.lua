sendFilesList = nil
sendPage = nil
collectgarbage()
print("Memory Used:"..collectgarbage("count"))
print("Heap Available:"..node.heap())
  
function sendFilesList(conn)
  conn:send('HTTP/1.1 200 OK\n\n')
  conn:send('<!DOCTYPE HTML>\n<html>\n<head><meta content="text/html; charset=utf-8">\n<title>Files</title></head>\n<body>\n<button onclick="window.location.href=\'/\'">SSIDs</button>\n<form action="/files" method="POST">\n')
  conn:send('<br/><br/>\n\n<table>\n<tr><th>Choose File:</th></tr>\n')
  l = file.list();
  for k,v in pairs(l) do
    print("name:"..k..", size:"..v)
    conn:send('<tr><td><input type="button" onClick=\'document.getElementById("filename").value = "' .. k .. '"\' value="' .. k .. '"/></td></tr>\n')
  end
  conn:send('</table>\n\nFile: <input type="text" id="filename" name="filename" value=""><br/>\n\n')
  conn:send('<input type="submit" value="Submit"/>\n<input type="button" onClick="window.location.reload()" value="Refresh"/>\n')
  conn:send('</form>\n</body></html>')
end

function sendPage(conn)
  conn:send('HTTP/1.1 200 OK\n\n')
  conn:send('<!DOCTYPE HTML>\n<html>\n<head><meta content="text/html; charset=utf-8">\n<title>Device Configuration</title></head>\n<body>\n<button onclick="window.location.href=\'/files\'">Files</button>\n<form action="/" method="POST">\n')

  --if(lastStatus ~= nil) then
  --  conn:send('<br/>Previous connection status: ' .. lastStatus ..'\n')
  --end
  
  --if(newssid ~= "") then
  --  conn:send('<br/>Upon reboot, unit will attempt to connect to SSID "' .. newssid ..'".\n')
  --end
    
  conn:send('<br/><br/>\n\n<table>\n<tr><th>Choose SSID to connect to:</th></tr>\n')

  for ap,v in pairs(currentAPs) do
    conn:send('<tr><td><input type="button" onClick=\'document.getElementById("ssid").value = "' .. ap .. '"\' value="' .. ap .. '"/></td></tr>\n')
  end
  
  conn:send('</table>\n\nSSID: <input type="text" id="ssid" name="ssid" value=""><br/>\nPassword: <input type="text" name="passwd" value=""><br/>\n\n')
  conn:send('<input type="submit" value="Submit"/>\n<input type="button" onClick="window.location.reload()" value="Refresh"/>\n<br/>If you\'re happy with this...\n<input type="submit" name="reboot" value="Reboot!"/>\n')
  conn:send('</form>\n</body></html>')
end

function url_decode(str)
  local s = string.gsub (str, "+", " ")
  s = string.gsub (s, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  s = string.gsub (s, "\r\n", "\n")
  return s
end

function incoming_connection(conn, payload)

  local client  = conn
  local request = payload
local buf = ""
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
                buf = buf , v
            end
       end
if method == "POST" then
    buf = "POST DETECTED"
    print(buf)
    --print("########")
    --print(request)
    --print("********")
else
    print(method)
end
--client:send("HTTP/1.1 200 OK\n")
--client:send("Server: NodeMCU 0.1\n")
--client:send("Content-Length: " .. string.len(buf) .. "\n\n")
--client:send(buf);
--client:close();
--collectgarbage();

  if (string.find(payload, "GET /favicon.ico HTTP/1.1") ~= nil) then
    print("GET favicon request")
  elseif (string.find(payload, "GET / HTTP/1.1") ~= nil) then
    print("GET received")
    ok, err = pcall(sendPage, conn)
    if ok then
        print("function sendPage is OK")
    else
        collectgarbage()
        print("Memory Used:"..collectgarbage("count"))
        print("Heap Available:"..node.heap())
        print("function sendPage is err: "..err)
    end
  elseif (string.find(payload, "GET /files HTTP/1.1") ~= nil) then
    print("GET files")
    ok, err = pcall(sendFilesList, conn)
    if ok then
        print("function sendFilesList is OK")
    else
        print("function sendFilesList is err: "..err)
    end
  else
    print("POST received")
    print("payload:"..payload)
    local blank, plStart = string.find(payload, "\r\n\r\n");
    print("blank:", blank)
    print("plStart:", plStart)
    if(plStart == nil) then
    --if(plStart ~= nil) then
        collectgarbage()
        print("Memory Used:"..collectgarbage("count"))
        print("Heap Available:"..node.heap())
        return
    end
    payload = string.sub(payload, plStart+1)
    args={}
    args.passwd=""
    -- parse all POST args into the 'args' table
    for k,v in string.gmatch(payload, "([^=&]*)=([^&]*)") do
      print(k, v)
      args[k]=url_decode(v)
    end
    if(args.ssid ~= nil and args.ssid ~= "") then
      print("New SSID: " .. args.ssid)
      print("Password: " .. args.passwd)
      newssid = args.ssid
      --wifi.sta.config(args.ssid, args.passwd)
      update=1 -- update flag for changing config file
      def_ssid = args.ssid
      def_pass = args.passwd
      wifi_cfg_file="wifi.config"
      dofile("updcfg.lua")
    end
    if args.filename ~= nil then
      dofile(args.filename)
      conn:send('HTTP/1.1 303 See Other\n')
      conn:send('Location: /files\n')
      return
    end    
    if(args.reboot ~= nil) then
      print("Rebooting")
      conn:close()
      node.restart()
    end
    conn:send('HTTP/1.1 303 See Other\n')
    conn:send('Location: /\n')
  end
end
