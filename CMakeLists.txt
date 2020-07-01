cmake_minimum_required(VERSION 3.10)

project(lliurex-sddm)
add_subdirectory(noise-plugin)

install (DIRECTORY lliurex DESTINATION share/sddm/themes/)