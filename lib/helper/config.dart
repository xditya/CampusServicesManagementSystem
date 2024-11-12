// ignore_for_file: non_constant_identifier_names

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final APPWRITE_PROJECT_ID = dotenv.get('APPWRITE_PROJECT_ID');
final APPWRITE_API_ENDPOINT = dotenv.get('APPWRITE_API_ENDPOINT');
Client client =
    Client().setProject(APPWRITE_PROJECT_ID).setEndpoint(APPWRITE_API_ENDPOINT);
final account = Account(client);
