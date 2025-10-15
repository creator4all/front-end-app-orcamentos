import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/budget_summary_card.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../../../shared/widgets/product_category.dart';
import '../../../../../../shared/widgets/school_census.dart';
import '../stores/budget_config_store.dart';

class ConfigNewBudgetPage extends StatefulWidget {
  final int budgetId;

  const ConfigNewBudgetPage({
    super.key,
    required this.budgetId,
  });

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  late final BudgetConfigStore store;

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    store = Modular.get<BudgetConfigStore>();

    // Define a data atual para o campo "Data do orçamento"
    _dataOrcamentoController.text = DateTime.now().toString().split(' ')[0];

    // Inicializa a store com o budgetId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store.initialize(widget.budgetId);
    });
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  Future<void> _selectValidityDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          store.validityDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _validadeOrcamentoController.text = picked.toString().split(' ')[0];
        store.setValidityDate(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    final result = await store.finalizeBudget();

    result.fold(
      (failure) {
        // Erro já foi definido na store
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
      (budget) {
        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Orçamento salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar de volta para a lista
        Modular.to.navigate('/budget/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Configurar Orçamento',
        showBackButton: true,
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.error != null && !store.hasData) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      store.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => store.initialize(widget.budgetId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!store.hasData) {
            return const Center(child: Text('Nenhum dado disponível'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Resumo do orçamento
                  BudgetSummaryCard(
                    budgetValue: store.totalValue,
                    selectedProductsCount: store.selectedProductsCount,
                  ),

                  SizedBox(height: 12.h),

                  // Censo Escolar
                  if (store.hasCensusData)
                    SchoolCensus(
                      leadingIcon:
                          const Icon(Icons.school, color: Colors.black54),
                      title: 'Censo Escolar',
                      info1: '${store.censusData!.totalClasses} turmas',
                      info2: '${store.censusData!.totalStudents} alunos',
                    ),

                  if (store.isLoadingCensus)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: const CircularProgressIndicator(),
                    ),

                  SizedBox(height: 12.h),

                  // Categoria: Livros
                  _buildCategory(
                    'livros',
                    'Livros',
                    Icons.menu_book,
                  ),

                  SizedBox(height: 16.h),

                  // Tecnologias
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Tecnologias',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF117BBD),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Categoria: Portal
                  _buildCategory(
                    'portal',
                    'Portal/Aplicativos',
                    Icons.computer,
                  ),

                  SizedBox(height: 8.h),

                  // Categoria: Gamificação
                  _buildCategory(
                    'gamificacao',
                    'Gamificação',
                    Icons.videogame_asset,
                  ),

                  SizedBox(height: 8.h),

                  // Categoria: Avaliação Diagnóstica
                  _buildCategory(
                    'avaliacao',
                    'Avaliação Diagnóstica',
                    Icons.assessment,
                  ),

                  SizedBox(height: 16.h),

                  // Categoria: Serviços
                  _buildCategory(
                    'servicos',
                    'Serviços',
                    Icons.support_agent,
                  ),

                  SizedBox(height: 24.h),

                  // Data do Orçamento
                  TextField(
                    controller: _dataOrcamentoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data do Orçamento',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Validade do Orçamento
                  TextField(
                    controller: _validadeOrcamentoController,
                    readOnly: true,
                    onTap: _selectValidityDate,
                    decoration: InputDecoration(
                      labelText: 'Validade do Orçamento *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Mensagem de erro
                  if (store.error != null)
                    Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              store.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: store.isSaving || !store.canFinalize
                          ? null
                          : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: store.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Orçamento',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategory(String key, String title, IconData icon) {
    return Observer(
      builder: (_) {
        final isSelected = store.categoryStates[key] ?? false;

        // Mock de dados - em produção viriam do budgetDetail
        const value = 'R\$ 0,00';
        const selectedCount = 0;
        const totalCount = 0;

        return ProductCategory(
          categoryIcon: Icon(icon, color: Colors.black54),
          title: title,
          value: value,
          selectedCount: selectedCount,
          totalCount: totalCount,
          isSelected: isSelected,
          onCheckboxChanged: (bool? value) {
            store.toggleCategory(key);
          },
        );
      },
    );
  }
}
