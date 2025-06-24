import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

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
              Image.asset('assets/logo.png', height: 60),
              const SizedBox(height: 12),
              const Text(
                'Cadastro de doação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: produtoController,
                      decoration: const InputDecoration(labelText: 'Produto:'),
                    ),
                    TextField(
                      controller: quantidadeController,
                      decoration: const InputDecoration(labelText: 'Quantidade:'),
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
