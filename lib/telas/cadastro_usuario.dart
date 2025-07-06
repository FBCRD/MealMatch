import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroDoadorPage extends StatefulWidget {
  const CadastroDoadorPage({super.key});
  @override
  State<CadastroDoadorPage> createState() => _CadastroDoadorPageState();
}

class _CadastroDoadorPageState extends State<CadastroDoadorPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  String? _tipoUsuario;
  bool _isLoading = false;

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

  Future <void> _cadastrar() async{
    if (!_formKey.currentState!.validate()) {
      return; // Se o formulário não for válido, não faz nada
    }

    setState(() => _isLoading = true);

    try {
      //Cria o usuário no Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Se chegou aqui, o usuário foi criado com sucesso.
      final User user = userCredential.user!;

      //Salva as informações adicionais no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'tipoUsuario': _tipoUsuario,
        'cpf_cnpj': _cpfController.text.trim(),
        'dataNascimento': _dataNascimentoController.text.trim(),
        'criadoEm': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        // Leva o usuário de volta para a tela de login após o sucesso
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase Auth
      String mensagemErro = 'Ocorreu um erro desconhecido.';
      if (e.code == 'weak-password') {
        mensagemErro = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        mensagemErro = 'Este e-mail já está sendo utilizado.';
      } else if (e.code == 'invalid-email') {
        mensagemErro = 'O e-mail fornecido é inválido.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Trata outros erros
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E),
      appBar: AppBar(
        title: const Text('Cadastro - Tánamesa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de usuário',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
                value: _tipoUsuario,
                items: const [
                  DropdownMenuItem(value: 'Doador', child: Text('Sou Doador')),
                  DropdownMenuItem(value: 'Instituição', child: Text('Sou Instituição')),
                ],
                onChanged: (valor) {
                  setState(() {
                    _tipoUsuario = valor;
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo de usuário' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome ou Razão Social', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Informe a senha' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF/CNPJ', border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Informe o CPF/CNPJ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento/Fundação',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                  fillColor: Colors.white,
                  filled: true,
                ),
                readOnly: true,
                onTap: () => _selecionarData(context),
                validator: (value) => value!.isEmpty ? 'Informe a data' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isLoading ? null: _cadastrar,
                  child: _isLoading ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ):



                  const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
