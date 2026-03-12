# iOS URL Scheme Configuration (Dynamic by Flavor)

## สรุปการตั้งค่า

ได้ตั้งค่า URL Scheme แบบ Dynamic ที่จะเปลี่ยนตาม Flavor/Environment โดยอัตโนมัติ:

| Flavor | Scheme สั้น (APP_URL_SCHEME) | Scheme ตาม Bundle ID |
|--------|-----------------------------|------------------------|
| **Dev**  | `youragentdev://`           | `com.youragent.painpointtoday.dev://` |
| **Prod** | `youragent://`              | `com.youragent.painpointtoday://`     |

## สิ่งที่ทำไปแล้ว

### 1. ตัวแปร `APP_URL_SCHEME` (User-Defined)

- **Dev** (Debug-dev, Release-dev, Profile-dev): ตั้งใน `Flutter/Debug-dev.xcconfig`, `Release-dev.xcconfig`, `Profile-dev.xcconfig` → `APP_URL_SCHEME=youragentdev`
- **Prod**: ตั้งใน `Flutter/Debug.xcconfig`, `Flutter/Release.xcconfig` และ Profile (Runner) ใน project → `APP_URL_SCHEME=youragent`

### 2. อัปเดต `Info.plist`

- **Scheme สั้น** (youragentdev / youragent): ใช้ `$(APP_URL_SCHEME)` ใน `CFBundleURLSchemes` และ `CFBundleURLName`
- **Scheme ตาม Bundle ID**: ยังมี entry ที่ใช้ `$(PRODUCT_BUNDLE_IDENTIFIER)` อยู่ (com.youragent.painpointtoday.dev / com.youragent.painpointtoday)

### 3. อัปเดต `LSApplicationQueriesSchemes`

เพิ่ม schemes ที่แอปอื่นอาจใช้เปิดแอปนี้ (รวมทั้งแบบสั้นและแบบ Bundle ID):

```xml
<string>youragent</string>
<string>youragentdev</string>
<string>com.youragent.painpointtoday</string>
<string>com.youragent.painpointtoday.dev</string>
```

**หมายเหตุ**: `LSApplicationQueriesSchemes` ไม่สามารถใช้ตัวแปรได้ ต้องระบุเป็น static strings ทั้งหมด ดังนั้นต้องเพิ่มทุก scheme ที่เป็นไปได้

## วิธีตรวจสอบใน Xcode

1. เปิด `ios/Runner.xcodeproj` ใน Xcode
2. เลือก Target **Runner** และเลือก Scheme (dev หรือ prod)
3. ไปที่แท็บ **Info** → ขยาย **URL Types**
4. ควรเห็น entry ที่ใช้ `$(APP_URL_SCHEME)` (คุณจะเห็นค่าจริงหลัง build เช่น youragentdev หรือ youragent) และ entry ที่ใช้ `$(PRODUCT_BUNDLE_IDENTIFIER)`

## การใช้งาน

### ใน Flutter/Dart Code

```dart
import 'package:app_links/app_links.dart';

final appLinks = AppLinks();

// รับ deep link (รองรับทั้ง scheme สั้นและแบบ Bundle ID)
appLinks.uriLinkStream.listen((uri) {
  final scheme = uri.scheme;
  if (scheme == 'youragentdev' || scheme == 'youragent' ||
      scheme == 'com.youragent.painpointtoday.dev' || scheme == 'com.youragent.painpointtoday') {
    print('Received deep link: ${uri.toString()}');
  }
});
```

### เปิดแอปจากแอปอื่นหรือ Web

**Dev (แบบสั้น):**
```
youragentdev://path/to/screen?param=value
```

**Dev (แบบ Bundle ID):**
```
com.youragent.painpointtoday.dev://path/to/screen?param=value
```

**Prod (แบบสั้น):**
```
youragent://path/to/screen?param=value
```

**Prod (แบบ Bundle ID):**
```
com.youragent.painpointtoday://path/to/screen?param=value
```

### ทดสอบจาก Terminal (macOS)

```bash
# Dev (scheme สั้น)
xcrun simctl openurl booted "youragentdev://test"

# Prod (scheme สั้น)
xcrun simctl openurl booted "youragent://test"

# Dev (Bundle ID)
xcrun simctl openurl booted "com.youragent.painpointtoday.dev://test"

# Prod (Bundle ID)
xcrun simctl openurl booted "com.youragent.painpointtoday://test"
```

## สรุป

- ✅ **Scheme สั้น**: ใช้ `$(APP_URL_SCHEME)` → Dev: `youragentdev`, Prod: `youragent`
- ✅ **Scheme ตาม Bundle ID**: ใช้ `$(PRODUCT_BUNDLE_IDENTIFIER)` → `com.youragent.painpointtoday.dev` / `com.youragent.painpointtoday`
- ✅ เพิ่มทุก scheme ใน `LSApplicationQueriesSchemes` → แอปอื่นเปิดแอปนี้ได้
- ✅ ตั้งค่า `APP_URL_SCHEME` ใน Flutter xcconfig ตาม flavor

## หมายเหตุ

- URL Scheme ไม่ควรมีอักขระพิเศษ (เช่น `-`, `.` ควรใช้ได้)
- Bundle ID ที่ใช้: `com.youragent.painpointtoday.dev` (dev), `com.youragent.painpointtoday` (prod)
- ถ้ามี staging bundle ID แยก (เช่น `com.youragent.painpointtoday.staging`) ให้เพิ่มใน `LSApplicationQueriesSchemes` ด้วย
