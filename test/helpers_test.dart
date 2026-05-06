import 'package:flutter_test/flutter_test.dart';
import 'package:myfirstapp/utils/helpers.dart';

void main() {
  group('Testes de Saudação |', () {
    test('Deve retornar Bom dia para horas antes do meio-dia', () {
      expect(Helpers.getSaudacao(9), 'Bom dia');
      expect(Helpers.getSaudacao(11), 'Bom dia');
    });

    test('Deve retornar Boa tarde para horas entre 12h e 17h', () {
      expect(Helpers.getSaudacao(13), 'Boa tarde');
      expect(Helpers.getSaudacao(17), 'Boa tarde');
    });

    test('Deve retornar Boa noite para horas após 18h', () {
      expect(Helpers.getSaudacao(19), 'Boa noite');
      expect(Helpers.getSaudacao(23), 'Boa noite');
    });
  });

  group('Testes de Dia da Semana |', () {
    test('Deve retornar o dia correto baseado no número (1 a 7)', () {
      expect(Helpers.obterDiaAtual(1), 'Segunda-feira');
      expect(Helpers.obterDiaAtual(5), 'Sexta-feira');
      expect(Helpers.obterDiaAtual(7), 'Domingo');
    });
  });

  group('Testes de Formatação do Cronômetro |', () {
    test('Deve formatar os segundos para o formato MM:SS', () {
      expect(Helpers.formatarTempoDescanso(90), '1:30'); // 1 min e meio
      expect(Helpers.formatarTempoDescanso(60), '1:00'); // 1 minuto exato
      expect(Helpers.formatarTempoDescanso(5), '0:05');  // Testando o zero à esquerda
    });
  });
}
