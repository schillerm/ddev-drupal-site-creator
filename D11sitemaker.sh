#!/bin/bash
read -p 'Sitename [Dev]: ' sitename
sitename=${sitename:-Dev}

mkdir $sitename && cd $sitename

ddev config --project-type=drupal11 --docroot=web
ddev start
ddev composer create drupal/recommended-project
ddev composer require drush/drush
ddev drush site:install --account-name=admin --account-pass=admin -y --site-name=$sitename

# Create the modules custom directory
mkdir -p web/modules/custom

# Create the themes custom directory
mkdir -p web/themes/custom

# Create the config directory
mkdir -p config

# Create the config/default directory
mkdir -p config/default

# Create the config/default/sync directory
mkdir -p config/default/sync

# Create the private directory
mkdir -p private

# Create the .vscode directory
mkdir -p .vscode

# copy vscode file over
cp ~/Documents/Sites/Extras/launch.json ~/Documents/Sites/$sitename/.vscode/launch.json


cat <<EOL > mark.code-workspace
{
  "folders": [
    {
      "path": "~/Documents/Sites"
    }
  ],
  "settings": {}
}
EOL


# Allow plugin sources
ddev composer config allow-plugins.tbachert/spi true
ddev composer config allow-plugins.cweagans/composer-patches true

# ddev composer config allow-plugins.lullabot/drainpipe true
# ddev composer config allow-plugins.lullabot/drainpipe-dev true

ddev composer config extra.drupal-scaffold.gitignore true
# ddev composer config --json extra.drupal-scaffold.allowed-packages "[\"lullabot/drainpipe\", \"lullabot/drainpipe-dev\"]"
# ddev composer require lullabot/drainpipe
# ddev composer require lullabot/drainpipe-dev --dev

ddev composer require cweagans/composer-patches
ddev composer require drupal/core-dev --dev --update-with-all-dependencies
ddev composer require drupal/devel --dev
ddev composer require drupal/admin_toolbar --dev
ddev composer require drupal/examples --dev
ddev composer require drupal/webprofiler --dev

ddev drush en admin_toolbar
ddev drush en devel
ddev drush en devel_generate
ddev drush en examples
ddev drush en webprofiler -y

ddev drush -y config-set system.performance js.preprocess 0
ddev drush -y config-set system.performance css.preprocess 0
ddev drush config:set system.theme twig_debug TRUE --yes

# Extract characters 5 and 6 from the sitename
substring="${sitename:4:2}"

# Run the drush generate command to create the module
ddev drush generate -q module \
  --answer="Test module" \
  --answer="t"$substring"m" \
  --answer="My test module" \
  --answer="Custom" \
  --answer="" \
  --answer="Yes" \
  --answer="Yes" \
  --answer="No" \

#modulename = ${substring} m"

# Create module folders
cd "web/modules/custom/t${substring}m"
mkdir js
mkdir css
mkdir config
mkdir config/install
mkdir src
mkdir src/Controller
cd ../../../../
 
ddev drush en "t"$substring"m"

# Run the drush generate command to create the theme
ddev drush generate -q theme \
  --answer="Test Theme" \
  --answer="t"$substring"t" \
  --answer="Olivero" \
  --answer="My test theme" \
  --answer="Custom" \
  --answer="No" \
  --answer="No" \
  
rm web/themes/custom/"t"$substring"t"/css/base/elements.css
rm web/themes/custom/"t"$substring"t"/css/layout/layout.css
rm web/themes/custom/"t"$substring"t"/css/component/block.css
rm web/themes/custom/"t"$substring"t"/css/component/tabs.css
rm web/themes/custom/"t"$substring"t"/css/component/breadcrumb.css
rm web/themes/custom/"t"$substring"t"/css/component/field.css
rm web/themes/custom/"t"$substring"t"/css/component/header.css
rm web/themes/custom/"t"$substring"t"/css/component/form.css
rm web/themes/custom/"t"$substring"t"/css/component/buttons.css
rm web/themes/custom/"t"$substring"t"/css/component/table.css
rm web/themes/custom/"t"$substring"t"/css/component/messages.css
rm web/themes/custom/"t"$substring"t"/css/component/sidebar.css
rm web/themes/custom/"t"$substring"t"/css/component/node.css
rm web/themes/custom/"t"$substring"t"/css/component/menu.css
rm web/themes/custom/"t"$substring"t"/css/theme/print.css

# Create theme folders
mkdir web/themes/custom/"t"$substring"t"/css/layout
mkdir web/themes/custom/"t"$substring"t"/config
mkdir web/themes/custom/"t"$substring"t"/config/install

# Copy theme regions over
SOURCE_FILE=web/core/themes/olivero/olivero.info.yml
TARGET_FILE=web/themes/custom/"t"$substring"t"/"t"$substring"t".info.yml
yq eval ".regions = load(\"$SOURCE_FILE\").regions" "$TARGET_FILE" -i

# Enable the theme and set as default
ddev drush theme:enable "t"$substring"t"
ddev drush config:set "t"$substring"t".settings logo.use_default 0 -y

# Enable twig development mode and do not cache markup
ddev drush php:eval "\Drupal::keyValue('development_settings')->setMultiple(['disable_rendered_output_cache_bins' => TRUE, 'twig_debug' => TRUE, 'twig_cache_disable' => TRUE]);"

# Install yarn
cd web/core/
yarn install
npm install eslint eslint-config-airbnb eslint-plugin-yml --save-dev
npm i eslint-config-drupal
cd ../../

# copy phpstan.neon over
cp ~/Documents/Sites/Extras/phpstan.neon ~/Documents/Sites/$sitename/phpstan.neon

# copy .gitignore over
cp ~/Documents/Sites/Extras/.gitignore ~/Documents/Sites/$sitename/.gitignore

yes | ddev phpmyadmin

git init
git branch -M main

# changes to settings.php
echo "\$settings['config_sync_directory'] = '../config/default/sync';" >> web/sites/default/settings.php
echo "\$settings['file_private_path'] = '../private';" >> web/sites/default/settings.php

ddev drush cr

ddev drush cex -y
git add .
git commit -m "Initial commit" -q


# copy pre-commit over
cp ~/Documents/Sites/Extras/pre-commit ~/Documents/Sites/$sitename/.git/hooks/pre-commit

ddev drush cr

yes | ddev restart

#ddev launch
# or automatically log in with
#ddev launch $(ddev drush uli)
