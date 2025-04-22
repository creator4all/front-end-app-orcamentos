import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo para demonstração
    final dummyBudgets = [
      {
        'id': '1',
        'title': 'Orçamento para Projeto A',
        'description': 'Desenvolvimento de sistema de gestão para empresa de logística',
        'date': '10/04/2025',
        'value': 15000.00,
        'status': 'Aprovado',
      },
      {
        'id': '2',
        'title': 'Orçamento para Projeto B',
        'description': 'Consultoria em implementação de ERP para indústria de alimentos',
        'date': '05/04/2025',
        'value': 8500.00,
        'status': 'Pendente',
      },
      {
        'id': '3',
        'title': 'Orçamento para Projeto C',
        'description': 'Desenvolvimento de aplicativo mobile para empresa de transporte',
        'date': '01/04/2025',
        'value': 12000.00,
        'status': 'Rejeitado',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implementar filtro de orçamentos
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar busca de orçamentos
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Seus Orçamentos',
              subtitle: 'Total: ${dummyBudgets.length} orçamentos',
              trailing: const Icon(
                Icons.add_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              onTrailingTap: () {
                // Navegar para tela de criação de orçamento
              },
            ),
            
            Expanded(
              child: ListView.builder(
                itemCount: dummyBudgets.length,
                itemBuilder: (context, index) {
                  final budget = dummyBudgets[index];
                  return BudgetCard(
                    title: budget['title'] as String,
                    description: budget['description'] as String,
                    date: budget['date'] as String,
                    value: budget['value'] as double,
                    status: budget['status'] as String,
                    onTap: () {
                      // Navegar para detalhes do orçamento
                    },
                    onEdit: () {
                      // Navegar para edição do orçamento
                    },
                    onDelete: () {
                      // Mostrar diálogo de confirmação para excluir orçamento
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmar exclusão'),
                          content: const Text(
                            'Tem certeza que deseja excluir este orçamento? Esta ação não pode ser desfeita.',
                          ),
                          actions: [
                            TextButtonLink(
                              text: 'Cancelar',
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                            ),
                            PrimaryButton(
                              text: 'Excluir',
                              onPressed: () {
                                // Implementar exclusão do orçamento
                                Navigator.of(ctx).pop();
                              },
                              width: 100,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para tela de criação de orçamento
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
