# DDev Drupal site creator
This project assists Drupal developers in setting up a Drupal site locally using DDEV.

Developers can use this script to easily set up a local site to work on an issue in the issue queue (issue forks not patches).
This does not work in some edge cases (recipe issues for example), I am still testing on various issues and improving as I go.

![Demo Animation](/demo/demo.gif)

Sites are set up in the way that I like, with the options/modules I personally find helpful. I hope others find it useful.

The dependancies needed to run this script are; xmlstarlet, ddev, composer, git, python3, yq, dogit (https://github.com/dpi/dogit).

This project is typically installed globally using composer.

```shell
composer global require schillerm/ddev-drupal-site-creator
```
To run just use..

```shell
ddev-drupal-site-creator
```
