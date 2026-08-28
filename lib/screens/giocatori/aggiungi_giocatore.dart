import 'package:flutter/material.dart';
import '../../models/giocatore.dart';
import '../../data/database.dart';
import '../../models/gioco.dart';
import '../../data/database.dart';

class AggiungiGiocatore extends StatefulWidget {
  final Giocatore? giocatore;
  const AggiungiGiocatore({super.key, this.giocatore});

  @override
  State<AggiungiGiocatore> createState() => _AggiungiGiocatoreState();
}

class _AggiungiGiocatoreState extends State<AggiungiGiocatore> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _noteController = TextEditingController();
  String _livelloEsperienza = 'Principiante';

  final List<String> _livelli = ['Principiante', 'Intermedio', 'Esperto'];

  // Elenco dei giocatori già esistenti, usato per controllare i duplicati
  // di nome e nickname mentre l'utente compila il form.
  List<Giocatore> _giocatoriEsistenti = [];
  List<String> _giochiPreferitiIds = [];
  List<Gioco> _tuttiGiochi = [];

  @override
  void initState() {
    super.initState();
    if (widget.giocatore != null) {
      _nomeController.text = widget.giocatore!.nome;
      _nicknameController.text = widget.giocatore!.nickname;
      _noteController.text = widget.giocatore!.note;
      _livelloEsperienza = widget.giocatore!.livelloEsperienza;
    }
    _caricaGiocatoriEsistenti();
    _caricaGiochi();
    if (widget.giocatore != null) {
      _giochiPreferitiIds = List.from(widget.giocatore!.giochiPreferitiIds);
    }
  }

  Future<void> _caricaGiocatoriEsistenti() async {
    final lista = await Database.getGiocatori();
    if (mounted) {
      setState(() {
        _giocatoriEsistenti = lista;
      });
    }
  }

  Future<void> _caricaGiochi() async {
    final giochi = await Database.getGiochi();
    setState(() => _tuttiGiochi = giochi);
  }

  /// Restituisce un messaggio di errore se [nome] o [nickname] sono già
  /// usati da un altro giocatore presente in [lista]; altrimenti null.
  /// Il confronto ignora maiuscole/minuscole e spazi iniziali/finali.
  /// Il giocatore che si sta eventualmente modificando viene escluso dal
  /// controllo (così può essere salvato senza cambiare nome/nickname).
  String? _erroreDuplicato(List<Giocatore> lista) {
    final nome = _nomeController.text.trim().toLowerCase();
    final nickname = _nicknameController.text.trim().toLowerCase();
    final idCorrente = widget.giocatore?.id;

    final nomeDuplicato = lista.any(
      (g) => g.id != idCorrente && g.nome.trim().toLowerCase() == nome,
    );
    if (nome.isNotEmpty && nomeDuplicato) {
      return 'Esiste già un giocatore con questo nome';
    }

    if (nickname.isNotEmpty) {
      final nicknameDuplicato = lista.any(
        (g) =>
            g.id != idCorrente && g.nickname.trim().toLowerCase() == nickname,
      );
      if (nicknameDuplicato) {
        return 'Esiste già un giocatore con questo nickname';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nicknameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _salva() async {
    if (!_formKey.currentState!.validate()) return;
    final giocatori = await Database.getGiocatori();

    // Controlla nickname duplicato
    final nicknameTaken = giocatori.any(
      (g) =>
          g.nickname.toLowerCase() ==
              _nicknameController.text.trim().toLowerCase() &&
          g.id != (widget.giocatore?.id ?? ''),
    );

    if (nicknameTaken && _nicknameController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Questo nickname è già usato da un altro giocatore!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Controlla nome duplicato
    final nomeTaken = giocatori.any(
      (g) =>
          g.nome.toLowerCase() == _nomeController.text.trim().toLowerCase() &&
          g.id != (widget.giocatore?.id ?? ''),
    );

    if (nomeTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esiste già un giocatore con questo nome!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.giocatore != null) {
      final index = giocatori.indexWhere((g) => g.id == widget.giocatore!.id);
      if (index != -1) {
        giocatori[index] = Giocatore(
          id: widget.giocatore!.id,
          nome: _nomeController.text.trim(),
          nickname: _nicknameController.text.trim(),
          livelloEsperienza: _livelloEsperienza,
          note: _noteController.text.trim(),
          giochiPreferitiIds: _giochiPreferitiIds,
        );
      }
    } else {
      giocatori.add(
        Giocatore(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          nome: _nomeController.text.trim(),
          nickname: _nicknameController.text.trim(),
          livelloEsperienza: _livelloEsperienza,
          note: _noteController.text.trim(),
          giochiPreferitiIds: _giochiPreferitiIds,
        ),
      );
    }
    await Database.salvaGiocatori(giocatori);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isModifica = widget.giocatore != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isModifica ? 'Modifica giocatore' : 'Nuovo giocatore'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Inserisci il nome';
                return _erroreDuplicato(_giocatoriEsistenti);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.alternate_email),
              ),
              validator: (v) {
                // Il nickname resta facoltativo: se vuoto non serve
                // controllare i duplicati (il controllo sul nome, sopra,
                // basta a validare il form).
                if (v == null || v.trim().isEmpty) return null;
                final errore = _erroreDuplicato(_giocatoriEsistenti);
                if (errore != null && errore.contains('nickname')) {
                  return errore;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _livelloEsperienza,
              decoration: InputDecoration(
                labelText: 'Livello esperienza',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.stars),
              ),
              items: _livelli
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _livelloEsperienza = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.note),
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
                      'Giochi preferiti',
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
                          value: _giochiPreferitiIds.contains(g.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _giochiPreferitiIds.add(g.id);
                              } else {
                                _giochiPreferitiIds.remove(g.id);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _salva,
              icon: const Icon(Icons.save),
              label: Text(
                isModifica ? 'Salva modifiche' : 'Aggiungi giocatore',
              ),
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
