#!/bin/bash


function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
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
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
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
echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
read -p 'Sitename [Dev]: ' initial_sitename
initial_sitename=${initial_sitename:-Dev}
clear

sitenumber=$(printf "%06d" $(( RANDOM % 1000000 )))
sitename="${initial_sitename}-${sitenumber}"

echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
read -p "Username [admin]: " username
username=${username:-admin}

clear
echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"

while true; do
    read -p 'Email [someone@example.com]: ' email
    email=${email:-someone@example.com}
    if [ -z "$email" ]; then
     echo "Please enter an email address!";
    else
     break;
    fi
done

clear
echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"


while true; do
    read -p 'Password [admin]: ' password
    password=${password:-admin}
    if [ -z "$password" ]; then
     echo "Please enter a password!";
    else
     break;
    fi
done

clear
echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"

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

clear






case "${d_options[$d_choice]}" in
"11")
echo "Select a Drupal 11 version"
echo
d11_options=(
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
  "11.1.6"|"11.1.5"|"11.1.4"|"11.1.3"|"11.1.2"|"11.1.1"|"11.1.0")
    php_options=(
      8.4
      8.3
    )
    ;;

  "11.0.13"|"11.0.12"|"11.0.11"|"11.0.10"|"11.0.9"|"11.0.8"|"11.0.7"|"11.0.6"|"11.0.5"|"11.0.4"|"11.0.3"|"11.0.2"|"11.0.1"|"11.0.0")
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

  "9.3.0"|"9.2.0"|"9.1.0")
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


echo "Select a PHP version"
echo
select_option "${php_options[@]}"
php_choice=$?
phpversion="${php_options[$php_choice]}"


clear

echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"
echo -e "Drupal version : ${green}$drupal_version${reset}"
echo -e "PHP version : ${green}$phpversion${reset}"

clear

case "$drupal_version" in
  "11.1.6"|"11.1.5"|"11.1.4"|"11.1.3"|"11.1.2"|"11.1.1"|"11.1.0")
    drushversion=13
    ;;

  "11.0.0"|"11.0.1"|"11.0.2"|"11.0.3"|"11.0.4"|"11.0.5"|"11.0.6"|"11.0.7"|"11.0.8"|"11.0.9"|"11.0.10"|"11.0.11"|"11.0.12"|"11.0.13")
echo "Select a Drush version"
drush_versions=(
  12
  13
)
select_option "${drush_versions[@]}"
drush_choice=$?
drushversion="${drush_versions[$drush_choice]}"
    ;;

  "10.2.0"|"10.3.0"|"10.4.0")
    drushversion=12
    ;;

  "10.0.0"|"10.1.0")
    drushversion=11
    ;;

  "9.4.0"|"9.5.0")
    drushversion=10
    ;;

  "9.0.0"|"9.1.0"|"9.2.0"|"9.3.0")
    drushversion=9
    ;;

  "8.4.0"|"8.5.0"|"8.6.0"|"8.7.0"|"8.8.0"|"8.9.0")
    drushversion=9
    ;;

  "8.0.0"|"8.1.0"|"8.2.0"|"8.3.0")
    drushversion=8
    ;;

  *)
    echo "Unknown or unsupported Drupal version: $drupal_version"
    drush_versions=()
    ;;
esac

clear

echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"
echo -e "Drupal version : ${green}$drupal_version${reset}"
echo -e "PHP version : ${green}$phpversion${reset}"
echo -e "Drush version : ${green}$drushversion${reset}"

clear

echo "Do you want a custom module set up?"
echo
custom_module_options=(
Yes
No
)

select_option "${custom_module_options[@]}"
custom_module_options_choice=$?
custom_module="${custom_module_options[$custom_module_options_choice]}"

clear

echo "Do you want a custom theme set up?"
echo
custom_theme_options=(
Yes
No
)

select_option "${custom_theme_options[@]}"
custom_theme_options_choice=$?
custom_theme="${custom_theme_options[$custom_theme_options_choice]}"

clear

echo -e "${blue}Creating new Drupal site${reset}"
echo -e " "
echo -e "Sitename : ${green}$sitename${reset}"
echo -e "Username : ${green}$username${reset}"
echo -e "Email : ${green}$email${reset}"
echo -e "Password : ${green}$password${reset}"
echo -e "Drupal version : ${green}$drupal_version${reset}"
echo -e "PHP version : ${green}$phpversion${reset}"
echo -e "Drush version : ${green}$drushversion${reset}"
echo -e "Custom Module : ${green}$custom_module${reset}"
echo -e "Custom Theme : ${green}$custom_theme${reset}"

mkdir $sitename
cd $sitename
# pwd


# composer create-project drupal/recommended-project:$version $sitename
