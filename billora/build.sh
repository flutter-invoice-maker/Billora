#!/bin/bash

# Build script for Vercel Flutter Web deployment
set -e

echo "🚀 Starting Flutter Web Build for Vercel..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Installing Flutter..."
    
    # Install Flutter
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:`pwd`/flutter/bin"
    
    # Enable web support
    flutter config --enable-web
fi

# Verify Flutter installation
flutter --version

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Build web app
echo "🔨 Building Flutter web app..."
flutter build web --release --web-renderer html

# Verify build output
if [ -d "build/web" ]; then
    echo "✅ Build successful! Output directory: build/web"
    ls -la build/web/
else
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "🎉 Flutter web build completed successfully!" 