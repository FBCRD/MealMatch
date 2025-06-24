import 'package:flutter/material.dart';

class CadastroDoadorPage extends StatefulWidget {
  @override
  _CadastroDoadorPageState createState() => _CadastroDoadorPageState();
}

class _CadastroDoadorPageState extends State<CadastroDoadorPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      setState(() {
        _selectedDate = dataSelecionada;
        _dataNascimentoController.text =
        "${dataSelecionada.day.toString().padLeft(2, '0')}/"
            "${dataSelecionada.month.toString().padLeft(2, '0')}/"
            "${dataSelecionada.year}";
      });
    }
  }

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      // Aqui você pega os valores e faz o cadastro
      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final senha = _senhaController.text;
      final cpf = _cpfController.text.trim();
      final dataNascimento = _selectedDate;

      // Exemplo simples de print, no seu caso você pode enviar para API ou salvar localmente
      print('Nome: $nome');
      print('Email: $email');
      print('Senha: $senha');
      print('CPF: $cpf');
      print('Data Nascimento: $dataNascimento');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    }
  }

  String? _validarCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o CPF';
    }
    // Aqui você pode colocar uma validação de CPF mais robusta
    if (value.length != 11) {
      return 'CPF deve ter 11 números';
    }
    return null;
  }
  String? _tipoUsuario;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro Doador - MealMatch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Informe um email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe a senha' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF/CNPJ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 11,
                validator: _validarCPF,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selecionarData(context),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe a data' : null,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de usuário',
                  border: OutlineInputBorder(),
                ),
                value: _tipoUsuario,
                items: [
                  DropdownMenuItem(value: 'Doador', child: Text('Doador')),
                  DropdownMenuItem(value: 'Instituição', child: Text('Instituição')),
                ],
                onChanged: (valor) {
                  setState(() {
                    _tipoUsuario = valor;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione o tipo de usuário';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _cadastrar,
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
