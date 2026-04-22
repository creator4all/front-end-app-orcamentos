class CensusValueNormalizer {
  static const Set<String> _stagesToCeil = {
    'in4ano',
    'in5ano',
    'in4anop',
    'in5anop',
  };

  static double consolidateStageValue(String nomeEtapa, double value) {
    if (_stagesToCeil.contains(nomeEtapa.toLowerCase())) {
      return value.ceilToDouble();
    }

    return value;
  }
}
