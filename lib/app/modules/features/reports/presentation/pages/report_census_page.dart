import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/widgets/custom_top_bar.dart';
import '../../../budget/budget_config/data/models/budget_census_dto.dart';

/// Página de visualização do Censo Escolar em modo somente leitura.
///
/// Exibe os dados do censo sem permitir edição. Esta página é uma versão
/// simplificada da SchoolCensusPage, removendo todas as funcionalidades
/// de edição.
class ReportCensusPage extends StatefulWidget {
  final int budgetId;
  final BudgetCensusDto? censoData;

  const ReportCensusPage({
    super.key,
    required this.budgetId,
    this.censoData,
  });

  @override
  State<ReportCensusPage> createState() => _ReportCensusPageState();
}

class _ReportCensusPageState extends State<ReportCensusPage> {
  @override
  Widget build(BuildContext context) {
    final censo = widget.censoData;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            CustomTopBar(
              title: 'Censo Escolar',
              showBackButton: true,
              onBackPressed: () => Modular.to.pop(),
            ),

            // Conteúdo
            Expanded(
              child: censo == null
                  ? _buildEmptyState()
                  : _buildCensusContent(censo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 48.w,
            color: const Color(0xFF828282),
          ),
          SizedBox(height: 16.h),
          Text(
            'Dados do censo não disponíveis',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF828282),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCensusContent(BudgetCensusDto censo) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de multi-cidade
          if (censo.multiCidade)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F0FF),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 20.w,
                    color: const Color(0xFF0C498E),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Orçamento multi-cidade (${censo.cidades.length} cidades)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF0C498E),
                    ),
                  ),
                ],
              ),
            ),

          // Censo agregado para multi-cidade
          if (censo.multiCidade && censo.censoAgregado.isNotEmpty)
            _buildCensoAgregadoCard(censo.censoAgregado),

          // Cidades
          ...censo.cidades.map((cidade) => _buildCidadeCard(cidade)),
        ],
      ),
    );
  }

  Widget _buildCensoAgregadoCard(Map<String, double> censoAgregado) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize,
                size: 20.w,
                color: const Color(0xFF0E3562),
              ),
              SizedBox(width: 8.w),
              Text(
                'Censo Agregado',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0E3562),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...censoAgregado.entries.map((entry) => _buildCensusRow(
                _formatEtapaName(entry.key),
                entry.value,
              )),
        ],
      ),
    );
  }

  Widget _buildCidadeCard(CidadeCensoDto cidade) {
    // Agrupar índices por grupo
    final gruposMap = <int, List<IndiceCensoDto>>{};
    final grupoNomes = <int, String>{};

    for (final indice in cidade.indices) {
      final grupoId = indice.grupo?.id ?? 0;
      grupoNomes[grupoId] = indice.grupo?.nome ?? 'Outros';
      gruposMap.putIfAbsent(grupoId, () => []);
      gruposMap[grupoId]!.add(indice);
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da cidade
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20.w,
                color: const Color(0xFF0E3562),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  cidade.nome,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0E3562),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Grupos de índices
          ...gruposMap.entries.map((entry) {
            final grupoId = entry.key;
            final indices = entry.value;
            final grupoNome = grupoNomes[grupoId] ?? 'Grupo';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do grupo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    grupoNome,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF484848),
                    ),
                  ),
                ),
                // Índices do grupo
                ...indices.map((indice) => _buildCensusRow(
                      indice.titulo.isNotEmpty
                          ? indice.titulo
                          : _formatEtapaName(indice.nomeEtapa),
                      indice.valor,
                    )),
                SizedBox(height: 12.h),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCensusRow(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF484848),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F0FF),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              _formatNumber(value),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0C498E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    // Se for número inteiro, não mostrar decimais
    if (value == value.roundToDouble()) {
      return NumberFormat('#,##0', 'pt_BR').format(value.toInt());
    }
    return NumberFormat('#,##0.00', 'pt_BR').format(value);
  }

  String _formatEtapaName(String nomeEtapa) {
    // Converter códigos de etapa para nomes legíveis
    final mappings = {
      'EI_creche': 'Creche',
      'EI_pre': 'Pré-escola',
      'EF_anos': 'Anos Iniciais',
      'EF_finais': 'Anos Finais',
      'EM_medio': 'Ensino Médio',
      'EJA': 'EJA',
      'creche_P': 'Creche (Professores)',
      'pre_P': 'Pré-escola (Professores)',
      'anos_P': 'Anos Iniciais (Professores)',
      'finais_P': 'Anos Finais (Professores)',
      'medio_P': 'Ensino Médio (Professores)',
      'eja_P': 'EJA (Professores)',
    };

    return mappings[nomeEtapa] ?? nomeEtapa;
  }
}
