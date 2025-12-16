#!/bin/bash
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
# Use HTML renderer for better compatibility on static hosts (avoids WASM MIME issues)
flutter build web --release --base-href / --web-renderer html
echo "Build Complete!"
