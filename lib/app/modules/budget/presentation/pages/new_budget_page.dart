import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:multimidiaapp/stores/store_provider.dart';

import '../../../../shared/widgets/custom_top_bar.dart';
import 'multi_city_school_census.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  String? _selectedPartner;
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late dynamic _geo;
  late dynamic _censo;

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
    if (_geo.estados.isEmpty && !_geo.isLoadingEstados) {
      _geo.carregarEstados().whenComplete(() {
        if (mounted) setState(() {});
      });
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

                    // Gerar orçamento para (opcional)
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
                        child: DropdownButton<String>(
                          value: _selectedPartner,
                          hint: Text(
                            'Parceiro',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Parceiro 1', child: Text('Parceiro 1')),
                            DropdownMenuItem(
                                value: 'Parceiro 2', child: Text('Parceiro 2')),
                            DropdownMenuItem(
                                value: 'Parceiro 3', child: Text('Parceiro 3')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPartner = value;
                            });
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
                        child: DropdownButton<String>(
                          value: _geo.estadoSelecionado?.nome,
                          hint: Text(
                            'Estado',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          items: _geo.estados
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.nome,
                                    child: Text(e.nome),
                                  ))
                              .toList(),
                          onChanged: (value) async {
                            final matches = _geo.estados.where((e) => e.nome == value);
                            final estado = matches.isNotEmpty ? matches.first : null;
                            if (estado != null) {
                              await _geo.selecionarEstado(estado);
                              if (mounted) setState(() {});
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Cidade (só aparece quando estado selecionado)
                    if (_geo.estadoSelecionado != null) ...[
                      Container(
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
                                .map((c) => DropdownMenuItem<String>(
                                      value: c.nome,
                                      child: Text(c.nome),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              final matches = _geo.cidades.where((c) => c.nome == value);
                              final cidade = matches.isNotEmpty ? matches.first : null;
                              _geo.selecionarCidade(cidade);
                              if (mounted) setState(() {});
                            },
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
                        await _censo
                            .carregarCensoPorCidade(_geo.cidadeSelecionada!.id)
                            .catchError((_) async {
                          await _censo.carregarGruposCenso();
                        });
                        Modular.to.pushNamed('/budget/config', arguments: {
                          'estado': _geo.estadoSelecionado,
                          'cidade': _geo.cidadeSelecionada,
                          'censo': _censo.censo,
                        });
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
