import 'package:flutter/material.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/indicador_etapa_entity.dart';
import 'package:multimidiaapp/app/modules/features/budget/budget_config/domain/entities/product_entity.dart';

import 'product_info_modal.dart';

/// Exemplo de uso do ProductInfoModal
class ProductInfoModalExample extends StatelessWidget {
  const ProductInfoModalExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo ProductInfoModal'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showProductInfoModal(context),
          child: const Text('Abrir Modal de Produto'),
        ),
      ),
    );
  }

  void _showProductInfoModal(BuildContext context) {
    // Indicadores de exemplo
    final indicadoresEtapa = [
      IndicadorEtapaEntity(
        produtoIndicadorId: 1,
        indicadorId: 1,
        indicadorNome: 'Infantil',
        nomeEtapa: 'Pré-escola',
        grupoId: 1,
        grupoNome: 'Etapas de Ensino',
        selecionado: true,
      ),
      IndicadorEtapaEntity(
        produtoIndicadorId: 2,
        indicadorId: 2,
        indicadorNome: 'Maternal',
        nomeEtapa: 'Pré-escola',
        grupoId: 1,
        grupoNome: 'Etapas de Ensino',
        selecionado: false,
      ),
      IndicadorEtapaEntity(
        produtoIndicadorId: 3,
        indicadorId: 3,
        indicadorNome: 'Berçário',
        nomeEtapa: 'Pré-escola',
        grupoId: 1,
        grupoNome: 'Etapas de Ensino',
        selecionado: false,
      ),
    ];

    // Criar ProductEntity de exemplo
    final productEntity = ProductEntity(
      id: 1,
      codigo: '001',
      solucao: 'Sistema de gestão completo',
      tipo: 'Software personalizado',
      ativo: true,
      valor: 150.00,
      indicacao: 'Pequenas e médias empresas',
      tipoProduto: 'Software',
      ordem: 1,
      subcategoriaId: 1,
      selecionado: false,
      quantidade: 0,
      temOverride: false,
      valorOriginal: 150.00,
      ativoOriginal: true,
      indicadoresEtapa: indicadoresEtapa,
    );

    ProductInfoModal.show(
      context: context,
      product: productEntity,
      onSave: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informações do produto salvas com sucesso!'),
            backgroundColor: Color(0xFF56B34A),
          ),
        );
      },
    );
  }
}
