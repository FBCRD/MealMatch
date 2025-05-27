import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionarioPage extends StatelessWidget {
  final TextEditingController respostaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF123560),
      appBar: AppBar(
        backgroundColor: Color(0xFF123560),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset(
              'assets/caminho_solidario.png',
              height: 100,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Qual a sua comida favorita?',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: respostaController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Resposta:',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 5,
              ),
              onPressed: () {
                // Salvar resposta ou avançar
              },
              child: Text('Responder'),
            ),
            Spacer(),
            Image.asset(
              'assets/logos.png',
              height: 50,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
