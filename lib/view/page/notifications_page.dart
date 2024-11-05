import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usc_tree_hole/data/notification_provider.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';
import 'package:usc_tree_hole/model/profile.dart';
import 'package:usc_tree_hole/view/component/avatar.dart';
import 'package:usc_tree_hole/view/page/not_signed_in_page.dart';
import 'package:usc_tree_hole/model/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.user});

  final User user;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    _notificationProvider =
        FirebaseNotificationProvider(userId: widget.user.uid);
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
      child: Column(
        children: [
          SizedBox(
            height: 40,
            width: double.infinity,
            child: StreamBuilder(
              stream: FirebaseProfileProvider()
                  .getProfileStreamById(notification.senderId),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                if (profile != null) {
                  return Row(children: [
                    Avatar(userId: profile.id),
                    Text(profile.name),
                  ]);
                } else {
                  return Placeholder();
                }
              },
            ),
          ),
          Text(notification.createTime.toDate().toString()),
          Text(notification.content),
        ],
      ),
    ));
  }
}
