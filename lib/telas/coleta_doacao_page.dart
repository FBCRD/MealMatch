// lib/pages/coleta_doacao_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../models/doacao.dart';
import '../database/doacao_database.dart';

class ColetaDoacaoPage extends StatefulWidget {
  const ColetaDoacaoPage({super.key});

  @override
  State<ColetaDoacaoPage> createState() => _ColetaDoacaoPageState();
}

class _ColetaDoacaoPageState extends State<ColetaDoacaoPage> {
  List<Doacao> doacoes = [];
  bool isLoading = true;
  Doacao? doacaoSelecionada;

  final MapController _mapController = MapController();
  LatLng coordenadaMapa = const LatLng(-29.6868, -53.8149); // Santa Maria padrão

  @override
  void initState() {
    super.initState();
    carregarDoacoes();
  }

  Future<void> carregarDoacoes() async {
    setState(() => isLoading = true);
    final lista = await DoacaoDatabase.instance.readAll();
    setState(() {
      doacoes = lista.where((d) => d.foicoletada == false).toList();
      isLoading = false;
    });
  }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível localizar o endereço: $e')));
    }
  }

  Future<void> coletarDoacao() async {
    if (doacaoSelecionada != null) {
      // Primeiro, marca como coletada no banco de dados.
      await DoacaoDatabase.instance.marcarComoColetada(doacaoSelecionada!.id!);

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coleta registrada! Veja o card de lembrete na sua home.')));

        // ALTERAÇÃO PRINCIPAL AQUI:
        // Em vez de apenas fechar, retorna o objeto 'doacaoSelecionada' para a tela anterior (Home).
        Navigator.pop(context, doacaoSelecionada);
      }
    }
  }

  // ... (o resto do arquivo, incluindo o método build, continua exatamente igual)

  @override
  Widget build(BuildContext context) {
    // NENHUMA MUDANÇA NECESSÁRIA NO MÉTODO BUILD
    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : doacoes.isEmpty
                          ? const Center(child: Text("Nenhuma doação para coletar.", style: TextStyle(fontSize: 16, color: Colors.black54)))
                          : ListView.builder(
                        itemCount: doacoes.length,
                        itemBuilder: (context, index) {
                          final d = doacoes[index];
                          final selecionado = doacaoSelecionada?.id == d.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() => doacaoSelecionada = d);
                              buscarCoordenadaPorEndereco(d.endereco);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: selecionado ? Colors.black : Colors.grey.shade300, width: selecionado ? 2 : 1), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: d.imagemPath != null && d.imagemPath!.isNotEmpty
                                        ? Image.file(File(d.imagemPath!), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholderImage())
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
                                            Text(d.produto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text(d.quantidade, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(d.endereco, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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





/*class _ColetaDoacaoPageState extends State<ColetaDoacaoPage> {
  List<Doacao> doacoes = [];
  bool isLoading = true;
  Doacao? doacaoSelecionada;

  final MapController _mapController = MapController();
  LatLng coordenadaMapa = const LatLng(-29.6868, -53.8149); // Santa Maria padrão

  @override
  void initState() {
    super.initState();
    carregarDoacoes();
  }

  Future<void> carregarDoacoes() async {
    setState(() => isLoading = true);
    final lista = await DoacaoDatabase.instance.readAll();
    setState(() {
      doacoes = lista.where((d) => d.foicoletada == false).toList();
      isLoading = false;
    });
  }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível localizar o endereço: $e')));
    }
  }

  Future<void> coletarDoacao() async {
    if (doacaoSelecionada != null) {
      await DoacaoDatabase.instance.marcarComoColetada(doacaoSelecionada!.id!);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coleta registrada com sucesso!')));
        // CORREÇÃO: Volta para a tela anterior (Home Instituição)
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D0C3),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.black))
                          : doacoes.isEmpty
                          ? const Center(child: Text("Nenhuma doação para coletar.", style: TextStyle(fontSize: 16, color: Colors.black54)))
                          : ListView.builder(
                        itemCount: doacoes.length,
                        itemBuilder: (context, index) {
                          final d = doacoes[index];
                          final selecionado = doacaoSelecionada?.id == d.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() => doacaoSelecionada = d);
                              buscarCoordenadaPorEndereco(d.endereco);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(border: Border.all(color: selecionado ? Colors.black : Colors.grey.shade300, width: selecionado ? 2 : 1), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: d.imagemPath != null && d.imagemPath!.isNotEmpty
                                        ? Image.file(File(d.imagemPath!), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholderImage())
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
                                            Text(d.produto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text(d.quantidade, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(d.endereco, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                  // Desabilita o botão se nenhuma doação for selecionada
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
}*/














/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import '../models/doacao.dart';
import '../database/doacao_database.dart';

class ColetaDoacaoPage extends StatefulWidget {
  const ColetaDoacaoPage({super.key});

  @override
  State<ColetaDoacaoPage> createState() => _ColetaDoacaoPageState();
}

class _ColetaDoacaoPageState extends State<ColetaDoacaoPage> {
  List<Doacao> doacoes = [];
  Doacao? doacaoSelecionada;

  final MapController _mapController = MapController();
  LatLng coordenadaMapa = const LatLng(-29.6868, -53.8149); // Santa Maria padrão

  @override
  void initState() {
    super.initState();
    carregarDoacoes();
  }

  Future<void> carregarDoacoes() async {
    final lista = await DoacaoDatabase.instance.readAll();
    setState(() {
      doacoes = lista.where((d) => d.foicoletada == false).toList(); // <- filtra as não coletadas
    });
  }


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
      print('Erro ao localizar endereço: $e');
    }
  }

  Future<void> coletarDoacao() async {
    if (doacaoSelecionada != null) {
      await DoacaoDatabase.instance.marcarComoColetada(doacaoSelecionada!.id!);
      await carregarDoacoes();
      setState(() {
        doacaoSelecionada = null;
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
        leading: const BackButton(color: Colors.black),
        actions: const [

          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Image.asset('assets/logo2.png', height: 60),
            const SizedBox(height: 12),
            const Text(
              'Coleta de doação',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: coordenadaMapa,
                    zoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: coordenadaMapa,
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'itens doados',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Produtos em destaque',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: doacoes.length,
                        itemBuilder: (context, index) {
                          final d = doacoes[index];
                          final selecionado = doacaoSelecionada?.id == d.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                doacaoSelecionada = d;
                              });
                              buscarCoordenadaPorEndereco(d.endereco);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selecionado
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: selecionado ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Imagem da doação
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(d.imagemPath ?? ''),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Texto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(d.produto,
                                                style: const TextStyle(fontSize: 16)),
                                            Text(d.quantidade,
                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(d.endereco,
                                            style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            ),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: doacaoSelecionada != null
                    ? () async {
                  await coletarDoacao(); // <- sua função que atualiza o banco
                  Navigator.pushNamed(context, '/coleta'); // navega para outra página
                }
                    : null, // botão desabilitado se não tiver seleção
                child: const Text('Coletar doação'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}*/
