import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgendaPage extends StatelessWidget {
  final String alunoId;

  const AgendaPage({super.key, required this.alunoId});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Agenda da Semana",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Resumo do seu planejamento de treinos",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: supabase.from('exercicios').select().eq('cliente_id', alunoId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "Nenhum treino na agenda.",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      );
                    }

                    final treinos = snapshot.data!;
                    
                    Map<String, Set<String>> agendaMap = {
                      "Segunda-feira": {},
                      "Terça-feira": {},
                      "Quarta-feira": {},
                      "Quinta-feira": {},
                      "Sexta-feira": {},
                      "Sábado": {},
                      "Domingo": {},
                      "Rotativo (Ficha)": {},
                      "Todos os dias": {},
                    };

                    for (var ex in treinos) {
                      String dia = ex['dia_semana'] ?? 'Geral';
                      String grupo = ex['grupo_muscular'] ?? 'Geral';
                      
                      if (agendaMap.containsKey(dia)) {
                        agendaMap[dia]!.add(grupo);
                      } else {
                        agendaMap[dia] = {grupo};
                      }
                    }

                    List<String> diasComTreino = agendaMap.keys
                        .where((dia) => agendaMap[dia]!.isNotEmpty)
                        .toList();

                    return ListView.builder(
                      itemCount: diasComTreino.length,
                      itemBuilder: (context, index) {
                        String dia = diasComTreino[index];
                        String gruposTexto = agendaMap[dia]!.join(", ");

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TreinoPorDiaPage(
                                    alunoId: alunoId,
                                    dia: dia,
                                  ),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calendar_month, color: Colors.deepPurpleAccent),
                            ),
                            title: Text(
                              dia,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "Foco: $gruposTexto",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TreinoPorDiaPage extends StatelessWidget {
  final String alunoId;
  final String dia;

  const TreinoPorDiaPage({super.key, required this.alunoId, required this.dia});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1F),
      appBar: AppBar(
        title: Text("Treino de $dia"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('exercicios')
            .select()
            .eq('cliente_id', alunoId)
            .eq('dia_semana', dia),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum exercício para este dia."));
          }

          final listaTreino = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: listaTreino.length,
            itemBuilder: (context, index) {
              final ex = listaTreino[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1122).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: (ex['imagem_url'] != null && ex['imagem_url'].toString().isNotEmpty)
                          ? Image.network(ex['imagem_url'], width: 60, height: 60, fit: BoxFit.cover)
                          : Container(width: 60, height: 60, color: Colors.grey),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex['nome_exercicio'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("${ex['series']} Séries • ${ex['repeticoes'] ?? '12 reps'}", 
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text("Carga: ${ex['carga'] ?? '0kg'}", 
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
