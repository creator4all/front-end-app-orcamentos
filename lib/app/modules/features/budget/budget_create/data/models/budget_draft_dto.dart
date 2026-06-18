import '../../../../../../../app/shared/utils/date_utils.dart';
import '../../../budget_config/data/models/category_dto.dart';
import '../../../budget_config/data/models/product_dto.dart';
import '../../../budget_config/data/models/subcategory_dto.dart';
import '../../domain/entities/budget_draft_entity.dart';
import '../../domain/entities/location_entity.dart';
import 'cidade_dto.dart';
import 'orcamento_produto_dto.dart';

class BudgetDraftDto {
  final int id;
  final String? name;
  final int? partnerId;
  final String? partnerName;
  final int userId;
  final String userName;
  final String userEmail;
  final List<int> cityIds;
  final List<String> cityNames;
  final String? responsibleName;
  final String? responsibleEmail;
  final DateTime validityDate;
  final int validityDays;
  final String status;
  final double total;
  final bool createdByAdmin;
  final DateTime? createdAt;
  final DateTime dataValidade;
  final CidadeDto? cidade;
  final List<OrcamentoProdutoDto> orcamentoProdutos;
  final List<CategoryDTO> categories;

  const BudgetDraftDto({
    required this.id,
    this.name,
    this.partnerId,
    this.partnerName,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.cityIds,
    required this.cityNames,
    this.responsibleName,
    this.responsibleEmail,
    required this.validityDate,
    required this.validityDays,
    required this.status,
    required this.total,
    required this.createdByAdmin,
    this.createdAt,
    required this.dataValidade,
    this.cidade,
    required this.orcamentoProdutos,
    this.categories = const [],
  });

  factory BudgetDraftDto.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'] as Map<String, dynamic>?;
    final partnerDestino = json['partner_destino'] as Map<String, dynamic>?;
    final cidadeJson = json['cidade'] as Map<String, dynamic>?;
    final produtosArray = json['produtos'];

    if (produtosArray is! List) {
      throw const FormatException(
          'Contrato inválido: "produtos" deve ser uma lista');
    }

    final mapaIndicadores = _parseMapaIndicadores(json['mapa_indicadores']);

    // Support prefixed (orc_cidade_id) and unprefixed (cidade_id) fields
    final cityId = (json['orc_cidade_id'] as num?)?.toInt() ??
        (json['cidade_id'] as num?)?.toInt() ??
        0;
    final cityName = cidadeJson?['nome_cidade'] as String? ??
        cidadeJson?['nome'] as String? ??
        '';
    final cityIds = cityId > 0 ? [cityId] : <int>[];
    final cityNames = cityName.isNotEmpty ? [cityName] : <String>[];

    // Support prefixed (orc_data_validade) and unprefixed (data_validade)
    final validityDateStr = json['orc_data_validade'] ?? json['data_validade'];
    final parsedValidityDate = validityDateStr != null
        ? DateTime.parse(validityDateStr as String)
        : DateTime.now();

    final orcamentoProdutos = <OrcamentoProdutoDto>[];
    final categories = _buildCategoriesFromProdutos(
      produtosArray,
      mapaIndicadores,
    );

    final cidade = cidadeJson != null ? CidadeDto.fromJson(cidadeJson) : null;

    // Support prefixed partner fields (par_partnerId, par_trade_name)
    final partnerIdValue =
        partnerDestino?['par_partnerId'] ?? partnerDestino?['id'];
    final partnerNameValue =
        partnerDestino?['par_trade_name'] ?? partnerDestino?['nome_fantasia'];

    // Support prefixed user fields (usr_userId, usr_name, usr_email)
    final userIdValue = (usuario?['usr_userId'] as num?)?.toInt() ??
        (usuario?['id'] as num?)?.toInt() ??
        0;
    final userNameValue =
        usuario?['usr_name'] as String? ?? usuario?['nome'] as String? ?? '';
    final userEmailValue =
        usuario?['usr_email'] as String? ?? usuario?['email'] as String? ?? '';

    return BudgetDraftDto(
      id: (json['orc_orcamentoId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      name: json['orc_nome'] as String? ?? json['nome'] as String?,
      partnerId:
          partnerIdValue != null ? (partnerIdValue as num?)?.toInt() : null,
      partnerName: partnerNameValue as String?,
      userId: userIdValue,
      userName: userNameValue,
      userEmail: userEmailValue,
      cityIds: cityIds,
      cityNames: cityNames,
      responsibleName: json['orc_responsavel_nome'] as String?,
      responsibleEmail: json['orc_responsavel_email'] as String?,
      validityDate: parsedValidityDate,
      validityDays: (json['orc_dias_validade'] as num?)?.toInt() ??
          (json['dias_validade'] as num?)?.toInt() ??
          60,
      status: json['orc_status'] as String? ??
          json['status'] as String? ??
          'rascunho',
      total: double.tryParse(
              (json['orc_total'] ?? json['total'])?.toString() ?? '0') ??
          0.0,
      createdByAdmin: json['orc_criado_por_admin'] as bool? ??
          json['criado_por_admin'] as bool? ??
          false,
      createdAt: parseDate(json['created_at']),
      dataValidade: parsedValidityDate,
      cidade: cidade,
      orcamentoProdutos: orcamentoProdutos,
      categories: categories,
    );
  }

  BudgetDraftEntity toEntity() {
    return BudgetDraftEntity(
      id: id,
      name: name,
      partnerId: partnerId,
      partnerName: partnerName ?? '',
      location: LocationEntity(
        stateCode: '',
        stateName: '',
        cityCode: cityIds.isNotEmpty ? cityIds.first.toString() : '',
        cityName: cityNames.isNotEmpty ? cityNames.first : '',
      ),
      responsibleName: responsibleName,
      responsibleEmail: responsibleEmail,
      validityDate: validityDate,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      createdByUserId: userId,
      validityDays: validityDays,
      total: total,
      createdByAdmin: createdByAdmin,
      dataValidade: dataValidade,
      cidade: cidade?.toEntity(),
      orcamentoProdutos:
          orcamentoProdutos.map((dto) => dto.toEntity()).toList(),
      categories: categories.map((dto) => dto.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'nome': name,
      'usuario_id': userId,
      'cidades': cityIds,
      'status': status,
      'total': total,
      'dias_validade': validityDays,
      'data_validade': validityDate.toIso8601String(),
      'criado_por_admin': createdByAdmin,
    };

    if (partnerId != null) {
      data['partner_destino_id'] = partnerId;
    }

    if (responsibleName != null) {
      data['orc_responsavel_nome'] = responsibleName;
    }

    if (responsibleEmail != null) {
      data['orc_responsavel_email'] = responsibleEmail;
    }

    return data;
  }

  static Map<int, Map<String, dynamic>> _parseMapaIndicadores(dynamic value) {
    if (value is! Map) {
      throw const FormatException(
          'Contrato inválido: "mapa_indicadores" deve ser um objeto');
    }

    return value.map((key, item) {
      final indicador = _asMap(item, 'mapa_indicadores[$key]');
      final id = _toInt(indicador['ine_indicadoresId']);

      if (id <= 0) {
        throw FormatException(
            'Contrato inválido: indicador sem ine_indicadoresId em "$key"');
      }

      return MapEntry(id, indicador);
    });
  }

  static List<CategoryDTO> _buildCategoriesFromProdutos(
    List<dynamic> produtosArray,
    Map<int, Map<String, dynamic>> mapaIndicadores,
  ) {
    final categorias = <int, _CategoryBucket>{};

    for (final item in produtosArray) {
      final produtoJson = _asMap(item, 'produtos[]');
      final subcategoriaJson =
          _asMap(produtoJson['subcategoria'], 'produto.subcategoria');
      final categoriaJson =
          _asMap(subcategoriaJson['categoria'], 'subcategoria.categoria');

      final categoriaId = _toInt(categoriaJson['cat_categoriaId']);
      final subcategoriaId = _toInt(subcategoriaJson['sub_subcategoriasId']);

      if (categoriaId <= 0 || subcategoriaId <= 0) {
        throw const FormatException(
            'Contrato inválido: produto sem categoria/subcategoria válida');
      }

      final categoria = categorias.putIfAbsent(
        categoriaId,
        () => _CategoryBucket(
          id: categoriaId,
          nome: _toString(categoriaJson['cat_nome']),
          ordem: _toInt(categoriaJson['cat_ordem']),
          expandido: _toBool(categoriaJson['cat_expandido']),
        ),
      );

      final subcategoria = categoria.subcategorias.putIfAbsent(
        subcategoriaId,
        () => _SubcategoryBucket(
          id: subcategoriaId,
          nome: _toString(subcategoriaJson['sub_name']),
          ordem: _toInt(subcategoriaJson['sub_order']),
        ),
      );

      final produtoComIndicadores = Map<String, dynamic>.from(produtoJson);
      produtoComIndicadores['indicadores_etapa'] =
          _buildIndicadoresEtapa(produtoJson, mapaIndicadores);

      subcategoria.produtos.add(ProductDTO.fromJson(produtoComIndicadores));
    }

    final orderedCategorias = categorias.values.toList()
      ..sort((a, b) {
        final ordem = a.ordem.compareTo(b.ordem);
        if (ordem != 0) return ordem;
        return a.id.compareTo(b.id);
      });

    return orderedCategorias.map((categoria) => categoria.toDto()).toList();
  }

  static List<Map<String, dynamic>> _buildIndicadoresEtapa(
    Map<String, dynamic> produtoJson,
    Map<int, Map<String, dynamic>> mapaIndicadores,
  ) {
    final indicadoresProduto = produtoJson['indicadores'];

    if (indicadoresProduto is! List) {
      throw const FormatException(
          'Contrato inválido: produto.indicadores deve ser uma lista');
    }

    final indicadoresSelecionados = <int>{};
    final produtoIndicadorPorIndicador = <int, int>{};

    for (final item in indicadoresProduto) {
      final indicadorProduto = _asMap(item, 'produto.indicadores[]');
      final indicadorId =
          _toInt(indicadorProduto['indicadores_etapa_ine_indicadoresId']);

      if (indicadorId <= 0) continue;

      if (_toBool(indicadorProduto['prd_valor'])) {
        indicadoresSelecionados.add(indicadorId);
      }

      final produtoIndicadorId =
          _toInt(indicadorProduto['prd_produtos_indicadoresId']);
      if (produtoIndicadorId > 0) {
        produtoIndicadorPorIndicador[indicadorId] = produtoIndicadorId;
      }
    }

    final indicadores = mapaIndicadores.values.toList()
      ..sort((a, b) {
        final grupoA = _asOptionalMap(a['grupo']);
        final grupoB = _asOptionalMap(b['grupo']);
        final grupoOrdem = _toInt(grupoA?['gru_ordem'])
            .compareTo(_toInt(grupoB?['gru_ordem']));
        if (grupoOrdem != 0) return grupoOrdem;

        final indicadorOrdem =
            _toInt(a['ine_ordem']).compareTo(_toInt(b['ine_ordem']));
        if (indicadorOrdem != 0) return indicadorOrdem;

        return _toInt(a['ine_indicadoresId'])
            .compareTo(_toInt(b['ine_indicadoresId']));
      });

    return indicadores.map((indicador) {
      final indicadorId = _toInt(indicador['ine_indicadoresId']);
      final grupo = _asOptionalMap(indicador['grupo']);
      final selecionado = indicadoresSelecionados.contains(indicadorId);

      return <String, dynamic>{
        'produto_indicador_id': produtoIndicadorPorIndicador[indicadorId] ?? 0,
        'indicador_id': indicadorId,
        'indicador_nome': _toString(indicador['ine_titulo']),
        'nome_etapa': _toString(indicador['ine_nome']),
        'grupo_id': _toInt(indicador['gru_gruposId']),
        'grupo_nome': _toString(grupo?['gru_grupo_nome']),
        'selecionado': selecionado,
        'valor_padrao': selecionado,
      };
    }).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value, String context) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('Contrato inválido: "$context" deve ser um objeto');
  }

  static Map<String, dynamic>? _asOptionalMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }

  static String _toString(dynamic value) => value?.toString() ?? '';
}

class _CategoryBucket {
  final int id;
  final String nome;
  final int ordem;
  final bool expandido;
  final Map<int, _SubcategoryBucket> subcategorias = {};

  _CategoryBucket({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.expandido,
  });

  CategoryDTO toDto() {
    final orderedSubcategorias = subcategorias.values.toList()
      ..sort((a, b) {
        final ordem = a.ordem.compareTo(b.ordem);
        if (ordem != 0) return ordem;
        return a.id.compareTo(b.id);
      });

    return CategoryDTO(
      id: id,
      nome: nome,
      ordem: ordem,
      expandido: expandido,
      subcategorias: orderedSubcategorias
          .map((subcategoria) => subcategoria.toDto())
          .toList(),
    );
  }
}

class _SubcategoryBucket {
  final int id;
  final String nome;
  final int ordem;
  final List<ProductDTO> produtos = [];

  _SubcategoryBucket({
    required this.id,
    required this.nome,
    required this.ordem,
  });

  SubcategoryDTO toDto() {
    produtos.sort((a, b) {
      final ordem = a.ordem.compareTo(b.ordem);
      if (ordem != 0) return ordem;
      return a.id.compareTo(b.id);
    });

    return SubcategoryDTO(
      id: id,
      nome: nome,
      ordem: ordem,
      produtos: produtos,
    );
  }
}
