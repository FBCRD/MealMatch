import 'package:flutter/material.dart';

import 'QuestionarioPage.dart';

class HomePage extends StatelessWidget {
  final String nome;

  const HomePage({super.key, required this.nome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF123560),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo do app
              Image.asset(
                'assets/app-logo.png',
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                'Bem vindo, "$nome"',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuestionarioPage()),
                  );
                },
                child: Text('Questionario'),
              ),
              SizedBox(height: 15),
              SizedBox(height: 50),
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
