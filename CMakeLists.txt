cmake_minimum_required(VERSION 3.10)
project(MultiApps)

# AI Apps (ChatServer)
message(STATUS "Building AI Apps ...")
include(${CMAKE_SOURCE_DIR}/AIAppsCMakeLists.txt)