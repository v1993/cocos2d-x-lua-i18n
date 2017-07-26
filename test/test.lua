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

local function pset(tab, key, val) -- protected set
	return pcall(function() tab[key] = val end)
end

do -- Base test
	local s, obj = pcall(ci18n)
	if not s or not obj then
		error('Constructor failure: '..tostring(obj))
	end
	assert(pcall_m(obj, 'cleanup'))
end

local obj

local function base_filemap(assert_equal)
	return function()
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
end

local function prefix_filemap(assert_equal)
	return function()
		local map1 = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
		}
		local map2 = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
		}
		local prefix1 = 'locale'
		local prefix2 = 'locale1'
		obj.filemap = map1
		obj.prefix = prefix1
		local ctab = {nextdir = function(self) self.prefix = prefix2; self.filemap = map2 end, onlang = function(self, dir, lang) self.lang = lang end, test = assert_equal}
		trtest.test_all(obj, ctab)
	end
end

local function base_next_filemap(assert_equal)
	return function()
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
		local ctab = {nextdir = function(self) self.filemap = map2 end, nextlang = function(self) self:next() end, test = assert_equal}
		trtest.test_all(obj, ctab)
	end
end

local function prefix_next_filemap(assert_equal)
	return function()
		local map1 = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
		}
		local map2 = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
		}
		local prefix1 = 'locale'
		local prefix2 = 'locale1'
		obj.filemap = map1
		obj.prefix = prefix1
		local ctab = {nextdir = function(self) self.prefix = prefix2; self.filemap = map2 end, nextlang = function(self) self:next() end, test = assert_equal}
		trtest.test_all(obj, ctab)
	end
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

local _ENV = TEST_CASE "default domain"

function setup()
	obj = ci18n(i18n.D_DEFAULT)
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

test_base_filemap = base_filemap(assert_equal)
test_filemap_with_prefix = prefix_filemap(assert_equal)
test_base_filemap_with_next = base_next_filemap(assert_equal)
test_prefix_next_filemap = prefix_next_filemap(assert_equal)

local _ENV = TEST_CASE "prefix setup"

function setup()
	obj = ci18n(i18n.D_DEFAULT, 'locale')
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

function test_start_prefix()
	obj.filemap  = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
	}
	trtest.test_dir(obj, 'locale', {onlang = function(self, dir, lang) self.lang = lang end, test = assert_equal})
end

function test_start_prefix_with_next()
	obj.filemap  = {
			ru = 'ru.mo',
			pl = 'pl.mo',
			zh_cn = 'zh-cn.mo'
	}
	trtest.test_dir(obj, 'locale', {nextlang = function(self, dir, lang) self:next() end, test = assert_equal})
end

local _ENV = TEST_CASE "address-based domain"

function setup()
	obj = ci18n()
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

test_base_filemap = base_filemap(assert_equal)
test_filemap_with_prefix = prefix_filemap(assert_equal)
test_base_filemap_with_next = base_next_filemap(assert_equal)
test_prefix_next_filemap = prefix_next_filemap(assert_equal)

local _ENV = TEST_CASE "dummies"

function setup()
	obj = ci18n()
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

function test_CCLangDefault()
	assert_true(pcall_m(obj, 'CCLangDefault'))
end

function test_CCLangLoad()
	assert_true(pcall_m(obj, 'CCLangLoad'))
end

function test_CCLangSave()
	assert_true(pcall_m(obj, 'CCLangSave'))
end

local _ENV = TEST_CASE "getLangStr"

function setup()
	obj = ci18n()
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

function test_valid()
	obj.lang = 'ru'
	assert_equal('ru-ru', obj:getLangStr())
end

function test_english()
	obj.lang = 'en'
	assert_equal('en-en', obj:getLangStr())
end

function test_default()
	assert_equal('en-en', obj:getLangStr())
end

local _ENV = TEST_CASE "fails"

function setup()
	obj = ci18n()
end

function teardown()
	assert_true(pcall_m(obj, 'cleanup'))
end

function test_no_file()
	obj.filemap = {ru = 'abcde.fgh'}
	obj.lang = 'ru'
	trtest.test_english(obj, assert_equal)
end

function test_bad_prefix()
	assert_false(pset(obj, 'prefix', {}))
	assert_false(pset(obj, 'prefix', 0))
	assert_false(pset(obj, 'prefix', io.stdin))
end

function test_bad_filemap()
	assert_false(pset(obj, 'filemap', 0))
	assert_false(pset(obj, 'filemap', ''))
	assert_false(pset(obj, 'filemap', io.stdin))
end

function test_bad_field()
	assert_false(pset(obj, 'abc', 0))
	assert_false(pset(obj, nil, ''))
	assert_false(pset(obj, 0, io.stdin))
	assert_false(pset(obj, io.stdin, {}))
end

if not HAS_RUNNER then lunit.run() end
