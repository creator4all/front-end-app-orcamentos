/// Modelos de dados para representar o retorno da API
library;

/// Modelo para um produto básico (lista de produtos)
class ApiProduct {
  final String nome;
  final String valorTotal;
  final int quantidade;
  final String valorUnitario;
  final bool isSelected;

  ApiProduct({
    required this.nome,
    required this.valorTotal,
    required this.quantidade,
    required this.valorUnitario,
    this.isSelected = false,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      nome: json['nome'] as String,
      valorTotal: json['valor_total'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
      valorUnitario: json['valor_unitario'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'valor_total': valorTotal,
      'quantidade': quantidade,
      'valor_unitario': valorUnitario,
      'is_selected': isSelected,
    };
  }
}

/// Modelo para índices escolares
class IndiceEscolar {
  final String nome;
  final bool checked;

  IndiceEscolar({
    required this.nome,
    required this.checked,
  });

  factory IndiceEscolar.fromJson(Map<String, dynamic> json) {
    return IndiceEscolar(
      nome: json['nome'] as String,
      checked: json['checked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'checked': checked,
    };
  }
}

/// Modelo para grupo de índices escolares
class GrupoIndiceEscolar {
  final String grupo;
  final List<IndiceEscolar> indices;

  GrupoIndiceEscolar({
    required this.grupo,
    required this.indices,
  });

  factory GrupoIndiceEscolar.fromJson(Map<String, dynamic> json) {
    return GrupoIndiceEscolar(
      grupo: json['grupo'] as String,
      indices: (json['indices'] as List)
          .map((e) => IndiceEscolar.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupo': grupo,
      'indices': indices.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para informações detalhadas do produto
class ApiProductInfo {
  final String grupo;
  final String subGrupo;
  final String solucao;
  final String indicacao;
  final String tipo;
  final String valorTotal;
  final List<GrupoIndiceEscolar> gruposIndices;

  ApiProductInfo({
    required this.grupo,
    required this.subGrupo,
    required this.solucao,
    required this.indicacao,
    required this.tipo,
    required this.valorTotal,
    required this.gruposIndices,
  });

  factory ApiProductInfo.fromJson(Map<String, dynamic> json) {
    return ApiProductInfo(
      grupo: json['grupo'] as String,
      subGrupo: json['sub_grupo'] as String,
      solucao: json['solucao'] as String,
      indicacao: json['indicacao'] as String,
      tipo: json['tipo'] as String,
      valorTotal: json['valor_total'] as String,
      gruposIndices: (json['grupos_indices'] as List)
          .map((e) => GrupoIndiceEscolar.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grupo': grupo,
      'sub_grupo': subGrupo,
      'solucao': solucao,
      'indicacao': indicacao,
      'tipo': tipo,
      'valor_total': valorTotal,
      'grupos_indices': gruposIndices.map((e) => e.toJson()).toList(),
    };
  }
}

/// Modelo para categoria de produtos
class ApiProductCategory {
  final String categoria;
  final List<ApiProduct> produtos;

  ApiProductCategory({
    required this.categoria,
    required this.produtos,
  });

  factory ApiProductCategory.fromJson(Map<String, dynamic> json) {
    return ApiProductCategory(
      categoria: json['categoria'] as String,
      produtos: (json['produtos'] as List)
          .map((e) => ApiProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'produtos': produtos.map((e) => e.toJson()).toList(),
    };
  }
}
