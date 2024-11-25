import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:usc_tree_hole/data/notification_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/notification.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage(
      {super.key,
      required this.user,
      required this.firestore,
      required this.storage,
      required this.auth});

  final User user;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    _notificationProvider =
        FirebaseNotificationProvider(widget.user.uid, widget.firestore);
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(
                onPressed: () {
                  _notificationProvider.clearNotifications();
                },
                child: const Text('Clear')),
          ],
        ),
        body: StreamBuilder<List<Notification>>(
            stream: _notificationProvider.notificationStream(),
            builder: (context, snapshot) {
              final notifications = snapshot.data;
              return notifications == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: notifications
                          .map((notification) => Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: NotificationCard(
                                  notification: notification,
                                ),
                              ))
                          .toList(),
                    );
            }));
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<Profile>(
          stream: FirebaseProfileProvider()
              .getProfileStreamById(notification.senderId),
          builder: (context, snapshot) {
            final sender = snapshot.data;
            if (sender == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                ListTile(
                  leading: Avatar(userId: sender.id, size: 50.0),
                  title: Text(sender.name),
                  subtitle: Text(notification.createTime.toDate().toString()),
                ),
                const Divider(),
                Text(notification.content),
              ],
            );
          }),
    ));
  }
}
