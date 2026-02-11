import '../models/drive_item_model.dart';

abstract class DriveRemoteDataSource {
  Future<List<DriveItemModel>> getRecentItems();

  Future<List<DriveItemModel>> getOwnFiles();

  Future<DriveItemModel> getFileDetails(String fileId);

  Future<DriveItemModel> getItemHierarchy(String itemId);

  Future<List<int>> downloadFileBytes(String fileId);
}
