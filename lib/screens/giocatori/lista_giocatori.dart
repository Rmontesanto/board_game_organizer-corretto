import 'package:flutter/material.dart';
import '../../models/giocatore.dart';
import '../../data/database.dart';
import 'aggiungi_giocatore.dart';
import 'dettaglio_giocatore.dart';

class ListaGiocatori extends StatefulWidget {
  const ListaGiocatori({super.key});

  @override
  State<ListaGiocatori> createState() => _ListaGiocatoriState();
}

class _ListaGiocatoriState extends State<ListaGiocatori> {
  List<Giocatore> _giocatori = [];
  List<Giocatore> _giocatoriFiltrati = [];
  String _ricerca = '';

  @override
  void initState() {
    super.initState();
    _caricaGiocatori();
  }

  Future<void> _caricaGiocatori() async {
    final giocatori = await Database.getGiocatori();
    setState(() {
      _giocatori = giocatori;
      _applicaFiltri();
    });
  }

  void _applicaFiltri() {
    setState(() {
      _giocatoriFiltrati = _giocatori.where((g) {
        return g.nome.toLowerCase().contains(_ricerca.toLowerCase()) ||
            g.nickname.toLowerCase().contains(_ricerca.toLowerCase());
      }).toList();
    });
  }

  Color _coloreEsperienza(String livello) {
    switch (livello) {
      case 'Principiante':
        return Colors.green;
      case 'Intermedio':
        return Colors.orange;
      case 'Esperto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giocatori')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca un giocatore...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
              ),
              onChanged: (value) {
                _ricerca = value;
                _applicaFiltri();
              },
            ),
          ),
          Expanded(
            child: _giocatoriFiltrati.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nessun giocatore trovato',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aggiungi il primo giocatore!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _giocatoriFiltrati.length,
                    itemBuilder: (context, index) {
                      final giocatore = _giocatoriFiltrati[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF6B3FA0),
                            child: Text(
                              giocatore.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            giocatore.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            giocatore.nickname.isEmpty
                                ? 'Nessun nickname'
                                : '@${giocatore.nickname}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _coloreEsperienza(
                                giocatore.livelloEsperienza,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              giocatore.livelloEsperienza,
                              style: TextStyle(
                                color: _coloreEsperienza(
                                  giocatore.livelloEsperienza,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DettaglioGiocatore(giocatore: giocatore),
                              ),
                            );
                            _caricaGiocatori();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AggiungiGiocatore()),
          );
          _caricaGiocatori();
        },
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi giocatore'),
      ),
    );
  }
}
