#!/bin/bash

rm -rf build
rm -rf release
rm -f translations/*.qm

rm -rf shared/rpm/BUILD/
rm -rf shared/rpm/BUILDROOT/
rm -rf shared/rpm/*RPMS/
rm -rf shared/rpm/SOURCES/
rm -f debug*.list
rm -f elfbins.list

find . -name CMakeFiles -exec rm -rf {} +
find . -name '*_autogen' -exec rm -rf {} +

find . -name cmake_install.cmake -delete
find . -name CMakeCache.txt -delete
find . -name Makefile -delete
