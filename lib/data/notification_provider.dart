import 'package:usc_tree_hole/model/notification.dart';

abstract class NotificationProvider {
  const NotificationProvider({required this.userId});
  final String userId;
  Stream<List<Notification>> get notificationStream;
}
