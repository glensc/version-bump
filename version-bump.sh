#!/bin/sh
set -e

# get current version using bump
current_version() {
	local out
	out=$(bump current)
	echo "$out" | awk '{print $NF}'
}

# get previous version from changelog
prev_version() {
	grep -E '^## ' CHANGELOG.md | head -n2 |tail -n1 | sed -rne 's/^## \[([0-9.]+)\].*/\1/p'
}

preg_quote() {
	if [ $# -gt 0 ]; then
		echo "$*"
	else
		cat
	fi | sed -e 's,[.],\\&,g'
}

# release actions:
# - update changelog to set release date
# - update changelog to update diff link
# - commit changelog
# - commit annotated tag
make_release() {
	local date version ver prev v

	date=$(date +%Y-%m-%d)
	version=$(current_version)
	ver=$(preg_quote "$version")
	prev=$(prev_version | preg_quote)

	# detect v prefix
	v=$(sed -nre "s/^\[$ver\]:.*compare\/(.*)$prev\.\.\..*/\1/p" CHANGELOG.md)

	sed -i -re "s,^(## \[$ver\]).*,\1 - $date," CHANGELOG.md
	sed -i -re "s,^(\[$ver\]:.*compare/$v$prev)\.\.\..*,\1...$v$ver," CHANGELOG.md

	git commit -m "set $version release date" CHANGELOG.md
	git tag -m "release $version" $v$version
}

# open dev version:
# - open new version section in changelog
# - create commit about new version being set
bump_dev() {
	local prev version v
	prev=$(current_version)
	prev=$(preg_quote "$prev")

	# bump revision
	bump patch --no-commit

	version=$(current_version)

	# detect v prefix
	v=$(sed -nre "s/^\[$prev\]:.*compare\/.*\.\.\.(v)?$prev/\1/p" CHANGELOG.md)

	local diff_link=$(grep "^\[$prev\]:" CHANGELOG.md)
	diff_link=$(echo "$diff_link" | sed -re "s,^\[$prev\]:.*(http.*compare)/.+,[$version]: \1/$v$prev...master,")
	local rel_section="## [$version]"

	sed -i -e "/^## \[$prev\]/ {
		i$rel_section
		i
		i$diff_link
		i
	}" CHANGELOG.md

	git commit -am "$version-dev"
}

case "$1" in
"release")
	make_release
	;;
"dev"|"bump")
	bump_dev
	;;
esac
