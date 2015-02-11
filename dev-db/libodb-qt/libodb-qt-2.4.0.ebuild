# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils versionator

MY_V="$(get_version_component_range 1-2)"

DESCRIPTION="Codesynthesis' ODB Qt support library."
HOMEPAGE="http://www.codesynthesis.com/projects/odb"
SRC_URI="http://www.codesynthesis.com/download/odb/${MY_V}/${P}.tar.bz2"

LICENSE="|| ( GPL-2 ODB-FPL ODB-CPL )"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc static-libs threads qt5"

RDEPEND="=dev-db/libodb-${MY_V}*[static-libs?,threads=]
	!qt5? ( dev-qt/qtcore:4 )
	qt5? ( dev-qt/qtcore:5 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

RESTRICT="test"

src_prepare() {
	local _pkg="$(use qt5 && echo Qt5Core || echo QtCore)"

	sed -i 's/libqt_lib_names=".*"/libqt_lib_names=""/g' m4/libqt.m4 || die "sed failed"
	sed -i 's/libqt_pkg_names=".*"/libqt_pkg_names="'"${_pkg}"'"/g' m4/libqt.m4 || die "sed failed"

	eautoreconf
}

src_configure() {
	myeconfargs=(
		--docdir="${T}"
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
