/// Drift schema — everything local, per the zero-server constraint.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// The standing shopping list you take into the store. One active list;
/// items persist between trips (staples stay, one-offs get removed).
class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get rawText => text()();
  TextColumn get normalizedText => text()();
  RealColumn get estPrice => real().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Signed scorecards. Verdict wording is FROZEN at sign-time — a ledger
/// entry scored under football stays a FUMBLE forever, whatever sport the
/// user picks next.
class LedgerEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get hole => integer()();
  DateTimeColumn get scoredAt => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real()();
  IntColumn get par => integer()();
  TextColumn get verdictName => text()();
  IntColumn get strokes => integer()();
  IntColumn get tier => integer()();
  TextColumn get headline => text()();
  TextColumn get quote => text()();
  TextColumn get sportKey => text()();
  TextColumn get tripWord => text()();
  TextColumn get parWord => text()();
  BoolColumn get mulliganUsed => boolean().withDefault(const Constant(false))();
  BoolColumn get hotDog => boolean().withDefault(const Constant(false))();
  RealColumn get impulseDollars => real().withDefault(const Constant(0))();
}

/// Raw scans kept for the parser corpus (open item #1 in the spec).
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ledgerEntryId => integer().nullable()();
  TextColumn get ocrRawText => text()();
  DateTimeColumn get parsedAt => dateTime().withDefault(currentDateAndTime)();
  RealColumn get subtotal => real().nullable()();
  RealColumn get total => real().nullable()();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
}

/// Real prices learned from signed trips — the app teaches itself what your
/// warehouse actually charges, so list prices auto-fill. On-device only.
class LearnedPrices extends Table {
  TextColumn get normalizedName => text()();
  RealColumn get price => real()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {normalizedName};
}

/// Confirmed abbreviation → plain-English mappings, learned from scan fixes.
class LearnedAliases extends Table {
  TextColumn get receiptToken => text()();
  TextColumn get plainText => text()();

  @override
  Set<Column> get primaryKey => {receiptToken};
}

class KeyValueSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  ListItems,
  LedgerEntries,
  Receipts,
  LearnedPrices,
  LearnedAliases,
  KeyValueSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'costgo'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(learnedPrices);
          }
        },
      );
}
