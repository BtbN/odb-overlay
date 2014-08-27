# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit base versionator

DESCRIPTION="Codesynthesis' ODB compiler examples"
HOMEPAGE="http://www.codesynthesis.com/projects/odb"

MY_V=$(get_version_component_range 1-2)
MY_URL_REL=http://www.codesynthesis.com/download/odb/${MY_V}
MY_URL_PRE=http://codesynthesis.com/~boris/tmp/odb/pre-release

MY_A=${P/_pre/.a}

test "${MY_A}" == "${P}" && MY_URL=${MY_URL_REL} || MY_URL=${MY_URL_PRE}

SRC_URI=${MY_URL}/${MY_A}.tar.bz2

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"

RESTRICT=test

src_unpack() {
	unpack ${A}
	if test "${MY_A}" != "${P}"; then
		mv "${WORKDIR}/${MY_A}" "${S}" || die
	fi
}

src_configure() {
	true
}

src_compile() {
	true
}

src_install() {
	local docs=usr/share/doc/${PF/-examples/}/examples
	local dest=${ED}/${docs}

	mkdir -p "${dest}" || die
	cp -a "${S}"/* "${dest}" || die

	# GPLv2 already in /usr/portage/licenses
	# User should not install
	# LICENSE: hints to Codesyntheis license policy may persist
	rm -f ${dest}/{INSTALL,GPLv2}

	docompress -x "${docs}"

	dodir "${docs}"
	find  "${dest}" '(' -regex 	   '.+proj$'\
						-or -regex '.+[.]filters'\
						-or -regex '.+[.]bat'\
						-or -regex '.+[.]sln' ')' -exec rm '{}' ';'
	einfo  "Microsoft related project files removed from examples"
}
# vim: ts=4:sw=4:
# hint: to get vi settings work, try "set modeline" >> ~/.vimrc
