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
SOURCEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#PREFIX="$SOURCEDIR/build"
# To install the toolchain directly into the OS X Pinoccio App
PREFIX=/usr/local/avr

# tools need each other and must therefore be in path
export PATH="${PREFIX}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
export DYLD_LIBRARY_PATH="${PREFIX}/lib:${DYLD_LIBRARY_PATH}"

# gcc-4.2 tested on OS X.  XCode's clang compiler can cause problems
function setCompilerVars {
  export CC=/usr/bin/gcc
  export CXX=/usr/bin/g++
  export CPP=/usr/bin/cpp
  export LD=/usr/bin/gcc
}

function unsetCompilerVars {
  unset CC
  unset CXX
  unset CPP
  unset LD
}

# specify here where to find/install the source archives
ARCHIVES="$SOURCEDIR/archives"

# specify here where to compile (i.e. to avoid compiling over nfs)
COMPILE_DIR="$SOURCEDIR/working"

# tools required for build process
REQUIRED="wget bison flex gcc g++"
# uncomment if you want to build avrdude from cvs
#REQUIRED="${REQUIRED} automake-1.9 cvs autoconf"

# download sites
GNU_MIRROR="ftp://ftp.gnu.org/pub/gnu"
NONGNU_MIRROR="http://savannah.nongnu.org/download"

# toolchain definition
BINUTILS=binutils-2.23.2
BINUTILS_PACKAGE=${BINUTILS}.tar.gz
BINUTILS_DOWNLOAD=${GNU_MIRROR}/binutils/${BINUTILS_PACKAGE}
BINUTILS_CHECKSUM="cda9dcc08c86ff2fd3f27e4adb250f6f"
BINUTILS_INSTALL=n

GMP=gmp-5.0.5
GMP_PACKAGE=${GMP}.tar.bz2
GMP_DOWNLOAD=ftp://ftp.gmplib.org/pub/${GMP}/${GMP_PACKAGE}
GMP_CHECKSUM="041487d25e9c230b0c42b106361055fe"
GMP_INSTALL=n

MPFR=mpfr-3.1.2
MPFR_PACKAGE=${MPFR}.tar.bz2
MPFR_DOWNLOAD=http://www.mpfr.org/mpfr-current/${MPFR_PACKAGE}
MPFR_CHECKSUM="ee2c3ac63bf0c2359bf08fc3ee094c19"
MPFR_INSTALL=n

MPC=mpc-1.0.1
MPC_PACKAGE=${MPC}.tar.gz
MPC_DOWNLOAD=http://www.multiprecision.org/mpc/download/${MPC_PACKAGE}
MPC_CHECKSUM="b32a2e1a3daa392372fbd586d1ed3679"
MPC_INSTALL=n

GCC=gcc-4.7.3
GCC_PACKAGE=${GCC}.tar.bz2
GCC_DOWNLOAD=${GNU_MIRROR}/gcc/${GCC}/${GCC_PACKAGE}
GCC_CHECKSUM="86f428a30379bdee0224e353ee2f999e"
GCC_INSTALL=n

GDB=gdb-7.5
GDB_PACKAGE=${GDB}.tar.bz2
GDB_DOWNLOAD=${GNU_MIRROR}/gdb/${GDB_PACKAGE}
GDB_CHECKSUM="24a6779a9fe0260667710de1b082ef61"
GDB_INSTALL=n

AVRLIBC=avr-libc-1.8.0
AVRLIBC_PACKAGE=${AVRLIBC}.tar.bz2
AVRLIBC_DOWNLOAD=${NONGNU_MIRROR}/avr-libc/${AVRLIBC_PACKAGE}
AVRLIBC_CHECKSUM="54c71798f24c96bab206be098062344f"
AVRLIBC_SVN="svn co svn://svn.sv.gnu.org/avr-libc/trunk/avr-libc"
AVRLIBC_INSTALL=y

UISP=uisp-20050207
UISP_PACKAGE=${UISP}.tar.gz
UISP_DOWNLOAD=${NONGNU_MIRROR}/uisp/${UISP_PACKAGE}
UISP_CHECKSUM="b1e499d5a1011489635c1a0e482b1627"
UISP_INSTALL=n

AVRDUDE=avrdude-6.0.1
AVRDUDE_PACKAGE=${AVRDUDE}.tar.gz
AVRDUDE_DOWNLOAD=http://download.savannah.gnu.org/releases/avrdude/${AVRDUDE_PACKAGE}
#AVRDUDE_CHECKSUM="3a43e288cb32916703b6945e3f260df9"
AVRDUDE_CHECKSUM="346ec2e46393a54ac152b95abf1d9850"
# uncomment if you want to build avrdude from cvs
#AVRDUDE_CVS="cvs -z3 -d:pserver:anonymous@cvs.savannah.nongnu.org:/sources/avrdude co avrdude"
AVRDUDE_INSTALL=n

AVARICE=avarice-2.13
AVARICE_PACKAGE=${AVARICE}.tar.bz2
AVARICE_DOWNLOAD=http://downloads.sourceforge.net/project/avarice/avarice/${AVARICE}/${AVARICE_PACKAGE}
AVARICE_CHECKSUM="b9ea1202cfe78b6b008192f092b2dd6c"
AVARICE_INSTALL=n

##
################################################################################
# end of configuration
################################################################################
##

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

USAGE="Usage: $0 [-h] [-p prefix] [tool...]"

while [ $# -gt 0 ]; do
  case "$1" in
    -p|--prefix)
      PREFIX="$2"
      shift
      ;;
    -h|--help|-*)
      echo "$USAGE" >&2
      exit 1
    ;;
    *)
      break
    ;;
  esac
  shift
done

if [ $# -gt 0 ]; then
  BINUTILS_INSTALL=
  GMP_INSTALL=
  MPFR_INSTALL=
  MPC_INSTALL=
  GCC_INSTALL=
  GDB_INSTALL=
  AVRLIBC_INSTALL=
  UISP_INSTALL=
  AVRDUDE_INSTALL=
  AVARICE_INSTALL=
  while [ $# -gt 0 ]; do
    case "$1" in
      binutils)	BINUTILS_INSTALL=y ;;
      gmp)  	GMP_INSTALL=y ;;
      mpfr)  	MPFR_INSTALL=y ;;
      mpc)  	MPC_INSTALL=y ;;
      gcc)  	GCC_INSTALL=y ;;
      gdb)  	GDB_INSTALL=y ;;
      avr-libc)	AVRLIBC_INSTALL=y ;;
      uisp)  	UISP_INSTALL=y ;;
      avrdude)	AVRDUDE_INSTALL=y ;;
      avarice)	AVARICE_INSTALL=y ;;
      *)
        echo "$USAGE" >&2
        exit 1
      ;;
    esac
    shift
  done
fi

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
#rmdir $PREFIX

# Check if there's already a avr-gcc
TOOL=`which avr-gcc 2>/dev/null`
if [ "${TOOL}" != "" ]
then
  echo "There's already a avr-gcc in ${TOOL},"
  echo "please remove it, as it will conflict"
  echo "with the build process!"
  #exit 1
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
    if [ $? -ne 0 ]; then
      echo "Error: Failed to fetch ${1}" >&2
      exit 1
    fi
  fi

  echo "Verifying md5 of ${ARCHIVES}/${1}... "
  if builtin command -v md5 > /dev/null ; then
    MD5=`md5 -r ${ARCHIVES}/$1 | awk '{print $1}'`
  else
    MD5=`md5sum ${ARCHIVES}/$1 | awk '{print $1}'`
  fi 
  if [ "$MD5" != "$3" ]
  then
    echo "Error: ${1} corrupted!" >&2
    echo "MD5 is: ${MD5}, but should be ${3}" >&2
    exit 1
  fi
}

echo
echo "Check / download source packages..."
[ -n "$BINUTILS_INSTALL" ] && download_and_check $BINUTILS_PACKAGE  $BINUTILS_DOWNLOAD   $BINUTILS_CHECKSUM &
[ -n "$GMP_INSTALL" ] && download_and_check $GMP_PACKAGE       $GMP_DOWNLOAD        $GMP_CHECKSUM &
[ -n "$MPFR_INSTALL" ] && download_and_check $MPFR_PACKAGE      $MPFR_DOWNLOAD       $MPFR_CHECKSUM &
[ -n "$MPC_INSTALL" ] && download_and_check $MPC_PACKAGE       $MPC_DOWNLOAD        $MPC_CHECKSUM &
[ -n "$GCC_INSTALL" ] && download_and_check $GCC_PACKAGE       $GCC_DOWNLOAD        $GCC_CHECKSUM &
[ -n "$GDB_INSTALL" ] && download_and_check $GDB_PACKAGE       $GDB_DOWNLOAD        $GDB_CHECKSUM &
[ -z "$AVRLIBC_SVN" ] &&
  [ -n "$AVRLIBC_INSTALL" ] && download_and_check $AVRLIBC_PACKAGE   $AVRLIBC_DOWNLOAD    $AVRLIBC_CHECKSUM &
[ -n "$UISP_INSTALL" ] && download_and_check $UISP_PACKAGE      $UISP_DOWNLOAD       $UISP_CHECKSUM &
[ -z "$AVRDUDE_CVS" ] &&
  [ -n "$AVRDUDE_INSTALL" ] && download_and_check $AVRDUDE_PACKAGE $AVRDUDE_DOWNLOAD    $AVRDUDE_CHECKSUM &
[ -n "$AVARICE_INSTALL" ] && download_and_check $AVARICE_PACKAGE   $AVARICE_DOWNLOAD    $AVARICE_CHECKSUM &

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
echo "If using Arduino with this build of avr-gcc you need"
echo "to remove the arduino/hardware/tools/avr/bin folder and"
echo "make a new symlink to $PREFIX/bin in its place."
echo "You will probably also need to symlink avrdude and avrdude.conf"
echo "in arduino/hardware/tools to the newly compiled version"
echo
echo "Press return to continue, CTRL-C to abort ..."
read


mkdir $COMPILE_DIR


# binutils
################################################################################
if [ -n "$BINUTILS_INSTALL" ]; then
  echo "Building Binutils..."
  cd $COMPILE_DIR &&
  tar xvfz ${ARCHIVES}/${BINUTILS}.tar.gz &&
  cp -f $SOURCEDIR/patches/binutils-2.23.2-patches/gas/config/tc-avr.c ${BINUTILS}/gas/config/tc-avr.c &&
  cd $BINUTILS &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --prefix=$PREFIX --target=avr --disable-nls --enable-install-libbfd --disable-werror &&
  make &&
  make check &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building Binutils..." >&2
    exit 1
  fi
fi


# gmp
###############################################################################
if [ -n "$GMP_INSTALL" ]; then
  echo "Building GMP ..."
  cd ${COMPILE_DIR} &&
  tar xvfj ${ARCHIVES}/${GMP}.tar.bz2 &&
  cd ${GMP} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$GMP --enable-cxx &&
  make -j8 &&
  make check &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building GMP..." >&2
    exit 1
  fi
fi


# mpfr
################################################################################
if [ -n "$MPFR_INSTALL" ]; then
  echo "Building MPFR ..."
  cd ${COMPILE_DIR} &&
  tar xvfj ${ARCHIVES}/${MPFR}.tar.bz2 &&
  cd ${MPFR} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$MPFR --with-gmp=$COMPILE_DIR/$GMP --disable-dependency-tracking &&
  make -j8 &&
  make check &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building MPFR..." >&2
    exit 1
  fi
fi


# mpc
################################################################################
if [ -n "$MPC_INSTALL" ]; then
  echo "Building MPC ..."
  cd $COMPILE_DIR &&
  tar xvfz $ARCHIVES/$MPC.tar.gz &&
  cd ${MPC} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=$COMPILE_DIR/$MPC --with-gmp=$COMPILE_DIR/$GMP --with-mpfr=$COMPILE_DIR/$MPFR &&
  make -j8 &&
  make check &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building MPC..." >&2
    exit 1
  fi
fi


# gcc
################################################################################
if [ -n "$GCC_INSTALL" ]; then
  echo "Building GCC ..."
  cd $COMPILE_DIR &&
  tar xvfj $ARCHIVES/$GCC.tar.bz2 &&
  # copy MCU definitions for new RFR2 chips into GCC source tree
  cp -f $SOURCEDIR/patches/gcc-4.7.3-patches/gcc/config/avr/avr-mcus.def ${GCC}/gcc/config/avr/avr-mcus.def &&
  cd ${GCC} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=$PREFIX --target=avr --enable-languages=c,c++ --disable-libssp --disable-nls --with-dwarf2 --with-gmp=$COMPILE_DIR/$GMP --with-mpfr=$COMPILE_DIR/$MPFR --with-mpc=$COMPILE_DIR/$MPC &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building GCC..." >&2
    exit 1
  fi
fi


# avr-libc
################################################################################
if [ -n "$AVRLIBC_INSTALL" ]; then
  echo "Building AVR-Libc ..."
  unsetCompilerVars # make sure CC/CXX/CPP/LD env vars aren't set, or avr-libc won't build
  if [ -z "${AVRLIBC_SVN}" ]
  then
    cd $COMPILE_DIR &&
    tar xvfj ${ARCHIVES}/${AVRLIBC}.tar.bz2 &&
    cd ${AVRLIBC} &&
    ./bootstrap &&
    mkdir -p obj-avr &&
    cd obj-avr &&
    PATH=$PREFIX/bin:$PATH &&
    ../configure --prefix=$PREFIX --build=`../config.guess` --host=avr &&
    CC=avr-gcc make -j8  &&
    make install
    if [ $? -gt 0 ]; then
      echo "Error building AVR-Libc..." >&2
      exit 1
    fi
  else
    # building avr-libc from SVN
    echo "Building AVR-Libc from SVN"
    cd ${COMPILE_DIR} &&
    `$AVRLIBC_SVN > /dev/null` &&	
    cd avr-libc &&
    ./bootstrap &&
    mkdir -p obj-avr &&
    cd obj-avr &&
    PATH=$PREFIX/bin:$PATH &&
    ../configure --prefix=$PREFIX --build=`../config.guess` --host=avr &&
    CC=avr-gcc make -j8  &&
    make install
    if [ $? -gt 0 ]; then
      echo "Error building AVR-Libc..." >&2
      exit 1
    fi
  fi
  setCompilerVars
fi


# gdb
################################################################################
if [ -n "$GDB_INSTALL" ]; then
  echo "Building GDB ..."
  cd ${COMPILE_DIR} &&
  tar xvfj ${ARCHIVES}/${GDB}.tar.bz2 &&
  cd ${GDB} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=${PREFIX} --target=avr &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building GDB..." >&2
    exit 1
  fi
fi


## uisp
#################################################################################
if [ -n "$UISP_INSTALL" ]; then
  echo "Building UISP ..."
  cd ${COMPILE_DIR} &&
  tar xvfz $ARCHIVES/$UISP.tar.gz &&
  cd ${UISP} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=$PREFIX --disable-werror &&
  sed -i'.bak' '/-Werror/d' src/Makefile &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building UISP..." >&2
    exit 1
  fi
fi


# avrdude
################################################################################
if [ -n "$AVRDUDE_INSTALL" ]; then
  echo "Building AVRDUDE..."
  if [ -z "${AVRDUDE_CVS}" ]
  then
    cd ${COMPILE_DIR} &&
    tar xvfz ${ARCHIVES}/${AVRDUDE}.tar.gz &&
    cd ${AVRDUDE} &&
    ./bootstrap &&
    mkdir -p obj-avr &&
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
    mkdir -p obj-avr &&
    cd obj-avr &&
    ../configure --disable-shared --enable-static --prefix=${PREFIX} &&
    make -j8 &&
    make install
    if [ $? -gt 0 ]; then
      echo "Error building AVRDUDE..." >&2
      exit 1
    fi
  fi
fi


# avarice
################################################################################
if [ -n "$AVARICE_INSTALL" ]; then
  echo "Building Avarice ..."
  cd ${COMPILE_DIR} &&
  tar xvfj ${ARCHIVES}/${AVARICE}.tar.bz2 &&
  cd ${AVARICE} &&
  mkdir -p obj-avr &&
  cd obj-avr &&
  ../configure --disable-shared --enable-static --prefix=${PREFIX} &&
  make -j8 &&
  make install
  if [ $? -gt 0 ]; then
    echo "Error building Avarice..." >&2
    exit 1
  fi
fi


# Cleanup
#rm -rf ${COMPILE_DIR}

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
