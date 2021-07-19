cmake_minimum_required(VERSION 3.10)

project(lliurex-sddm)
add_subdirectory(noise-plugin)
add_subdirectory(locale-plugin)

install (DIRECTORY lliurex DESTINATION share/sddm/themes/)
install (DIRECTORY lliurex-live DESTINATION share/sddm/themes/)
install (FILES conf/80-lliurex.conf DESTINATION lib/sddm/sddm.conf.d/)
install (FILES sddm.service.d/10-lliurex-n4d.conf DESTINATION lib/systemd/system/sddm.service.d)

add_custom_target(
    po
    COMMAND xgettext -kde -ki18nd:2 ${CMAKE_CURRENT_SOURCE_DIR}/lliurex/*.qml ${CMAKE_CURRENT_SOURCE_DIR}/lliurex/ui/*.qml -o ${CMAKE_CURRENT_SOURCE_DIR}/messages.po
    COMMENT "extracting po..." 
)

set(langs es ca@valencia)
find_package(Intl)
find_package(Gettext)

foreach(lang ${langs})
    gettext_process_po_files(${lang} ALL PO_FILES locale/${lang}.po)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${lang}.gmo DESTINATION
            share/locale/${lang}/LC_MESSAGES/ RENAME lliurex-sddm-theme.mo)
endforeach()
