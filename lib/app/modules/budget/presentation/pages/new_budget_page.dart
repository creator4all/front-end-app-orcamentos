import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../shared/widgets/custom_top_bar.dart';

class NewBudgetPage extends StatefulWidget {
  const NewBudgetPage({super.key});

  @override
  State<NewBudgetPage> createState() => _NewBudgetPageState();
}

class _NewBudgetPageState extends State<NewBudgetPage> {
  String? _selectedPartner;
  String? _selectedState;
  String? _selectedCity;
  final TextEditingController _responsibleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _validityDateController = TextEditingController();

  // Lista de estados
  final List<String> _states = [
    'Acre',
    'Alagoas',
    'Amapá',
    'Amazonas',
    'Bahia',
    'Ceará',
    'Distrito Federal',
    'Espírito Santo',
    'Goiás',
    'Maranhão',
    'Mato Grosso',
    'Mato Grosso do Sul',
    'Minas Gerais',
    'Pará',
    'Paraíba',
    'Paraná',
    'Pernambuco',
    'Piauí',
    'Rio de Janeiro',
    'Rio Grande do Norte',
    'Rio Grande do Sul',
    'Rondônia',
    'Roraima',
    'Santa Catarina',
    'São Paulo',
    'Sergipe',
    'Tocantins'
  ];

  // Mapa de cidades por estado (exemplo simplificado)
  final Map<String, List<String>> _citiesByState = {
    'São Paulo': [
      'São Paulo',
      'Campinas',
      'Santos',
      'Ribeirão Preto',
      'Sorocaba'
    ],
    'Rio de Janeiro': [
      'Rio de Janeiro',
      'Niterói',
      'Campos dos Goytacazes',
      'Nova Iguaçu'
    ],
    'Minas Gerais': [
      'Belo Horizonte',
      'Uberlândia',
      'Contagem',
      'Juiz de Fora'
    ],
    // Adicione mais estados conforme necessário
  };

  @override
  void dispose() {
    _responsibleController.dispose();
    _emailController.dispose();
    _validityDateController.dispose();
    super.dispose();
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
                        value: _selectedState,
                        hint: Text(
                          'Estado',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        items: _states.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedCity =
                                null; // Reset cidade quando mudar estado
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Cidade (só aparece quando estado selecionado)
                  if (_selectedState != null) ...[
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
                          value: _selectedCity,
                          hint: Text(
                            'Cidade',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          items: (_citiesByState[_selectedState] ?? [])
                              .map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                            });
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
                    onPressed: () {
                      // Navegar para tela de configurações com o nome da cidade
                      String cityName =
                          _selectedCity ?? 'Cidade não selecionada';
                      Modular.to.pushNamed('/budget/config', arguments: {
                        'cityName': cityName,
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
                      // TODO: Implementar orçamento multi-cidades
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
