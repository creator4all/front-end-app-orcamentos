import 'package:flutter_modular/flutter_modular.dart';

import '../new_drive/domain/repositories/file_opener.dart';
import '../new_drive/domain/repositories/temp_file_store.dart';
import '../new_drive/external/file_opener_impl.dart';
import '../new_drive/external/temp_file_store_impl.dart';
import 'data/repositories/partner_repository_impl.dart';
import 'data/services/partner_service.dart';
import 'domain/repositories/partner_repository.dart';
import 'domain/usecases/get_partner_usecase.dart';
import 'domain/usecases/update_partner_usecase.dart';
import 'domain/usecases/upload_logo_usecase.dart';
import 'domain/usecases/view_contract_usecase.dart';
import 'presentation/pages/partner_edit_page.dart';
import 'presentation/stores/partner_store.dart';

class PartnerModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<PartnerRepository>(
          (i) => PartnerRepositoryImpl(i<PartnerService>()),
        ),
        Bind.singleton<GetPartnerUseCase>(
          (i) => GetPartnerUseCase(i.get<PartnerRepository>()),
        ),
        Bind.singleton<UpdatePartnerUseCase>(
          (i) => UpdatePartnerUseCase(i.get<PartnerRepository>()),
        ),
        Bind.singleton<UploadLogoUseCase>(
          (i) => UploadLogoUseCase(i.get<PartnerRepository>()),
        ),
        Bind.singleton<ViewContractUseCase>(
          (i) => ViewContractUseCase(i.get<PartnerRepository>()),
        ),
        Bind.singleton<TempFileStore>(
          (i) => TempFileStoreImpl(),
        ),
        Bind.singleton<FileOpener>(
          (i) => FileOpenerImpl(),
        ),
        Bind.lazySingleton<PartnerStore>(
          (i) => PartnerStore(
            i.get<GetPartnerUseCase>(),
            i.get<UpdatePartnerUseCase>(),
            i.get<UploadLogoUseCase>(),
            i.get<ViewContractUseCase>(),
            i.get<TempFileStore>(),
            i.get<FileOpener>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/edit', child: (context, args) => const PartnerEditPage()),
      ];
}
