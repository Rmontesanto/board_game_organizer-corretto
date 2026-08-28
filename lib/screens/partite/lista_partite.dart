import 'package:flutter/material.dart';
import '../../models/partita.dart';
import '../../models/gioco.dart';
import '../../models/giocatore.dart';
import '../../data/database.dart';
import 'aggiungi_partita.dart';
import 'dettaglio_partita.dart';

class ListaPartite extends StatefulWidget {
  const ListaPartite({super.key});

  @override
  State<ListaPartite> createState() => _ListaPartiteState();
}

class _ListaPartiteState extends State<ListaPartite> {
  List<Partita> _partite = [];
  List<Gioco> _giochi = [];
  List<Giocatore> _giocatori = [];

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    final partite = await Database.getPartite();
    final giochi = await Database.getGiochi();
    final giocatori = await Database.getGiocatori();
    partite.sort((a, b) => b.data.compareTo(a.data));
    setState(() {
      _partite = partite;
      _giochi = giochi;
      _giocatori = giocatori;
    });
  }

  String _nomeGioco(String id) {
    final gioco = _giochi.where((g) => g.id == id).firstOrNull;
    return gioco?.nome ?? 'Gioco sconosciuto';
  }

  String _nomeGiocatore(String id) {
    final giocatore = _giocatori.where((g) => g.id == id).firstOrNull;
    return giocatore?.nome ?? 'Sconosciuto';
  }

  String _formattaData(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partite')),
      body: _partite.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_esports, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna partita registrata',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registra la tua prima partita!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _partite.length,
              itemBuilder: (context, index) {
                final partita = _partite[index];
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
                      child: const Icon(
                        Icons.sports_esports,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      _nomeGioco(partita.giocoId),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formattaData(partita.data)),
                        if (partita.vincitoreId.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: Colors.amber,
                              ),
                              Text(
                                ' ${_nomeGiocatore(partita.vincitoreId)}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Text(
                      '${partita.giocatoriIds.length} gioc.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DettaglioPartita(partita: partita),
                        ),
                      );
                      _caricaDati();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AggiungiPartita()),
          );
          _caricaDati();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuova partita'),
      ),
    );
  }
}
