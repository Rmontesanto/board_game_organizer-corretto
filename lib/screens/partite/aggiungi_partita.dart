import 'package:flutter/material.dart';
import '../../models/partita.dart';
import '../../models/gioco.dart';
import '../../models/giocatore.dart';
import '../../models/serata.dart';
import '../../data/database.dart';

class AggiungiPartita extends StatefulWidget {
  final Partita? partita;
  const AggiungiPartita({super.key, this.partita});

  @override
  State<AggiungiPartita> createState() => _AggiungiPartitaState();
}

class _AggiungiPartitaState extends State<AggiungiPartita> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final _durataController = TextEditingController();
  DateTime _data = DateTime.now();
  String? _giocoId;
  String? _serataId;
  String _vincitoreId = '';
  List<String> _giocatoriIds = [];
  Map<String, int> _punteggi = {};
  List<Gioco> _tuttiGiochi = [];
  List<Giocatore> _tuttiGiocatori = [];
  List<Serata> _tutteSerate = [];
  int _valutazione = 0;

  @override
  void initState() {
    super.initState();
    _caricaDati();
    if (widget.partita != null) {
      _giocoId = widget.partita!.giocoId;
      _serataId = widget.partita!.serataId.isEmpty
          ? null
          : widget.partita!.serataId;
      _data = widget.partita!.data;
      _giocatoriIds = List.from(widget.partita!.giocatoriIds);
      _punteggi = Map.from(widget.partita!.punteggi);
      _vincitoreId = widget.partita!.vincitoreId;
      _noteController.text = widget.partita!.note;
      _durataController.text = widget.partita!.durata.toString();
      _valutazione = widget.partita?.valutazione ?? 0;
    }
  }

  Future<void> _caricaDati() async {
    final giochi = await Database.getGiochi();
    final giocatori = await Database.getGiocatori();
    final serate = await Database.getSerate();
    setState(() {
      _tuttiGiochi = giochi;
      _tuttiGiocatori = giocatori;
      _tutteSerate = serate;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _durataController.dispose();
    super.dispose();
  }

  Future<void> _selezionaData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) setState(() => _data = data);
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;
    if (_giocoId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleziona un gioco!')));
      return;
    }
    final partite = await Database.getPartite();
    final nuovaPartita = Partita(
      id:
          widget.partita?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      giocoId: _giocoId!,
      serataId: _serataId ?? '',
      data: _data,
      giocatoriIds: _giocatoriIds,
      punteggi: _punteggi,
      vincitoreId: _vincitoreId,
      durata: int.tryParse(_durataController.text) ?? 0,
      note: _noteController.text.trim(),
      valutazione: _valutazione,
    );
    if (widget.partita != null) {
      final index = partite.indexWhere((p) => p.id == widget.partita!.id);
      if (index != -1) partite[index] = nuovaPartita;
    } else {
      partite.add(nuovaPartita);
    }
    await Database.salvaPartite(partite);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isModifica = widget.partita != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isModifica ? 'Modifica partita' : 'Nuova partita'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _giocoId,
              decoration: InputDecoration(
                labelText: 'Gioco *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.games),
              ),
              hint: const Text('Seleziona un gioco'),
              items: _tuttiGiochi
                  .map(
                    (g) => DropdownMenuItem(value: g.id, child: Text(g.nome)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _giocoId = v),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selezionaData,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text('${_data.day}/${_data.month}/${_data.year}'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _serataId,
              decoration: InputDecoration(
                labelText: 'Serata associata (opzionale)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event),
              ),
              hint: const Text('Nessuna serata'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Nessuna serata'),
                ),
                ..._tutteSerate.map(
                  (s) => DropdownMenuItem(value: s.id, child: Text(s.titolo)),
                ),
              ],
              onChanged: (v) => setState(() => _serataId = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durataController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Durata (minuti)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.timer),
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
                      'Giocatori partecipanti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_tuttiGiocatori.isEmpty)
                      const Text(
                        'Nessun giocatore disponibile',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._tuttiGiocatori.map(
                        (g) => CheckboxListTile(
                          title: Text(g.nome),
                          value: _giocatoriIds.contains(g.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _giocatoriIds.add(g.id);
                              } else {
                                _giocatoriIds.remove(g.id);
                                _punteggi.remove(g.id);
                                if (_vincitoreId == g.id) {
                                  _vincitoreId = '';
                                }
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_giocatoriIds.isNotEmpty) ...[
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
                        'Punteggi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._giocatoriIds.map((id) {
                        final giocatore = _tuttiGiocatori
                            .where((g) => g.id == id)
                            .firstOrNull;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(giocatore?.nome ?? 'Sconosciuto'),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  initialValue:
                                      _punteggi[id]?.toString() ?? '0',
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  onChanged: (v) {
                                    _punteggi[id] = int.tryParse(v) ?? 0;
                                  },
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
                        'Vincitore',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._giocatoriIds.map((id) {
                        final giocatore = _tuttiGiocatori
                            .where((g) => g.id == id)
                            .firstOrNull;
                        return RadioListTile<String>(
                          title: Text(giocatore?.nome ?? 'Sconosciuto'),
                          value: id,
                          groupValue: _vincitoreId,
                          onChanged: (v) =>
                              setState(() => _vincitoreId = v ?? ''),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
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
                      'Valutazione partita',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _valutazione
                                ? Icons.star
                                : Icons.star_outline,
                            color: Colors.amber,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _valutazione = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    Center(
                      child: Text(
                        _valutazione == 0
                            ? 'Nessuna valutazione'
                            : _valutazione == 1
                            ? '⭐ Pessima'
                            : _valutazione == 2
                            ? '⭐⭐ Sufficiente'
                            : _valutazione == 3
                            ? '⭐⭐⭐ Buona'
                            : _valutazione == 4
                            ? '⭐⭐⭐⭐ Ottima'
                            : '⭐⭐⭐⭐⭐ Eccellente',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _salva,
              icon: const Icon(Icons.save),
              label: Text(isModifica ? 'Salva modifiche' : 'Registra partita'),
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
