#!/bin/bash

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

red="\e[0;91m"
green="\e[0;92m"
blue="\e[0;94m"
reset="\e[0m"

clear
echo -e "${blue}Creating new DDev Drupal site${reset}"
echo -e " "
echo "Do you want to install a DrupalCMS site?"
echo
drupal_cms_options=(
  No
  Yes
)

select_option "${drupal_cms_options[@]}"
drupal_cms_options_choice=$?
drupal_cms="${drupal_cms_options[$drupal_cms_options_choice]}"

clear

if [ "$drupal_cms" = "No" ]; then

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

  clear

  case "${d_options[$d_choice]}" in
  "11")
    echo -e "${blue}Creating new DDev Drupal site${reset}"
    echo -e " "
    echo "Select a Drupal 11 version"
    echo
    d11_options=(
      11.x-dev
      11.1.7
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

  clear

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
  phpversion="${php_options[$php_choice]}"

fi

if [ "$drupal_cms" = "Yes" ]; then

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

  echo -e "$dcms_install"

fi

if [ "$dcms_install" = "Use this script" ] || [ "$drupal_cms" = "No" ]; then

  clear

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "

  # Loop until valid input is provided
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

  clear
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

  if [ "$drupal_cms" = "Yes" ]; then
    basic_drupal_version=11
  fi

  clear

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo "Do you want to add the drupal version to the site name?"
  echo
  add_drupal_version_to_sitename_options=(
    Yes
    No
  )

  select_option "${add_drupal_version_to_sitename_options[@]}"
  add_drupal_version_to_sitename_options_choice=$?
  add_drupal_version_to_choice="${add_drupal_version_to_sitename_options[$add_drupal_version_to_sitename_options_choice]}"

  clear

  site_number=$(printf "%06d" $((RANDOM % 1000000)))

  if [ "$suffix_digits_choice" = "Yes" ]; then
    if [ "$add_drupal_version_to_choice" = "Yes" ]; then
      sitename="${initial_sitename}-${basic_drupal_version}-${site_number}"
    else
      sitename="${initial_sitename}-${site_number}"
    fi

  else
    sitename="${initial_sitename}"
    if [ "$add_drupal_version_to_choice" = "Yes" ]; then
      sitename="${initial_sitename}-${basic_drupal_version}"
    fi
  fi

  clear

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"

  default_site_title="${sitename//-/ }"

  while true; do
    read -p "Site Title ["${default_site_title}"] : " site_title
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

  clear

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

  clear
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

  clear
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

fi

clear

echo -e "${blue}Creating new DDev Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Site Title : ${green}$site_title${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"
echo -e "Drupal CMS : ${green}$drupal_cms${reset}"
if [ "$drupal_cms" = "No" ]; then
  echo -e "Drupal Basic version : ${green}$basic_drupal_version${reset}"
  echo -e "Drupal version : ${green}$drupal_version${reset}"
  echo -e "PHP version : ${green}$phpversion${reset}"
fi
clear

if [ "$drupal_cms" = "No" ]; then
  case "$drupal_version" in
  "11.1.6" | "11.1.5" | "11.1.4" | "11.1.3" | "11.1.2" | "11.1.1" | "11.1.0")
    drush_version=13
    ;;

  "11.0.0" | "11.0.1" | "11.0.2" | "11.0.3" | "11.0.4" | "11.0.5" | "11.0.6" | "11.0.7" | "11.0.8" | "11.0.9" | "11.0.10" | "11.0.11" | "11.0.12" | "11.0.13")
    echo "Select a Drush version"
    drush_versions=(
      13
      12
    )
    select_option "${drush_versions[@]}"
    drush_choice=$?
    drush_version="${drush_versions[$drush_choice]}"
    ;;

  "10.2.0" | "10.3.0" | "10.4.0")
    drush_version=12
    ;;

  "10.0.0" | "10.1.0")
    drush_version=11
    ;;

  "9.4.0" | "9.5.0")
    drush_version=10
    ;;

  "9.0.0" | "9.1.0" | "9.2.0" | "9.3.0")
    drush_version=9
    ;;

  "8.4.0" | "8.5.0" | "8.6.0" | "8.7.0" | "8.8.0" | "8.9.0")
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

fi

clear

echo -e "${blue}Creating new DDev Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Site Title : ${green}$site_title${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"
echo -e "Drupal CMS : ${green}$drupal_cms${reset}"
if [ "$drupal_cms" = "No" ]; then
  echo -e "Drupal Basic version : ${green}$basic_drupal_version${reset}"
  echo -e "Drupal version : ${green}$drupal_version${reset}"
  echo -e "PHP version : ${green}$phpversion${reset}"
  echo -e "Drush version : ${green}$drush_version${reset}"
fi

clear

if [ "$drupal_cms" = "No" ]; then

  if [ "$basic_drupal_version" = "11" ]; then
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
  fi

  clear

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

  clear

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

  clear

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

  clear

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "\nDo you want to work on an issue?\n
This will:

  • Clone the project
  • Add and fetch the issue fork's repository
  • Check out the issue branch

If this is a core issue, a site will be installed using the justafish/ddev-drupal-core-dev add-on.

This means the sitename, site title, user, and password will NOT be configurable.\n"

  echo
  issue_options=(
    Yes
    No
  )

  select_option "${issue_options[@]}"
  issue_options_choice=$?
  issue_choice="${issue_options[$issue_options_choice]}"

  clear

  # Ask for issue url
  if [ "$issue_choice" = "Yes" ]; then
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
  fi

  clear

  echo -e "${blue}Creating new DDev Drupal site${reset}"
  echo -e " "
  echo -e "Sitename : ${green}$sitename${reset}"
  echo -e "Site Title : ${green}$site_title${reset}"
  echo -e "Username : ${green}$username${reset}"
  echo -e "Email : ${green}$email${reset}"
  echo -e "Password : ${green}$password${reset}"
  echo -e "Drupal CMS : ${green}$drupal_cms${reset}"
  if [ "$drupal_cms" = "No" ]; then
    echo -e "Drupal Basic version : ${green}$basic_drupal_version${reset}"
    echo -e "Drupal version : ${green}$drupal_version${reset}"
    echo -e "PHP version : ${green}$phpversion${reset}"
    echo -e "Drush version : ${green}$drush_version${reset}"
  fi
  if [ "$basic_drupal_version" = "11" ]; then
    echo -e "Dev modules : ${green}$dev_things${reset}"
  fi
  echo -e "Dev settings : ${green}$dev_things${reset}"
  echo -e "Custom Module : ${green}$custom_module${reset}"
  echo -e "Custom Theme : ${green}$custom_theme${reset}"
  if [ "$issue_choice" = "Yes" ]; then
    echo -e "Issue Number : ${green}$issue_number${reset}"
    echo -e "Issue Project : ${green}$project_name${reset}"
  fi
  echo -e "You may need to enter your password for sudo or allow escalation. So don't walk away just yet."
fi

# Make the directory and cd into it
if [ "$drupal_cms" = "Yes" ]; then
  sitename="dcms"
  mkdir $sitename
  cd $sitename
fi

if [ "$drupal_cms" = "No" ]; then

  # Issue commands
  if [ "$issue_choice" = "Yes" ]; then

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

  # End of issue project section
  fi

  clear

  # Not sure if this bit makes sense..
  if [ "$issue_choice" = "No" ] || [ "$MT_project_type" != "core" ]; then
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
  fi

  clear

  # Here we check if we need to make a new site directory
  if [ "$issue_choice" = "Yes" ] && [ "$MT_project_type" = "core" ]; then

    nothing="nothing"
  else
    mkdir "$sitename"
    cd "$sitename"
  fi

  project_type="drupal${basic_drupal_version}"
else
  project_type="drupal11"
# End DrupalCMS = No line 737
fi

if [ "$MT_project_type" != "core" ]; then
  recommended_project="recommended-project:^${basic_drupal_version}"
  ddev config --project-type="$project_type" --docroot=web
  ddev start
fi

# DrupalCMS install starts here ##############################
if [ "$drupal_cms" = "Yes" ]; then

  ddev composer create-project drupal/cms

  # Use site info we collected if appropriate
  if [ "$dcms_install" = "Use this script" ]; then
    ddev drush site:install --account-name=$username --account-pass=$password -y --site-name=$sitename
    ddev drush config:set system.site name "$sanitized_title" --yes
  fi

# End DrupalCMS install bit ###################
else

  if [ "$issue_choice" = "Yes" ] && [ "$MT_project_type" = "core" ]; then
    # install using drupal issue fork
    # Setting up repository for the first time
    git clone https://git.drupalcode.org/project/drupal.git "$sitename"
    cd "$sitename"

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
  else

    # Not Drupal core issue site, so install normally
    ddev composer create-project "drupal/${recommended_project}"

    if [ "$basic_drupal_version" = "11" ]; then
      ddev composer require drush/drush
    else
      ddev composer require "drush/drush:^${drush_version}"
    fi

    # Site install using drush
    ddev drush site:install \
      --account-name="$username" \
      --account-pass="$password" \
      -y \
      --site-name="$sitename"

    if [ "$issue_choice" = "Yes" ] && [ "$MT_project_type" != "core" ]; then

      # Create the modules custom directory
      mkdir -p web/modules/custom

      # Create the modules contrib directory
      mkdir -p web/modules/contrib

      # Create the themes custom directory
      mkdir -p web/themes/custom

      # Create the themes contrib directory
      mkdir -p web/themes/contrib

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

    fi

  fi # End using drupal issue fork

  if [ "$issue_choice" = "Yes" ] && [ "$MT_project_type" = "core" ]; then

    # Create the modules custom directory
    mkdir -p modules/custom

    # Create the modules contrib directory
    mkdir -p modules/contrib

    # Create the themes custom directory
    mkdir -p themes/custom

    # Create the themes contrib directory
    mkdir -p themes/contrib

  else

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

    if [ "$dev_things" = "Yes" ]; then
      # Allow plugin sources
      ddev composer config allow-plugins.tbachert/spi true
      ddev composer config allow-plugins.cweagans/composer-patches true

      # Configure development settings
      ddev drush -y config-set system.performance js.preprocess 0
      ddev drush -y config-set system.performance css.preprocess 0
      ddev drush config:set system.theme twig_debug TRUE --yes

      # Enable twig development mode and do not cache markup
      ddev drush php:eval "\Drupal::keyValue('development_settings')->setMultiple(['disable_rendered_output_cache_bins' => TRUE, 'twig_debug' => TRUE, 'twig_cache_disable' => TRUE]);"
    fi
    ddev composer config extra.drupal-scaffold.gitignore true

    if [ "$dev_modules" = "Yes" ]; then

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
    fi

    if [ "$custom_module" = "Yes" ]; then

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

    fi

    if [ "$custom_theme" = "Yes" ]; then

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
    fi

    # Copy phpstan.neon over
    cp ../Extras/phpstan.neon phpstan.neon

    if [ "$git_choice" = "Yes" ]; then
      # Copy .gitignore over
      cp ../Extras/.gitignore .gitignore
    fi

    # Enable phpmyadmin in DDev
    yes | ddev phpmyadmin

    # Set the Site Title
    ddev drush config:set system.site name "$sanitized_title" --yes

    if [ "$git_choice" = "Yes" ]; then
      # Initalize git repo
      git init
      git branch -M main
    fi

    # Changes to settings.php
    echo "\$settings['config_sync_directory'] = '../config/default/sync';" >>"web/sites/default/settings.php"
    echo "\$settings['file_private_path'] = '../private';" >>"web/sites/default/settings.php"
    echo "\$settings['skip_permissions_hardening'] = FALSE;" >>"web/sites/default/settings.php"

    # Set the permissions
    chmod 644 "web/sites/default/settings.php"
    chmod 755 "web/sites/default"

    ddev drush cr

    # Export config
    ddev drush cex -y

    if [ "$git_choice" = "Yes" ]; then
      git add .
      git commit -m "Initial commit" -q
    fi

    ddev drush cr

    yes | ddev restart

  fi # End if statement about core issue

# End if statement about DrupalCMS
fi
