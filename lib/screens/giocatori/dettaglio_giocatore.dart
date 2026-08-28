import 'package:flutter/material.dart';
import '../../models/giocatore.dart';
import '../../data/database.dart';
import 'aggiungi_giocatore.dart';

class DettaglioGiocatore extends StatelessWidget {
  final Giocatore giocatore;
  const DettaglioGiocatore({super.key, required this.giocatore});

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
      appBar: AppBar(
        title: Text(giocatore.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AggiungiGiocatore(giocatore: giocatore),
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
                  title: const Text('Elimina giocatore'),
                  content: Text('Vuoi eliminare "${giocatore.nome}"?'),
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
                final giocatori = await Database.getGiocatori();
                giocatori.removeWhere((g) => g.id == giocatore.id);
                await Database.salvaGiocatori(giocatori);
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
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF6B3FA0),
              child: Text(
                giocatore.nome[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              giocatore.nickname.isEmpty
                  ? giocatore.nome
                  : '@${giocatore.nickname}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _coloreEsperienza(
                  giocatore.livelloEsperienza,
                ).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                giocatore.livelloEsperienza,
                style: TextStyle(
                  color: _coloreEsperienza(giocatore.livelloEsperienza),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (giocatore.giochiPreferitiIds.isNotEmpty) ...[
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
                      'Giochi preferiti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<dynamic>>(
                      future: Database.getGiochi(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const CircularProgressIndicator();
                        final giochi = snapshot.data!
                            .where(
                              (g) =>
                                  giocatore.giochiPreferitiIds.contains(g.id),
                            )
                            .toList();
                        return Column(
                          children: giochi
                              .map(
                                (g) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF1A237E),
                                    child: Text(
                                      g.nome[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(g.nome),
                                  subtitle: Text(g.categoria),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (giocatore.note.isNotEmpty)
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
                    Text(giocatore.note),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
