#!/bin/bash

set -eou pipefail

pushd kubespray

python3 -m venv .venv

. .venv/bin/activate

python3 -m pip install wheel

python3 -m pip install -r requirements.txt
