import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class MaintenanceHelper {
  static bool isMaintenanceEnable() {
    final config = Get.find<SplashController>().configModel;
    if(config?.maintenanceMode != true) {
      return false;
    }

    final maintenanceData = config?.maintenanceModeData;
    if(maintenanceData == null) {
      return false;
    }

    final String platform = GetPlatform.isWeb ? 'user_web_app' : 'user_mobile_app';
    final systems = maintenanceData.maintenanceSystemSetup ?? <String>[];
    if(!systems.contains(platform)) {
      return false;
    }

    final duration = maintenanceData.maintenanceDurationSetup;
    if(duration == null) {
      return false;
    }

    if(duration.maintenanceDuration == 'until_change') {
      return true;
    }

    final DateTime? start = DateTime.tryParse(duration.startDate ?? '');
    final DateTime? end = DateTime.tryParse(duration.endDate ?? '');
    if(start == null || end == null) {
      return false;
    }

    final DateTime now = DateTime.now();
    return !now.isBefore(start) && !now.isAfter(end);
  }
}
