-- Required ST provided libraries
local driver = require('st.driver')
local caps = require('st.capabilities')

-- Local imports
local commands = require('commands')
local discovery = require('discovery')
local lifecycles = require('lifecycles')



-- Create the driver object
local driver =
  driver(
    'LAN-Thermostat',
    {
      discovery = discovery.handle_discovery,
      lifecycle_handlers = lifecycles,
      supported_capabilities = {
        caps.switch,
        caps.thermostatCoolingSetpoint,
        caps.fanSpeed,
        caps.thermostatMode,
        caps.refresh
      },
      capability_handlers = {
        [caps.switch.ID] = {
          [caps.switch.commands.on.NAME] = commands.handle_onoff,
          [caps.switch.commands.off.NAME] = commands.handle_onoff
        },
        [caps.thermostatCoolingSetpoint.ID] = {
          [caps.thermostatCoolingSetpoint.commands.setCoolingSetpoint.NAME] = commands.handle_setCoolingSetpoint
        },
        [caps.fanSpeed.ID] = {
          [caps.fanSpeed.commands.setFanSpeed.NAME] = commands.handle_setFanSpeed
        },
        [caps.thermostatMode.ID] = {
          [caps.thermostatMode.commands.setThermostatMode.NAME] = commands.handle_setThermostatMode
        },
        [caps.refresh.ID] = {
          [caps.refresh.commands.refresh.NAME] = commands.handle_refresh
        }
      }
    }
  )

-- Run the driver
driver:run()
