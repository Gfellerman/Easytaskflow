#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter Doctor..."
flutter doctor -v

echo "Enabling Web..."
flutter config --enable-web

echo "Getting Dependencies..."
flutter pub get

echo "Building Web..."
flutter build web --release --base-href /

echo "Build Complete!"
