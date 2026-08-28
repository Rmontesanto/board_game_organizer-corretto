import 'package:flutter/material.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';
import 'aggiungi_gioco.dart';
import 'dettaglio_gioco.dart';

class ListaGiochi extends StatefulWidget {
  const ListaGiochi({super.key});

  @override
  State<ListaGiochi> createState() => _ListaGiochiState();
}

class _ListaGiochiState extends State<ListaGiochi> {
  List<Gioco> _giochi = [];
  List<Gioco> _giochiFiltrati = [];
  String _ricerca = '';
  String _filtroCategoria = 'Tutti';
  String _filtroStato = 'Tutti';

  final List<String> _categorie = [
    'Tutti',
    'Strategia',
    'Famiglia',
    'Cooperativo',
    'Party',
    'Carte',
    'Dadi',
    'Avventura',
    'Altro',
  ];
  final List<String> _stati = [
    'Tutti',
    'Posseduto',
    'Wishlist',
    'Prestato',
    'Da provare',
  ];

  @override
  void initState() {
    super.initState();
    _caricaGiochi();
  }

  Future<void> _caricaGiochi() async {
    final giochi = await Database.getGiochi();
    setState(() {
      _giochi = giochi;
      _applicaFiltri();
    });
  }

  void _applicaFiltri() {
    setState(() {
      _giochiFiltrati = _giochi.where((g) {
        final matchRicerca = g.nome.toLowerCase().contains(
          _ricerca.toLowerCase(),
        );
        final matchCategoria =
            _filtroCategoria == 'Tutti' || g.categoria == _filtroCategoria;
        final matchStato = _filtroStato == 'Tutti' || g.stato == _filtroStato;
        return matchRicerca && matchCategoria && matchStato;
      }).toList();
    });
  }

  Color _coloreStato(String stato) {
    switch (stato) {
      case 'Posseduto':
        return Colors.green;
      case 'Wishlist':
        return Colors.blue;
      case 'Prestato':
        return Colors.orange;
      case 'Da provare':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei giochi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostraFiltri,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cerca un gioco...',
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
          if (_filtroCategoria != 'Tutti' || _filtroStato != 'Tutti')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (_filtroCategoria != 'Tutti')
                    Chip(
                      label: Text(_filtroCategoria),
                      onDeleted: () {
                        _filtroCategoria = 'Tutti';
                        _applicaFiltri();
                      },
                    ),
                  const SizedBox(width: 8),
                  if (_filtroStato != 'Tutti')
                    Chip(
                      label: Text(_filtroStato),
                      onDeleted: () {
                        _filtroStato = 'Tutti';
                        _applicaFiltri();
                      },
                    ),
                ],
              ),
            ),
          Expanded(
            child: _giochiFiltrati.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.games, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nessun gioco trovato',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aggiungi il tuo primo gioco!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _giochiFiltrati.length,
                    itemBuilder: (context, index) {
                      final gioco = _giochiFiltrati[index];
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
                              gioco.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            gioco.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gioco.categoria.isEmpty
                                    ? 'Nessuna categoria'
                                    : gioco.categoria,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  Text(
                                    ' ${gioco.minGiocatori}-${gioco.maxGiocatori}  ',
                                  ),
                                  Icon(
                                    Icons.timer,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  Text(' ${gioco.durata} min'),
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
                              color: _coloreStato(gioco.stato).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              gioco.stato,
                              style: TextStyle(
                                color: _coloreStato(gioco.stato),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DettaglioGioco(gioco: gioco),
                              ),
                            );
                            _caricaGiochi();
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
            MaterialPageRoute(builder: (_) => const AggiungiGioco()),
          );
          _caricaGiochi();
        },
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi gioco'),
      ),
    );
  }

  void _mostraFiltri() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtra per categoria',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categorie.map((cat) {
                      return ChoiceChip(
                        label: Text(cat),
                        selected: _filtroCategoria == cat,
                        onSelected: (selected) {
                          setStateModal(() => _filtroCategoria = cat);
                          _applicaFiltri();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filtra per stato',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _stati.map((stato) {
                      return ChoiceChip(
                        label: Text(stato),
                        selected: _filtroStato == stato,
                        onSelected: (selected) {
                          setStateModal(() => _filtroStato = stato);
                          _applicaFiltri();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
