# Version Bumper

Updating Version in your VCS project is tedious.

So far I have not found project that is able to do:
- `make release` [example](https://github.com/eventum/eventum/commit/ad54ed1):
  - update changelog to set release date
  - update changelog to update diff link
  - update version info in code
  - commit signed tag
  - optionally and push commit and tag
- `bump version` [example](https://github.com/eventum/eventum/commit/76e3032):
  - open new version section in changelog
  - update version info in code
  - create commit about new version being set
  - optionally push it
  
This project is my attempt to rectify the problem.

## Related

Somehow related, similar projects or similar problems.

- [bump gem](https://github.com/gregorym/bump)
- [php-cs-fixer: "fixer" to modify code constants, variables](https://github.com/FriendsOfPHP/PHP-CS-Fixer/issues/2389)
