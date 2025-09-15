import 'package:flutter/material.dart';

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
    // Dados de exemplo do produto
    final productInfo = {
      'Grupo': 'Solução tecnológica',
      'Sub-grupo': 'Desenvolvimento Web',
      'Solução': 'Sistema de gestão completo',
      'Indicação': 'Pequenas e médias empresas',
      'Tipo': 'Software personalizado',
      'Valor Total': 'R\$ 15.000,00',
    };

    // Grupos de checkbox de exemplo
    final checkboxGroups = [
      CheckboxGroup(
        title: 'Pré-escola',
        items: [
          CheckboxItem(label: 'Infantil'),
          CheckboxItem(label: 'Maternal'),
          CheckboxItem(label: 'Berçário'),
        ],
      ),
    ];

    ProductInfoModal.show(
      context: context,
      productInfo: productInfo,
      checkboxGroups: checkboxGroups,
      unitValue: 'R\$ 150,00',
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
