To run phpunit
```shell
ddev ssh
./vendor/bin/phpunit web/modules/contrib/devel
```

To run phpstan
```shell
ddev exec vendor/bin/phpstan analyze web/modules/contrib/devel -l 5
```

To run phpcs
```shell
phpcs --standard=Drupal,DrupalPractice --extensions=php,module,inc,install,test,profile,theme,info,txt,md,yml web/modules/contrib/hal
```

To install yarn (plan to automate this in future)
```shell
cd web/core
ddev yarn install
cd ../../ && ln -s web/core/node_modules && cd web/core
```
To run eslint
```shell
cd web/core
ddev yarn eslint ../themes/contrib/gin/js/init.js
```

To run cspell
```shell
ddev yarn run spellcheck "path/to/file/or/directory/**/*"
ddev yarn run spellcheck "modules/views/templates/views-view-field.html.twig"
ddev yarn run spellcheck "../modules/contrib/tracer"
```

To run gitlab-ci-local (once it's been installed). Run inside module folder.
```shell
gitlab-ci-local \
  --remote-variables git@git.drupal.org:project/gitlab_templates=includes/include.drupalci.variables.yml=main \
  --variable="_GITLAB_TEMPLATES_REPO=project/gitlab_templates" \
  "$@"
  ```
..or if it's set up as an alias
```shell
drupal-ci-local
  ```

Post gitlab-ci-local
```shell
git restore .
git clean -fd
  ```
