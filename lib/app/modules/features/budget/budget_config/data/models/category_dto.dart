import '../../domain/entities/category_entity.dart';
import 'subcategory_dto.dart';

/// DTO para parsing JSON das categorias da API
class CategoryDTO {
  final int id;
  final String nome;
  final List<SubcategoryDTO> subcategorias;

  CategoryDTO({
    required this.id,
    required this.nome,
    required this.subcategorias,
  });

  /// Cria um DTO a partir do JSON da API
  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [CategoryDTO] Parseando categoria: ${json['nome']}');

      final int id = json['id'] as int;
      final String nome = json['nome'] as String;

      print('   ✅ ID: $id, Nome: $nome');

      final List<SubcategoryDTO> subcategorias = [];
      if (json['subcategorias'] != null && json['subcategorias'] is List) {
        final subcatList = json['subcategorias'] as List<dynamic>;
        print('   📦 Parseando ${subcatList.length} subcategorias...');

        for (int i = 0; i < subcatList.length; i++) {
          try {
            final subcatJson = subcatList[i] as Map<String, dynamic>;
            final subcat = SubcategoryDTO.fromJson(subcatJson);
            subcategorias.add(subcat);
            print(
                '      ✅ Subcategoria ${i + 1}/${subcatList.length}: ${subcat.nome}');
          } catch (e) {
            print('      ❌ Erro na subcategoria ${i + 1}: $e');
            print('      📄 JSON: ${subcatList[i]}');
            rethrow;
          }
        }
      }

      return CategoryDTO(
        id: id,
        nome: nome,
        subcategorias: subcategorias,
      );
    } catch (e, stackTrace) {
      print('❌ [CategoryDTO] Erro ao parsear categoria: $e');
      print('📄 JSON recebido: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Converte o DTO para Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      nome: nome,
      subcategorias: subcategorias.map((s) => s.toEntity()).toList(),
    );
  }

  /// Converte o DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'subcategorias': subcategorias.map((s) => s.toJson()).toList(),
    };
  }

  /// Converte uma Entity para DTO
  factory CategoryDTO.fromEntity(CategoryEntity entity) {
    return CategoryDTO(
      id: entity.id,
      nome: entity.nome,
      subcategorias: entity.subcategorias
          .map((s) => SubcategoryDTO.fromEntity(s))
          .toList(),
    );
  }
}
