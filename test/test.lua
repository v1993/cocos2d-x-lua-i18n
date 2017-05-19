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

do
	local s, obj = pcall(ci18n)
	if not s or not obj then
		error('Constructor failure: '..tostring(obj))
	end
	assert(pcall_m(obj, 'cleanup'))
end

local _ENV = TEST_CASE "converter"

local typemap = ci18n.typemap
local answer = i18n.langMap['ru-ru']

function test_strings()
	 assert_equal(answer, typemap['ru-ru'])
	 assert_equal(answer, typemap['ru_ru']) 
end

function test_english()
	assert_equal(nil, typemap['en-en'])
	assert_equal(nil, typemap['en_en'])
	assert_equal(nil, typemap['nil'])
	assert_equal(nil, typemap[''])
	assert_equal(nil, typemap[nil])
	assert_equal(nil, typemap[0])
end

function test_numbers()
	assert_equal(answer, typemap[6])
end

local _ENV = TEST_CASE "default"
local obj

function setup()
	obj = ci18n(i18n.D_DEFAULT, 'locale')
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

function test_base_filemap()
end

if not HAS_RUNNER then lunit.run() end
