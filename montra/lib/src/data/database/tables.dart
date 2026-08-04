import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type => text()(); 
  RealColumn get initialBalance => real()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type => text()(); 
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); 
  TextColumn get merchant => text().nullable()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  IntColumn get accountId => integer()();
  IntColumn get targetAccountId => integer().nullable()(); 
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get originalSms => text().nullable()();
  TextColumn get bankTransactionId => text().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get month => integer()(); 
  IntColumn get year => integer()();
  IntColumn get categoryId => integer().nullable()(); 
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get notificationDate => dateTime()();
  BoolColumn get isRead => boolean()();
  TextColumn get type => text()(); 
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get color => text().nullable()();
}

class TransactionTags extends Table {
  IntColumn get transactionId => integer()();
  IntColumn get tagId => integer()();

  @override
  Set<Column> get primaryKey => {transactionId, tagId};
}
