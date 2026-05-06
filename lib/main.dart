import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'agenda_page.dart';
import 'utils/validators.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://peisigvtfgpndubdayse.supabase.co',
    anonKey: 'sb_publishable_tWOJaWSIV_KCY5FJNmIOEQ_iuUjjTRb',
  );
  runApp(const GymApp());
}

final supabase = Supabase.instance.client;

class GymApp extends StatelessWidget {
  const GymApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CCAM App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E1F),
        primaryColor: const Color(0xFF6C28D9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C28D9),
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    try {
      final resposta = await supabase
          .from('clientes')
          .select()
          .eq('email', email)
          .eq('cpf', senha)
          .maybeSingle();

      if (resposta == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acesso negado! Verifique seu email e senha (CPF).'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigationScreen(alunoData: resposta),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMeshBackground(),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fitness_center, size: 80, color: Colors.deepPurpleAccent),
                  const SizedBox(height: 20),
                  const Text(
                    "Bem-vindo ao CCAM",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    validator: Validators.validaEmail,
                    decoration: InputDecoration(
                      labelText: 'E-mail do Aluno',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _senhaController,
                    validator: Validators.validaSenha,
                    decoration: InputDecoration(
                      labelText: 'Senha (Seu CPF)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.4),
                    ),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _fazerLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Entrar", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> alunoData;
  const MainNavigationScreen({super.key, required this.alunoData});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TrainingPage(alunoData: widget.alunoData),
      AgendaPage(alunoId: widget.alunoData['id'].toString()),
      const MuralPage(),
      const FinanceiroPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMeshBackground(),
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0E1F).withOpacity(0.9),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Treino'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Mural'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Finan.'),
        ],
      ),
    );
  }
}

Widget _buildMeshBackground() {
  return Stack(
    children: [
      Container(color: const Color(0xFF0A0E1F)),
      Positioned(
        top: -150,
        left: -100,
        child: Container(
          width: 450,
          height: 450,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepPurple.withOpacity(0.18),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.18),
                blurRadius: 200,
                spreadRadius: 80,
              ),
            ],
          ),
        ),
      ),
      Positioned(
        bottom: 100,
        right: -150,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal.withOpacity(0.12),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.12),
                blurRadius: 200,
                spreadRadius: 80,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class TrainingPage extends StatelessWidget {
  final Map<String, dynamic> alunoData;
  const TrainingPage({super.key, required this.alunoData});

  String _getSaudacao() {
    var hora = DateTime.now().hour;
    if (hora < 12) return "Bom dia";
    if (hora < 18) return "Boa tarde";
    return "Boa noite";
  }

  String _obterDiaAtual() {
    int diaDaSemana = DateTime.now().weekday;
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

  @override
  Widget build(BuildContext context) {
    final nome = alunoData['nome'] ?? 'Aluno';
    final alunoId = alunoData['id'].toString();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getSaudacao(), style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 0.5)),
                    Text(nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white38, size: 24),
                  onPressed: () => Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage())
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const RestTimer(),
            const SizedBox(height: 20),
            const Text("Seu Treino de Hoje", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: () {
                  String hoje = _obterDiaAtual();
                  return supabase
                      .from('exercicios')
                      .select()
                      .eq('cliente_id', alunoId)
                      .eq('dia_semana', hoje);
                }(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhum exercício cadastrado para hoje."));
                  }
                  final listaTreino = snapshot.data!;
                  return ListView.builder(
                    itemCount: listaTreino.length,
                    itemBuilder: (context, index) {
                      final ex = listaTreino[index];
                      return _buildExerciseCard(
                        context,
                        ex['nome_exercicio'],
                        "${ex['series']} Séries",
                        ex['repeticoes'] ?? "12 reps",
                        ex['carga'] ?? "0kg",
                        ex['imagem_url'] ?? ""
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String title, String series, String reps, String weight, String gifUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1122).withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (gifUrl.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.black,
                    child: Image.network(gifUrl, fit: BoxFit.contain),
                  ),
                );
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: gifUrl.isNotEmpty 
                ? Image.network(gifUrl, width: 60, height: 60, fit: BoxFit.cover)
                : Container(width: 60, height: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$series • $reps", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text("Carga: $weight", style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
              ],
            ),
          ),
          const ExerciseCheck(),
        ],
      ),
    );
  }
}

class RestTimer extends StatefulWidget {
  const RestTimer({super.key});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  Timer? _timer;
  int _secondsRemaining = 0;

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.deepPurpleAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                _secondsRemaining > 0 ? _formatTime(_secondsRemaining) : "Descanso",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              _timerButton("1m", 60),
              _timerButton("1.5m", 90),
              _timerButton("3m", 180),
              if (_secondsRemaining > 0)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 22),
                  onPressed: () {
                    _timer?.cancel();
                    setState(() => _secondsRemaining = 0);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerButton(String label, int seconds) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _startTimer(seconds),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B0B3B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ExerciseCheck extends StatefulWidget {
  const ExerciseCheck({super.key});
  @override
  State<ExerciseCheck> createState() => _ExerciseCheckState();
}

class _ExerciseCheckState extends State<ExerciseCheck> {
  bool _isDone = false;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: _isDone ? Colors.greenAccent : Colors.white24,
      ),
      onPressed: () {
        setState(() {
          _isDone = !_isDone;
        });
      },
    );
  }
}

class MuralPage extends StatelessWidget { const MuralPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("Mural")); }
class FinanceiroPage extends StatelessWidget { const FinanceiroPage({super.key}); @override Widget build(BuildContext context) => const Center(child: Text("Financeiro")); }
