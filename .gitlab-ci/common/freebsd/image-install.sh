#!/usr/bin/env bash

set -e

# note: really wanna install to /usr/local, since that's explicitly searched first,
# so we always catch the locally installed before any system/ports provided one
# otherwise we might run into trouble like trying to use outdated xorgproto
build_autoconf() {
    local subdir="$1"
    shift
    (
        cd $subdir
        ./autogen.sh --prefix=/usr/local "$@"
        make -j${FDO_CI_CONCURRENT:-4}
        make -j${FDO_CI_CONCURRENT:-4} install
    )
}

build_meson() {
    local subdir="$1"
    shift
    (
        cd $subdir
        meson _build -Dprefix=/usr/local "$@"
        ninja -C _build -j${FDO_CI_CONCURRENT:-4} install
    )
}

do_clone() {
    git clone "$1" --depth 1 --branch="$2"
}

gpart recover ada0
gpart resize -i 4 ada0
growfs /

cp .gitlab-ci/common/freebsd/FreeBSD.conf /etc/pkg

pkg upgrade -f -y

pkg install -y \
    git gcc pkgconf autoconf automake libtool xorg-macros xorgproto meson \
    ninja pixman xtrans libXau libXdmcp libXfont libXfont2 libxkbfile libxcvt \
    libpciaccess font-util libepoll-shim libdrm mesa-libs libdrm libglu mesa-dri \
    libepoxy nettle xkbcomp libXvMC xcb-util valgrind libXcursor libXScrnSaver \
    libXinerama libXtst evdev-proto libevdev libmtdev libinput spice-protocol \
    libspice-server

[ -f /bin/bash ] || ln -sf /usr/local/bin/bash /bin/bash

echo "=== post-install script END"
