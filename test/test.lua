scanning = true
pcall(require, "luacov")


print("------------------------------------")
print("Lua version: " .. (jit and jit.version or _VERSION))
print("------------------------------------")
print("")

local HAS_RUNNER = not not lunit
local lunit = require "lunit"
local TEST_CASE = lunit.TEST_CASE

local ci18n = require 'cocos-i18n'
local function pcall_m(...)
	local arg = {...};
	return pcall(arg[1][arg[2]], arg[1], select(3, ...));
end

local trtest = require 'translate_test'

local function pget(tab, key) -- protected get
	return pcall(function() return tab[key] end)
end

do -- Base test
	local s, obj = pcall(ci18n)
	if not s or not obj then
		error('Constructor failure: '..tostring(obj))
	end
	assert(pcall_m(obj, 'cleanup'))
end

local _ENV = TEST_CASE "converter"

local typemap = ci18n.typemap
local answer = i18n.langMap['ru-ru']

function test_numbers() -- Test LangType from cocos
	assert_equal(answer, typemap[6])
end

function test_strings() -- Test string notation
	 assert_equal(answer, typemap['ru-ru'])
	 assert_equal(answer, typemap['ru_ru'])
	 assert_equal(answer, typemap['ru'])
end

function test_english() -- Test everything, that mean english (nil in `langt`)
	assert_equal(nil, typemap['en-en'])
	assert_equal(nil, typemap['en_en'])
	assert_equal(nil, typemap['en'])
	assert_equal(nil, typemap['nil'])
	assert_equal(nil, typemap[''])
	assert_equal(nil, typemap[nil])
	assert_equal(nil, typemap[0])
end

function test_langt() -- Test raw accepting
	assert_equal(answer, typemap[answer])
end

function test_failure() -- All this requests should fail
	assert_false(pget(typemap, {}))
	assert_false(pget(typemap, -1))
	assert_false(pget(typemap, 100500)) -- Стопицот! (Russian mem)
	assert_false(pget(typemap, 'ujygfj'))
	assert_false(pget(typemap, 'retretgtf-jhncfy'))
	assert_false(pget(typemap, io.stdin)) -- Test with userdata
end

local _ENV = TEST_CASE "default"
local obj

function setup()
	obj = ci18n(i18n.D_DEFAULT)
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

local function trace (event)
	local s = debug.getinfo(2).short_src
	print(s)
end

function test_base_filemap()
	local map1 = {
		ru = 'locale/ru.mo',
		pl = 'locale/pl.mo',
		zh_cn = 'locale/zh-cn.mo'
	}
	local map2 = {
		ru = 'locale1/ru.mo',
		pl = 'locale1/pl.mo',
		zh_cn = 'locale1/zh-cn.mo'
	}
	obj.filemap = map1
	local ctab = {nextdir = function(self) self.filemap = map2 end, onlang = function(self, dir, lang) self.lang = lang end, test = assert_equal}
	trtest.test_all(obj, ctab)
end

if not HAS_RUNNER then lunit.run() end
