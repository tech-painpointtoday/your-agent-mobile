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
    var status = await permission.status;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      await AppConfirmationBottomSheet.show(
        context: context,
        title: title ?? 'ไม่ได้รับอนุญาต',
        description:
            deniedForeverMessage ??
            'คุณปิดสิทธิ์การเข้าถึงถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์',
        confirmLabel: 'ไปที่ตั้งค่า',
        cancelLabel: 'ยกเลิก',
        style: ConfirmationStyle.normal,
        onConfirm: () => openAppSettings(),
      );
      return false;
    }

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isGranted) {
      return true;
    }

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
    // Storage permission is used on older Android, Photos on iOS and newer Android
    Permission photoPermission = Permission.photos;

    // Check status
    return await ensurePermission(
      context,
      photoPermission,
      title: 'เข้าถึงรูปภาพ',
      message: 'กรุณาอนุญาตการเข้าถึงรูปภาพเพื่อเลือกภาพจากอัลบั้ม',
      deniedForeverMessage:
          'คุณปิดสิทธิ์การเข้าถึงรูปภาพถาวร กรุณาไปที่การตั้งค่าเพื่อเปิดสิทธิ์',
    );
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
