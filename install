#!/bin/bash

CONFIG="install.conf.json"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"
PYTHON_BIN="python"
[ $(which python2) ] && PYTHON_BIN="python2"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${BASEDIR}"
git submodule update --init --recursive ${DOTBOT_DIR}

${PYTHON_BIN} "${BASEDIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${BASEDIR}" -c "${CONFIG}" $@
