import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/brazilian_phone_input_formatter.dart';
import 'package:multimidiaapp/app/shared/widgets/city_selection_modal.dart';
import 'package:multimidiaapp/app/shared/widgets/custom_modal.dart';
import 'package:multimidiaapp/app/shared/widgets/searchable_dropdown_widget.dart';

import '../../../../../../../stores/store_provider.dart';
import '../../../../../../shared/widgets/custom_top_bar.dart';
import '../../../../auth/presentation/stores/auth_store.dart';
import '../../domain/entities/partner_entity.dart';
import '../stores/budget_create_store.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  final _store = Modular.get<BudgetCreateStore>();
  final _authStore = Modular.get<AuthStore>();

  dynamic _geo;
  dynamic _censo;

  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _responsibleController.addListener(() {
      _store.setResponsibleName(_responsibleController.text);
    });

    _emailController.addListener(() {
      _store.setResponsibleEmail(_emailController.text);
    });

    _phoneController.addListener(() {
      _store.setResponsiblePhone(_phoneController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPage();
    });
  }

  Future<void> _refreshPage() async {
    _store.reset();

    if (_authStore.isAdmin) {
      await _store.loadPartners(excludePartnerId: _authStore.partnerId);
    }

    if (mounted && _geo != null) {
      await _geo.carregarEstados();
      if (mounted) setState(() {});
    }
  }

  Future<String?> _showMultiCityBudgetNameModal() async {
    final controller = TextEditingController();

    return CustomModal.show<String>(
      context: context,
      title: 'Nome do Orçamento',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ex: Projeto Educação 2024',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF117BBD),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Próximo',
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

  Future<List<Map<String, dynamic>>?> _showMultiCityCitySelectionModal() async {
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      await _geo.carregarEstados();
    }

    if (!mounted) return null;

    return CitySelectionModal.show(
      context: context,
      geo: _geo,
      initialSelectedCities: [],
    );
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

    if (_geo == null || _censo == null) {
      final provider = StoreProvider.of(context);
      _geo = provider.geoStore;
      _censo = provider.censoStore;
    }
  }

  String _partnerLabel(PartnerEntity partner) {
    final name = partner.displayName;
    final hasDuplicateName =
        _store.partners.where((item) => item.displayName == name).length > 1;
    final cnpj = partner.cnpj?.trim() ?? '';

    if (hasDuplicateName && cnpj.isNotEmpty) {
      return '$name - $cnpj';
    }

    return name;
  }

  PartnerEntity? _findPartnerByLabel(String label) {
    for (final partner in _store.partners) {
      if (_partnerLabel(partner) == label) {
        return partner;
      }
    }

    return null;
  }

  void _syncLocation() {
    if (_geo.estadoSelecionado != null && _geo.cidadeSelecionada != null) {
      final estadoCodigo = _geo.estadoSelecionado!.id?.toString() ?? '';

      _store.setSelectedState(
        estadoCodigo,
        _geo.estadoSelecionado!.nome,
        _geo.estadoSelecionado!.uf,
      );
      _store.setSelectedCity(
        _geo.cidadeSelecionada!.id.toString(),
        _geo.cidadeSelecionada!.nome,
      );
    }
  }

  Future<void> _createDraftBudget() async {
    _syncLocation();

    if (!_store.isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um estado e uma cidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      await _censo
          .carregarCensoPorCidade(_geo.cidadeSelecionada!.id)
          .catchError((_) async {
        await _censo.carregarGruposCenso();
      });

      final partnerId = _authStore.isAdmin && _store.selectedPartner != null
          ? _store.selectedPartner!.id
          : (_authStore.partnerId ?? 1);

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

      if (_store.createdDraft != null) {
        final budgetId = _store.createdDraft!.id;

        final locationData = {
          'cityName': _geo.cidadeSelecionada?.nome ?? '',
          'stateName': _geo.estadoSelecionado?.uf ?? '',
        };

        await Modular.to.pushNamed(
          '/budget/config/$budgetId',
          arguments: {
            'budget': _store.createdDraft,
            'location': locationData,
          },
        );

        if (mounted) {
          _store.clearForm();
          _responsibleController.clear();
          _emailController.clear();
          _phoneController.clear();

          if (_geo != null) {
            _geo.limparSelecao();
            if (mounted) setState(() {});
          }
        }
      }
    } catch (e) {
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              Observer(
                builder: (_) {
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
                      if (_store.isLoadingPartners)
                        SizedBox(
                          height: 35.h,
                          child: Center(
                            child: SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF117BBD),
                              ),
                            ),
                          ),
                        )
                      else
                        SearchableDropdownWidget(
                          label: 'Gerar orçamento para',
                          hint: !_store.hasPartners
                              ? 'Nenhum parceiro disponível'
                              : 'Selecione um parceiro',
                          searchHint: 'Pesquisar parceiro...',
                          items: _store.partners.map(_partnerLabel).toList(),
                          value: _store.selectedPartner != null
                              ? _partnerLabel(_store.selectedPartner!)
                              : null,
                          enabled: _store.hasPartners,
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            final partner = _findPartnerByLabel(value);
                            if (partner != null) {
                              _store.selectPartner(partner);
                            }
                          },
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
              Observer(
                builder: (_) {
                  final List<String> estadosNomes = _geo.estados
                      .map((dynamic e) => e.nome as String)
                      .cast<String>()
                      .toList();

                  return SearchableDropdownWidget(
                    label: 'Selecione o Estado',
                    hint: 'Estado',
                    searchHint: 'Pesquisar estado...',
                    items: estadosNomes,
                    value: _geo.estadoSelecionado?.nome,
                    onChanged: (value) async {
                      if (value == null) {
                        return;
                      }

                      final matches =
                          _geo.estados.where((e) => e.nome == value);
                      final estado = matches.isNotEmpty ? matches.first : null;

                      if (estado != null) {
                        await _geo.selecionarEstado(estado);

                        _store.setSelectedState(
                          estado.id?.toString() ?? '',
                          estado.nome,
                          estado.uf,
                        );

                        if (mounted) setState(() {});
                      }
                    },
                  );
                },
              ),
              if (_geo.estadoSelecionado != null) ...[
                SizedBox(height: 10.h),
                Observer(
                  builder: (_) {
                    final List<String> cidadesNomes = _geo.cidades
                        .map((dynamic c) => c.nome as String)
                        .cast<String>()
                        .toList();

                    return SearchableDropdownWidget(
                      label: 'Selecione a Cidade',
                      hint: 'Cidade',
                      searchHint: 'Pesquisar cidade...',
                      items: cidadesNomes,
                      value: _geo.cidadeSelecionada?.nome,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        final matches =
                            _geo.cidades.where((c) => c.nome == value);
                        final cidade =
                            matches.isNotEmpty ? matches.first : null;

                        if (cidade != null) {
                          _geo.selecionarCidade(cidade);

                          _store.setSelectedCity(
                            cidade.id.toString(),
                            cidade.nome,
                            cityId: cidade.id,
                          );

                          if (mounted) setState(() {});
                        }
                      },
                    );
                  },
                ),
              ],
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: Colors.grey[300],
              ),
              SizedBox(height: 20.h),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
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
                  inputFormatters: [BrazilianPhoneInputFormatter()],
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
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
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final budgetName = await _showMultiCityBudgetNameModal();
                    if (budgetName == null || budgetName.isEmpty) {
                      return;
                    }

                    if (!mounted) {
                      return;
                    }
                    final selectedCities =
                        await _showMultiCityCitySelectionModal();
                    if (selectedCities == null || selectedCities.isEmpty) {
                      return;
                    }

                    if (!mounted) {
                      return;
                    }
                    await Modular.to.pushNamed(
                      '/budget/multi-city/census',
                      arguments: {
                        'budgetName': budgetName,
                        'budgetId': null,
                        'selectedCities': selectedCities,
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 24.w,
                    ),
                    child: Text(
                      'Orçamento multi-cidades',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF117BBD),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF117BBD),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
