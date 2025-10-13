// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserModelCWProxy {
  UserModel id(int id);

  UserModel name(String name);

  UserModel email(String email);

  UserModel status(bool status);

  UserModel delete(bool delete);

  UserModel avatar(String? avatar);

  UserModel cargo(String? cargo);

  UserModel phone(String? phone);

  UserModel deletedAt(String? deletedAt);

  UserModel createdAt(String? createdAt);

  UserModel updatedAt(String? updatedAt);

  UserModel partner(PartnerModel? partner);

  UserModel role(RoleModel? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserModel(...).copyWith(id: 12, name: "My name")
  /// ````
  UserModel call({
    int? id,
    String? name,
    String? email,
    bool? status,
    bool? delete,
    String? avatar,
    String? cargo,
    String? phone,
    String? deletedAt,
    String? createdAt,
    String? updatedAt,
    PartnerModel? partner,
    RoleModel? role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserModel.copyWith.fieldName(...)`
class _$UserModelCWProxyImpl implements _$UserModelCWProxy {
  const _$UserModelCWProxyImpl(this._value);

  final UserModel _value;

  @override
  UserModel id(int id) => this(id: id);

  @override
  UserModel name(String name) => this(name: name);

  @override
  UserModel email(String email) => this(email: email);

  @override
  UserModel status(bool status) => this(status: status);

  @override
  UserModel delete(bool delete) => this(delete: delete);

  @override
  UserModel avatar(String? avatar) => this(avatar: avatar);

  @override
  UserModel cargo(String? cargo) => this(cargo: cargo);

  @override
  UserModel phone(String? phone) => this(phone: phone);

  @override
  UserModel deletedAt(String? deletedAt) => this(deletedAt: deletedAt);

  @override
  UserModel createdAt(String? createdAt) => this(createdAt: createdAt);

  @override
  UserModel updatedAt(String? updatedAt) => this(updatedAt: updatedAt);

  @override
  UserModel partner(PartnerModel? partner) => this(partner: partner);

  @override
  UserModel role(RoleModel? role) => this(role: role);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserModel(...).copyWith(id: 12, name: "My name")
  /// ````
  UserModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? delete = const $CopyWithPlaceholder(),
    Object? avatar = const $CopyWithPlaceholder(),
    Object? cargo = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? deletedAt = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? partner = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return UserModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      email: email == const $CopyWithPlaceholder() || email == null
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as bool,
      delete: delete == const $CopyWithPlaceholder() || delete == null
          ? _value.delete
          // ignore: cast_nullable_to_non_nullable
          : delete as bool,
      avatar: avatar == const $CopyWithPlaceholder()
          ? _value.avatar
          // ignore: cast_nullable_to_non_nullable
          : avatar as String?,
      cargo: cargo == const $CopyWithPlaceholder()
          ? _value.cargo
          // ignore: cast_nullable_to_non_nullable
          : cargo as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      deletedAt: deletedAt == const $CopyWithPlaceholder()
          ? _value.deletedAt
          // ignore: cast_nullable_to_non_nullable
          : deletedAt as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as String?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as String?,
      partner: partner == const $CopyWithPlaceholder()
          ? _value.partner
          // ignore: cast_nullable_to_non_nullable
          : partner as PartnerModel?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as RoleModel?,
    );
  }
}

extension $UserModelCopyWith on UserModel {
  /// Returns a callable class that can be used as follows: `instanceOfUserModel.copyWith(...)` or like so:`instanceOfUserModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserModelCWProxy get copyWith => _$UserModelCWProxyImpl(this);
}
