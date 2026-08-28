import 'package:flutter/material.dart';
import '../../models/partita.dart';
import '../../models/gioco.dart';
import '../../models/giocatore.dart';
import '../../data/database.dart';
import 'aggiungi_partita.dart';

class DettaglioPartita extends StatefulWidget {
  final Partita partita;
  const DettaglioPartita({super.key, required this.partita});

  @override
  State<DettaglioPartita> createState() => _DettaglioPartitaState();
}

class _DettaglioPartitaState extends State<DettaglioPartita> {
  Gioco? _gioco;
  List<Giocatore> _giocatori = [];
  Giocatore? _vincitore;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  Future<void> _caricaDati() async {
    final giochi = await Database.getGiochi();
    final giocatori = await Database.getGiocatori();
    setState(() {
      _gioco = giochi.where((g) => g.id == widget.partita.giocoId).firstOrNull;
      _giocatori = giocatori
          .where((g) => widget.partita.giocatoriIds.contains(g.id))
          .toList();
      _vincitore = giocatori
          .where((g) => g.id == widget.partita.vincitoreId)
          .firstOrNull;
    });
  }

  String _formattaData(DateTime data) =>
      '${data.day}/${data.month}/${data.year}';

  Widget _stelle(int valutazione) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < valutazione ? Icons.star : Icons.star_outline,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gioco?.nome ?? 'Dettaglio partita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AggiungiPartita(partita: widget.partita),
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
                  title: const Text('Elimina partita'),
                  content: const Text('Vuoi eliminare questa partita?'),
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
                final partite = await Database.getPartite();
                partite.removeWhere((p) => p.id == widget.partita.id);
                await Database.salvaPartite(partite);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info principali
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
                  _riga(Icons.games, 'Gioco', _gioco?.nome ?? 'Sconosciuto'),
                  _riga(
                    Icons.calendar_today,
                    'Data',
                    _formattaData(widget.partita.data),
                  ),
                  if (widget.partita.durata > 0)
                    _riga(
                      Icons.timer,
                      'Durata',
                      '${widget.partita.durata} minuti',
                    ),
                  if (widget.partita.valutazione > 0) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Valutazione',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    _stelle(widget.partita.valutazione),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Vincitore
          if (_vincitore != null)
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
                      'Vincitore',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1A237E),
                          child: Text(
                            _vincitore!.nome[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _vincitore!.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Giocatori e punteggi
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
                    'Giocatori (${_giocatori.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_giocatori.isEmpty)
                    const Text(
                      'Nessun giocatore',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._giocatori.map((g) {
                      final punteggio = widget.partita.punteggi[g.id] ?? 0;
                      final isVincitore = g.id == widget.partita.vincitoreId;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isVincitore
                                  ? Colors.amber
                                  : const Color(0xFF1A237E),
                              child: Text(
                                g.nome[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(g.nome)),
                            if (isVincitore)
                              const Text('🏆 ', style: TextStyle(fontSize: 16)),
                            Text(
                              '$punteggio pt',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isVincitore
                                    ? Colors.amber
                                    : const Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Note
          if (widget.partita.note.isNotEmpty) ...[
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
                    Text(widget.partita.note),
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
          Icon(icon, size: 20, color: const Color(0xFF1A237E)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(valore, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
