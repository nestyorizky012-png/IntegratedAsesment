import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> setFromAuth({required String uid, required String email}) async {
    if (_profile != null && _profile!.uid == uid) return;

    _isLoading = true;
    notifyListeners();

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _profile = UserProfile(
          uid: uid,
          email: email,
          name: data['name'],
          kelas: data['kelas'],
          sekolah: data['sekolah'],
          avatarUrl: data['avatarUrl'],
        );
      } else {
        _profile = UserProfile(uid: uid, email: email);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _profile = UserProfile(uid: uid, email: email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? kelas, String? sekolah, String? avatarUrl}) async {
    if (_profile == null) return;
    
    if (name != null) _profile!.name = name;
    if (kelas != null) _profile!.kelas = kelas;
    if (sekolah != null) _profile!.sekolah = sekolah;
    if (avatarUrl != null) _profile!.avatarUrl = avatarUrl;
    notifyListeners(); // Optimistic UI update

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(_profile!.uid);
      await docRef.set({
        'name': _profile!.name,
        'kelas': _profile!.kelas,
        'sekolah': _profile!.sekolah,
        'avatarUrl': _profile!.avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving config: $e');
    }
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
