// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../../util/map_ext.dart';

class UserModel {
  UserModel({
   this.id,
   this.username,
   this.password,
   this.token,
   this.refreshToken,
   this.gender,
   this.birthday,
   this.characterName,
  });
  final String? id;
  final String? username;
  final String? password;
  final String? token;
  final String? refreshToken;
  final String? gender;
  final String? birthday;
  final String? characterName;
  static const document = 'users';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'password': password,
      'token': token,
      'refresh_token': refreshToken,
      'gender': gender,
      'birthday': birthday,
      'character_name': characterName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic>? map) {
    return UserModel(
      id: map?.getOrNull('id') as String?,
      username: map?.getOrNull('username') as String?,
      password: map?.getOrNull('password') as String?,
      token: map?.getOrNull('token') as String?,
      refreshToken: map?.getOrNull('refresh_token') as String?,
      gender: map?.getOrNull('gender') as String?,
      birthday: map?.getOrNull('birthday') as String?,
      characterName: map?.getOrNull('character_name') as String?,
    );
  }
}