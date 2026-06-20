import '../entities/category_entity.dart';
import '../entities/censo_escolar_entity.dart';
import '../entities/product_entity.dart';
import '../entities/subcategory_entity.dart';
import 'census_value_normalizer.dart';

class ProductCalculationService {
  const ProductCalculationService();

  double calcularQuantidade(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    // Quantidade manual tem prioridade: ignora indicadores/censo
    if (produto.quantidadeManual) {
      return produto.quantidade.toDouble();
    }

    if (_isServico(produto.tipoProduto)) {
      return produto.quantidade.toDouble();
    }

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
      return _calcularQuantidadeTecnologia(indicadores, censo);
    }
  }

  double calcularValorProduto(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    final quantidade = calcularQuantidade(produto, censo);
    return produto.valor * quantidade;
  }

  double calcularValorUnitario(
    ProductEntity produto,
    CensoEscolarEntity? censo,
  ) {
    final valorTotal = calcularValorProduto(produto, censo);
    return valorTotal > 0 ? valorTotal : produto.valor;
  }

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

  bool _isLivro(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('livro') || tipo.contains('colecao');
  }

  bool _isTecnologia(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('tecnologia') ||
        tipo.contains('software') ||
        tipo.contains('plataforma') ||
        tipo.contains('digital');
  }

  bool _isServico(String tipoProduto) {
    final tipo = tipoProduto.toLowerCase();
    return tipo.contains('servico') || tipo.contains('serviço');
  }

  String _getTipoLabel(String tipoProduto) {
    if (_isLivro(tipoProduto)) return 'Livro';
    if (_isTecnologia(tipoProduto)) return 'Tecnologia';
    if (_isServico(tipoProduto)) return 'Serviço';
    return 'Produto';
  }

  double _calcularQuantidadeLivro(
    List<dynamic> indicadores,
    CensoEscolarEntity censo,
  ) {
    final temProfessores = indicadores.any(
      (ind) => ind.nomeEtapa.toLowerCase() == 'professores',
    );

    double total = 0.0;

    for (final ind in indicadores) {
      final nomeEtapa = ind.nomeEtapa as String;

      if (nomeEtapa.toLowerCase() == 'professores') continue;

      if (temProfessores) {
        final nomeComP = '${nomeEtapa}P';
        final valorP = censo.getValorEtapa(nomeComP) ?? 0.0;
        // Censo exibe in4ano/in5ano já arredondados — ceil individual
        total += CensusValueNormalizer.consolidateStageValue(nomeComP, valorP);
      } else {
        final valor = censo.getValorEtapa(nomeEtapa) ?? 0.0;
        total += CensusValueNormalizer.consolidateStageValue(nomeEtapa, valor);
      }
    }

    return total;
  }

  double _calcularQuantidadeTecnologia(
    List<dynamic> indicadores,
    CensoEscolarEntity censo,
  ) {
    final temProfessores = indicadores.any(
      (ind) => ind.nomeEtapa.toLowerCase() == 'professores',
    );

    double total = 0.0;

    for (final ind in indicadores) {
      final nomeEtapa = ind.nomeEtapa as String;

      if (nomeEtapa.toLowerCase() == 'professores') continue;

      final valorNormal = censo.getValorEtapa(nomeEtapa) ?? 0.0;
      total += CensusValueNormalizer.consolidateStageValue(
        nomeEtapa,
        valorNormal,
      );

      if (temProfessores) {
        final nomeComP = '${nomeEtapa}P';
        final valorP = censo.getValorEtapa(nomeComP) ?? 0.0;
        total += CensusValueNormalizer.consolidateStageValue(
          nomeComP,
          valorP,
        );
      }
    }

    return total;
  }

  List<CategoryEntity> recalcularQuantidadesProdutos(
    List<CategoryEntity> categories,
    CensoEscolarEntity censo,
  ) {
    final result = <CategoryEntity>[];

    for (final category in categories) {
      var categoryChanged = false;
      final updatedSubs = List<SubcategoryEntity>.from(category.subcategorias);

      for (var j = 0; j < updatedSubs.length; j++) {
        final sub = updatedSubs[j];
        var subChanged = false;
        final updatedProds = List<ProductEntity>.from(sub.produtos);

        for (var k = 0; k < updatedProds.length; k++) {
          final product = updatedProds[k];
          if (!product.selecionado) continue;

          final novaQtd = calcularQuantidade(product, censo);
          if (novaQtd != product.quantidade) {
            updatedProds[k] = product.copyWith(quantidade: novaQtd);
            subChanged = true;
          }
        }

        if (subChanged) {
          updatedSubs[j] = sub.copyWith(produtos: updatedProds);
          categoryChanged = true;
        }
      }

      result.add(categoryChanged
          ? category.copyWith(subcategorias: updatedSubs)
          : category);
    }

    return result;
  }
}
