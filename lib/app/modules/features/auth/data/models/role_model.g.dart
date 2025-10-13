// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RoleModelCWProxy {
  RoleModel id(int id);

  RoleModel name(String name);

  RoleModel description(String description);

  RoleModel createdAt(String? createdAt);

  RoleModel updatedAt(String? updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RoleModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RoleModel(...).copyWith(id: 12, name: "My name")
  /// ````
  RoleModel call({
    int? id,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRoleModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRoleModel.copyWith.fieldName(...)`
class _$RoleModelCWProxyImpl implements _$RoleModelCWProxy {
  const _$RoleModelCWProxyImpl(this._value);

  final RoleModel _value;

  @override
  RoleModel id(int id) => this(id: id);

  @override
  RoleModel name(String name) => this(name: name);

  @override
  RoleModel description(String description) => this(description: description);

  @override
  RoleModel createdAt(String? createdAt) => this(createdAt: createdAt);

  @override
  RoleModel updatedAt(String? updatedAt) => this(updatedAt: updatedAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RoleModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RoleModel(...).copyWith(id: 12, name: "My name")
  /// ````
  RoleModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return RoleModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as String?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as String?,
    );
  }
}

extension $RoleModelCopyWith on RoleModel {
  /// Returns a callable class that can be used as follows: `instanceOfRoleModel.copyWith(...)` or like so:`instanceOfRoleModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RoleModelCWProxy get copyWith => _$RoleModelCWProxyImpl(this);
}
