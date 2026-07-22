To send updates to packagist..
make changes to files
git status
git add .
git commit -m "Made some changes"
git push
git tag v1.3.1
git push origin v1.3.1

To run phpunit
```shell
ddev ssh
./vendor/bin/phpunit web/modules/contrib/devel
```

To run phpstan
```shell
ddev exec vendor/bin/phpstan analyze web/modules/contrib/devel -l 5
```

To run phpstan using phpstan.neon (run from site root)
```shell
vendor/bin/phpstan analyse web/modules/contrib/devel
```

To run phpcs (using default phpcs.xml)
```shell
phpcs  web/modules/contrib/hal
```

To run phpcs with extra DrupalPractice (overriding phpcs.xml)
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
