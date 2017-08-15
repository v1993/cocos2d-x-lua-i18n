local tests = {
	{name = 'test1', path = 'tests.test1'};
	{name = 'test2', path = 'tests.test2'};
}

local ci18n = require 'cocos-i18n'

local LINE_SPACE = 40
local s = cc.Director:getInstance():getWinSize()

local TESTS_COUNT = #tests

local sc = cc.Scene:create()
local menuNode = cc.Node:create()
sc:addChild(menuNode)
menuNode:setPosition(cc.p(0,0))

do -- 
	local function closeCallback()
		cc.Director:getInstance():endToLua()
	end
	
	local CloseItem = cc.MenuItemImage:create('exit.png', 'exit2.png')
	CloseItem:registerScriptTapHandler(closeCallback)
	CloseItem:setPosition(cc.p(0, display.height))
	CloseItem:setAnchorPoint(cc.p(0, 1))

	local CloseMenu = cc.Menu:create()
	CloseMenu:setPosition(cc.p(0, 0))
	CloseMenu:addChild(CloseItem)
	menuNode:addChild(CloseMenu)
end

do
	local CurPos = {x = 0, y = 0}
	local BeginPos = {x = 0, y = 0}
	
	local mainMenu = cc.Menu:create()
	
	local make_menu_label = function(text)
		local sc = 1.5
		local label = cc.Label:createWithSystemFont(text, "Arial", 24*sc)
			:setScale(1/sc)
			:setAnchorPoint(cc.p(0.5, 0.5))
		print(label)
		return label
	end
	
	for num,conf in ipairs(tests) do
		local path = conf.path
		local callback = function()--[[
			local testsc = require(path)
			cc.Director:getInstance():pushScene()]]--
			print('Loading', path)
		end
		local label = make_menu_label(num..'. '..conf.name)
		local mitem = cc.MenuItemLabel:create(label)
		mitem:registerScriptTapHandler(callback)
		mitem:setPosition(cc.p(s.width / 2, (s.height - (num) * LINE_SPACE)))
		mainMenu:addChild(mitem, num + 10000, num + 10000)
	end
	mainMenu:setContentSize(cc.size(s.width, (TESTS_COUNT + 1) * (LINE_SPACE)))
	mainMenu:setPosition(CurPos.x, CurPos.y)
	
	-- handling touch events
	local function onTouchBegan(touch, event)
		BeginPos = touch:getLocation()
		-- CCTOUCHBEGAN event must return true
		return true
	end
	
	local function onTouchMoved(touch, event)
		local location = touch:getLocation()
		local nMoveY = location.y - BeginPos.y
		local curPosx, curPosy = mainMenu:getPosition()
		local nextPosy = curPosy + nMoveY
		local winSize = cc.Director:getInstance():getWinSize()
		if nextPosy < 0 then
			mainMenu:setPosition(0, 0)
			return
		end
		if nextPosy > ((TESTS_COUNT + 1) * LINE_SPACE - winSize.height) then
			mainMenu:setPosition(0, ((TESTS_COUNT + 1) * LINE_SPACE - winSize.height))
			return
		end
		mainMenu:setPosition(curPosx, nextPosy)
		BeginPos = {x = location.x, y = location.y}
		CurPos = {x = curPosx, y = nextPosy}
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	local eventDispatcher = menuNode:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, menuNode)
	menuNode:addChild(mainMenu)
end

return sc
