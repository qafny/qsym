#!/bin/sh

cabal test --test-show-detail=streaming --enable-profiling --profiling-detail=all-functions "$@"
