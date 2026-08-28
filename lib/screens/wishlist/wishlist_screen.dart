import 'package:flutter/material.dart';
import '../../data/database.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Map<String, dynamic>> _elementi = [];
  String _filtroTipo = 'Tutti';

  final List<String> _tipi = [
    'Tutti',
    'Da acquistare',
    'Da provare',
    'Preferiti',
    'Prestato',
    'Checklist',
  ];

  @override
  void initState() {
    super.initState();
    _caricaElementi();
  }

  Future<void> _caricaElementi() async {
    final elementi = await Database.getWishlist();
    setState(() => _elementi = elementi);
  }

  List<Map<String, dynamic>> get _elementiFiltrati {
    if (_filtroTipo == 'Tutti') return _elementi;
    return _elementi.where((e) => e['tipo'] == _filtroTipo).toList();
  }

  Future<void> _aggiungiElemento() async {
    final titoloController = TextEditingController();
    String tipoSelezionato = 'Da acquistare';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nuovo elemento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titoloController,
                decoration: InputDecoration(
                  labelText: 'Titolo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoSelezionato,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _tipi
                    .where((t) => t != 'Tutti')
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => tipoSelezionato = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titoloController.text.trim().isEmpty) return;
                final elementi = await Database.getWishlist();
                elementi.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'titolo': titoloController.text.trim(),
                  'tipo': tipoSelezionato,
                  'completato': false,
                });
                await Database.salvaWishlist(elementi);
                await _caricaElementi();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _modificaElemento(Map<String, dynamic> elemento) async {
    final titoloController = TextEditingController(text: elemento['titolo']);
    String tipoSelezionato = elemento['tipo'];
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Modifica elemento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titoloController,
                decoration: InputDecoration(
                  labelText: 'Titolo *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoSelezionato,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _tipi
                    .where((t) => t != 'Tutti')
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => tipoSelezionato = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titoloController.text.trim().isEmpty) return;
                final elementi = await Database.getWishlist();
                final index = elementi.indexWhere(
                  (e) => e['id'] == elemento['id'],
                );
                if (index != -1) {
                  elementi[index]['titolo'] = titoloController.text.trim();
                  elementi[index]['tipo'] = tipoSelezionato;
                  await Database.salvaWishlist(elementi);
                  await _caricaElementi();
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCompletato(Map<String, dynamic> elemento) async {
    final elementi = await Database.getWishlist();
    final index = elementi.indexWhere((e) => e['id'] == elemento['id']);
    if (index != -1) {
      elementi[index]['completato'] = !elementi[index]['completato'];
      await Database.salvaWishlist(elementi);
      _caricaElementi();
    }
  }

  Future<void> _eliminaElemento(Map<String, dynamic> elemento) async {
    final elementi = await Database.getWishlist();
    elementi.removeWhere((e) => e['id'] == elemento['id']);
    await Database.salvaWishlist(elementi);
    _caricaElementi();
  }

  IconData _iconaTipo(String tipo) {
    switch (tipo) {
      case 'Da acquistare':
        return Icons.shopping_cart;
      case 'Da provare':
        return Icons.play_circle;
      case 'Preferiti':
        return Icons.star;
      case 'Prestato':
        return Icons.swap_horiz;
      case 'Checklist':
        return Icons.checklist;
      default:
        return Icons.list;
    }
  }

  Color _coloreTipo(String tipo) {
    switch (tipo) {
      case 'Da acquistare':
        return Colors.blue;
      case 'Da provare':
        return Colors.purple;
      case 'Preferiti':
        return Colors.amber;
      case 'Prestato':
        return Colors.orange;
      case 'Checklist':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist & Checklist'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filtroTipo = value);
            },
            itemBuilder: (context) => _tipi
                .map((t) => PopupMenuItem(value: t, child: Text(t)))
                .toList(),
          ),
        ],
      ),
      body: _elementiFiltrati.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessun elemento',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aggiungi giochi alla wishlist!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _elementiFiltrati.length,
              itemBuilder: (context, index) {
                final elemento = _elementiFiltrati[index];
                final completato = elemento['completato'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: _coloreTipo(
                        elemento['tipo'],
                      ).withOpacity(0.2),
                      child: Icon(
                        _iconaTipo(elemento['tipo']),
                        color: _coloreTipo(elemento['tipo']),
                      ),
                    ),
                    title: Text(
                      elemento['titolo'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: completato
                            ? TextDecoration.lineThrough
                            : null,
                        color: completato ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Text(elemento['tipo']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                          onPressed: () => _modificaElemento(elemento),
                        ),
                        IconButton(
                          icon: Icon(
                            completato
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: completato ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleCompletato(elemento),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _eliminaElemento(elemento),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _aggiungiElemento,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
      ),
    );
  }
}
