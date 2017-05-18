export MYLUALIBS="$HOME/.lualibs"
export PATH=${PATH}:$HOME/.lua:$HOME/.local/bin:${TRAVIS_BUILD_DIR}/install/luarocks/bin
bash .travis/setup_lua.sh
eval `$HOME/.lua/luarocks path`
export LUA_PATH="$LUA_PATH;$MYLUALIBS/?.lua;$MYLUALIBS/?/init.lua"
