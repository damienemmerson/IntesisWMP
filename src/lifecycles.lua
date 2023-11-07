-- Required ST provided libraries
local log = require('log')
local caps = require('st.capabilities')

-- Local imports
local client = require('client')
local commands = require('commands')
local config = require('config')


-----------------------------------------------------------------
-- Lifecycle functions
-----------------------------------------------------------------

local lifecycles = {}

-- This function is called once a device is added by the cloud and synchronized down to the hub
function lifecycles.init(driver, device)
  log.info("[" .. device.id .. "] Initializing device")
  
  if device.preferences.ipAddress ~= "0.0.0.0" then
    -- Connect to Intesis Interface
    client.tcpConnect(driver, device)
    -- Refresh the device to get the state for each capability attribute
    commands.handle_refresh(driver, device)
  end
  -- Set connection keepalive schedule
  device.thread:call_on_schedule(
    config.SCHEDULE_PERIOD,
    function ()
      return client.sendCommand(driver, device,"PING\n")
    end,
    'keepalive')

  -- Can't seem to get this to work in device config
  device:emit_event(caps.thermostatMode.supportedThermostatModes({"auto", "cool", "fanonly", "heat", "dryair"}))
  -- The device isn't online until the IP adress is configured in preferences
  device:offline()
end



-- This function is called both when a device is added (but after `added`) and after a hub reboots
function lifecycles.added(driver, device)
  log.info("[" .. device.id .. "] Adding new device")

end



-- This function is called when a device is removed by the cloud and synchronized down to the hub
function lifecycles.removed(_, device)
  log.info("[" .. device.id .. "] Removing device")

end


function lifecycles.infoChanged(driver, device, event, args)
 
  if args.old_st_store.preferences.ipAddress ~= device.preferences.ipAddress then
      
    -- If the IP address changes the interface is offline until successfully connected again
    log.trace("Shutting down socket gracefully")
    device.thread:unregister_socket(tcpClient)
    log.trace("Closing TCP Connection")
    tcpClient:close()
    log.trace("Device is now offline")
    device:offline()
    
    -- Connect to the Intesis Interface
    client.tcpConnect(driver, device)

    -- Refresh the device to get the state for each capability attribute
    commands.handle_refresh(driver, device)
  end
end

return lifecycles