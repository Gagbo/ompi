#!/usr/bin/env sh
#
# Copyright (c) 2004-2005 The Trustees of Indiana University and Indiana
#                         University Research and Technology
#                         Corporation.  All rights reserved.
# Copyright (c) 2004-2005 The University of Tennessee and The University
#                         of Tennessee Research Foundation.  All rights
#                         reserved.
# Copyright (c) 2004-2005 High Performance Computing Center Stuttgart,
#                         University of Stuttgart.  All rights reserved.
# Copyright (c) 2004-2005 The Regents of the University of California.
#                         All rights reserved.
# Copyright (c) 2009-2015 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2015      Research Organization for Information Science
#                         and Technology (RIST). All rights reserved.
# Copyright (c) 2015      Los Alamos National Security, LLC. All rights
#                         reserved.
# $COPYRIGHT$
#
# Additional copyrights may follow
#
# $HEADER$
#

srcdir=$1
builddir=$PWD
distdir=$builddir/$2
OMPI_VERSION=$3
OMPI_REPO_REV=$4

if test x"$2" = x ; then
    echo "Must supply relative distdir as argv[2] -- aborting"
    exit 1
elif test x$OMPI_VERSION = x ; then
    echo "Must supply version as argv[1] -- aborting"
    exit 1
fi

# we can catch some hard (but possible) to do mistakes by looking at
# our repo's revision, but only if we are in the source tree.
# Otherwise, use what configure told us, at the cost of allowing one
# or two corner cases in (but otherwise VPATH builds won't work)
repo_rev=$OMPI_REPO_REV
if test -d .git ; then
    repo_rev=$(config/opal_get_version.sh VERSION --repo-rev)
fi

start=$(date)
cat <<EOF

Creating Open MPI distribution
In directory: `pwd`
Version: $OMPI_VERSION
Started: $start

EOF

umask 022

# Some shell startup files alias cp, mv, and rm to have "-i"
# (interactive).  Unalias here, just so that we don't use that option.
unalias cp &> /dev/null
unalias rm &> /dev/null
unalias mv &> /dev/null

if test ! -d "$distdir" ; then
    echo "*** ERROR: dist dir does not exist"
    echo "*** ERROR:   $distdir"
    exit 1
fi

#
# Update VERSION:repo_rev with the best value we have.
#
sed -e 's/^repo_rev=.*/repo_rev='$repo_rev'/' "${distdir}/VERSION" > "${distdir}/version.new"
cp -f "${distdir}/version.new" "${distdir}/VERSION"
rm -f "${distdir}/version.new"
# need to reset the timestamp to not annoy AM dependencies
touch -r "${srcdir}/VERSION" "${distdir}/VERSION"
echo "*** Updated VERSION file with repo rev number"

#########################################################
# VERY IMPORTANT: Now go into the new distribution tree #
#########################################################
cd "$distdir"
echo "*** Now in distdir: $distdir"

#
# Put the release version number in the README and INSTALL files
#

files="README INSTALL"
echo "*** Updating version number in $files..."
for file in $(echo $files) ; do
    echo " - Setting $file"
    if test -f $file ; then
	sed -e "s/OMPI_VERSION/$OMPI_VERSION/g" $file > bar
	mv -f bar $file
    fi
done

#
# All done
#

cat <<EOF
*** Open MPI version $OMPI_VERSION distribution created

Started: $start
Ended:   `date`

EOF

