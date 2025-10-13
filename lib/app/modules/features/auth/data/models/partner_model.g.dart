// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_model.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PartnerModelCWProxy {
  PartnerModel id(int id);

  PartnerModel legalName(String legalName);

  PartnerModel tradeName(String tradeName);

  PartnerModel email(String email);

  PartnerModel phone(String phone);

  PartnerModel logo(String? logo);

  PartnerModel cnpj(String cnpj);

  PartnerModel status(bool status);

  PartnerModel createdAt(String? createdAt);

  PartnerModel updatedAt(String? updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartnerModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartnerModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PartnerModel call({
    int? id,
    String? legalName,
    String? tradeName,
    String? email,
    String? phone,
    String? logo,
    String? cnpj,
    bool? status,
    String? createdAt,
    String? updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPartnerModel.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPartnerModel.copyWith.fieldName(...)`
class _$PartnerModelCWProxyImpl implements _$PartnerModelCWProxy {
  const _$PartnerModelCWProxyImpl(this._value);

  final PartnerModel _value;

  @override
  PartnerModel id(int id) => this(id: id);

  @override
  PartnerModel legalName(String legalName) => this(legalName: legalName);

  @override
  PartnerModel tradeName(String tradeName) => this(tradeName: tradeName);

  @override
  PartnerModel email(String email) => this(email: email);

  @override
  PartnerModel phone(String phone) => this(phone: phone);

  @override
  PartnerModel logo(String? logo) => this(logo: logo);

  @override
  PartnerModel cnpj(String cnpj) => this(cnpj: cnpj);

  @override
  PartnerModel status(bool status) => this(status: status);

  @override
  PartnerModel createdAt(String? createdAt) => this(createdAt: createdAt);

  @override
  PartnerModel updatedAt(String? updatedAt) => this(updatedAt: updatedAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PartnerModel(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PartnerModel(...).copyWith(id: 12, name: "My name")
  /// ````
  PartnerModel call({
    Object? id = const $CopyWithPlaceholder(),
    Object? legalName = const $CopyWithPlaceholder(),
    Object? tradeName = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? logo = const $CopyWithPlaceholder(),
    Object? cnpj = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return PartnerModel(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      legalName: legalName == const $CopyWithPlaceholder() || legalName == null
          ? _value.legalName
          // ignore: cast_nullable_to_non_nullable
          : legalName as String,
      tradeName: tradeName == const $CopyWithPlaceholder() || tradeName == null
          ? _value.tradeName
          // ignore: cast_nullable_to_non_nullable
          : tradeName as String,
      email: email == const $CopyWithPlaceholder() || email == null
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      phone: phone == const $CopyWithPlaceholder() || phone == null
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      logo: logo == const $CopyWithPlaceholder()
          ? _value.logo
          // ignore: cast_nullable_to_non_nullable
          : logo as String?,
      cnpj: cnpj == const $CopyWithPlaceholder() || cnpj == null
          ? _value.cnpj
          // ignore: cast_nullable_to_non_nullable
          : cnpj as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as bool,
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

extension $PartnerModelCopyWith on PartnerModel {
  /// Returns a callable class that can be used as follows: `instanceOfPartnerModel.copyWith(...)` or like so:`instanceOfPartnerModel.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PartnerModelCWProxy get copyWith => _$PartnerModelCWProxyImpl(this);
}
