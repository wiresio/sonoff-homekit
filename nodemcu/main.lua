tmr.alarm(1, 500, 1, function() 
    if wifi.sta.status()~=wifi.STA_GOTIP then
		node.reset()
	end 
end)

function readStatus()
	if file.open("status", "r") then
	  status = file.readline()
	  file.close()
	end
end

function writeStatus()
	if file.open("status", "w+") then
	  file.writeline(status)
	  file.close()
	end
end

-- Button gpio3
gpio.mode(3, gpio.INT, gpio.PULLUP)
gpio.trig(3, "both", function()
    gpio.write(7, gpio.HIGH)
    node.restart()
end)

-- Green LED gpio7
gpio.mode(7, gpio.OUTPUT)
gpio.write(7, gpio.LOW)

-- Relay gpio6
readStatus()
gpio.mode(6, gpio.OUTPUT)
if status == "0\n" then
	gpio.write(6, gpio.LOW)
else
	gpio.write(6, gpio.HIGH)
end	

srv = net.createServer(net.TCP, 1)
srv:listen(80, function(conn)
	conn:on("receive", function(conn, payload)
		 -- get requested resource name
		 i_s, j = string.find(payload, "/")
		 i_e, j = string.find(payload, " ",j)

		 meth = string.sub(payload,1,i_s-2);
		 res = string.sub(payload,i_s+1,i_e-1);

		if meth=="POST" then
            if res == "On" then
                gpio.write(6, gpio.HIGH)
                status = "1\n"
				writeStatus()
            elseif res == "Off" then
                gpio.write(6, gpio.LOW)
                status = "0\n"
				writeStatus()
            end
		end
        
        conn:send("HTTP/1.1 200 OK\r\n" ..
        "Server: Sonoff Switch\r\n" ..
        "Access-Control-Allow-Origin: *\r\n" ..
        "Access-Control-Allow-Methods: POST, GET, PUT, OPTIONS\r\n" ..
        "Access-Control-Allow-Headers: Content-Type\r\n" ..
        "Content-Type: text/plain\r\n\r\n" .. status)
        
	end)
	conn:on("sent", function(conn) conn:close() end)
end)