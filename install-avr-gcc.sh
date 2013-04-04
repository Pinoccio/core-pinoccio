#!/bin/bash

#
# install_avr_gcc.sh, avr-gcc build and installation script
# Last updated: 2012/11/06
#
# run this script with "sh ./install_avr_gcc.sh"
#
# The default installation target is /usr/local/avr. If you don't
# have the necessary rights to create files there you may change
# the installation target to e.g. $HOME/avr in your home directory
#

# select where to install the software
PREFIX=/usr/local/avr
# To install the toolchain directly into the OS X Pinoccio App
#PREFIX=/Applications/Pinoccio.app/Contents/Resources/Java/hardware/tools/avr

export PATH=$PREFIX:$PATH

# tools need each other and must therefore be in path
export PATH="${PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export DYLD_LIBRARY_PATH="${PREFIX}/lib:${DYLD_LIBRARY_PATH}"

# gcc-4.2 tested on OS X.  XCode's clang compiler can cause problems
function setCompilerVars {
  export CC=/usr/bin/gcc-4.2
  export CXX=/usr/bin/g++-4.2
  export CPP=/usr/bin/cpp-4.2
  export LD=/usr/bin/gcc-4.2
}

function unsetCompilerVars {
  unset CC
  unset CXX
  unset CPP
  unset LD
}

# specify here where to find/install the source archives
ARCHIVES=$HOME/src

# specify here where to compile (i.e. to avoid compiling over nfs)
COMPILE_DIR=/tmp/$USER

# tools required for build process
REQUIRED="wget bison flex gcc g++"
# uncomment if you want to build avrdude from cvs
#REQUIRED="${REQUIRED} automake-1.9 cvs autoconf"

# download sites
GNU_MIRROR="ftp://ftp.gnu.org/pub/gnu"
NONGNU_MIRROR="http://savannah.nongnu.org/download"

# toolchain definition
BINUTILS=binutils-2.23
BINUTILS_PACKAGE=${BINUTILS}.tar.gz
BINUTILS_DOWNLOAD=${GNU_MIRROR}/binutils/${BINUTILS_PACKAGE}
BINUTILS_CHECKSUM="ed58f50d8920c3f1d9cb110d5c972c27"

GMP=gmp-5.0.5
GMP_PACKAGE=${GMP}.tar.bz2
GMP_DOWNLOAD=ftp://ftp.gmplib.org/pub/${GMP}/${GMP_PACKAGE}
GMP_CHECKSUM="041487d25e9c230b0c42b106361055fe"

MPFR=mpfr-3.1.1
MPFR_PACKAGE=${MPFR}.tar.bz2
MPFR_DOWNLOAD=http://www.mpfr.org/mpfr-current/${MPFR_PACKAGE}
MPFR_CHECKSUM="e90e0075bb1b5f626c6e31aaa9c64e3b"

MPC=mpc-1.0.1
MPC_PACKAGE=${MPC}.tar.gz
MPC_DOWNLOAD=http://www.multiprecision.org/mpc/download/${MPC_PACKAGE}
MPC_CHECKSUM="b32a2e1a3daa392372fbd586d1ed3679"

GCC=gcc-4.7.2
GCC_PACKAGE=${GCC}.tar.bz2
GCC_DOWNLOAD=${GNU_MIRROR}/gcc/${GCC}/${GCC_PACKAGE}
GCC_CHECKSUM="cc308a0891e778cfda7a151ab8a6e762"

GDB=gdb-7.5
GDB_PACKAGE=${GDB}.tar.bz2
GDB_DOWNLOAD=${GNU_MIRROR}/gdb/${GDB_PACKAGE}
GDB_CHECKSUM="24a6779a9fe0260667710de1b082ef61"

AVRLIBC=avr-libc-1.8.0
AVRLIBC_PACKAGE=${AVRLIBC}.tar.bz2
AVRLIBC_DOWNLOAD=${NONGNU_MIRROR}/avr-libc/${AVRLIBC_PACKAGE}
AVRLIBC_CHECKSUM="54c71798f24c96bab206be098062344f"

UISP=uisp-20050207
UISP_PACKAGE=${UISP}.tar.gz
UISP_DOWNLOAD=${NONGNU_MIRROR}/uisp/${UISP_PACKAGE}
UISP_CHECKSUM="b1e499d5a1011489635c1a0e482b1627"

AVRDUDE=avrdude-5.10
AVRDUDE_PACKAGE=${AVRDUDE}.tar.gz
AVRDUDE_DOWNLOAD=${NONGNU_MIRROR}/avrdude/${AVRDUDE_PACKAGE}
AVRDUDE_CHECKSUM="ba62697270b1292146dc56d462f5da14"
# uncomment if you want to build avrdude from cvs
#AVRDUDE_CVS="cvs -z3 -d:pserver:anonymous@cvs.savannah.nongnu.org:/sources/avrdude co avrdude"

AVARICE=avarice-2.13
AVARICE_PACKAGE=${AVARICE}.tar.bz2
AVARICE_DOWNLOAD=http://downloads.sourceforge.net/project/avarice/avarice/${AVARICE}/${AVARICE_PACKAGE}
AVARICE_CHECKSUM="ba62697270b1292146dc56d462f5da14"

##
################################################################################
# end of configuration
################################################################################
##

OLDPWD=$PWD
setCompilerVars

echo "--------------------------------------"
echo "- Installation of avr-gcc tool chain -"
echo "--------------------------------------"
echo
echo "Tools to build:"
echo "  binutils - collection of binary tools"
echo "  gmp      - Arbitrary precision arithmetic library"
echo "  mpfr     - Mulitple-precision floating-point library"
echo "  mpc      - GNU Mulitprecision and complex number library"
echo "  gcc      - GNU Compiler Collection"
echo "  gdb      - GNU Project debugger"
echo "  avr-libc - C library for use with GCC on Atmel AVR microcontrollers."
echo "  uisp     - tool for AVR microcontrollers which can interface to many hardware"
echo "             in-system programmers"
echo "  avrdude  - software for programming Atmel AVR Microcontrollers"
echo "  avarice  - software to connect GDB to Atmel ICE JTAG interfaces"
echo
echo "Installation into target directory:"
echo "${PREFIX}"
echo

# Search for required tools
echo "Checking for required tools ..."
for i in ${REQUIRED}
do
  echo -n "Checking for $i ..."
  TOOL=`which $i 2>/dev/null`
  if [ "${TOOL}" == "" ]
  then
    echo " not found, please install it!"
    exit 1
  else
    echo " ${TOOL}, ok"
  fi
done
echo

# Check if target is already there
if [ -x $PREFIX ]
then
  echo "Target $PREFIX already exists! This may be due to"
  echo "a previous incomplete build attempt. Please remove"
  echo "it and restart."
  #exit 1
fi

# Check if target can be created
install -d $PREFIX >/dev/null
if [ "$?" != "0" ]
then
  echo "Unable to create target $PREFIX, please check permissions"
  exit 1
fi
rmdir $PREFIX

# Check if there's already a avr-gcc
TOOL=`which avr-gcc 2>/dev/null`
if [ "${TOOL}" != "" ]
then
  echo "There's already a avr-gcc in ${TOOL},"
  echo "please remove it, as it will conflict"
  echo "with the build process!"
  exit 1
fi

# crate ARCHIVE directory if it doesn't exist
if [ ! -d ${ARCHIVES} ]
then
  echo "Archive directory ${ARCHIVES} does not exist, creating it."
  install -d ${ARCHIVES}
fi

# download and check the source packages
download_and_check() {
  if [ ! -f ${ARCHIVES}/$1 ]
  then
    echo "Archive ${ARCHIVES}/$1 not found, downloading..."
    wget --quiet -O ${ARCHIVES}/$1 $2
  fi

  echo -n "Verifying md5 of ${ARCHIVES}/${1}... "
  MD5=`md5 -r ${ARCHIVES}/$1 | awk '{print $1}'`
  if [ "$MD5" != "$3" ]
  then
    echo "Error: ${1} corrupted!"
    echo "MD5 is: ${MD5}, but should be ${3}"
    exit 1
  fi
}

echo "Check / download source packages..."
download_and_check $BINUTILS_PACKAGE  $BINUTILS_DOWNLOAD   $BINUTILS_CHECKSUM &
download_and_check $GMP_PACKAGE       $GMP_DOWNLOAD        $GMP_CHECKSUM &
download_and_check $MPFR_PACKAGE      $MPFR_DOWNLOAD       $MPFR_CHECKSUM &
download_and_check $MPC_PACKAGE       $MPC_DOWNLOAD        $MPC_CHECKSUM &
download_and_check $GCC_PACKAGE       $GCC_DOWNLOAD        $GCC_CHECKSUM &
download_and_check $GDB_PACKAGE       $GDB_DOWNLOAD        $GDB_CHECKSUM &
download_and_check $AVRLIBC_PACKAGE   $AVRLIBC_DOWNLOAD    $AVRLIBC_CHECKSUM &
download_and_check $UISP_PACKAGE      $UISP_DOWNLOAD       $UISP_CHECKSUM &
[ -z "$AVRDUDE_CVS" ] && download_and_check $AVRDUDE_PACKAGE   $AVRDUDE_DOWNLOAD    $AVRDUDE_CHECKSUM &
download_and_check $AVARICE_PACKAGE      $AVARICE_DOWNLOAD       $AVARICE_CHECKSUM &

# wait until the subshells are finished
wait

echo
echo "Build environment seems fine!"
echo
echo "After successful installation add $PREFIX/bin to"
echo "your PATH by e.g. adding"
echo "   export PATH=\$PATH:$PREFIX/bin"
echo "to your $HOME/.bashrc file."
echo
echo "Press return to continue, CTRL-C to abort ..."
read


mkdir $COMPILE_DIR


# binutils
################################################################################
echo "Building Binutils..."
cd $COMPILE_DIR &&
tar xvfz ${ARCHIVES}/${BINUTILS}.tar.gz &&
cd $BINUTILS &&
mkdir obj-avr &&
cd obj-avr &&
../configure --prefix=$PREFIX --target=avr --disable-nls --enable-install-libbfd --disable-werror &&
make &&
make check &&
make install
if [ $? -gt 0 ]; then
	echo "Error building Binutils..." >&2
	exit 1
fi


# gmp
###############################################################################
echo "Building GMP ..."
cd ${COMPILE_DIR} &&
tar xvfj ${ARCHIVES}/${GMP}.tar.bz2 &&
cd ${GMP} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$GMP --enable-cxx &&
make -j8 &&
make check &&
make install
if [ $? -gt 0 ]; then
	echo "Error building GMP..." >&2
	exit 1
fi


# mpfr
################################################################################
echo "Building MPFR ..."
cd ${COMPILE_DIR} &&
tar xvfj ${ARCHIVES}/${MPFR}.tar.bz2 &&
cd ${MPFR} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$MPFR --with-gmp=$COMPILE_DIR/$GMP --disable-dependency-tracking &&
make -j8 &&
make check &&
make install
if [ $? -gt 0 ]; then
	echo "Error building MPFR..." >&2
	exit 1
fi


# mpc
################################################################################
echo "Building MPC ..."
cd $COMPILE_DIR &&
tar xvfj $ARCHIVES/$MPC.tar.gz &&
cd ${MPC} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$MPC --with-gmp=$COMPILE_DIR/$GMP --with-mpfr=$COMPILE_DIR/$MPFR &&
make -j8 &&
make check &&
make install
if [ $? -gt 0 ]; then
	echo "Error building MPC..." >&2
	exit 1
fi


# gcc
################################################################################
echo "Building GCC ..."
cd $COMPILE_DIR &&
tar xvfj $ARCHIVES/$GCC.tar.bz2 &&
cd ${GCC} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=$PREFIX --target=avr --enable-languages=c,c++ --disable-libssp --disable-nls --with-dwarf2 --with-gmp=$COMPILE_DIR/$GMP --with-mpfr=$COMPILE_DIR/$MPFR --with-mpc=$COMPILE_DIR/$MPC &&
make -j8 &&
make install
if [ $? -gt 0 ]; then
	echo "Error building GCC..." >&2
	exit 1
fi


# avr-libc
################################################################################
echo "Building AVR-Libc ..."
unsetCompilerVars # make sure CC/CXX/CPP/LD env vars aren't set, or avr-libc won't build
cd $COMPILE_DIR &&
tar xvfj ${ARCHIVES}/${AVRLIBC}.tar.bz2 &&
cd ${AVRLIBC} &&
mkdir obj-avr &&
cd obj-avr &&
PATH=$PATH:$PREFIX/bin &&
../configure --prefix=$PREFIX --build=`../config.guess` --host=avr &&
CC=avr-gcc make -j8  &&
make install
if [ $? -gt 0 ]; then
	echo "Error building AVR-Libc..." >&2
	exit 1
fi
setCompilerVars


# gdb
################################################################################
echo "Building GDB ..."
cd ${COMPILE_DIR} &&
tar xvfj ${ARCHIVES}/${GDB}.tar.bz2 &&
cd ${GDB} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=${PREFIX} --target=avr &&
make -j8 &&
make install
if [ $? -gt 0 ]; then
	echo "Error building GDB..." >&2
	exit 1
fi


## uisp
#################################################################################
# echo "Building UISP ..."
# cd ${COMPILE_DIR}
# tar xvfz $ARCHIVES/$UISP.tar.gz
# cd ${UISP}
# mkdir obj-avr
# cd obj-avr
# ../configure --disable-shared --enable-static --prefix=$PREFIX --disable-werror
# make -j8
# make install


# avrdude
################################################################################
echo "Building AVRDUDE..."
if [ -z "${AVRDUDE_CVS}" ]
then
  cd ${COMPILE_DIR} &&
  tar xvfz ${ARCHIVES}/${AVRDUDE}.tar.gz &&
  cd ${AVRDUDE} &&
  mkdir obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=${PREFIX} &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
	  echo "Error building AVRDUDE..." >&2
	  exit 1
  fi
else
  # building avrdude from cvs
  cd ${COMPILE_DIR} &&
  `$AVRDUDE_CVS` &&
  cd avrdude &&
  ./bootstrap &&
  mkdir obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=${PREFIX} &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
	  echo "Error building AVRDUDE..." >&2
	  exit 1
  fi
fi


# avarice
################################################################################
echo "Building Avarice ..."
cd ${COMPILE_DIR} &&
tar xvfj ${ARCHIVES}/${AVARICE}.tar.bz2 &&
cd ${AVARICE} &&
mkdir obj-avr &&
cd obj-avr &&
../configure --disable-shared --enable-static --prefix=${PREFIX} &&
make -j8 &&
make install
if [ $? -gt 0 ]; then
	echo "Error building Avarice..." >&2
	exit 1
fi


# Cleanup
rm -rf ${COMPILE_DIR}

################################################################################
echo "--------------------------------------------------------------------------------"
echo "Installation script finished!"
# show versions
echo "--------------------------------------------------------------------------------"
echo "These are the current installed versions of the avr tool chain:"
echo
echo "--binutils--"
avr-ld --version | head -1
avr-as --version | head -1
echo
echo "--gcc--"
avr-gcc -dumpversion
echo
echo "--gdb--"
avr-gdb --version | head -1
echo
echo "--avrlibc--"
ls ${PREFIX}/lib/gcc/avr
echo
echo "--uisp--"
uisp --version | head -1
echo
echo "--avrdude--"
avrdude  -v 2>&1 | grep Version
echo
echo "--avarice--"
avarice --version
# show path / manpath hints
echo "--------------------------------------------------------------------------------"
echo "Make sure to have $PREFIX/bin in your PATH"
echo "You can do this by adding the following"
echo "line to your $HOME/.bashrc file:"
echo "    export PATH=\$PATH:$PREFIX/bin"
echo
echo "And for manpages, add the following line:"
echo "    export MANPATH=\$MANPATH:$PREFIX/man"
echo
echo "--------------------------------------------------------------------------------"
# return to users current directory
cd $OLDPWD
