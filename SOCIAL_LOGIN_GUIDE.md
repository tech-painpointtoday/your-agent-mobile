# Social Login Configuration Guide

This guide details the native configuration steps required to enable Google and Facebook login for the YourHome application.

## 1. Google Sign-In

### Firebase/Google Cloud Console Setup
1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Create a new project or select an existing one.
3.  **Android App**:
    *   Add an Android app with the package name: `com.youragent.painpointtoday.mobile` (Check `android/app/build.gradle` for the exact `applicationId`).
    *   Download `google-services.json`.
    *   Move this file to: `android/app/google-services.json`.
4.  **iOS App**:
    *   Add an iOS app with the Bundle ID: `com.youragent.painpointtoday.mobile` (Check `ios/Runner.xcodeproj` for the exact Bundle Identifier).
    *   Download `GoogleService-Info.plist`.
    *   Move this file to: `ios/Runner/GoogleService-Info.plist`.
    *   **Crucial**: Open the project in Xcode (`ios/Runner.xcworkspace`) and drag the file into the project navigator to ensure it's linked correctly.

### iOS Configuration (`ios/Runner/Info.plist`)
Open `ios/Runner/Info.plist` and add the `CFBundleURLTypes` for Google:

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO: Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.YOUR-CLIENT-ID-HERE</string>
		</array>
	</dict>
</array>
```

---

## 2. Facebook Login

### Meta Developers Setup
1.  Go to [Meta for Developers](https://developers.facebook.com/).
2.  Create an App (Type: "Consumer" or "Business").
3.  **Android Platform**:
    *   Add Platform > Android.
    *   Google Play Package Name: `com.youragent.painpointtoday.mobile`.
    *   Class Name: `com.youragent.painpointtoday.mobile.MainActivity` (or your main activity).
    *   Key Hashes: Generate development key hashes using:
        `keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64`
        (Password is typically `android`).
4.  **iOS Platform**:
    *   Add Platform > iOS.
    *   Bundle ID: `com.youragent.painpointtoday.mobile`.

### Android Configuration

**1. `android/app/src/main/res/values/strings.xml`**
Add your Facebook App ID and Client Token:

```xml
<string name="facebook_app_id">YOUR_APP_ID</string>
<string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
```

**2. `android/app/src/main/AndroidManifest.xml`**
Add the following inside the `<application>` tag:

```xml
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>

<activity android:name="com.facebook.FacebookActivity"
    android:configChanges=
        "keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />
<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```
*Note: You also need a string resource for `fb_login_protocol_scheme` which is usually `fb` + your app id (e.g., `fb123456...`).*

### iOS Configuration (`ios/Runner/Info.plist`)

Add the following keys:

```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- ... Google configuration ... -->
    <dict>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>fbYOUR_APP_ID</string>
    </array>
    </dict>
</array>

<key>FacebookAppID</key>
<string>YOUR_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_CLIENT_TOKEN</string>
<key>FacebookDisplayName</key>
<string>YourHome</string>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>fbapi</string>
    <string>fb-messenger-share-api</string>
</array>
```

---

## 3. Backend Requirements

The mobile app will send a POST request to your backend to exchange the social token for a session.

**Endpoint**: `POST /auth/social-login` (based on current implementation in `AuthApiService`).
**Request Body**:
```json
{
  "provider": "google" | "facebook",
  "token": "ACCESS_TOKEN_FROM_PROVIDER",
  "role": "agent" | "agency"
}
```

**Expected Response**:
Standard authentication response containing the user profile and API token.
