import 'package:csms/helper/config.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  late final Db db;

  factory DBService() => _instance;

  DBService._internal();

  Future<void> connect() async {
    final url = MONGODB_URL;
    db = await Db.create(url);
    await db.open();
  }

  bool get isConnected => db.state == State.open;
}
