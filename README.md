# Cocos2d-x lua internationalization helper
[![Build Status](https://travis-ci.org/v1993/cocos2d-x-lua-i18n.svg?branch=master)](https://travis-ci.org/v1993/cocos2d-x-lua-i18n)
[![codecov](https://codecov.io/gh/v1993/cocos2d-x-lua-i18n/branch/master/graph/badge.svg)](https://codecov.io/gh/v1993/cocos2d-x-lua-i18n)
[![License](http://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

**IMPORTANT: this libary need lua module from https://github.com/kaishiqi/I18N-Gettext-Supported. `require 'i18n'` should work.**

This library is only wrap around that, so you should read documentation to both libraries.

## Why do you need this wrap?

1. Language magement: you can set mapping between languages and files. Also, you can set prefix for all files.
2. Better interface: now you have got object-oriented metamethod-based API. There is no more tons of ugly methods.
3. Full cocos2d-x integration: functions for saving, loading and using system language is aviable.

## Documentation

See [DOCUMENTATION.md](DOCUMENTATION.md) for help.

## TODO list

1. [x] make auto-testing with Travis-ci
2. [ ] make manual-testing with Cocos2d-x
3. [ ] write examples
