# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils versionator

MY_V="$(get_version_component_range 1-2)"

DESCRIPTION="C++ Object-Relational Mapping (ORM) implemented as a gcc plugin"
HOMEPAGE="http://www.codesynthesis.com/projects/odb"
SRC_URI="http://www.codesynthesis.com/download/odb/${MY_V}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="static-libs threads mysql postgres sqlite oracle qt boost doc"

DEPEND=">=sys-devel/gcc-4.5.0
	dev-db/libcutl[static-libs?,threads=,boost?]
	qt?       ( =dev-db/libodb-qt-${MY_V}*[static-libs=,threads=,doc?]     )
	boost?    ( =dev-db/libodb-boost-${MY_V}*[static-libs=,threads=,doc?]  )
	postgres? ( =dev-db/libodb-pgsql-${MY_V}*[static-libs=,threads=,doc?]  )
	sqlite?   ( =dev-db/libodb-sqlite-${MY_V}*[static-libs=,threads=,doc?] )
	mysql?    ( =dev-db/libodb-mysql-${MY_V}*[static-libs=,threads=,doc?]  )
	oracle?   ( =dev-db/libodb-oracle-${MY_V}*[static-libs=,threads=,doc?] )"
RDEPEND="${DEPEND}"

src_configure() {
	local docdir="/usr/share/doc/${PF}"
	local myeconfargs=(
			--docdir="${docdir}"
			--pdfdir="${docdir}/pdf"
			--htmldir="${docdir}/html"
			--psdir="${docdir}/ps"
			--disable-static
	)
	autotools-utils_src_configure
}
