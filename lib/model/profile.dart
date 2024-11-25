import 'package:cloud_firestore/cloud_firestore.dart';

const roles = <String>[
  'Undergraduate',
  'Graduate',
  'Faculty',
  'Staff',
];

class Profile {
  final String id;
  final String name;
  final String role;
  final String uscId;
  final List<dynamic> subscribedCategories;

  const Profile({
    required this.id,
    required this.name,
    required this.role,
    required this.uscId,
    this.subscribedCategories = const <String>[],
  });

  @override
  bool operator ==(Object other) {
    if (other is Profile) {
      return true;
    } else {
      return false;
    }
  }

  factory Profile.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Profile(
      id: snapshot.id,
      name: data['name'],
      role: data['role'],
      uscId: data['uscId'],
      subscribedCategories: data['subscribedCategories'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'role': this.role,
      'uscId': this.uscId,
      'subscribedCategories': this.subscribedCategories,
    };
  }
}
