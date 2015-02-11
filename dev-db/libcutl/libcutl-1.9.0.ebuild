# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils versionator

DESCRIPTION="C++ utility library internally needed for Codesynthesis' tools"
HOMEPAGE="http://www.codesynthesis.com/projects/libcutl"
SRC_URI="http://www.codesynthesis.com/download/libcutl/$(get_version_component_range 1-2)/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc static-libs threads boost"

DEPEND="boost? ( dev-libs/boost[static-libs?,threads?] )"
RDEPEND="${DEPEND}"

RESTRICT="test"

src_configure() {
	local myeconfargs=(
		--docdir="${T}"
	    $(use_with boost external-boost)
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
