import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/services/censo_service.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

import '../../../../shared/widgets/city_badge_widget.dart';
import '../../../../shared/widgets/city_selection_modal.dart';
import '../../../../shared/widgets/custom_top_bar.dart';
import '../../domain/models/budget_create.dart';
import '../../external/services/budget_service.dart';

class MultiCitySchoolCensusPage extends StatefulWidget {
  const MultiCitySchoolCensusPage({super.key});

  @override
  State<MultiCitySchoolCensusPage> createState() =>
      _MultiCitySchoolCensusPageState();
}

class _MultiCitySchoolCensusPageState extends State<MultiCitySchoolCensusPage> {
  // Selected cities with complete data (id, nome, uf)
  List<Map<String, dynamic>> _selectedCities = [];
  Map<String, dynamic>? _censusData;
  bool _isLoadingCensus = false;

  final Map<String, TextEditingController> _controllers = {};
  final CensoService _censoService = CensoService();
  late dynamic _geo;
  late dynamic _auth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = StoreProvider.of(context);
    _geo = provider.geoStore;
    _auth = provider.authStore;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCensusData() async {
    if (_selectedCities.isEmpty) return;

    setState(() {
      _isLoadingCensus = true;
    });

    try {
      final cidadeIds = _selectedCities.map((c) => c['id'] as int).toList();

      print('📊 Carregando censo agregado para cidades: $cidadeIds');

      final data = await _censoService.buscarCensoAgregado(cidadeIds);

      setState(() {
        _censusData = data;
        _isLoadingCensus = false;
        _initializeControllers();
      });

      print('✅ Censo agregado carregado com sucesso');
    } catch (e) {
      print('❌ Erro ao carregar censo agregado: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }

      setState(() {
        _isLoadingCensus = false;
      });
    }
  }

  void _initializeControllers() {
    // Limpar controllers existentes
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    if (_censusData == null) return;

    // Criar controllers para cada item
    final grupos = _censusData!['grupos'] as List?;
    if (grupos == null) return;

    for (var grupo in grupos) {
      final itens = grupo['itens'] as List?;
      if (itens == null) continue;

      for (var item in itens) {
        final key = '${grupo['id']}_${item['id']}';
        final valorTotal = item['valor_total'] ?? 0;
        _controllers[key] = TextEditingController(text: valorTotal.toString());
      }
    }
  }

  void _showAddCitiesModal() async {
    // Carregar estados se necessário
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      await _geo.carregarEstados();
    }

    if (!mounted) return;

    final result = await CitySelectionModal.show(
      context: context,
      geo: _geo,
      initialSelectedCities: _selectedCities,
    );

    // Se retornou cidades, atualizar e carregar censo
    if (result != null && result.isNotEmpty) {
      print('🏙️ Cidades selecionadas na modal: $result');

      setState(() {
        _selectedCities = result;
      });

      // Mostrar loading antes de carregar censo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Carregando dados do censo...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await _loadCensusData();
    }
  }

  Widget _buildSelectedCitiesBadges() {
    if (_selectedCities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _selectedCities.map((cityData) {
          return CityBadgeWidget(
            city: cityData['nome'] ?? '',
            state: cityData['uf'] ?? '',
            onRemove: () {
              setState(() {
                _selectedCities.remove(cityData);
                _loadCensusData(); // Recarregar dados após remover cidade
              });
            },
            showIcon: false,
            // Custom colors matching modal
            backgroundColor: const Color(0xFF00364D),
            textColor: const Color(0xFFEBF9FF),
            iconBackgroundColor: const Color(0xFFEBF9FF),
            iconColor: const Color(0xFF00364D),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGroupSection(Map<String, dynamic> group) {
    final itens = group['itens'] as List? ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            group['nome'] ?? group['name'] ?? '',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF117BBD),
            ),
          ),
          SizedBox(height: 12.h),
          ...itens.map<Widget>((item) {
            final key = '${group['id']}_${item['id']}';
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['nome'] ?? item['name'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _controllers[key],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 6.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r),
                          borderSide:
                              const BorderSide(color: Color(0xFF117BBD)),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_selectedCities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos uma cidade')),
      );
      return;
    }

    try {
      final budgetService = Modular.get<BudgetService>();

      // Extrair IDs das cidades
      final cidadeIds = _selectedCities.map((c) => c['id'] as int).toList();

      // Extrair indicadores dos controllers
      final indicadores = <Map<String, dynamic>>[];

      if (_censusData != null) {
        final grupos = _censusData!['grupos'] as List;

        for (var grupo in grupos) {
          final itens = grupo['itens'] as List;

          for (var item in itens) {
            final key = '${grupo['id']}_${item['id']}';
            final controller = _controllers[key];

            if (controller != null && controller.text.isNotEmpty) {
              final valorDigitado = double.tryParse(controller.text) ?? 0.0;

              // Adicionar um indicador por cidade (distribuir proporcionalmente)
              final porCidade = item['por_cidade'] as List;
              for (var cidadeValor in porCidade) {
                indicadores.add({
                  'cidade_id': cidadeValor['cidade_id'],
                  'ine_indice_etapa_id': item['id'],
                  'valor': valorDigitado, // Usar valor agregado
                });
              }
            }
          }
        }
      }

      // Definir nome do orçamento
      final nomeOrcamento = _selectedCities.length == 1
          ? '${_selectedCities[0]['nome']} - ${_selectedCities[0]['uf']}'
          : 'Orçamento ${_selectedCities.length} cidades';

      print('📦 Criando orçamento multi-cidades: $nomeOrcamento');
      print('🏙️ Cidades: $cidadeIds');
      print('📊 Indicadores: ${indicadores.length}');

      // Pegar usuário autenticado
      final userId =
          _auth.user?.id != null ? int.tryParse(_auth.user!.id) ?? 1 : 1;

      print('👤 Usuário autenticado: ${_auth.user?.name} (ID: $userId)');

      // Criar DTO
      final dto = BudgetCreateDto(
        nome: nomeOrcamento,
        diasValidade: 60,
        cidades: cidadeIds,
        cidadePrincipalId: cidadeIds.isNotEmpty ? cidadeIds.first : null,
        total: 0.0,
        usuarioId: userId,
        products: [],
        indicadores: indicadores,
      );

      // Criar orçamento como rascunho
      final orcamento = await budgetService.criar(dto, status: 'rascunho');
      final budgetId = orcamento['id'] ?? orcamento['orc_orcamentoId'];

      print('✅ Orçamento multi-cidades criado: $budgetId');

      // Navegar para configuração
      await Modular.to.pushNamed('/budget/config/$budgetId');
    } catch (e) {
      print('❌ Erro ao criar orçamento multi-cidades: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar orçamento: $e')),
        );
      }
    }
  }

  Widget _buildNextButton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        height: 48.h,
        child: ElevatedButton(
          onPressed: _selectedCities.isEmpty ? null : _handleNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF117BBD),
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Próximo',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _selectedCities.isEmpty ? Colors.grey : Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward,
                color: _selectedCities.isEmpty ? Colors.grey : Colors.white,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Censo Escolar',
        showBackButton: true,
        actionButton: GestureDetector(
          onTap: _showAddCitiesModal,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFF117BBD),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF117BBD).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.add,
              size: 20.sp,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectedCitiesBadges(),
                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Preencha os dados do censo escolar para as cidades selecionadas',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF828282),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (_isLoadingCensus)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.h),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF117BBD),
                          ),
                        ),
                      )
                    else if (_censusData != null &&
                        _censusData!['grupos'] != null)
                      ...(_censusData!['grupos'] as List)
                          .map<Widget>((group) => _buildGroupSection(group))
                    else if (_selectedCities.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.h),
                          child: Text(
                            'Nenhum dado de censo encontrado',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.h),
                          child: Text(
                            'Adicione cidades para visualizar os dados do censo',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }
}
