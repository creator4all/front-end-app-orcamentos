import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Importações temporárias para GeoStore e CensoStore (não migramos ainda)
import '../../../../../../../stores/store_provider.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../stores/budget_create_store.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  // Stores Clean Architecture
  final _store = Modular.get<BudgetCreateStore>();
  final _authStore = Modular.get<AuthStore>();

  // Stores legadas (temporário) - nullable para verificar inicialização
  dynamic _geo;
  dynamic _censo;

  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Adicionar listeners para sincronizar TextFields com Store
    _responsibleController.addListener(() {
      _store.setResponsibleName(_responsibleController.text.trim().isEmpty
          ? null
          : _responsibleController.text.trim());
    });

    _emailController.addListener(() {
      _store.setResponsibleEmail(_emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim());
    });

    _phoneController.addListener(() {
      _store.setResponsiblePhone(_phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim());
    });

    // Resetar e recarregar dados sempre que entrar na página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPage();
    });
  }

  /// Atualiza todos os dados da página
  Future<void> _refreshPage() async {
    print(' Atualizando página...');

    // Resetar store de orçamentos (limpa cache de parceiros)
    _store.reset();

    // Recarregar parceiros (apenas para admins)
    if (_authStore.isAdmin) {
      print(' Carregando parceiros (Admin)...');
      await _store.loadPartners();
    }

    // Recarregar estados se já tiver provider inicializado
    if (mounted && _geo != null) {
      print(' Recarregando estados...');
      await _geo.carregarEstados();
      if (mounted) setState(() {});
    }

    print(' Página atualizada');
  }

  @override
  void dispose() {
    _responsibleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Inicializar stores legadas (apenas na primeira vez)
    if (_geo == null || _censo == null) {
      final provider = StoreProvider.of(context);
      _geo = provider.geoStore;
      _censo = provider.censoStore;

      print(' Stores legadas inicializadas');
    }
  }

  /// Sincroniza localização do GeoStore com BudgetCreateStore
  void _syncLocation() {
    print(' Sincronizando localização...');

    if (_geo.estadoSelecionado != null && _geo.cidadeSelecionada != null) {
      // Usar ID do estado como código (já que UF não existe no modelo)
      final estadoCodigo = _geo.estadoSelecionado!.id?.toString() ?? '';

      print(
          '   Estado: ${_geo.estadoSelecionado!.nome} (ID: ${_geo.estadoSelecionado!.id})');
      print(
          '   Cidade: ${_geo.cidadeSelecionada!.nome} (ID: ${_geo.cidadeSelecionada!.id})');

      _store.setSelectedState(
        estadoCodigo,
        _geo.estadoSelecionado!.nome,
      );
      _store.setSelectedCity(
        _geo.cidadeSelecionada!.id.toString(),
        _geo.cidadeSelecionada!.nome,
      );

      print('   Store atualizada:');
      print('      - selectedStateCode: ${_store.selectedStateCode}');
      print('      - selectedStateName: ${_store.selectedStateName}');
      print('      - selectedCityCode: ${_store.selectedCityCode}');
      print('      - selectedCityName: ${_store.selectedCityName}');
      print('      - isFormValid: ${_store.isFormValid}');
    } else {
      print('   Estado ou cidade não selecionados');
      print('      - estadoSelecionado: ${_geo.estadoSelecionado}');
      print('      - cidadeSelecionada: ${_geo.cidadeSelecionada}');
    }
  }

  /// Cria o orçamento em rascunho
  Future<void> _createDraftBudget() async {
    print(' Iniciando criação de orçamento...');

    // Sincronizar localização
    _syncLocation();

    // Validar campos obrigatórios
    if (!_store.isFormValid) {
      print(' Validação falhou - isFormValid: ${_store.isFormValid}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um estado e uma cidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print(' Validação passou');

    // Validar email se preenchido
    if (!_store.isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Carregar censo
      await _censo
          .carregarCensoPorCidade(_geo.cidadeSelecionada!.id)
          .catchError((_) async {
        await _censo.carregarGruposCenso();
      });

      // Determinar partnerId
      final partnerId = _authStore.isAdmin && _store.selectedPartner != null
          ? _store.selectedPartner!.id
          : (_authStore.partnerId ?? 1);

      // Obter userId do usuário autenticado
      final userId = _authStore.currentUser?.id ?? 0;

      if (userId <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print(
          ' Criando orçamento para parceiro ID: $partnerId, usuário ID: $userId');

      // Criar orçamento em rascunho via Store
      final success = await _store.createDraft(partnerId, userId);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_store.error ?? 'Erro ao criar orçamento'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Sucesso - navegar para config
      if (_store.createdDraft != null) {
        final budgetId = _store.createdDraft!.id;
        print(' Navegando para config/$budgetId');

        // Preparar dados de localização para o header
        final locationData = {
          'cityName': _geo.cidadeSelecionada?.nome ?? '',
          'stateName': _geo.estadoSelecionado?.nome ?? '',
        };

        await Modular.to.pushNamed(
          '/budget/config/$budgetId',
          arguments: {
            'budget': _store.createdDraft,
            'location': locationData,
          },
        );

        // Limpar formulário e estado ao voltar
        if (mounted) {
          _store.clearForm();
          _responsibleController.clear();
          _emailController.clear();
          _phoneController.clear();

          // Resetar estado e cidade no GeoStore
          if (_geo != null) {
            _geo.limparSelecao();
            if (mounted) setState(() {});
          }
        }
      }
    } catch (e) {
      print(' Erro ao criar orçamento: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar orçamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(
        title: 'Novo orçamento',
        showBackButton: true,
        authStore: _authStore,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Column(
          children: [
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),

                    // CAMPO PARCEIRO (apenas para admins)
                    Observer(
                      builder: (_) {
                        // ✅ REMOVIDO: Lógica de carregamento movida para initState
                        // Evita loop infinito quando API retorna lista vazia

                        // Não mostrar campo se não for admin
                        if (!_authStore.isAdmin) {
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
                                child: _store.isLoadingPartners
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
                                        value: _store.selectedPartner?.id,
                                        hint: Text(
                                          !_store.hasPartners
                                              ? 'Nenhum parceiro disponível'
                                              : 'Selecione um parceiro',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        items: _store.partners
                                            .map((partner) =>
                                                DropdownMenuItem<int>(
                                                  value: partner.id,
                                                  child: Text(
                                                    partner.displayName,
                                                    style: TextStyle(
                                                        fontSize: 16.sp),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: !_store.hasPartners
                                            ? null
                                            : (value) {
                                                final partner = _store.partners
                                                    .firstWhere(
                                                        (p) => p.id == value);
                                                _store.selectPartner(partner);
                                              },
                                      ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: double.infinity,
                              height: 1.h,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 10.h),
                          ],
                        );
                      },
                    ),

                    // ESTADO
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

                                // ✅ Sincronizar com BudgetCreateStore imediatamente
                                // Usar ID como código já que UF não existe no modelo
                                _store.setSelectedState(
                                  estado.id?.toString() ?? '',
                                  estado.nome,
                                );

                                print(
                                    '📍 Estado sincronizado: ${estado.nome} (ID: ${estado.id})');

                                if (mounted) setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // CIDADE
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

                                if (cidade != null) {
                                  _geo.selecionarCidade(cidade);

                                  // ✅ Sincronizar com BudgetCreateStore imediatamente
                                  _store.setSelectedCity(
                                    cidade.id.toString(),
                                    cidade.nome,
                                    cityId: cidade.id,
                                  );

                                  if (mounted) setState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),

                    // Linha horizontal
                    Container(
                      width: double.infinity,
                      height: 1.h,
                      color: Colors.grey[300],
                    ),

                    SizedBox(height: 20.h),

                    // RESPONSÁVEL
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
                          hintText: 'Informe o nome',
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

                    // EMAIL
                    Text(
                      'Email (opcional):',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Observer(
                      builder: (_) => SizedBox(
                        height: 35.h,
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Informe o email',
                            hintStyle: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                            ),
                            errorText: _emailController.text.isNotEmpty &&
                                    !_store.isEmailValid
                                ? 'Email inválido'
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // TELEFONE
                    Text(
                      'Telefone (opcional):',
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
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          // Máscara para telefone brasileiro: (XX) XXXXX-XXXX
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            String text =
                                newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

                            if (text.length > 11) {
                              text = text.substring(0, 11);
                            }

                            String formatted = '';
                            if (text.isNotEmpty) {
                              formatted = '($text';
                              if (text.length >= 2) {
                                formatted = '(${text.substring(0, 2)}';
                                if (text.length > 2) {
                                  formatted += ') ';
                                  if (text.length <= 7) {
                                    formatted += text.substring(2);
                                  } else {
                                    formatted += '${text.substring(2, 7)}-';
                                    if (text.length > 7) {
                                      formatted += text.substring(7);
                                    }
                                  }
                                }
                              }
                            }

                            return TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }),
                        ],
                        decoration: InputDecoration(
                          hintText: '(00) 00000-0000',
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
                  Observer(
                    builder: (_) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _store.isCreatingDraft ? null : _createDraftBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF117BBD),
                          disabledBackgroundColor: Colors.grey[300],
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _store.isCreatingDraft
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
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
                  ),

                  SizedBox(height: 10.h),

                  // Link Orçamento multi-cidades (desabilitado por enquanto)
                  Center(
                    child: Text(
                      'Orçamento multi-cidades (em breve)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ], // Fim do Column do RefreshIndicator
        ), // Fim do RefreshIndicator
      ),
    );
  }
}
