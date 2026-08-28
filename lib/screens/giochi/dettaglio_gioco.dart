import 'package:flutter/material.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';
import 'aggiungi_gioco.dart';

class DettaglioGioco extends StatelessWidget {
  final Gioco gioco;
  const DettaglioGioco({super.key, required this.gioco});

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
        title: Text(gioco.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AggiungiGioco(gioco: gioco)),
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
                  title: const Text('Elimina gioco'),
                  content: Text('Vuoi eliminare "${gioco.nome}"?'),
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
                final giochi = await Database.getGiochi();
                giochi.removeWhere((g) => g.id == gioco.id);
                await Database.salvaGiochi(giochi);
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
                gioco.nome[0].toUpperCase(),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _coloreStato(gioco.stato).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                gioco.stato,
                style: TextStyle(
                  color: _coloreStato(gioco.stato),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (gioco.descrizione.isNotEmpty) ...[
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
                      'Descrizione',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(gioco.descrizione),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                    'Dettagli',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _riga(
                    Icons.category,
                    'Categoria',
                    gioco.categoria.isEmpty
                        ? 'Non specificata'
                        : gioco.categoria,
                  ),
                  _riga(
                    Icons.people,
                    'Giocatori',
                    '${gioco.minGiocatori} - ${gioco.maxGiocatori}',
                  ),
                  _riga(Icons.timer, 'Durata', '${gioco.durata} minuti'),
                  _riga(Icons.psychology, 'Difficoltà', gioco.difficolta),
                ],
              ),
            ),
          ),
          if (gioco.note.isNotEmpty) ...[
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
                    Text(gioco.note),
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
          Text(valore, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
