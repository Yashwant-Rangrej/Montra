import 'package:drift/drift.dart';


class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bankName => text().unique()();
  IntColumn get totalTransactions => integer().withDefault(const Constant(0))();
  RealColumn get totalIncome => real().withDefault(const Constant(0.0))();
  RealColumn get totalExpenses => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastTransactionDate => dateTime().nullable()();
  RealColumn get availableBalance => real().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
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
  RealColumn get availableBalance => real().nullable()(); 
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get originalSms => text().nullable()();
  TextColumn get bankTransactionId => text().nullable()();
  TextColumn get receiptAttachment => text().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get month => integer()(); 
  IntColumn get year => integer()();
  IntColumn get categoryId => integer().nullable()(); 
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class Notifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get notificationDate => dateTime()();
  TextColumn get type => text()(); 
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get payload => text().nullable()();
}

class UnrecognizedSms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sender => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get reason => text().nullable()();
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
