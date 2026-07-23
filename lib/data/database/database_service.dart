import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recurring_transaction_model.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  static const _storageKey = 'transactions';
  static const _recurringStorageKey = 'recurring_transactions';
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

  Future<void> clearAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_initialBalanceKey, 0);
    
    await prefs.setString(_storageKey, '[]');
    
    await prefs.setString(_recurringStorageKey, '[]');
  }

  Future<List<RecurringTransactionModel>> getAllRecurringTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_recurringStorageKey);

    if (payload == null || payload.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(payload);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => RecurringTransactionModel.fromJson(item))
        .toList();
  }

  Future<void> saveRecurringTransaction(RecurringTransactionModel recurringTransaction) async {
    final recurringTransactions = await getAllRecurringTransactions();
    final updated = [...recurringTransactions, recurringTransaction];

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_recurringStorageKey, payload);
  }

  Future<void> updateRecurringTransaction(RecurringTransactionModel recurringTransaction) async {
    final recurringTransactions = await getAllRecurringTransactions();
    final updated = recurringTransactions.map((item) => item.id == recurringTransaction.id ? recurringTransaction : item).toList();

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_recurringStorageKey, payload);
  }

  Future<void> deleteRecurringTransaction(int id) async {
    final recurringTransactions = await getAllRecurringTransactions();
    final updated = recurringTransactions.where((item) => item.id != id).toList();

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(updated.map((item) => item.toJson()).toList());
    await prefs.setString(_recurringStorageKey, payload);
  }

  Future<void> syncRecurringTransactions() async {
    final recurringTransactions = await getAllRecurringTransactions();
    final transactions = await getAllTransactions();
    final now = DateTime.now();

    for (final recurring in recurringTransactions.where((item) => item.isActive)) {
      if (recurring.nextDueDate.isAfter(now)) {
        continue;
      }

      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch + recurring.id,
        amountInCents: recurring.amountInCents,
        description: recurring.description,
        date: recurring.nextDueDate,
        type: recurring.type,
        categoryName: recurring.categoryName,
      );

      transactions.add(newTransaction);

      DateTime nextDate = recurring.nextDueDate;
      switch (recurring.frequency) {
        case 'weekly':
          nextDate = nextDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
          break;
        default:
          nextDate = nextDate.add(const Duration(days: 1));
      }

      await updateRecurringTransaction(
        recurring.copyWith(nextDueDate: nextDate),
      );
    }

    if (transactions.isNotEmpty) {
      transactions.sort((a, b) => b.date.compareTo(a.date));
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode(transactions.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, payload);
    }
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