class Helpers {
  // 1. Lógica de Saudação
  static String getSaudacao(int hora) {
    if (hora < 12) return "Bom dia";
    if (hora < 18) return "Boa tarde";
    return "Boa noite";
  }

  // 2. Lógica do Dia da Semana
  static String obterDiaAtual(int diaDaSemana) {
    switch (diaDaSemana) {
      case 1: return "Segunda-feira";
      case 2: return "Terça-feira";
      case 3: return "Quarta-feira";
      case 4: return "Quinta-feira";
      case 5: return "Sexta-feira";
      case 6: return "Sábado";
      case 7: return "Domingo";
      default: return "Segunda-feira";
    }
  }

  // 3. Lógica do Cronômetro de Descanso
  static String formatarTempoDescanso(int segundos) {
    int mins = segundos ~/ 60;
    int secs = segundos % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }
}
