import 'package:flutter/material.dart';


import 'home_page.dart';



class Login extends StatelessWidget {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF123560), // azul escuro
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            //Logo
            children: [
              Image.asset(
                'assets/app-logo.png',
                height: 200,
              ),
              SizedBox(height: 20),
              //Texto acima do input Nome
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                'Nome:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,

                ),
              ),
              ),
              //Forms para inserir nome
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
              //Texto acima do input Idade
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Idade:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
              //Forms para inserir idade
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
              SizedBox(height: 20),
              //Texto acima do input Nome
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Turma:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
              //Forms para inserir turma
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Turma',
                  hintText: 'Digite sua turma',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              //botão de confirmação
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
                //Função que o botão vai executar ao ser pressionado
                onPressed: () {
                  Navigator.pushReplacement(//PushReplacement, substitui a tela anterior
                    context,
                    MaterialPageRoute(builder: (_) => HomePage(nome: nomeController.text)), //Encaminha para a proxima pagina com o nome inserido
                  );
                },
                child: Text('Começar'),
              ),
              SizedBox(height: 30),
              //Logo Marista
              Image.asset(
                'assets/marista-logo.png',
                height: 120,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

