-- OLED Display demo
-- March, 2016 
-- @kayakpete | pete@hoffswell.com

-- Hardware:
--   ESP-12E Devkit
--   4 pin I2C OLED 128x64 Display Module

-- Connections:
--   ESP  --  OLED
--   3v3  --  VCC
--   GND  --  GND
--   D1   --  SDA
--   D2   --  SCL

-- Variables
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin

function init_OLED(sda,scl) --Set up the u8glib lib
   sla = 0x3C
   i2c.setup(0, sda, scl, i2c.SLOW)
   disp = u8g.ssd1306_128x64_i2c(sla)
   disp:setFont(u8g.font_6x10)
   --disp:setFont(u8g.font_cyrilic6x10)
   --disp:setFont(u8g.font_cyr_6x10)
   --disp:setFont(u8g.font_rus6x10)
   disp:setFontRefHeightExtendedText()
   disp:setDefaultForegroundColor()
   disp:setFontPosTop()
   --disp:setRot180()           -- Rotate Display if needed
end

function print_OLED()
 disp:firstPage()
 repeat
   disp:drawFrame(2,2,126,62)
   disp:drawStr(5,  5, oled_str1)
   disp:drawStr(5, 20, oled_str2)
   disp:drawStr(5, 35, oled_str3)
   disp:drawStr(5, 50, oled_str4)
   --disp:drawCircle(18, 47, 14)
 until disp:nextPage() == false
end

-- Main Program
if oled_str1 == nil then
    oled_str1="  Enter Strings "
end
if oled_str2 == nil then
    oled_str2="  @ IVE0"
end
if oled_str3 == nil then
    oled_str3="  ------"
end
if oled_str4 == nil then
    oled_str4="  ------"
end
init_OLED(sda,scl)
print_OLED() 
