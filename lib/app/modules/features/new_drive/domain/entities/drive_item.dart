import 'package:equatable/equatable.dart';

import 'shared_by_user.dart';

enum DriveItemType {
  document,
  video,
  image,
  folder,
}

class DriveItem extends Equatable {
  final String id;
  final String name;
  final DriveItemType type;
  final String size;
  final DateTime lastViewed;
  final String? thumbnailUrl;
  final int? parentId;
  final String? parentName;
  final List<DriveItem>? children;
  final SharedByUser? sharedBy;
  final String? downloadUrl;

  const DriveItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.lastViewed,
    this.thumbnailUrl,
    this.parentId,
    this.parentName,
    this.children,
    this.sharedBy,
    this.downloadUrl,
  });
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(lastViewed);

    if (difference.inDays == 0) {
      return 'compartilhado hoje';
    } else if (difference.inDays == 1) {
      return 'compartilhado ontem';
    } else if (difference.inDays <= 7) {
      return 'compartilhado semana passada';
    } else {
      if (lastViewed.year == now.year) {
        return '${lastViewed.day.toString().padLeft(2, '0')}/${lastViewed.month.toString().padLeft(2, '0')}';
      } else {
        return '${lastViewed.day.toString().padLeft(2, '0')}/${lastViewed.month.toString().padLeft(2, '0')}/${lastViewed.year}';
      }
    }
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        size,
        lastViewed,
        thumbnailUrl,
        parentId,
        parentName,
        children,
        sharedBy,
        downloadUrl,
      ];
}
