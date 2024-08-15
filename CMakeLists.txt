cmake_minimum_required(VERSION 3.28)
project(yanxiang_X86_OS C)

set(CMAKE_C_STANDARD 99)

add_executable(yanxiang_X86_OS oskernel/init/main.c
        tools/fileinfo.cpp
        tools/fileinfo.h
        tools/floppy.cpp
        tools/floppy.h
        tools/common.h)
