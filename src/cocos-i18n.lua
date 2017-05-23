require 'i18n' -- Load library, search path sould include "path_to_storage/?/init.lua"

local cc, i18n = cc, i18n -- For speed up

for k,v in pairs(i18n.langMap) do
	setmetatable(v, {__tostring = function() return k end})
end

local static = {} -- Constants
local lib = setmetatable({}, {__index = static}) -- Everything, but storage of functions in fact

local eng = {}
do
	local englist = {'en-en', 'en_en', 'en', 'nil', ''}
	for k,v in ipairs(englist) do
		eng[v] = true
	end
end

local nummap
if cc then
	nummap = { -- Convert from LangType to i18n
		[cc.LANGUAGE_ENGLISH] = nil; -- Just use default strings
		[cc.LANGUAGE_CHINESE] = i18n.zh_cn;
		[cc.LANGUAGE_FRENCH] = i18n.fr_fr;
		[cc.LANGUAGE_ITALIAN] = i18n.it_it;
		[cc.LANGUAGE_GERMAN] = i18n.de_de;
		[cc.LANGUAGE_SPANISH] = i18n.es_es;
		[cc.LANGUAGE_RUSSIAN] = i18n.ru_ru;
		[cc.LANGUAGE_KOREAN] = i18n.ko_kr;
		[cc.LANGUAGE_JAPANESE] = i18n.ja_jp;
		[cc.LANGUAGE_HUNGARIAN] = i18n.hu_hu;
		[cc.LANGUAGE_PORTUGUESE] = i18n.pt_pt;
		[cc.LANGUAGE_ARABIC] = i18n.ar_sa;
	}
else -- Fallback
	nummap = {i18n.zh_cn, i18n.fr_fr, i18n.it_it, i18n.de_de, i18n.es_es, i18n.ru_ru, i18n.ko_kr, i18n.ja_jp, i18n.hu_hu, i18n.pt_pt, i18n.ar_sa} -- Basic Enum from v. 3.14
end


static.typemap = setmetatable({}, {__index = function(self, key)
		if type(key) == 'number' and key >= 0 and key <= #nummap then -- Convert LangType
			return self[nummap[key]]
		elseif type(key) == 'table' and key.country and key.lang then
			return key
		elseif key == nil or eng[key] then
			return nil
		elseif type(key) == 'string' then -- Convert language codes (both "ln_cn" and "ln-cn" are enabled, also use xx for 'xx-xx")
			local res = i18n.langMap[string.gsub(key, '_', '-')] or i18n.langMap[string.format('%s-%s', key, key)]
			if res then
				return res
			end
		end
		error('Unknown language format')
end})

local getdomain = function(self)
	return self.domain
end

local checkFile

if cc then
	checkFile = function(fanme)
		return cc.FileUtils:getInstance():isFileExist(fanme)
	end
else
	checkFile = function(fname)
		local f = io.open(fname, "r")
		if f ~= nil then
			io.close(f)
			return true
		else
			return false
		end
	end
end

local fields_allowed = {
	domain = function(self, value) -- Domain always is text, right?
		local result
		local mt = getmetatable(self)
		mt.__tostring = nil;
		if value == nil then
			result = tostring(self)
		else
			result = tostring(value)
		end
		mt.__tostring = getdomain
		return true, result
	end;
	filemap = function(self, value, key, mt) -- Accept only tables
		if type(value) == 'table' then
			local correct = {}
			local i = 1;
			for k,v in pairs(value) do
				local lang = self.typemap[k];
				correct[i] = {lang = lang, file = v}
				correct[lang] = v
				i = i + 1
			end
			table.sort(correct, function(a, b) return tostring(a.lang) < tostring(b.lang) end)
			correct.i = 0;
			rawset(mt, key, correct)
			self.lang = nil
			return false
		elseif value == nil then
			self[key] = {}
			return false
		else
			return nil, nil, 'Invalid filemap'
		end
	end;
	lang = function(self, lang, key, mt) -- Convert language and update data
		rawset(mt, key, self.typemap[lang])
		return false, self:langUpdate()
	end;
	prefix = function(self, value, key, mt) -- Prefix, 'locale' for example
		local _, str = pcall(tostring, value)
		if type(str) == 'string' or value == nil then
			local res
			if value == nil then
				res = nil
			else
				res = str
			end
			rawset(mt, key, res)
			return false, self:langUpdate()
		else
			return nil, nil, 'Non-string prefix'
		end
	end
};

if cc then
	local fnam = function(name) -- Use "lang" by default
		if name == nil then name = "lang" end
		return name
	end
	lib.CCLangDefault = function(self) -- Set language to default
		self.lang = cc.Application:getInstance():getCurrentLanguage() - 1
	end
	lib.CCLangLoad = function(self, name) -- Load language from UserDefault
		local empty = 'none'
		local lang = cc.UserDefault:getInstance():getStringForKey(tostring(fnam(name)) , empty)
		if lang ~= empty then
			self.lang = lang
		else
			self:CCLangDefault()
		end
	end
	lib.CCLangSave = function(self, name) -- Save language to UserDefault
		cc.UserDefault:getInstance():setStringForKey(tostring(fnam(name)) , self:getLangStr())
	end
else
	local dummy = function()
		print('Warning: `cc` module is unaviable, using dummy')
	end
	lib.CCLangDefault = dummy
	lib.CCLangLoad = dummy
	lib.CCLangSave = dummy
end

lib.getLangStr = function(self) -- You can use result string for saving and resuming language
	local lang = self.lang
	if lang ~= nil then
		return tostring(lang)
	else
		return "en-en" -- Okay, okay
	end
end

lib.langUpdate = function(self) -- Reload language
	i18n.removeMO(self)
	if self.lang then
		local file = self.filemap[self.lang]
		if file then
			local path = ''
			if self.prefix then
				path = self.prefix..'/'..file
			else
				path = file
			end
			if checkFile(path) then
				return i18n.addMO(path, self)
			end
		end
	end
	return true
end

lib.next = function(self)
	local filemap = self.filemap;
	filemap.i = filemap.i+1
	local field = filemap[filemap.i]
	local lang
	if field then
		lang = field.lang
	else
		filemap.i = 0
	end
	self.lang = lang
	return lang
end

lib.cleanup = function(self)
	i18n.removeMO(self)
end

lib.ctor = function(self, domain, prefix)
	self.domain = domain
	self.lang = nil
	self.prefix = prefix
	self.filemap = nil
end

local newInstance = function(_, ...)
	local mt = {}
	mt.__newindex = function(self, key, value)
		local upd, err
		if fields_allowed[key] then
			if type(fields_allowed[key]) == 'function' then
				upd, value, err = fields_allowed[key](self, value, key, mt)
				if err then error(err, 2) end
			else
				upd = true
			end
		else
			error("Access to invalid field", 2)
		end
		if upd then
			rawset(mt, key, value)
		end
	end;
	mt.__index = function(self, key)
		if fields_allowed[key] then
			return mt[key]
		else
			return lib[key]
		end
	end
	mt.__tostring = getdomain;
	mt.__gc = lib.cleanup;
	local instance = setmetatable({}, mt)
	instance:ctor(...)
	return instance
end

return setmetatable(static, {__call = newInstance})
