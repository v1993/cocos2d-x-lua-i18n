set -eufo pipefail

I18N_DIR=I18N

git clone https://github.com/kaishiqi/I18N-Gettext-Supported.git $I18N_DIR

echo "${I18N_DIR}/I18NTest_lua/i18n" "$MYLUALIBS"

cp -r "${I18N_DIR}/I18NTest_lua/i18n" "$MYLUALIBS"
