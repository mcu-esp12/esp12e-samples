if global_work ~= "http_srv" then
    return
end

http_srv_is_run=1

if global_work ~= nil then  -- and global_work ~= 0
    print("mcu in working process: "..global_work)
    global_work=global_work.."_in"
end

dofile("httpsrv_fn.lua")

-- Start a simple http server
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive", incoming_connection)
  -- https://nodemcu.readthedocs.io/en/master/en/modules/net/#netsocketon
  -- "connection", "reconnection", "disconnection", "receive" or "sent"
  conn:on("reconnection",function(conn,payload)
    print(payload)
    node_mode=wifi.getmode()
    if node_mode == wifi.STATION then
        str_mode = "STATION"
        ip, nm, gw=wifi.sta.getip()
    elseif node_mode == wifi.SOFTAP then
        str_mode = "SOFTAP"
        ip, nm, gw = wifi.ap.getip()
    elseif node_mode == wifi.STATIONAP then
        str_mode = "STATIONAP"
        ip, nm, gw=wifi.sta.getip()
    elseif node_mode == wifi.NULLMODE then
        str_mode = "NULLMODE"
        ip = "null"
        nm = "null"
        gw = "null"
    else
        str_mode = "UNKNOWN"
        ip = "unknown"
        nm = "unknown"
        gw = "unknown"
    end
    print ("NodeMCU as "..str_mode)
    print ("  ip: "..ip)
    print ("  nm: "..nm)
    print ("  gw: "..gw)
    print ("\n\n")
    msg = "<h1> NodeMCU as "..str_mode.." </h1>"
    msg = msg.."<br>ip: "..ip
    msg = msg.."<br>nm: "..nm
    msg = msg.."<br>gw: "..gw
    conn:send('HTTP/1.1 200 OK\n\n')
    conn:send("<!DOCTYPE HTML>\n<html>"..msg)
    conn:send("</html>")
  end)
  conn:on("sent",function(conn) conn:close() end)
  collectgarbage()
  print("Memory Used:"..collectgarbage("count"))
  print("Heap Available:"..node.heap())
end)

global_work="init_end"
