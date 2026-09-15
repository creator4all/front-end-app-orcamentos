import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/repositories/file_opener.dart';
import 'package:multimidiaapp/app/modules/features/new_drive/domain/repositories/temp_file_store.dart';
import 'package:multimidiaapp/app/modules/features/partner/domain/repositories/partner_repository.dart';
import 'package:multimidiaapp/app/modules/features/partner/domain/usecases/get_partner_usecase.dart';
import 'package:multimidiaapp/app/modules/features/partner/domain/usecases/update_partner_usecase.dart';
import 'package:multimidiaapp/app/modules/features/partner/domain/usecases/upload_logo_usecase.dart';
import 'package:multimidiaapp/app/modules/features/partner/domain/usecases/view_contract_usecase.dart';
import 'package:multimidiaapp/app/modules/features/partner/presentation/stores/partner_store.dart';

class _PartnerRepository implements PartnerRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TempFileStore implements TempFileStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FileOpener implements FileOpener {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PartnerStore buildStore() {
  final repository = _PartnerRepository();

  return PartnerStore(
    GetPartnerUseCase(repository),
    UpdatePartnerUseCase(repository),
    UploadLogoUseCase(repository),
    ViewContractUseCase(repository),
    _TempFileStore(),
    _FileOpener(),
  );
}

PartnerStore storeWithValidData() {
  return buildStore()
    ..setTradeName('Multimidia Educacional')
    ..setLegalName('Multimedia Arts LTDA')
    ..setCnpj('03.848.869/0001-89')
    ..setPhone('11999999999')
    ..setEmail('multimidia@sistema.com')
    ..setUrl('');
}

void main() {
  group('PartnerStore.setUrl', () {
    test('should add the scheme the webservice requires', () {
      final store = buildStore()..setUrl('www.multimidia.com.br');

      expect(store.url, 'https://www.multimidia.com.br');
    });

    test('should keep an explicit scheme', () {
      final store = buildStore()..setUrl('http://multimidia.com.br');

      expect(store.url, 'http://multimidia.com.br');
    });

    test('should stay empty when the field is blank', () {
      final store = buildStore()..setUrl('   ');

      expect(store.url, '');
    });
  });

  group('PartnerStore.validate', () {
    test('should accept a complete form', () {
      expect(storeWithValidData().validate(), isNull);
    });

    test('should accept a form without email and url', () {
      final store = storeWithValidData()
        ..setEmail('')
        ..setUrl('');

      expect(store.validate(), isNull);
    });

    test('should require the trade name', () {
      final store = storeWithValidData()..setTradeName('  ');

      expect(store.validate(), 'Informe o nome fantasia da empresa.');
    });

    test('should require the legal name', () {
      final store = storeWithValidData()..setLegalName('');

      expect(store.validate(), 'Informe a razão social da empresa.');
    });

    test('should reject a document with an invalid check digit', () {
      final store = storeWithValidData()..setCnpj('11.111.111/0001-99');

      expect(store.validate(), contains('CNPJ informado não é válido'));
    });

    test('should reject an incomplete phone', () {
      final store = storeWithValidData()..setPhone('119999999');

      expect(store.validate(), 'Informe um telefone completo, com DDD.');
    });

    test('should reject a malformed email', () {
      final store = storeWithValidData()..setEmail('multimidia@');

      expect(store.validate(), 'Informe um e-mail válido.');
    });

    test('should reject a url the webservice would refuse', () {
      final store = storeWithValidData()..setUrl('ftp://multimidia.com.br');

      expect(store.validate(), isNotNull);
    });

    test('should report the first invalid field only', () {
      final store = storeWithValidData()
        ..setTradeName('')
        ..setPhone('1');

      expect(store.validate(), 'Informe o nome fantasia da empresa.');
    });
  });
}
