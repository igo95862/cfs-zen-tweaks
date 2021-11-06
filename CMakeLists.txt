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

set(CPACK_GENERATOR "DEB;RPM")
set(CPACK_PACKAGE_NAME "cfs-zen-tweaks")
set(CPACK_PACKAGE_CONTACT "github.com/igo95862/cfs-zen-tweaks")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "0")
set(CPACK_PACKAGE_VERSION_PATCH "0")

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "any")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "bash, systemd, gawk")

set(CPACK_RPM_PACKAGE_ARCHITECTURE "noarch")
set(CPACK_RPM_PACKAGE_REQUIRES "bash, systemd, gawk")

include(CPack)
