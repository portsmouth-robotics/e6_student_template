#!/usr/bin/env bash

# Run this script once after creating your project from the template.
# It renames the ROS 2 package from e6_student_template to your group package name.

set -e

OLD_NAME="e6_student_template"
NEW_NAME="$1"

if [ -z "$NEW_NAME" ]; then
    echo "Usage:"
    echo "  ./rename_package.sh <new_package_name>"
    echo
    echo "Example:"
    echo "  ./rename_package.sh e6_group_08"
    exit 1
fi

if [[ ! "$NEW_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    echo "Error: package name must:"
    echo "  - start with a lowercase letter"
    echo "  - contain only lowercase letters, numbers, and underscores"
    exit 1
fi

if [ ! -f "package.xml" ] || [ ! -f "setup.py" ]; then
    echo "Error: run this script from the root of the student package."
    exit 1
fi

if [ "$NEW_NAME" = "$OLD_NAME" ]; then
    echo "Package is already named $OLD_NAME."
    exit 0
fi

echo "Renaming ROS 2 package:"
echo "  $OLD_NAME"
echo "  -> $NEW_NAME"
echo

# Rename the Python package directory.
if [ -d "$OLD_NAME" ]; then
    mv "$OLD_NAME" "$NEW_NAME"
fi

# Rename the ament resource marker.
if [ -f "resource/$OLD_NAME" ]; then
    mv "resource/$OLD_NAME" "resource/$NEW_NAME"
fi

# Replace references to the old package name in the package metadata
# and Python setup files.
sed -i "s/$OLD_NAME/$NEW_NAME/g" package.xml setup.py setup.cfg

# Replace any remaining references inside the Python source files.
grep -rl "$OLD_NAME" "$NEW_NAME" 2>/dev/null | while read -r file; do
    sed -i "s/$OLD_NAME/$NEW_NAME/g" "$file"
done

echo "Rename complete."
echo
echo "New package name: $NEW_NAME"
echo
echo "Rebuild your workspace with:"
echo "  cd ~/dobot_ws"
echo "  colcon build --packages-select $NEW_NAME"
echo "  source install/setup.bash"