# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2021  igo95862

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, version 2.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
cmake_policy(SET CMP0048 NEW)

project(cfs-zen-tweaks
        LANGUAGES NONE
        HOMEPAGE_URL "https://github.com/igo95862/cfs-zen-tweaks"
        DESCRIPTION "Tweak Linux kernel CFS scheduler for responsiveness"
        VERSION "1.2.0"
)

cmake_minimum_required(VERSION 3.21)

option(USE_SBIN "Use sbin location instead of lib. Mostly used for SELinux on fedora.")

if(USE_SBIN)
    set(SCRIPT_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/sbin")
else()
    set(SCRIPT_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/lib/cfs-zen-tweaks")
endif()

install(FILES set-cfs-zen-tweaks.sh
        DESTINATION "${SCRIPT_INSTALL_DIR}/"
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ WORLD_EXECUTE
)

configure_file("set-cfs-tweaks.service.in" "set-cfs-tweaks.service")

install(FILES "${CMAKE_BINARY_DIR}/set-cfs-tweaks.service"
        DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/systemd/system"
)

set(CPACK_GENERATOR "DEB;RPM")
set(CPACK_PACKAGE_NAME "cfs-zen-tweaks")
set(CPACK_PACKAGE_CONTACT "github.com/igo95862/cfs-zen-tweaks")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-2.0-only")

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "systemd, gawk")

set(CPACK_RPM_PACKAGE_ARCHITECTURE "noarch")
set(CPACK_RPM_PACKAGE_REQUIRES "systemd, gawk")
set(CPACK_RPM_PACKAGE_LICENSE "GPL-2.0-only")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION "/usr/sbin;/usr/lib/systemd;/usr/lib/systemd/system")

include(CPack)
