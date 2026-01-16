import 'package:equatable/equatable.dart';

import 'shared_by_user.dart';

/// Enum para tipos de itens do drive
enum DriveItemType {
  document,
  video,
  image,
  folder,
}

/// Entidade que representa um item do drive
/// Esta é uma entidade pura de domínio sem dependências externas
class DriveItem extends Equatable {
  final String id;
  final String name;
  final DriveItemType type;
  final String size;
  final DateTime lastViewed;
  final String? thumbnailUrl;
  final int? itemCount; // Para pastas/categorias
  final int? parentId; // ID da pasta pai
  final String? parentName; // Nome da pasta pai (para exibição)
  final List<DriveItem>? children; // Itens dentro desta pasta
  final SharedByUser? sharedBy; // Usuário que compartilhou
  final String? downloadUrl; // URL para download direto

  const DriveItem({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.lastViewed,
    this.thumbnailUrl,
    this.itemCount,
    this.parentId,
    this.parentName,
    this.children,
    this.sharedBy,
    this.downloadUrl,
  });

  /// Formata a data de compartilhamento de acordo com as regras de negócio
  /// - "compartilhado hoje" se for hoje
  /// - "compartilhado ontem" se foi ontem
  /// - "compartilhado semana passada" se foi nos últimos 7 dias
  /// - "DD/MM" para outras datas no mesmo ano
  /// - "DD/MM/YYYY" para datas de anos anteriores
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
      // Se for do mesmo ano, não mostra o ano
      if (lastViewed.year == now.year) {
        return '${lastViewed.day.toString().padLeft(2, '0')}/${lastViewed.month.toString().padLeft(2, '0')}';
      } else {
        // Se for de outro ano, mostra o ano completo
        return '${lastViewed.day.toString().padLeft(2, '0')}/${lastViewed.month.toString().padLeft(2, '0')}/${lastViewed.year}';
      }
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        size,
        lastViewed,
        thumbnailUrl,
        itemCount,
        parentId,
        parentName,
        children,
        sharedBy,
        downloadUrl,
      ];
}
