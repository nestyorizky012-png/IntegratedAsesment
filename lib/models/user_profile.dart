class UserProfile {
  final String uid;
  final String email;
  String? name;
  String? kelas;
  String? sekolah;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.kelas,
    this.sekolah,
  });

  bool get isComplete => 
    (name?.trim().isNotEmpty ?? false) && (kelas?.trim().isNotEmpty ?? false);
}
