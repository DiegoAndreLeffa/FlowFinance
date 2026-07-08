import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static const _storageKey = 'transactions';
  static const _initialBalanceKey = 'initial_balance';

  Future<void> saveTransaction(TransactionModel newTransaction) async {
    final transactions = await getAllTransactions();
    final updated = [...transactions, newTransaction];

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      updated.map((transaction) => transaction.toJson()).toList(),
    );

    await prefs.setString(_storageKey, payload);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_storageKey);

    if (payload == null || payload.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      return [];
    }

    final transactions = decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => TransactionModel.fromJson(item))
        .toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final transactions = await getAllTransactions();
    final updated = transactions.map((item) => item.id == transaction.id ? transaction : item).toList();

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, payload);
  }

  Future<void> deleteTransaction(int id) async {
    final transactions = await getAllTransactions();
    final updated = transactions.where((item) => item.id != id).toList();

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, payload);
  }

  Future<int> getInitialBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_initialBalanceKey) ?? 0;
  }

  Future<void> saveInitialBalance(int amountInCents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_initialBalanceKey, amountInCents);
  }

  Future<String> exportToJson() async {
    final transactions = await getAllTransactions();
    final initialBalance = await getInitialBalance();
    return jsonEncode({
      'initialBalance': initialBalance,
      'transactions': transactions.map((item) => item.toJson()).toList(),
    });
  }

  Future<void> importFromJson(String payload) async {
    final decoded = jsonDecode(payload);

    if (decoded is Map<String, dynamic>) {
      final initialBalance = decoded['initialBalance'] as int? ?? 0;
      final transactionsJson = decoded['transactions'];
      if (transactionsJson is! List) {
        return;
      }

      final transactions = transactionsJson
          .whereType<Map<String, dynamic>>()
          .map((item) => TransactionModel.fromJson(item))
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_initialBalanceKey, initialBalance);
      await prefs.setString(_storageKey, jsonEncode(transactions.map((item) => item.toJson()).toList()));
      return;
    }

    if (decoded is! List) {
      return;
    }

    final transactions = decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => TransactionModel.fromJson(item))
        .toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(transactions.map((item) => item.toJson()).toList()));
  }
}