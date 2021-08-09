#!/bin/bash
if [[ "${CI}" == "true" ]]; then
    if [[ "${TRAVIS}" == "true" ]]; then
        echo "** Overriding src/Makevars and removing C++14 on Travis only"
        mkdir -p ~/.R
        echo 'CXX17 = g++-7 -std=gnu++17 -fPIC' > ~/.R/Makevars
    fi
fi