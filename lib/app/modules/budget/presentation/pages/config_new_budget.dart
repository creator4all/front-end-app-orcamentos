import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/budget_summary_card.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/product_category.dart';
import '../../../../shared/widgets/school_census.dart';

class ConfigNewBudgetPage extends StatefulWidget {
  const ConfigNewBudgetPage({super.key});

  @override
  State<ConfigNewBudgetPage> createState() => _ConfigNewBudgetPageState();
}

class _ConfigNewBudgetPageState extends State<ConfigNewBudgetPage> {
  bool isLivrosSelected = true;
  bool isPortalSelected = false;
  bool isGamificacaoSelected = false;
  bool isAvaliacaoSelected = false;
  bool isServicosSelected = false;
  
  final TextEditingController _dataOrcamentoController = TextEditingController();
  final TextEditingController _validadeOrcamentoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Define a data atual para o campo "Data do orçamento"
    _dataOrcamentoController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    _dataOrcamentoController.dispose();
    _validadeOrcamentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Novo orçamento',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
          children: [
            const BudgetSummaryCard(
              budgetValue: 0.0,
              selectedProductsCount: 0,
            ),
            const SizedBox(height: 12),
            const SchoolCensus(
              leadingIcon: Icon(Icons.school, color: Colors.black54),
              title: 'Censo Escolar',
              info1: '7 turmas',
              info2: '2000 alunos',
            ),
            const SizedBox(height: 12),
            ProductCategory(
              categoryIcon: const Icon(Icons.menu_book, color: Colors.black54),
              title: 'Livros',
              value: 'R\$500.000,00',
              selectedCount: 47,
              totalCount: 48,
              isSelected: isLivrosSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isLivrosSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tecnologias',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF117BBD),
                      ),
                    ),
                    Text(
                      'R\$ 33.642.456,80',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Portal/Aplicativos
            ProductCategory(
              categoryIcon: const Icon(Icons.web, color: Colors.black54),
              title: 'Portal/Aplicativos',
              value: 'R\$150.000,00',
              selectedCount: 5,
              totalCount: 10,
              isSelected: isPortalSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isPortalSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Gamificação
            ProductCategory(
              categoryIcon: const Icon(Icons.games, color: Colors.black54),
              title: 'Gamificação',
              value: 'R\$75.000,00',
              selectedCount: 12,
              totalCount: 15,
              isSelected: isGamificacaoSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isGamificacaoSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Avaliação Diagnóstica
            ProductCategory(
              categoryIcon: const Icon(Icons.assessment, color: Colors.black54),
              title: 'Avaliação Diagnóstica',
              value: 'R\$200.000,00',
              selectedCount: 8,
              totalCount: 12,
              isSelected: isAvaliacaoSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isAvaliacaoSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 12),
            
            // Serviços
            ProductCategory(
              categoryIcon: const Icon(Icons.build, color: Colors.black54),
              title: 'Serviços',
              value: 'R\$300.000,00',
              selectedCount: 20,
              totalCount: 25,
              isSelected: isServicosSelected,
              onCheckboxChanged: (bool? value) {
                setState(() {
                  isServicosSelected = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Data do orçamento
            Row(
              children: [
                Text(
                  'Data do orçamento',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Mostrar informação sobre a data do orçamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data em que o orçamento foi gerado'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: const Color(0xFF2830F2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34.h,
              child: TextFormField(
                controller: _dataOrcamentoController,
                enabled: false, // Campo sempre desabilitado
                decoration: InputDecoration(
                  hintText: 'Data de geração do orçamento',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  fillColor: Colors.grey[100],
                  filled: true,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Validade do orçamento
            Row(
              children: [
                Text(
                  'Validade do orçamento',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Mostrar informação sobre a validade do orçamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data até quando o orçamento é válido'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: const Color(0xFF2830F2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34.h,
              child: TextFormField(
                controller: _validadeOrcamentoController,
                decoration: InputDecoration(
                  hintText: 'Selecione a data de validade',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFF117BBD)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                readOnly: true,
                onTap: () async {
                  // Abre o seletor de data
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selectedDate != null) {
                    _validadeOrcamentoController.text = selectedDate.toString().split(' ')[0];
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar lógica de salvar orçamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Orçamento salvo com sucesso!'),
                      backgroundColor: Color(0xFF56B34A),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF56B34A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Salvar Orçamento',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Espaço no final para scroll
          ],
          ),
        ),
      ),
    );
  }
}
