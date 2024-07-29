
find_package(ECM 1.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Qml Quick)

include(KDEInstallDirs)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)

#set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -fexceptions")

add_library(lliurexlocaleplugin SHARED plugin.cpp)

target_link_libraries (lliurexlocaleplugin
    Qt6::Qml
    Qt6::Quick
)

install (TARGETS lliurexlocaleplugin DESTINATION ${KDE_INSTALL_QMLDIR}/net/lliurex/locale)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/net/lliurex/locale)
