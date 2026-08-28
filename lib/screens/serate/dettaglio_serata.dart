import 'package:flutter/material.dart';
import '../../models/serata.dart';
import '../../models/giocatore.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';
import 'aggiungi_serata.dart';

class DettaglioSerata extends StatefulWidget {
  final Serata serata;
  const DettaglioSerata({super.key, required this.serata});

  @override
  State<DettaglioSerata> createState() => _DettaglioSerataState();
}

class _DettaglioSerataState extends State<DettaglioSerata> {
  List<Giocatore> _giocatori = [];
  List<Gioco> _giochi = [];

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    final giocatori = await Database.getGiocatori();
    final giochi = await Database.getGiochi();
    setState(() {
      _giocatori = giocatori
          .where((g) => widget.serata.partecipantiIds.contains(g.id))
          .toList();
      _giochi = giochi
          .where((g) => widget.serata.giochiIds.contains(g.id))
          .toList();
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

  String _formattaData(DateTime data) {
    return '${data.day}/${data.month}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serata.titolo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AggiungiSerata(serata: widget.serata),
                ),
              );
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final conferma = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Elimina serata'),
                  content: Text('Vuoi eliminare "${widget.serata.titolo}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annulla'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Elimina',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (conferma == true) {
                final serate = await Database.getSerate();
                serate.removeWhere((s) => s.id == widget.serata.id);
                await Database.salvaSerate(serate);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _coloreStato(widget.serata.stato).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.serata.stato,
                style: TextStyle(
                  color: _coloreStato(widget.serata.stato),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informazioni',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _riga(
                    Icons.calendar_today,
                    'Data',
                    _formattaData(widget.serata.data),
                  ),
                  if (widget.serata.luogo.isNotEmpty)
                    _riga(Icons.location_on, 'Luogo', widget.serata.luogo),
                  if (widget.serata.descrizione.isNotEmpty)
                    _riga(
                      Icons.description,
                      'Descrizione',
                      widget.serata.descrizione,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partecipanti (${_giocatori.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_giocatori.isEmpty)
                    const Text(
                      'Nessun partecipante',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._giocatori.map(
                      (g) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6B3FA0),
                          child: Text(
                            g.nome[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(g.nome),
                        subtitle: g.nickname.isNotEmpty
                            ? Text('@${g.nickname}')
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giochi proposti (${_giochi.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_giochi.isEmpty)
                    const Text(
                      'Nessun gioco proposto',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._giochi.map(
                      (g) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6B3FA0),
                          child: Text(
                            g.nome[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(g.nome),
                        subtitle: Text(g.categoria),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.serata.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.serata.note),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _riga(IconData icon, String label, String valore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B3FA0)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Flexible(
            child: Text(
              valore,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
