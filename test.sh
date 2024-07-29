#!/bin/bash

set -uo pipefail

source ./stage.sh

clear

new_stage stage 10 60 50 30

render_stage stage
