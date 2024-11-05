import 'package:flutter/material.dart';
import 'package:usc_tree_hole/data/profile_provider.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.userId,
    this.cornerRadius = 10.0,
    this.size = 100.0,
  });

  final String userId;
  final double cornerRadius;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseProfileProvider().getAvatarUrl(userId),
        builder: (context, snapshot) {
          return SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: snapshot.hasError
                      ? Image.asset('assets/default_avatar.jpg')
                      : snapshot.hasData
                          ? Image.network(
                              snapshot.data!,
                            )
                          : const Center(child: CircularProgressIndicator())));
        });
  }
}
