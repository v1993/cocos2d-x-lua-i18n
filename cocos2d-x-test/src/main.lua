require "config"
require "cocos.init"

-- Add library path

local s = package.config:sub(1,1)
local prefix = ";."..s.."lib"..s
package.path = package.path..prefix.."?.lua"..prefix.."?"..s.."init.lua"


--cc.FileUtils:getInstance():addSearchResolutionsOrder("src/lib");

-- I prefer this order

table.pack = pack
table.unpack = unpack

-- DEBUG
print = release_print

local function main()
    cc.Director:getInstance():runWithScene(require("tests.menu"))
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
