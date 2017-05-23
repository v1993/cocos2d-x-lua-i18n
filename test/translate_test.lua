local json  = require 'lunajson'

local data
local efunc = function() end
local mymt = {__index = function() return efunc end}

local setmt

setmt = function(tab, mtab) -- Tree call
	setmetatable(tab, mtab)
	for k,v in pairs(tab) do
		if type(v) == 'table' then
			setmt(v, mtab)
		end
	end
end

do
	local file = io.open('data.json', 'r')
	data = json.decode(file:read('*a'))
	setmt(data, {__call = function(self, ...) return next(self, (select(2, ...))) end})
	file:close()	
end

local test_word = function(obj, dir, lang, word, correct, ctab)
	local res = __(word, obj)
	local msg = "Test failed on domain "..tostring(obj)..", directory "..dir..", language "..tostring(lang)..", field "..word
	ctab.test(correct, res, msg)
end

local test_lang = function(obj, dir, lang, ctab)
	local langtab = data[dir][lang]
	for word,correct in data[dir][lang] do
		test_word(obj, dir, lang, word, correct, ctab)
	end
end

local test_dir = function(obj, dir, ctab)
	setmetatable(ctab, mymt)
	for k,lang in ipairs(data[dir].order) do
		ctab.onlang(obj, dir, lang)
		test_lang(obj, dir, lang, ctab)
		ctab.nextlang(obj, dir)
	end
end

local test_all = function(obj, ctab)
	setmetatable(ctab, mymt)
	for k,dir in ipairs(data.order) do
		ctab.ondir(obj, dir)
		test_dir(obj, dir, ctab)
		ctab.nextdir(obj)
	end
end

return {test_word = test_word, test_lang = test_lang, test_dir = test_dir, test_all = test_all}
