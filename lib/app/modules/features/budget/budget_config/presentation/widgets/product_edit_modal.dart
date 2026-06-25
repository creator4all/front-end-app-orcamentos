import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multimidiaapp/app/shared/utils/brl_currency_input_formatter.dart';
import 'package:multimidiaapp/app/shared/utils/currency_utils.dart';

import '../../domain/entities/indicador_etapa_entity.dart';
import '../../domain/entities/product_entity.dart';

class ProductEditModal extends StatefulWidget {
  final ProductEntity product;
  final Function(ProductEntity) onSave;
  final VoidCallback? onClose;

  const ProductEditModal({
    super.key,
    required this.product,
    required this.onSave,
    this.onClose,
  });

  @override
  State<ProductEditModal> createState() => _ProductEditModalState();
}

class _ProductEditModalState extends State<ProductEditModal> {
  late TextEditingController _valorController;
  late List<IndicadorEtapaEntity> _indicadores;
  late bool _isLivro;
  late bool _isTecnologia;

  @override
  void initState() {
    super.initState();
    _valorController = TextEditingController(
      text: CurrencyUtils.formatBRLNoSymbol(widget.product.valor),
    );
    _indicadores = List.from(widget.product.indicadoresEtapa);
    _isLivro = _checkIsLivro(widget.product.tipoProduto);
    _isTecnologia = _checkIsTecnologia(widget.product.tipoProduto);
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  bool _checkIsLivro(String tipoProduto) {
    return tipoProduto.toLowerCase().contains('livro') ||
        tipoProduto.toLowerCase().contains('colecao') ||
        tipoProduto.toLowerCase().contains('material didático');
  }

  bool _checkIsTecnologia(String tipoProduto) {
    return tipoProduto.toLowerCase().contains('tecnologia') ||
        tipoProduto.toLowerCase().contains('software') ||
        tipoProduto.toLowerCase().contains('plataforma') ||
        tipoProduto.toLowerCase().contains('digital');
  }

  void _toggleIndicador(int index) {
    setState(() {
      _indicadores[index] = _indicadores[index].copyWith(
        selecionado: !_indicadores[index].selecionado,
      );
    });
  }

  void _marcarTodos() {
    setState(() {
      _indicadores =
          _indicadores.map((ind) => ind.copyWith(selecionado: true)).toList();
    });
  }

  void _desmarcarTodos() {
    setState(() {
      _indicadores =
          _indicadores.map((ind) => ind.copyWith(selecionado: false)).toList();
    });
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    final valor =
        BrlCurrencyInputFormatter.parseToDouble(_valorController.text);

    final updatedProduct = widget.product.copyWith(
      valor: valor,
      indicadoresEtapa: _indicadores,
    );

    widget.onSave(updatedProduct);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 0.9.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Editar Produto',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.solucao,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.product.indicacao,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                _isLivro ? Icons.book : Icons.computer,
                                size: 16.sp,
                                color: const Color(0xFF117BBD),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _isLivro
                                    ? 'Livro'
                                    : _isTecnologia
                                        ? 'Tecnologia'
                                        : 'Outro',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF117BBD),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (_isLivro || _isTecnologia) ...[
                      Text(
                        'Valor Unitário',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [BrlCurrencyInputFormatter()],
                        decoration: InputDecoration(
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Indicadores',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _marcarTodos,
                              child: Text(
                                'Marcar todos',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            TextButton(
                              onPressed: _desmarcarTodos,
                              child: Text(
                                'Desmarcar todos',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        children: _indicadores.asMap().entries.map((entry) {
                          final index = entry.key;
                          final indicador = entry.value;
                          final isProfessor = indicador.nomeEtapa.endsWith('P');

                          return CheckboxListTile(
                            value: indicador.selecionado,
                            onChanged: (value) => _toggleIndicador(index),
                            activeColor: const Color(0xFF117BBD),
                            title: Text(
                              _formatarNomeIndicador(indicador.nomeEtapa),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isProfessor
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: isProfessor
                                ? Text(
                                    'Professores',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.orange[700],
                                    ),
                                  )
                                : null,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        }).toList(),
                      ),
                    ),
                    if (_isLivro || _isTecnologia) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Regra de cálculo',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _isLivro
                                  ? 'Livros: Soma apenas indicadores de professores (P)'
                                  : 'Tecnologias: Soma todos os indicadores',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _close,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF117BBD),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarNomeIndicador(String nome) {
    final Map<String, String> titulos = {
      'bercario': 'Berçário',
      'maternal': 'Maternal',
      'in4ano': 'Infantil - 4 anos',
      'in5ano': 'Infantil - 5 anos',
      'ef1ano': '1º Ano',
      'ef2ano': '2º Ano',
      'ef3ano': '3º Ano',
      'ef4ano': '4º Ano',
      'ef5ano': '5º Ano',
      'ef6ano': '6º Ano',
      'ef7ano': '7º Ano',
      'ef8ano': '8º Ano',
      'ef9ano': '9º Ano',
      'em1ano': '1º Ano - EM',
      'em2ano': '2º Ano - EM',
      'em3ano': '3º Ano - EM',
      'efEja': 'EJA - EF',
      'emEja': 'EJA - EM',
      'professores': 'Professores',
      'cursistas': 'Cursistas',
    };

    if (nome.endsWith('P')) {
      final baseNome = nome.substring(0, nome.length - 1);
      final tituloBase = titulos[baseNome] ?? baseNome;
      return '$tituloBase - Professores';
    }

    return titulos[nome] ?? nome;
  }
}
