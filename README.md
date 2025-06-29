# Minimal Fin

A lightweight, minimal desktop client for Jellyfin media servers built with Flutter. This application provides a clean,
frameless window that displays your Jellyfin server's web interface with enhanced desktop integration.

## Features

- **Minimal Design**: Clean, frameless window interface that focuses on your media content
- **Desktop Integration**: Native window controls (minimize, maximize, close) with hover effects
- **WebView2 Integration**: Uses Microsoft WebView2 for optimal web content rendering on Windows
- **Persistent Settings**: Remembers your server configuration between sessions

## Requirements

- Windows 10/11 (WebView2 Runtime required)
- Flutter 3.0 or higher
- A running Jellyfin server

## Installation

### Prerequisites

1. Ensure you have WebView2 Runtime installed on your system. Most modern Windows installations include this by default.
2. Have a Jellyfin server running and accessible on your network.

### Building from Source

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd minimal_fin
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Build the application:
   ```bash
   flutter build windows
   ```

4. Run the application:
   ```bash
   flutter run -d windows
   ```

## Usage

### First Launch

1. Launch the application
2. You'll be automatically redirected to the settings page
3. Enter your Jellyfin server URL (e.g., `http://192.168.1.100:8096` or `https://jellyfin.example.com`)
4. Click "Save and Connect"
5. The application will load your Jellyfin web interface

### Navigation

- **Settings**: Hover over the top of the window and click the settings icon to change your server URL
- **Window Controls**: Use the minimize, maximize, and close buttons that appear when hovering over the top-right area
- **Fullscreen**: The application intercepts Jellyfin's fullscreen button to provide native window maximization

### Settings

The application stores your server URL locally using Hive database. Your settings persist between application restarts.

## Project Structure

```
lib/
├── main.dart                          # Application entry point and initialization
├── model/
│   ├── constants.dart                 # Global constants and WebView environment
│   └── settings_storage.dart          # Settings persistence using Hive
└── view/
    ├── routing/
    │   └── app_routes.dart            # Application routing configuration
    ├── screens/
    │   ├── settings_page.dart         # Server configuration screen
    │   └── web_view_page.dart         # Main Jellyfin web interface
    └── widgets/
        ├── page_wrapper.dart          # Common page layout wrapper
        └── top_buttons_bar.dart       # Window controls and navigation
```

## Technical Details

### Architecture

- **Flutter Framework**: Cross-platform UI toolkit
- **WebView Integration**: Uses `flutter_inappwebview` for web content rendering
- **State Management**: Built-in Flutter state management with StatefulWidget
- **Routing**: Go Router for declarative navigation
- **Storage**: Hive for lightweight local data persistence
- **Window Management**: Custom window controls using `window_manager`

### Key Components

- **WebViewButtonModifications**: JavaScript injection system for customizing Jellyfin's web interface
- **PageWrapper**: Consistent layout wrapper with drag-to-resize functionality
- **TopButtonsBar**: Hover-activated window controls with smooth animations
- **Settings Validation**: URL validation with user-friendly error messages

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter/Dart coding conventions
- Add documentation for new classes and methods
- Test your changes thoroughly
- Update this README if you add new features

## License

This project is open source. Please check the LICENSE file for details.

## Troubleshooting

### WebView2 Issues

If you encounter WebView2 related errors, ensure you have the WebView2 Runtime installed:

- Download from [Microsoft WebView2](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

### Connection Issues

- Verify your Jellyfin server is running and accessible
- Check that the URL includes the protocol (http:// or https://)
- Ensure there are no firewall restrictions blocking the connection
