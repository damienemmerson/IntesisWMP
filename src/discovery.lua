-- Required ST provided libraries
local log = require('log')
local socket = require 'cosock.socket'
--local socket = require('socket')

-- Local imoprts
local config = require('config')


-----------------------------------------------------------------
-- Discovery
-----------------------------------------------------------------


local function find_device()
  -- UDP socket initialization
  local udp = socket.udp()
  udp:setsockname('*', 0)
  udp:setoption('broadcast', true)
  udp:settimeout(2)

  -- broadcasting request
  log.info('===== SCANNING NETWORK...')
  udp:sendto('DISCOVER\r\n', '255.255.255.255', 3310)

  -- Socket will wait 2 seconds to receive a response back.
  local res = udp:receivefrom()
  
  -- close udp socket
  udp:close()

  if res ~= nil then
    return res
  end
  return nil
end

local disco = {}
function disco.start(driver, opts, cons)
  while true do
    local device_res = find_device()

    if device_res ~= nil then
      
      log.info('===== DEVICE FOUND IN NETWORK...')
      
    end
    log.error('===== DEVICE NOT FOUND IN NETWORK')
  end
end

return disco