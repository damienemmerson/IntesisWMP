-- Required ST provided libraries
local socket = require 'cosock.socket'
local log = require('log')
local string = require('string')
local caps = require('st.capabilities')

-- local imports
local config = require('config')


-----------------------------------------------------------------
-- Client functions
-----------------------------------------------------------------

local hub_server = {}

-- Connect to Intesis device
function hub_server.tcpConnect(driver, device)

  local ip = config.DEVICE_IP
  local port = config.DEVICE_PORT

  -- Create TCP object
  tcpClient = socket.tcp()

  -- Connect to Intesis Device
  while true do
    local res, err = tcpClient:connect(ip, port)
    -- Handle timeout errors
    if err == "timeout" then
      log.trace("Connection attempt timed out")
      -- The second argument here is the "sender" position
      socket.select({}, {tcpClient})
      res, err = tcpClient:connect(ip, port)
    end
    -- Handle successful connection
    if res then
      log.trace("Connected to Intesis device")
      -- Register socket to receive data
      hub_server.tcpReceive(driver, device)
      break
    else
      log.trace("Failed to connect. Retrying in 10 seconds.")
      socket.sleep(10)
    end
  end
end


-- Receive data
function hub_server.tcpReceive(driver, device)
  log.info("Registering socket and preparing to receive data")
  device.thread:register_socket(
  tcpClient,
  function ()
    local data, status = tcpClient:receive()
    if data then
      log.trace("Received data: "..data)
      -- Handle the received data
      hub_server.handleData(driver, device, data)
    elseif status then
      log.trace("Error in receiving data: "..status)
    end
   end,
   'tcpReceive')

end


-- Send commands to Intesis device
function hub_server.sendCommand(driver, device, payload)  
  log.trace("Sending command: "..payload)
  local res, status = tcpClient:send(payload)

  if res then
    log.trace("Payload sent: "..res)
  end

  if status then
    log.trace("Socket error: "..status)
    -- Shut down socket gracefully
    device.thread:unregister_socket(tcpClient)
    tcpClient:close()
    -- Device now offline
    device.offline()
    -- Try to reconnect
    hub_server.tcpConnect(driver, device)
  end

end


-- Handle received data
function hub_server.handleData(driver, device, data)
 
  local cmd, acNum, func, value = string.match(data, "(%a+),(%d+):(%a+),(%w+)")
 
  if cmd == 'CHN' then
    if func == 'ONOFF' then
      if value == 'ON' then
        device:emit_event(caps.switch.switch.on()) else
        device:emit_event(caps.switch.switch.off())
      end 
    end
    if func == 'FANSP' then
      if value == 'AUTO' then
        value = 0
      end
      log.trace("Setting Fanspeed to: "..value)
      device:emit_event(caps.fanSpeed.fanSpeed(tonumber(value)))
    end
    if func == 'AMBTEMP' then
      value = value / 10
      device:emit_event(caps.temperatureMeasurement.temperature({ value = value, unit = "C" }))
    end
    if func == 'SETPTEMP' then
      value = value / 10
      device:emit_event(caps.thermostatCoolingSetpoint.coolingSetpoint({ value = value, unit = "C" }))
    end
    if func == 'MODE' then
      if value == 'HEAT' then
        device:emit_event(caps.thermostatMode.thermostatMode("heat"))
      end 
      if value == 'COOL' then
        device:emit_event(caps.thermostatMode.thermostatMode("cool"))
      end 
      if value == 'DRY' then
        device:emit_event(caps.thermostatMode.thermostatMode("dryair"))
      end 
      if value == 'AUTO' then
        device:emit_event(caps.thermostatMode.thermostatMode("auto"))
      end 
      if value == 'FAN' then
        device:emit_event(caps.thermostatMode.thermostatMode("fanonly"))
      end 
    end
  end
end

return hub_server
