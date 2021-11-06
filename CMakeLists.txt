project(cfs_zen_tweaks)

cmake_minimum_required(VERSION 3.21)

find_program(M4 m4)

include(GNUInstallDirs)

set(SCRIPT_INSTALL_DIR "${CMAKE_INSTALL_FULL_LIBDIR}/cfs-zen-tweaks")

install(FILES script.sh
        DESTINATION "${SCRIPT_INSTALL_DIR}/"
)

configure_file("set-cfs-tweaks.service.in" "set-cfs-tweaks.service")

install(FILES "${CMAKE_BINARY_DIR}/set-cfs-tweaks.service"
        DESTINATION "${CMAKE_INSTALL_FULL_LIBDIR}/systemd/system"
)
