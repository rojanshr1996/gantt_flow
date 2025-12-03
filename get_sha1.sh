#!/bin/bash

echo "=== Debug Keystore SHA-1 ==="
keytool -list -v -keystore android/app/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1

echo ""
echo "=== Release Keystore SHA-1 ==="
keytool -list -v -keystore android/app/release.keystore -alias ganttflow -storepass ganttflow2024 -keypass ganttflow2024 | grep SHA1

echo ""
echo "Add both SHA-1 fingerprints to Firebase Console:"
echo "1. Go to Firebase Console > Project Settings"
echo "2. Select your Android app"
echo "3. Add both SHA-1 fingerprints"
echo "4. Download the new google-services.json"
echo "5. Replace android/app/google-services.json"
