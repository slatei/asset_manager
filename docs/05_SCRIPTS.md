# Helper Scripts and Functions

## Project Configuration

```bash
firebase login
firebase init hosting

dart pub global activate flutterfire_cli

# Use Flutter Firebase CLI to configure project
flutterfire configure
flutterfire configure --project=assetmanager-af9af
```

## Emulators

```bash
firebase init emulators

firebase emulators:start

firebase emulators:start --log-verbosity debug

firebase emulators:export ./emulatorDataExport
firebase emulators:start --import test/emulator_data
```

## Flutter

```bash
# Run the service
flutter run

# Add dependencies
flutter pub add cloud_firestore
flutter pub add -d firebase_auth_mocks
```

## Testing

```bash
flutter test
```
