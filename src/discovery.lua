-- Required ST provided libraries
local log = require('log')
local socket = require 'cosock.socket'
--local socket = require('socket')

-- Local imoprts
local config = require('config')


-----------------------------------------------------------------
-- Discovery
-----------------------------------------------------------------

local discovery = {}

-- handle discovery events, normally you'd try to discover devices on your
-- network in a loop until calling `should_continue()` returns false.
function discovery.start(driver, _should_continue)
  log.info("Starting Discovery")

  

  local metadata = {
    type = config.DEVICE_TYPE,
    -- the DNI must be unique across your hub, using static ID here so that we
    -- only ever have a single instance of this "device"
    device_network_id = "LAN-IntesisInterface",
    label = "Intesis Interface",
    profile = config.DEVICE_PROFILE,
    manufacturer = "damienemmerson",
    model = "v1",
    vendor_provided_label = nil
  }


  -- tell the cloud to create a new device record, will get synced back down
  -- and `device_added` and `device_init` callbacks will be called
  driver:try_create_device(metadata)
end 
return discovery

-- local function find_device()
--   -- UDP socket initialization
--   local udp = socket.udp()
--   udp:setsockname('*', 0)
--   udp:setoption('broadcast', true)
--   udp:settimeout(2)

--   -- broadcasting request
--   log.info('===== SCANNING NETWORK...')
--   udp:sendto('DISCOVER\r\n', '255.255.255.255', 3310)

--   -- Socket will wait 2 seconds to receive a response back.
--   local res = udp:receivefrom()
  
--   -- close udp socket
--   udp:close()

--   if res ~= nil then
--     return res
--   end
--   return nil
-- end

-- local disco = {}
-- function disco.start(driver, opts, cons)
--   while true do
--     local device_res = find_device()

--     if device_res ~= nil then
      
--       log.info('===== DEVICE FOUND IN NETWORK...')
      
--     end
--     log.error('===== DEVICE NOT FOUND IN NETWORK')
--   end
-- end

-- return disco