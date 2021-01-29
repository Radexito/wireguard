#!/bin/bash
# passes `shellcheck` and `shfmt -i 2`

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
MAINDIR=$(dirname "$(dirname "${DIR}")")
tmpdir=/tmp/tmp.$(( RANDOM * 19318203981230 + 40 ))
plugin=$(basename "${DIR}")
version=$(date +"%Y.%m.%d")$1
plgfile="${MAINDIR}/plugins/${plugin}.plg"
txzfile="${MAINDIR}/archive/${plugin}.txz"
#txzfile="${MAINDIR}/archive/${plugin}-${version}-x86_64-1.txz"

# create txz package 
mkdir -p "$(dirname "${txzfile}")"
mkdir -p "${tmpdir}"
# shellcheck disable=SC2046
cp --parents -f $(find . -type f ! \( -iname "pkg_build.sh" -o -iname "sftp-config.json" \)) "${tmpdir}/"
cd "${tmpdir}" || exit 1
makepkg -l y -c y "${txzfile}"
rm -rf "${tmpdir}"
md5=$(md5sum "${txzfile}" | cut -f 1 -d ' ')
echo "MD5: ${md5}"

# test txz package 
mkdir -p "${tmpdir}"
cd "${tmpdir}" || exit 1
RET=$(explodepkg "${txzfile}" 2>&1 >/dev/null)
rm -rf "${tmpdir}"
[[ "${RET}" != "" ]] && echo "Error: invalid txz package created: ${txzfile}" && exit 1
cd "${DIR}" || exit 1

# update plg file
sed -i -E "s#(ENTITY name\s*)\".*\"#\1\"${plugin}\"#g" "${plgfile}"
sed -i -E "s#(ENTITY version\s*)\".*\"#\1\"${version}\"#g" "${plgfile}"
sed -i -E "s#(ENTITY MD5\s*)\".*\"#\1\"${md5}\"#g" "${plgfile}"

# add changelog for major versions
# [[ -z "$1" ]] && sed -i "/<CHANGES>/a ###${version}\n" ${plgfile}

echo
grep -E "ENTITY (name|version|MD5)" "${plgfile}"
echo
echo "plugin: ${plgfile}"
echo "txz:    ${txzfile}"
