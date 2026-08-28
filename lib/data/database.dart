import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gioco.dart';
import '../models/giocatore.dart';
import '../models/serata.dart';
import '../models/partita.dart';

class Database {
  // ─── GIOCHI ───────────────────────────────────────────────
  static Future<List<Gioco>> getGiochi() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('giochi') ?? [];
    return data.map((e) => Gioco.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> salvaGiochi(List<Gioco> giochi) async {
    final prefs = await SharedPreferences.getInstance();
    final data = giochi.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('giochi', data);
  }

  // ─── GIOCATORI ────────────────────────────────────────────
  static Future<List<Giocatore>> getGiocatori() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('giocatori') ?? [];
    return data.map((e) => Giocatore.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> salvaGiocatori(List<Giocatore> giocatori) async {
    final prefs = await SharedPreferences.getInstance();
    final data = giocatori.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('giocatori', data);
  }

  // ─── SERATE ───────────────────────────────────────────────
  static Future<List<Serata>> getSerate() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('serate') ?? [];
    return data.map((e) => Serata.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> salvaSerate(List<Serata> serate) async {
    final prefs = await SharedPreferences.getInstance();
    final data = serate.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('serate', data);
  }

  // ─── PARTITE ──────────────────────────────────────────────
  static Future<List<Partita>> getPartite() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('partite') ?? [];
    return data.map((e) => Partita.fromMap(jsonDecode(e))).toList();
  }

  static Future<void> salvaPartite(List<Partita> partite) async {
    final prefs = await SharedPreferences.getInstance();
    final data = partite.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('partite', data);
  }

  // ─── WISHLIST ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('wishlist') ?? [];
    return data.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> salvaWishlist(List<Map<String, dynamic>> wishlist) async {
    final prefs = await SharedPreferences.getInstance();
    final data = wishlist.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('wishlist', data);
  }
}
