import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/api_models.dart';
import 'book_item.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

/// Modal para livros com estrutura de dados da API
class BooksModal {
  /// Mock de dados de livros simulando retorno da API
  static final List<ApiProduct> _mockBooksData = [
    ApiProduct(
      nome: 'Matemática - 1º Ano',
      valorTotal: 'R\$ 45,00',
      quantidade: 43,
      valorUnitario: 'R\$ 1,04',
      isSelected: true,
    ),
    ApiProduct(
      nome: 'Português - 1º Ano',
      valorTotal: 'R\$ 42,00',
      quantidade: 35,
      valorUnitario: 'R\$ 1,20',
      isSelected: true,
    ),
    ApiProduct(
      nome: 'História - 1º Ano',
      valorTotal: 'R\$ 38,00',
      quantidade: 0,
      valorUnitario: 'R\$ 1,52',
      isSelected: false,
    ),
    ApiProduct(
      nome: 'Geografia - 1º Ano',
      valorTotal: 'R\$ 40,00',
      quantidade: 20,
      valorUnitario: 'R\$ 2,00',
      isSelected: true,
    ),
    ApiProduct(
      nome: 'Ciências - 1º Ano',
      valorTotal: 'R\$ 44,00',
      quantidade: 1,
      valorUnitario: 'R\$ 44,00',
      isSelected: false,
    ),
  ];

  /// Mock de dados de produtos dentro de cada livro simulando retorno da API
  static final Map<String, List<ApiProduct>> _mockBookProductsData = {
    'Matemática - 1º Ano': [
      ApiProduct(
        nome: 'Livro Didático - Volume 1',
        valorTotal: 'R\$ 25,00',
        quantidade: 150,
        valorUnitario: 'R\$ 0,17',
        isSelected: true,
      ),
      ApiProduct(
        nome: 'Livro Didático - Volume 2',
        valorTotal: 'R\$ 25,00',
        quantidade: 140,
        valorUnitario: 'R\$ 0,18',
        isSelected: true,
      ),
      ApiProduct(
        nome: 'Livro de Exercícios',
        valorTotal: 'R\$ 15,00',
        quantidade: 80,
        valorUnitario: 'R\$ 0,19',
        isSelected: false,
      ),
      ApiProduct(
        nome: 'Guia do Professor',
        valorTotal: 'R\$ 35,00',
        quantidade: 200,
        valorUnitario: 'R\$ 0,18',
        isSelected: true,
      ),
    ],
    'Português - 1º Ano': [
      ApiProduct(
        nome: 'Livro Didático - Volume 1',
        valorTotal: 'R\$ 22,00',
        quantidade: 130,
        valorUnitario: 'R\$ 0,17',
        isSelected: true,
      ),
      ApiProduct(
        nome: 'Livro de Exercícios',
        valorTotal: 'R\$ 18,00',
        quantidade: 90,
        valorUnitario: 'R\$ 0,20',
        isSelected: true,
      ),
      ApiProduct(
        nome: 'Guia do Professor',
        valorTotal: 'R\$ 32,00',
        quantidade: 180,
        valorUnitario: 'R\$ 0,18',
        isSelected: false,
      ),
    ],
    'História - 1º Ano': [
      ApiProduct(
        nome: 'Livro Didático - Volume 1',
        valorTotal: 'R\$ 28,00',
        quantidade: 120,
        valorUnitario: 'R\$ 0,23',
        isSelected: false,
      ),
      ApiProduct(
        nome: 'Atlas Histórico',
        valorTotal: 'R\$ 35,00',
        quantidade: 60,
        valorUnitario: 'R\$ 0,58',
        isSelected: false,
      ),
    ],
    'Geografia - 1º Ano': [
      ApiProduct(
        nome: 'Livro Didático - Volume 1',
        valorTotal: 'R\$ 30,00',
        quantidade: 110,
        valorUnitario: 'R\$ 0,27',
        isSelected: true,
      ),
      ApiProduct(
        nome: 'Atlas Geográfico',
        valorTotal: 'R\$ 40,00',
        quantidade: 80,
        valorUnitario: 'R\$ 0,50',
        isSelected: true,
      ),
    ],
    'Ciências - 1º Ano': [
      ApiProduct(
        nome: 'Livro Didático - Volume 1',
        valorTotal: 'R\$ 26,00',
        quantidade: 100,
        valorUnitario: 'R\$ 0,26',
        isSelected: false,
      ),
      ApiProduct(
        nome: 'Kit de Experimentos',
        valorTotal: 'R\$ 45,00',
        quantidade: 1,
        valorUnitario: 'R\$ 45,00',
        isSelected: false,
      ),
    ],
  };

  /// Mock de dados de informações detalhadas dos livros simulando retorno da API
  static final Map<String, ApiProductInfo> _mockBookInfoData = {
    'Matemática - 1º Ano': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 45,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: true),
            IndiceEscolar(nome: 'Maternal', checked: false),
            IndiceEscolar(nome: 'Berçário', checked: false),
          ],
        ),
        GrupoIndiceEscolar(
          grupo: 'Características',
          indices: [
            IndiceEscolar(nome: 'Material colorido', checked: true),
            IndiceEscolar(nome: 'Capa dura', checked: true),
            IndiceEscolar(nome: 'Papel reciclável', checked: false),
          ],
        ),
      ],
    ),
    'Português - 1º Ano': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 42,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: true),
            IndiceEscolar(nome: 'Maternal', checked: true),
            IndiceEscolar(nome: 'Berçário', checked: false),
          ],
        ),
      ],
    ),
    'História - 1º Ano': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 38,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: false),
            IndiceEscolar(nome: 'Maternal', checked: false),
            IndiceEscolar(nome: 'Berçário', checked: false),
          ],
        ),
      ],
    ),
    'Geografia - 1º Ano': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 40,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: true),
            IndiceEscolar(nome: 'Maternal', checked: false),
            IndiceEscolar(nome: 'Berçário', checked: false),
          ],
        ),
      ],
    ),
    'Ciências - 1º Ano': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 44,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: false),
            IndiceEscolar(nome: 'Maternal', checked: false),
            IndiceEscolar(nome: 'Berçário', checked: true),
          ],
        ),
      ],
    ),
    // Produtos dentro dos livros
    'Livro Didático - Volume 1': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 25,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Pré-escola',
          indices: [
            IndiceEscolar(nome: 'Infantil', checked: true),
            IndiceEscolar(nome: 'Maternal', checked: false),
            IndiceEscolar(nome: 'Berçário', checked: false),
          ],
        ),
        GrupoIndiceEscolar(
          grupo: 'Características',
          indices: [
            IndiceEscolar(nome: 'Material colorido', checked: true),
            IndiceEscolar(nome: 'Capa dura', checked: true),
            IndiceEscolar(nome: 'Papel reciclável', checked: false),
          ],
        ),
      ],
    ),
    'Livro Didático - Volume 2': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Livros Didáticos',
      solucao: 'Ensino Fundamental I',
      indicacao: 'Alunos do 1º ano',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 25,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Características',
          indices: [
            IndiceEscolar(nome: 'Material colorido', checked: true),
            IndiceEscolar(nome: 'Capa flexível', checked: true),
            IndiceEscolar(nome: 'Papel reciclável', checked: false),
          ],
        ),
        GrupoIndiceEscolar(
          grupo: 'Complementos',
          indices: [
            IndiceEscolar(nome: 'Exercícios práticos', checked: true),
            IndiceEscolar(
                nome: 'QR Code para conteúdo digital', checked: false),
          ],
        ),
      ],
    ),
    'Livro de Exercícios': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Material de Apoio',
      solucao: 'Atividades Práticas',
      indicacao: 'Reforço escolar',
      tipo: 'Material digital',
      valorTotal: 'R\$ 15,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Formato',
          indices: [
            IndiceEscolar(nome: 'PDF interativo', checked: true),
            IndiceEscolar(nome: 'Acesso online', checked: true),
            IndiceEscolar(nome: 'Download permitido', checked: false),
          ],
        ),
        GrupoIndiceEscolar(
          grupo: 'Recursos',
          indices: [
            IndiceEscolar(nome: 'Correção automática', checked: false),
            IndiceEscolar(nome: 'Relatórios de progresso', checked: true),
          ],
        ),
      ],
    ),
    'Guia do Professor': ApiProductInfo(
      grupo: 'Material Didático',
      subGrupo: 'Material de Apoio',
      solucao: 'Suporte Pedagógico',
      indicacao: 'Professores',
      tipo: 'Material impresso',
      valorTotal: 'R\$ 35,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Conteúdo',
          indices: [
            IndiceEscolar(nome: 'Planos de aula', checked: true),
            IndiceEscolar(nome: 'Atividades extras', checked: true),
            IndiceEscolar(nome: 'Avaliações', checked: false),
          ],
        ),
        GrupoIndiceEscolar(
          grupo: 'Recursos Digitais',
          indices: [
            IndiceEscolar(nome: 'Acesso ao portal', checked: true),
            IndiceEscolar(nome: 'Vídeos explicativos', checked: false),
            IndiceEscolar(nome: 'Banco de questões', checked: true),
          ],
        ),
      ],
    ),
  };

  /// Converte dados da API para formato do ProductInfoModal
  static Map<String, dynamic> _getProductInfoData(String productName) {
    final apiProductInfo = _mockBookInfoData[productName];

    if (apiProductInfo == null) {
      return {
        'productInfo': {
          'Grupo': 'Produto Genérico',
          'Sub-grupo': 'Categoria Padrão',
          'Solução': 'Solução Educacional',
          'Indicação': 'Uso geral',
          'Tipo': 'Material misto',
          'Valor Total': 'R\$ 30,00',
        },
        'checkboxGroups': [
          CheckboxGroup(
            title: 'Características Gerais',
            items: [
              CheckboxItem(label: 'Qualidade premium'),
              CheckboxItem(label: 'Suporte incluso'),
            ],
          ),
        ],
        'unitValue': 'R\$ 30,00',
      };
    }

    final productInfo = {
      'Grupo': apiProductInfo.grupo,
      'Sub-grupo': apiProductInfo.subGrupo,
      'Solução': apiProductInfo.solucao,
      'Indicação': apiProductInfo.indicacao,
      'Tipo': apiProductInfo.tipo,
      'Valor Total': apiProductInfo.valorTotal,
    };

    final checkboxGroups = apiProductInfo.gruposIndices.map((grupo) {
      return CheckboxGroup(
        title: grupo.grupo,
        items: grupo.indices.map((indice) {
          return CheckboxItem(
            label: indice.nome,
            isSelected: indice.checked,
          );
        }).toList(),
      );
    }).toList();

    return {
      'productInfo': productInfo,
      'checkboxGroups': checkboxGroups,
      'unitValue': apiProductInfo.valorTotal,
    };
  }

  /// Abre o modal de informações do produto
  static void _showProductInfoModal(BuildContext context, String productName) {
    final data = _getProductInfoData(productName);

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

  /// Exibe modal de produtos dentro de um livro específico
  static Future<T?> showBookProducts<T>({
    required BuildContext context,
    required String bookTitle,
  }) {
    final products = _mockBookProductsData[bookTitle] ?? [];

    return CustomModal.show<T>(
      context: context,
      title: bookTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lista de produtos usando TechnologyItem
          ...products.map((product) {
            return TechnologyItem(
              itemName: product.nome,
              text1: product.valorTotal,
              text2: '${product.quantidade} pág',
              text3: product.valorUnitario,
              isSelected: product.isSelected,
              onCheckboxChanged: (value) {
                // TODO: Implementar lógica de seleção
              },
              onActionTap: () {
                _showProductInfoModal(context, product.nome);
              },
            );
          }),

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
                    content: Text('$bookTitle - Produtos salvos com sucesso!'),
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

  /// Exibe a modal principal de livros
  static Future<T?> show<T>({
    required BuildContext context,
  }) {
    return CustomModal.show<T>(
      context: context,
      title: 'Livros',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lista de livros usando BookItem com dados da API
          ..._mockBooksData.map((book) {
            // Calcula total baseado nos produtos do livro
            final bookProducts = _mockBookProductsData[book.nome] ?? [];
            final totalQuantity = bookProducts.fold<int>(
                0, (sum, product) => sum + product.quantidade);

            return BookItem(
              title: book.nome,
              value: book.valorTotal,
              quantity: '${book.quantidade}/$totalQuantity',
              isSelected: book.isSelected,
              onCheckboxChanged: (value) {
                // TODO: Implementar lógica de seleção
              },
              onTap: () {
                showBookProducts(context: context, bookTitle: book.nome);
              },
            );
          }),

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
}
