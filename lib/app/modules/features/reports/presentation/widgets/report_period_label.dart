import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPeriodLabel extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;

  const ReportPeriodLabel({super.key, this.start, this.end});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy');
    final period = start == null && end == null
        ? 'sem filtro de período'
        : start == null
            ? 'até ${format.format(end!)}'
            : end == null
                ? 'a partir de ${format.format(start!)}'
                : '${format.format(start!)} a ${format.format(end!)}';
    return Text('Criação dos orçamentos: $period',
        style: Theme.of(context).textTheme.bodySmall);
  }
}
