#!/bin/bash

# Uncomment to do clears, comment out to run with no clears, see all output.
clear_toggle="on"

function select_option {

  # little helpers for terminal print control and key input
  ESC=$(printf "\033")
  cursor_blink_on() { printf "$ESC[?25h"; }
  cursor_blink_off() { printf "$ESC[?25l"; }
  cursor_to() { printf "$ESC[$1;${2:-1}H"; }
  print_option() { printf "   $1 "; }
  print_selected() { printf "  $ESC[7m $1 $ESC[27m"; }
  get_cursor_row() {
    IFS=';' read -sdR -p $'\E[6n' ROW COL
    echo ${ROW#*[}
  }
  key_input() {
    read -s -n3 key 2>/dev/null >&2
    if [[ $key = $ESC[A ]]; then echo up; fi
    if [[ $key = $ESC[B ]]; then echo down; fi
    if [[ $key = "" ]]; then echo enter; fi
  }

  # initially print empty new lines (scroll down if at bottom of screen)
  for opt; do printf "\n"; done

  # determine current screen position for overwriting the options
  local lastrow=$(get_cursor_row)
  local startrow=$(($lastrow - $#))

  # ensure cursor and input echoing back on upon a ctrl+c during read -s
  trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
  cursor_blink_off

  local selected=0
  while true; do
    # print options by overwriting the last lines
    local idx=0
    for opt; do
      cursor_to $(($startrow + $idx))
      if [ $idx -eq $selected ]; then
        print_selected "$opt"
      else
        print_option "$opt"
      fi
      ((idx++))
    done

    # user key control
    case $(key_input) in
    enter) break ;;
    up)
      ((selected--))
      if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
      ;;
    down)
      ((selected++))
      if [ $selected -ge $# ]; then selected=0; fi
      ;;
    esac
  done

  # cursor position back to normal
  cursor_to $lastrow
  printf "\n"
  cursor_blink_on

  return $selected
}

function get_basic_drupal_version {
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Select a Drupal version"
  echo
  d_options=(
    11
    10
    9
    8
  )

  select_option "${d_options[@]}"
  d_choice=$?
  basic_drupal_version="${d_options[d_choice]}"

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
}

function get_site_details() {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  # Sitename
  # Loop until valid input is provided
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "

  while true; do
    read -p 'Sitename [Dev] : ' initial_sitename
    initial_sitename="${initial_sitename:-Dev}"

    # Validate: first character must be a letter, rest can be alphanumeric or hyphen
    if [[ "$initial_sitename" =~ ^[a-zA-Z][a-zA-Z0-9-]*$ ]]; then
      break
    else
      echo "Invalid sitename. It must start with a letter and contain only letters, numbers, or hyphens."
    fi
  done

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  if [[ -n "$issue_number" ]]; then
    # Issue number exists offer the option to include this in the sitename

    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Do you want to suffix the issue number in the sitename?"
    echo
    suffix_issue_number_options=(
      Yes
      No
    )

    select_option "${suffix_issue_number_options[@]}"
    suffix_issue_number_options_choice=$?
    suffix_issue_number_choice="${suffix_issue_number_options[$suffix_issue_number_options_choice]}"

    if [[ "$clear_toggle" == "on" ]]; then
      clear
    fi

  else
    # No issue number so offer random number instead
    if [[ "$clear_toggle" == "on" ]]; then
      clear
    fi
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Do you want to suffix the sitename with 6 random digits?"
    echo
    suffix_digits_options=(
      Yes
      No
    )

    select_option "${suffix_digits_options[@]}"
    suffix_digits_options_choice=$?
    suffix_digits_choice="${suffix_digits_options[$suffix_digits_options_choice]}"

  fi

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e ""
  echo "Do you want to add the drupal version to the site name?"
  echo
  add_drupal_version_to_sitename_options=(
    Yes
    No
  )

  select_option "${add_drupal_version_to_sitename_options[@]}"
  add_drupal_version_to_sitename_options_choice=$?
  add_drupal_version_to_choice="${add_drupal_version_to_sitename_options[$add_drupal_version_to_sitename_options_choice]}"

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  ############# This section builds the sitename ###################

  if [ "$suffix_digits_choice" = "Yes" ] || [ "$suffix_issue_number_choice" = "Yes" ]; then

    if [ "$suffix_issue_number_choice" = "Yes" ]; then
      # Suffix sitename with the issue number
      if [ "$add_drupal_version_to_choice" = "Yes" ]; then
        sitename="${initial_sitename}-${basic_drupal_version}-${issue_number}"
      else
        sitename="${initial_sitename}-${issue_number}"
      fi
    else
      # else suffix sitename with a random number
      site_number=$(printf "%06d" $((RANDOM % 1000000)))
      if [ "$add_drupal_version_to_choice" = "Yes" ]; then
        sitename="${initial_sitename}-${basic_drupal_version}-${site_number}"
      else
        sitename="${initial_sitename}-${site_number}"
      fi

    fi

  else
    # Build sitename with no suffix
    sitename="${initial_sitename}"
    if [ "$add_drupal_version_to_choice" = "Yes" ]; then
      sitename="${initial_sitename}-${basic_drupal_version}"
    fi
  fi

  # End of build sitename section

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"

  default_site_title="${sitename//-/ }"

  while true; do
    #read -p "Site Title ["${default_site_title}"] : " site_title
    read -p "Site Title [${default_site_title}]: " site_title

    site_title=${site_title:-"$default_site_title"}

    # Trim to first 100 characters
    site_title="${site_title:0:100}"

    # Sanitize: remove unsafe characters
    sanitized_title=$(echo "$site_title" | sed 's/[^a-zA-Z0-9 ._-]//g')

    # Check if sanitized version is equal to input and not empty
    if [[ "$sanitized_title" == "$site_title" && -n "$site_title" ]]; then
      break
    else
      echo "Invalid site title. Only letters, numbers, spaces, dashes, underscores, and dots are allowed. Max length: 100 characters."
    fi
  done

  # Sanitize the site title
  sanitize_site_title() {
    local input="$1"

    # Trim leading/trailing whitespace
    input="$(echo "$input" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    # Remove control characters (non-printable)
    input="$(echo "$input" | tr -dC '[:print:]')"

    # Replace dangerous shell characters with dashes or nothing
    input="$(echo "$input" | sed 's/["'\''`\\$&<>|]/-/g')"

    echo "$input"
  }

  sanitized_title=$(sanitize_site_title "$site_title")

  # Optional: confirm valid title
  echo "Using site title: '$site_title'"

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"
  echo -e "Site Title : ${green}$site_title${reset}"

  while true; do
    read -p "Username [admin]: " username
    username="${username:-admin}"

    # Check: valid characters and length (3 to 60)
    if [[ "$username" =~ ^[a-zA-Z0-9._-]{3,60}$ ]]; then
      break
    else
      echo "Invalid username. Use 3–60 characters: letters, numbers, dot (.), dash (-), or underscore (_)."
    fi
  done

  echo "Using username: $username"

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"
  echo -e "Site Title : ${green}$site_title${reset}"
  echo -e "Username : ${green}$username${reset}"

  while true; do
    read -p 'Email [someone@example.com]: ' email
    email="${email:-someone@example.com}"
    if [ -z "$email" ]; then
      echo "Please enter an email address!"
    else
      break
    fi
  done

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"
  echo -e "Site Title : ${green}$site_title${reset}"
  echo -e "Username : ${green}$username${reset}"
  echo -e "Email : ${green}$email${reset}"

  while true; do
    read -p 'Password [admin]: ' password
    password="${password:-admin}"
    if [ -z "$password" ]; then
      echo "Please enter a password!"
    else
      break
    fi
  done

}

function get_drupal_version() {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  case "$1" in
  "11")
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drupal 11 version"
    echo
    d11_options=(
      11.x-dev
      11.1.6
      11.1.5
      11.1.4
      11.1.3
      11.1.2
      11.1.1
      11.1.0
      11.0.13
      11.0.12
      11.0.11
      11.0.10
      11.0.9
      11.0.8
      11.0.7
      11.0.6
      11.0.5
      11.0.4
      11.0.3
      11.0.2
      11.0.1
      11.0.0
    )

    select_option "${d11_options[@]}"
    d11_choice=$?
    drupal_version="${d11_options[d11_choice]}"
    ;;
  "10")
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drupal 10 version"
    echo
    d10_options=(
      10.4.0
      10.3.0
      10.2.0
      10.1.0
      10.0.0
    )

    select_option "${d10_options[@]}"
    d10_choice=$?
    drupal_version="${d10_options[d10_choice]}"
    ;;
  "9")
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drupal 9 version"
    echo
    d9_options=(
      9.5.0
      9.4.0
      9.3.0
      9.2.0
      9.1.0
      9.0.0
    )

    select_option "${d9_options[@]}"
    d9_choice=$?
    drupal_version="${d9_options[d9_choice]}"
    ;;
  "8")
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drupal 8 version"
    echo
    d8_options=(
      8.9.0
      8.8.0
    )

    select_option "${d8_options[@]}"
    d8_choice=$?
    drupal_version="${d8_options[d8_choice]}"
    ;;

  esac

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

}

function get_php_version {
  case "$drupal_version" in
  "11.x-dev" | "11.1.7" | "11.1.6" | "11.1.5" | "11.1.4" | "11.1.3" | "11.1.2" | "11.1.1" | "11.1.0")
    php_options=(
      8.4
      8.3
    )
    ;;

  "11.0.13" | "11.0.12" | "11.0.11" | "11.0.10" | "11.0.9" | "11.0.8" | "11.0.7" | "11.0.6" | "11.0.5" | "11.0.4" | "11.0.3" | "11.0.2" | "11.0.1" | "11.0.0")
    php_options=(
      8.3
    )
    ;;

  "10.4.0")
    php_options=(
      8.4
      8.3
      8.2
      8.1
    )
    ;;

  "10.3.0")
    php_options=(
      8.3
      8.2
      8.1
    )
    ;;

  "10.2.0")
    php_options=(
      8.3
      8.2
      8.1
    )
    ;;

  "10.1.0" | "10.0.0")
    php_options=(
      8.2
      8.1
    )
    ;;

  "9.5.0")
    php_options=(
      8.1
      8.0
      7.4
    )
    ;;

  "9.4.0")
    php_options=(
      8.1
      8.0
      7.4
      7.3
    )
    ;;

  "9.3.0" | "9.2.0" | "9.1.0")
    php_options=(
      8.0
      7.4
      7.3
    )
    ;;

  "9.0.0")
    php_options=(
      8.0
      7.4
      7.3
    )
    ;;

  "8.9.0")
    php_options=(
      7.4
      7.3
      7.2
    )
    ;;

  "8.8.0")
    php_options=(
      7.3
      7.2
      7.1
    )
    ;;

  *)
    echo "Selected version not explicitly handled, you chose: ${options[$choice]}"
    php_options=(
      8.4
      8.3
      8.2
      8.1
      8.0
      7.4
    )
    ;;
  esac

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Select a PHP version"
  echo
  select_option "${php_options[@]}"
  php_choice=$?
  php_version="${php_options[$php_choice]}"
}

function get_drush_version() {

  if [[ -z "$drupal_version" && -n "$1" ]]; then
    drupal_version="$1"
  fi

  case "$drupal_version" in
  "11.1.6" | "11.1.5" | "11.1.4" | "11.1.3" | "11.1.2" | "11.1.1" | "11.1.0")
    drush_version=13
    ;;

  "11.0.0" | "11.0.1" | "11.0.2" | "11.0.3" | "11.0.4" | "11.0.5" | "11.0.6" | "11.0.7" | "11.0.8" | "11.0.9" | "11.0.10" | "11.0.11" | "11.0.12" | "11.0.13")
    if [[ "$clear_toggle" == "on" ]]; then
      clear
    fi
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drush version"
    drush_versions=(
      13
      12
    )
    select_option "${drush_versions[@]}"
    drush_choice=$?
    drush_version="${drush_versions[$drush_choice]}"
    ;;

  "10.2.0" | "10.3.0" | "10.4.0" | "10")
    drush_version=12
    ;;

  "10.0.0" | "10.1.0")
    drush_version=11
    ;;

  "9.4.0" | "9.5.0" | "9")
    drush_version=10
    ;;

  "9.0.0" | "9.1.0" | "9.2.0" | "9.3.0")
    drush_version=9
    ;;

  "8.4.0" | "8.5.0" | "8.6.0" | "8.7.0" | "8.8.0" | "8.9.0" | "8")
    drush_version=9
    ;;

  "8.0.0" | "8.1.0" | "8.2.0" | "8.3.0")
    drush_version=8
    ;;

  *)
    echo "Unknown or unsupported Drupal version: $drupal_version"
    drush_versions=()
    ;;
  esac
}

function make_site_folder() {

  mkdir "$1"
  cd "$1"

}

function install_drush() {
  if [ "$basic_drupal_version" = "11" ]; then
    ddev composer require drush/drush
  else
    local version="$1"
    ddev composer require "drush/drush:^${version}"
  fi
}

function get_dev_modules {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Do you want development modules installed?\n\nIncluding composer-patches, core-dev, devel, examples, admin_toolbar, webprofiler"
  echo
  dev_modules_options=(
    Yes
    No
  )

  select_option "${dev_modules_options[@]}"
  dev_modules_options_choice=$?
  dev_modules="${dev_modules_options[$dev_modules_options_choice]}"
}

function install_dev_modules {
  # Install and enable useful dev modules
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
}

function get_dev_things {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Do you want other development settings enabled?\n\nTwig development mode, JS and CSS aggregation, render cache, dynamic page cache, and page cache are bypassed."
  echo
  dev_things_options=(
    Yes
    No
  )

  select_option "${dev_things_options[@]}"
  dev_things_options_choice=$?
  dev_things="${dev_things_options[$dev_things_options_choice]}"

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
}

function set_dev_things {
  # Allow plugin sources
  ddev composer config allow-plugins.tbachert/spi true
  ddev composer config allow-plugins.cweagans/composer-patches true

  # Configure development settings
  ddev drush -y config-set system.performance js.preprocess 0
  ddev drush -y config-set system.performance css.preprocess 0
  ddev drush config:set system.theme twig_debug TRUE --yes

  # Enable twig development mode and do not cache markup
  ddev drush php:eval "\Drupal::keyValue('development_settings')->setMultiple(['disable_rendered_output_cache_bins' => TRUE, 'twig_debug' => TRUE, 'twig_cache_disable' => TRUE]);"
}

function get_custom_module {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Do you want a custom module set up?"
  echo
  custom_module_options=(
    No
    Yes
  )

  select_option "${custom_module_options[@]}"
  custom_module_options_choice=$?
  custom_module="${custom_module_options[$custom_module_options_choice]}"
}

function create_custom_module {
  module_name="${sitename}-module"
  module_name="${module_name,,}"
  module_name="${module_name//-/_}"

  # Run the drush generate command to create the module
  ddev drush generate -q module \
    --answer="Test module" \
    --answer="$module_name" \
    --answer="My test module" \
    --answer="Custom" \
    --answer="" \
    --answer="Yes" \
    --answer="Yes" \
    --answer="No"

  # Create module folders
  cd "web/modules/custom/$module_name"
  mkdir js
  mkdir css
  mkdir config
  mkdir config/install
  mkdir src
  mkdir src/Controller
  cd ../../../../

  ddev drush en "$module_name"
}

function get_custom_theme {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Do you want a custom theme set up?"
  echo
  custom_theme_options=(
    No
    Yes
  )

  select_option "${custom_theme_options[@]}"
  custom_theme_options_choice=$?
  custom_theme="${custom_theme_options[$custom_theme_options_choice]}"

}

function create_custom_theme {
  theme_name="${sitename}-theme"
  theme_name="${theme_name,,}"
  theme_name="${theme_name//-/_}"

  ddev drush generate -q theme \
    --answer="Test Theme" \
    --answer="$theme_name" \
    --answer="Olivero" \
    --answer="My test theme" \
    --answer="Custom" \
    --answer="No" \
    --answer="No"

  rm "web/themes/custom/$theme_name/css/base/elements.css"
  rm "web/themes/custom/$theme_name/css/layout/layout.css"
  rm "web/themes/custom/$theme_name/css/component/block.css"
  rm "web/themes/custom/$theme_name/css/component/tabs.css"
  rm "web/themes/custom/$theme_name/css/component/breadcrumb.css"
  rm "web/themes/custom/$theme_name/css/component/field.css"
  rm "web/themes/custom/$theme_name/css/component/header.css"
  rm "web/themes/custom/$theme_name/css/component/form.css"
  rm "web/themes/custom/$theme_name/css/component/buttons.css"
  rm "web/themes/custom/$theme_name/css/component/table.css"
  rm "web/themes/custom/$theme_name/css/component/messages.css"
  rm "web/themes/custom/$theme_name/css/component/sidebar.css"
  rm "web/themes/custom/$theme_name/css/component/node.css"
  rm "web/themes/custom/$theme_name/css/component/menu.css"
  rm "web/themes/custom/$theme_name/css/theme/print.css"

  # Create theme folders
  mkdir "web/themes/custom/$theme_name/config"
  mkdir "web/themes/custom/$theme_name/config/install"

  # Copy theme regions over
  SOURCE_FILE=web/core/themes/olivero/olivero.info.yml
  TARGET_FILE=web/themes/custom/$theme_name/$theme_name.info.yml
  yq eval ".regions = load(\"$SOURCE_FILE\").regions" "$TARGET_FILE" -i

  # Enable the theme and set as default
  ddev drush theme:enable $theme_name
  ddev drush config:set $theme_name.settings logo.use_default 0 -y
  ddev drush config:set system.theme default $theme_name -y
}

function get_git {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Do you want to initalize a git repo?"
  echo
  git_options=(
    Yes
    No
  )
  select_option "${git_options[@]}"
  git_options_choice=$?
  git_choice="${git_options[$git_options_choice]}"

  if [ "$git_choice" = "Yes" ]; then
    # Initalize git repo
    git init
    git branch -M main
    # Copy .gitignore over
    cp ../Extras/.gitignore .gitignore
  fi

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
}

function git_add_and_commit {
  if [ "$git_choice" = "Yes" ]; then
    git add .
    git commit -m "Initial commit" -q
  fi
}

function make_folders_copy_files {
  # Create the modules custom directory
  mkdir -p web/modules/custom

  # Create the modules contrib directory
  mkdir -p web/modules/contrib

  # Create the themes custom directory
  mkdir -p web/themes/custom

  # Create the themes contrib directory
  mkdir -p web/themes/contrib

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
  cp ../Extras/launch.json .vscode/launch.json

  # Copy phpstan.neon over
  cp ../Extras/phpstan.neon phpstan.neon
}

function change_settings {
  echo "\$settings['config_sync_directory'] = '../config/default/sync';" >>"web/sites/default/settings.php"
  echo "\$settings['file_private_path'] = '../private';" >>"web/sites/default/settings.php"
  echo "\$settings['skip_permissions_hardening'] = FALSE;" >>"web/sites/default/settings.php"
}

function set_permissions {
  # Set the permissions
  chmod 644 "web/sites/default/settings.php"
  chmod 755 "web/sites/default"
}

function enable_phpmyadmin {
  # Enable phpmyadmin in DDev
  yes | ddev phpmyadmin
}

function export_config {
  # Export config
  ddev drush cex -y
}

function get_dcms_install {
  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi
  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Do you want to go through the site install steps in Drupal CMS site GUI, or automate it using this script?"
  echo
  dcms_auto_install_options=(
    "Install using Drupal CMS"
    "Use this script"
  )

  select_option "${dcms_auto_install_options[@]}"
  dcms_auto_install_options_choice=$?
  dcms_install="${dcms_auto_install_options[$dcms_auto_install_options_choice]}"
}

function get_project_stable_version() {

  MODULE="$1" # Replace with any module machine name

  # Use a Python script inline to extract text from the page
  stable_version=$(
    python3 <<EOF
import requests
from bs4 import BeautifulSoup

# Issue queue URL to scrape
project_url="$project_url"
issue_response = requests.get(project_url)
issue_soup = BeautifulSoup(issue_response.text, "html.parser")

# Find the first element with class "stability-stable"
sv = issue_soup.find('div', class_='stability-stable')

# Within that div, find the version span
vs = sv.find('span', class_='views-field-field-release-version')

# Extract the version from the <a> tag
version = vs.find('a').text.strip()

if version:
    print(version)
EOF
  )
}

function get_project_latest_drupal_version {
  # From # project page get the drupal version
  # Use a Python script inline to extract text from the page

  latest_version=$(
    python3 <<EOF
import requests
import re
from bs4 import BeautifulSoup

# Issue queue URL to scrape
project_url="$project_url"
issue_response = requests.get(project_url)
issue_soup = BeautifulSoup(issue_response.text, "html.parser")

# Find the first element with class "stability-stable"
sv = issue_soup.find('div', class_='stability-stable')

# Find the <small> tag
small_tag = sv.find('small', string=re.compile(r'^Works with Drupal:'))

# Extract text
text = small_tag.get_text()

# Extract version numbers using regex and convert to integers
versions = list(map(int, re.findall(r'\^(\d+)', text)))

# Get the latest version
latest_version = max(versions) if versions else None

if latest_version:
    print(latest_version)
EOF
  )
  echo "$latest_version"
}

function get_issue_url {

  if [[ "$clear_toggle" == "on" ]]; then
    clear
  fi

  # Ask for issue url
  while true; do
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    read -p 'Issue URL [] : ' issue_url
    # Validate against expected Drupal.org issue URL format
    if [[ "$issue_url" =~ ^https:\/\/www\.drupal\.org\/project\/([a-zA-Z0-9_\-]+)\/issues\/([0-9]{1,8})$ ]]; then
      # Extract using BASH_REMATCH from the regex
      project_name="${BASH_REMATCH[1]}"
      issue_number="${BASH_REMATCH[2]}"
      break
    else
      echo "Invalid input. Issue URL must match:"
      echo "https://www.drupal.org/project/[project-name]/issues/[issue-number]"
    fi
  done

  # Use a Python script inline to extract link text from the page
  link_text=$(
    python3 <<EOF
import requests
from bs4 import BeautifulSoup

# Issue queue URL to scrape
issue_url="$issue_url"
issue_response = requests.get(issue_url)
issue_soup = BeautifulSoup(issue_response.text, "html.parser")

# Find the first element with class "remote-add-ssh"
link = issue_soup.find('a', attrs={'title': 'View branch in GitLab'})
if link:
    print(link.text.strip())
EOF
  )

  # Work out if Module or theme here..
  # Use a Python script inline to extract name from the page
  MT_project_type_raw=$(
    python3 <<EOF
import requests
from bs4 import BeautifulSoup

# Issue queue URL to scrape
issue_url="$issue_url"
issue_response = requests.get(issue_url)
issue_soup = BeautifulSoup(issue_response.text, "html.parser")

# Find the <nav> by class
nav = issue_soup.find('nav', class_='breadcrumb container-12')

# Get the first <a> tag inside it
if nav:
    first_link = nav.find('a')
    if first_link:
        print(first_link.text.strip())  # Output: Modules
EOF
  )

  # Set project URL here
  # https://www.drupal.org/project/cas/issues/3275551
  project_url="https://www.drupal.org/project/${project_name}"

  # Set the project type ..
  case "$MT_project_type_raw" in
  "Modules")
    MT_project_type="modules"
    ;;
  "Themes")
    MT_project_type="themes"
    ;;
  "Drupal core")
    MT_project_type="core"
    ;;
  *)
    echo "Unknown project type: $MT_project_type_raw"
    ;;
  esac
}

function check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' is not installed or not in PATH"
    exit 1
  else
    echo "'$1' is installed"
  fi
}

function check_python_package() {
  if ! python3 -c "import $1" >/dev/null 2>&1; then
    echo "ERROR: Python package '$1' is not installed"
    echo "Try: pip3 install $1"
    exit 1
  else
    echo "Python package '$1' is installed"
  fi
}

function check_prerequisites {
  # Exit immediately if any command fails
  set -e

  # Exit on error within functions, pipelines, or subshells
  set -o pipefail

  echo "🔍 Checking required tools and packages..."

  check_command ddev
  check_command git
  check_command python3
  check_command yq
  check_python_package bs4 # for Beautiful Soup 4

  echo "All dependencies are satisfied. Proceeding..."
}

#############################################################

red="\e[0;91m"
green="\e[0;92m"
blue="\e[0;94m"
reset="\e[0m"

#############################################################
# Check for installed software first..

# ANSI Escape Codes for retro green
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

# Clear screen and set up the retro atmosphere
if [[ "$clear_toggle" == "on" ]]; then
  clear
fi
echo -e "${GREEN}${BOLD}"
figlet -f small "DDev Drupal Site creator"
echo -e "${NC}"

# Progress bar
for i in {1..100}; do
  echo -ne "${GREEN}▓"
  sleep 0.01
done
echo -e "${NC}\n"

#Checking prerequisites
check_prerequisites

##############################################################

if [[ "$clear_toggle" == "on" ]]; then
  clear
fi
echo -e "${blue}Creating new DDev Drupal site${reset}"
echo -e " "
echo "What type of install is this?"
echo
drupal_install_options=(
  'Drupal site'
  'Drupal CMS site'
  'Drupal site based on an issue'
)

select_option "${drupal_install_options[@]}"
drupal_install_options_choice=$?
drupal_install="${drupal_install_options[$drupal_install_options_choice]}"

if [[ "$clear_toggle" == "on" ]]; then
  clear
fi

#########################################################

if [ "$drupal_install" = "Drupal site" ]; then
  get_basic_drupal_version
  get_site_details
  get_drupal_version "$basic_drupal_version"
  get_php_version
  get_drush_version ""
  make_site_folder "$sitename"

  project_type="drupal${basic_drupal_version}"
  ddev config --project-type="$project_type" --docroot=web

  ddev composer create-project "drupal/recommended-project:^${drupal_version}"

  ddev start
  install_drush "$drush_version"
  ddev drush site:install --account-name=$username --account-pass=$password -y --site-name=$sitename
  ddev drush config:set system.site name "$sanitized_title" --yes

  make_folders_copy_files

  get_dev_modules
  get_dev_things

  if [ "$dev_things" = "Yes" ]; then
    set_dev_things
  fi

  if [ "${dev_modules}" = "Yes" ]; then
    install_dev_modules
  fi

  get_custom_module
  if [ "${custom_module}" = "Yes" ]; then
    create_custom_module
  fi

  get_custom_theme
  if [ "${custom_theme}" = "Yes" ]; then
    create_custom_theme
  fi

  get_git

  change_settings
  set_permissions
  export_config

  ddev drush cr

  enable_phpmyadmin
  yes | ddev restart
  git_add_and_commit

  echo -e "${GREEN}${BOLD}"
  figlet -f small "Finished!"
  echo -e "${NC}"
fi

#########################################################

if [ "$drupal_install" = "Drupal CMS site" ]; then
  get_dcms_install
  if [ "$dcms_install" = "Use this script" ]; then
    get_site_details
    make_site_folder "$sitename"
    ddev config --project-type=drupal11 --docroot=web
    ddev start
    ddev composer create-project drupal/cms
    ddev drush site:install --account-name=$username --account-pass=$password -y --site-name=$sitename
    ddev drush config:set system.site name "$sanitized_title" --yes
  fi
  if [ "$dcms_install" = "Install using Drupal CMS" ]; then
    make_site_folder "drupal"
    ddev config --project-type=drupal11 --docroot=web
    ddev start
    ddev composer create-project drupal/cms
  fi
fi

#########################################################

if [ "$drupal_install" = "Drupal site based on an issue" ]; then
  get_issue_url
  if [ "$MT_project_type" = "core" ]; then
    # Install using justafish/ddev-drupal-core-dev and issue fork

    # Setting up repository for the first time
    git clone https://git.drupalcode.org/project/drupal.git "$project_name"
    cd "$project_name"

    # Config ddev
    ddev config --omit-containers=db --disable-settings-management

    # Run a composer install
    ddev composer install

    # Get ddev-core-dev add on
    ddev add-on get justafish/ddev-drupal-core-dev

    # Run a site install
    ddev drupal install standard

    # Add & fetch this issue fork’s repository
    git remote add "${project_name}-${issue_number}" \
      "git@git.drupal.org:issue/${project_name}-${issue_number}.git"

    # git fetch
    git fetch "${project_name}-${issue_number}"

    # Check out the branch
    git checkout -b "${link_text}" --track "${project_name}-${issue_number}/${link_text}"

    echo -e "${GREEN}${BOLD}"
    figlet -f small "Finished!"
    echo -e "${NC}"

  fi
  if [ "$MT_project_type" = "modules" ]; then
    get_project_stable_version

    basic_drupal_version=$(get_project_latest_drupal_version)

    get_site_details "$basic_drupal_version"
    make_site_folder "$sitename"

    project_type="drupal${basic_drupal_version}"
    ddev config --project-type="$project_type" --docroot=web
    ddev start

    recommended_project="recommended-project:^${basic_drupal_version}"
    ddev composer create-project "drupal/${recommended_project}"

    get_drush_version "$basic_drupal_version"
    install_drush "$drush_version"

    ddev drush site:install --account-name=$username --account-pass=$password -y --site-name=$sitename
    ddev drush config:set system.site name "$sanitized_title" --yes

    make_folders_copy_files

    # Go into contrib folder and clone issue module or theme
    cd "web/${MT_project_type}/contrib/"

    # Setting up repository for the first time
    git_clone_url="https://git.drupalcode.org/project/${project_name}.git"

    # Setting up repository for the first time
    git clone ${git_clone_url}
    cd ${project_name}

    # Add & fetch this issue fork’s repository
    git remote add "${project_name}-${issue_number}" "git@git.drupal.org:issue/${project_name}-${issue_number}.git"
    git fetch "${project_name}-${issue_number}"

    # Check out this branch for the first time
    git checkout -b "${link_text}" --track "${project_name}-${issue_number}/${link_text}"

    # Initialize an empty array
    dep_array=()

    # Get dependencies from the *.info.yml, add them to our array
    while read -r value; do
      dep_array+=("$value")
    done < <(yq eval '.dependencies[]' "cas.info.yml" | cut -d: -f1)

    # CD back out of the directory
    cd ../../../../

    # Install dependancies
    for element in "${dep_array[@]}"; do
      ddev composer require "drupal/$element"
    done

    # Enable the module/theme
    ddev drush en "${project_name}" -y

    # Clear the cache
    ddev drush cr

    get_dev_modules
    get_dev_things

    if [ "$dev_things" = "Yes" ]; then
      set_dev_things
    fi

    if [ "${dev_modules}" = "Yes" ]; then
      install_dev_modules
    fi

    get_custom_module
    if [ "${custom_module}" = "Yes" ]; then
      create_custom_module
    fi

    get_custom_theme
    if [ "${custom_theme}" = "Yes" ]; then
      create_custom_theme
    fi

    get_git

    change_settings
    set_permissions
    export_config

    ddev drush cr
    enable_phpmyadmin
    yes | ddev restart
    git_add_and_commit

    echo -e "${GREEN}${BOLD}"
    figlet -f small "Finished!"
    echo -e "${NC}"

  fi
  if [ "MT_project_type" = "themes" ]; then
    # Do some stuff to deal with themes here
    dog="Woof"
  fi
fi

#########################################################
