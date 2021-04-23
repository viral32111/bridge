#!/bin/bash

g++ -Wall -o bridge.o -c bridge/bridge.cpp
g++ -Wall -Ibridge -o alice.o -c testing/alice.cpp
g++ -Wall bridge.o alice.o -o alice
rm -f bridge.o alice.o
