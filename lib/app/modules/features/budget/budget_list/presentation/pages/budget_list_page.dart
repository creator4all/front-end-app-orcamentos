import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../../shared/widgets/rename_budget_modal.dart';
import '../../../../../../shared/widgets/widgets.dart';
import '../stores/budget_list_store.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  late final BudgetListStore _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<BudgetListStore>();
    _checkAuthAndFetch();
  }

  Future<void> _checkAuthAndFetch() async {
    // Verificar se há token de autenticação
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print('🔐 Token encontrado: ${token != null ? 'SIM' : 'NÃO'}');
      if (token != null) {
        print(
            '🔐 Token (primeiros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }
    } catch (e) {
      print('❌ Erro ao verificar token: $e');
    }

    _store.fetch();
  }

  void _handleSearchChanged(String query) {
    _store.setSearchQuery(query);
  }

  void _handleFiltersChanged(List<String> filters) {
    // Sincronizar filtros da UI com a store
    // Remover filtros que não estão mais na lista
    for (final filter in _store.selectedFilters.toList()) {
      if (!filters.contains(filter)) {
        _store.toggleFilter(filter);
      }
    }

    // Adicionar novos filtros
    for (final filter in filters) {
      if (!_store.selectedFilters.contains(filter)) {
        _store.toggleFilter(filter);
      }
    }
  }

  void _handleReset() {
    _store.resetFilters();
  }

  Future<void> _handleRenameBudget(int budgetId, String currentName) async {
    try {
      await RenameBudgetModal.show(
        context: context,
        currentName: currentName,
        onRename: (String newName) async {
          // Chamar a Store que usa o UseCase
          await _store.renameBudget(budgetId, newName);

          // Verificar se houve erro
          if (_store.error != null) {
            throw Exception(_store.error);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao renomear orçamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Orçamentos',
        showBackButton: false,
        userName: 'Pedro Penha',
        userEmail: 'pedro.penha.martins@gmail.com',
        userDocument: '03.848.869/0001-89',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Componente de filtros
            BudgetFilterWidget(
              onSearchChanged: _handleSearchChanged,
              onFiltersChanged: _handleFiltersChanged,
              onReset: _handleReset,
            ),

            // Seção Realizados/Arquivados
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Observer(
                builder: (_) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _store.selectedFilters.contains('arquivado')
                          ? 'Arquivados'
                          : 'Realizados',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: const Color(0xFF484848),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Modular.to.pushNamed('/budget/new');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                      ),
                      icon: Icon(
                        Icons.add,
                        size: 16.sp,
                        color: const Color(0xFFFFFFFF),
                      ),
                      label: const Text('Novo Orç.'),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading && _store.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_store.error != null && _store.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Erro: ${_store.error}'),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _store.refresh(),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (_store.items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => _store.refresh(),
                      child: ListView(
                        children: [
                          SizedBox(height: 200.h),
                          const Center(
                              child: Text('Nenhum orçamento encontrado')),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => _store.refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      itemCount: _store.items.length,
                      itemBuilder: (context, index) {
                        final b = _store.items[index];

                        // Mapear status da API para enum
                        BudgetStatus status;
                        switch (b.status.toLowerCase()) {
                          case 'aprovado':
                            status = BudgetStatus.approved;
                            break;
                          case 'reprovado':
                            status = BudgetStatus.notApproved;
                            break;
                          case 'expirado':
                            status = BudgetStatus.expired;
                            break;
                          default:
                            status = BudgetStatus.pending;
                        }

                        // Calcular dias restantes
                        int daysRemaining = 0;
                        if (b.dataValidade != null) {
                          final now = DateTime.now();
                          final difference =
                              b.dataValidade!.difference(now).inDays;
                          daysRemaining = difference > 0 ? difference : 0;
                        }

                        return GestureDetector(
                          onLongPress: () {
                            _handleRenameBudget(
                              b.id,
                              b.nome ?? 'Orçamento #${b.id}',
                            );
                          },
                          child: BudgetCardWidget(
                            title: b.nome ?? 'Orçamento #${b.id}',
                            partner:
                                null, // TODO: Implementar quando tiver dados do parceiro
                            seller:
                                null, // TODO: Implementar quando tiver dados do vendedor
                            budgetCode:
                                'ORC-${b.id.toString().padLeft(4, '0')}',
                            dueDate: b.dataValidade ??
                                DateTime.now()
                                    .add(Duration(days: b.diasValidade)),
                            totalValue: b.total,
                            daysRemaining: daysRemaining,
                            status: status,
                            isArchived: b.status.toLowerCase() == 'arquivado',
                            userRole: UserRole
                                .admin, // TODO: Implementar baseado no usuário logado
                            onTap: () {
                              // Navigate to edit budget page
                              Modular.to.pushNamed(
                                '/budget/edit',
                                arguments: {'budget': b},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
