import '../../domain/entities/subcategory_entity.dart';
import 'product_dto.dart';

/// DTO para parsing JSON das subcategorias da API
class SubcategoryDTO {
  final int id;
  final String nome;
  final List<ProductDTO> produtos;

  SubcategoryDTO({
    required this.id,
    required this.nome,
    required this.produtos,
  });

  /// Cria um DTO a partir do JSON da API
  factory SubcategoryDTO.fromJson(Map<String, dynamic> json) {
    try {
      print('   🔍 [SubcategoryDTO] Parseando subcategoria: ${json['nome']}');

      final int id = json['id'] as int;
      final String nome = json['nome'] as String;

      final List<ProductDTO> produtos = [];
      if (json['produtos'] != null && json['produtos'] is List) {
        final prodList = json['produtos'] as List<dynamic>;
        print('      📦 Parseando ${prodList.length} produtos...');

        for (int i = 0; i < prodList.length; i++) {
          try {
            final prodJson = prodList[i] as Map<String, dynamic>;
            final prod = ProductDTO.fromJson(prodJson);
            produtos.add(prod);
            print(
                '         ✅ Produto ${i + 1}/${prodList.length}: ${prod.solucao}');
          } catch (e) {
            print('         ❌ Erro no produto ${i + 1}: $e');
            print('         📄 JSON: ${prodList[i]}');
            rethrow;
          }
        }
      }

      return SubcategoryDTO(
        id: id,
        nome: nome,
        produtos: produtos,
      );
    } catch (e, stackTrace) {
      print('❌ [SubcategoryDTO] Erro ao parsear subcategoria: $e');
      print('📄 JSON recebido: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Converte o DTO para Entity
  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
      id: id,
      nome: nome,
      produtos: produtos.map((p) => p.toEntity()).toList(),
    );
  }

  /// Converte o DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'produtos': produtos.map((p) => p.toJson()).toList(),
    };
  }

  /// Converte uma Entity para DTO
  factory SubcategoryDTO.fromEntity(SubcategoryEntity entity) {
    return SubcategoryDTO(
      id: entity.id,
      nome: entity.nome,
      produtos: entity.produtos.map((p) => ProductDTO.fromEntity(p)).toList(),
    );
  }
}
