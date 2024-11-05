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

  const Profile({
    required this.id,
    required this.name,
    required this.role,
    required this.uscId,
  });

  factory Profile.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Profile(
      id: snapshot.id,
      name: data['name'],
      role: data['role'],
      uscId: data['uscId'],
    );
  }
}
