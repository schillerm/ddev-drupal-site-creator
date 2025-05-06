#!/bin/bash

pwd

# copy .gitignore over

# Define the target directory
TARGET_DIRECTORY="./"

# Create the config directory
mkdir -p "$TARGET_DIRECTORY/config"

# Create the config/default directory
mkdir -p "$TARGET_DIRECTORY/config/default"

# Create the config/default/sync directory
mkdir -p "$TARGET_DIRECTORY/config/default/sync"

# Create the private directory
mkdir -p "$TARGET_DIRECTORY/private"

# Create the .vscode directory
mkdir -p "$TARGET_DIRECTORY/.vscode"

# Add any initial configuration files if needed
cat <<EOL > "$TARGET_DIRECTORY/.vscode/launch.json"
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}"
            }
        }
    ]
}
EOL


# copy .gitignore over
cp ~/Documents/Sites/Extras/.gitignore "$TARGET_DIRECTORY/"

# copy pre-commit over
cp ~/Documents/Sites/Extras/pre-commit "$TARGET_DIRECTORY/./.git/hooks/pre-commit"

# Create the modules custom directory
mkdir -p "$TARGET_DIRECTORY/web/modules/custom"

# Create the themes custom directory
mkdir -p "$TARGET_DIRECTORY/web/themes/custom"


echo "Setup complete"
