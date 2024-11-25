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

  Profile copyWith({String? id, String? name, String? role, String? uscId}) =>
      Profile(
          id: id ?? this.id,
          name: name ?? this.name,
          role: role ?? this.role,
          uscId: uscId ?? this.uscId);
}
