# Maternal Sentinel

Maternal Sentinel is a cross-platform application designed to improve maternal health monitoring and reporting. Built with Flutter, it supports Android, iOS, Web, Linux, macOS, and Windows platforms. The app empowers healthcare professionals and users to track, record, and analyze maternal health data, ensuring timely interventions and better outcomes.

## Table of Contents
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development](#development)
- [Testing](#testing)
- [Configuration](#configuration)
- [Important Notes](#important-notes)
- [Contributing](#contributing)
- [License](#license)

## Features
- User authentication and secure storage
- BVN (Bank Verification Number) verification (use BVN: `1111111111` for testing)
- Add and manage maternal health visits
- API integration for data synchronization
- Multi-platform support (Android, iOS, Web, Linux, macOS, Windows)
- Theming and responsive UI
- Modular code structure for scalability

## Project Structure
```
├── analysis_options.yaml         # Linting and analysis rules
├── pubspec.yaml                 # Flutter/Dart dependencies
├── build.gradle.kts             # Gradle build configuration
├── app/                         # Android-specific files
├── ios/                         # iOS-specific files
├── linux/                       # Linux-specific files
├── macos/                       # macOS-specific files
├── windows/                     # Windows-specific files
├── web/                         # Web-specific files
├── lib/
│   ├── main.dart                # App entry point
│   ├── app.dart                 # App configuration
│   ├── controllers/             # State management controllers
│   ├── repositories/            # Data repositories
│   ├── screens/                 # UI screens
│   ├── services/                # API and utility services
│   └── theme/                   # Theming and styles
├── test/                        # Unit and widget tests
└── README.md                    # Project documentation
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (comes with Flutter)
- Android Studio or Xcode (for mobile development)
- Chrome or compatible browser (for web)
- Git

### Installation
1. **Clone the repository:**
	 ```bash
	 git clone <repository-url>
	 cd maternal_sentinel
	 ```
2. **Install dependencies:**
	 ```bash
	 flutter pub get
	 ```
3. **Run the app:**
	 - **Android/iOS:**
		 ```bash
		 flutter run
		 ```
	 - **Web:**
		 ```bash
		 flutter run -d chrome
		 ```
	 - **Desktop (Linux/macOS/Windows):**
		 ```bash
		 flutter run -d <linux|macos|windows>
		 ```

## Development
- **Code organization:**
	- Business logic is separated into controllers and repositories.
	- UI is organized into screens and widgets.
	- Services handle API calls and utility functions.
- **State management:**
	- Uses controllers for managing app state.
- **API integration:**
	- All API calls are managed in `lib/services/api_service.dart`.

## Testing
- All tests are located in the `test/` directory.
- To run tests:
	```bash
	flutter test
	```

## Configuration
- **BVN Verification:**
	- For testing purposes, always use the BVN: `1111111111`.
	- This is required for authentication and certain features.
- **Environment variables:**
	- Configure API endpoints and keys as needed in the appropriate files.

## Important Notes
- **BVN Requirement:**
	- The application requires a valid BVN for user verification. For all test and demo purposes, use `1111111111` as the BVN.
- **Platform Support:**
	- Some features may be limited or behave differently depending on the platform.
- **Security:**
	- Sensitive data is securely stored using platform-specific secure storage solutions.

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a pull request

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
