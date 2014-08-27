# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools-utils versionator

DESCRIPTION="Codesynthesis' ODB common runtime library"
HOMEPAGE="http://www.codesynthesis.com/projects/odb"
SRC_URI="http://www.codesynthesis.com/download/odb/$(get_version_component_range 1-2)/${P}.tar.bz2"

LICENSE="|| ( GPL-2 ODB-FPL ODB-CPL )"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc static-libs threads"
RESTRICT="test"

src_configure() {
	myeconfargs=(
		--docdir="${T}"
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
