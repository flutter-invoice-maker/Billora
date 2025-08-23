#!/bin/bash

# Vercel build script for Flutter Web
# This script will be executed by Vercel during the build process

set -e

echo "🚀 Starting Flutter Web Build for Vercel..."

# Function to install Flutter
install_flutter() {
    echo "📥 Installing Flutter..."
    
    # Clone Flutter repository
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:`pwd`/flutter/bin"
    
    # Enable web support
    flutter config --enable-web
    
    echo "✅ Flutter installed successfully"
}

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Installing Flutter..."
    install_flutter
else
    echo "✅ Flutter found in PATH"
fi

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
flutter --version

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please ensure you're in the Flutter project root."
    exit 1
fi

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build web app (removed --web-renderer flag)
echo "🔨 Building Flutter web app..."
flutter build web --release

# Verify build output
if [ -d "build/web" ]; then
    echo "✅ Build successful! Output directory: build/web"
    echo "📁 Build contents:"
    ls -la build/web/
    
    # Check for essential files
    if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
        echo "✅ Essential files found: index.html and main.dart.js"
    else
        echo "❌ Warning: Essential files missing from build output"
    fi
else
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "🎉 Flutter web build completed successfully!"
echo "📊 Build size: $(du -sh build/web | cut -f1)" 