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

1. **Deploy via Vercel Dashboard**:
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your Git repository
   - Vercel will automatically detect Flutter and use the configuration

#### 3. Build Configuration

The project includes:
- `vercel.json` - Vercel configuration for static deployment
- `.vercelignore` - Files to exclude from deployment
- `package.json` - Build scripts and metadata

#### 4. Deployment Process

Vercel will automatically:
1. Detect Flutter web project
2. Use static deployment configuration
3. Serve the `build/web` directory
4. Handle routing for SPA (Single Page Application)

#### 5. Custom Domain

After deployment:
1. Go to your project settings in Vercel
2. Navigate to "Domains"
3. Add your custom domain
4. Update DNS records as instructed

### Build Process

1. **Local Build**:
   ```bash
   flutter build web --release
   ```

2. **Vercel Deployment**:
   - Vercel serves the `build/web` directory
   - All routes redirect to `index.html` for SPA
   - Static assets are served directly

### File Structure for Deployment

```
build/web/
├── index.html          # Main HTML file
├── main.dart.js        # Flutter compiled JavaScript
├── flutter_bootstrap.js # Flutter bootstrap
├── assets/             # App assets
├── icons/              # App icons
└── canvaskit/          # Canvas rendering (if enabled)
```

### Routing Configuration

The `vercel.json` handles:
- **Static assets**: `/assets/*`, `/icons/*`, `/canvaskit/*`
- **Flutter files**: `/flutter_bootstrap.js`, `/main.dart.js`
- **SPA routing**: All other routes redirect to `index.html`

### Troubleshooting

#### Common Issues

1. **Build Fails**:
   - Check Flutter version compatibility
   - Ensure all dependencies are properly configured
   - Verify `vercel.json` configuration

2. **Assets Not Loading**:
   - Check asset paths in `web/index.html`
   - Verify build output in `build/web/` directory

3. **Routing Issues**:
   - Ensure `vercel.json` routes are correct
   - Check that all routes redirect to `index.html`

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

**Note**: This deployment guide is specifically for Vercel static deployment. The configuration is optimized for Flutter web SPA applications. 