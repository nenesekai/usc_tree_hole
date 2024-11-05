import 'package:usc_tree_hole/model/notification.dart';

abstract class NotificationProvider {
  Stream<List<Notification>> get notificationStream;
}
