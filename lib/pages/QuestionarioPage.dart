import 'package:flutter/material.dart';

class QuestionarioPage extends StatefulWidget {
  const QuestionarioPage({Key? key}) : super(key: key);

  @override
  State<QuestionarioPage> createState() => _QuestionarioPageState();
}

class _QuestionarioPageState extends State<QuestionarioPage> {
  // Lista com as perguntas do questionário
  final List<Map<String, dynamic>> perguntas = [
    {
      'pergunta': 'Qual é a sua comida favorita?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Qual fruta você mais gosta?',
      'tipo': 'select',
      'opcoes': [
        'Maçã',
        'Banana',
        'Morango',
        'Melancia',
        'Abacaxi',
        'Uva',
        'Laranja',
        'Manga',
        'Pera',
        'Outra'
      ],
    },
    {
      'pergunta': 'Qual legume ou verdura você gosta?',
      'tipo': 'select',
      'opcoes': [
        'Alface',
        'Tomate',
        'Cenoura',
        'Brócolis',
        'Couve',
        'Pepino',
        'Beterraba',
        'Espinafre',
        'Outra'
      ],
    },
    {
      'pergunta': 'Tem algum alimento que você não gosta? Qual?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Você gosta de cozinhar? Já cozinhou algo antes? O quê?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Que tipo de lanche você costuma levar ou comer na escola?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Você já foi a uma feira, mercado ou horta? O que achou?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Você costuma comer frutas todos os dias?',
      'tipo': 'select',
      'opcoes': ['Sim', 'Não'],
    },
    {
      'pergunta':
      'Você tem alguma alergia alimentar? (Leite, ovos, glúten, amendoim, etc.)',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Tem algum alimento que não pode comer?',
      'tipo': 'texto',
    },
    {
      'pergunta':
      'Alguma comida que te faz mal ou você não gosta nem do cheiro?',
      'tipo': 'texto',
    },
    {
      'pergunta': 'Que comida diferente você gostaria de aprender a fazer?',
      'tipo': 'texto',
    },
    {
      'pergunta':
      'O que você gostaria de aprender na oficina? (Fazer doces, salgados, massas, etc.)',
      'tipo': 'select',
      'opcoes': ['Doces', 'Salgados', 'Massas', 'Sobremesas', 'Outros'],
    },
    {
      'pergunta': 'Você prefere fazer lanches, refeições ou sobremesas?',
      'tipo': 'select',
      'opcoes': ['Lanches', 'Refeições', 'Sobremesas'],
    },
    {
      'pergunta':
      'Você gosta de decorar pratos? (Com frutas, cores, formatos diferentes…)',
      'tipo': 'select',
      'opcoes': ['Sim', 'Não'],
    },
  ];

  int indicePergunta = 0;

  // Controlador para respostas do tipo texto
  final TextEditingController respostaController = TextEditingController();

  // Variável para armazenar respostas do tipo select
  String? respostaSelecionada;

  // Mapa para armazenar as respostas
  Map<String, String> respostas = {};

  // Função para avançar para a próxima pergunta ou mostrar resultado
  void avancarPergunta() {
    String chave = perguntas[indicePergunta]['pergunta'];

    if (perguntas[indicePergunta]['tipo'] == 'texto') {
      if (respostaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, preencha sua resposta')),
        );
        return;
      }
      respostas[chave] = respostaController.text;
      respostaController.clear();
    } else if (perguntas[indicePergunta]['tipo'] == 'select') {
      if (respostaSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma opção')),
        );
        return;
      }
      respostas[chave] = respostaSelecionada!;
      respostaSelecionada = null;
    }

    if (indicePergunta < perguntas.length - 1) {
      setState(() {
        indicePergunta++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadoPage(respostas: respostas),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final perguntaAtual = perguntas[indicePergunta];

    return Scaffold(
      backgroundColor: const Color(0xFF123560),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123560),
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/app-logo.png',
                    height: 150,
                  ),
                ),

                const SizedBox(height: 20),

                // Pergunta com contador
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Text(
                        '${indicePergunta + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        perguntaAtual['pergunta'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Campo de texto
                if (perguntaAtual['tipo'] == 'texto')
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: respostaController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Resposta:',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                // Dropdown select
                if (perguntaAtual['tipo'] == 'select')
                  Container(
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: respostaSelecionada,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Selecione uma opção',
                      ),
                      items: (perguntaAtual['opcoes'] as List<String>)
                          .map(
                            (opcao) => DropdownMenuItem(
                          value: opcao,
                          child: Text(opcao),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          respostaSelecionada = value;
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // Botão Responder
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: avancarPergunta,
                    child: const Text('Responder'),
                  ),
                ),

                const SizedBox(height: 50),

                // Logo Marista
                Center(
                  child: Image.asset(
                    'assets/marista-logo.png',
                    height: 100,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Página de Resultado
class ResultadoPage extends StatelessWidget {
  final Map<String, String> respostas;

  const ResultadoPage({super.key, required this.respostas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF123560),
      appBar: AppBar(
        backgroundColor: const Color(0xFF123560),
        title: const Text(
          'Respostas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: respostas.entries.map((entry) {
            return Card(
              color: Colors.white,
              child: ListTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(entry.value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
