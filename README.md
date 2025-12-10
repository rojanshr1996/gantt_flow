# Gantt Mobile 📊

A comprehensive scheduling and project management application built with Flutter that integrates with Google Calendar to provide powerful Gantt Chart visualization. This app enables users to manage multiple calendars, create events, and visualize project timelines with an intuitive interface.

## 🌟 Overview

Gantt Mobile transforms traditional calendar management by providing a visual timeline representation of events across multiple Google Calendars. Users can efficiently manage schedules, identify conflicts, prevent overbooking, and collaborate with team members through shared Google Calendars.

### Key Benefits
- **Visual Timeline Management**: See all events across multiple calendars in a single Gantt Chart view
- **Conflict Prevention**: Quickly identify scheduling gaps and overlapping events
- **Team Collaboration**: Share calendars with team members for coordinated planning
- **Cross-Platform Sync**: Real-time synchronization with Google Calendar across all devices
- **PDF Export**: Generate professional timeline reports for meetings and presentations

## 🚀 Features

### 📅 Calendar Management
- **Multi-Calendar Support**: Add and manage multiple Google Calendars simultaneously
- **Real-time Sync**: Automatic synchronization with Google Calendar
- **Calendar Selection**: Choose which calendars to display in the Gantt Chart
- **Shared Calendar Access**: View and manage shared Google Calendars from team members

### 📊 Gantt Chart Visualization
- **Timeline View**: Visual representation of events across time periods
- **Multiple Time Scales**: Switch between Month and Year views
- **Interactive Interface**: Tap events to view details and make modifications
- **Color-coded Events**: Different colors for different calendars and event types
- **Responsive Design**: Optimized for various screen sizes and orientations

### 📝 Event Management
- **Create Events**: Add new events directly to Google Calendar from the app
- **Edit Events**: Modify existing events with full synchronization
- **Delete Events**: Remove events with confirmation dialogs
- **Event Details**: View comprehensive event information including:
  - Title and description
  - Start and end dates/times
  - Location information
  - Attendee management
  - File attachments from Google Drive

### 👥 Collaboration Features
- **Attendee Management**: Add and manage event attendees
- **Google Drive Integration**: Attach files and images from Google Drive
- **Shared Calendar Support**: Access calendars shared by other users
- **Real-time Updates**: See changes made by other users instantly

### 📄 Export & Sharing
- **PDF Generation**: Create professional PDF reports of Gantt Charts
- **Timeline Export**: Export specific date ranges and calendar combinations
- **Share Reports**: Share generated PDFs through various platforms
- **Print Support**: Direct printing capabilities for physical copies

## 🛠️ Technical Specifications

### Flutter & Dart Versions
- **Flutter SDK**: `>=3.0.0 <4.0.0`
- **Dart SDK**: `>=3.0.0 <4.0.0`
- **App Version**: `1.0.0+1`

### Core Dependencies
- **Authentication**: `firebase_auth ^5.7.0`, `google_sign_in ^6.3.0`
- **Google APIs**: `googleapis ^14.0.0`
- **State Management**: `provider ^6.1.5`
- **UI Components**: `font_awesome_flutter ^10.9.1`
- **Date/Time**: `intl ^0.20.0`, `date_time_picker_plus ^1.0.1`
- **PDF Generation**: `pdf ^3.11.1`, `printing ^5.13.4`
- **Storage**: `shared_preferences ^2.5.3`
- **Utilities**: `url_launcher ^6.3.2`, `fluttertoast ^9.0.0`

### Architecture
- **Design Pattern**: Provider-based state management
- **Project Structure**: Modular architecture with separation of concerns
- **API Integration**: Google Calendar API and Google Drive API
- **Authentication**: Firebase Authentication with Google Sign-In

## 📦 Installation & Setup

### Prerequisites
1. **Flutter SDK**: Install Flutter 3.0.0 or higher
   ```bash
   flutter --version
   ```

2. **Development Environment**:
   - Android Studio / VS Code with Flutter extensions
   - Xcode (for iOS development on macOS)

3. **Google Cloud Console Setup**:
   - Create a project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Google Calendar API and Google Drive API
   - Create OAuth 2.0 credentials

4. **Firebase Setup**:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Google Sign-In provider

### Setup Instructions

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd gantt-mobile
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Firebase Configuration

**Android Setup:**
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory

**iOS Setup:**
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add it to the iOS project in Xcode

#### 4. Google APIs Configuration
1. Configure OAuth 2.0 credentials in Google Cloud Console
2. Add authorized redirect URIs for your app
3. Download and configure the OAuth client configuration

#### 5. Generate SHA-1 Certificate (Android)
```bash
# Run the provided script
./get_sha1.sh

# Add the SHA-1 fingerprint to Firebase Console and Google Cloud Console
```

#### 6. Generate App Icons and Splash Screen
```bash
# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

#### 7. Run the Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 🏗️ Project Structure

```
lib/
├── base/               # Base classes and utilities
├── model/              # Data models and entities
│   ├── calendar_model.dart
│   ├── event_model.dart
│   └── user_model.dart
├── providers/          # State management providers
│   ├── auth_provider.dart
│   ├── calendar_provider.dart
│   └── event_provider.dart
├── screens/            # UI screens and pages
│   ├── auth/           # Authentication screens
│   ├── home/           # Home and Gantt Chart screens
│   ├── event/          # Event management screens
│   └── profile/        # User profile screens
├── services/           # Business logic and API services
│   ├── auth_service.dart
│   ├── calendar_service.dart
│   ├── google_api_service.dart
│   └── pdf_service.dart
├── styles/             # App themes and styling
│   ├── colors.dart
│   ├── text_styles.dart
│   └── themes.dart
├── widgets/            # Reusable UI components
│   ├── gantt_chart_widget.dart
│   ├── calendar_selector.dart
│   └── event_card.dart
└── main.dart           # App entry point
```

## 🎯 User Journey & Features

### Authentication Flow
#### 🔐 Authentication Process

The app implements a secure authentication flow using Google Sign-In integrated with Firebase Authentication:

**Authentication Features:**
- **Google Sign-In**: Seamless login using Google accounts
- **Firebase Integration**: Secure user session management
- **Permission Handling**: Automatic request for necessary permissions
- **Session Persistence**: Remember user login across app sessions

**Required Permissions:**
- **Google Calendar**: Access to read, create, edit, and delete calendar events
- **Google Drive**: Access to attach files and images from user's Drive
- **Profile Information**: Basic profile data for user identification

**Security Measures:**
- OAuth 2.0 authentication flow
- Secure token management
- Automatic token refresh
- Encrypted user data storage

<div align="center">
<img src="assets/screenshots/login.png" alt="Login Screen" height="380" width="170"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/googleSign.png" alt="Google Account Selection" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/googlePermission.png" alt="Permission Grant Screen" height="380" width="170">
</div>

---

#### 🏠 Home Screen & Dashboard

The home screen serves as the central hub for all calendar and project management activities:

**Dashboard Features:**
- **Calendar Overview**: Display all added calendars in a unified view
- **Quick Actions**: Easy access to primary functions through action buttons
- **Gantt Chart Display**: Visual timeline representation of all events
- **Navigation Menu**: Access to all app features and settings

**Calendar Management:**
- **Add Calendars**: Select from available Google Calendars to display
- **Calendar Selection Dialog**: Choose which calendars to include in the Gantt view
- **Multi-Calendar Support**: Display events from multiple calendars simultaneously
- **Color Coding**: Each calendar has a unique color for easy identification

**View Options:**
- **Month View**: Detailed monthly timeline with daily granularity
- **Year View**: Annual overview for long-term planning
- **Toggle Views**: Easy switching between different time scales
- **Zoom Controls**: Adjust timeline granularity for better visibility

<div align="center">
<img src="assets/screenshots/home.png" alt="Home Dashboard" height="380" width="170">
</div>

**Gantt Chart Visualization:**
- **Timeline Representation**: Events displayed as horizontal bars across time
- **Event Duration**: Visual representation of event start and end times
- **Overlap Detection**: Identify scheduling conflicts at a glance
- **Interactive Elements**: Tap events for detailed information

<div align="center">
<img src="assets/screenshots/addCalendar.png" alt="Add Calendar Dialog" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/ganttChart.png" alt="Gantt Chart View" height="380" width="170">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/changeGanttView.png" alt="View Toggle Options" height="380" width="170">
</div>

**Action Menu:**
The floating action menu provides quick access to essential functions:

- **📅 Add Calendar**: Include new Google Calendars in the Gantt view
- **➕ Add Event**: Create new events in selected calendars
- **📄 Generate PDF**: Export current Gantt Chart as PDF document

<div align="center">
<img src="assets/screenshots/menubar.png" alt="Action Menu Bar" height="50" width="250">
</div>

---

#### 📝 Event Management System

The app provides comprehensive event management capabilities with full Google Calendar integration:

**Event Creation:**
- **Direct Integration**: Create events directly in Google Calendar from the app
- **Real-time Sync**: Events appear immediately in the Gantt Chart timeline
- **Comprehensive Details**: Add title, description, location, and timing information
- **Calendar Selection**: Choose which calendar to create the event in
- **Recurring Events**: Support for repeating events and series

**Advanced Event Features:**
- **👥 Attendee Management**: Add and manage event participants
- **📎 File Attachments**: Attach documents and images from Google Drive
- **🔔 Notifications**: Set custom reminders and alerts
- **🌍 Time Zones**: Handle events across different time zones
- **📍 Location Services**: Add and display event locations

<div align="center">
<img src="assets/screenshots/addEvent.png" alt="Event Creation Form" height="380" width="170">
</div>

**Event Operations:**
- **✏️ Edit Events**: Modify existing events with full synchronization
- **🗑️ Delete Events**: Remove events with confirmation dialogs
- **📋 View Details**: Comprehensive event information display
- **🔄 Sync Status**: Real-time synchronization with Google Calendar

**Event Details Screen:**
- **Complete Information**: View all event details in an organized layout
- **Attendee List**: See all participants and their response status
- **Attachment Access**: View and download attached files
- **Quick Actions**: Edit, delete, or duplicate events with one tap

<div align="center">
<img src="assets/screenshots/eventDetail.png" alt="Event Details View" height="380" width="170"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="assets/screenshots/deleteEvent.png" alt="Event Deletion Confirmation" height="380" width="170">
</div>

**Synchronization Features:**
- **Bi-directional Sync**: Changes sync across all Google Calendar instances
- **Conflict Resolution**: Handle simultaneous edits gracefully
- **Offline Support**: Cache events for offline viewing
- **Real-time Updates**: See changes made by other users instantly

---

#### 👤 User Profile & Settings

The profile section provides user information and app configuration options:

**Profile Information:**
- **Google Account Integration**: Profile data automatically synced from Google account
- **User Details**: Display name, email, and profile picture
- **Account Status**: Show authentication and sync status
- **Privacy Settings**: Manage data sharing and privacy preferences

**App Settings:**
- **Theme Preferences**: Light/dark mode selection
- **Notification Settings**: Configure alert preferences
- **Sync Options**: Control synchronization frequency
- **Language Settings**: Multi-language support options

**Account Management:**
- **Sign Out**: Secure logout with data cleanup
- **Account Switching**: Support for multiple Google accounts
- **Data Management**: Control local data storage and cache
- **Privacy Controls**: Manage permissions and data access

<div align="center">
<img src="assets/screenshots/profile.png" alt="User Profile Screen" height="380" width="170">
</div>

---

#### 📄 PDF Export & Reporting

Advanced PDF generation capabilities for professional reporting and sharing:

**PDF Generation Features:**
- **High-Quality Output**: Professional-grade PDF documents
- **Custom Date Ranges**: Export specific time periods
- **Calendar Selection**: Choose which calendars to include
- **Multiple Formats**: Various layout options and orientations
- **Branding Options**: Add logos and custom headers

**Export Options:**
- **📱 Device Storage**: Save PDFs to local device storage
- **📤 Share Directly**: Share via email, messaging, or cloud services
- **🖨️ Print Support**: Direct printing to connected printers
- **☁️ Cloud Upload**: Save to Google Drive or other cloud services

**PDF Customization:**
- **Layout Options**: Portrait or landscape orientation
- **Time Scale**: Month, week, or custom date ranges
- **Color Schemes**: Match your brand or preferences
- **Detail Level**: Choose information density and detail
- **Header/Footer**: Add custom text and metadata

**Use Cases:**
- **📊 Project Reports**: Generate timeline reports for stakeholders
- **📋 Meeting Materials**: Create agenda timelines for meetings
- **📈 Progress Tracking**: Document project milestones and progress
- **🤝 Client Presentations**: Professional timeline presentations

<div align="center">
<img src="assets/screenshots/ganttpdf.png" alt="PDF Generation Interface" height="380" width="170">
</div>

---

## 🔧 Configuration & Customization

### Environment Configuration
```bash
# Development environment
flutter run --flavor dev

# Production environment
flutter run --flavor prod --release
```

### API Configuration
1. **Google Calendar API**: Configure scopes and permissions
2. **Google Drive API**: Set up file access permissions
3. **Firebase**: Configure authentication and analytics

### Customization Options
- **Themes**: Customize colors, fonts, and UI elements
- **Branding**: Add company logos and custom styling
- **Localization**: Support for multiple languages
- **Feature Flags**: Enable/disable specific features

## 🚀 Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

### Code Signing
- Configure Android signing keys
- Set up iOS provisioning profiles
- Manage certificates and identifiers

## 🧪 Testing

### Test Coverage
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter test --coverage
```

### Testing Strategy
- **Unit Tests**: Core business logic and utilities
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user workflows
- **API Tests**: Google Calendar and Drive integration

## 📱 Platform-Specific Features

### Android
- **Material Design**: Native Android UI components
- **Adaptive Icons**: Support for various launcher styles
- **Background Sync**: Efficient background synchronization
- **Notification Channels**: Organized notification management

### iOS
- **Cupertino Design**: Native iOS UI elements
- **App Store Guidelines**: Full compliance with iOS standards
- **Background App Refresh**: Intelligent background updates
- **iOS Shortcuts**: Siri shortcuts integration

## 🤝 Contributing

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the coding standards and guidelines
4. Write tests for new functionality
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Write comprehensive documentation
- Maintain test coverage above 80%

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🆘 Support & Documentation

### Getting Help
- **Issues**: Report bugs and request features via GitHub Issues
- **Documentation**: Comprehensive guides in the `/docs` folder
- **API Reference**: Detailed API documentation available
- **Community**: Join our developer community for support

### Troubleshooting
- **Authentication Issues**: Check Google Cloud Console configuration
- **Sync Problems**: Verify API permissions and network connectivity
- **Performance**: Monitor app performance and optimize as needed

## 📋 Version History

- **v1.0.0+1**: Initial release with core Gantt Chart functionality
- Enhanced Google Calendar integration
- Professional PDF export capabilities
- Multi-platform support with native UI elements

---

**Built with ❤️ using Flutter and Google APIs**

*Transform your calendar management with visual timeline planning*




