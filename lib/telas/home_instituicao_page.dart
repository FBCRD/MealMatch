import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../models/doacao.dart';
import '../database/doacao_database.dart';

class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  List<Doacao> doacoes = [];
  LatLng? coordenadaColeta;

  bool get hasDoacoes => doacoes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    carregarDoacoes();
  }

  Future<void> carregarDoacoes() async {
    final lista = await DoacaoDatabase.instance.readAll();
    setState(() {
      doacoes = lista;
    });

    // Se houver doações, busca a coordenada do primeiro endereço
    if (lista.isNotEmpty) {
      await buscarCoordenadaDoEndereco(lista.first.endereco);
    } else {
      setState(() {
        coordenadaColeta = const LatLng(-29.6868, -53.8149); // Santa Maria padrão
      });
    }
  }

  Future<void> buscarCoordenadaDoEndereco(String endereco) async {
    try {
      final locations = await locationFromAddress(endereco);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          coordenadaColeta = LatLng(loc.latitude, loc.longitude);
        });
      }
    } catch (e) {
      print('Erro ao buscar coordenada: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D0C3),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDoacoes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Image.asset('assets/logo.png', height: 60),
                const SizedBox(height: 12),
                const Text(
                  'Bem vindo, Vivianna',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/coleta');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: const Text('Fazer Coleta'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: const Text('Minhas coletas'),
                ),
                const SizedBox(height: 20),

                // Bloco de alerta
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Válido até Hoje', style: TextStyle(color: Colors.grey)),
                      Text(
                        hasDoacoes ? 'Doações disponíveis' : 'Lembre-se de coletar',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (hasDoacoes)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Divider(),
                        ),
                      if (hasDoacoes)
                        Column(
                          children: doacoes.map((doacao) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(doacao.imagemPath ?? ''),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(doacao.produto,
                                                style: const TextStyle(fontSize: 15)),
                                            Text(doacao.quantidade,
                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(doacao.endereco,
                                            style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
