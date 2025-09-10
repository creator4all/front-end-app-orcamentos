// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UserDtoCWProxy {
  UserDto id(String id);

  UserDto name(String name);

  UserDto email(String email);

  UserDto phone(String? phone);

  UserDto createdAt(String? createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UserDto call({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUserDto.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUserDto.copyWith.fieldName(...)`
class _$UserDtoCWProxyImpl implements _$UserDtoCWProxy {
  const _$UserDtoCWProxyImpl(this._value);

  final UserDto _value;

  @override
  UserDto id(String id) => this(id: id);

  @override
  UserDto name(String name) => this(name: name);

  @override
  UserDto email(String email) => this(email: email);

  @override
  UserDto phone(String? phone) => this(phone: phone);

  @override
  UserDto createdAt(String? createdAt) => this(createdAt: createdAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UserDto(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UserDto(...).copyWith(id: 12, name: "My name")
  /// ````
  UserDto call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return UserDto(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      email: email == const $CopyWithPlaceholder() || email == null
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as String?,
    );
  }
}

extension $UserDtoCopyWith on UserDto {
  /// Returns a callable class that can be used as follows: `instanceOfUserDto.copyWith(...)` or like so:`instanceOfUserDto.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UserDtoCWProxy get copyWith => _$UserDtoCWProxyImpl(this);
}
