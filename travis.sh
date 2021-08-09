#!/bin/bash
if [[ "${CI}" == "true" ]]; then
    if [[ "${TRAVIS}" == "true" ]]; then
        echo "** Overriding src/Makevars and removing C++14 on Travis only"
        sed -i 's|CXX_STD = CXX17||' src/Makevars
        echo 'CXX17 = g++-7 -std=gnu++17 -fPIC' > src/Makevars
    fi
fi