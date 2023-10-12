#!/usr/bin/env bash

printf "Select flavor to build\n"
# Bump build number
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml
app_name=$(grep -m 1 'name: ' pubspec.yaml | head -1 | sed 's/name: //')
version=$(grep 'version: ' pubspec.yaml | sed 's/version: //' | sed 's/+/_/')
file_name="${app_name}_${version}"
echo "Preparing lib: $file_name"

# Generate assets
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Commit and tag this change.
git add .
git commit -m "$version"
git tag "$version" -f