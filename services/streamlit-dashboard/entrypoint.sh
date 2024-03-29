#!/bin/bash

# Trigger an error if non-zero exit code is encountered
set -eo pipefail

# Modify the environment
export FOO="Baz"

# Decide what is to replace this process
if [ "${1}" == "serve" ]; then
    # This is the primary target
    shift # consume the 1st argument
    exec python -m streamlit run --server.enableCORS false --server.enableXsrfProtection true main.py ${@}
else
    # An unknown command (debugging the container?): Forward as is
    exec ${@}
fi
