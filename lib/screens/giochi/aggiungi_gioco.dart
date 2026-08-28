import 'package:flutter/material.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';

class AggiungiGioco extends StatefulWidget {
  final Gioco? gioco;
  const AggiungiGioco({super.key, this.gioco});

  @override
  State<AggiungiGioco> createState() => _AggiungiGiocoState();
}

class _AggiungiGiocoState extends State<AggiungiGioco> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _noteController = TextEditingController();
  String _categoria = 'Strategia';
  String _difficolta = 'Media';
  String _stato = 'Posseduto';
  int _minGiocatori = 2;
  int _maxGiocatori = 4;
  int _durata = 60;
  int _etaConsigliata = 8;

  final List<String> _categorie = [
    'Strategia',
    'Famiglia',
    'Cooperativo',
    'Party',
    'Carte',
    'Dadi',
    'Avventura',
    'Altro',
  ];
  final List<String> _difficolta_list = [
    'Facile',
    'Media',
    'Difficile',
    'Esperto',
  ];
  final List<String> _stati = [
    'Posseduto',
    'Wishlist',
    'Prestato',
    'Da provare',
  ];
  final List<int> _eta = [3, 6, 8, 10, 12, 14, 16, 18];

  @override
  void initState() {
    super.initState();
    if (widget.gioco != null) {
      _nomeController.text = widget.gioco!.nome;
      _descrizioneController.text = widget.gioco!.descrizione;
      _noteController.text = widget.gioco!.note;
      _categoria = widget.gioco!.categoria.isEmpty
          ? 'Strategia'
          : widget.gioco!.categoria;
      _difficolta = widget.gioco!.difficolta;
      _stato = widget.gioco!.stato;
      _minGiocatori = widget.gioco!.minGiocatori;
      _maxGiocatori = widget.gioco!.maxGiocatori;
      _durata = widget.gioco!.durata;
      _etaConsigliata = widget.gioco?.etaConsigliata ?? 8;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descrizioneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;
    final giochi = await Database.getGiochi();

    // Controlla nome duplicato
    final nomeTaken = giochi.any(
      (g) =>
          g.nome.toLowerCase() == _nomeController.text.trim().toLowerCase() &&
          g.id != (widget.gioco?.id ?? ''),
    );

    if (nomeTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esiste già un gioco con questo nome!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.gioco != null) {
      final index = giochi.indexWhere((g) => g.id == widget.gioco!.id);
      if (index != -1) {
        giochi[index] = Gioco(
          id: widget.gioco!.id,
          nome: _nomeController.text.trim(),
          descrizione: _descrizioneController.text.trim(),
          categoria: _categoria,
          minGiocatori: _minGiocatori,
          maxGiocatori: _maxGiocatori,
          durata: _durata,
          difficolta: _difficolta,
          stato: _stato,
          note: _noteController.text.trim(),
          etaConsigliata: _etaConsigliata,
        );
      }
    } else {
      giochi.add(
        Gioco(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text.trim(),
          descrizione: _descrizioneController.text.trim(),
          categoria: _categoria,
          minGiocatori: _minGiocatori,
          maxGiocatori: _maxGiocatori,
          durata: _durata,
          difficolta: _difficolta,
          stato: _stato,
          note: _noteController.text.trim(),
          etaConsigliata: _etaConsigliata,
        ),
      );
    }
    await Database.salvaGiochi(giochi);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isModifica = widget.gioco != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isModifica ? 'Modifica gioco' : 'Nuovo gioco'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _etaConsigliata,
              decoration: InputDecoration(
                labelText: 'Età consigliata',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.child_care),
              ),
              items: [3, 6, 8, 10, 12, 14, 16, 18]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e+')))
                  .toList(),
              onChanged: (v) => setState(() => _etaConsigliata = v!),
            ),
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome gioco *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.games),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Inserisci il nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descrizioneController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categorie
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _difficolta,
                    decoration: InputDecoration(
                      labelText: 'Difficoltà',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _difficolta_list
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _difficolta = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stato,
                    decoration: InputDecoration(
                      labelText: 'Stato',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _stati
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _stato = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      'Numero giocatori',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Min: '),
                        Expanded(
                          child: Slider(
                            value: _minGiocatori.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _minGiocatori.toString(),
                            onChanged: (v) =>
                                setState(() => _minGiocatori = v.toInt()),
                          ),
                        ),
                        Text('$_minGiocatori'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Max:'),
                        Expanded(
                          child: Slider(
                            value: _maxGiocatori.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _maxGiocatori.toString(),
                            onChanged: (v) =>
                                setState(() => _maxGiocatori = v.toInt()),
                          ),
                        ),
                        Text('$_maxGiocatori'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      'Durata stimata (minuti)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _durata.toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 29,
                            label: '$_durata min',
                            onChanged: (v) =>
                                setState(() => _durata = v.toInt()),
                          ),
                        ),
                        Text('$_durata min'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salva,
              icon: const Icon(Icons.save),
              label: Text(isModifica ? 'Salva modifiche' : 'Aggiungi gioco'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
