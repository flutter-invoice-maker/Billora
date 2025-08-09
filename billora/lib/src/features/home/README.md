# Home Feature - New Layout

## Overview
The home feature has been redesigned with a new layout that includes:

1. **Custom Header**: Logo, user info, and avatar with dropdown menu
2. **Tabbed Navigation**: Fixed bottom navigation with 4 main tabs
3. **Scan FAB**: Floating action button for bill scanning
4. **Responsive Design**: Works across different screen sizes

## Layout Components

### Header
- **Logo**: Billora logo on the left
- **User Info**: Display name and email (from authenticated user)
- **Avatar**: 
  - Shows Google profile photo if available
  - Falls back to user's first initial
  - Default person icon for guest users
- **Dropdown Menu**: Profile and Logout options

### Bottom Navigation
- **Dashboard** (Indigo): Overview and analytics
- **Customers** (Blue): Customer management
- **Products** (Purple): Product catalog
- **Invoices** (Green): Invoice management

### Scan FAB
- **Position**: Center-docked floating action button
- **Color**: Orange gradient
- **Function**: Navigate to bill scanner

## Usage

### HomePage
The main home page uses the new layout with tabbed content:

```dart
class HomePage extends StatefulWidget {
  // Uses custom header, tabbed navigation, and scan FAB
}
```

### MainLayoutWrapper
For other pages that need the same layout:

```dart
MainLayoutWrapper(
  currentTabIndex: 0, // 0-3 for Dashboard, Customers, Products, Invoices
  onTabChanged: (index) {
    // Handle tab changes
  },
  child: YourPageContent(),
)
```

## User Authentication

The layout automatically adapts based on authentication state:

- **Authenticated**: Shows user's display name, email, and avatar
- **Unauthenticated**: Shows "Guest User" placeholder

### Google Sign-In Support
- Automatically displays Google profile photo when available
- Falls back to user's first initial if no photo
- Handles network errors gracefully

## Navigation

### Tab Navigation
- Tabs are always visible at the bottom
- Current tab is highlighted with its theme color
- Tab changes are handled by the parent widget

### Scan Button
- Always accessible via the center FAB
- Navigates to `/bill-scanner` route
- Distinctive orange color to stand out

### User Menu
- Click avatar to open dropdown
- Click outside to close
- Options: Profile (coming soon), Logout

## Theme Colors

- **Dashboard**: `#6366F1` (Indigo)
- **Customers**: `#3B82F6` (Blue)
- **Products**: `#8B5CF6` (Purple)
- **Invoices**: `#10B981` (Green)
- **Scan FAB**: `#FF6B35` to `#FF8E53` (Orange gradient)
- **Avatar**: `#8B5FBF` (Purple)

## Future Enhancements

1. **Profile Page**: Implement user profile management
2. **Tab Content**: Add actual content to each tab
3. **Notifications**: Add notification badge to tabs
4. **Animations**: Add smooth transitions between tabs
5. **Customization**: Allow users to customize tab order 