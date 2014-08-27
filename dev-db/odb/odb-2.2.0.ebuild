# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils versionator

DESCRIPTION="C++ Object-Relational Mapping (ORM) implemented as a gcc plugin"

HOMEPAGE="http://www.codesynthesis.com/projects/odb"

MY_URL_REL=http://www.codesynthesis.com/download/odb
MY_URL_PRE=http://codesynthesis.com/~boris/tmp/odb/pre-release

# pre-release tar archives contain directories with suffixes [.]a[1-9]
MY_A=${P/_pre/.a}

# depending on test use flag, odb-tests package with same version is needed
MY_AT=${MY_A/odb-/odb-tests-}

# this is where test sources get moved to
MY_PTS=${PF/odb-/odb-tests-}

test "${MY_A}" == "${P}" && MY_URL=${MY_URL_REL} || MY_URL=${MY_URL_PRE}

MY_V=$(get_version_component_range 1-2)

SRC_URI="${MY_URL}/${MY_V}/${MY_A}.tar.bz2
		 test? ( ${MY_URL}/${MY_V}/${MY_AT}.tar.bz2 )"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~amd64"

IUSE="static-libs threads mysql postgres sqlite
	  mssql oracle qt boost doc examples test"

REQUIRED_USE="test? ( || ( sqlite postgres mysql mssql oracle ) )"

# The dependency on the same state of use flags are not neccessary
# for compiling odb, but are meant for achieving consistency
# as seen from the user point of view.
# -- dev-libs/gmp[static-libs?,cxx(+)] is a dependency introduced
#    by gcc and should therfore be already handled.
DEPEND=">=sys-devel/gcc-4.5.0
	dev-db/libcutl[static-libs?,threads=,boost?]
	qt?       ( =dev-db/libodb-qt-${MY_V}*[static-libs=,threads=,doc?]     )
	boost?    ( =dev-db/libodb-boost-${MY_V}*[static-libs=,threads=,doc?]  )
	postgres? ( =dev-db/libodb-pgsql-${MY_V}*[static-libs=,threads=,doc?]  )
	sqlite?   ( =dev-db/libodb-sqlite-${MY_V}*[static-libs=,threads=,doc?] )
	mysql?    ( =dev-db/libodb-mysql-${MY_V}*[static-libs=,threads=,doc?]  )
	mssql?    ( =dev-db/libodb-mssql-${MY_V}*[static-libs=,threads=,doc?]  )
	oracle?   ( =dev-db/libodb-oracle-${MY_V}*[static-libs=,threads=,doc?] )
	examples? ( =dev-db/odb-examples-${MY_V}*                              )
	"
RDEPEND=${DEPEND}

# list of testing targets (DBS: database systems)
MY_DBS=$(echo $(usev sqlite;usev postgres;usev mysql;usev mssql;usev oracle))

# PostgreSQL parameters accepted by odb-tests/configure: --with-pgsql-.+
MY_DBS=${MY_DBS/postgres/pgsql}

# database backend tests listed here will get compiled, but not run
# This can be passed on the command line much like EXTRA_ECONF
# MY_OFFLINE=${MY_OFFLINE:-oracle mssql}

# odb-tests/configure knows postgres related flags as --with-pgsql.*
MY_OFFLINE=${MY_OFFLINE/postgres/pgsql}

src_unpack() {
	unpack ${A}
	if test "${WORKDIR}/${MY_A}" != "${S}"; then
	   mv "${WORKDIR}/${MY_A}" "${S}" || die
	fi
	use test || return 0
	mv "${WORKDIR}/${MY_AT}" "${S}/odb-tests" || die
}

src_prepare() {
	if use test; then
		PATCHES=("${FILESDIR}/${PF}"-add-test-subdir.patch
				 "${FILESDIR}/${PF}"-odb-tests-dont-test-for-not-yet-existing-odb.patch
		)
		AUTOTOOLS_AUTORECONF=1 autotools-utils_src_prepare
	else
		autotools-utils_src_prepare
	fi
}

src_configure() {
:	#--{en,dis}able-static passed by autotools-utils
	# but --enable-static is a workaround for platforms without plugin support
	local docdir=/usr/share/doc/${PF}
	myeconfargs=(
			--docdir="${docdir}"\
			--pdfdir="${docdir}/pdf"\
			--htmldir="${docdir}/html"\
			--psdir="${docdir}/ps"
			--disable-static
	)
	# odb-tests' configure needs to know where odb executable is built, so
	# set BUILD_DIR here explicitly, even if the value matches the default
	BUILD_DIR="${S}_build" autotools-utils_src_configure
	use test || return 0

	# run configure in a separate build directory specific for each db backend
	# --with-pgsql-host: if omitted the client will try to connect using a
	#                    socket in /var/postgres, but subsequently fails
	#                    since user may 'portage' lack access rights for this
	#                    directory. ( This is in turn determined by having
	#                    'userpriv' in FEATURES, I believe.) EXTRA_ECONF may
	#                    finally overwrite this option

	for db in ${MY_DBS}; do
		local b="${WORKDIR}/${MY_PTS}-${db}_build"
		elog "configuring test sources for '${db}' in '$(basename ${b})'"
		myeconfargs=(
		  --with-database="${db}"
		  --with-odb="${S}_build"
		  $(use_enable threads)
		  $(test "${db}" == 'pgsql' && echo "--with-pgsql-host=localhost")
		)
		ECONF_SOURCE="${S}/odb-tests" BUILD_DIR="${b}"\
		autotools-utils_src_configure
	done
}

src_compile() {
	BUILD_DIR="${S}_build" autotools-utils_src_compile
	use test || return 0
	for db in ${MY_DBS}; do
	   BUILD_DIR="${WORKDIR}/${MY_PTS}-${db}_build" autotools-utils_src_compile
	done
}

src_test() {
	einfo ">>> Test phase [check]: ${CATEGORY}/${PF}"

	array() {
		for i in ${@}; do printf '[%q]=%q\n' "${i}" "${i}"; done
	}

	# convert the flat list of database backends not to be tested
	# online into an associative array of tests names
	# for running the related test later under control of the 
	# nonfatal helper -- e.g. ( [oracle]=oracle [mssql]=msql )
	eval "local -A nf=($(array ${MY_OFFLINE}))"

	local off="ignored as requested by MY_OFFLINE = '${MY_OFFLINE}'"

	for db in ${MY_DBS}; do
		local b="${WORKDIR}/${MY_PTS}-${db}_build"
		local t="${T}/test-of-$(basename ${b})-complete"

		# long compile time: hence I need this test while developing the ebuild
		test -f "${t}" && echo "'${b}' exists, skipping test ..." && continue

		case ${db} in
			  ${nf[${db}]}) # <- evaluates to '' or any entry in $MY_OFFLINE
					BUILD_DIR="${b}" nonfatal autotools-utils_src_test
					ewarn "Test result for '${db/pgsql/postgres}' ${off}"
					;;
			  *) 	BUILD_DIR="${b}" autotools-utils_src_test
					;;
		esac
		touch "${t}" || die
	done
}

src_install() {
	BUILD_DIR="${S}_build" autotools-utils_src_install
	if use doc; then
		docompress -x "usr/share/doc/${PF}/html" "usr/share/doc/${PF}/pdf"
		rm "${ED}/usr/share/doc/${PF}"/{GPLv3,version} || die
	else
		rm -r "${ED}/usr/share/doc/${PF}" || die
	fi
}

# Just check if database credentials have been passed in EXTRA_ECONF.
# Except for sqlite, running the lengthy test options will almost
# certainly fail due to the 'odb_test' database and/or the 'odb_test'
# user not being configured. So check beforehand if any database
# related parameters have been passed via EXTRA_ECONF. If not,
# show some database specific help and die

pkg_pretend() {
	use test || return 0

	econf_help() {
	grep "${1}"<<EOF
	--with-mysql-db=NAME		MySQL database name      (database 'test' may exist)
	--with-mysql-user=NAME		MySQL database user      (user 'test' may exist)
	--with-mysql-password=PASS	MySQL database password  (not needed for user 'test')
	--with-mysql-host=HOST		MySQL database host      (localhost by default)
	--with-mysql-port=PORT		MySQL database port      (standard port by default)
	--with-mysql-socket=SOCKET	MySQL unix socket        (may be used instead of host)
	--with-pgsql-db=NAME		PostgreSQL database name
	--with-pgsql-user=NAME		PostgreSQL database user
	--with-pgsql-password=NAME	PostgreSQL db password
	--with-pgsql-port=PORT		PostgreSQL database port (standard PostgreSQL port by default)
	--with-pgsql-host=HOST		PostgreSQL database host (localhost by default)
	--with-oracle-service=NAME	Service name in /etc/oracle/tnsnames.ora
	--with-oracle-user=NAME		Oracle database user     (always needed)
	--with-oracle-password=PASS	Oracle database password (always needed)
	--with-oracle-host=HOST		Oracle database host     (localhost by default)
	--with-oracle-port=PORT		Oracle database port     (standard port by default)
	--with-mssql-db=NAME		SQL Server database name
	--with-mssql-user=NAME		SQL Server database user
	--with-mssql-password=PASS	SQL Server database password
	--with-mssql-server=ADDR	SQL Server database host
	--with-mssql-driver=NAME	Driver name in /etc/unixODBC/odbcinst.ini
EOF
	}

	einfo ">>> pretend phase [check]: ${CATEGORY}/${PF}"

	# Funny: vi, being more catholic than repoman itself, switches to
	# red alert mode when recognizing occurences of EXTRA_ECONF.

	local extnm='EXTRA_ECONF'
	local extra=${EXTRA_ECONF}
	local msg="None of the following odb-tests-${PV}/configure script "
		  msg+="parameters found in '${extnm}':"
	local need=''

	for db in ${MY_DBS}; do
		elog "Test of '${db}' backend requested"
		# in contrast to other dbs, sqlite needs no credentials being set
		test "${db}" == 'sqlite' && continue

		ebegin "Checking if '--with-${db}-.*' parameters exist in '${extnm}'"

		if  test "${extra/--with-${db}-/}" == "${extra}"; then
			need+="${db} "; eend $((1)) "${msg}"; econf_help "${db}"
			continue
		fi
		eend $((0))
	done

	if test -n "${need}"; then
		local dmsg="configuration parameters for '${need}' not given. Please "
		     dmsg+="specify sensible parameters.\n  ${extnm} = '${extra}'"
		die "${dmsg}"
	fi

	local offline=${MY_OFFLINE/pgsql/postgres}
	local offmsg="as requested by MY_OFFLINE='${offline}'."

	for db in ${offline}; do
		elog "Result of run-time test for '${db}' will be ignored ${offmsg}"
	done

}
# vim: ts=4:sw=4:
# hint: to get vi settings work, try "set modeline" >> ~/.vimrc
