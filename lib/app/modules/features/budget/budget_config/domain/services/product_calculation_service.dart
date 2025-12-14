import '../entities/censo_escolar_entity.dart';
import '../entities/product_entity.dart';

/// Serviço responsável por calcular valores dos produtos baseado no censo escolar
/// e nos indicadores selecionados
class ProductCalculationService {
  const ProductCalculationService();

  /// Calcula o valor total de um produto baseado no tipo e indicadores selecionados
  double calcularValorProduto(
    ProductEntity produto,
    CensoEscolarEntity censo,
  ) {
    // Extrair nomes das etapas selecionadas
    final indicadoresSelecionados = produto.indicadoresEtapa
        .where((ind) => ind.selecionado)
        .map((ind) => ind.nomeEtapa)
        .toList();

    if (indicadoresSelecionados.isEmpty) {
      return 0.0;
    }

    // Calcular baseado no tipo do produto
    if (_isLivro(produto.tipoProduto)) {
      return _calcularValorLivro(produto, censo, indicadoresSelecionados);
    } else if (_isTecnologia(produto.tipoProduto)) {
      return _calcularValorTecnologia(produto, censo, indicadoresSelecionados);
    } else {
      // Para outros tipos, usar lógica padrão (como tecnologias)
      return _calcularValorTecnologia(produto, censo, indicadoresSelecionados);
    }
  }

  /// Calcula o valor unitário do produto (sem considerar quantidade)
  double calcularValorUnitario(
    ProductEntity produto,
    CensoEscolarEntity censo,
  ) {
    final valorTotal = calcularValorProduto(produto, censo);
    return valorTotal > 0 ? valorTotal : produto.valor;
  }

  /// Verifica se o produto é do tipo Livro
  bool _isLivro(String tipoProduto) {
    return tipoProduto.toLowerCase().contains('livro') ||
        tipoProduto.toLowerCase().contains('colecao') ||
        tipoProduto.toLowerCase().contains('material didático');
  }

  /// Verifica se o produto é do tipo Tecnologia
  bool _isTecnologia(String tipoProduto) {
    return tipoProduto.toLowerCase().contains('tecnologia') ||
        tipoProduto.toLowerCase().contains('software') ||
        tipoProduto.toLowerCase().contains('plataforma') ||
        tipoProduto.toLowerCase().contains('digital');
  }

  /// Calcula valor para produtos do tipo LIVRO
  /// Regra: Soma apenas indicadores de professores (com sufixo P)
  double _calcularValorLivro(
    ProductEntity produto,
    CensoEscolarEntity censo,
    List<String> indicadoresSelecionados,
  ) {
    double totalCenso = 0.0;

    // Para livros, consideramos apenas indicadores de professores
    for (String indicador in indicadoresSelecionados) {
      if (indicador.endsWith('P')) {
        totalCenso += censo.getValorEtapaProfessores(indicador) ?? 0.0;
      }
    }

    // Se não há professores selecionados, valor é zero
    if (totalCenso == 0.0) {
      return 0.0;
    }

    // Valor final = valor unitário * total de professores
    return produto.valor * totalCenso;
  }

  /// Calcula valor para produtos do tipo TECNOLOGIA
  /// Regra: Soma todos os indicadores (alunos + professores)
  double _calcularValorTecnologia(
    ProductEntity produto,
    CensoEscolarEntity censo,
    List<String> indicadoresSelecionados,
  ) {
    double totalCenso = 0.0;

    // Para tecnologias, somamos todos os indicadores
    for (String indicador in indicadoresSelecionados) {
      if (indicador.endsWith('P')) {
        totalCenso += censo.getValorEtapaProfessores(indicador) ?? 0.0;
      } else {
        totalCenso += censo.getValorEtapa(indicador) ?? 0.0;
      }
    }

    // Se não há indicadores selecionados, valor é zero
    if (totalCenso == 0.0) {
      return 0.0;
    }

    // Valor final = valor unitário * total de alunos/professores
    return produto.valor * totalCenso;
  }

  /// Calcula a quantidade baseada nos indicadores selecionados
  double calcularQuantidade(
    ProductEntity produto,
    CensoEscolarEntity censo,
  ) {
    final indicadoresSelecionados = produto.indicadoresEtapa
        .where((ind) => ind.selecionado)
        .map((ind) => ind.nomeEtapa)
        .toList();

    if (indicadoresSelecionados.isEmpty) {
      return 0.0;
    }

    double total = 0.0;

    if (_isLivro(produto.tipoProduto)) {
      // Para livros, soma apenas professores
      for (String indicador in indicadoresSelecionados) {
        if (indicador.endsWith('P')) {
          total += censo.getValorEtapaProfessores(indicador) ?? 0.0;
        }
      }
    } else {
      // Para tecnologias, soma todos
      for (String indicador in indicadoresSelecionados) {
        if (indicador.endsWith('P')) {
          total += censo.getValorEtapaProfessores(indicador) ?? 0.0;
        } else {
          total += censo.getValorEtapa(indicador) ?? 0.0;
        }
      }
    }

    return total;
  }

  /// Gera um resumo do cálculo para exibição
  String gerarResumoCalculo(
    ProductEntity produto,
    CensoEscolarEntity censo,
  ) {
    final indicadoresSelecionados =
        produto.indicadoresEtapa.where((ind) => ind.selecionado).toList();

    if (indicadoresSelecionados.isEmpty) {
      return 'Nenhum indicador selecionado';
    }

    final tipo = _isLivro(produto.tipoProduto) ? 'Livro' : 'Tecnologia';
    final quantidade = calcularQuantidade(produto, censo);
    final valorTotal = calcularValorProduto(produto, censo);

    return '$tipo: ${indicadoresSelecionados.length} indicadores, '
        'Quantidade: ${quantidade.toStringAsFixed(0)}, '
        'Total: R\$ ${valorTotal.toStringAsFixed(2)}';
  }
}
