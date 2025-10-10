import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/stores/store_provider.dart';
import 'package:multimidiaapp/services/censo_service.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../../shared/widgets/city_badge_widget.dart';
import '../../external/services/budget_service.dart';
import '../../domain/models/budget_create.dart';

class MultiCitySchoolCensusPage extends StatefulWidget {
  const MultiCitySchoolCensusPage({super.key});

  @override
  State<MultiCitySchoolCensusPage> createState() => _MultiCitySchoolCensusPageState();
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
        _controllers[key] = TextEditingController(
          text: valorTotal.toString()
        );
      }
    }
  }

  void _showAddCitiesModal() async {
    // Carregar estados se necessário
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      await _geo.carregarEstados();
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => _CitySelectionDialog(
        geo: _geo,
        initialSelectedCities: _selectedCities,
        onCitiesSelected: (selectedCities) {
          setState(() {
            _selectedCities = selectedCities;
          });
          _loadCensusData();
        },
      ),
    );
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
            city: cityData['nome'] ?? cityData['city'] ?? '',
            state: cityData['uf'] ?? cityData['state'] ?? '',
            onRemove: () {
              setState(() {
                _selectedCities.remove(cityData);
                _loadCensusData(); // Recarregar dados após remover cidade
              });
            },
            showIcon: false,
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
                          borderSide: const BorderSide(color: Color(0xFF117BBD)),
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
          }).toList(),
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
      final userId = _auth.user?.id != null ? int.tryParse(_auth.user!.id) ?? 1 : 1;
      
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
                          child: CircularProgressIndicator(
                            color: const Color(0xFF117BBD),
                          ),
                        ),
                      )
                    else if (_censusData != null && _censusData!['grupos'] != null)
                      ...(_censusData!['grupos'] as List).map<Widget>((group) => _buildGroupSection(group))
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

/// Dialog para seleção de múltiplas cidades usando GeoStore
class _CitySelectionDialog extends StatefulWidget {
  final dynamic geo;
  final List<Map<String, dynamic>> initialSelectedCities;
  final Function(List<Map<String, dynamic>>) onCitiesSelected;

  const _CitySelectionDialog({
    required this.geo,
    required this.initialSelectedCities,
    required this.onCitiesSelected,
  });

  @override
  State<_CitySelectionDialog> createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends State<_CitySelectionDialog> {
  late List<Map<String, dynamic>> _tempSelectedCities;

  @override
  void initState() {
    super.initState();
    _tempSelectedCities = List.from(widget.initialSelectedCities);
  }

  void _addCity(dynamic cidade, String uf) {
    // Verificar se já está na lista
    final jaExiste = _tempSelectedCities.any((c) => c['id'] == cidade.id);
    
    if (!jaExiste) {
      setState(() {
        _tempSelectedCities.add({
          'id': cidade.id,
          'nome': cidade.nome,
          'uf': uf,
        });
      });
    }
  }

  void _removeCity(int cidadeId) {
    setState(() {
      _tempSelectedCities.removeWhere((c) => c['id'] == cidadeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 600.h,
          maxWidth: 500.w,
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adicionar cidades',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF117BBD),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // Cidades selecionadas
            if (_tempSelectedCities.isNotEmpty) ...[
              Text(
                'Cidades selecionadas:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _tempSelectedCities.map((cityData) {
                  return Chip(
                    label: Text('${cityData['nome']} - ${cityData['uf']}'),
                    onDeleted: () => _removeCity(cityData['id']),
                    deleteIcon: Icon(Icons.close, size: 16.sp),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
            ],
            
            Divider(),
            SizedBox(height: 16.h),
            
            // Seleção de estado
            Text(
              'Selecione o estado:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            
            DropdownButtonFormField<dynamic>(
              value: widget.geo.estadoSelecionado,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              hint: const Text('Selecione um estado'),
              items: widget.geo.estados.map<DropdownMenuItem>((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado.nome),
                );
              }).toList(),
              onChanged: (estado) async {
                await widget.geo.selecionarEstado(estado);
                setState(() {});
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Seleção de cidade
            if (widget.geo.estadoSelecionado != null) ...[
              Text(
                'Selecione a cidade:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              
              widget.geo.isLoadingCidades
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<dynamic>(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      hint: const Text('Selecione uma cidade'),
                      items: widget.geo.cidades.map<DropdownMenuItem>((cidade) {
                        return DropdownMenuItem(
                          value: cidade,
                          child: Text(cidade.nome),
                        );
                      }).toList(),
                      onChanged: (cidade) {
                        if (cidade != null) {
                          _addCity(cidade, widget.geo.estadoSelecionado.uf);
                        }
                      },
                    ),
            ],
            
            Spacer(),
            
            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCitiesSelected(_tempSelectedCities);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF117BBD),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
