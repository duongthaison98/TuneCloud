# TuneCloud

This is an app where you can listen to music online without advertise.

## Installation
1. Download Android Studio -> Download Dart -> Download Flutter.
2. Get into pubspec.yaml and press "Pub get" on top right corner or open Terminal of Android Studio and type command "flutter pub get".
3. Open Device Manager, create Virtual Device with default settings. When you're done, click Start button to start virtual mobile.
4. Right click on '/lib/main.dart' and select "Run main.dart" to run the project.

## How to build Android
There are 2 ways you can build your project to an .apk app:
1. In the head navigation of Android Studio, click Build -> Flutter -> Build APK
2. Or just open Terminal and type command "flutter build apk".
When the app is built, the path to your .apk is "/build/app/outputs/flutter-apk/app-release.apk"

## How to build IOS
1. Type "open ios/Runner.xcworkspace" to open file.
2. In Xcode, select the project in the left sidebar and go to the "Signing & Capabilities" tab.
    - Set your Team to an active Apple Developer account.
    - Set the Bundle Identifier to a unique identifier.
    - Set the Deployment Target to the desired iOS version.
3. Type "flutter build ios" to build app.