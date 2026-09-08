import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:multimidiaapp/app/shared/domain/value_objects/fractional_order.dart';

void main() {
  test('preserva 40 posições distintas com a mesma parte inteira', () {
    final orders = List.generate(
      40,
      (index) =>
          FractionalOrder.parse('1.${(index + 1).toString().padLeft(8, '0')}'),
    );
    expect([...orders]..sort(), orders);
    expect(orders.reversed.toList()..sort(), orders);
    expect(orders.toSet(), hasLength(40));
  });

  test('preserva a última casa na faixa inteira de DECIMAL(18,8)', () {
    final before = FractionalOrder.parse('9999999999.99999998');
    final after = FractionalOrder.parse('9999999999.99999999');
    expect(before.compareTo(after), lessThan(0));
    expect(before, isNot(after));
    expect(jsonDecode(jsonEncode([before, after])),
        ['9999999999.99999998', '9999999999.99999999']);
  });

  test('compara sinais, magnitudes e frações numericamente', () {
    final expected = [
      '-9999999999.99999999',
      '-10',
      '-1.75',
      '-1.25',
      '-0.00000001',
      '0',
      '0.00000001',
      '1.25',
      '1.75',
      '10',
    ].map(FractionalOrder.parse).toList();
    expect(expected.reversed.toList()..sort(), expected);
  });

  test('normaliza representação e aceita números legados e ausência', () {
    expect(FractionalOrder.parse(null), FractionalOrder.zero);
    expect(FractionalOrder.parse('-0.00000000'), FractionalOrder.zero);
    expect(FractionalOrder.parse(2), FractionalOrder.parse('2.00000000'));
    expect(FractionalOrder.parse(1.25), FractionalOrder.parse('+001.2500'));
    expect(FractionalOrder.parse(1e-8).toJson(), '0.00000001');
    expect(FractionalOrder.parse('1.25e2').toJson(), '125');
    expect({FractionalOrder.parse('1.2500'), FractionalOrder.parse('1.25')},
        hasLength(1));
  });

  test('rejeita entradas inválidas sem inventar posição', () {
    for (final value in ['inválido', '', true, double.nan, double.infinity]) {
      expect(() => FractionalOrder.parse(value), throwsFormatException);
    }
  });
}
