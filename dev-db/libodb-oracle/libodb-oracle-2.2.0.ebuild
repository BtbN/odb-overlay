# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools-utils versionator

DESCRIPTION="Codesynthesis' ODB runtime for accessing an Oracle SQL database"

HOMEPAGE="http://www.codesynthesis.com/projects"

MY_URL_REL=http://www.codesynthesis.com/download/odb
MY_URL_PRE=http://codesynthesis.com/~boris/tmp/odb/pre-release

MY_V=$(get_version_component_range 1-2)
MY_A=${P/_pre/.a}

test  "${MY_A}" == "${P}" \
	&& SRC_URI="${MY_URL_REL}/${MY_V}/${P}.tar.bz2"\
	|| SRC_URI="${MY_URL_PRE}/${MY_A}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="|| ( GPL-2 ODB-FPL ODB-CPL ODB-NCUEL )"

SLOT="0"

KEYWORDS="~amd64"

IUSE="doc static-libs threads"

DEPEND="=dev-db/libodb-${MY_V}*[static-libs?,threads=]
		 dev-db/oracle-instantclient-sqlplus
		 dev-db/unixODBC[static-libs?]"

RDEPEND="${DEPEND}"

RESTRICT=test

src_unpack() {
	unpack ${A}
	if  test "${MY_A}" != "${P}"; then
		mv "${WORKDIR}/${MY_A}" "${S}" || die
	fi
}

src_configure() {
	einfo "please see http://codesynthesis.com/products/odb/license.xhtml"
	#--{en,dis}able-static is set by autotools-utils dependend on static-libs
	myeconfargs=(
		--docdir="${T}"
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
# vim: ts=4:sw=4:
# hint: to get vi settings work, try "set modeline" >> ~/.vimrc
