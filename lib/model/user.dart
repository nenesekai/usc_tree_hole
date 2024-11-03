import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String role;
  final String uscId;
  final String? profilePictureUrl;

  User._({
    required this.id,
    required this.name,
    required this.role,
    required this.uscId,
    this.profilePictureUrl,
  });

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return User._(
      id: snapshot.id,
      name: data['name'],
      role: data['role'],
      uscId: data['uscId'],
      profilePictureUrl: data['profilePicture'],
    );
  }
}
