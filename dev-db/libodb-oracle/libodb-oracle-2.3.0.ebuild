# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils versionator

MY_V="$(get_version_component_range 1-2)"

DESCRIPTION="Codesynthesis' ODB runtime for accessing an Oracle SQL database"
HOMEPAGE="http://www.codesynthesis.com/projects"
SRC_URI="http://www.codesynthesis.com/download/odb/${MY_V}/${P}.tar.bz2"
LICENSE="|| ( GPL-2 ODB-FPL ODB-CPL ODB-NCUEL )"

SLOT="0"
KEYWORDS="~amd64"
IUSE="doc static-libs threads"

DEPEND="=dev-db/libodb-${MY_V}*[static-libs?,threads=]
		 dev-db/oracle-instantclient-sqlplus
		 dev-db/unixODBC[static-libs?]"
RDEPEND="${DEPEND}"

RESTRICT="test"

src_configure() {
	myeconfargs=(
		--docdir="${T}"
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
