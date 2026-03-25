import 'package:sixam_mart/features/notification/domain/models/notification_model.dart';
import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class NotificationRepositoryInterface implements RepositoryInterface {
  @override
  Future<List<NotificationModel>?> getList({int? offset});
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
}
