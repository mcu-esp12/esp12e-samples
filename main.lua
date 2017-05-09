if global_work ~= "main" then
    return
end

if global_work ~= nil then  -- and global_work ~= 0
    print("mcu in working process: "..global_work)
    global_work=global_work.."_in"
end

-- TODO

global_work="init_end"

return

while 1 do
  gpio.write(3, gpio.HIGH)
  tmr.delay(1000000)   -- wait 1,000,000 us = 1 second
  gpio.write(3, gpio.LOW)
  tmr.delay(1000000)   -- wait 1,000,000 us = 1 second
end
