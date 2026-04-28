class UserProfile {
  final String uid;
  final String email;
  String? name;
  String? kelas;
  String? sekolah;
  String? avatarUrl;

  UserProfile({
    required this.uid,
    required this.email,
    this.name,
    this.kelas,
    this.sekolah,
    this.avatarUrl,
  });

  bool get isComplete => 
    (name?.trim().isNotEmpty ?? false) && (kelas?.trim().isNotEmpty ?? false);
}
