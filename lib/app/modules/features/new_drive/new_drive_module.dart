import 'package:flutter_modular/flutter_modular.dart';

import '../../../shared/core/http/app_http_client.dart';
import 'data/datasources/drive_remote_datasource.dart';
import 'data/repositories/drive_repository_impl.dart';
import 'data/repositories/file_saver_impl.dart';
import 'domain/entities/drive_item.dart';
import 'domain/repositories/drive_repository.dart';
import 'domain/repositories/file_opener.dart';
import 'domain/repositories/file_saver.dart';
import 'domain/repositories/temp_file_store.dart';
import 'domain/usecases/download_and_open_file_usecase.dart';
import 'domain/usecases/download_file_to_cache_usecase.dart';
import 'domain/usecases/download_file_usecase.dart';
import 'domain/usecases/get_folder_contents_usecase.dart';
import 'domain/usecases/get_own_files_usecase.dart';
import 'domain/usecases/get_recent_items_usecase.dart';
import 'external/drive_remote_datasource_impl.dart';
import 'external/file_opener_impl.dart';
import 'external/temp_file_store_impl.dart';
import 'presentation/pages/all_shared_files_page.dart';
import 'presentation/pages/category_details_page.dart';
import 'presentation/pages/folder_contents_page.dart';
import 'presentation/pages/image_viewer_page.dart';
import 'presentation/pages/my_files_page.dart';
import 'presentation/pages/new_drive_page.dart';
import 'presentation/pages/video_player_page.dart';
import 'presentation/stores/file_opener_store.dart';
import 'presentation/stores/new_drive_store.dart';

class NewDriveModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.singleton<DriveRemoteDataSource>(
          (i) => DriveRemoteDataSourceImpl(i.get<AppHttpClient>()),
        ),
        Bind.singleton<DriveRepository>(
          (i) => DriveRepositoryImpl(
              remoteDataSource: i.get<DriveRemoteDataSource>()),
        ),
        Bind.singleton<GetRecentItemsUseCase>(
          (i) => GetRecentItemsUseCase(i.get<DriveRepository>()),
        ),
        Bind.singleton<GetOwnFilesUseCase>(
          (i) => GetOwnFilesUseCase(i.get<DriveRepository>()),
        ),
        Bind.singleton<GetFolderContentsUseCase>(
          (i) => GetFolderContentsUseCase(i.get<DriveRepository>()),
        ),
        Bind.singleton<DownloadAndOpenFileUsecase>(
          (i) => DownloadAndOpenFileUsecase(
            i.get<DriveRepository>(),
            i.get<TempFileStore>(),
            i.get<FileOpener>(),
          ),
        ),
        Bind.singleton<FileSaver>(
          (i) => FileSaverImpl(),
        ),
        Bind.singleton<TempFileStore>(
          (i) => TempFileStoreImpl(),
        ),
        Bind.singleton<FileOpener>(
          (i) => FileOpenerImpl(),
        ),
        Bind.singleton<DownloadFileUsecase>(
          (i) => DownloadFileUsecase(
            i.get<DriveRepository>(),
            i.get<FileSaver>(),
            i.get<TempFileStore>(),
          ),
        ),
        Bind.singleton<DownloadFileToCacheUsecase>(
          (i) => DownloadFileToCacheUsecase(
            i.get<DriveRepository>(),
            i.get<FileSaver>(),
            i.get<TempFileStore>(),
          ),
        ),
        Bind.singleton<NewDriveStore>(
          (i) => NewDriveStore(
            getRecentItemsUseCase: i.get<GetRecentItemsUseCase>(),
            getOwnFilesUseCase: i.get<GetOwnFilesUseCase>(),
            getFolderContentsUseCase: i.get<GetFolderContentsUseCase>(),
            driveRepository: i.get<DriveRepository>(),
          ),
        ),
        Bind.singleton<FileOpenerStore>(
          (i) => FileOpenerStore(
            i.get<DownloadAndOpenFileUsecase>(),
            i.get<DownloadFileUsecase>(),
            i.get<DownloadFileToCacheUsecase>(),
          ),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (context, args) => const NewDrivePage()),
        ChildRoute(
          '/video-player',
          child: (context, args) => VideoPlayerPage(item: args.data),
        ),
        ChildRoute(
          '/image-viewer',
          child: (context, args) => ImageViewerPage(item: args.data),
        ),
        ChildRoute(
          '/category',
          child: (context, args) {
            final categoryType =
                args.data as DriveItemType? ?? DriveItemType.document;
            return CategoryDetailsPage(categoryType: categoryType);
          },
        ),
        ChildRoute('/my-files', child: (context, args) => const MyFilesPage()),
        ChildRoute(
          '/shared-files',
          child: (context, args) => const AllSharedFilesPage(),
        ),
        ChildRoute(
          '/folder',
          child: (context, args) {
            final folderId = args.data?['folderId'] as String? ?? '';
            final folderName = args.data?['folderName'] as String?;
            return FolderContentsPage(
                folderId: folderId, folderName: folderName);
          },
        ),
      ];
}
