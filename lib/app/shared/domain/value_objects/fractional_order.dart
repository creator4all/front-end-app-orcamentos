/// Ordem decimal da API, preservada sem conversão para ponto flutuante.
///
/// As colunas DECIMAL(18,8) podem diferir apenas na última casa, que um double
/// não representa em toda a faixa. A representação canônica também mantém a
/// precisão ao serializar para JSON, inclusive no Flutter Web.
class FractionalOrder implements Comparable<FractionalOrder> {
  final String _integer;
  final String _fraction;
  final bool _negative;

  const FractionalOrder._(this._integer, this._fraction, this._negative);

  static const zero = FractionalOrder._('0', '', false);

  /// Aceita decimais em texto e números de respostas legadas; ausente é zero.
  /// Lança [FormatException] para valores que não representam um decimal finito.
  factory FractionalOrder.parse(Object? value) {
    if (value == null) return zero;
    if (value is FractionalOrder) return value;
    final text = value.toString().trim();
    final match = RegExp(r'^([+-]?)(\d+)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$')
        .firstMatch(text);
    if (match == null || (value is! String && value is! num)) {
      throw FormatException('Ordem decimal inválida', value);
    }

    var integer = match[2]!;
    var fraction = match[3] ?? '';
    final exponent = int.tryParse(match[4] ?? '0');
    if (exponent == null || exponent.abs() > 1000) {
      throw FormatException('Expoente decimal fora da faixa', value);
    }
    if (exponent != 0) {
      final digits = integer + fraction;
      final point = integer.length + exponent;
      if (point <= 0) {
        integer = '0';
        fraction = '${''.padLeft(-point, '0')}$digits';
      } else if (point >= digits.length) {
        integer = digits.padRight(point, '0');
        fraction = '';
      } else {
        integer = digits.substring(0, point);
        fraction = digits.substring(point);
      }
    }
    integer = integer.replaceFirst(RegExp(r'^0+'), '');
    if (integer.isEmpty) integer = '0';
    fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    if (integer == '0' && fraction.isEmpty) return zero;
    return FractionalOrder._(integer, fraction, match[1] == '-');
  }

  @override
  int compareTo(FractionalOrder other) {
    if (_negative != other._negative) return _negative ? -1 : 1;
    var result = _integer.length.compareTo(other._integer.length);
    if (result == 0) result = _integer.compareTo(other._integer);
    if (result == 0) {
      final length = _fraction.length > other._fraction.length
          ? _fraction.length
          : other._fraction.length;
      result = _fraction
          .padRight(length, '0')
          .compareTo(other._fraction.padRight(length, '0'));
    }
    return _negative ? -result : result;
  }

  String toJson() => toString();

  @override
  String toString() =>
      '${_negative ? '-' : ''}$_integer${_fraction.isEmpty ? '' : '.$_fraction'}';

  @override
  bool operator ==(Object other) =>
      other is FractionalOrder &&
      _integer == other._integer &&
      _fraction == other._fraction &&
      _negative == other._negative;

  @override
  int get hashCode => Object.hash(_integer, _fraction, _negative);
}
