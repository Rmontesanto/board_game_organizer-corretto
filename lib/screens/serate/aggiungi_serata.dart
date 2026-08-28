import 'package:flutter/material.dart';
import '../../models/serata.dart';
import '../../models/giocatore.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';

class AggiungiSerata extends StatefulWidget {
  final Serata? serata;
  const AggiungiSerata({super.key, this.serata});

  @override
  State<AggiungiSerata> createState() => _AggiungiSerataState();
}

class _AggiungiSerataState extends State<AggiungiSerata> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _luogoController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _data = DateTime.now();
  String _stato = 'Futura';
  List<String> _partecipantiIds = [];
  List<String> _giochiIds = [];
  List<Giocatore> _tuttiGiocatori = [];
  List<Gioco> _tuttiGiochi = [];

  final List<String> _stati = ['Futura', 'Completata', 'Annullata'];

  @override
  void initState() {
    super.initState();
    _caricaDati();
    if (widget.serata != null) {
      _titoloController.text = widget.serata!.titolo;
      _luogoController.text = widget.serata!.luogo;
      _descrizioneController.text = widget.serata!.descrizione;
      _noteController.text = widget.serata!.note;
      _data = widget.serata!.data;
      _stato = widget.serata!.stato;
      _partecipantiIds = List.from(widget.serata!.partecipantiIds);
      _giochiIds = List.from(widget.serata!.giochiIds);
    }
  }

  Future<void> _caricaDati() async {
    final giocatori = await Database.getGiocatori();
    final giochi = await Database.getGiochi();
    setState(() {
      _tuttiGiocatori = giocatori;
      _tuttiGiochi = giochi;
    });
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _luogoController.dispose();
    _descrizioneController.dispose();
    _noteController.dispose();
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
    final serate = await Database.getSerate();
    if (widget.serata != null) {
      final index = serate.indexWhere((s) => s.id == widget.serata!.id);
      if (index != -1) {
        serate[index] = Serata(
          id: widget.serata!.id,
          titolo: _titoloController.text.trim(),
          data: _data,
          luogo: _luogoController.text.trim(),
          descrizione: _descrizioneController.text.trim(),
          partecipantiIds: _partecipantiIds,
          giochiIds: _giochiIds,
          stato: _stato,
          note: _noteController.text.trim(),
        );
      }
    } else {
      serate.add(
        Serata(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titolo: _titoloController.text.trim(),
          data: _data,
          luogo: _luogoController.text.trim(),
          descrizione: _descrizioneController.text.trim(),
          partecipantiIds: _partecipantiIds,
          giochiIds: _giochiIds,
          stato: _stato,
          note: _noteController.text.trim(),
        ),
      );
    }
    await Database.salvaSerate(serate);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isModifica = widget.serata != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isModifica ? 'Modifica serata' : 'Nuova serata'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titoloController,
              decoration: InputDecoration(
                labelText: 'Titolo *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Inserisci il titolo' : null,
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
            TextFormField(
              controller: _luogoController,
              decoration: InputDecoration(
                labelText: 'Luogo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _stato,
              decoration: InputDecoration(
                labelText: 'Stato',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.info),
              ),
              items: _stati
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _stato = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descrizioneController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
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
                      'Partecipanti',
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
                          subtitle: g.nickname.isNotEmpty
                              ? Text('@${g.nickname}')
                              : null,
                          value: _partecipantiIds.contains(g.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _partecipantiIds.add(g.id);
                              } else {
                                _partecipantiIds.remove(g.id);
                              }
                            });
                          },
                        ),
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
                      'Giochi proposti',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_tuttiGiochi.isEmpty)
                      const Text(
                        'Nessun gioco disponibile',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      ..._tuttiGiochi.map(
                        (g) => CheckboxListTile(
                          title: Text(g.nome),
                          subtitle: Text(g.categoria),
                          value: _giochiIds.contains(g.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _giochiIds.add(g.id);
                              } else {
                                _giochiIds.remove(g.id);
                              }
                            });
                          },
                        ),
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
                labelText: 'Note organizzative',
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
              label: Text(isModifica ? 'Salva modifiche' : 'Crea serata'),
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
