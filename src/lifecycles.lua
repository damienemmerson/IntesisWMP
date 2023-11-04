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
  
  -- Connect to the Intesis device
  client.tcpConnect(driver, device)

  -- Set connection keepalive schedule
  device.thread:call_on_schedule(
    config.SCHEDULE_PERIOD,
    function ()
      return client.sendCommand(driver, device,"PING\n")
    end,
    'keepalive')

  -- Refresh the device to get the state for each capability attribute
  commands.handle_refresh(driver, device)

  -- Can't seem to get this to work in device config
  device:emit_event(caps.thermostatMode.supportedThermostatModes({"auto", "cool", "fanonly", "heat", "dryair"}))

  -- Mark device as online so it can be controlled from the app
  device:online()
end



-- This function is called both when a device is added (but after `added`) and after a hub reboots
function lifecycles.added(driver, device)
  log.info("[" .. device.id .. "] Adding new device")

end



-- This function is called when a device is removed by the cloud and synchronized down to the hub
function lifecycles.removed(_, device)
  log.info("[" .. device.id .. "] Removing device")

end

return lifecycles