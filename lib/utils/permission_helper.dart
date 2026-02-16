import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';

class PermissionHelper {
  /// Ensures the specified permission is granted.
  /// Shows dialogs if denied or permanently denied.
  static Future<bool> ensurePermission(
    BuildContext context,
    Permission permission, {
    String? title,
    String? message,
    String? deniedForeverMessage,
  }) async {
    PermissionStatus status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;

      // Use StatusDialog for cleaner UI or confirmation sheet
      bool openSettings = false;
      await AppConfirmationBottomSheet.show(
        context: context,
        title: title ?? 'Permission Required',
        description:
            deniedForeverMessage ?? 'Please enable permission in settings.',
        confirmLabel: 'Open Settings',
        cancelLabel: 'Cancel',
        onConfirm: () {
          openSettings = true;
        },
      );

      if (openSettings) {
        await openAppSettings();
      }
      return false;
    }

    // Request permission if not determined/denied
    status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // If still denied after request (but not permanently yet)
    if (!context.mounted) return false;
    StatusDialog.showWarning(
      context: context,
      title: title ?? 'ไม่ได้รับอนุญาต',
      message: message ?? 'กรุณาอนุญาตการเข้าถึงเพื่อใช้งานฟีเจอร์นี้',
    );
    return false;
  }

  /// Specialized handler for Location (includes Service check)
  static Future<bool> ensureLocationReady(BuildContext context) async {
    // 1. Check if Service is enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return false;
      StatusDialog.showWarning(
        context: context,
        title: 'เปิดบริการตำแหน่ง',
        message: 'กรุณาเปิด Location Services เพื่อใช้งานตำแหน่งปัจจุบัน',
      );
      return false;
    }

    // 2. Check Permissions
    if (!context.mounted) return false;
    return await ensurePermission(
      context,
      Permission.location,
      title: 'เข้าถึงตำแหน่ง',
      message: 'กรุณาอนุญาตการเข้าถึงตำแหน่งเพื่อระบุตำแหน่งของคุณ',
      deniedForeverMessage:
          'คุณปิดสิทธิ์ตำแหน่งถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์ตำแหน่ง',
    );
  }

  /// Helper to get current position with permission check
  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      final ok = await ensureLocationReady(context);
      if (!ok) return null;
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (!context.mounted) return null;
      StatusDialog.showError(
        context: context,
        title: 'เกิดข้อผิดพลาด',
        message: 'ไม่สามารถรับตำแหน่งปัจจุบันได้: ${e.toString()}',
      );
      return null;
    }
  }

  /// Ensures Camera permission is ready
  static Future<bool> ensureCameraReady(BuildContext context) async {
    return await ensurePermission(
      context,
      Permission.camera,
      title: 'เข้าถึงกล้องถ่ายรูป',
      message: 'กรุณาอนุญาตการเข้าถึงกล้องเพื่อถ่ายภาพ',
      deniedForeverMessage:
          'คุณปิดสิทธิ์การเข้าถึงกล้องถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์',
    );
  }

  /// Ensures Photo/Gallery permission is ready
  static Future<bool> ensurePhotosReady(BuildContext context) async {
    // On Android 13+ use Permission.photos, older use storage
    // On iOS use Permission.photos
    // You might need check device info, but typically checking both or specific one is good.
    // Simple approach: Request photos, if not applicable, try storage.
    // BUT permission_handler handles this logic usually if configured correctly in AndroidManifest.
    // Let's check photos first.

    // Ideally check platform version, but for simplicity we can check Permission.photos first.
    // If that returns permanently denied or restricted on Android < 13 immediately, it might be wrong.
    // Code below handles generic "photos" permission.

    if (await Permission.photos.status.isGranted) return true;

    // If photos not granted, try requesting it
    if (!context.mounted) return false;
    bool photosGranted = await ensurePermission(
      context,
      Permission.photos,
      title: 'Access Photos',
      message: 'Allow app to access your photos.',
    );

    if (photosGranted) return true;

    // Fallback for older Android if needed (Storage) - only if photos didn't work/not applicable
    // This part is tricky without device info. Assuming modern flutter env.
    // If permission.photos is permanently denied, ensurePermission above would have shown dialog.

    return false;
  }

  /// Ensures Notification permission is ready
  static Future<bool> ensureNotificationReady(BuildContext context) async {
    return await ensurePermission(
      context,
      Permission.notification,
      title: 'การแจ้งเตือน',
      message: 'กรุณาอนุญาตการแจ้งเตือนเพื่อรับข่าวสารและข้อความใหม่',
      deniedForeverMessage:
          'คุณปิดสิทธิ์การแจ้งเตือนถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์การแจ้งเตือน',
    );
  }
}
