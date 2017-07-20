#!/bin/sh
set -xe

# get current version using bump
current_version() {
	bump current | awk '{print $NF}'
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
	local date=$(date +%Y-%m-%d)
	local version=$(current_version)
	local ver=$(preg_quote "$version")
	local prev=$(prev_version | preg_quote)

	sed -i -re "s,^(## \[$ver\]).*,\1 - $date," CHANGELOG.md
	sed -i -re "s,^(\[$ver\]:.*compare/$prev)\.\.\..*,\1...$ver," CHANGELOG.md

	git commit -am "set $version release date"
	git tag -m "release $version" v$version
}

# open dev version:
# - open new version section in changelog
# - create commit about new version being set
bump_dev() {
	local prev=$(current_version | preg_quote)

	# bump revision
	bump patch --no-commit

	local version=$(current_version)

	local diff_link=$(grep "^\[$prev\]:" CHANGELOG.md)
	diff_link=$(echo "$diff_link" | sed -re "s,^\[$prev\]:(.*compare)/.+,[$version]: \1/$prev...master,")
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
"dev")
	bump_dev
	;;
esac
