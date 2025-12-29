import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  void setFromAuth({required String uid, required String email}) {
    // jangan overwrite kalau sudah ada dan uid sama
    if (_profile != null && _profile!.uid == uid) return;
    _profile = UserProfile(uid: uid, email: email);
    notifyListeners();
  }

  void updateProfile({String? name, String? kelas, String? sekolah}) {
    if (_profile == null) return;
    if (name != null) _profile!.name = name;
    if (kelas != null) _profile!.kelas = kelas;
    if (sekolah != null) _profile!.sekolah = sekolah;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
