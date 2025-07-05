// lib/pages/cadastro_doacao_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../models/doacao.dart';
import '../database/doacao_database.dart';

class CadastroDoacaoPage extends StatefulWidget {
  const CadastroDoacaoPage({super.key});

  @override
  State<CadastroDoacaoPage> createState() => _CadastroDoacaoPageState();
}

class _CadastroDoacaoPageState extends State<CadastroDoacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final produtoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final validadeController = TextEditingController();
  final enderecoController = TextEditingController();

  final MapController _mapController = MapController();
  LatLng? localizacaoMapa;
  final LatLng localPadrao = const LatLng(-29.6868, -53.8149); // Santa Maria

  File? imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selecionarData(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      validadeController.text =
      "${dataSelecionada.day.toString().padLeft(2, '0')}/"
          "${dataSelecionada.month.toString().padLeft(2, '0')}/"
          "${dataSelecionada.year}";
    }
  }

  Future<void> buscarCoordenadas() async {
    if (enderecoController.text.length < 5) return;
    try {
      final locations = await locationFromAddress(enderecoController.text);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          localizacaoMapa = LatLng(loc.latitude, loc.longitude);
        });
        _mapController.move(localizacaoMapa!, 15);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Endereço não encontrado: $e")));
    }
  }

  Future<void> capturarImagem() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (imagem != null) {
      setState(() {
        imagemSelecionada = File(imagem.path);
      });
    }
  }

  Future<void> _salvarDoacao() async {
    if (_formKey.currentState!.validate()) {
      final novaDoacao = Doacao(
        produto: produtoController.text,
        quantidade: quantidadeController.text,
        validade: validadeController.text,
        endereco: enderecoController.text,
        imagemPath: imagemSelecionada?.path,
        foicoletada: false, // CORREÇÃO: Sempre inicia como não coletada
      );

      await DoacaoDatabase.instance.create(novaDoacao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação cadastrada com sucesso!')),
        );
        Navigator.pop(context); // Volta para a Home do Doador
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFBA2E),
      appBar: AppBar(
        title: const Text('Cadastro de Doação'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(controller: produtoController, decoration: const InputDecoration(labelText: 'Produto:'), validator: (v) => v!.isEmpty ? "Campo obrigatório" : null),
                      TextFormField(controller: quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade (ex: 5kg, 3 caixas):'), validator: (v) => v!.isEmpty ? "Campo obrigatório" : null),
                      TextFormField(controller: validadeController, decoration: const InputDecoration(labelText: 'Data de Validade:', suffixIcon: Icon(Icons.calendar_today)), readOnly: true, onTap: () => _selecionarData(context), validator: (v) => v!.isEmpty ? "Campo obrigatório" : null),
                      TextFormField(controller: enderecoController, decoration: InputDecoration(labelText: 'Endereço de retirada:', suffixIcon: IconButton(icon: Icon(Icons.search), onPressed: buscarCoordenadas,)), validator: (v) => v!.isEmpty ? "Campo obrigatório" : null),
                      const SizedBox(height: 16),
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(height: 150, child: FlutterMap(mapController: _mapController, options: MapOptions(center: localizacaoMapa ?? localPadrao, zoom: 15), children: [TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'), if (localizacaoMapa != null) MarkerLayer(markers: [Marker(point: localizacaoMapa!, width: 40, height: 40, child: const Icon(Icons.location_pin, size: 40, color: Colors.red))])]))),
                      const SizedBox(height: 16),
                      const Text('Foto do produto:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 150, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: imagemSelecionada != null ? Image.file(imagemSelecionada!, fit: BoxFit.cover) : const Center(child: Text('Nenhuma imagem'))),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(onPressed: capturarImagem, icon: const Icon(Icons.camera_alt), label: const Text('Tirar Foto'), style: OutlinedButton.styleFrom(foregroundColor: Colors.black)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size.fromHeight(50)),
                        onPressed: _salvarDoacao,
                        child: const Text('Efetivar Doação', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}































/*
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/doacao.dart';
import '../database/doacao_database.dart';

class CadastroDoacaoPage extends StatefulWidget {
  const CadastroDoacaoPage({super.key});

  @override
  State<CadastroDoacaoPage> createState() => _CadastroDoacaoPageState();
}

class _CadastroDoacaoPageState extends State<CadastroDoacaoPage> {
  final produtoController = TextEditingController();
  final quantidadeController = TextEditingController();
  final validadeController = TextEditingController();
  final enderecoController = TextEditingController();


  final MapController _mapController = MapController();

  LatLng? localizacaoMapa;
  final LatLng localPadrao = LatLng(-29.6868, -53.8149); // Ex: Santa Maria

  File? imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> buscarCoordenadas(String endereco) async {
    try {
      final locations = await locationFromAddress(endereco);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          localizacaoMapa = LatLng(loc.latitude, loc.longitude);
        });

        _mapController.move(localizacaoMapa!, 15);
      }
    } catch (e) {
      print("Erro ao buscar endereço: $e");
    }
  }

  Future<void> capturarImagem() async {
    final XFile? imagem = await _picker.pickImage(source: ImageSource.camera);
    if (imagem != null) {
      setState(() {
        imagemSelecionada = File(imagem.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D0C3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD7D0C3),
        elevation: 0,
        leading: BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/logo2.png', height: 60),
              const SizedBox(height: 12),
              const Text(
                'Cadastro de doação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: produtoController,
                      decoration: const InputDecoration(labelText: 'Produto:'),
                    ),
                    TextField(
                      controller: quantidadeController,
                      decoration:
                      const InputDecoration(labelText: 'Quantidade:'),
                    ),
                    TextField(
                      controller: validadeController,
                      decoration: const InputDecoration(
                          labelText: 'Data de Validade:',
                          hintText: 'xx/xx/xxxx'),
                    ),
                    TextField(
                      controller: enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço:',
                        hintText: 'Insira o endereço de busca das doações',
                      ),
                      onChanged: (value) {
                        if (value.length > 5) {
                          buscarCoordenadas(value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center: localizacaoMapa ?? localPadrao,
                            zoom: 15,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            if (localizacaoMapa != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: localizacaoMapa!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_pin,
                                      size: 40,
                                      color: Colors.red,
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campo da imagem
                    Text('Imagem da doação:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    imagemSelecionada != null
                        ? Image.file(imagemSelecionada!, height: 150)
                        : const Text('Nenhuma imagem selecionada'),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: capturarImagem,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tirar foto da doação'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        final novaDoacao = Doacao(
                          produto: produtoController.text,
                          quantidade: quantidadeController.text,
                          validade: validadeController.text,
                          endereco: enderecoController.text,
                          imagemPath: imagemSelecionada?.path
                        );

                        await DoacaoDatabase.instance.create(novaDoacao);
                        Navigator.pushReplacementNamed(context, '/homeDoador');
                      },
                      child: const Text('Efetivar doação'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
