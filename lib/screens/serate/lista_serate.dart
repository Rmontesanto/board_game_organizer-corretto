import 'package:flutter/material.dart';
import '../../models/serata.dart';
import '../../data/database.dart';
import 'aggiungi_serata.dart';
import 'dettaglio_serata.dart';

class ListaSerate extends StatefulWidget {
  const ListaSerate({super.key});

  @override
  State<ListaSerate> createState() => _ListaSerateState();
}

class _ListaSerateState extends State<ListaSerate> {
  List<Serata> _serate = [];
  List<Serata> _serateFiltrate = [];
  String _filtroStato = 'Tutti';

  final List<String> _stati = ['Tutti', 'Futura', 'Completata', 'Annullata'];

  @override
  void initState() {
    super.initState();
    _caricaSerate();
  }

  Future<void> _caricaSerate() async {
    final serate = await Database.getSerate();
    serate.sort((a, b) => a.data.compareTo(b.data));
    setState(() {
      _serate = serate;
      _applicaFiltri();
    });
  }

  void _applicaFiltri() {
    setState(() {
      _serateFiltrate = _serate.where((s) {
        return _filtroStato == 'Tutti' || s.stato == _filtroStato;
      }).toList();
    });
  }

  Color _coloreStato(String stato) {
    switch (stato) {
      case 'Futura':
        return Colors.blue;
      case 'Completata':
        return Colors.green;
      case 'Annullata':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _iconaStato(String stato) {
    switch (stato) {
      case 'Futura':
        return Icons.event;
      case 'Completata':
        return Icons.check_circle;
      case 'Annullata':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  String _formattaData(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serate di gioco'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              _filtroStato = value;
              _applicaFiltri();
            },
            itemBuilder: (context) => _stati
                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                .toList(),
          ),
        ],
      ),
      body: _serateFiltrate.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna serata trovata',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Organizza la tua prima serata!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _serateFiltrate.length,
              itemBuilder: (context, index) {
                final serata = _serateFiltrate[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: _coloreStato(
                        serata.stato,
                      ).withOpacity(0.2),
                      child: Icon(
                        _iconaStato(serata.stato),
                        color: _coloreStato(serata.stato),
                      ),
                    ),
                    title: Text(
                      serata.titolo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formattaData(serata.data)),
                        if (serata.luogo.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey,
                              ),
                              Text(' ${serata.luogo}'),
                            ],
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _coloreStato(serata.stato).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        serata.stato,
                        style: TextStyle(
                          color: _coloreStato(serata.stato),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DettaglioSerata(serata: serata),
                        ),
                      );
                      _caricaSerate();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AggiungiSerata()),
          );
          _caricaSerate();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuova serata'),
      ),
    );
  }
}
