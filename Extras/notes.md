To run phpunit ok
```shell
ddev ssh
./vendor/bin/phpunit web/modules/contrib/devel
```

To run phpstan ok
```shell
ddev exec vendor/bin/phpstan analyze web/modules/contrib/devel -l 5
```

To run phpcs ok
```shell
phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,info,txt,md,yml web/modules/contrib/hal
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
