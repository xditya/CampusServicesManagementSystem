// ignore_for_file: non_constant_identifier_names

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final APPWRITE_PROJECT_ID = dotenv.get('APPWRITE_PROJECT_ID');
final APPWRITE_API_ENDPOINT = dotenv.get('APPWRITE_API_ENDPOINT');
// final APPWRITE_DATABASE_ID = dotenv.get('APPWRITE_DATABASE_ID');
// final APPWRITE_USERDB_COLLECTION_ID =
//     dotenv.get('APPWRITE_USERDB_COLLECTION_ID');
final MONGODB_URL = dotenv.get('MONGODB_URL');
final RAZORPAY_API_KEY = dotenv.get('RAZORPAY_API_KEY');

Client client =
    Client().setProject(APPWRITE_PROJECT_ID).setEndpoint(APPWRITE_API_ENDPOINT);

final account = Account(client);

Databases databases = Databases(client);

final NOTIF_WEBSOCKET = dotenv.get('NOTIF_WEBSOCKET');