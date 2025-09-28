import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../shared/widgets/widgets.dart';
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
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      print('🔐 Token encontrado: ${token != null ? 'SIM' : 'NÃO'}');
      if (token != null) {
        print('🔐 Token (primeiros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      }
    } catch (e) {
      print('❌ Erro ao verificar token: $e');
    }
    
    _store.fetch();
  }

  String _selectedFilter = '';

  void _handleSearchChanged(String query) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Search query: $query');
  }

  void _handleFiltersChanged(List<String> filters) {
    // Aqui você pode implementar a lógica de filtragem
    debugPrint('Selected filters: $filters');

    // Atualiza o filtro selecionado para controlar o texto "Realizados/Arquivados"
    setState(() {
      _selectedFilter = filters.contains('archived') ? 'archived' : '';
    });
  }

  void _handleReset() {
    // Aqui você pode implementar a lógica de reset
    debugPrint('Filters reset');
    setState(() {
      _selectedFilter = '';
    });
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _selectedFilter == 'archived' ? 'Arquivados' : 'Realizados',
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

                        return BudgetCardWidget(
                          title: b.nome ?? 'Orçamento #${b.id}',
                          partner:
                              null, // TODO: Implementar quando tiver dados do parceiro
                          seller:
                              null, // TODO: Implementar quando tiver dados do vendedor
                          budgetCode: 'ORC-${b.id.toString().padLeft(4, '0')}',
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
                            // TODO: Navegar para detalhes do orçamento
                            print('Orçamento ${b.id} clicado');
                          },
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
