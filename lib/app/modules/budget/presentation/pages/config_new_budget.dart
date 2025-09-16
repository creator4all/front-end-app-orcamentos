import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../shared/widgets/book_item.dart';
import '../../../../shared/widgets/books_modal.dart';
import '../../../../shared/widgets/budget_summary_card.dart';
import '../../../../shared/widgets/custom_modal.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/product_category.dart';
import '../../../../shared/widgets/product_info_modal.dart';
import '../../../../shared/widgets/school_census.dart';
import '../../../../shared/widgets/technology_item.dart';
import '../../../../shared/widgets/technology_products_modal.dart';
import 'school_census.dart';

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

  final TextEditingController _dataOrcamentoController =
      TextEditingController();
  final TextEditingController _validadeOrcamentoController =
      TextEditingController();

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

  /// Cria dados de exemplo para o ProductInfoModal
  Map<String, dynamic> _createProductData(String productName) {
    // Dados de exemplo baseados no nome do produto
    final productInfo = <String, String>{};
    final checkboxGroups = <CheckboxGroup>[];
    String unitValue = '';

    switch (productName) {
      case 'Livro Didático - Volume 1':
        productInfo.addAll({
          'Grupo': 'Material Didático',
          'Sub-grupo': 'Livros Didáticos',
          'Solução': 'Ensino Fundamental I',
          'Indicação': 'Alunos do 1º ano',
          'Tipo': 'Material impresso',
          'Valor Total': 'R\$ 25,00',
        });
        unitValue = 'R\$ 25,00';
        checkboxGroups.addAll([
          CheckboxGroup(
            title: 'Pré-escola',
            items: [
              CheckboxItem(label: 'Infantil'),
              CheckboxItem(label: 'Maternal'),
              CheckboxItem(label: 'Berçário'),
            ],
          ),
          CheckboxGroup(
            title: 'Características',
            items: [
              CheckboxItem(label: 'Material colorido'),
              CheckboxItem(label: 'Capa dura'),
              CheckboxItem(label: 'Papel reciclável'),
            ],
          ),
        ]);
        break;
      case 'Livro Didático - Volume 2':
        productInfo.addAll({
          'Grupo': 'Material Didático',
          'Sub-grupo': 'Livros Didáticos',
          'Solução': 'Ensino Fundamental I',
          'Indicação': 'Alunos do 1º ano',
          'Tipo': 'Material impresso',
          'Valor Total': 'R\$ 25,00',
        });
        unitValue = 'R\$ 25,00';
        checkboxGroups.addAll([
          CheckboxGroup(
            title: 'Características',
            items: [
              CheckboxItem(label: 'Material colorido'),
              CheckboxItem(label: 'Capa flexível'),
              CheckboxItem(label: 'Papel reciclável'),
            ],
          ),
          CheckboxGroup(
            title: 'Complementos',
            items: [
              CheckboxItem(label: 'Exercícios práticos'),
              CheckboxItem(label: 'QR Code para conteúdo digital'),
            ],
          ),
        ]);
        break;
      case 'Livro de Exercícios':
        productInfo.addAll({
          'Grupo': 'Material Didático',
          'Sub-grupo': 'Material de Apoio',
          'Solução': 'Atividades Práticas',
          'Indicação': 'Reforço escolar',
          'Tipo': 'Material digital',
          'Valor Total': 'R\$ 15,00',
        });
        unitValue = 'R\$ 15,00';
        checkboxGroups.addAll([
          CheckboxGroup(
            title: 'Formato',
            items: [
              CheckboxItem(label: 'PDF interativo'),
              CheckboxItem(label: 'Acesso online'),
              CheckboxItem(label: 'Download permitido'),
            ],
          ),
          CheckboxGroup(
            title: 'Recursos',
            items: [
              CheckboxItem(label: 'Correção automática'),
              CheckboxItem(label: 'Relatórios de progresso'),
            ],
          ),
        ]);
        break;
      case 'Guia do Professor':
        productInfo.addAll({
          'Grupo': 'Material Didático',
          'Sub-grupo': 'Material de Apoio',
          'Solução': 'Suporte Pedagógico',
          'Indicação': 'Professores',
          'Tipo': 'Material impresso',
          'Valor Total': 'R\$ 35,00',
        });
        unitValue = 'R\$ 35,00';
        checkboxGroups.addAll([
          CheckboxGroup(
            title: 'Conteúdo',
            items: [
              CheckboxItem(label: 'Planos de aula'),
              CheckboxItem(label: 'Atividades extras'),
              CheckboxItem(label: 'Avaliações'),
            ],
          ),
          CheckboxGroup(
            title: 'Recursos Digitais',
            items: [
              CheckboxItem(label: 'Acesso ao portal'),
              CheckboxItem(label: 'Vídeos explicativos'),
              CheckboxItem(label: 'Banco de questões'),
            ],
          ),
        ]);
        break;
      default:
        productInfo.addAll({
          'Grupo': 'Produto Genérico',
          'Sub-grupo': 'Categoria Padrão',
          'Solução': 'Solução Educacional',
          'Indicação': 'Uso geral',
          'Tipo': 'Material misto',
          'Valor Total': 'R\$ 30,00',
        });
        unitValue = 'R\$ 30,00';
        checkboxGroups.add(
          CheckboxGroup(
            title: 'Características Gerais',
            items: [
              CheckboxItem(label: 'Qualidade premium'),
              CheckboxItem(label: 'Suporte incluso'),
            ],
          ),
        );
    }

    return {
      'productInfo': productInfo,
      'checkboxGroups': checkboxGroups,
      'unitValue': unitValue,
    };
  }

  /// Abre o modal de informações do produto
  void _showProductInfoModal(BuildContext context, String productName) {
    final data = _createProductData(productName);

    ProductInfoModal.show(
      context: context,
      productInfo: data['productInfo'] as Map<String, String>,
      checkboxGroups: data['checkboxGroups'] as List<CheckboxGroup>,
      unitValue: data['unitValue'] as String,
      onSave: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informações de "$productName" salvas com sucesso!'),
            backgroundColor: const Color(0xFF56B34A),
          ),
        );
      },
    );
  }

  /// Shows the products modal for a specific book category
  void _showProductsModal(BuildContext context, String categoryTitle) {
    CustomModal.show(
      context: context,
      title: categoryTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lista de produtos usando TechnologyItem
          TechnologyItem(
            itemName: 'Livro Didático - Volume 1',
            text1: 'R\$ 25,00',
            text2: '150 pág',
            text3: 'Físico',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onActionTap: () {
              _showProductInfoModal(context, 'Livro Didático - Volume 1');
            },
          ),
          TechnologyItem(
            itemName: 'Livro Didático - Volume 2',
            text1: 'R\$ 25,00',
            text2: '140 pág',
            text3: 'Físico',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onActionTap: () {
              _showProductInfoModal(context, 'Livro Didático - Volume 2');
            },
          ),
          TechnologyItem(
            itemName: 'Livro de Exercícios',
            text1: 'R\$ 15,00',
            text2: '80 pág',
            text3: 'Digital',
            isSelected: false,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onActionTap: () {
              _showProductInfoModal(context, 'Livro de Exercícios');
            },
          ),
          TechnologyItem(
            itemName: 'Guia do Professor',
            text1: 'R\$ 35,00',
            text2: '200 pág',
            text3: 'Físico',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onActionTap: () {
              _showProductInfoModal(context, 'Guia do Professor');
            },
          ),

          SizedBox(height: 20.h),

          // Botão de salvar
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('$categoryTitle - Produtos salvos com sucesso!'),
                    backgroundColor: const Color(0xFF56B34A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56B34A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(
                Icons.save,
                size: 18.sp,
                color: Colors.white,
              ),
              label: Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the modal for "Livros" category
  void _showLivrosModal(BuildContext context) {
    CustomModal.show(
      context: context,
      title: 'Livros',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lista de livros usando BookItem
          BookItem(
            title: 'Matemática - 1º Ano',
            value: 'R\$ 45,00',
            quantity: '43/48',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onTap: () {
              _showProductsModal(context, 'Matemática - 1º Ano');
            },
          ),
          BookItem(
            title: 'Português - 1º Ano',
            value: 'R\$ 42,00',
            quantity: '35/40',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onTap: () {
              _showProductsModal(context, 'Português - 1º Ano');
            },
          ),
          BookItem(
            title: 'História - 1º Ano',
            value: 'R\$ 38,00',
            quantity: '0/25',
            isSelected: false,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onTap: () {
              _showProductsModal(context, 'História - 1º Ano');
            },
          ),
          BookItem(
            title: 'Geografia - 1º Ano',
            value: 'R\$ 40,00',
            quantity: '20/30',
            isSelected: true,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onTap: () {
              _showProductsModal(context, 'Geografia - 1º Ano');
            },
          ),
          BookItem(
            title: 'Ciências - 1º Ano',
            value: 'R\$ 44,00',
            quantity: '1/1',
            isSelected: false,
            onCheckboxChanged: (value) {
              // TODO: Implementar lógica de seleção
            },
            onTap: () {
              _showProductsModal(context, 'Ciências - 1º Ano');
            },
          ),

          SizedBox(height: 20.h),

          // Botão de salvar
          SizedBox(
            width: double.infinity,
            height: 40.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Livros salvos com sucesso!'),
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
              icon: Icon(
                Icons.save,
                size: 18.sp,
                color: Colors.white,
              ),
              label: Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              SchoolCensus(
                leadingIcon: const Icon(Icons.school, color: Colors.black54),
                title: 'Censo Escolar',
                info1: '7 turmas',
                info2: '2000 alunos',
                onActionTap: () {
                  print('DEBUG: School Census tapped, navigating to SchoolCensusPage');
                  try {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SchoolCensusPage(),
                      ),
                    );
                    print('DEBUG: Navigation successful');
                  } catch (e) {
                    print('DEBUG: Navigation failed with error: $e');
                  }
                },
              ),
              const SizedBox(height: 12),
              ProductCategory(
                categoryIcon:
                    const Icon(Icons.menu_book, color: Colors.black54),
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
                onCardTap: () {
                  BooksModal.show(context: context);
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
                onCardTap: () {
                  TechnologyProductsModal.show(
                    context: context,
                    category: 'Portal/Aplicativos',
                  );
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
                onCardTap: () {
                  TechnologyProductsModal.show(
                    context: context,
                    category: 'Gamificação',
                  );
                },
              ),
              const SizedBox(height: 12),

              // Avaliação Diagnóstica
              ProductCategory(
                categoryIcon:
                    const Icon(Icons.assessment, color: Colors.black54),
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
                onCardTap: () {
                  TechnologyProductsModal.show(
                    context: context,
                    category: 'Avaliação Diagnóstica',
                  );
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
                onCardTap: () {
                  TechnologyProductsModal.show(
                    context: context,
                    category: 'Serviços',
                  );
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
                      _validadeOrcamentoController.text =
                          selectedDate.toString().split(' ')[0];
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
