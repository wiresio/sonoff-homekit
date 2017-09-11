wifi.setphymode(wifi.PHYMODE_G)
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="MySSID"
station_cfg.pwd="MyPassword"
wifi.sta.config(station_cfg)
tmr.alarm(1,1000, 1, function() 
    if wifi.sta.getip()~=nil then  
        tmr.stop(1)
		dofile("main.lc")
     end 
end)