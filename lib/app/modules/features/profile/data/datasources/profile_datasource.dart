import 'dart:io';

import '../models/user_profile_model.dart';

abstract class ProfileDatasource {
  Future<UserProfileModel> getProfile();

  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);

  Future<String> deleteAccount();

  Future<UserProfileModel> uploadAvatar(File imageFile);

  Future<UserProfileModel> removeAvatar();
}
