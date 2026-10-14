import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum AudioPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  /// Check whether audio storage permission is granted
  Future<bool> hasAudioPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true; // Desktop / Web fallback
    }

    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_AUDIO
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;

      // Android 12 and below uses storage
      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted;
    }

    return true;
  }

  /// Request required permissions for audio library access and playback notification
  Future<AudioPermissionStatus> requestAudioPermissions() async {
    if (!Platform.isAndroid) {
      return AudioPermissionStatus.granted;
    }

    try {
      // Notification permission for background playback controls (Android 13+)
      if (await Permission.notification.status.isDenied) {
        await Permission.notification.request();
      }

      // Request audio / storage permissions
      PermissionStatus status = await Permission.audio.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        return AudioPermissionStatus.granted;
      } else if (status.isPermanentlyDenied) {
        return AudioPermissionStatus.permanentlyDenied;
      } else if (status.isRestricted) {
        return AudioPermissionStatus.restricted;
      } else {
        return AudioPermissionStatus.denied;
      }
    } catch (e) {
      // Graceful fallback
      return AudioPermissionStatus.denied;
    }
  }

  /// Open application system settings
  Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }
}
