import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/api_models.dart';
import 'custom_modal.dart';
import 'product_info_modal.dart';
import 'technology_item.dart';

/// Modal reutilizável para produtos de tecnologia
class TechnologyProductsModal {
  /// Mock de dados simulando retorno da API
  static final Map<String, ApiProductCategory> _mockApiData = {
    'Portal/Aplicativos': ApiProductCategory(
      categoria: 'Portal/Aplicativos',
      produtos: [
        ApiProduct(
          nome: 'Portal Educacional',
          valorTotal: 'R\$ 5.000,00',
          quantidade: 1,
          valorUnitario: 'R\$ 5.000,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'App Mobile Alunos',
          valorTotal: 'R\$ 8.000,00',
          quantidade: 1,
          valorUnitario: 'R\$ 8.000,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'App Mobile Professores',
          valorTotal: 'R\$ 7.500,00',
          quantidade: 1,
          valorUnitario: 'R\$ 7.500,00',
          isSelected: false,
        ),
      ],
    ),
    'Gamificação': ApiProductCategory(
      categoria: 'Gamificação',
      produtos: [
        ApiProduct(
          nome: 'Sistema de Pontos',
          valorTotal: 'R\$ 2.500,00',
          quantidade: 1,
          valorUnitario: 'R\$ 2.500,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Ranking de Alunos',
          valorTotal: 'R\$ 1.800,00',
          quantidade: 1,
          valorUnitario: 'R\$ 1.800,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Badges e Conquistas',
          valorTotal: 'R\$ 3.200,00',
          quantidade: 1,
          valorUnitario: 'R\$ 3.200,00',
          isSelected: true,
        ),
      ],
    ),
    'Avaliação Diagnóstica': ApiProductCategory(
      categoria: 'Avaliação Diagnóstica',
      produtos: [
        ApiProduct(
          nome: 'Testes Adaptativos',
          valorTotal: 'R\$ 4.500,00',
          quantidade: 1,
          valorUnitario: 'R\$ 4.500,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Relatórios Analíticos',
          valorTotal: 'R\$ 3.800,00',
          quantidade: 1,
          valorUnitario: 'R\$ 3.800,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Dashboard de Desempenho',
          valorTotal: 'R\$ 5.200,00',
          quantidade: 1,
          valorUnitario: 'R\$ 5.200,00',
          isSelected: false,
        ),
      ],
    ),
    'Serviços': ApiProductCategory(
      categoria: 'Serviços',
      produtos: [
        ApiProduct(
          nome: 'Treinamento de Professores',
          valorTotal: 'R\$ 8.000,00',
          quantidade: 1,
          valorUnitario: 'R\$ 8.000,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Suporte Técnico',
          valorTotal: 'R\$ 12.000,00',
          quantidade: 12,
          valorUnitario: 'R\$ 1.000,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Consultoria Pedagógica',
          valorTotal: 'R\$ 15.000,00',
          quantidade: 6,
          valorUnitario: 'R\$ 2.500,00',
          isSelected: true,
        ),
        ApiProduct(
          nome: 'Implantação do Sistema',
          valorTotal: 'R\$ 5.500,00',
          quantidade: 1,
          valorUnitario: 'R\$ 5.500,00',
          isSelected: false,
        ),
      ],
    ),
  };

  /// Mock de dados de informações detalhadas dos produtos simulando retorno da API
  static final Map<String, ApiProductInfo> _mockProductInfoData = {
    'Portal Educacional': ApiProductInfo(
      grupo: 'Tecnologia Educacional',
      subGrupo: 'Portal Web',
      solucao: 'Plataforma Digital',
      indicacao: 'Escolas e universidades',
      tipo: 'Sistema web',
      valorTotal: 'R\$ 5.000,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Funcionalidades',
          indices: [
            IndiceEscolar(nome: 'Login seguro', checked: true),
            IndiceEscolar(nome: 'Dashboard interativo', checked: false),
            IndiceEscolar(nome: 'Relatórios personalizados', checked: true),
          ],
        ),
      ],
    ),
    'App Mobile Alunos': ApiProductInfo(
      grupo: 'Tecnologia Educacional',
      subGrupo: 'Aplicativo Mobile',
      solucao: 'App para Estudantes',
      indicacao: 'Alunos do ensino básico',
      tipo: 'Aplicativo móvel',
      valorTotal: 'R\$ 8.000,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Plataformas',
          indices: [
            IndiceEscolar(nome: 'Android', checked: true),
            IndiceEscolar(nome: 'iOS', checked: true),
          ],
        ),
      ],
    ),
    'App Mobile Professores': ApiProductInfo(
      grupo: 'Tecnologia Educacional',
      subGrupo: 'Aplicativo Mobile',
      solucao: 'App para Educadores',
      indicacao: 'Professores e coordenadores',
      tipo: 'Aplicativo móvel',
      valorTotal: 'R\$ 7.500,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Recursos',
          indices: [
            IndiceEscolar(nome: 'Gestão de turmas', checked: true),
            IndiceEscolar(nome: 'Lançamento de notas', checked: false),
            IndiceEscolar(nome: 'Comunicação com pais', checked: true),
          ],
        ),
      ],
    ),
    'Sistema de Pontos': ApiProductInfo(
      grupo: 'Gamificação',
      subGrupo: 'Sistema de Recompensas',
      solucao: 'Pontuação por Atividades',
      indicacao: 'Estudantes de todas as idades',
      tipo: 'Módulo digital',
      valorTotal: 'R\$ 2.500,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Tipos de Pontos',
          indices: [
            IndiceEscolar(nome: 'Pontos por exercício', checked: true),
            IndiceEscolar(nome: 'Pontos por presença', checked: true),
            IndiceEscolar(nome: 'Pontos por participação', checked: false),
          ],
        ),
      ],
    ),
    'Ranking de Alunos': ApiProductInfo(
      grupo: 'Gamificação',
      subGrupo: 'Sistema de Classificação',
      solucao: 'Ranking Competitivo',
      indicacao: 'Turmas do ensino médio',
      tipo: 'Módulo digital',
      valorTotal: 'R\$ 1.800,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Modalidades',
          indices: [
            IndiceEscolar(nome: 'Ranking por turma', checked: true),
            IndiceEscolar(nome: 'Ranking geral', checked: false),
            IndiceEscolar(nome: 'Ranking por matéria', checked: true),
          ],
        ),
      ],
    ),
    'Badges e Conquistas': ApiProductInfo(
      grupo: 'Gamificação',
      subGrupo: 'Sistema de Conquistas',
      solucao: 'Medalhas e Certificados',
      indicacao: 'Todos os níveis de ensino',
      tipo: 'Módulo digital',
      valorTotal: 'R\$ 3.200,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Tipos de Badge',
          indices: [
            IndiceEscolar(nome: 'Badge de conclusão', checked: true),
            IndiceEscolar(nome: 'Badge de excelência', checked: true),
            IndiceEscolar(nome: 'Badge de participação', checked: false),
          ],
        ),
      ],
    ),
    'Testes Adaptativos': ApiProductInfo(
      grupo: 'Avaliação Diagnóstica',
      subGrupo: 'Sistema de Avaliação',
      solucao: 'Testes Inteligentes',
      indicacao: 'Avaliação de aprendizagem',
      tipo: 'Sistema digital',
      valorTotal: 'R\$ 4.500,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Funcionalidades',
          indices: [
            IndiceEscolar(nome: 'Questões adaptativas', checked: true),
            IndiceEscolar(nome: 'Análise de desempenho', checked: true),
            IndiceEscolar(nome: 'Feedback instantâneo', checked: false),
          ],
        ),
      ],
    ),
    'Relatórios Analíticos': ApiProductInfo(
      grupo: 'Avaliação Diagnóstica',
      subGrupo: 'Análise de Dados',
      solucao: 'Business Intelligence Educacional',
      indicacao: 'Gestores e coordenadores',
      tipo: 'Módulo de relatórios',
      valorTotal: 'R\$ 3.800,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Tipos de Relatório',
          indices: [
            IndiceEscolar(nome: 'Desempenho por aluno', checked: true),
            IndiceEscolar(nome: 'Análise por turma', checked: false),
            IndiceEscolar(nome: 'Comparativo temporal', checked: true),
          ],
        ),
      ],
    ),
    'Dashboard de Desempenho': ApiProductInfo(
      grupo: 'Avaliação Diagnóstica',
      subGrupo: 'Interface de Monitoramento',
      solucao: 'Painel de Controle Educacional',
      indicacao: 'Diretores e supervisores',
      tipo: 'Interface web',
      valorTotal: 'R\$ 5.200,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Visualizações',
          indices: [
            IndiceEscolar(nome: 'Gráficos interativos', checked: true),
            IndiceEscolar(nome: 'Métricas em tempo real', checked: true),
            IndiceEscolar(nome: 'Alertas automáticos', checked: false),
          ],
        ),
      ],
    ),
    'Treinamento de Professores': ApiProductInfo(
      grupo: 'Serviços Educacionais',
      subGrupo: 'Capacitação Profissional',
      solucao: 'Formação Continuada',
      indicacao: 'Corpo docente',
      tipo: 'Serviço presencial',
      valorTotal: 'R\$ 8.000,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Modalidades',
          indices: [
            IndiceEscolar(nome: 'Treinamento presencial', checked: true),
            IndiceEscolar(nome: 'Workshop prático', checked: true),
            IndiceEscolar(nome: 'Certificação inclusa', checked: false),
          ],
        ),
      ],
    ),
    'Suporte Técnico': ApiProductInfo(
      grupo: 'Serviços Educacionais',
      subGrupo: 'Assistência Técnica',
      solucao: 'Suporte Especializado',
      indicacao: 'Instituições de ensino',
      tipo: 'Serviço online',
      valorTotal: 'R\$ 12.000,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Canais de Atendimento',
          indices: [
            IndiceEscolar(nome: 'Chat online', checked: true),
            IndiceEscolar(nome: 'Telefone dedicado', checked: false),
            IndiceEscolar(nome: 'Email prioritário', checked: true),
          ],
        ),
      ],
    ),
    'Consultoria Pedagógica': ApiProductInfo(
      grupo: 'Serviços Educacionais',
      subGrupo: 'Consultoria Especializada',
      solucao: 'Assessoria Educacional',
      indicacao: 'Equipe pedagógica',
      tipo: 'Serviço híbrido',
      valorTotal: 'R\$ 15.000,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Áreas de Atuação',
          indices: [
            IndiceEscolar(nome: 'Metodologias ativas', checked: true),
            IndiceEscolar(nome: 'Avaliação educacional', checked: true),
            IndiceEscolar(nome: 'Tecnologia educacional', checked: false),
          ],
        ),
      ],
    ),
    'Implantação do Sistema': ApiProductInfo(
      grupo: 'Serviços Educacionais',
      subGrupo: 'Implementação Técnica',
      solucao: 'Setup Completo',
      indicacao: 'Novas implementações',
      tipo: 'Serviço presencial',
      valorTotal: 'R\$ 5.500,00',
      gruposIndices: [
        GrupoIndiceEscolar(
          grupo: 'Etapas',
          indices: [
            IndiceEscolar(nome: 'Configuração inicial', checked: true),
            IndiceEscolar(nome: 'Migração de dados', checked: false),
            IndiceEscolar(nome: 'Testes de funcionamento', checked: true),
          ],
        ),
      ],
    ),
  };

  /// Converte dados da API para formato do ProductInfoModal
  static Map<String, dynamic> _getProductInfoData(String productName) {
    final apiProductInfo = _mockProductInfoData[productName];

    if (apiProductInfo == null) {
      // Retorna dados padrão se produto não encontrado
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

    // Converte dados da API para formato do ProductInfoModal
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

  /// Exibe a modal de produtos de tecnologia para uma categoria específica
  static Future<T?> show<T>({
    required BuildContext context,
    required String category,
  }) {
    final categoryData = _mockApiData[category];
    if (categoryData == null) return Future.value(null);

    return CustomModal.show<T>(
      context: context,
      title: category,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lista de produtos usando dados da API
          ...categoryData.produtos.map((product) {
            return TechnologyItem(
              itemName: product.nome,
              text1: product.valorTotal,
              text2: '${product.quantidade}',
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
                    content: Text('$category salvos com sucesso!'),
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
}
