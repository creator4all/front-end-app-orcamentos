import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/modules/features/partner/data/services/partner_service.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import '../../../features/partner/domain/models/partner_profile.dart';
import '../../domain/models/budget_create.dart';
import '../../external/services/budget_service.dart';
import 'multi_city_school_census.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  int? _selectedPartnerId;
  List<PartnerProfile> _partners = [];
  bool _isLoadingPartners = false;
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late dynamic _geo;
  late dynamic _censo;
  late dynamic _auth;

  final TextEditingController _validityDateController = TextEditingController();

  @override
  void dispose() {
    _responsibleController.dispose();
    _emailController.dispose();
    _validityDateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = StoreProvider.of(context);
    _geo = provider.geoStore;
    _censo = provider.censoStore;
    _auth = provider.authStore;
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      _geo.carregarEstados().whenComplete(() {
        if (mounted) setState(() {});
      });
    }

    // Não carregar aqui, pois o usuário ainda não está disponível
    // Vamos usar Observer no build para reagir quando o usuário for carregado
  }

  Future<void> _carregarParceiros() async {
    // Verifica se o usuário é admin antes de tentar carregar
    if (_auth?.isAdmin != true) {
      print(
          'ℹ️ Usuário não é administrador, pulando carregamento de parceiros');
      return;
    }

    if (_isLoadingPartners || _partners.isNotEmpty) return;

    setState(() {
      _isLoadingPartners = true;
    });

    try {
      final partnerService = Modular.get<PartnerService>();
      final parceiros = await partnerService.listarTodos();

      if (mounted) {
        setState(() {
          _partners = parceiros;
          _isLoadingPartners = false;
        });
      }

      print('✅ ${parceiros.length} parceiros carregados');
    } catch (e) {
      print('⚠️ Erro ao carregar parceiros: $e');
      if (mounted) {
        setState(() {
          _isLoadingPartners = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Novo orçamento',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),

                    // Observer para reagir ao carregamento do usuário
                    Observer(
                      builder: (_) {
                        // Quando o usuário for carregado e for admin, carrega os parceiros
                        if (_auth?.isAdmin == true &&
                            _partners.isEmpty &&
                            !_isLoadingPartners) {
                          // Agendar o carregamento para o próximo frame
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _carregarParceiros();
                          });
                        }

                        // Mostrar campo apenas se for admin
                        if (_auth?.isAdmin != true) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gerar orçamento para (opcional):',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              height: 35.h,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: _isLoadingPartners
                                    ? Center(
                                        child: SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF117BBD),
                                          ),
                                        ),
                                      )
                                    : DropdownButton<int>(
                                        value: _selectedPartnerId,
                                        hint: Text(
                                          _partners.isEmpty
                                              ? 'Nenhum parceiro disponível'
                                              : 'Selecione um parceiro',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        items: _partners
                                            .map((partner) =>
                                                DropdownMenuItem<int>(
                                                  value: partner.id,
                                                  child: Text(
                                                    partner.tradeName,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: _partners.isEmpty
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  _selectedPartnerId = value;
                                                });
                                                print(
                                                    '🎯 Parceiro selecionado: $value');
                                              },
                                      ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            // Linha horizontal
                            Container(
                              width: double.infinity,
                              height: 1.h,
                              color: Colors.grey[300],
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 10.h),

                    SizedBox(height: 10.h),

                    // Estado
                    Container(
                      width: double.infinity,
                      height: 35.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: Observer(
                          builder: (_) => DropdownButton<String>(
                            value: _geo.estadoSelecionado?.nome,
                            hint: Text(
                              'Estado',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            items: _geo.estados
                                .map<DropdownMenuItem<String>>(
                                    (e) => DropdownMenuItem<String>(
                                          value: e.nome,
                                          child: Text(e.nome),
                                        ))
                                .toList(),
                            onChanged: (value) async {
                              final matches =
                                  _geo.estados.where((e) => e.nome == value);
                              final estado =
                                  matches.isNotEmpty ? matches.first : null;
                              if (estado != null) {
                                await _geo.selecionarEstado(estado);
                                if (mounted) setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Cidade (só aparece quando estado selecionado)
                    if (_geo.estadoSelecionado != null) ...[
                      Observer(
                        builder: (_) => Container(
                          width: double.infinity,
                          height: 35.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _geo.cidadeSelecionada?.nome,
                              hint: Text(
                                'Cidade',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                              items: _geo.cidades
                                  .map<DropdownMenuItem<String>>(
                                      (c) => DropdownMenuItem<String>(
                                            value: c.nome,
                                            child: Text(c.nome),
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                final matches =
                                    _geo.cidades.where((c) => c.nome == value);
                                final cidade =
                                    matches.isNotEmpty ? matches.first : null;
                                _geo.selecionarCidade(cidade);
                                if (mounted) setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 10.h),

                    // Linha horizontal
                    Container(
                      width: double.infinity,
                      height: 1.h,
                      color: Colors.grey[300],
                    ),

                    SizedBox(height: 10.h),

                    // Responsável cliente (opcional)
                    Text(
                      'Responsável cliente (opcional):',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 35.h,
                      child: TextFormField(
                        controller: _responsibleController,
                        decoration: InputDecoration(
                          hintText: 'Informe seu nome',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Email (opcional)
                    Text(
                      'Email (opcional):',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 35.h,
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Informe seu email',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Data de validade (opcional)
                    Text(
                      'Data de validade (opcional):',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 35.h,
                      child: TextFormField(
                        controller: _validityDateController,
                        decoration: InputDecoration(
                          hintText: 'Informe o telefone',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botões fixos no final
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Botão Próximo
                  SizedBox(
                    width: double.infinity,
                    height: 35.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_geo.estadoSelecionado == null ||
                            _geo.cidadeSelecionada == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Selecione um estado e uma cidade')),
                          );
                          return;
                        }

                        // Carregar censo
                        await _censo
                            .carregarCensoPorCidade(_geo.cidadeSelecionada!.id)
                            .catchError((_) async {
                          await _censo.carregarGruposCenso();
                        });

                        // Criar orçamento como rascunho
                        try {
                          final budgetService = Modular.get<BudgetService>();

                          // Pegar usuário autenticado
                          final userId = _auth.user?.id != null
                              ? int.tryParse(_auth.user!.id) ?? 1
                              : 1;

                          print(
                              '📦 Criando orçamento sem produtos (backend marcará todos como selecionados)');
                          print(
                              '👤 Usuário autenticado: ${_auth.user?.name} (ID: $userId)');

                          // Criar DTO sem produtos - backend marcará TODOS como selecionados
                          final dto = BudgetCreateDto(
                            nome: _geo.cidadeSelecionada!.nome,
                            diasValidade: 60,
                            cidades: [_geo.cidadeSelecionada!.id],
                            cidadePrincipalId: _geo.cidadeSelecionada!.id,
                            total: 0.0, // Será calculado depois
                            usuarioId: userId,
                            products: [], // Backend marcará todos como selecionados
                            partnerDestinoId:
                                _selectedPartnerId, // Parceiro destino (se admin)
                          );

                          // Criar com status rascunho
                          final orcamento = await budgetService.criar(dto,
                              status: 'rascunho');

                          print('📦 Resposta completa: $orcamento');
                          print(
                              '📦 Keys disponíveis: ${orcamento.keys.toList()}');

                          // Extrair ID do orçamento (pode vir como 'id' ou 'orc_orcamentoId')
                          final budgetId =
                              orcamento['id'] ?? orcamento['orc_orcamentoId'];

                          print('✅ Orçamento rascunho criado: $budgetId');
                          print('✅ Tipo do budgetId: ${budgetId.runtimeType}');

                          if (budgetId == null) {
                            throw Exception(
                                'ID do orçamento não encontrado na resposta');
                          }

                          print('🚀 Navegando para: /budget/config/$budgetId');

                          // Navegar para config passando o budgetId
                          await Modular.to
                              .pushNamed('/budget/config/$budgetId');

                          print('✅ Navegação concluída');
                        } catch (e) {
                          print('❌ Erro ao criar orçamento rascunho: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erro ao criar orçamento: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
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
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            color: const Color(0xFFFFFFFF),
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Link Orçamento multi-cidades
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const MultiCitySchoolCensusPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Orçamento multi-cidades',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF117BBD),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF117BBD),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
