# Standarts
This library use tables from `i18n.langMap` as main language type (I will call it just `langt` above), `nil` means english.  
This library also make some changes of native libary, read about them [here](#notes)

# Structure
* cocos-i18n
  * [`typemap`](#typemap) (converter)
  * [`()`](#constructor) (constructor)
    * [`typemap`](#typemap) (duplicate)
    * [Methods](#methods):
      * [`getLangStr`](#getlangstr) (store language id to string)
      * [`langUpdate`](#langupdate) (reload data from file)
      * [`next`](#next) (select next language (sorted by alphabet))
      * [`cleanup`](#cleanup) (prepare object for removing)
      * [Cocos-specific methods](#cocos-specific-methods)
        * [`CCLangDefault`](#cclangdefault) (Use system language (using `cc.Application:getInstance():getCurrentLanguage()`))
        * [`CCLangLoad`](#cclangload) (load language using `UserDefault`)
        * [`CCLangSave`](#cclangsave) (save language using `UserDefault`)
    * [Fields](#fields)
      * [`domain`](#domain) (domain under control)
      * [`filemap`](#filemap) (mapping between languages and files)
      * [`prefix`](#prefix) (prefix between all file names)
      * [`lang`](#lang) (current language)
      
# Documentation
## `typemap`
`typemap` is table for converting another language formats to `langt`.  
It can convert from:

* Native cocos `LangType` (**IMPORTANT**: DO NOT use `cc.Application:getInstance():getCurrentLanguage()` with it, use [`CCLangDefault`](#cclangdefault) instead)
* Text notation `ct-ln` and `ct_ln`. Also `xx` will be interpreted as `xx-xx`
* `"en-en"`, `"en_en"`, `"nil"` and  `""` (and `nil`, of couse) to `nil` (therefore, english)
* Native `langt` will be accepted

Often, you don't really need it, any value will be auto-converted.

## Constructor
	obj = cocos_i18n(domain, prefix)
Constructor accepts two arguments: `domain` and `prefix`  
If domain is `nil`, then adress of new instance will be used.  

## Methods
There is a list of all aviable methods, use `:` to call them:

	obj:method()
### `getLangStr`
	langstr = obj:getLangStr()
You can use this function for getting current language at most compatible format. General for saving and transferring.

### `next`
	newlang = obj:next()
Select next language (in alphabet order) and return it. Works correctly with non-configured objects.

### `langUpdate`
	assert(obj:langUpdate())
Reload language from file. You don't need it in most cases.

### `cleanup`
	lib:cleanup()
Clean up extra data, I can't guarantee correct working after this call.  
You should call it before unloading object

### Cocos-specific methods
This methods only prints warning in non-cocos programs, but really usable in cocos games

#### `CCLangDefault`
	obj:CCLangDefault()
Set language getten by `cc.Application:getInstance():getCurrentLanguage()`  
Note: you shold use this instead of raw equalization becouse `cc.Application:getInstance():getCurrentLanguage() == 1` but `cc.LANGUAGE_ENGLISH == 0` (if system language is english)

#### `CCLangLoad`
	obj:CCLangLoad(name)
Load language from field called `name` using `UserDefault` (`"lang"` by default). If field not found, use system language (see [`CCLangDefault`](#cclangdefault)).  
See also: [`CCLangSave`](#cclangsave), its pair.

#### `CCLangSave`
	obj:CCLangSave(name)
Save language to field called `name` using `UserDefault` (`"lang"` by default).  
See also: [`CCLangLoad`](#cclangload), its pair.

## Fields
You can give access only to these fields, otherwise error will be raised.  
*Warning*: not every field can be copied to another object, if you want it, use `rawset`.

### `domain`
	obj.domain = domainname
Set domain to be controlled.

	obj.domain = nil
	obj.domain = obj
Set `"table: 0x???????"` as domain, where `0x???????` is object's address

### `filemap`
	obj.filemap = {
		[i18n.zh_cn] = 'zh_Hans.mo',
		[i18n.zh_tw] = 'zh_Hant.mo',
		[i18n.ja_jp] = 'ja.mo',
		[i18n.ko_kr] = 'ko.mo',
		[i18n.fr_fr] = 'fr.mo',
		[i18n.de_de] = 'de.mo',
		[i18n.ru_ru] = 'ru.mo',
	}
Set mapping between files and languages, update language.  
*Note*: it sets language back to english.  
**Important: do NOT use this field as base for another objects.**

### `prefix`
	obj.prefix = prefix
Set prefix - path to all files.

### `lang`
	obj.lang = langid
Sets current language: converts `langid` to `langt`, updates field, calls [`langUpdate`](#langupdate).

# Notes
1. This library make some changes in base library: now `tostring()` applied to language code table returns language code.

	`tostring(i18n.langMap[lang]) == lang`
2. If `cocos` is aviable, then `FileUtils` will be used for file operations
3. This library can be used without cocos2d-x, in this case, dummy functions will be used instead of [cocos-specific methods](#cocos-specific-methods).
