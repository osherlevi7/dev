#!/bin/bash
# Trigger an error if non-zero exit code is encountered
set +e
# Modify the environment
export FOO="Baz"
# Decide what is to replace this process
if [ "${1}" == "serve" ]; then
    # This is the primary target
    shift # consume the 1st argument
    cd src
    npm install --force && npm run build && npm start
else
    # An unknown command (debugging the container?): Forward as is
    exec ${@}
fi