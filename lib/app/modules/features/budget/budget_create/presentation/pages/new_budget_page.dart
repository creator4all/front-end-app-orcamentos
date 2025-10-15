import 'package:flutter/material.dart';
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

  // Stores legadas (temporário)
  late dynamic _geo;
  late dynamic _censo;

  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _validityDateController = TextEditingController();

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
  }

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

    // Inicializar stores legadas
    final provider = StoreProvider.of(context);
    _geo = provider.geoStore;
    _censo = provider.censoStore;

    // Carregar estados se necessário
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      _geo.carregarEstados().whenComplete(() {
        if (mounted) setState(() {});
      });
    }
  }

  /// Sincroniza localização do GeoStore com BudgetCreateStore
  void _syncLocation() {
    if (_geo.estadoSelecionado != null && _geo.cidadeSelecionada != null) {
      _store.setSelectedState(
        _geo.estadoSelecionado!.uf,
        _geo.estadoSelecionado!.nome,
      );
      _store.setSelectedCity(
        _geo.cidadeSelecionada!.id.toString(),
        _geo.cidadeSelecionada!.nome,
      );
    }
  }

  /// Cria o orçamento em rascunho
  Future<void> _createDraftBudget() async {
    // Sincronizar localização
    _syncLocation();

    // Validar campos obrigatórios
    if (!_store.isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um estado e uma cidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      print(
          '📦 [NewBudgetPage] Criando orçamento para parceiro ID: $partnerId');

      // Criar orçamento em rascunho via Store
      final success = await _store.createDraft(partnerId);

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
        print('✅ [NewBudgetPage] Navegando para config/$budgetId');

        await Modular.to.pushNamed('/budget/config/$budgetId');

        // Limpar formulário ao voltar
        if (mounted) {
          _store.clearForm();
          _responsibleController.clear();
          _emailController.clear();
          _validityDateController.clear();
        }
      }
    } catch (e) {
      print('❌ [NewBudgetPage] Erro ao criar orçamento: $e');
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

                    // CAMPO PARCEIRO (apenas para admins)
                    Observer(
                      builder: (_) {
                        // Carregar parceiros se for admin e ainda não carregou
                        if (_authStore.isAdmin &&
                            !_store.hasPartners &&
                            !_store.isLoadingPartners) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _store.loadPartners();
                          });
                        }

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
                                _geo.selecionarCidade(cidade);
                                if (mounted) setState(() {});
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

                    // DATA DE VALIDADE (desabilitado por enquanto)
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
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Em breve',
                          hintStyle: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey[200]!),
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
                      height: 35.h,
                      child: ElevatedButton(
                        onPressed:
                            _store.isCreatingDraft ? null : _createDraftBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF117BBD),
                          disabledBackgroundColor: Colors.grey[300],
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
          ],
        ),
      ),
    );
  }
}
