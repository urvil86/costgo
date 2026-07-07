// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ListItemsTable extends ListItems
    with TableInfo<$ListItemsTable, ListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedTextMeta =
      const VerificationMeta('normalizedText');
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
      'normalized_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _estPriceMeta =
      const VerificationMeta('estPrice');
  @override
  late final GeneratedColumn<double> estPrice = GeneratedColumn<double>(
      'est_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, rawText, normalizedText, estPrice, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_items';
  @override
  VerificationContext validateIntegrity(Insertable<ListItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
          _normalizedTextMeta,
          normalizedText.isAcceptableOrUnknown(
              data['normalized_text']!, _normalizedTextMeta));
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('est_price')) {
      context.handle(_estPriceMeta,
          estPrice.isAcceptableOrUnknown(data['est_price']!, _estPriceMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      normalizedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_text'])!,
      estPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}est_price'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $ListItemsTable createAlias(String alias) {
    return $ListItemsTable(attachedDatabase, alias);
  }
}

class ListItem extends DataClass implements Insertable<ListItem> {
  final int id;
  final String rawText;
  final String normalizedText;
  final double estPrice;
  final int sortOrder;
  const ListItem(
      {required this.id,
      required this.rawText,
      required this.normalizedText,
      required this.estPrice,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['raw_text'] = Variable<String>(rawText);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['est_price'] = Variable<double>(estPrice);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ListItemsCompanion toCompanion(bool nullToAbsent) {
    return ListItemsCompanion(
      id: Value(id),
      rawText: Value(rawText),
      normalizedText: Value(normalizedText),
      estPrice: Value(estPrice),
      sortOrder: Value(sortOrder),
    );
  }

  factory ListItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListItem(
      id: serializer.fromJson<int>(json['id']),
      rawText: serializer.fromJson<String>(json['rawText']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      estPrice: serializer.fromJson<double>(json['estPrice']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rawText': serializer.toJson<String>(rawText),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'estPrice': serializer.toJson<double>(estPrice),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ListItem copyWith(
          {int? id,
          String? rawText,
          String? normalizedText,
          double? estPrice,
          int? sortOrder}) =>
      ListItem(
        id: id ?? this.id,
        rawText: rawText ?? this.rawText,
        normalizedText: normalizedText ?? this.normalizedText,
        estPrice: estPrice ?? this.estPrice,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  ListItem copyWithCompanion(ListItemsCompanion data) {
    return ListItem(
      id: data.id.present ? data.id.value : this.id,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      estPrice: data.estPrice.present ? data.estPrice.value : this.estPrice,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListItem(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('estPrice: $estPrice, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rawText, normalizedText, estPrice, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListItem &&
          other.id == this.id &&
          other.rawText == this.rawText &&
          other.normalizedText == this.normalizedText &&
          other.estPrice == this.estPrice &&
          other.sortOrder == this.sortOrder);
}

class ListItemsCompanion extends UpdateCompanion<ListItem> {
  final Value<int> id;
  final Value<String> rawText;
  final Value<String> normalizedText;
  final Value<double> estPrice;
  final Value<int> sortOrder;
  const ListItemsCompanion({
    this.id = const Value.absent(),
    this.rawText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.estPrice = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ListItemsCompanion.insert({
    this.id = const Value.absent(),
    required String rawText,
    required String normalizedText,
    this.estPrice = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : rawText = Value(rawText),
        normalizedText = Value(normalizedText);
  static Insertable<ListItem> custom({
    Expression<int>? id,
    Expression<String>? rawText,
    Expression<String>? normalizedText,
    Expression<double>? estPrice,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawText != null) 'raw_text': rawText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (estPrice != null) 'est_price': estPrice,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ListItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? rawText,
      Value<String>? normalizedText,
      Value<double>? estPrice,
      Value<int>? sortOrder}) {
    return ListItemsCompanion(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      estPrice: estPrice ?? this.estPrice,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (estPrice.present) {
      map['est_price'] = Variable<double>(estPrice.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListItemsCompanion(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('estPrice: $estPrice, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $LedgerEntriesTable extends LedgerEntries
    with TableInfo<$LedgerEntriesTable, LedgerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _holeMeta = const VerificationMeta('hole');
  @override
  late final GeneratedColumn<int> hole = GeneratedColumn<int>(
      'hole', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scoredAtMeta =
      const VerificationMeta('scoredAt');
  @override
  late final GeneratedColumn<DateTime> scoredAt = GeneratedColumn<DateTime>(
      'scored_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _parMeta = const VerificationMeta('par');
  @override
  late final GeneratedColumn<int> par = GeneratedColumn<int>(
      'par', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verdictNameMeta =
      const VerificationMeta('verdictName');
  @override
  late final GeneratedColumn<String> verdictName = GeneratedColumn<String>(
      'verdict_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _strokesMeta =
      const VerificationMeta('strokes');
  @override
  late final GeneratedColumn<int> strokes = GeneratedColumn<int>(
      'strokes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
      'tier', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _headlineMeta =
      const VerificationMeta('headline');
  @override
  late final GeneratedColumn<String> headline = GeneratedColumn<String>(
      'headline', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
      'quote', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sportKeyMeta =
      const VerificationMeta('sportKey');
  @override
  late final GeneratedColumn<String> sportKey = GeneratedColumn<String>(
      'sport_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tripWordMeta =
      const VerificationMeta('tripWord');
  @override
  late final GeneratedColumn<String> tripWord = GeneratedColumn<String>(
      'trip_word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parWordMeta =
      const VerificationMeta('parWord');
  @override
  late final GeneratedColumn<String> parWord = GeneratedColumn<String>(
      'par_word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mulliganUsedMeta =
      const VerificationMeta('mulliganUsed');
  @override
  late final GeneratedColumn<bool> mulliganUsed = GeneratedColumn<bool>(
      'mulligan_used', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("mulligan_used" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hotDogMeta = const VerificationMeta('hotDog');
  @override
  late final GeneratedColumn<bool> hotDog = GeneratedColumn<bool>(
      'hot_dog', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("hot_dog" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _impulseDollarsMeta =
      const VerificationMeta('impulseDollars');
  @override
  late final GeneratedColumn<double> impulseDollars = GeneratedColumn<double>(
      'impulse_dollars', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        hole,
        scoredAt,
        total,
        par,
        verdictName,
        strokes,
        tier,
        headline,
        quote,
        sportKey,
        tripWord,
        parWord,
        mulliganUsed,
        hotDog,
        impulseDollars
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hole')) {
      context.handle(
          _holeMeta, hole.isAcceptableOrUnknown(data['hole']!, _holeMeta));
    } else if (isInserting) {
      context.missing(_holeMeta);
    }
    if (data.containsKey('scored_at')) {
      context.handle(_scoredAtMeta,
          scoredAt.isAcceptableOrUnknown(data['scored_at']!, _scoredAtMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('par')) {
      context.handle(
          _parMeta, par.isAcceptableOrUnknown(data['par']!, _parMeta));
    } else if (isInserting) {
      context.missing(_parMeta);
    }
    if (data.containsKey('verdict_name')) {
      context.handle(
          _verdictNameMeta,
          verdictName.isAcceptableOrUnknown(
              data['verdict_name']!, _verdictNameMeta));
    } else if (isInserting) {
      context.missing(_verdictNameMeta);
    }
    if (data.containsKey('strokes')) {
      context.handle(_strokesMeta,
          strokes.isAcceptableOrUnknown(data['strokes']!, _strokesMeta));
    } else if (isInserting) {
      context.missing(_strokesMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
          _tierMeta, tier.isAcceptableOrUnknown(data['tier']!, _tierMeta));
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('headline')) {
      context.handle(_headlineMeta,
          headline.isAcceptableOrUnknown(data['headline']!, _headlineMeta));
    } else if (isInserting) {
      context.missing(_headlineMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
          _quoteMeta, quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta));
    } else if (isInserting) {
      context.missing(_quoteMeta);
    }
    if (data.containsKey('sport_key')) {
      context.handle(_sportKeyMeta,
          sportKey.isAcceptableOrUnknown(data['sport_key']!, _sportKeyMeta));
    } else if (isInserting) {
      context.missing(_sportKeyMeta);
    }
    if (data.containsKey('trip_word')) {
      context.handle(_tripWordMeta,
          tripWord.isAcceptableOrUnknown(data['trip_word']!, _tripWordMeta));
    } else if (isInserting) {
      context.missing(_tripWordMeta);
    }
    if (data.containsKey('par_word')) {
      context.handle(_parWordMeta,
          parWord.isAcceptableOrUnknown(data['par_word']!, _parWordMeta));
    } else if (isInserting) {
      context.missing(_parWordMeta);
    }
    if (data.containsKey('mulligan_used')) {
      context.handle(
          _mulliganUsedMeta,
          mulliganUsed.isAcceptableOrUnknown(
              data['mulligan_used']!, _mulliganUsedMeta));
    }
    if (data.containsKey('hot_dog')) {
      context.handle(_hotDogMeta,
          hotDog.isAcceptableOrUnknown(data['hot_dog']!, _hotDogMeta));
    }
    if (data.containsKey('impulse_dollars')) {
      context.handle(
          _impulseDollarsMeta,
          impulseDollars.isAcceptableOrUnknown(
              data['impulse_dollars']!, _impulseDollarsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      hole: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hole'])!,
      scoredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scored_at'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      par: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}par'])!,
      verdictName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verdict_name'])!,
      strokes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}strokes'])!,
      tier: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tier'])!,
      headline: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}headline'])!,
      quote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quote'])!,
      sportKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sport_key'])!,
      tripWord: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trip_word'])!,
      parWord: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}par_word'])!,
      mulliganUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}mulligan_used'])!,
      hotDog: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}hot_dog'])!,
      impulseDollars: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}impulse_dollars'])!,
    );
  }

  @override
  $LedgerEntriesTable createAlias(String alias) {
    return $LedgerEntriesTable(attachedDatabase, alias);
  }
}

class LedgerEntry extends DataClass implements Insertable<LedgerEntry> {
  final int id;
  final int hole;
  final DateTime scoredAt;
  final double total;
  final int par;
  final String verdictName;
  final int strokes;
  final int tier;
  final String headline;
  final String quote;
  final String sportKey;
  final String tripWord;
  final String parWord;
  final bool mulliganUsed;
  final bool hotDog;
  final double impulseDollars;
  const LedgerEntry(
      {required this.id,
      required this.hole,
      required this.scoredAt,
      required this.total,
      required this.par,
      required this.verdictName,
      required this.strokes,
      required this.tier,
      required this.headline,
      required this.quote,
      required this.sportKey,
      required this.tripWord,
      required this.parWord,
      required this.mulliganUsed,
      required this.hotDog,
      required this.impulseDollars});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hole'] = Variable<int>(hole);
    map['scored_at'] = Variable<DateTime>(scoredAt);
    map['total'] = Variable<double>(total);
    map['par'] = Variable<int>(par);
    map['verdict_name'] = Variable<String>(verdictName);
    map['strokes'] = Variable<int>(strokes);
    map['tier'] = Variable<int>(tier);
    map['headline'] = Variable<String>(headline);
    map['quote'] = Variable<String>(quote);
    map['sport_key'] = Variable<String>(sportKey);
    map['trip_word'] = Variable<String>(tripWord);
    map['par_word'] = Variable<String>(parWord);
    map['mulligan_used'] = Variable<bool>(mulliganUsed);
    map['hot_dog'] = Variable<bool>(hotDog);
    map['impulse_dollars'] = Variable<double>(impulseDollars);
    return map;
  }

  LedgerEntriesCompanion toCompanion(bool nullToAbsent) {
    return LedgerEntriesCompanion(
      id: Value(id),
      hole: Value(hole),
      scoredAt: Value(scoredAt),
      total: Value(total),
      par: Value(par),
      verdictName: Value(verdictName),
      strokes: Value(strokes),
      tier: Value(tier),
      headline: Value(headline),
      quote: Value(quote),
      sportKey: Value(sportKey),
      tripWord: Value(tripWord),
      parWord: Value(parWord),
      mulliganUsed: Value(mulliganUsed),
      hotDog: Value(hotDog),
      impulseDollars: Value(impulseDollars),
    );
  }

  factory LedgerEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerEntry(
      id: serializer.fromJson<int>(json['id']),
      hole: serializer.fromJson<int>(json['hole']),
      scoredAt: serializer.fromJson<DateTime>(json['scoredAt']),
      total: serializer.fromJson<double>(json['total']),
      par: serializer.fromJson<int>(json['par']),
      verdictName: serializer.fromJson<String>(json['verdictName']),
      strokes: serializer.fromJson<int>(json['strokes']),
      tier: serializer.fromJson<int>(json['tier']),
      headline: serializer.fromJson<String>(json['headline']),
      quote: serializer.fromJson<String>(json['quote']),
      sportKey: serializer.fromJson<String>(json['sportKey']),
      tripWord: serializer.fromJson<String>(json['tripWord']),
      parWord: serializer.fromJson<String>(json['parWord']),
      mulliganUsed: serializer.fromJson<bool>(json['mulliganUsed']),
      hotDog: serializer.fromJson<bool>(json['hotDog']),
      impulseDollars: serializer.fromJson<double>(json['impulseDollars']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'hole': serializer.toJson<int>(hole),
      'scoredAt': serializer.toJson<DateTime>(scoredAt),
      'total': serializer.toJson<double>(total),
      'par': serializer.toJson<int>(par),
      'verdictName': serializer.toJson<String>(verdictName),
      'strokes': serializer.toJson<int>(strokes),
      'tier': serializer.toJson<int>(tier),
      'headline': serializer.toJson<String>(headline),
      'quote': serializer.toJson<String>(quote),
      'sportKey': serializer.toJson<String>(sportKey),
      'tripWord': serializer.toJson<String>(tripWord),
      'parWord': serializer.toJson<String>(parWord),
      'mulliganUsed': serializer.toJson<bool>(mulliganUsed),
      'hotDog': serializer.toJson<bool>(hotDog),
      'impulseDollars': serializer.toJson<double>(impulseDollars),
    };
  }

  LedgerEntry copyWith(
          {int? id,
          int? hole,
          DateTime? scoredAt,
          double? total,
          int? par,
          String? verdictName,
          int? strokes,
          int? tier,
          String? headline,
          String? quote,
          String? sportKey,
          String? tripWord,
          String? parWord,
          bool? mulliganUsed,
          bool? hotDog,
          double? impulseDollars}) =>
      LedgerEntry(
        id: id ?? this.id,
        hole: hole ?? this.hole,
        scoredAt: scoredAt ?? this.scoredAt,
        total: total ?? this.total,
        par: par ?? this.par,
        verdictName: verdictName ?? this.verdictName,
        strokes: strokes ?? this.strokes,
        tier: tier ?? this.tier,
        headline: headline ?? this.headline,
        quote: quote ?? this.quote,
        sportKey: sportKey ?? this.sportKey,
        tripWord: tripWord ?? this.tripWord,
        parWord: parWord ?? this.parWord,
        mulliganUsed: mulliganUsed ?? this.mulliganUsed,
        hotDog: hotDog ?? this.hotDog,
        impulseDollars: impulseDollars ?? this.impulseDollars,
      );
  LedgerEntry copyWithCompanion(LedgerEntriesCompanion data) {
    return LedgerEntry(
      id: data.id.present ? data.id.value : this.id,
      hole: data.hole.present ? data.hole.value : this.hole,
      scoredAt: data.scoredAt.present ? data.scoredAt.value : this.scoredAt,
      total: data.total.present ? data.total.value : this.total,
      par: data.par.present ? data.par.value : this.par,
      verdictName:
          data.verdictName.present ? data.verdictName.value : this.verdictName,
      strokes: data.strokes.present ? data.strokes.value : this.strokes,
      tier: data.tier.present ? data.tier.value : this.tier,
      headline: data.headline.present ? data.headline.value : this.headline,
      quote: data.quote.present ? data.quote.value : this.quote,
      sportKey: data.sportKey.present ? data.sportKey.value : this.sportKey,
      tripWord: data.tripWord.present ? data.tripWord.value : this.tripWord,
      parWord: data.parWord.present ? data.parWord.value : this.parWord,
      mulliganUsed: data.mulliganUsed.present
          ? data.mulliganUsed.value
          : this.mulliganUsed,
      hotDog: data.hotDog.present ? data.hotDog.value : this.hotDog,
      impulseDollars: data.impulseDollars.present
          ? data.impulseDollars.value
          : this.impulseDollars,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntry(')
          ..write('id: $id, ')
          ..write('hole: $hole, ')
          ..write('scoredAt: $scoredAt, ')
          ..write('total: $total, ')
          ..write('par: $par, ')
          ..write('verdictName: $verdictName, ')
          ..write('strokes: $strokes, ')
          ..write('tier: $tier, ')
          ..write('headline: $headline, ')
          ..write('quote: $quote, ')
          ..write('sportKey: $sportKey, ')
          ..write('tripWord: $tripWord, ')
          ..write('parWord: $parWord, ')
          ..write('mulliganUsed: $mulliganUsed, ')
          ..write('hotDog: $hotDog, ')
          ..write('impulseDollars: $impulseDollars')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      hole,
      scoredAt,
      total,
      par,
      verdictName,
      strokes,
      tier,
      headline,
      quote,
      sportKey,
      tripWord,
      parWord,
      mulliganUsed,
      hotDog,
      impulseDollars);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerEntry &&
          other.id == this.id &&
          other.hole == this.hole &&
          other.scoredAt == this.scoredAt &&
          other.total == this.total &&
          other.par == this.par &&
          other.verdictName == this.verdictName &&
          other.strokes == this.strokes &&
          other.tier == this.tier &&
          other.headline == this.headline &&
          other.quote == this.quote &&
          other.sportKey == this.sportKey &&
          other.tripWord == this.tripWord &&
          other.parWord == this.parWord &&
          other.mulliganUsed == this.mulliganUsed &&
          other.hotDog == this.hotDog &&
          other.impulseDollars == this.impulseDollars);
}

class LedgerEntriesCompanion extends UpdateCompanion<LedgerEntry> {
  final Value<int> id;
  final Value<int> hole;
  final Value<DateTime> scoredAt;
  final Value<double> total;
  final Value<int> par;
  final Value<String> verdictName;
  final Value<int> strokes;
  final Value<int> tier;
  final Value<String> headline;
  final Value<String> quote;
  final Value<String> sportKey;
  final Value<String> tripWord;
  final Value<String> parWord;
  final Value<bool> mulliganUsed;
  final Value<bool> hotDog;
  final Value<double> impulseDollars;
  const LedgerEntriesCompanion({
    this.id = const Value.absent(),
    this.hole = const Value.absent(),
    this.scoredAt = const Value.absent(),
    this.total = const Value.absent(),
    this.par = const Value.absent(),
    this.verdictName = const Value.absent(),
    this.strokes = const Value.absent(),
    this.tier = const Value.absent(),
    this.headline = const Value.absent(),
    this.quote = const Value.absent(),
    this.sportKey = const Value.absent(),
    this.tripWord = const Value.absent(),
    this.parWord = const Value.absent(),
    this.mulliganUsed = const Value.absent(),
    this.hotDog = const Value.absent(),
    this.impulseDollars = const Value.absent(),
  });
  LedgerEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int hole,
    this.scoredAt = const Value.absent(),
    required double total,
    required int par,
    required String verdictName,
    required int strokes,
    required int tier,
    required String headline,
    required String quote,
    required String sportKey,
    required String tripWord,
    required String parWord,
    this.mulliganUsed = const Value.absent(),
    this.hotDog = const Value.absent(),
    this.impulseDollars = const Value.absent(),
  })  : hole = Value(hole),
        total = Value(total),
        par = Value(par),
        verdictName = Value(verdictName),
        strokes = Value(strokes),
        tier = Value(tier),
        headline = Value(headline),
        quote = Value(quote),
        sportKey = Value(sportKey),
        tripWord = Value(tripWord),
        parWord = Value(parWord);
  static Insertable<LedgerEntry> custom({
    Expression<int>? id,
    Expression<int>? hole,
    Expression<DateTime>? scoredAt,
    Expression<double>? total,
    Expression<int>? par,
    Expression<String>? verdictName,
    Expression<int>? strokes,
    Expression<int>? tier,
    Expression<String>? headline,
    Expression<String>? quote,
    Expression<String>? sportKey,
    Expression<String>? tripWord,
    Expression<String>? parWord,
    Expression<bool>? mulliganUsed,
    Expression<bool>? hotDog,
    Expression<double>? impulseDollars,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hole != null) 'hole': hole,
      if (scoredAt != null) 'scored_at': scoredAt,
      if (total != null) 'total': total,
      if (par != null) 'par': par,
      if (verdictName != null) 'verdict_name': verdictName,
      if (strokes != null) 'strokes': strokes,
      if (tier != null) 'tier': tier,
      if (headline != null) 'headline': headline,
      if (quote != null) 'quote': quote,
      if (sportKey != null) 'sport_key': sportKey,
      if (tripWord != null) 'trip_word': tripWord,
      if (parWord != null) 'par_word': parWord,
      if (mulliganUsed != null) 'mulligan_used': mulliganUsed,
      if (hotDog != null) 'hot_dog': hotDog,
      if (impulseDollars != null) 'impulse_dollars': impulseDollars,
    });
  }

  LedgerEntriesCompanion copyWith(
      {Value<int>? id,
      Value<int>? hole,
      Value<DateTime>? scoredAt,
      Value<double>? total,
      Value<int>? par,
      Value<String>? verdictName,
      Value<int>? strokes,
      Value<int>? tier,
      Value<String>? headline,
      Value<String>? quote,
      Value<String>? sportKey,
      Value<String>? tripWord,
      Value<String>? parWord,
      Value<bool>? mulliganUsed,
      Value<bool>? hotDog,
      Value<double>? impulseDollars}) {
    return LedgerEntriesCompanion(
      id: id ?? this.id,
      hole: hole ?? this.hole,
      scoredAt: scoredAt ?? this.scoredAt,
      total: total ?? this.total,
      par: par ?? this.par,
      verdictName: verdictName ?? this.verdictName,
      strokes: strokes ?? this.strokes,
      tier: tier ?? this.tier,
      headline: headline ?? this.headline,
      quote: quote ?? this.quote,
      sportKey: sportKey ?? this.sportKey,
      tripWord: tripWord ?? this.tripWord,
      parWord: parWord ?? this.parWord,
      mulliganUsed: mulliganUsed ?? this.mulliganUsed,
      hotDog: hotDog ?? this.hotDog,
      impulseDollars: impulseDollars ?? this.impulseDollars,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (hole.present) {
      map['hole'] = Variable<int>(hole.value);
    }
    if (scoredAt.present) {
      map['scored_at'] = Variable<DateTime>(scoredAt.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (par.present) {
      map['par'] = Variable<int>(par.value);
    }
    if (verdictName.present) {
      map['verdict_name'] = Variable<String>(verdictName.value);
    }
    if (strokes.present) {
      map['strokes'] = Variable<int>(strokes.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (headline.present) {
      map['headline'] = Variable<String>(headline.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (sportKey.present) {
      map['sport_key'] = Variable<String>(sportKey.value);
    }
    if (tripWord.present) {
      map['trip_word'] = Variable<String>(tripWord.value);
    }
    if (parWord.present) {
      map['par_word'] = Variable<String>(parWord.value);
    }
    if (mulliganUsed.present) {
      map['mulligan_used'] = Variable<bool>(mulliganUsed.value);
    }
    if (hotDog.present) {
      map['hot_dog'] = Variable<bool>(hotDog.value);
    }
    if (impulseDollars.present) {
      map['impulse_dollars'] = Variable<double>(impulseDollars.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerEntriesCompanion(')
          ..write('id: $id, ')
          ..write('hole: $hole, ')
          ..write('scoredAt: $scoredAt, ')
          ..write('total: $total, ')
          ..write('par: $par, ')
          ..write('verdictName: $verdictName, ')
          ..write('strokes: $strokes, ')
          ..write('tier: $tier, ')
          ..write('headline: $headline, ')
          ..write('quote: $quote, ')
          ..write('sportKey: $sportKey, ')
          ..write('tripWord: $tripWord, ')
          ..write('parWord: $parWord, ')
          ..write('mulliganUsed: $mulliganUsed, ')
          ..write('hotDog: $hotDog, ')
          ..write('impulseDollars: $impulseDollars')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts with TableInfo<$ReceiptsTable, Receipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _ledgerEntryIdMeta =
      const VerificationMeta('ledgerEntryId');
  @override
  late final GeneratedColumn<int> ledgerEntryId = GeneratedColumn<int>(
      'ledger_entry_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ocrRawTextMeta =
      const VerificationMeta('ocrRawText');
  @override
  late final GeneratedColumn<String> ocrRawText = GeneratedColumn<String>(
      'ocr_raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parsedAtMeta =
      const VerificationMeta('parsedAt');
  @override
  late final GeneratedColumn<DateTime> parsedAt = GeneratedColumn<DateTime>(
      'parsed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _itemCountMeta =
      const VerificationMeta('itemCount');
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
      'item_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, ledgerEntryId, ocrRawText, parsedAt, subtotal, total, itemCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(Insertable<Receipt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ledger_entry_id')) {
      context.handle(
          _ledgerEntryIdMeta,
          ledgerEntryId.isAcceptableOrUnknown(
              data['ledger_entry_id']!, _ledgerEntryIdMeta));
    }
    if (data.containsKey('ocr_raw_text')) {
      context.handle(
          _ocrRawTextMeta,
          ocrRawText.isAcceptableOrUnknown(
              data['ocr_raw_text']!, _ocrRawTextMeta));
    } else if (isInserting) {
      context.missing(_ocrRawTextMeta);
    }
    if (data.containsKey('parsed_at')) {
      context.handle(_parsedAtMeta,
          parsedAt.isAcceptableOrUnknown(data['parsed_at']!, _parsedAtMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('item_count')) {
      context.handle(_itemCountMeta,
          itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receipt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ledgerEntryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ledger_entry_id']),
      ocrRawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ocr_raw_text'])!,
      parsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}parsed_at'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal']),
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total']),
      itemCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_count'])!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class Receipt extends DataClass implements Insertable<Receipt> {
  final int id;
  final int? ledgerEntryId;
  final String ocrRawText;
  final DateTime parsedAt;
  final double? subtotal;
  final double? total;
  final int itemCount;
  const Receipt(
      {required this.id,
      this.ledgerEntryId,
      required this.ocrRawText,
      required this.parsedAt,
      this.subtotal,
      this.total,
      required this.itemCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || ledgerEntryId != null) {
      map['ledger_entry_id'] = Variable<int>(ledgerEntryId);
    }
    map['ocr_raw_text'] = Variable<String>(ocrRawText);
    map['parsed_at'] = Variable<DateTime>(parsedAt);
    if (!nullToAbsent || subtotal != null) {
      map['subtotal'] = Variable<double>(subtotal);
    }
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<double>(total);
    }
    map['item_count'] = Variable<int>(itemCount);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      ledgerEntryId: ledgerEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerEntryId),
      ocrRawText: Value(ocrRawText),
      parsedAt: Value(parsedAt),
      subtotal: subtotal == null && nullToAbsent
          ? const Value.absent()
          : Value(subtotal),
      total:
          total == null && nullToAbsent ? const Value.absent() : Value(total),
      itemCount: Value(itemCount),
    );
  }

  factory Receipt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receipt(
      id: serializer.fromJson<int>(json['id']),
      ledgerEntryId: serializer.fromJson<int?>(json['ledgerEntryId']),
      ocrRawText: serializer.fromJson<String>(json['ocrRawText']),
      parsedAt: serializer.fromJson<DateTime>(json['parsedAt']),
      subtotal: serializer.fromJson<double?>(json['subtotal']),
      total: serializer.fromJson<double?>(json['total']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ledgerEntryId': serializer.toJson<int?>(ledgerEntryId),
      'ocrRawText': serializer.toJson<String>(ocrRawText),
      'parsedAt': serializer.toJson<DateTime>(parsedAt),
      'subtotal': serializer.toJson<double?>(subtotal),
      'total': serializer.toJson<double?>(total),
      'itemCount': serializer.toJson<int>(itemCount),
    };
  }

  Receipt copyWith(
          {int? id,
          Value<int?> ledgerEntryId = const Value.absent(),
          String? ocrRawText,
          DateTime? parsedAt,
          Value<double?> subtotal = const Value.absent(),
          Value<double?> total = const Value.absent(),
          int? itemCount}) =>
      Receipt(
        id: id ?? this.id,
        ledgerEntryId:
            ledgerEntryId.present ? ledgerEntryId.value : this.ledgerEntryId,
        ocrRawText: ocrRawText ?? this.ocrRawText,
        parsedAt: parsedAt ?? this.parsedAt,
        subtotal: subtotal.present ? subtotal.value : this.subtotal,
        total: total.present ? total.value : this.total,
        itemCount: itemCount ?? this.itemCount,
      );
  Receipt copyWithCompanion(ReceiptsCompanion data) {
    return Receipt(
      id: data.id.present ? data.id.value : this.id,
      ledgerEntryId: data.ledgerEntryId.present
          ? data.ledgerEntryId.value
          : this.ledgerEntryId,
      ocrRawText:
          data.ocrRawText.present ? data.ocrRawText.value : this.ocrRawText,
      parsedAt: data.parsedAt.present ? data.parsedAt.value : this.parsedAt,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      total: data.total.present ? data.total.value : this.total,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receipt(')
          ..write('id: $id, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('parsedAt: $parsedAt, ')
          ..write('subtotal: $subtotal, ')
          ..write('total: $total, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, ledgerEntryId, ocrRawText, parsedAt, subtotal, total, itemCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receipt &&
          other.id == this.id &&
          other.ledgerEntryId == this.ledgerEntryId &&
          other.ocrRawText == this.ocrRawText &&
          other.parsedAt == this.parsedAt &&
          other.subtotal == this.subtotal &&
          other.total == this.total &&
          other.itemCount == this.itemCount);
}

class ReceiptsCompanion extends UpdateCompanion<Receipt> {
  final Value<int> id;
  final Value<int?> ledgerEntryId;
  final Value<String> ocrRawText;
  final Value<DateTime> parsedAt;
  final Value<double?> subtotal;
  final Value<double?> total;
  final Value<int> itemCount;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    this.ocrRawText = const Value.absent(),
    this.parsedAt = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.total = const Value.absent(),
    this.itemCount = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    this.id = const Value.absent(),
    this.ledgerEntryId = const Value.absent(),
    required String ocrRawText,
    this.parsedAt = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.total = const Value.absent(),
    this.itemCount = const Value.absent(),
  }) : ocrRawText = Value(ocrRawText);
  static Insertable<Receipt> custom({
    Expression<int>? id,
    Expression<int>? ledgerEntryId,
    Expression<String>? ocrRawText,
    Expression<DateTime>? parsedAt,
    Expression<double>? subtotal,
    Expression<double>? total,
    Expression<int>? itemCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerEntryId != null) 'ledger_entry_id': ledgerEntryId,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (parsedAt != null) 'parsed_at': parsedAt,
      if (subtotal != null) 'subtotal': subtotal,
      if (total != null) 'total': total,
      if (itemCount != null) 'item_count': itemCount,
    });
  }

  ReceiptsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? ledgerEntryId,
      Value<String>? ocrRawText,
      Value<DateTime>? parsedAt,
      Value<double?>? subtotal,
      Value<double?>? total,
      Value<int>? itemCount}) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      ledgerEntryId: ledgerEntryId ?? this.ledgerEntryId,
      ocrRawText: ocrRawText ?? this.ocrRawText,
      parsedAt: parsedAt ?? this.parsedAt,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ledgerEntryId.present) {
      map['ledger_entry_id'] = Variable<int>(ledgerEntryId.value);
    }
    if (ocrRawText.present) {
      map['ocr_raw_text'] = Variable<String>(ocrRawText.value);
    }
    if (parsedAt.present) {
      map['parsed_at'] = Variable<DateTime>(parsedAt.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerEntryId: $ledgerEntryId, ')
          ..write('ocrRawText: $ocrRawText, ')
          ..write('parsedAt: $parsedAt, ')
          ..write('subtotal: $subtotal, ')
          ..write('total: $total, ')
          ..write('itemCount: $itemCount')
          ..write(')'))
        .toString();
  }
}

class $LearnedPricesTable extends LearnedPrices
    with TableInfo<$LearnedPricesTable, LearnedPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnedPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedNameMeta =
      const VerificationMeta('normalizedName');
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
      'normalized_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [normalizedName, price, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learned_prices';
  @override
  VerificationContext validateIntegrity(Insertable<LearnedPrice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_name')) {
      context.handle(
          _normalizedNameMeta,
          normalizedName.isAcceptableOrUnknown(
              data['normalized_name']!, _normalizedNameMeta));
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedName};
  @override
  LearnedPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedPrice(
      normalizedName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_name'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LearnedPricesTable createAlias(String alias) {
    return $LearnedPricesTable(attachedDatabase, alias);
  }
}

class LearnedPrice extends DataClass implements Insertable<LearnedPrice> {
  final String normalizedName;
  final double price;
  final DateTime updatedAt;
  const LearnedPrice(
      {required this.normalizedName,
      required this.price,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_name'] = Variable<String>(normalizedName);
    map['price'] = Variable<double>(price);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LearnedPricesCompanion toCompanion(bool nullToAbsent) {
    return LearnedPricesCompanion(
      normalizedName: Value(normalizedName),
      price: Value(price),
      updatedAt: Value(updatedAt),
    );
  }

  factory LearnedPrice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedPrice(
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      price: serializer.fromJson<double>(json['price']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedName': serializer.toJson<String>(normalizedName),
      'price': serializer.toJson<double>(price),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LearnedPrice copyWith(
          {String? normalizedName, double? price, DateTime? updatedAt}) =>
      LearnedPrice(
        normalizedName: normalizedName ?? this.normalizedName,
        price: price ?? this.price,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LearnedPrice copyWithCompanion(LearnedPricesCompanion data) {
    return LearnedPrice(
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      price: data.price.present ? data.price.value : this.price,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedPrice(')
          ..write('normalizedName: $normalizedName, ')
          ..write('price: $price, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(normalizedName, price, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedPrice &&
          other.normalizedName == this.normalizedName &&
          other.price == this.price &&
          other.updatedAt == this.updatedAt);
}

class LearnedPricesCompanion extends UpdateCompanion<LearnedPrice> {
  final Value<String> normalizedName;
  final Value<double> price;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LearnedPricesCompanion({
    this.normalizedName = const Value.absent(),
    this.price = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearnedPricesCompanion.insert({
    required String normalizedName,
    required double price,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : normalizedName = Value(normalizedName),
        price = Value(price);
  static Insertable<LearnedPrice> custom({
    Expression<String>? normalizedName,
    Expression<double>? price,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (price != null) 'price': price,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearnedPricesCompanion copyWith(
      {Value<String>? normalizedName,
      Value<double>? price,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LearnedPricesCompanion(
      normalizedName: normalizedName ?? this.normalizedName,
      price: price ?? this.price,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnedPricesCompanion(')
          ..write('normalizedName: $normalizedName, ')
          ..write('price: $price, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearnedAliasesTable extends LearnedAliases
    with TableInfo<$LearnedAliasesTable, LearnedAliase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearnedAliasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _receiptTokenMeta =
      const VerificationMeta('receiptToken');
  @override
  late final GeneratedColumn<String> receiptToken = GeneratedColumn<String>(
      'receipt_token', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plainTextMeta =
      const VerificationMeta('plainText');
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
      'plain_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [receiptToken, plainText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learned_aliases';
  @override
  VerificationContext validateIntegrity(Insertable<LearnedAliase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('receipt_token')) {
      context.handle(
          _receiptTokenMeta,
          receiptToken.isAcceptableOrUnknown(
              data['receipt_token']!, _receiptTokenMeta));
    } else if (isInserting) {
      context.missing(_receiptTokenMeta);
    }
    if (data.containsKey('plain_text')) {
      context.handle(_plainTextMeta,
          plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta));
    } else if (isInserting) {
      context.missing(_plainTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {receiptToken};
  @override
  LearnedAliase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearnedAliase(
      receiptToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receipt_token'])!,
      plainText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plain_text'])!,
    );
  }

  @override
  $LearnedAliasesTable createAlias(String alias) {
    return $LearnedAliasesTable(attachedDatabase, alias);
  }
}

class LearnedAliase extends DataClass implements Insertable<LearnedAliase> {
  final String receiptToken;
  final String plainText;
  const LearnedAliase({required this.receiptToken, required this.plainText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['receipt_token'] = Variable<String>(receiptToken);
    map['plain_text'] = Variable<String>(plainText);
    return map;
  }

  LearnedAliasesCompanion toCompanion(bool nullToAbsent) {
    return LearnedAliasesCompanion(
      receiptToken: Value(receiptToken),
      plainText: Value(plainText),
    );
  }

  factory LearnedAliase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearnedAliase(
      receiptToken: serializer.fromJson<String>(json['receiptToken']),
      plainText: serializer.fromJson<String>(json['plainText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'receiptToken': serializer.toJson<String>(receiptToken),
      'plainText': serializer.toJson<String>(plainText),
    };
  }

  LearnedAliase copyWith({String? receiptToken, String? plainText}) =>
      LearnedAliase(
        receiptToken: receiptToken ?? this.receiptToken,
        plainText: plainText ?? this.plainText,
      );
  LearnedAliase copyWithCompanion(LearnedAliasesCompanion data) {
    return LearnedAliase(
      receiptToken: data.receiptToken.present
          ? data.receiptToken.value
          : this.receiptToken,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearnedAliase(')
          ..write('receiptToken: $receiptToken, ')
          ..write('plainText: $plainText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(receiptToken, plainText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearnedAliase &&
          other.receiptToken == this.receiptToken &&
          other.plainText == this.plainText);
}

class LearnedAliasesCompanion extends UpdateCompanion<LearnedAliase> {
  final Value<String> receiptToken;
  final Value<String> plainText;
  final Value<int> rowid;
  const LearnedAliasesCompanion({
    this.receiptToken = const Value.absent(),
    this.plainText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearnedAliasesCompanion.insert({
    required String receiptToken,
    required String plainText,
    this.rowid = const Value.absent(),
  })  : receiptToken = Value(receiptToken),
        plainText = Value(plainText);
  static Insertable<LearnedAliase> custom({
    Expression<String>? receiptToken,
    Expression<String>? plainText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (receiptToken != null) 'receipt_token': receiptToken,
      if (plainText != null) 'plain_text': plainText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearnedAliasesCompanion copyWith(
      {Value<String>? receiptToken,
      Value<String>? plainText,
      Value<int>? rowid}) {
    return LearnedAliasesCompanion(
      receiptToken: receiptToken ?? this.receiptToken,
      plainText: plainText ?? this.plainText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (receiptToken.present) {
      map['receipt_token'] = Variable<String>(receiptToken.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearnedAliasesCompanion(')
          ..write('receiptToken: $receiptToken, ')
          ..write('plainText: $plainText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KeyValueSettingsTable extends KeyValueSettings
    with TableInfo<$KeyValueSettingsTable, KeyValueSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyValueSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_value_settings';
  @override
  VerificationContext validateIntegrity(Insertable<KeyValueSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KeyValueSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyValueSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $KeyValueSettingsTable createAlias(String alias) {
    return $KeyValueSettingsTable(attachedDatabase, alias);
  }
}

class KeyValueSetting extends DataClass implements Insertable<KeyValueSetting> {
  final String key;
  final String value;
  const KeyValueSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KeyValueSettingsCompanion toCompanion(bool nullToAbsent) {
    return KeyValueSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory KeyValueSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyValueSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KeyValueSetting copyWith({String? key, String? value}) => KeyValueSetting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  KeyValueSetting copyWithCompanion(KeyValueSettingsCompanion data) {
    return KeyValueSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyValueSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class KeyValueSettingsCompanion extends UpdateCompanion<KeyValueSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KeyValueSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KeyValueSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<KeyValueSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KeyValueSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return KeyValueSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyValueSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ListItemsTable listItems = $ListItemsTable(this);
  late final $LedgerEntriesTable ledgerEntries = $LedgerEntriesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $LearnedPricesTable learnedPrices = $LearnedPricesTable(this);
  late final $LearnedAliasesTable learnedAliases = $LearnedAliasesTable(this);
  late final $KeyValueSettingsTable keyValueSettings =
      $KeyValueSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        listItems,
        ledgerEntries,
        receipts,
        learnedPrices,
        learnedAliases,
        keyValueSettings
      ];
}

typedef $$ListItemsTableCreateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  required String rawText,
  required String normalizedText,
  Value<double> estPrice,
  Value<int> sortOrder,
});
typedef $$ListItemsTableUpdateCompanionBuilder = ListItemsCompanion Function({
  Value<int> id,
  Value<String> rawText,
  Value<String> normalizedText,
  Value<double> estPrice,
  Value<int> sortOrder,
});

class $$ListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estPrice => $composableBuilder(
      column: $table.estPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$ListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estPrice => $composableBuilder(
      column: $table.estPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$ListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListItemsTable> {
  $$ListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText, builder: (column) => column);

  GeneratedColumn<double> get estPrice =>
      $composableBuilder(column: $table.estPrice, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ListItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItem,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItem, BaseReferences<_$AppDatabase, $ListItemsTable, ListItem>),
    ListItem,
    PrefetchHooks Function()> {
  $$ListItemsTableTableManager(_$AppDatabase db, $ListItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> normalizedText = const Value.absent(),
            Value<double> estPrice = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              ListItemsCompanion(
            id: id,
            rawText: rawText,
            normalizedText: normalizedText,
            estPrice: estPrice,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rawText,
            required String normalizedText,
            Value<double> estPrice = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              ListItemsCompanion.insert(
            id: id,
            rawText: rawText,
            normalizedText: normalizedText,
            estPrice: estPrice,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListItemsTable,
    ListItem,
    $$ListItemsTableFilterComposer,
    $$ListItemsTableOrderingComposer,
    $$ListItemsTableAnnotationComposer,
    $$ListItemsTableCreateCompanionBuilder,
    $$ListItemsTableUpdateCompanionBuilder,
    (ListItem, BaseReferences<_$AppDatabase, $ListItemsTable, ListItem>),
    ListItem,
    PrefetchHooks Function()>;
typedef $$LedgerEntriesTableCreateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<int> id,
  required int hole,
  Value<DateTime> scoredAt,
  required double total,
  required int par,
  required String verdictName,
  required int strokes,
  required int tier,
  required String headline,
  required String quote,
  required String sportKey,
  required String tripWord,
  required String parWord,
  Value<bool> mulliganUsed,
  Value<bool> hotDog,
  Value<double> impulseDollars,
});
typedef $$LedgerEntriesTableUpdateCompanionBuilder = LedgerEntriesCompanion
    Function({
  Value<int> id,
  Value<int> hole,
  Value<DateTime> scoredAt,
  Value<double> total,
  Value<int> par,
  Value<String> verdictName,
  Value<int> strokes,
  Value<int> tier,
  Value<String> headline,
  Value<String> quote,
  Value<String> sportKey,
  Value<String> tripWord,
  Value<String> parWord,
  Value<bool> mulliganUsed,
  Value<bool> hotDog,
  Value<double> impulseDollars,
});

class $$LedgerEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hole => $composableBuilder(
      column: $table.hole, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scoredAt => $composableBuilder(
      column: $table.scoredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get par => $composableBuilder(
      column: $table.par, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verdictName => $composableBuilder(
      column: $table.verdictName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get strokes => $composableBuilder(
      column: $table.strokes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sportKey => $composableBuilder(
      column: $table.sportKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tripWord => $composableBuilder(
      column: $table.tripWord, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parWord => $composableBuilder(
      column: $table.parWord, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get mulliganUsed => $composableBuilder(
      column: $table.mulliganUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hotDog => $composableBuilder(
      column: $table.hotDog, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get impulseDollars => $composableBuilder(
      column: $table.impulseDollars,
      builder: (column) => ColumnFilters(column));
}

class $$LedgerEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hole => $composableBuilder(
      column: $table.hole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scoredAt => $composableBuilder(
      column: $table.scoredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get par => $composableBuilder(
      column: $table.par, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verdictName => $composableBuilder(
      column: $table.verdictName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get strokes => $composableBuilder(
      column: $table.strokes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tier => $composableBuilder(
      column: $table.tier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get headline => $composableBuilder(
      column: $table.headline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sportKey => $composableBuilder(
      column: $table.sportKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tripWord => $composableBuilder(
      column: $table.tripWord, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parWord => $composableBuilder(
      column: $table.parWord, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get mulliganUsed => $composableBuilder(
      column: $table.mulliganUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hotDog => $composableBuilder(
      column: $table.hotDog, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get impulseDollars => $composableBuilder(
      column: $table.impulseDollars,
      builder: (column) => ColumnOrderings(column));
}

class $$LedgerEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerEntriesTable> {
  $$LedgerEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get hole =>
      $composableBuilder(column: $table.hole, builder: (column) => column);

  GeneratedColumn<DateTime> get scoredAt =>
      $composableBuilder(column: $table.scoredAt, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get par =>
      $composableBuilder(column: $table.par, builder: (column) => column);

  GeneratedColumn<String> get verdictName => $composableBuilder(
      column: $table.verdictName, builder: (column) => column);

  GeneratedColumn<int> get strokes =>
      $composableBuilder(column: $table.strokes, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get headline =>
      $composableBuilder(column: $table.headline, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get sportKey =>
      $composableBuilder(column: $table.sportKey, builder: (column) => column);

  GeneratedColumn<String> get tripWord =>
      $composableBuilder(column: $table.tripWord, builder: (column) => column);

  GeneratedColumn<String> get parWord =>
      $composableBuilder(column: $table.parWord, builder: (column) => column);

  GeneratedColumn<bool> get mulliganUsed => $composableBuilder(
      column: $table.mulliganUsed, builder: (column) => column);

  GeneratedColumn<bool> get hotDog =>
      $composableBuilder(column: $table.hotDog, builder: (column) => column);

  GeneratedColumn<double> get impulseDollars => $composableBuilder(
      column: $table.impulseDollars, builder: (column) => column);
}

class $$LedgerEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()> {
  $$LedgerEntriesTableTableManager(_$AppDatabase db, $LedgerEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> hole = const Value.absent(),
            Value<DateTime> scoredAt = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<int> par = const Value.absent(),
            Value<String> verdictName = const Value.absent(),
            Value<int> strokes = const Value.absent(),
            Value<int> tier = const Value.absent(),
            Value<String> headline = const Value.absent(),
            Value<String> quote = const Value.absent(),
            Value<String> sportKey = const Value.absent(),
            Value<String> tripWord = const Value.absent(),
            Value<String> parWord = const Value.absent(),
            Value<bool> mulliganUsed = const Value.absent(),
            Value<bool> hotDog = const Value.absent(),
            Value<double> impulseDollars = const Value.absent(),
          }) =>
              LedgerEntriesCompanion(
            id: id,
            hole: hole,
            scoredAt: scoredAt,
            total: total,
            par: par,
            verdictName: verdictName,
            strokes: strokes,
            tier: tier,
            headline: headline,
            quote: quote,
            sportKey: sportKey,
            tripWord: tripWord,
            parWord: parWord,
            mulliganUsed: mulliganUsed,
            hotDog: hotDog,
            impulseDollars: impulseDollars,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int hole,
            Value<DateTime> scoredAt = const Value.absent(),
            required double total,
            required int par,
            required String verdictName,
            required int strokes,
            required int tier,
            required String headline,
            required String quote,
            required String sportKey,
            required String tripWord,
            required String parWord,
            Value<bool> mulliganUsed = const Value.absent(),
            Value<bool> hotDog = const Value.absent(),
            Value<double> impulseDollars = const Value.absent(),
          }) =>
              LedgerEntriesCompanion.insert(
            id: id,
            hole: hole,
            scoredAt: scoredAt,
            total: total,
            par: par,
            verdictName: verdictName,
            strokes: strokes,
            tier: tier,
            headline: headline,
            quote: quote,
            sportKey: sportKey,
            tripWord: tripWord,
            parWord: parWord,
            mulliganUsed: mulliganUsed,
            hotDog: hotDog,
            impulseDollars: impulseDollars,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerEntriesTable,
    LedgerEntry,
    $$LedgerEntriesTableFilterComposer,
    $$LedgerEntriesTableOrderingComposer,
    $$LedgerEntriesTableAnnotationComposer,
    $$LedgerEntriesTableCreateCompanionBuilder,
    $$LedgerEntriesTableUpdateCompanionBuilder,
    (
      LedgerEntry,
      BaseReferences<_$AppDatabase, $LedgerEntriesTable, LedgerEntry>
    ),
    LedgerEntry,
    PrefetchHooks Function()>;
typedef $$ReceiptsTableCreateCompanionBuilder = ReceiptsCompanion Function({
  Value<int> id,
  Value<int?> ledgerEntryId,
  required String ocrRawText,
  Value<DateTime> parsedAt,
  Value<double?> subtotal,
  Value<double?> total,
  Value<int> itemCount,
});
typedef $$ReceiptsTableUpdateCompanionBuilder = ReceiptsCompanion Function({
  Value<int> id,
  Value<int?> ledgerEntryId,
  Value<String> ocrRawText,
  Value<DateTime> parsedAt,
  Value<double?> subtotal,
  Value<double?> total,
  Value<int> itemCount,
});

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ledgerEntryId => $composableBuilder(
      column: $table.ledgerEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ocrRawText => $composableBuilder(
      column: $table.ocrRawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get parsedAt => $composableBuilder(
      column: $table.parsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnFilters(column));
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ledgerEntryId => $composableBuilder(
      column: $table.ledgerEntryId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ocrRawText => $composableBuilder(
      column: $table.ocrRawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get parsedAt => $composableBuilder(
      column: $table.parsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemCount => $composableBuilder(
      column: $table.itemCount, builder: (column) => ColumnOrderings(column));
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ledgerEntryId => $composableBuilder(
      column: $table.ledgerEntryId, builder: (column) => column);

  GeneratedColumn<String> get ocrRawText => $composableBuilder(
      column: $table.ocrRawText, builder: (column) => column);

  GeneratedColumn<DateTime> get parsedAt =>
      $composableBuilder(column: $table.parsedAt, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);
}

class $$ReceiptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()> {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> ledgerEntryId = const Value.absent(),
            Value<String> ocrRawText = const Value.absent(),
            Value<DateTime> parsedAt = const Value.absent(),
            Value<double?> subtotal = const Value.absent(),
            Value<double?> total = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
          }) =>
              ReceiptsCompanion(
            id: id,
            ledgerEntryId: ledgerEntryId,
            ocrRawText: ocrRawText,
            parsedAt: parsedAt,
            subtotal: subtotal,
            total: total,
            itemCount: itemCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> ledgerEntryId = const Value.absent(),
            required String ocrRawText,
            Value<DateTime> parsedAt = const Value.absent(),
            Value<double?> subtotal = const Value.absent(),
            Value<double?> total = const Value.absent(),
            Value<int> itemCount = const Value.absent(),
          }) =>
              ReceiptsCompanion.insert(
            id: id,
            ledgerEntryId: ledgerEntryId,
            ocrRawText: ocrRawText,
            parsedAt: parsedAt,
            subtotal: subtotal,
            total: total,
            itemCount: itemCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReceiptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReceiptsTable,
    Receipt,
    $$ReceiptsTableFilterComposer,
    $$ReceiptsTableOrderingComposer,
    $$ReceiptsTableAnnotationComposer,
    $$ReceiptsTableCreateCompanionBuilder,
    $$ReceiptsTableUpdateCompanionBuilder,
    (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
    Receipt,
    PrefetchHooks Function()>;
typedef $$LearnedPricesTableCreateCompanionBuilder = LearnedPricesCompanion
    Function({
  required String normalizedName,
  required double price,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LearnedPricesTableUpdateCompanionBuilder = LearnedPricesCompanion
    Function({
  Value<String> normalizedName,
  Value<double> price,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LearnedPricesTableFilterComposer
    extends Composer<_$AppDatabase, $LearnedPricesTable> {
  $$LearnedPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LearnedPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnedPricesTable> {
  $$LearnedPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LearnedPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnedPricesTable> {
  $$LearnedPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedName => $composableBuilder(
      column: $table.normalizedName, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LearnedPricesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearnedPricesTable,
    LearnedPrice,
    $$LearnedPricesTableFilterComposer,
    $$LearnedPricesTableOrderingComposer,
    $$LearnedPricesTableAnnotationComposer,
    $$LearnedPricesTableCreateCompanionBuilder,
    $$LearnedPricesTableUpdateCompanionBuilder,
    (
      LearnedPrice,
      BaseReferences<_$AppDatabase, $LearnedPricesTable, LearnedPrice>
    ),
    LearnedPrice,
    PrefetchHooks Function()> {
  $$LearnedPricesTableTableManager(_$AppDatabase db, $LearnedPricesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnedPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnedPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnedPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> normalizedName = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearnedPricesCompanion(
            normalizedName: normalizedName,
            price: price,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String normalizedName,
            required double price,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearnedPricesCompanion.insert(
            normalizedName: normalizedName,
            price: price,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LearnedPricesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LearnedPricesTable,
    LearnedPrice,
    $$LearnedPricesTableFilterComposer,
    $$LearnedPricesTableOrderingComposer,
    $$LearnedPricesTableAnnotationComposer,
    $$LearnedPricesTableCreateCompanionBuilder,
    $$LearnedPricesTableUpdateCompanionBuilder,
    (
      LearnedPrice,
      BaseReferences<_$AppDatabase, $LearnedPricesTable, LearnedPrice>
    ),
    LearnedPrice,
    PrefetchHooks Function()>;
typedef $$LearnedAliasesTableCreateCompanionBuilder = LearnedAliasesCompanion
    Function({
  required String receiptToken,
  required String plainText,
  Value<int> rowid,
});
typedef $$LearnedAliasesTableUpdateCompanionBuilder = LearnedAliasesCompanion
    Function({
  Value<String> receiptToken,
  Value<String> plainText,
  Value<int> rowid,
});

class $$LearnedAliasesTableFilterComposer
    extends Composer<_$AppDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get receiptToken => $composableBuilder(
      column: $table.receiptToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plainText => $composableBuilder(
      column: $table.plainText, builder: (column) => ColumnFilters(column));
}

class $$LearnedAliasesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get receiptToken => $composableBuilder(
      column: $table.receiptToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plainText => $composableBuilder(
      column: $table.plainText, builder: (column) => ColumnOrderings(column));
}

class $$LearnedAliasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearnedAliasesTable> {
  $$LearnedAliasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get receiptToken => $composableBuilder(
      column: $table.receiptToken, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);
}

class $$LearnedAliasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearnedAliasesTable,
    LearnedAliase,
    $$LearnedAliasesTableFilterComposer,
    $$LearnedAliasesTableOrderingComposer,
    $$LearnedAliasesTableAnnotationComposer,
    $$LearnedAliasesTableCreateCompanionBuilder,
    $$LearnedAliasesTableUpdateCompanionBuilder,
    (
      LearnedAliase,
      BaseReferences<_$AppDatabase, $LearnedAliasesTable, LearnedAliase>
    ),
    LearnedAliase,
    PrefetchHooks Function()> {
  $$LearnedAliasesTableTableManager(
      _$AppDatabase db, $LearnedAliasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearnedAliasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearnedAliasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearnedAliasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> receiptToken = const Value.absent(),
            Value<String> plainText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearnedAliasesCompanion(
            receiptToken: receiptToken,
            plainText: plainText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String receiptToken,
            required String plainText,
            Value<int> rowid = const Value.absent(),
          }) =>
              LearnedAliasesCompanion.insert(
            receiptToken: receiptToken,
            plainText: plainText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LearnedAliasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LearnedAliasesTable,
    LearnedAliase,
    $$LearnedAliasesTableFilterComposer,
    $$LearnedAliasesTableOrderingComposer,
    $$LearnedAliasesTableAnnotationComposer,
    $$LearnedAliasesTableCreateCompanionBuilder,
    $$LearnedAliasesTableUpdateCompanionBuilder,
    (
      LearnedAliase,
      BaseReferences<_$AppDatabase, $LearnedAliasesTable, LearnedAliase>
    ),
    LearnedAliase,
    PrefetchHooks Function()>;
typedef $$KeyValueSettingsTableCreateCompanionBuilder
    = KeyValueSettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KeyValueSettingsTableUpdateCompanionBuilder
    = KeyValueSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KeyValueSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $KeyValueSettingsTable> {
  $$KeyValueSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$KeyValueSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $KeyValueSettingsTable> {
  $$KeyValueSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$KeyValueSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KeyValueSettingsTable> {
  $$KeyValueSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KeyValueSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KeyValueSettingsTable,
    KeyValueSetting,
    $$KeyValueSettingsTableFilterComposer,
    $$KeyValueSettingsTableOrderingComposer,
    $$KeyValueSettingsTableAnnotationComposer,
    $$KeyValueSettingsTableCreateCompanionBuilder,
    $$KeyValueSettingsTableUpdateCompanionBuilder,
    (
      KeyValueSetting,
      BaseReferences<_$AppDatabase, $KeyValueSettingsTable, KeyValueSetting>
    ),
    KeyValueSetting,
    PrefetchHooks Function()> {
  $$KeyValueSettingsTableTableManager(
      _$AppDatabase db, $KeyValueSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyValueSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyValueSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyValueSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KeyValueSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              KeyValueSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KeyValueSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KeyValueSettingsTable,
    KeyValueSetting,
    $$KeyValueSettingsTableFilterComposer,
    $$KeyValueSettingsTableOrderingComposer,
    $$KeyValueSettingsTableAnnotationComposer,
    $$KeyValueSettingsTableCreateCompanionBuilder,
    $$KeyValueSettingsTableUpdateCompanionBuilder,
    (
      KeyValueSetting,
      BaseReferences<_$AppDatabase, $KeyValueSettingsTable, KeyValueSetting>
    ),
    KeyValueSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ListItemsTableTableManager get listItems =>
      $$ListItemsTableTableManager(_db, _db.listItems);
  $$LedgerEntriesTableTableManager get ledgerEntries =>
      $$LedgerEntriesTableTableManager(_db, _db.ledgerEntries);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$LearnedPricesTableTableManager get learnedPrices =>
      $$LearnedPricesTableTableManager(_db, _db.learnedPrices);
  $$LearnedAliasesTableTableManager get learnedAliases =>
      $$LearnedAliasesTableTableManager(_db, _db.learnedAliases);
  $$KeyValueSettingsTableTableManager get keyValueSettings =>
      $$KeyValueSettingsTableTableManager(_db, _db.keyValueSettings);
}
