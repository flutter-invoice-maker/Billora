# Billora Web Deployment Guide

## Deploy to Vercel

### Prerequisites
- Flutter SDK installed and configured
- Vercel account
- Git repository with your Flutter project

### Steps to Deploy

#### 1. Prepare Your Project
```bash
# Ensure Flutter web is enabled
flutter config --enable-web

# Get dependencies
flutter pub get

# Test web build locally
flutter build web --release
```

#### 2. Connect to Vercel

1. **Install Vercel CLI** (optional):
   ```bash
   npm i -g vercel
   ```

2. **Deploy via Vercel Dashboard**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your Git repository
   - Vercel will automatically detect Flutter and use the configuration

#### 3. Build Configuration

The project includes:
- `vercel.json` - Vercel configuration
- `.vercelignore` - Files to exclude from deployment
- `package.json` - Build scripts and metadata

#### 4. Environment Variables

Set these in Vercel dashboard if needed:
- `FLUTTER_VERSION` - Flutter version to use
- `NODE_VERSION` - Node.js version (default: 16)

#### 5. Custom Domain

After deployment:
1. Go to your project settings in Vercel
2. Navigate to "Domains"
3. Add your custom domain
4. Update DNS records as instructed

### Build Process

Vercel will automatically:
1. Install Flutter
2. Run `flutter pub get`
3. Execute `flutter build web --release`
4. Deploy the `build/web` directory

### Troubleshooting

#### Common Issues

1. **Build Fails**:
   - Check Flutter version compatibility
   - Ensure all dependencies are properly configured
   - Verify `vercel.json` configuration

2. **Assets Not Loading**:
   - Check asset paths in `web/index.html`
   - Verify `--base-href` configuration

3. **Performance Issues**:
   - Enable Flutter web optimizations
   - Use `--release` build mode
   - Implement proper caching strategies

#### Build Commands

```bash
# Local development
flutter run -d chrome

# Production build
flutter build web --release

# Build with custom base href
flutter build web --release --base-href /your-path/

# Analyze build size
flutter build web --analyze-size
```

### Performance Optimization

1. **Enable Web Optimizations**:
   ```dart
   // In main.dart
   if (kIsWeb) {
     // Web-specific optimizations
   }
   ```

2. **Asset Preloading**:
   - Use `<link rel="preload">` for critical resources
   - Implement lazy loading for non-critical assets

3. **Caching Strategy**:
   - Configure proper cache headers
   - Use service workers for offline support

### Monitoring

- **Vercel Analytics**: Built-in performance monitoring
- **Error Tracking**: Configure error reporting services
- **Performance Metrics**: Monitor Core Web Vitals

### Support

For deployment issues:
1. Check Vercel build logs
2. Verify Flutter web compatibility
3. Review `vercel.json` configuration
4. Test locally with `flutter build web`

---

**Note**: This deployment guide is specifically for Vercel. For other platforms, refer to their respective Flutter web deployment documentation. 