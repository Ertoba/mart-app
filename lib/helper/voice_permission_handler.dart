import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sixam_mart/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/search/widgets/voice_search_bottom_sheet.dart';

class VoicePermissionHandler {
  static Future<bool> requestVoicePermissions() async {
    final hasMicrophonePermission = await requestMicrophonePermission();
    if (!hasMicrophonePermission) {
      return false;
    }

    if (!GetPlatform.isIOS && !GetPlatform.isMacOS) {
      return true;
    }

    final status = await Permission.speech.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.speech.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog(isSpeechPermission: true);
      return false;
    }

    if (status.isRestricted) {
      showCustomSnackBar('speech_recognition_restricted'.tr);
      return false;
    }

    return false;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    if (status.isRestricted) {
      showCustomSnackBar('microphone_restricted'.tr);
      return false;
    }

    return false;
  }

  static void _showPermissionDeniedDialog({bool isSpeechPermission = false}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSpeechPermission
                        ? Icons.record_voice_over_outlined
                        : Icons.mic_off_rounded,
                    size: 48,
                    color: Get.theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  (isSpeechPermission
                          ? 'speech_permission_required'
                          : 'microphone_permission_required')
                      .tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  isSpeechPermission
                      ? 'speech_permission_message'.tr
                      : GetPlatform.isWeb
                      ? 'microphone_permission_message_web'.tr
                      : 'microphone_permission_message'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.theme.hintColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                GetPlatform.isWeb
                    ? SizedBox(
                        width: 100,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Get.theme.disabledColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text('cancel'.tr),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Get.theme.disabledColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text('cancel'.tr),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                                openAppSettings();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Get.theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: Text(
                                'open_settings'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> openVoiceSearch({
    required BuildContext context,
    required TextEditingController searchTextEditingController,
    required bool isDesktop,
  }) async {
    final hasPermission = await requestVoicePermissions();

    if (!hasPermission) {
      return;
    }

    if (isDesktop) {
      Get.dialog(
        Dialog(
          child: VoiceSearchBottomSheet(
            searchTextEditingController: searchTextEditingController,
          ),
        ),
      );
    } else {
      showCustomBottomSheet(
        child: VoiceSearchBottomSheet(
          searchTextEditingController: searchTextEditingController,
        ),
      );
    }
  }
}
