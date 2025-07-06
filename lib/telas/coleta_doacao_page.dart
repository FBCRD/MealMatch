
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../models/doacao.dart';


class ColetaDoacaoPage extends StatefulWidget {
  const ColetaDoacaoPage({super.key});

  @override
  State<ColetaDoacaoPage> createState() => _ColetaDoacaoPageState();
}

class _ColetaDoacaoPageState extends State<ColetaDoacaoPage> {
  String? idCessao;
  Doacao? doacaoSelecionada;

  @override
  void initState(){
    super.initState();
    _carregarDadosUsuario();
  }
  Future<void> _carregarDadosUsuario() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          idCessao = userDoc.get('uid');
        });
      }
    }
  }





  final MapController _mapController = MapController();
  LatLng coordenadaMapa = const LatLng(-29.6868, -53.8149); // Santa Maria padrão

  Future<void> buscarCoordenadaPorEndereco(String endereco) async {
    try {
      final locations = await locationFromAddress(endereco);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final novaCoordenada = LatLng(loc.latitude, loc.longitude);
        setState(() {
          coordenadaMapa = novaCoordenada;
        });
        _mapController.move(novaCoordenada, 15);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível localizar o endereço: $e')));
      }
    }
  }

  Future<void> coletarDoacao() async {
    if (doacaoSelecionada != null && doacaoSelecionada!.id != null) {
      try {
        await FirebaseFirestore.instance
            .collection('doacoes')
            .doc(doacaoSelecionada!.id)
            .update({'foicoletada': true,
        'idCessao':idCessao,
        'dataColeta':DateTime.timestamp()});

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coleta registrada com sucesso!')));
          Navigator.pop(context, doacaoSelecionada);
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar coleta: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E), // Cor de exemplo
      appBar: AppBar(
        title: const Text('Coleta de Doação'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(center: coordenadaMapa, zoom: 14),
                  children: [
                    TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
                    MarkerLayer(markers: [Marker(point: coordenadaMapa, width: 40, height: 40, child: const Icon(Icons.location_pin, size: 40, color: Colors.red))]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione um item para ver no mapa e coletar:', style: TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('doacoes')
                            .where('foicoletada', isEqualTo: false)
                            .orderBy('dataCadastro', descending: true)
                            .snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Colors.black));
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Erro ao carregar doações.'));
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("Nenhuma doação para coletar.", style: TextStyle(fontSize: 16, color: Colors.black54)),
                            );
                          }

                          // Se tem dados, constroi a lista
                          final doacoesDocs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: doacoesDocs.length,
                            itemBuilder: (context, index) {
                              // Converte o documento para um objeto Doacao
                              final doacao = Doacao.fromFirestore(doacoesDocs[index]);
                              final selecionado = doacaoSelecionada?.id == doacao.id;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => doacaoSelecionada = doacao);
                                  buscarCoordenadaPorEndereco(doacao.endereco);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: selecionado ? Colors.black : Colors.grey.shade300, width: selecionado ? 2 : 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: doacao.imagemPath != null && doacao.imagemPath!.isNotEmpty
                                            ? Image.file(File(doacao.imagemPath!), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholderImage())
                                            : _buildPlaceholderImage(),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(doacao.produto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                Text(doacao.quantidade, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(doacao.endereco, style: const TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                onPressed: doacaoSelecionada != null ? coletarDoacao : null,
                child: const Text('Confirmar Coleta', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 30),
    );
  }
}