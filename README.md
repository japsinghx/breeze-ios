# Breeze iOS App

A native iOS application for monitoring air quality, built with Swift and SwiftUI.

## Features

- **Real-time Air Quality**: View US AQI index for any location worldwide
- **Pollutant Details**: Track PM2.5, PM10, NO₂, SO₂, O₃, and CO levels
- **Pollen/Allergy Tracker**: Monitor grass, tree, and weed pollen levels
- **Climate Trends**: See historical temperature data for your location
- **City Search**: Search and select cities with autocomplete
- **Location Services**: Use current location for instant air quality data
- **Dark Mode**: Automatic dark mode support

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

### 1. Open in Xcode

```bash
cd BreezeApp
open BreezeApp.xcodeproj
```

### 2. Configure API Keys (Optional)

For pollen data, add your Google Pollen API key:

1. In Xcode, go to Product → Scheme → Edit Scheme
2. Under "Run" → "Arguments" → "Environment Variables"
3. Add: `GOOGLE_POLLEN_API_KEY = your_api_key_here`

The app will work without this key, but pollen data will not be available.

### 3. Build and Run

1. Select your target device (iPhone 15 recommended for simulator)
2. Press `Cmd + R` to build and run

## Project Structure

```
BreezeApp/
├── App/                    # App entry point
├── Models/                 # Data models
├── Services/               # API services
├── ViewModels/            # State management
├── Views/
│   ├── Dashboard/         # Main dashboard views
│   ├── Search/            # City search
│   ├── Environmental/     # Pollen and climate views
│   └── Components/        # Reusable components
├── Extensions/            # Swift extensions
└── Resources/             # Assets and resources
```

## APIs Used

- [Open-Meteo Air Quality API](https://open-meteo.com/en/docs/air-quality-api)
- [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api)
- [Google Pollen API](https://developers.google.com/maps/documentation/pollen) (optional)
- [Open-Meteo Historical Weather API](https://open-meteo.com/en/docs/historical-weather-api)

## App Store Submission

Before submitting to the App Store:

1. Add your Development Team in project settings
2. Configure your Bundle Identifier
3. Add a 1024x1024 App Icon to Assets.xcassets
4. Create App Store screenshots
5. Complete App Store Connect listing

## License

© 2025 Breeze. All rights reserved.
