import '../entities/censo_escolar_entity.dart';
import '../entities/product_entity.dart';

/// Serviço responsável por calcular valores dos produtos baseado no censo escolar
/// e nos indicadores selecionados.
///
/// Tipos de produto e regras:
/// - **Livro/Coleção**: Se indicador 'professores' selecionado, soma apenas índices com sufixo P
/// - **Tecnologia**: Soma todos os índices (alunos + professores quando marcado)
/// - **Serviço**: Usa quantidade manual definida pelo usuário
class ProductCalculationService {
  const ProductCalculationService();

  // ==================== MÉTODOS PÚBLICOS ====================

  /// Calcula a quantidade baseada nos indicadores selecionados e tipo do produto
  ///
  /// Para Livros: soma apenas valores P quando 'professores' está selecionado
  /// Para Tecnologia: soma todos os valores
  /// Para Serviços: retorna a quantidade manual do produto
  double calcularQuantidade(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    // Serviços usam quantidade manual
    if (_isServico(produto.tipoProduto)) {
      return produto.quantidade.toDouble();
    }

    // Sem censo, não podemos calcular
    if (censo == null) {
      return produto.quantidade.toDouble();
    }

    final indicadores =
        produto.indicadoresEtapa.where((ind) => ind.selecionado).toList();

    if (indicadores.isEmpty) {
      return 0.0;
    }

    if (_isLivro(produto.tipoProduto)) {
      return _calcularQuantidadeLivro(indicadores, censo);
    } else {
      // Tecnologia e outros tipos
      return _calcularQuantidadeTecnologia(indicadores, censo);
    }
  }

  /// Calcula o valor total de um produto (quantidade * valor unitário)
  double calcularValorProduto(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    final quantidade = calcularQuantidade(produto, censo);
    return produto.valor * quantidade;
  }

  /// Calcula o valor unitário do produto (sem considerar quantidade)
  double calcularValorUnitario(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    final valorTotal = calcularValorProduto(produto, censo);
    return valorTotal > 0 ? valorTotal : produto.valor;
  }

  /// Gera um resumo do cálculo para exibição
  String gerarResumoCalculo(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    final indicadoresSelecionados =
        produto.indicadoresEtapa.where((ind) => ind.selecionado).toList();

    if (indicadoresSelecionados.isEmpty && !_isServico(produto.tipoProduto)) {
      return 'Nenhum indicador selecionado';
    }

    final tipo = _getTipoLabel(produto.tipoProduto);
    final quantidade = calcularQuantidade(produto, censo);
    final valorTotal = calcularValorProduto(produto, censo);

    return '$tipo: ${indicadoresSelecionados.length} indicadores, '
        'Quantidade: ${quantidade.toStringAsFixed(0)}, '
        'Total: R\$ ${valorTotal.toStringAsFixed(2)}';
  }

  // ==================== CLASSIFICAÇÃO DE TIPOS ====================

  /// Verifica se o produto é do tipo Livro (inclui coleção)
  bool _isLivro(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('livro') || tipo.contains('colecao');
  }

  /// Verifica se o produto é do tipo Tecnologia
  bool _isTecnologia(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('tecnologia') ||
        tipo.contains('software') ||
        tipo.contains('plataforma') ||
        tipo.contains('digital');
  }

  /// Verifica se o produto é do tipo Serviço
  bool _isServico(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('servico') || tipo.contains('serviço');
  }

  /// Retorna label legível do tipo
  String _getTipoLabel(String tipoProduto) {
    if (_isLivro(tipoProduto)) return 'Livro';
    if (_isTecnologia(tipoProduto)) return 'Tecnologia';
    if (_isServico(tipoProduto)) return 'Serviço';
    return 'Produto';
  }

  // ==================== CÁLCULOS ESPECÍFICOS ====================

  /// Calcula quantidade para produtos do tipo LIVRO
  ///
  /// Regra:
  /// - Se 'professores' está selecionado: soma valores com sufixo P (ef1anoP, ef2anoP)
  /// - Se não: soma valores normais (ef1ano, ef2ano)
  double _calcularQuantidadeLivro(
    List<dynamic> indicadores,
    CensoEscolarEntity censo,
  ) {
    // Verificar se 'professores' está selecionado
    final temProfessores = indicadores.any(
      (ind) => ind.nomeEtapa.toLowerCase() == 'professores',
    );

    double total = 0.0;

    for (final ind in indicadores) {
      final nomeEtapa = ind.nomeEtapa as String;

      // Pular o próprio indicador 'professores'
      if (nomeEtapa.toLowerCase() == 'professores') continue;

      if (temProfessores) {
        // Buscar versão P do indicador no censo
        final valorP = censo.getValorEtapa('${nomeEtapa}P') ?? 0.0;
        total += valorP;
      } else {
        // Buscar valor normal no censo
        final valor = censo.getValorEtapa(nomeEtapa) ?? 0.0;
        total += valor;
      }
    }

    return total;
  }

  /// Calcula quantidade para produtos do tipo TECNOLOGIA
  ///
  /// Regra: Soma TODOS os valores (etapas normais + professores quando selecionado)
  double _calcularQuantidadeTecnologia(
    List<dynamic> indicadores,
    CensoEscolarEntity censo,
  ) {
    // Verificar se 'professores' está selecionado
    final temProfessores = indicadores.any(
      (ind) => ind.nomeEtapa.toLowerCase() == 'professores',
    );

    double total = 0.0;

    for (final ind in indicadores) {
      final nomeEtapa = ind.nomeEtapa as String;

      // Pular o próprio indicador 'professores'
      if (nomeEtapa.toLowerCase() == 'professores') continue;

      // Sempre soma o valor normal
      final valorNormal = censo.getValorEtapa(nomeEtapa) ?? 0.0;
      total += valorNormal;

      // Se professores selecionado, também soma a versão P
      if (temProfessores) {
        final valorP = censo.getValorEtapa('${nomeEtapa}P') ?? 0.0;
        total += valorP;
      }
    }

    return total;
  }
}
