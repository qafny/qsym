#!/bin/sh

# Profiling output will be written to the file QSym.prof

cabal exec QSym -- +RTS -pa
