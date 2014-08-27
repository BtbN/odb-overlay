# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit autotools-utils versionator

DESCRIPTION="Codesynthesis' ODB runtime library for accessing PostgreSQL"
HOMEPAGE="http://www.codesynthesis.com/projects/odb"

MY_URL_REL=http://www.codesynthesis.com/download/odb
MY_URL_PRE=http://codesynthesis.com/~boris/tmp/odb/pre-release

MY_V=$(get_version_component_range 1-2)
MY_A=${P/_pre/.a}

test  "${MY_A}" == "${P}" \
	&& SRC_URI="${MY_URL_REL}/${MY_V}/${P}.tar.bz2"\
	|| SRC_URI="${MY_URL_PRE}/${MY_A}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="|| ( GPL-2 ODB-FPL ODB-CPL )"

SLOT="0"

KEYWORDS="~amd64"

IUSE="doc static-libs threads"

DEPEND="=dev-db/libodb-${MY_V}*[static-libs?,threads=]
		 dev-db/postgresql-base[threads?]"

RDEPEND="${DEPEND}"

RESTRICT=test

src_unpack() {
	unpack ${A}
	if  test "${P}" != "${MY_A}"; then
		mv "${WORKDIR}/${MY_A}" "${S}" || die
	fi
}

src_configure() {
	#--{en,dis}able-static is set by autotools-utils dependend on static-libs
	myeconfargs=(
		--docdir="${T}"
		$(use_enable threads)
	)
	autotools-utils_src_configure
}
# vim: ts=4:sw=4:
# hint: to get vi settings work, try "set modeline" >> ~/.vimrc
