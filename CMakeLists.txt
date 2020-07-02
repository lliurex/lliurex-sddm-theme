cmake_minimum_required(VERSION 3.10)

project(lliurex-sddm)
add_subdirectory(noise-plugin)

install (DIRECTORY lliurex DESTINATION share/sddm/themes/)
install (FILES conf/80-lliurex.conf DESTINATION lib/sddm/sddm.conf.d/)
install (FILES sddm.service.d/10-lliurex-n4d.conf DESTINATION lib/systemd/system/)