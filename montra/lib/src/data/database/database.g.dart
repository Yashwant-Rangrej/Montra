// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _totalTransactionsMeta = const VerificationMeta(
    'totalTransactions',
  );
  @override
  late final GeneratedColumn<int> totalTransactions = GeneratedColumn<int>(
    'total_transactions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalIncomeMeta = const VerificationMeta(
    'totalIncome',
  );
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
    'total_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalExpensesMeta = const VerificationMeta(
    'totalExpenses',
  );
  @override
  late final GeneratedColumn<double> totalExpenses = GeneratedColumn<double>(
    'total_expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastTransactionDateMeta =
      const VerificationMeta('lastTransactionDate');
  @override
  late final GeneratedColumn<DateTime> lastTransactionDate =
      GeneratedColumn<DateTime>(
        'last_transaction_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _availableBalanceMeta = const VerificationMeta(
    'availableBalance',
  );
  @override
  late final GeneratedColumn<double> availableBalance = GeneratedColumn<double>(
    'available_balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bankName,
    totalTransactions,
    totalIncome,
    totalExpenses,
    lastTransactionDate,
    availableBalance,
    icon,
    color,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('total_transactions')) {
      context.handle(
        _totalTransactionsMeta,
        totalTransactions.isAcceptableOrUnknown(
          data['total_transactions']!,
          _totalTransactionsMeta,
        ),
      );
    }
    if (data.containsKey('total_income')) {
      context.handle(
        _totalIncomeMeta,
        totalIncome.isAcceptableOrUnknown(
          data['total_income']!,
          _totalIncomeMeta,
        ),
      );
    }
    if (data.containsKey('total_expenses')) {
      context.handle(
        _totalExpensesMeta,
        totalExpenses.isAcceptableOrUnknown(
          data['total_expenses']!,
          _totalExpensesMeta,
        ),
      );
    }
    if (data.containsKey('last_transaction_date')) {
      context.handle(
        _lastTransactionDateMeta,
        lastTransactionDate.isAcceptableOrUnknown(
          data['last_transaction_date']!,
          _lastTransactionDateMeta,
        ),
      );
    }
    if (data.containsKey('available_balance')) {
      context.handle(
        _availableBalanceMeta,
        availableBalance.isAcceptableOrUnknown(
          data['available_balance']!,
          _availableBalanceMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      totalTransactions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_transactions'],
      )!,
      totalIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_income'],
      )!,
      totalExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_expenses'],
      )!,
      lastTransactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_transaction_date'],
      ),
      availableBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_balance'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String bankName;
  final int totalTransactions;
  final double totalIncome;
  final double totalExpenses;
  final DateTime? lastTransactionDate;
  final double? availableBalance;
  final String? icon;
  final String? color;
  final bool isHidden;
  const Account({
    required this.id,
    required this.bankName,
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpenses,
    this.lastTransactionDate,
    this.availableBalance,
    this.icon,
    this.color,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bank_name'] = Variable<String>(bankName);
    map['total_transactions'] = Variable<int>(totalTransactions);
    map['total_income'] = Variable<double>(totalIncome);
    map['total_expenses'] = Variable<double>(totalExpenses);
    if (!nullToAbsent || lastTransactionDate != null) {
      map['last_transaction_date'] = Variable<DateTime>(lastTransactionDate);
    }
    if (!nullToAbsent || availableBalance != null) {
      map['available_balance'] = Variable<double>(availableBalance);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      bankName: Value(bankName),
      totalTransactions: Value(totalTransactions),
      totalIncome: Value(totalIncome),
      totalExpenses: Value(totalExpenses),
      lastTransactionDate: lastTransactionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastTransactionDate),
      availableBalance: availableBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(availableBalance),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isHidden: Value(isHidden),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      bankName: serializer.fromJson<String>(json['bankName']),
      totalTransactions: serializer.fromJson<int>(json['totalTransactions']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalExpenses: serializer.fromJson<double>(json['totalExpenses']),
      lastTransactionDate: serializer.fromJson<DateTime?>(
        json['lastTransactionDate'],
      ),
      availableBalance: serializer.fromJson<double?>(json['availableBalance']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bankName': serializer.toJson<String>(bankName),
      'totalTransactions': serializer.toJson<int>(totalTransactions),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalExpenses': serializer.toJson<double>(totalExpenses),
      'lastTransactionDate': serializer.toJson<DateTime?>(lastTransactionDate),
      'availableBalance': serializer.toJson<double?>(availableBalance),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  Account copyWith({
    int? id,
    String? bankName,
    int? totalTransactions,
    double? totalIncome,
    double? totalExpenses,
    Value<DateTime?> lastTransactionDate = const Value.absent(),
    Value<double?> availableBalance = const Value.absent(),
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isHidden,
  }) => Account(
    id: id ?? this.id,
    bankName: bankName ?? this.bankName,
    totalTransactions: totalTransactions ?? this.totalTransactions,
    totalIncome: totalIncome ?? this.totalIncome,
    totalExpenses: totalExpenses ?? this.totalExpenses,
    lastTransactionDate: lastTransactionDate.present
        ? lastTransactionDate.value
        : this.lastTransactionDate,
    availableBalance: availableBalance.present
        ? availableBalance.value
        : this.availableBalance,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isHidden: isHidden ?? this.isHidden,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      totalTransactions: data.totalTransactions.present
          ? data.totalTransactions.value
          : this.totalTransactions,
      totalIncome: data.totalIncome.present
          ? data.totalIncome.value
          : this.totalIncome,
      totalExpenses: data.totalExpenses.present
          ? data.totalExpenses.value
          : this.totalExpenses,
      lastTransactionDate: data.lastTransactionDate.present
          ? data.lastTransactionDate.value
          : this.lastTransactionDate,
      availableBalance: data.availableBalance.present
          ? data.availableBalance.value
          : this.availableBalance,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('totalTransactions: $totalTransactions, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('lastTransactionDate: $lastTransactionDate, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bankName,
    totalTransactions,
    totalIncome,
    totalExpenses,
    lastTransactionDate,
    availableBalance,
    icon,
    color,
    isHidden,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.bankName == this.bankName &&
          other.totalTransactions == this.totalTransactions &&
          other.totalIncome == this.totalIncome &&
          other.totalExpenses == this.totalExpenses &&
          other.lastTransactionDate == this.lastTransactionDate &&
          other.availableBalance == this.availableBalance &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isHidden == this.isHidden);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> bankName;
  final Value<int> totalTransactions;
  final Value<double> totalIncome;
  final Value<double> totalExpenses;
  final Value<DateTime?> lastTransactionDate;
  final Value<double?> availableBalance;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isHidden;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.bankName = const Value.absent(),
    this.totalTransactions = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpenses = const Value.absent(),
    this.lastTransactionDate = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isHidden = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String bankName,
    this.totalTransactions = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpenses = const Value.absent(),
    this.lastTransactionDate = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isHidden = const Value.absent(),
  }) : bankName = Value(bankName);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? bankName,
    Expression<int>? totalTransactions,
    Expression<double>? totalIncome,
    Expression<double>? totalExpenses,
    Expression<DateTime>? lastTransactionDate,
    Expression<double>? availableBalance,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isHidden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bankName != null) 'bank_name': bankName,
      if (totalTransactions != null) 'total_transactions': totalTransactions,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalExpenses != null) 'total_expenses': totalExpenses,
      if (lastTransactionDate != null)
        'last_transaction_date': lastTransactionDate,
      if (availableBalance != null) 'available_balance': availableBalance,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isHidden != null) 'is_hidden': isHidden,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? bankName,
    Value<int>? totalTransactions,
    Value<double>? totalIncome,
    Value<double>? totalExpenses,
    Value<DateTime?>? lastTransactionDate,
    Value<double?>? availableBalance,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isHidden,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      lastTransactionDate: lastTransactionDate ?? this.lastTransactionDate,
      availableBalance: availableBalance ?? this.availableBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (totalTransactions.present) {
      map['total_transactions'] = Variable<int>(totalTransactions.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalExpenses.present) {
      map['total_expenses'] = Variable<double>(totalExpenses.value);
    }
    if (lastTransactionDate.present) {
      map['last_transaction_date'] = Variable<DateTime>(
        lastTransactionDate.value,
      );
    }
    if (availableBalance.present) {
      map['available_balance'] = Variable<double>(availableBalance.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('bankName: $bankName, ')
          ..write('totalTransactions: $totalTransactions, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpenses: $totalExpenses, ')
          ..write('lastTransactionDate: $lastTransactionDate, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, color, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String type;
  final String? color;
  final String? icon;
  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.color,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      color: serializer.fromJson<String?>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'color': serializer.toJson<String?>(color),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? type,
    Value<String?> color = const Value.absent(),
    Value<String?> icon = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    color: color.present ? color.value : this.color,
    icon: icon.present ? icon.value : this.icon,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, color, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.color == this.color &&
          other.icon == this.icon);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> color;
  final Value<String?> icon;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? color,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? color,
    Value<String?>? icon,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('color: $color, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAccountIdMeta = const VerificationMeta(
    'targetAccountId',
  );
  @override
  late final GeneratedColumn<int> targetAccountId = GeneratedColumn<int>(
    'target_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _availableBalanceMeta = const VerificationMeta(
    'availableBalance',
  );
  @override
  late final GeneratedColumn<double> availableBalance = GeneratedColumn<double>(
    'available_balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalSmsMeta = const VerificationMeta(
    'originalSms',
  );
  @override
  late final GeneratedColumn<String> originalSms = GeneratedColumn<String>(
    'original_sms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankTransactionIdMeta = const VerificationMeta(
    'bankTransactionId',
  );
  @override
  late final GeneratedColumn<String> bankTransactionId =
      GeneratedColumn<String>(
        'bank_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _receiptAttachmentMeta = const VerificationMeta(
    'receiptAttachment',
  );
  @override
  late final GeneratedColumn<String> receiptAttachment =
      GeneratedColumn<String>(
        'receipt_attachment',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    type,
    merchant,
    categoryId,
    paymentMethod,
    accountId,
    targetAccountId,
    availableBalance,
    transactionDate,
    notes,
    originalSms,
    bankTransactionId,
    receiptAttachment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('target_account_id')) {
      context.handle(
        _targetAccountIdMeta,
        targetAccountId.isAcceptableOrUnknown(
          data['target_account_id']!,
          _targetAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('available_balance')) {
      context.handle(
        _availableBalanceMeta,
        availableBalance.isAcceptableOrUnknown(
          data['available_balance']!,
          _availableBalanceMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('original_sms')) {
      context.handle(
        _originalSmsMeta,
        originalSms.isAcceptableOrUnknown(
          data['original_sms']!,
          _originalSmsMeta,
        ),
      );
    }
    if (data.containsKey('bank_transaction_id')) {
      context.handle(
        _bankTransactionIdMeta,
        bankTransactionId.isAcceptableOrUnknown(
          data['bank_transaction_id']!,
          _bankTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('receipt_attachment')) {
      context.handle(
        _receiptAttachmentMeta,
        receiptAttachment.isAcceptableOrUnknown(
          data['receipt_attachment']!,
          _receiptAttachmentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      targetAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_account_id'],
      ),
      availableBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}available_balance'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      originalSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_sms'],
      ),
      bankTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_transaction_id'],
      ),
      receiptAttachment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_attachment'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final double amount;
  final String type;
  final String? merchant;
  final int? categoryId;
  final String? paymentMethod;
  final int accountId;
  final int? targetAccountId;
  final double? availableBalance;
  final DateTime transactionDate;
  final String? notes;
  final String? originalSms;
  final String? bankTransactionId;
  final String? receiptAttachment;
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    this.merchant,
    this.categoryId,
    this.paymentMethod,
    required this.accountId,
    this.targetAccountId,
    this.availableBalance,
    required this.transactionDate,
    this.notes,
    this.originalSms,
    this.bankTransactionId,
    this.receiptAttachment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || targetAccountId != null) {
      map['target_account_id'] = Variable<int>(targetAccountId);
    }
    if (!nullToAbsent || availableBalance != null) {
      map['available_balance'] = Variable<double>(availableBalance);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || originalSms != null) {
      map['original_sms'] = Variable<String>(originalSms);
    }
    if (!nullToAbsent || bankTransactionId != null) {
      map['bank_transaction_id'] = Variable<String>(bankTransactionId);
    }
    if (!nullToAbsent || receiptAttachment != null) {
      map['receipt_attachment'] = Variable<String>(receiptAttachment);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      type: Value(type),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      accountId: Value(accountId),
      targetAccountId: targetAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAccountId),
      availableBalance: availableBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(availableBalance),
      transactionDate: Value(transactionDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      originalSms: originalSms == null && nullToAbsent
          ? const Value.absent()
          : Value(originalSms),
      bankTransactionId: bankTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankTransactionId),
      receiptAttachment: receiptAttachment == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptAttachment),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      accountId: serializer.fromJson<int>(json['accountId']),
      targetAccountId: serializer.fromJson<int?>(json['targetAccountId']),
      availableBalance: serializer.fromJson<double?>(json['availableBalance']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      originalSms: serializer.fromJson<String?>(json['originalSms']),
      bankTransactionId: serializer.fromJson<String?>(
        json['bankTransactionId'],
      ),
      receiptAttachment: serializer.fromJson<String?>(
        json['receiptAttachment'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'merchant': serializer.toJson<String?>(merchant),
      'categoryId': serializer.toJson<int?>(categoryId),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'accountId': serializer.toJson<int>(accountId),
      'targetAccountId': serializer.toJson<int?>(targetAccountId),
      'availableBalance': serializer.toJson<double?>(availableBalance),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'notes': serializer.toJson<String?>(notes),
      'originalSms': serializer.toJson<String?>(originalSms),
      'bankTransactionId': serializer.toJson<String?>(bankTransactionId),
      'receiptAttachment': serializer.toJson<String?>(receiptAttachment),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? type,
    Value<String?> merchant = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    Value<String?> paymentMethod = const Value.absent(),
    int? accountId,
    Value<int?> targetAccountId = const Value.absent(),
    Value<double?> availableBalance = const Value.absent(),
    DateTime? transactionDate,
    Value<String?> notes = const Value.absent(),
    Value<String?> originalSms = const Value.absent(),
    Value<String?> bankTransactionId = const Value.absent(),
    Value<String?> receiptAttachment = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    type: type ?? this.type,
    merchant: merchant.present ? merchant.value : this.merchant,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    accountId: accountId ?? this.accountId,
    targetAccountId: targetAccountId.present
        ? targetAccountId.value
        : this.targetAccountId,
    availableBalance: availableBalance.present
        ? availableBalance.value
        : this.availableBalance,
    transactionDate: transactionDate ?? this.transactionDate,
    notes: notes.present ? notes.value : this.notes,
    originalSms: originalSms.present ? originalSms.value : this.originalSms,
    bankTransactionId: bankTransactionId.present
        ? bankTransactionId.value
        : this.bankTransactionId,
    receiptAttachment: receiptAttachment.present
        ? receiptAttachment.value
        : this.receiptAttachment,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      targetAccountId: data.targetAccountId.present
          ? data.targetAccountId.value
          : this.targetAccountId,
      availableBalance: data.availableBalance.present
          ? data.availableBalance.value
          : this.availableBalance,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      originalSms: data.originalSms.present
          ? data.originalSms.value
          : this.originalSms,
      bankTransactionId: data.bankTransactionId.present
          ? data.bankTransactionId.value
          : this.bankTransactionId,
      receiptAttachment: data.receiptAttachment.present
          ? data.receiptAttachment.value
          : this.receiptAttachment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('accountId: $accountId, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('originalSms: $originalSms, ')
          ..write('bankTransactionId: $bankTransactionId, ')
          ..write('receiptAttachment: $receiptAttachment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    type,
    merchant,
    categoryId,
    paymentMethod,
    accountId,
    targetAccountId,
    availableBalance,
    transactionDate,
    notes,
    originalSms,
    bankTransactionId,
    receiptAttachment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.merchant == this.merchant &&
          other.categoryId == this.categoryId &&
          other.paymentMethod == this.paymentMethod &&
          other.accountId == this.accountId &&
          other.targetAccountId == this.targetAccountId &&
          other.availableBalance == this.availableBalance &&
          other.transactionDate == this.transactionDate &&
          other.notes == this.notes &&
          other.originalSms == this.originalSms &&
          other.bankTransactionId == this.bankTransactionId &&
          other.receiptAttachment == this.receiptAttachment);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> type;
  final Value<String?> merchant;
  final Value<int?> categoryId;
  final Value<String?> paymentMethod;
  final Value<int> accountId;
  final Value<int?> targetAccountId;
  final Value<double?> availableBalance;
  final Value<DateTime> transactionDate;
  final Value<String?> notes;
  final Value<String?> originalSms;
  final Value<String?> bankTransactionId;
  final Value<String?> receiptAttachment;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.accountId = const Value.absent(),
    this.targetAccountId = const Value.absent(),
    this.availableBalance = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.originalSms = const Value.absent(),
    this.bankTransactionId = const Value.absent(),
    this.receiptAttachment = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String type,
    this.merchant = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    required int accountId,
    this.targetAccountId = const Value.absent(),
    this.availableBalance = const Value.absent(),
    required DateTime transactionDate,
    this.notes = const Value.absent(),
    this.originalSms = const Value.absent(),
    this.bankTransactionId = const Value.absent(),
    this.receiptAttachment = const Value.absent(),
  }) : amount = Value(amount),
       type = Value(type),
       accountId = Value(accountId),
       transactionDate = Value(transactionDate);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? merchant,
    Expression<int>? categoryId,
    Expression<String>? paymentMethod,
    Expression<int>? accountId,
    Expression<int>? targetAccountId,
    Expression<double>? availableBalance,
    Expression<DateTime>? transactionDate,
    Expression<String>? notes,
    Expression<String>? originalSms,
    Expression<String>? bankTransactionId,
    Expression<String>? receiptAttachment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (merchant != null) 'merchant': merchant,
      if (categoryId != null) 'category_id': categoryId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (accountId != null) 'account_id': accountId,
      if (targetAccountId != null) 'target_account_id': targetAccountId,
      if (availableBalance != null) 'available_balance': availableBalance,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (notes != null) 'notes': notes,
      if (originalSms != null) 'original_sms': originalSms,
      if (bankTransactionId != null) 'bank_transaction_id': bankTransactionId,
      if (receiptAttachment != null) 'receipt_attachment': receiptAttachment,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<String>? type,
    Value<String?>? merchant,
    Value<int?>? categoryId,
    Value<String?>? paymentMethod,
    Value<int>? accountId,
    Value<int?>? targetAccountId,
    Value<double?>? availableBalance,
    Value<DateTime>? transactionDate,
    Value<String?>? notes,
    Value<String?>? originalSms,
    Value<String?>? bankTransactionId,
    Value<String?>? receiptAttachment,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      merchant: merchant ?? this.merchant,
      categoryId: categoryId ?? this.categoryId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      targetAccountId: targetAccountId ?? this.targetAccountId,
      availableBalance: availableBalance ?? this.availableBalance,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
      originalSms: originalSms ?? this.originalSms,
      bankTransactionId: bankTransactionId ?? this.bankTransactionId,
      receiptAttachment: receiptAttachment ?? this.receiptAttachment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (targetAccountId.present) {
      map['target_account_id'] = Variable<int>(targetAccountId.value);
    }
    if (availableBalance.present) {
      map['available_balance'] = Variable<double>(availableBalance.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (originalSms.present) {
      map['original_sms'] = Variable<String>(originalSms.value);
    }
    if (bankTransactionId.present) {
      map['bank_transaction_id'] = Variable<String>(bankTransactionId.value);
    }
    if (receiptAttachment.present) {
      map['receipt_attachment'] = Variable<String>(receiptAttachment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('merchant: $merchant, ')
          ..write('categoryId: $categoryId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('accountId: $accountId, ')
          ..write('targetAccountId: $targetAccountId, ')
          ..write('availableBalance: $availableBalance, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('notes: $notes, ')
          ..write('originalSms: $originalSms, ')
          ..write('bankTransactionId: $bankTransactionId, ')
          ..write('receiptAttachment: $receiptAttachment')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    month,
    year,
    categoryId,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class Budget extends DataClass implements Insertable<Budget> {
  final int id;
  final double amount;
  final int month;
  final int year;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  const Budget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.categoryId,
    this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'categoryId': serializer.toJson<int?>(categoryId),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  Budget copyWith({
    int? id,
    double? amount,
    int? month,
    int? year,
    Value<int?> categoryId = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => Budget(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    month: month ?? this.month,
    year: year ?? this.year,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, amount, month, year, categoryId, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.month == this.month &&
          other.year == this.year &&
          other.categoryId == this.categoryId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<int> id;
  final Value<double> amount;
  final Value<int> month;
  final Value<int> year;
  final Value<int?> categoryId;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required int month,
    required int year,
    this.categoryId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  }) : amount = Value(amount),
       month = Value(month),
       year = Value(year);
  static Insertable<Budget> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<int>? month,
    Expression<int>? year,
    Expression<int>? categoryId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  BudgetsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<int>? month,
    Value<int>? year,
    Value<int?>? categoryId,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationDateMeta = const VerificationMeta(
    'notificationDate',
  );
  @override
  late final GeneratedColumn<DateTime> notificationDate =
      GeneratedColumn<DateTime>(
        'notification_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    notificationDate,
    type,
    isRead,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Notification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('notification_date')) {
      context.handle(
        _notificationDateMeta,
        notificationDate.isAcceptableOrUnknown(
          data['notification_date']!,
          _notificationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationDateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      notificationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notification_date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final int id;
  final String title;
  final String body;
  final DateTime notificationDate;
  final String type;
  final bool isRead;
  final String? payload;
  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationDate,
    required this.type,
    required this.isRead,
    this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['notification_date'] = Variable<DateTime>(notificationDate);
    map['type'] = Variable<String>(type);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      notificationDate: Value(notificationDate),
      type: Value(type),
      isRead: Value(isRead),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
    );
  }

  factory Notification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      notificationDate: serializer.fromJson<DateTime>(json['notificationDate']),
      type: serializer.fromJson<String>(json['type']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      payload: serializer.fromJson<String?>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'notificationDate': serializer.toJson<DateTime>(notificationDate),
      'type': serializer.toJson<String>(type),
      'isRead': serializer.toJson<bool>(isRead),
      'payload': serializer.toJson<String?>(payload),
    };
  }

  Notification copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? notificationDate,
    String? type,
    bool? isRead,
    Value<String?> payload = const Value.absent(),
  }) => Notification(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    notificationDate: notificationDate ?? this.notificationDate,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    payload: payload.present ? payload.value : this.payload,
  );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      notificationDate: data.notificationDate.present
          ? data.notificationDate.value
          : this.notificationDate,
      type: data.type.present ? data.type.value : this.type,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('notificationDate: $notificationDate, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, notificationDate, type, isRead, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.notificationDate == this.notificationDate &&
          other.type == this.type &&
          other.isRead == this.isRead &&
          other.payload == this.payload);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> notificationDate;
  final Value<String> type;
  final Value<bool> isRead;
  final Value<String?> payload;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.notificationDate = const Value.absent(),
    this.type = const Value.absent(),
    this.isRead = const Value.absent(),
    this.payload = const Value.absent(),
  });
  NotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String body,
    required DateTime notificationDate,
    required String type,
    this.isRead = const Value.absent(),
    this.payload = const Value.absent(),
  }) : title = Value(title),
       body = Value(body),
       notificationDate = Value(notificationDate),
       type = Value(type);
  static Insertable<Notification> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? notificationDate,
    Expression<String>? type,
    Expression<bool>? isRead,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (notificationDate != null) 'notification_date': notificationDate,
      if (type != null) 'type': type,
      if (isRead != null) 'is_read': isRead,
      if (payload != null) 'payload': payload,
    });
  }

  NotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? notificationDate,
    Value<String>? type,
    Value<bool>? isRead,
    Value<String?>? payload,
  }) {
    return NotificationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      notificationDate: notificationDate ?? this.notificationDate,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (notificationDate.present) {
      map['notification_date'] = Variable<DateTime>(notificationDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('notificationDate: $notificationDate, ')
          ..write('type: $type, ')
          ..write('isRead: $isRead, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
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

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
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
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
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

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
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
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String? color;
  const Tag({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
    };
  }

  Tag copyWith({
    int? id,
    String? name,
    Value<String?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [transactionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId, tagId};
  @override
  TransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTag(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTag extends DataClass implements Insertable<TransactionTag> {
  final int transactionId;
  final int tagId;
  const TransactionTag({required this.transactionId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['transaction_id'] = Variable<int>(transactionId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      transactionId: Value(transactionId),
      tagId: Value(tagId),
    );
  }

  factory TransactionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTag(
      transactionId: serializer.fromJson<int>(json['transactionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<int>(transactionId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  TransactionTag copyWith({int? transactionId, int? tagId}) => TransactionTag(
    transactionId: transactionId ?? this.transactionId,
    tagId: tagId ?? this.tagId,
  );
  TransactionTag copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTag(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTag(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(transactionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTag &&
          other.transactionId == this.transactionId &&
          other.tagId == this.tagId);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTag> {
  final Value<int> transactionId;
  final Value<int> tagId;
  final Value<int> rowid;
  const TransactionTagsCompanion({
    this.transactionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    required int transactionId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       tagId = Value(tagId);
  static Insertable<TransactionTag> custom({
    Expression<int>? transactionId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'transaction_id': transactionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<int>? transactionId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return TransactionTagsCompanion(
      transactionId: transactionId ?? this.transactionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnrecognizedSmsTable extends UnrecognizedSms
    with TableInfo<$UnrecognizedSmsTable, UnrecognizedSm> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnrecognizedSmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sender, body, receivedAt, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unrecognized_sms';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnrecognizedSm> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnrecognizedSm map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnrecognizedSm(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $UnrecognizedSmsTable createAlias(String alias) {
    return $UnrecognizedSmsTable(attachedDatabase, alias);
  }
}

class UnrecognizedSm extends DataClass implements Insertable<UnrecognizedSm> {
  final int id;
  final String sender;
  final String body;
  final DateTime receivedAt;
  final String? reason;
  const UnrecognizedSm({
    required this.id,
    required this.sender,
    required this.body,
    required this.receivedAt,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender'] = Variable<String>(sender);
    map['body'] = Variable<String>(body);
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  UnrecognizedSmsCompanion toCompanion(bool nullToAbsent) {
    return UnrecognizedSmsCompanion(
      id: Value(id),
      sender: Value(sender),
      body: Value(body),
      receivedAt: Value(receivedAt),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory UnrecognizedSm.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnrecognizedSm(
      id: serializer.fromJson<int>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      body: serializer.fromJson<String>(json['body']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sender': serializer.toJson<String>(sender),
      'body': serializer.toJson<String>(body),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  UnrecognizedSm copyWith({
    int? id,
    String? sender,
    String? body,
    DateTime? receivedAt,
    Value<String?> reason = const Value.absent(),
  }) => UnrecognizedSm(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    body: body ?? this.body,
    receivedAt: receivedAt ?? this.receivedAt,
    reason: reason.present ? reason.value : this.reason,
  );
  UnrecognizedSm copyWithCompanion(UnrecognizedSmsCompanion data) {
    return UnrecognizedSm(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      body: data.body.present ? data.body.value : this.body,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnrecognizedSm(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sender, body, receivedAt, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnrecognizedSm &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.body == this.body &&
          other.receivedAt == this.receivedAt &&
          other.reason == this.reason);
}

class UnrecognizedSmsCompanion extends UpdateCompanion<UnrecognizedSm> {
  final Value<int> id;
  final Value<String> sender;
  final Value<String> body;
  final Value<DateTime> receivedAt;
  final Value<String?> reason;
  const UnrecognizedSmsCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.body = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.reason = const Value.absent(),
  });
  UnrecognizedSmsCompanion.insert({
    this.id = const Value.absent(),
    required String sender,
    required String body,
    required DateTime receivedAt,
    this.reason = const Value.absent(),
  }) : sender = Value(sender),
       body = Value(body),
       receivedAt = Value(receivedAt);
  static Insertable<UnrecognizedSm> custom({
    Expression<int>? id,
    Expression<String>? sender,
    Expression<String>? body,
    Expression<DateTime>? receivedAt,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (body != null) 'body': body,
      if (receivedAt != null) 'received_at': receivedAt,
      if (reason != null) 'reason': reason,
    });
  }

  UnrecognizedSmsCompanion copyWith({
    Value<int>? id,
    Value<String>? sender,
    Value<String>? body,
    Value<DateTime>? receivedAt,
    Value<String?>? reason,
  }) {
    return UnrecognizedSmsCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnrecognizedSmsCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

class $SavedSummariesTable extends SavedSummaries
    with TableInfo<$SavedSummariesTable, SavedSummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalExpenseMeta = const VerificationMeta(
    'totalExpense',
  );
  @override
  late final GeneratedColumn<double> totalExpense = GeneratedColumn<double>(
    'total_expense',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topCategoryMeta = const VerificationMeta(
    'topCategory',
  );
  @override
  late final GeneratedColumn<String> topCategory = GeneratedColumn<String>(
    'top_category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topCategoryAmountMeta = const VerificationMeta(
    'topCategoryAmount',
  );
  @override
  late final GeneratedColumn<double> topCategoryAmount =
      GeneratedColumn<double>(
        'top_category_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _topMerchantMeta = const VerificationMeta(
    'topMerchant',
  );
  @override
  late final GeneratedColumn<String> topMerchant = GeneratedColumn<String>(
    'top_merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionCountMeta = const VerificationMeta(
    'transactionCount',
  );
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
    'transaction_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    month,
    year,
    totalExpense,
    topCategory,
    topCategoryAmount,
    topMerchant,
    transactionCount,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedSummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('total_expense')) {
      context.handle(
        _totalExpenseMeta,
        totalExpense.isAcceptableOrUnknown(
          data['total_expense']!,
          _totalExpenseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalExpenseMeta);
    }
    if (data.containsKey('top_category')) {
      context.handle(
        _topCategoryMeta,
        topCategory.isAcceptableOrUnknown(
          data['top_category']!,
          _topCategoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topCategoryMeta);
    }
    if (data.containsKey('top_category_amount')) {
      context.handle(
        _topCategoryAmountMeta,
        topCategoryAmount.isAcceptableOrUnknown(
          data['top_category_amount']!,
          _topCategoryAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_topCategoryAmountMeta);
    }
    if (data.containsKey('top_merchant')) {
      context.handle(
        _topMerchantMeta,
        topMerchant.isAcceptableOrUnknown(
          data['top_merchant']!,
          _topMerchantMeta,
        ),
      );
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
        _transactionCountMeta,
        transactionCount.isAcceptableOrUnknown(
          data['transaction_count']!,
          _transactionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionCountMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedSummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      totalExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_expense'],
      )!,
      topCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_category'],
      )!,
      topCategoryAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}top_category_amount'],
      )!,
      topMerchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top_merchant'],
      ),
      transactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_count'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $SavedSummariesTable createAlias(String alias) {
    return $SavedSummariesTable(attachedDatabase, alias);
  }
}

class SavedSummary extends DataClass implements Insertable<SavedSummary> {
  final int id;
  final int month;
  final int year;
  final double totalExpense;
  final String topCategory;
  final double topCategoryAmount;
  final String? topMerchant;
  final int transactionCount;
  final DateTime generatedAt;
  const SavedSummary({
    required this.id,
    required this.month,
    required this.year,
    required this.totalExpense,
    required this.topCategory,
    required this.topCategoryAmount,
    this.topMerchant,
    required this.transactionCount,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['month'] = Variable<int>(month);
    map['year'] = Variable<int>(year);
    map['total_expense'] = Variable<double>(totalExpense);
    map['top_category'] = Variable<String>(topCategory);
    map['top_category_amount'] = Variable<double>(topCategoryAmount);
    if (!nullToAbsent || topMerchant != null) {
      map['top_merchant'] = Variable<String>(topMerchant);
    }
    map['transaction_count'] = Variable<int>(transactionCount);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  SavedSummariesCompanion toCompanion(bool nullToAbsent) {
    return SavedSummariesCompanion(
      id: Value(id),
      month: Value(month),
      year: Value(year),
      totalExpense: Value(totalExpense),
      topCategory: Value(topCategory),
      topCategoryAmount: Value(topCategoryAmount),
      topMerchant: topMerchant == null && nullToAbsent
          ? const Value.absent()
          : Value(topMerchant),
      transactionCount: Value(transactionCount),
      generatedAt: Value(generatedAt),
    );
  }

  factory SavedSummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSummary(
      id: serializer.fromJson<int>(json['id']),
      month: serializer.fromJson<int>(json['month']),
      year: serializer.fromJson<int>(json['year']),
      totalExpense: serializer.fromJson<double>(json['totalExpense']),
      topCategory: serializer.fromJson<String>(json['topCategory']),
      topCategoryAmount: serializer.fromJson<double>(json['topCategoryAmount']),
      topMerchant: serializer.fromJson<String?>(json['topMerchant']),
      transactionCount: serializer.fromJson<int>(json['transactionCount']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'month': serializer.toJson<int>(month),
      'year': serializer.toJson<int>(year),
      'totalExpense': serializer.toJson<double>(totalExpense),
      'topCategory': serializer.toJson<String>(topCategory),
      'topCategoryAmount': serializer.toJson<double>(topCategoryAmount),
      'topMerchant': serializer.toJson<String?>(topMerchant),
      'transactionCount': serializer.toJson<int>(transactionCount),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  SavedSummary copyWith({
    int? id,
    int? month,
    int? year,
    double? totalExpense,
    String? topCategory,
    double? topCategoryAmount,
    Value<String?> topMerchant = const Value.absent(),
    int? transactionCount,
    DateTime? generatedAt,
  }) => SavedSummary(
    id: id ?? this.id,
    month: month ?? this.month,
    year: year ?? this.year,
    totalExpense: totalExpense ?? this.totalExpense,
    topCategory: topCategory ?? this.topCategory,
    topCategoryAmount: topCategoryAmount ?? this.topCategoryAmount,
    topMerchant: topMerchant.present ? topMerchant.value : this.topMerchant,
    transactionCount: transactionCount ?? this.transactionCount,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  SavedSummary copyWithCompanion(SavedSummariesCompanion data) {
    return SavedSummary(
      id: data.id.present ? data.id.value : this.id,
      month: data.month.present ? data.month.value : this.month,
      year: data.year.present ? data.year.value : this.year,
      totalExpense: data.totalExpense.present
          ? data.totalExpense.value
          : this.totalExpense,
      topCategory: data.topCategory.present
          ? data.topCategory.value
          : this.topCategory,
      topCategoryAmount: data.topCategoryAmount.present
          ? data.topCategoryAmount.value
          : this.topCategoryAmount,
      topMerchant: data.topMerchant.present
          ? data.topMerchant.value
          : this.topMerchant,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSummary(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('topCategory: $topCategory, ')
          ..write('topCategoryAmount: $topCategoryAmount, ')
          ..write('topMerchant: $topMerchant, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    month,
    year,
    totalExpense,
    topCategory,
    topCategoryAmount,
    topMerchant,
    transactionCount,
    generatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSummary &&
          other.id == this.id &&
          other.month == this.month &&
          other.year == this.year &&
          other.totalExpense == this.totalExpense &&
          other.topCategory == this.topCategory &&
          other.topCategoryAmount == this.topCategoryAmount &&
          other.topMerchant == this.topMerchant &&
          other.transactionCount == this.transactionCount &&
          other.generatedAt == this.generatedAt);
}

class SavedSummariesCompanion extends UpdateCompanion<SavedSummary> {
  final Value<int> id;
  final Value<int> month;
  final Value<int> year;
  final Value<double> totalExpense;
  final Value<String> topCategory;
  final Value<double> topCategoryAmount;
  final Value<String?> topMerchant;
  final Value<int> transactionCount;
  final Value<DateTime> generatedAt;
  const SavedSummariesCompanion({
    this.id = const Value.absent(),
    this.month = const Value.absent(),
    this.year = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.topCategory = const Value.absent(),
    this.topCategoryAmount = const Value.absent(),
    this.topMerchant = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  SavedSummariesCompanion.insert({
    this.id = const Value.absent(),
    required int month,
    required int year,
    required double totalExpense,
    required String topCategory,
    required double topCategoryAmount,
    this.topMerchant = const Value.absent(),
    required int transactionCount,
    this.generatedAt = const Value.absent(),
  }) : month = Value(month),
       year = Value(year),
       totalExpense = Value(totalExpense),
       topCategory = Value(topCategory),
       topCategoryAmount = Value(topCategoryAmount),
       transactionCount = Value(transactionCount);
  static Insertable<SavedSummary> custom({
    Expression<int>? id,
    Expression<int>? month,
    Expression<int>? year,
    Expression<double>? totalExpense,
    Expression<String>? topCategory,
    Expression<double>? topCategoryAmount,
    Expression<String>? topMerchant,
    Expression<int>? transactionCount,
    Expression<DateTime>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (month != null) 'month': month,
      if (year != null) 'year': year,
      if (totalExpense != null) 'total_expense': totalExpense,
      if (topCategory != null) 'top_category': topCategory,
      if (topCategoryAmount != null) 'top_category_amount': topCategoryAmount,
      if (topMerchant != null) 'top_merchant': topMerchant,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  SavedSummariesCompanion copyWith({
    Value<int>? id,
    Value<int>? month,
    Value<int>? year,
    Value<double>? totalExpense,
    Value<String>? topCategory,
    Value<double>? topCategoryAmount,
    Value<String?>? topMerchant,
    Value<int>? transactionCount,
    Value<DateTime>? generatedAt,
  }) {
    return SavedSummariesCompanion(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      totalExpense: totalExpense ?? this.totalExpense,
      topCategory: topCategory ?? this.topCategory,
      topCategoryAmount: topCategoryAmount ?? this.topCategoryAmount,
      topMerchant: topMerchant ?? this.topMerchant,
      transactionCount: transactionCount ?? this.transactionCount,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (totalExpense.present) {
      map['total_expense'] = Variable<double>(totalExpense.value);
    }
    if (topCategory.present) {
      map['top_category'] = Variable<String>(topCategory.value);
    }
    if (topCategoryAmount.present) {
      map['top_category_amount'] = Variable<double>(topCategoryAmount.value);
    }
    if (topMerchant.present) {
      map['top_merchant'] = Variable<String>(topMerchant.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSummariesCompanion(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('year: $year, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('topCategory: $topCategory, ')
          ..write('topCategoryAmount: $topCategoryAmount, ')
          ..write('topMerchant: $topMerchant, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationSettingsDbTable extends NotificationSettingsDb
    with TableInfo<$NotificationSettingsDbTable, NotificationSettingsDbData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationSettingsDbTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dailySummaryEnabledMeta =
      const VerificationMeta('dailySummaryEnabled');
  @override
  late final GeneratedColumn<bool> dailySummaryEnabled = GeneratedColumn<bool>(
    'daily_summary_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("daily_summary_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _weeklySummaryEnabledMeta =
      const VerificationMeta('weeklySummaryEnabled');
  @override
  late final GeneratedColumn<bool> weeklySummaryEnabled = GeneratedColumn<bool>(
    'weekly_summary_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weekly_summary_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _monthlySummaryEnabledMeta =
      const VerificationMeta('monthlySummaryEnabled');
  @override
  late final GeneratedColumn<bool> monthlySummaryEnabled =
      GeneratedColumn<bool>(
        'monthly_summary_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("monthly_summary_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _budgetAlertsEnabledMeta =
      const VerificationMeta('budgetAlertsEnabled');
  @override
  late final GeneratedColumn<bool> budgetAlertsEnabled = GeneratedColumn<bool>(
    'budget_alerts_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("budget_alerts_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _goalRemindersEnabledMeta =
      const VerificationMeta('goalRemindersEnabled');
  @override
  late final GeneratedColumn<bool> goalRemindersEnabled = GeneratedColumn<bool>(
    'goal_reminders_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("goal_reminders_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smsDetectionEnabledMeta =
      const VerificationMeta('smsDetectionEnabled');
  @override
  late final GeneratedColumn<bool> smsDetectionEnabled = GeneratedColumn<bool>(
    'sms_detection_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sms_detection_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _largeExpenseAlertsEnabledMeta =
      const VerificationMeta('largeExpenseAlertsEnabled');
  @override
  late final GeneratedColumn<bool> largeExpenseAlertsEnabled =
      GeneratedColumn<bool>(
        'large_expense_alerts_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("large_expense_alerts_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _smartInsightsEnabledMeta =
      const VerificationMeta('smartInsightsEnabled');
  @override
  late final GeneratedColumn<bool> smartInsightsEnabled = GeneratedColumn<bool>(
    'smart_insights_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("smart_insights_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _quietHoursEnabledMeta = const VerificationMeta(
    'quietHoursEnabled',
  );
  @override
  late final GeneratedColumn<bool> quietHoursEnabled = GeneratedColumn<bool>(
    'quiet_hours_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_hours_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _largeExpenseThresholdMeta =
      const VerificationMeta('largeExpenseThreshold');
  @override
  late final GeneratedColumn<double> largeExpenseThreshold =
      GeneratedColumn<double>(
        'large_expense_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(10000.0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailySummaryEnabled,
    weeklySummaryEnabled,
    monthlySummaryEnabled,
    budgetAlertsEnabled,
    goalRemindersEnabled,
    smsDetectionEnabled,
    largeExpenseAlertsEnabled,
    smartInsightsEnabled,
    quietHoursEnabled,
    largeExpenseThreshold,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_settings_db';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationSettingsDbData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_summary_enabled')) {
      context.handle(
        _dailySummaryEnabledMeta,
        dailySummaryEnabled.isAcceptableOrUnknown(
          data['daily_summary_enabled']!,
          _dailySummaryEnabledMeta,
        ),
      );
    }
    if (data.containsKey('weekly_summary_enabled')) {
      context.handle(
        _weeklySummaryEnabledMeta,
        weeklySummaryEnabled.isAcceptableOrUnknown(
          data['weekly_summary_enabled']!,
          _weeklySummaryEnabledMeta,
        ),
      );
    }
    if (data.containsKey('monthly_summary_enabled')) {
      context.handle(
        _monthlySummaryEnabledMeta,
        monthlySummaryEnabled.isAcceptableOrUnknown(
          data['monthly_summary_enabled']!,
          _monthlySummaryEnabledMeta,
        ),
      );
    }
    if (data.containsKey('budget_alerts_enabled')) {
      context.handle(
        _budgetAlertsEnabledMeta,
        budgetAlertsEnabled.isAcceptableOrUnknown(
          data['budget_alerts_enabled']!,
          _budgetAlertsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('goal_reminders_enabled')) {
      context.handle(
        _goalRemindersEnabledMeta,
        goalRemindersEnabled.isAcceptableOrUnknown(
          data['goal_reminders_enabled']!,
          _goalRemindersEnabledMeta,
        ),
      );
    }
    if (data.containsKey('sms_detection_enabled')) {
      context.handle(
        _smsDetectionEnabledMeta,
        smsDetectionEnabled.isAcceptableOrUnknown(
          data['sms_detection_enabled']!,
          _smsDetectionEnabledMeta,
        ),
      );
    }
    if (data.containsKey('large_expense_alerts_enabled')) {
      context.handle(
        _largeExpenseAlertsEnabledMeta,
        largeExpenseAlertsEnabled.isAcceptableOrUnknown(
          data['large_expense_alerts_enabled']!,
          _largeExpenseAlertsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('smart_insights_enabled')) {
      context.handle(
        _smartInsightsEnabledMeta,
        smartInsightsEnabled.isAcceptableOrUnknown(
          data['smart_insights_enabled']!,
          _smartInsightsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_enabled')) {
      context.handle(
        _quietHoursEnabledMeta,
        quietHoursEnabled.isAcceptableOrUnknown(
          data['quiet_hours_enabled']!,
          _quietHoursEnabledMeta,
        ),
      );
    }
    if (data.containsKey('large_expense_threshold')) {
      context.handle(
        _largeExpenseThresholdMeta,
        largeExpenseThreshold.isAcceptableOrUnknown(
          data['large_expense_threshold']!,
          _largeExpenseThresholdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationSettingsDbData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationSettingsDbData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailySummaryEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}daily_summary_enabled'],
      )!,
      weeklySummaryEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weekly_summary_enabled'],
      )!,
      monthlySummaryEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}monthly_summary_enabled'],
      )!,
      budgetAlertsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}budget_alerts_enabled'],
      )!,
      goalRemindersEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}goal_reminders_enabled'],
      )!,
      smsDetectionEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sms_detection_enabled'],
      )!,
      largeExpenseAlertsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}large_expense_alerts_enabled'],
      )!,
      smartInsightsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}smart_insights_enabled'],
      )!,
      quietHoursEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_hours_enabled'],
      )!,
      largeExpenseThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}large_expense_threshold'],
      )!,
    );
  }

  @override
  $NotificationSettingsDbTable createAlias(String alias) {
    return $NotificationSettingsDbTable(attachedDatabase, alias);
  }
}

class NotificationSettingsDbData extends DataClass
    implements Insertable<NotificationSettingsDbData> {
  final int id;
  final bool dailySummaryEnabled;
  final bool weeklySummaryEnabled;
  final bool monthlySummaryEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final bool smsDetectionEnabled;
  final bool largeExpenseAlertsEnabled;
  final bool smartInsightsEnabled;
  final bool quietHoursEnabled;
  final double largeExpenseThreshold;
  const NotificationSettingsDbData({
    required this.id,
    required this.dailySummaryEnabled,
    required this.weeklySummaryEnabled,
    required this.monthlySummaryEnabled,
    required this.budgetAlertsEnabled,
    required this.goalRemindersEnabled,
    required this.smsDetectionEnabled,
    required this.largeExpenseAlertsEnabled,
    required this.smartInsightsEnabled,
    required this.quietHoursEnabled,
    required this.largeExpenseThreshold,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_summary_enabled'] = Variable<bool>(dailySummaryEnabled);
    map['weekly_summary_enabled'] = Variable<bool>(weeklySummaryEnabled);
    map['monthly_summary_enabled'] = Variable<bool>(monthlySummaryEnabled);
    map['budget_alerts_enabled'] = Variable<bool>(budgetAlertsEnabled);
    map['goal_reminders_enabled'] = Variable<bool>(goalRemindersEnabled);
    map['sms_detection_enabled'] = Variable<bool>(smsDetectionEnabled);
    map['large_expense_alerts_enabled'] = Variable<bool>(
      largeExpenseAlertsEnabled,
    );
    map['smart_insights_enabled'] = Variable<bool>(smartInsightsEnabled);
    map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled);
    map['large_expense_threshold'] = Variable<double>(largeExpenseThreshold);
    return map;
  }

  NotificationSettingsDbCompanion toCompanion(bool nullToAbsent) {
    return NotificationSettingsDbCompanion(
      id: Value(id),
      dailySummaryEnabled: Value(dailySummaryEnabled),
      weeklySummaryEnabled: Value(weeklySummaryEnabled),
      monthlySummaryEnabled: Value(monthlySummaryEnabled),
      budgetAlertsEnabled: Value(budgetAlertsEnabled),
      goalRemindersEnabled: Value(goalRemindersEnabled),
      smsDetectionEnabled: Value(smsDetectionEnabled),
      largeExpenseAlertsEnabled: Value(largeExpenseAlertsEnabled),
      smartInsightsEnabled: Value(smartInsightsEnabled),
      quietHoursEnabled: Value(quietHoursEnabled),
      largeExpenseThreshold: Value(largeExpenseThreshold),
    );
  }

  factory NotificationSettingsDbData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationSettingsDbData(
      id: serializer.fromJson<int>(json['id']),
      dailySummaryEnabled: serializer.fromJson<bool>(
        json['dailySummaryEnabled'],
      ),
      weeklySummaryEnabled: serializer.fromJson<bool>(
        json['weeklySummaryEnabled'],
      ),
      monthlySummaryEnabled: serializer.fromJson<bool>(
        json['monthlySummaryEnabled'],
      ),
      budgetAlertsEnabled: serializer.fromJson<bool>(
        json['budgetAlertsEnabled'],
      ),
      goalRemindersEnabled: serializer.fromJson<bool>(
        json['goalRemindersEnabled'],
      ),
      smsDetectionEnabled: serializer.fromJson<bool>(
        json['smsDetectionEnabled'],
      ),
      largeExpenseAlertsEnabled: serializer.fromJson<bool>(
        json['largeExpenseAlertsEnabled'],
      ),
      smartInsightsEnabled: serializer.fromJson<bool>(
        json['smartInsightsEnabled'],
      ),
      quietHoursEnabled: serializer.fromJson<bool>(json['quietHoursEnabled']),
      largeExpenseThreshold: serializer.fromJson<double>(
        json['largeExpenseThreshold'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailySummaryEnabled': serializer.toJson<bool>(dailySummaryEnabled),
      'weeklySummaryEnabled': serializer.toJson<bool>(weeklySummaryEnabled),
      'monthlySummaryEnabled': serializer.toJson<bool>(monthlySummaryEnabled),
      'budgetAlertsEnabled': serializer.toJson<bool>(budgetAlertsEnabled),
      'goalRemindersEnabled': serializer.toJson<bool>(goalRemindersEnabled),
      'smsDetectionEnabled': serializer.toJson<bool>(smsDetectionEnabled),
      'largeExpenseAlertsEnabled': serializer.toJson<bool>(
        largeExpenseAlertsEnabled,
      ),
      'smartInsightsEnabled': serializer.toJson<bool>(smartInsightsEnabled),
      'quietHoursEnabled': serializer.toJson<bool>(quietHoursEnabled),
      'largeExpenseThreshold': serializer.toJson<double>(largeExpenseThreshold),
    };
  }

  NotificationSettingsDbData copyWith({
    int? id,
    bool? dailySummaryEnabled,
    bool? weeklySummaryEnabled,
    bool? monthlySummaryEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    bool? smsDetectionEnabled,
    bool? largeExpenseAlertsEnabled,
    bool? smartInsightsEnabled,
    bool? quietHoursEnabled,
    double? largeExpenseThreshold,
  }) => NotificationSettingsDbData(
    id: id ?? this.id,
    dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
    weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
    monthlySummaryEnabled: monthlySummaryEnabled ?? this.monthlySummaryEnabled,
    budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
    goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
    smsDetectionEnabled: smsDetectionEnabled ?? this.smsDetectionEnabled,
    largeExpenseAlertsEnabled:
        largeExpenseAlertsEnabled ?? this.largeExpenseAlertsEnabled,
    smartInsightsEnabled: smartInsightsEnabled ?? this.smartInsightsEnabled,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    largeExpenseThreshold: largeExpenseThreshold ?? this.largeExpenseThreshold,
  );
  NotificationSettingsDbData copyWithCompanion(
    NotificationSettingsDbCompanion data,
  ) {
    return NotificationSettingsDbData(
      id: data.id.present ? data.id.value : this.id,
      dailySummaryEnabled: data.dailySummaryEnabled.present
          ? data.dailySummaryEnabled.value
          : this.dailySummaryEnabled,
      weeklySummaryEnabled: data.weeklySummaryEnabled.present
          ? data.weeklySummaryEnabled.value
          : this.weeklySummaryEnabled,
      monthlySummaryEnabled: data.monthlySummaryEnabled.present
          ? data.monthlySummaryEnabled.value
          : this.monthlySummaryEnabled,
      budgetAlertsEnabled: data.budgetAlertsEnabled.present
          ? data.budgetAlertsEnabled.value
          : this.budgetAlertsEnabled,
      goalRemindersEnabled: data.goalRemindersEnabled.present
          ? data.goalRemindersEnabled.value
          : this.goalRemindersEnabled,
      smsDetectionEnabled: data.smsDetectionEnabled.present
          ? data.smsDetectionEnabled.value
          : this.smsDetectionEnabled,
      largeExpenseAlertsEnabled: data.largeExpenseAlertsEnabled.present
          ? data.largeExpenseAlertsEnabled.value
          : this.largeExpenseAlertsEnabled,
      smartInsightsEnabled: data.smartInsightsEnabled.present
          ? data.smartInsightsEnabled.value
          : this.smartInsightsEnabled,
      quietHoursEnabled: data.quietHoursEnabled.present
          ? data.quietHoursEnabled.value
          : this.quietHoursEnabled,
      largeExpenseThreshold: data.largeExpenseThreshold.present
          ? data.largeExpenseThreshold.value
          : this.largeExpenseThreshold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsDbData(')
          ..write('id: $id, ')
          ..write('dailySummaryEnabled: $dailySummaryEnabled, ')
          ..write('weeklySummaryEnabled: $weeklySummaryEnabled, ')
          ..write('monthlySummaryEnabled: $monthlySummaryEnabled, ')
          ..write('budgetAlertsEnabled: $budgetAlertsEnabled, ')
          ..write('goalRemindersEnabled: $goalRemindersEnabled, ')
          ..write('smsDetectionEnabled: $smsDetectionEnabled, ')
          ..write('largeExpenseAlertsEnabled: $largeExpenseAlertsEnabled, ')
          ..write('smartInsightsEnabled: $smartInsightsEnabled, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('largeExpenseThreshold: $largeExpenseThreshold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dailySummaryEnabled,
    weeklySummaryEnabled,
    monthlySummaryEnabled,
    budgetAlertsEnabled,
    goalRemindersEnabled,
    smsDetectionEnabled,
    largeExpenseAlertsEnabled,
    smartInsightsEnabled,
    quietHoursEnabled,
    largeExpenseThreshold,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationSettingsDbData &&
          other.id == this.id &&
          other.dailySummaryEnabled == this.dailySummaryEnabled &&
          other.weeklySummaryEnabled == this.weeklySummaryEnabled &&
          other.monthlySummaryEnabled == this.monthlySummaryEnabled &&
          other.budgetAlertsEnabled == this.budgetAlertsEnabled &&
          other.goalRemindersEnabled == this.goalRemindersEnabled &&
          other.smsDetectionEnabled == this.smsDetectionEnabled &&
          other.largeExpenseAlertsEnabled == this.largeExpenseAlertsEnabled &&
          other.smartInsightsEnabled == this.smartInsightsEnabled &&
          other.quietHoursEnabled == this.quietHoursEnabled &&
          other.largeExpenseThreshold == this.largeExpenseThreshold);
}

class NotificationSettingsDbCompanion
    extends UpdateCompanion<NotificationSettingsDbData> {
  final Value<int> id;
  final Value<bool> dailySummaryEnabled;
  final Value<bool> weeklySummaryEnabled;
  final Value<bool> monthlySummaryEnabled;
  final Value<bool> budgetAlertsEnabled;
  final Value<bool> goalRemindersEnabled;
  final Value<bool> smsDetectionEnabled;
  final Value<bool> largeExpenseAlertsEnabled;
  final Value<bool> smartInsightsEnabled;
  final Value<bool> quietHoursEnabled;
  final Value<double> largeExpenseThreshold;
  const NotificationSettingsDbCompanion({
    this.id = const Value.absent(),
    this.dailySummaryEnabled = const Value.absent(),
    this.weeklySummaryEnabled = const Value.absent(),
    this.monthlySummaryEnabled = const Value.absent(),
    this.budgetAlertsEnabled = const Value.absent(),
    this.goalRemindersEnabled = const Value.absent(),
    this.smsDetectionEnabled = const Value.absent(),
    this.largeExpenseAlertsEnabled = const Value.absent(),
    this.smartInsightsEnabled = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.largeExpenseThreshold = const Value.absent(),
  });
  NotificationSettingsDbCompanion.insert({
    this.id = const Value.absent(),
    this.dailySummaryEnabled = const Value.absent(),
    this.weeklySummaryEnabled = const Value.absent(),
    this.monthlySummaryEnabled = const Value.absent(),
    this.budgetAlertsEnabled = const Value.absent(),
    this.goalRemindersEnabled = const Value.absent(),
    this.smsDetectionEnabled = const Value.absent(),
    this.largeExpenseAlertsEnabled = const Value.absent(),
    this.smartInsightsEnabled = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.largeExpenseThreshold = const Value.absent(),
  });
  static Insertable<NotificationSettingsDbData> custom({
    Expression<int>? id,
    Expression<bool>? dailySummaryEnabled,
    Expression<bool>? weeklySummaryEnabled,
    Expression<bool>? monthlySummaryEnabled,
    Expression<bool>? budgetAlertsEnabled,
    Expression<bool>? goalRemindersEnabled,
    Expression<bool>? smsDetectionEnabled,
    Expression<bool>? largeExpenseAlertsEnabled,
    Expression<bool>? smartInsightsEnabled,
    Expression<bool>? quietHoursEnabled,
    Expression<double>? largeExpenseThreshold,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailySummaryEnabled != null)
        'daily_summary_enabled': dailySummaryEnabled,
      if (weeklySummaryEnabled != null)
        'weekly_summary_enabled': weeklySummaryEnabled,
      if (monthlySummaryEnabled != null)
        'monthly_summary_enabled': monthlySummaryEnabled,
      if (budgetAlertsEnabled != null)
        'budget_alerts_enabled': budgetAlertsEnabled,
      if (goalRemindersEnabled != null)
        'goal_reminders_enabled': goalRemindersEnabled,
      if (smsDetectionEnabled != null)
        'sms_detection_enabled': smsDetectionEnabled,
      if (largeExpenseAlertsEnabled != null)
        'large_expense_alerts_enabled': largeExpenseAlertsEnabled,
      if (smartInsightsEnabled != null)
        'smart_insights_enabled': smartInsightsEnabled,
      if (quietHoursEnabled != null) 'quiet_hours_enabled': quietHoursEnabled,
      if (largeExpenseThreshold != null)
        'large_expense_threshold': largeExpenseThreshold,
    });
  }

  NotificationSettingsDbCompanion copyWith({
    Value<int>? id,
    Value<bool>? dailySummaryEnabled,
    Value<bool>? weeklySummaryEnabled,
    Value<bool>? monthlySummaryEnabled,
    Value<bool>? budgetAlertsEnabled,
    Value<bool>? goalRemindersEnabled,
    Value<bool>? smsDetectionEnabled,
    Value<bool>? largeExpenseAlertsEnabled,
    Value<bool>? smartInsightsEnabled,
    Value<bool>? quietHoursEnabled,
    Value<double>? largeExpenseThreshold,
  }) {
    return NotificationSettingsDbCompanion(
      id: id ?? this.id,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      weeklySummaryEnabled: weeklySummaryEnabled ?? this.weeklySummaryEnabled,
      monthlySummaryEnabled:
          monthlySummaryEnabled ?? this.monthlySummaryEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      smsDetectionEnabled: smsDetectionEnabled ?? this.smsDetectionEnabled,
      largeExpenseAlertsEnabled:
          largeExpenseAlertsEnabled ?? this.largeExpenseAlertsEnabled,
      smartInsightsEnabled: smartInsightsEnabled ?? this.smartInsightsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      largeExpenseThreshold:
          largeExpenseThreshold ?? this.largeExpenseThreshold,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailySummaryEnabled.present) {
      map['daily_summary_enabled'] = Variable<bool>(dailySummaryEnabled.value);
    }
    if (weeklySummaryEnabled.present) {
      map['weekly_summary_enabled'] = Variable<bool>(
        weeklySummaryEnabled.value,
      );
    }
    if (monthlySummaryEnabled.present) {
      map['monthly_summary_enabled'] = Variable<bool>(
        monthlySummaryEnabled.value,
      );
    }
    if (budgetAlertsEnabled.present) {
      map['budget_alerts_enabled'] = Variable<bool>(budgetAlertsEnabled.value);
    }
    if (goalRemindersEnabled.present) {
      map['goal_reminders_enabled'] = Variable<bool>(
        goalRemindersEnabled.value,
      );
    }
    if (smsDetectionEnabled.present) {
      map['sms_detection_enabled'] = Variable<bool>(smsDetectionEnabled.value);
    }
    if (largeExpenseAlertsEnabled.present) {
      map['large_expense_alerts_enabled'] = Variable<bool>(
        largeExpenseAlertsEnabled.value,
      );
    }
    if (smartInsightsEnabled.present) {
      map['smart_insights_enabled'] = Variable<bool>(
        smartInsightsEnabled.value,
      );
    }
    if (quietHoursEnabled.present) {
      map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled.value);
    }
    if (largeExpenseThreshold.present) {
      map['large_expense_threshold'] = Variable<double>(
        largeExpenseThreshold.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationSettingsDbCompanion(')
          ..write('id: $id, ')
          ..write('dailySummaryEnabled: $dailySummaryEnabled, ')
          ..write('weeklySummaryEnabled: $weeklySummaryEnabled, ')
          ..write('monthlySummaryEnabled: $monthlySummaryEnabled, ')
          ..write('budgetAlertsEnabled: $budgetAlertsEnabled, ')
          ..write('goalRemindersEnabled: $goalRemindersEnabled, ')
          ..write('smsDetectionEnabled: $smsDetectionEnabled, ')
          ..write('largeExpenseAlertsEnabled: $largeExpenseAlertsEnabled, ')
          ..write('smartInsightsEnabled: $smartInsightsEnabled, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('largeExpenseThreshold: $largeExpenseThreshold')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $UnrecognizedSmsTable unrecognizedSms = $UnrecognizedSmsTable(
    this,
  );
  late final $SavedSummariesTable savedSummaries = $SavedSummariesTable(this);
  late final $NotificationSettingsDbTable notificationSettingsDb =
      $NotificationSettingsDbTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    transactions,
    budgets,
    notifications,
    settings,
    tags,
    transactionTags,
    unrecognizedSms,
    savedSummaries,
    notificationSettingsDb,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String bankName,
      Value<int> totalTransactions,
      Value<double> totalIncome,
      Value<double> totalExpenses,
      Value<DateTime?> lastTransactionDate,
      Value<double?> availableBalance,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isHidden,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> bankName,
      Value<int> totalTransactions,
      Value<double> totalIncome,
      Value<double> totalExpenses,
      Value<DateTime?> lastTransactionDate,
      Value<double?> availableBalance,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isHidden,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTransactionDate => $composableBuilder(
    column: $table.lastTransactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTransactionDate => $composableBuilder(
    column: $table.lastTransactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<int> get totalTransactions => $composableBuilder(
    column: $table.totalTransactions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalIncome => $composableBuilder(
    column: $table.totalIncome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalExpenses => $composableBuilder(
    column: $table.totalExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastTransactionDate => $composableBuilder(
    column: $table.lastTransactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<int> totalTransactions = const Value.absent(),
                Value<double> totalIncome = const Value.absent(),
                Value<double> totalExpenses = const Value.absent(),
                Value<DateTime?> lastTransactionDate = const Value.absent(),
                Value<double?> availableBalance = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                bankName: bankName,
                totalTransactions: totalTransactions,
                totalIncome: totalIncome,
                totalExpenses: totalExpenses,
                lastTransactionDate: lastTransactionDate,
                availableBalance: availableBalance,
                icon: icon,
                color: color,
                isHidden: isHidden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bankName,
                Value<int> totalTransactions = const Value.absent(),
                Value<double> totalIncome = const Value.absent(),
                Value<double> totalExpenses = const Value.absent(),
                Value<DateTime?> lastTransactionDate = const Value.absent(),
                Value<double?> availableBalance = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                bankName: bankName,
                totalTransactions: totalTransactions,
                totalIncome: totalIncome,
                totalExpenses: totalExpenses,
                lastTransactionDate: lastTransactionDate,
                availableBalance: availableBalance,
                icon: icon,
                color: color,
                isHidden: isHidden,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      Value<String?> color,
      Value<String?> icon,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String?> color,
      Value<String?> icon,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                color: color,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<String?> color = const Value.absent(),
                Value<String?> icon = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                color: color,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required String type,
      Value<String?> merchant,
      Value<int?> categoryId,
      Value<String?> paymentMethod,
      required int accountId,
      Value<int?> targetAccountId,
      Value<double?> availableBalance,
      required DateTime transactionDate,
      Value<String?> notes,
      Value<String?> originalSms,
      Value<String?> bankTransactionId,
      Value<String?> receiptAttachment,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<String> type,
      Value<String?> merchant,
      Value<int?> categoryId,
      Value<String?> paymentMethod,
      Value<int> accountId,
      Value<int?> targetAccountId,
      Value<double?> availableBalance,
      Value<DateTime> transactionDate,
      Value<String?> notes,
      Value<String?> originalSms,
      Value<String?> bankTransactionId,
      Value<String?> receiptAttachment,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalSms => $composableBuilder(
    column: $table.originalSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankTransactionId => $composableBuilder(
    column: $table.bankTransactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptAttachment => $composableBuilder(
    column: $table.receiptAttachment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalSms => $composableBuilder(
    column: $table.originalSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankTransactionId => $composableBuilder(
    column: $table.bankTransactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptAttachment => $composableBuilder(
    column: $table.receiptAttachment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get targetAccountId => $composableBuilder(
    column: $table.targetAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get availableBalance => $composableBuilder(
    column: $table.availableBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get originalSms => $composableBuilder(
    column: $table.originalSms,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankTransactionId => $composableBuilder(
    column: $table.bankTransactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptAttachment => $composableBuilder(
    column: $table.receiptAttachment,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> targetAccountId = const Value.absent(),
                Value<double?> availableBalance = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> originalSms = const Value.absent(),
                Value<String?> bankTransactionId = const Value.absent(),
                Value<String?> receiptAttachment = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                type: type,
                merchant: merchant,
                categoryId: categoryId,
                paymentMethod: paymentMethod,
                accountId: accountId,
                targetAccountId: targetAccountId,
                availableBalance: availableBalance,
                transactionDate: transactionDate,
                notes: notes,
                originalSms: originalSms,
                bankTransactionId: bankTransactionId,
                receiptAttachment: receiptAttachment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required String type,
                Value<String?> merchant = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                required int accountId,
                Value<int?> targetAccountId = const Value.absent(),
                Value<double?> availableBalance = const Value.absent(),
                required DateTime transactionDate,
                Value<String?> notes = const Value.absent(),
                Value<String?> originalSms = const Value.absent(),
                Value<String?> bankTransactionId = const Value.absent(),
                Value<String?> receiptAttachment = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                type: type,
                merchant: merchant,
                categoryId: categoryId,
                paymentMethod: paymentMethod,
                accountId: accountId,
                targetAccountId: targetAccountId,
                availableBalance: availableBalance,
                transactionDate: transactionDate,
                notes: notes,
                originalSms: originalSms,
                bankTransactionId: bankTransactionId,
                receiptAttachment: receiptAttachment,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      required double amount,
      required int month,
      required int year,
      Value<int?> categoryId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<int> month,
      Value<int> year,
      Value<int?> categoryId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          Budget,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
          Budget,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                amount: amount,
                month: month,
                year: year,
                categoryId: categoryId,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required int month,
                required int year,
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                amount: amount,
                month: month,
                year: year,
                categoryId: categoryId,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      Budget,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (Budget, BaseReferences<_$AppDatabase, $BudgetsTable, Budget>),
      Budget,
      PrefetchHooks Function()
    >;
typedef $$NotificationsTableCreateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      required String title,
      required String body,
      required DateTime notificationDate,
      required String type,
      Value<bool> isRead,
      Value<String?> payload,
    });
typedef $$NotificationsTableUpdateCompanionBuilder =
    NotificationsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> body,
      Value<DateTime> notificationDate,
      Value<String> type,
      Value<bool> isRead,
      Value<String?> payload,
    });

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notificationDate => $composableBuilder(
    column: $table.notificationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notificationDate => $composableBuilder(
    column: $table.notificationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get notificationDate => $composableBuilder(
    column: $table.notificationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$NotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationsTable,
          Notification,
          $$NotificationsTableFilterComposer,
          $$NotificationsTableOrderingComposer,
          $$NotificationsTableAnnotationComposer,
          $$NotificationsTableCreateCompanionBuilder,
          $$NotificationsTableUpdateCompanionBuilder,
          (
            Notification,
            BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
          ),
          Notification,
          PrefetchHooks Function()
        > {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> notificationDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<String?> payload = const Value.absent(),
              }) => NotificationsCompanion(
                id: id,
                title: title,
                body: body,
                notificationDate: notificationDate,
                type: type,
                isRead: isRead,
                payload: payload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String body,
                required DateTime notificationDate,
                required String type,
                Value<bool> isRead = const Value.absent(),
                Value<String?> payload = const Value.absent(),
              }) => NotificationsCompanion.insert(
                id: id,
                title: title,
                body: body,
                notificationDate: notificationDate,
                type: type,
                isRead: isRead,
                payload: payload,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationsTable,
      Notification,
      $$NotificationsTableFilterComposer,
      $$NotificationsTableOrderingComposer,
      $$NotificationsTableAnnotationComposer,
      $$NotificationsTableCreateCompanionBuilder,
      $$NotificationsTableUpdateCompanionBuilder,
      (
        Notification,
        BaseReferences<_$AppDatabase, $NotificationsTable, Notification>,
      ),
      Notification,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
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

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> color,
    });

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> color = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$TransactionTagsTableCreateCompanionBuilder =
    TransactionTagsCompanion Function({
      required int transactionId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$TransactionTagsTableUpdateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<int> transactionId,
      Value<int> tagId,
      Value<int> rowid,
    });

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$TransactionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTagsTable,
          TransactionTag,
          $$TransactionTagsTableFilterComposer,
          $$TransactionTagsTableOrderingComposer,
          $$TransactionTagsTableAnnotationComposer,
          $$TransactionTagsTableCreateCompanionBuilder,
          $$TransactionTagsTableUpdateCompanionBuilder,
          (
            TransactionTag,
            BaseReferences<
              _$AppDatabase,
              $TransactionTagsTable,
              TransactionTag
            >,
          ),
          TransactionTag,
          PrefetchHooks Function()
        > {
  $$TransactionTagsTableTableManager(
    _$AppDatabase db,
    $TransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> transactionId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion(
                transactionId: transactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int transactionId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => TransactionTagsCompanion.insert(
                transactionId: transactionId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTagsTable,
      TransactionTag,
      $$TransactionTagsTableFilterComposer,
      $$TransactionTagsTableOrderingComposer,
      $$TransactionTagsTableAnnotationComposer,
      $$TransactionTagsTableCreateCompanionBuilder,
      $$TransactionTagsTableUpdateCompanionBuilder,
      (
        TransactionTag,
        BaseReferences<_$AppDatabase, $TransactionTagsTable, TransactionTag>,
      ),
      TransactionTag,
      PrefetchHooks Function()
    >;
typedef $$UnrecognizedSmsTableCreateCompanionBuilder =
    UnrecognizedSmsCompanion Function({
      Value<int> id,
      required String sender,
      required String body,
      required DateTime receivedAt,
      Value<String?> reason,
    });
typedef $$UnrecognizedSmsTableUpdateCompanionBuilder =
    UnrecognizedSmsCompanion Function({
      Value<int> id,
      Value<String> sender,
      Value<String> body,
      Value<DateTime> receivedAt,
      Value<String?> reason,
    });

class $$UnrecognizedSmsTableFilterComposer
    extends Composer<_$AppDatabase, $UnrecognizedSmsTable> {
  $$UnrecognizedSmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnrecognizedSmsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnrecognizedSmsTable> {
  $$UnrecognizedSmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnrecognizedSmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnrecognizedSmsTable> {
  $$UnrecognizedSmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$UnrecognizedSmsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnrecognizedSmsTable,
          UnrecognizedSm,
          $$UnrecognizedSmsTableFilterComposer,
          $$UnrecognizedSmsTableOrderingComposer,
          $$UnrecognizedSmsTableAnnotationComposer,
          $$UnrecognizedSmsTableCreateCompanionBuilder,
          $$UnrecognizedSmsTableUpdateCompanionBuilder,
          (
            UnrecognizedSm,
            BaseReferences<
              _$AppDatabase,
              $UnrecognizedSmsTable,
              UnrecognizedSm
            >,
          ),
          UnrecognizedSm,
          PrefetchHooks Function()
        > {
  $$UnrecognizedSmsTableTableManager(
    _$AppDatabase db,
    $UnrecognizedSmsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnrecognizedSmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnrecognizedSmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnrecognizedSmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<String?> reason = const Value.absent(),
              }) => UnrecognizedSmsCompanion(
                id: id,
                sender: sender,
                body: body,
                receivedAt: receivedAt,
                reason: reason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sender,
                required String body,
                required DateTime receivedAt,
                Value<String?> reason = const Value.absent(),
              }) => UnrecognizedSmsCompanion.insert(
                id: id,
                sender: sender,
                body: body,
                receivedAt: receivedAt,
                reason: reason,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnrecognizedSmsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnrecognizedSmsTable,
      UnrecognizedSm,
      $$UnrecognizedSmsTableFilterComposer,
      $$UnrecognizedSmsTableOrderingComposer,
      $$UnrecognizedSmsTableAnnotationComposer,
      $$UnrecognizedSmsTableCreateCompanionBuilder,
      $$UnrecognizedSmsTableUpdateCompanionBuilder,
      (
        UnrecognizedSm,
        BaseReferences<_$AppDatabase, $UnrecognizedSmsTable, UnrecognizedSm>,
      ),
      UnrecognizedSm,
      PrefetchHooks Function()
    >;
typedef $$SavedSummariesTableCreateCompanionBuilder =
    SavedSummariesCompanion Function({
      Value<int> id,
      required int month,
      required int year,
      required double totalExpense,
      required String topCategory,
      required double topCategoryAmount,
      Value<String?> topMerchant,
      required int transactionCount,
      Value<DateTime> generatedAt,
    });
typedef $$SavedSummariesTableUpdateCompanionBuilder =
    SavedSummariesCompanion Function({
      Value<int> id,
      Value<int> month,
      Value<int> year,
      Value<double> totalExpense,
      Value<String> topCategory,
      Value<double> topCategoryAmount,
      Value<String?> topMerchant,
      Value<int> transactionCount,
      Value<DateTime> generatedAt,
    });

class $$SavedSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedSummariesTable> {
  $$SavedSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topCategory => $composableBuilder(
    column: $table.topCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get topCategoryAmount => $composableBuilder(
    column: $table.topCategoryAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topMerchant => $composableBuilder(
    column: $table.topMerchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedSummariesTable> {
  $$SavedSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topCategory => $composableBuilder(
    column: $table.topCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get topCategoryAmount => $composableBuilder(
    column: $table.topCategoryAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topMerchant => $composableBuilder(
    column: $table.topMerchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedSummariesTable> {
  $$SavedSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get totalExpense => $composableBuilder(
    column: $table.totalExpense,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topCategory => $composableBuilder(
    column: $table.topCategory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get topCategoryAmount => $composableBuilder(
    column: $table.topCategoryAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topMerchant => $composableBuilder(
    column: $table.topMerchant,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$SavedSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedSummariesTable,
          SavedSummary,
          $$SavedSummariesTableFilterComposer,
          $$SavedSummariesTableOrderingComposer,
          $$SavedSummariesTableAnnotationComposer,
          $$SavedSummariesTableCreateCompanionBuilder,
          $$SavedSummariesTableUpdateCompanionBuilder,
          (
            SavedSummary,
            BaseReferences<_$AppDatabase, $SavedSummariesTable, SavedSummary>,
          ),
          SavedSummary,
          PrefetchHooks Function()
        > {
  $$SavedSummariesTableTableManager(
    _$AppDatabase db,
    $SavedSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<double> totalExpense = const Value.absent(),
                Value<String> topCategory = const Value.absent(),
                Value<double> topCategoryAmount = const Value.absent(),
                Value<String?> topMerchant = const Value.absent(),
                Value<int> transactionCount = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
              }) => SavedSummariesCompanion(
                id: id,
                month: month,
                year: year,
                totalExpense: totalExpense,
                topCategory: topCategory,
                topCategoryAmount: topCategoryAmount,
                topMerchant: topMerchant,
                transactionCount: transactionCount,
                generatedAt: generatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int month,
                required int year,
                required double totalExpense,
                required String topCategory,
                required double topCategoryAmount,
                Value<String?> topMerchant = const Value.absent(),
                required int transactionCount,
                Value<DateTime> generatedAt = const Value.absent(),
              }) => SavedSummariesCompanion.insert(
                id: id,
                month: month,
                year: year,
                totalExpense: totalExpense,
                topCategory: topCategory,
                topCategoryAmount: topCategoryAmount,
                topMerchant: topMerchant,
                transactionCount: transactionCount,
                generatedAt: generatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedSummariesTable,
      SavedSummary,
      $$SavedSummariesTableFilterComposer,
      $$SavedSummariesTableOrderingComposer,
      $$SavedSummariesTableAnnotationComposer,
      $$SavedSummariesTableCreateCompanionBuilder,
      $$SavedSummariesTableUpdateCompanionBuilder,
      (
        SavedSummary,
        BaseReferences<_$AppDatabase, $SavedSummariesTable, SavedSummary>,
      ),
      SavedSummary,
      PrefetchHooks Function()
    >;
typedef $$NotificationSettingsDbTableCreateCompanionBuilder =
    NotificationSettingsDbCompanion Function({
      Value<int> id,
      Value<bool> dailySummaryEnabled,
      Value<bool> weeklySummaryEnabled,
      Value<bool> monthlySummaryEnabled,
      Value<bool> budgetAlertsEnabled,
      Value<bool> goalRemindersEnabled,
      Value<bool> smsDetectionEnabled,
      Value<bool> largeExpenseAlertsEnabled,
      Value<bool> smartInsightsEnabled,
      Value<bool> quietHoursEnabled,
      Value<double> largeExpenseThreshold,
    });
typedef $$NotificationSettingsDbTableUpdateCompanionBuilder =
    NotificationSettingsDbCompanion Function({
      Value<int> id,
      Value<bool> dailySummaryEnabled,
      Value<bool> weeklySummaryEnabled,
      Value<bool> monthlySummaryEnabled,
      Value<bool> budgetAlertsEnabled,
      Value<bool> goalRemindersEnabled,
      Value<bool> smsDetectionEnabled,
      Value<bool> largeExpenseAlertsEnabled,
      Value<bool> smartInsightsEnabled,
      Value<bool> quietHoursEnabled,
      Value<double> largeExpenseThreshold,
    });

class $$NotificationSettingsDbTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationSettingsDbTable> {
  $$NotificationSettingsDbTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dailySummaryEnabled => $composableBuilder(
    column: $table.dailySummaryEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get monthlySummaryEnabled => $composableBuilder(
    column: $table.monthlySummaryEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get budgetAlertsEnabled => $composableBuilder(
    column: $table.budgetAlertsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get goalRemindersEnabled => $composableBuilder(
    column: $table.goalRemindersEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smsDetectionEnabled => $composableBuilder(
    column: $table.smsDetectionEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get largeExpenseAlertsEnabled => $composableBuilder(
    column: $table.largeExpenseAlertsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smartInsightsEnabled => $composableBuilder(
    column: $table.smartInsightsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get largeExpenseThreshold => $composableBuilder(
    column: $table.largeExpenseThreshold,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationSettingsDbTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationSettingsDbTable> {
  $$NotificationSettingsDbTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dailySummaryEnabled => $composableBuilder(
    column: $table.dailySummaryEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get monthlySummaryEnabled => $composableBuilder(
    column: $table.monthlySummaryEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get budgetAlertsEnabled => $composableBuilder(
    column: $table.budgetAlertsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get goalRemindersEnabled => $composableBuilder(
    column: $table.goalRemindersEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smsDetectionEnabled => $composableBuilder(
    column: $table.smsDetectionEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get largeExpenseAlertsEnabled => $composableBuilder(
    column: $table.largeExpenseAlertsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smartInsightsEnabled => $composableBuilder(
    column: $table.smartInsightsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get largeExpenseThreshold => $composableBuilder(
    column: $table.largeExpenseThreshold,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationSettingsDbTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationSettingsDbTable> {
  $$NotificationSettingsDbTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get dailySummaryEnabled => $composableBuilder(
    column: $table.dailySummaryEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weeklySummaryEnabled => $composableBuilder(
    column: $table.weeklySummaryEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get monthlySummaryEnabled => $composableBuilder(
    column: $table.monthlySummaryEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get budgetAlertsEnabled => $composableBuilder(
    column: $table.budgetAlertsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get goalRemindersEnabled => $composableBuilder(
    column: $table.goalRemindersEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get smsDetectionEnabled => $composableBuilder(
    column: $table.smsDetectionEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get largeExpenseAlertsEnabled => $composableBuilder(
    column: $table.largeExpenseAlertsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get smartInsightsEnabled => $composableBuilder(
    column: $table.smartInsightsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get largeExpenseThreshold => $composableBuilder(
    column: $table.largeExpenseThreshold,
    builder: (column) => column,
  );
}

class $$NotificationSettingsDbTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationSettingsDbTable,
          NotificationSettingsDbData,
          $$NotificationSettingsDbTableFilterComposer,
          $$NotificationSettingsDbTableOrderingComposer,
          $$NotificationSettingsDbTableAnnotationComposer,
          $$NotificationSettingsDbTableCreateCompanionBuilder,
          $$NotificationSettingsDbTableUpdateCompanionBuilder,
          (
            NotificationSettingsDbData,
            BaseReferences<
              _$AppDatabase,
              $NotificationSettingsDbTable,
              NotificationSettingsDbData
            >,
          ),
          NotificationSettingsDbData,
          PrefetchHooks Function()
        > {
  $$NotificationSettingsDbTableTableManager(
    _$AppDatabase db,
    $NotificationSettingsDbTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationSettingsDbTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationSettingsDbTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationSettingsDbTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailySummaryEnabled = const Value.absent(),
                Value<bool> weeklySummaryEnabled = const Value.absent(),
                Value<bool> monthlySummaryEnabled = const Value.absent(),
                Value<bool> budgetAlertsEnabled = const Value.absent(),
                Value<bool> goalRemindersEnabled = const Value.absent(),
                Value<bool> smsDetectionEnabled = const Value.absent(),
                Value<bool> largeExpenseAlertsEnabled = const Value.absent(),
                Value<bool> smartInsightsEnabled = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<double> largeExpenseThreshold = const Value.absent(),
              }) => NotificationSettingsDbCompanion(
                id: id,
                dailySummaryEnabled: dailySummaryEnabled,
                weeklySummaryEnabled: weeklySummaryEnabled,
                monthlySummaryEnabled: monthlySummaryEnabled,
                budgetAlertsEnabled: budgetAlertsEnabled,
                goalRemindersEnabled: goalRemindersEnabled,
                smsDetectionEnabled: smsDetectionEnabled,
                largeExpenseAlertsEnabled: largeExpenseAlertsEnabled,
                smartInsightsEnabled: smartInsightsEnabled,
                quietHoursEnabled: quietHoursEnabled,
                largeExpenseThreshold: largeExpenseThreshold,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> dailySummaryEnabled = const Value.absent(),
                Value<bool> weeklySummaryEnabled = const Value.absent(),
                Value<bool> monthlySummaryEnabled = const Value.absent(),
                Value<bool> budgetAlertsEnabled = const Value.absent(),
                Value<bool> goalRemindersEnabled = const Value.absent(),
                Value<bool> smsDetectionEnabled = const Value.absent(),
                Value<bool> largeExpenseAlertsEnabled = const Value.absent(),
                Value<bool> smartInsightsEnabled = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<double> largeExpenseThreshold = const Value.absent(),
              }) => NotificationSettingsDbCompanion.insert(
                id: id,
                dailySummaryEnabled: dailySummaryEnabled,
                weeklySummaryEnabled: weeklySummaryEnabled,
                monthlySummaryEnabled: monthlySummaryEnabled,
                budgetAlertsEnabled: budgetAlertsEnabled,
                goalRemindersEnabled: goalRemindersEnabled,
                smsDetectionEnabled: smsDetectionEnabled,
                largeExpenseAlertsEnabled: largeExpenseAlertsEnabled,
                smartInsightsEnabled: smartInsightsEnabled,
                quietHoursEnabled: quietHoursEnabled,
                largeExpenseThreshold: largeExpenseThreshold,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationSettingsDbTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationSettingsDbTable,
      NotificationSettingsDbData,
      $$NotificationSettingsDbTableFilterComposer,
      $$NotificationSettingsDbTableOrderingComposer,
      $$NotificationSettingsDbTableAnnotationComposer,
      $$NotificationSettingsDbTableCreateCompanionBuilder,
      $$NotificationSettingsDbTableUpdateCompanionBuilder,
      (
        NotificationSettingsDbData,
        BaseReferences<
          _$AppDatabase,
          $NotificationSettingsDbTable,
          NotificationSettingsDbData
        >,
      ),
      NotificationSettingsDbData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$UnrecognizedSmsTableTableManager get unrecognizedSms =>
      $$UnrecognizedSmsTableTableManager(_db, _db.unrecognizedSms);
  $$SavedSummariesTableTableManager get savedSummaries =>
      $$SavedSummariesTableTableManager(_db, _db.savedSummaries);
  $$NotificationSettingsDbTableTableManager get notificationSettingsDb =>
      $$NotificationSettingsDbTableTableManager(
        _db,
        _db.notificationSettingsDb,
      );
}
