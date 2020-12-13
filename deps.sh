#!/bin/bash -ex

# https://github.com/bluelabsio/records-mover/blob/v1.1.0/deps.sh

brew update && ( brew upgrade pyenv || true )
pyenv rehash  # needed if pyenv is updated

python_version=3.8.5
pyenv install -s "${python_version:?}"
pyenv virtualenv "${python_version:?}" with_op-"${python_version:?}" || true
pyenv local with_op-"${python_version:?}" mylibs

pip3 install --upgrade pip

pip3 install wheel

pip3 install -r requirements_dev.txt -e '.'
