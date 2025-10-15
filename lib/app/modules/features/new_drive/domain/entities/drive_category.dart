import 'package:equatable/equatable.dart';

import 'drive_item.dart';

/// Entidade que representa uma categoria de arquivos no drive
class DriveCategory extends Equatable {
  final String id;
  final String name;
  final DriveItemType type;
  final int itemCount;
  final String totalSize;

  const DriveCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.itemCount,
    required this.totalSize,
  });

  @override
  List<Object?> get props => [id, name, type, itemCount, totalSize];
}
