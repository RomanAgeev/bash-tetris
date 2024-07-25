#!/bin/bash

my_path="$(dirname $BASH_SOURCE)"

# shellcheck source=/dev/null
source $my_path/valid_int.sh

# shellcheck source=/dev/null
source $my_path/array.sh

# shellcheck source=/dev/null
source $my_path/template.sh

# shellcheck source=/dev/null
source $my_path/class.sh

# shellcheck source=/dev/null
source $my_path/timestamp.sh

# shellcheck source=/dev/null
source $my_path/screen.sh

# shellcheck source=/dev/null
source $my_path/require.sh

# shellcheck source=/dev/null
source $my_path/constants.sh
