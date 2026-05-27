class CensusStageRules {
  static bool isCursistaStage(String nomeEtapa) {
    final n = nomeEtapa.trim().toLowerCase();
    return n == 'cursista' || n == 'cursistas';
  }

  static bool isProfessorStage(String nomeEtapa) {
    final n = nomeEtapa.trim().toLowerCase();
    return n == 'professores' || n.endsWith('p');
  }

  static bool isStudentStage(String nomeEtapa) {
    return !isProfessorStage(nomeEtapa) && !isCursistaStage(nomeEtapa);
  }
}
