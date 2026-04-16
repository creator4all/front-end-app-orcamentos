import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/utils/user_role_mapper.dart';
import '../../../../../../shared/widgets/rename_budget_modal.dart';
import '../../../../../../shared/widgets/widgets.dart';
import '../../../../../features/auth/presentation/stores/auth_store.dart';
import '../stores/budget_list_store.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  late final BudgetListStore _store;
  late final AuthStore _authStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = Modular.get<BudgetListStore>();
    _authStore = Modular.get<AuthStore>();

    if (_store.allItems.isEmpty) {
      _store.fetch();
    }
  }

  void _handleSearchChanged(String query) {
    _store.setSearchQuery(query);
  }

  void _handleFiltersChanged(List<String> filters) {
    for (final filter in _store.selectedFilters.toList()) {
      if (!filters.contains(filter)) {
        _store.toggleFilter(filter);
      }
    }

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
          await _store.renameBudget(budgetId, newName);

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
    // PopScope com canPop: false impede que o botão voltar feche o app
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: CustomTopBar(
          title: 'Orçamentos',
          showBackButton: false,
          authStore: _authStore,
        ),
        body: RefreshIndicator(
          onRefresh: () => _store.refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Componente de filtros
              SliverToBoxAdapter(
                child: BudgetFilterWidget(
                  onSearchChanged: _handleSearchChanged,
                  onFiltersChanged: _handleFiltersChanged,
                  onReset: _handleReset,
                ),
              ),

              // Seção Realizados/Arquivados
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                          onPressed: () async {
                            final result = await Modular.to.pushNamed(
                              '/budget/new',
                            );
                            if (result == true) {
                              _store.refresh();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF117BBD),
                            foregroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
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
              ),

              // Lista de orçamentos
              Observer(
                builder: (_) {
                  if (_store.isLoading && _store.items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (_store.error != null && _store.items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
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
                        ),
                      ),
                    );
                  }
                  if (_store.items.isEmpty) {
                    return SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 200.h),
                            const Center(
                              child: Text('Nenhum orçamento encontrado'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final b = _store.items[index];
                        final budgetTitle = b.nome ?? 'Orçamento #${b.id}';

                        final showAdminIcon = b.criadoPorAdmin &&
                            b.partnerDestinoId != null &&
                            b.partnerDestinoId != _authStore.partnerId;

                        BudgetStatus status;
                        switch (b.status.toLowerCase()) {
                          case 'aprovado':
                            status = BudgetStatus.approved;
                            break;
                          case 'nao_aprovado':
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
                          final today = DateTime(now.year, now.month, now.day);
                          final target = DateTime(b.dataValidade!.year,
                              b.dataValidade!.month, b.dataValidade!.day);
                          final difference = target.difference(today).inDays;
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
                            partner: b.empresaRazaoSocial,
                            seller: b.usuarioNome,
                            budgetCode:
                                'ORC-${b.id.toString().padLeft(4, '0')}',
                            dueDate: b.dataValidade ??
                                DateTime.now().add(
                                  Duration(days: b.diasValidade),
                                ),
                            totalValue: b.total,
                            daysRemaining: daysRemaining,
                            status: status,
                            isArchived: b.isArchived,
                            userRole: mapStringToUserRole(_authStore.userRole),
                            createdByAdmin: showAdminIcon,
                            onInfoTap: showAdminIcon
                                ? () => CustomInfoDialog.show(
                                      context: context,
                                      type: DialogType.info,
                                      title:
                                          'Orçamento criado por Administrador',
                                      message:
                                          'Este orçamento foi criado por um usuário '
                                          'administrador e direcionado para você. '
                                          'Por isso ele aparece na sua lista.',
                                    )
                                : null,
                            onTap: () async {
                              final result = await Modular.to.pushNamed(
                                '/budget/edit/${b.id}',
                                arguments: {'initialTitle': budgetTitle},
                              );
                              if (result == true) {
                                _store.refresh();
                              }
                            },
                          ),
                        );
                      }, childCount: _store.items.length),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
