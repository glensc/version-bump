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

## Examples

An example how to use this tool GitLab CI.
This will add `create release` manual job on `master` branch, when `played` will create next patch release.

```yml
create release:
  stage: release
  tags:
    - chef-client
  image: $CI_REGISTRY/docker-images/chef-client
  when: manual
  only:
    - master
  variables:
    # ssh name where to push (may differ from http address)
    CI_GIT_PUSH_SERVER=gitlab.example.org
  before_script:
    - git clone https://github.com/glensc/version-bump
    - gem install --bindir=/usr/local/bin bump
    - git config user.email "$GITLAB_USER_EMAIL"
    - git config user.name "GitLab Autodeploy"
    # reconfigure for push url
    - git remote set-url --push origin git@${CI_GIT_PUSH_SERVER}:${CI_PROJECT_PATH}.git
  script: |
    set -x
    # create new release
    version-bump/version-bump.sh release
    # push it out
    git push origin refs/heads/$CI_COMMIT_REF_NAME refs/tags/*

    # start new development
    version-bump/version-bump.sh bump
    # push it out
    git push origin refs/heads/$CI_COMMIT_REF_NAME
```


## Related

Somehow related, similar projects or similar problems.

- [bump gem](https://github.com/gregorym/bump)
- [php-cs-fixer: "fixer" to modify code constants, variables](https://github.com/FriendsOfPHP/PHP-CS-Fixer/issues/2389)
