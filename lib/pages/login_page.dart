import 'package:flutter/material.dart';
import 'home_page.dart';

class Login extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController turmaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF123560), // Cor de fundo azul escuro
      body: SafeArea(
        child: SingleChildScrollView( // 🔥 Faz a tela rolar se o teclado abrir
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo do app
                Center(
                  child: Image.asset(
                    'assets/app-logo.png',
                    height: 200,
                  ),
                ),
                SizedBox(height: 20),

                // Campo Nome
                Text(
                  'Nome:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    hintText: 'Digite seu nome',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                // Campo Idade
                Text(
                  'Idade:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: idadeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Idade',
                    hintText: 'Digite sua idade',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),

                // Campo Turma
                Text(
                  'Turma:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: turmaController,
                  decoration: InputDecoration(
                    labelText: 'Turma',
                    hintText: 'Digite sua turma',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Botão de Começar
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          nome: nomeController.text,
                        ),
                      ),
                    );
                  },
                  child: Text('Começar'),
                ),
                SizedBox(height: 30),

                // Logo Marista
                Center(
                  child: Image.asset(
                    'assets/marista-logo.png',
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
