#!/bin/bash
if [[ "${CI}" == "true" ]]; then
    if [[ "${TRAVIS}" == "true" ]]; then
        echo "** Define the CXX17 flag for R"
        mkdir -p ~/.R
        echo 'CXX17 = g++-7 -std=gnu++17 -fPIC -shared -Wall -g -O2' > ~/.R/Makevars
    fi
fi