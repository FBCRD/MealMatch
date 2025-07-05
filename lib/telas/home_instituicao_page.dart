// lib/pages/home_instituicao_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doacao.dart';
import '../database/doacao_database.dart';

class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  List<Doacao> doacoesDisponiveis = [];
  Doacao? coletaAtual;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  // Nenhuma mudança aqui
  Future<void> carregarDados() async {
    setState(() => isLoading = true);
    // Apenas carrega as doações que ainda não foram marcadas como coletadas no DB
    final todas = await DoacaoDatabase.instance.readAll();
    final naoColetadas = todas.where((d) => !d.foicoletada).toList();

    setState(() {
      doacoesDisponiveis = naoColetadas;
      isLoading = false;
    });
  }

  // ALTERAÇÃO: Função de rota aprimorada
  void abrirNoGoogleMaps(String enderecoDestino) async {
    final queryDestino = Uri.encodeComponent(enderecoDestino);

    // ALTERAÇÃO: Esta nova URL é específica para iniciar o modo de rotas/direções.
    // O Google Maps irá automaticamente usar a localização atual do usuário como ponto de partida.
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$queryDestino');

    // Para depuração: veja no console a URL que está sendo aberta.
    print('Tentando abrir a URL de direções: ${url.toString()}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Falha ao chamar canLaunchUrl.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível traçar a rota no Google Maps.')),
      );
    }
  }

  // NOVO: Função para navegar e aguardar o resultado
  Future<void> _navegarParaColeta() async {
    // Navega para a tela de coleta e aguarda um resultado.
    final resultado = await Navigator.pushNamed(context, '/coleta');

    // Se um resultado foi retornado (e é uma Doacao), atualizamos o estado.
    if (resultado != null && resultado is Doacao) {
      setState(() {
        // A doação que acabamos de coletar se torna a "coletaAtual"
        coletaAtual = resultado;
      });
    }

    // Recarrega a lista de doações disponíveis, que agora terá um item a menos.
    await carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDados,
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 12),
                // ALTERAÇÃO: Nome de exemplo, pode ser dinâmico no futuro
                const Text('Bem vindo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // ALTERAÇÃO: Chama a nova função de navegação
                    onPressed: _navegarParaColeta,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Fazer Coleta', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { /* TODO: Tela Minhas Coletas */ },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Minhas coletas', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // Card de Coleta Atual (agora funciona!)
                if (coletaAtual != null)
                  _buildCardColetaAtual(coletaAtual!),

                // Card de Doações Disponíveis
                _buildCardDoacoesDisponiveis(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Este widget já estava correto e agora será exibido quando `coletaAtual` não for nulo.
  Widget _buildCardColetaAtual(Doacao coleta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sua coleta atual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Lembre-se de coletar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => abrirNoGoogleMaps(coleta.endereco),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                child: const Text('Ver rota'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(coleta.produto, style: const TextStyle(fontSize: 16)),
              Text(coleta.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(coleta.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // Nenhuma mudança necessária aqui
  Widget _buildCardDoacoesDisponiveis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Válido até Hoje', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Doações disponíveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black)),
          if (!isLoading && doacoesDisponiveis.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhuma doação disponível no momento.", style: TextStyle(fontSize: 16, color: Colors.black54)))),
          if (!isLoading && doacoesDisponiveis.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doacoesDisponiveis.length,
              itemBuilder: (context, index) {
                final doacao = doacoesDisponiveis[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(doacao.produto, style: const TextStyle(fontSize: 16)),
                          Text(doacao.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // No card de doações, o endereço é o nome do restaurante
                      Text(doacao.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
        ],
      ),
    );
  }
}






/*class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  List<Doacao> doacoesDisponiveis = [];
  Doacao? coletaAtual;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => isLoading = true);
    final todas = await DoacaoDatabase.instance.readAll();

    // Separa a coleta que foi marcada como "em coleta" (mas não finalizada)
    // Para este exemplo, vamos considerar a primeira não coletada como a "atual"
    final naoColetadas = todas.where((d) => !d.foicoletada).toList();

    setState(() {
      // Aqui, a lógica de "coleta atual" precisaria ser mais robusta,
      // por exemplo, ter um campo "coleta_iniciada_por_instituicao_id" no DB.
      // Para simplificar, vamos assumir que não há uma coleta "em andamento" específica
      // e o card "Sua coleta atual" só aparecerá se uma coleta for iniciada na tela '/coleta'.
      // Por enquanto, vamos preencher apenas as doações disponíveis.
      coletaAtual = null; // Você pode mudar isso com uma lógica mais avançada
      doacoesDisponiveis = naoColetadas;
      isLoading = false;
    });
  }

  void abrirNoGoogleMaps(String endereco) async {
    final query = Uri.encodeComponent(endereco);
    final url = Uri.parse('http://googleusercontent.com/maps.google.com/3');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD6C9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDados,
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                Image.asset('assets/logo2.png', height: 80),
                const SizedBox(height: 12),
                const Text('Bem vindo, Instituição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/coleta').then((_) => carregarDados());
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Fazer Coleta', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { *//* TODO: Tela Minhas Coletas *//* },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Minhas coletas', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // Card de Coleta Atual (lógica a ser implementada se necessário)
                if (coletaAtual != null)
                  _buildCardColetaAtual(coletaAtual!),

                // Card de Doações Disponíveis
                _buildCardDoacoesDisponiveis(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardColetaAtual(Doacao coleta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sua coleta atual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Lembre-se de coletar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              ElevatedButton(
                onPressed: () => abrirNoGoogleMaps(coleta.endereco),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                child: const Text('Ver rota'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(coleta.produto, style: const TextStyle(fontSize: 16)),
              Text(coleta.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(coleta.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCardDoacoesDisponiveis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Válido até Hoje', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Doações disponíveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black)),
          if (!isLoading && doacoesDisponiveis.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhuma doação disponível no momento.", style: TextStyle(fontSize: 16, color: Colors.black54)))),
          if (!isLoading && doacoesDisponiveis.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doacoesDisponiveis.length,
              itemBuilder: (context, index) {
                final doacao = doacoesDisponiveis[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(doacao.produto, style: const TextStyle(fontSize: 16)),
                          Text(doacao.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(doacao.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
        ],
      ),
    );
  }
}*/









/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doacao.dart'; // Mantenha a importação do seu modelo
import '../database/doacao_database.dart'; // Mantenha a importação do seu DB

class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  // Dados de exemplo para corresponder à imagem.
  // Você deve substituir isso pela sua lógica de carregamento real.
  final Doacao _coletaAtual = Doacao(
    id: 1,
    produto: 'Arroz com galinha',
    quantidade: '20kg',
    endereco: 'Endereço da Coleta Atual', // Coloque o endereço real aqui
    foicoletada: false, // Indica que é uma coleta ativa
  );

  final List<Doacao> _doacoesDisponiveis = [
    Doacao(id: 2, produto: 'Arroz com galinha', quantidade: '20kg', endereco: 'Restaurante Dona Chica', foicoletada: true),
    Doacao(id: 3, produto: 'Frutas', quantidade: '5kg', endereco: 'Fruteira beira-Rio', foicoletada: true),
    Doacao(id: 4, produto: 'Pães diversos', quantidade: '7kg', endereco: 'Padaria Nonadeli', foicoletada: true),
  ];
  // Fim dos dados de exemplo.

  // Descomente suas variáveis quando for usar seu banco de dados
  // List<Doacao> doacoes = [];
  // bool get temColetaAtiva => doacoes.any((d) => d.foicoletada == false);
  // Doacao? get coletaAtiva => temColetaAtiva ? doacoes.firstWhere((d) => d.foicoletada == false) : null;

  @override
  void initState() {
    super.initState();
    // carregarDoacoes(); // Descomente para usar seu DB
  }

  // Função para abrir o endereço no Google Maps (CORRIGIDA)
  void abrirNoGoogleMaps(String endereco) async {
    final query = Uri.encodeComponent(endereco);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Maps')),
      );
    }
  }

  // Sua função de carregar doações (mantenha como está)
  Future<void> carregarDoacoes() async {
    // final lista = await DoacaoDatabase.instance.readAll();
    // setState(() {
    //   doacoes = lista;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD6C9), // Cor de fundo ajustada para a da imagem
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: carregarDoacoes,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // --- CABEÇALHO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Image.asset('assets/logo2.png', height: 80), // Ajuste a altura se necessário
                const SizedBox(height: 12),
                const Text(
                  'Bem vindo, Vivianna',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),

                // --- BOTÕES DE AÇÃO ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/coleta');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Fazer Coleta', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Minhas coletas', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                // --- CARD: SUA COLETA ATUAL (APARECE SE TIVER COLETA) ---
                // Para teste, estou usando `_coletaAtual != null`. Troque pela sua variável `temColetaAtiva`.
                if (_coletaAtual != null)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sua coleta atual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                SizedBox(height: 4),
                                Text(
                                  'Lembre-se de coletar',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Use `coletaAtiva!.endereco` com seu DB
                                abrirNoGoogleMaps(_coletaAtual.endereco);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Ver rota'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _coletaAtual.produto, // Use `coletaAtiva!.produto` com seu DB
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              _coletaAtual.quantidade, // Use `coletaAtiva!.quantidade` com seu DB
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _coletaAtual.endereco, // Use `coletaAtiva!.endereco` com seu DB
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // --- CARD: DOAÇÕES DISPONÍVEIS ---
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
                      const Text('Valido até Hoje', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      const Text(
                        'Doacao disponiveis', // "Doação" com 'ç' e "disponíveis" com 'í'
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),

                      // Lista de doações disponíveis
                      // Use a sua lista `doacoes.where((d) => d.foicoletada).toList()` aqui
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _doacoesDisponiveis.length,
                        itemBuilder: (context, index) {
                          final doacao = _doacoesDisponiveis[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(doacao.produto, style: const TextStyle(fontSize: 16)),
                                    Text(
                                      doacao.quantidade,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doacao.endereco, // Este campo deve conter o nome do local/restaurante
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
