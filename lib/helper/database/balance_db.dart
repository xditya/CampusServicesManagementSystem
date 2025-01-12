// using mongodb is not a preferred way to store user data, should've used appwrite instead
// but anyways, here it is :)

import 'package:csms/helper/database/db_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<double> getBalance(String email) async {
  final dbService = DBService();
  if (!dbService.isConnected) {
    await dbService.connect();
  }
  final collection = dbService.db.collection('users');
  var userInfo = await collection.findOne(where.eq('email', email));
  if (userInfo == null) {
    return 0;
  }
  return userInfo['balance'];
}

Future updateBalance(String email, double value, String type) async {
  final collection = DBService().db.collection('users');
  try {
    var userInfo = await collection.findOne(where.eq('email', email));
    if (userInfo != null) {
      await collection.update(
        where.eq('email', email),
        modify
            .set('balance', userInfo['balance'] + value)
            .push('transactions', {
          'type': type,
          'amount': value,
          'date': DateTime.now().toString(),
        }),
      );
    } else {
      await collection.insert({
        'email': email,
        'balance': value,
        'transactions': [
          {
            'type': type,
            'amount': value,
            'date': DateTime.now().toString(),
          }
        ],
      });
    }
  } catch (e) {
    await collection.insert({
      'email': email,
      'balance': value,
      'transactions': [
        {
          'type': type,
          'amount': value,
          'date': DateTime.now().toString(),
        }
      ],
    });
  }
}

Future<List> getTransactions(String email) async {
  final collection = DBService().db.collection('users');
  try {
    var userInfo = await collection.findOne(where.eq('email', email));
    if (userInfo == null) {
      return [];
    }
    return userInfo['transactions'];
  } catch (e) {
    return [];
  }
}

// import 'package:csms/helper/config.dart';

// Future updateBalance(String email, double value, String type) async {
//   try {
//     var userInfo = await databases.getDocument(
//         databaseId: APPWRITE_DATABASE_ID,
//         collectionId: APPWRITE_USERDB_COLLECTION_ID,
//         documentId: email.split("@")[0].split(".")[1]);
//     await databases.updateDocument(
//         databaseId: APPWRITE_DATABASE_ID,
//         collectionId: APPWRITE_USERDB_COLLECTION_ID,
//         documentId: email.split("@")[0].split(".")[1], // register number
//         data: {
//           'email': email,
//           'balance': userInfo.data['balance'] + value,
//           'transactions': [
//             ...userInfo.data['transactions'],
//             {
//               'type': type,
//               'amount': value,
//               'date': DateTime.now().toString(),
//             }
//           ]
//         });
//   } catch (e) {
//     await databases.createDocument(
//         databaseId: APPWRITE_DATABASE_ID,
//         collectionId: APPWRITE_USERDB_COLLECTION_ID,
//         documentId: email.split("@")[0].split(".")[1],
//         data: {
//           'email': email,
//           'balance': value,
//           'transactions': [
//             {
//               'type': type,
//               'amount': value,
//               'date': DateTime.now().toString(),
//             }
//           ]
//         });
//   }
// }

// Future<int> getBalance(String email) async {
//   try {
//     var userInfo = await databases.getDocument(
//         databaseId: APPWRITE_DATABASE_ID,
//         collectionId: APPWRITE_USERDB_COLLECTION_ID,
//         documentId: email.split("@")[0].split(".")[1] // register number
//         );

//     return userInfo.data['balance'];
//   } catch (e) {
//     return 0;
//   }
// }

// Future<List> getTransactions(String email) async {
//   try {
//     var userInfo = await databases.getDocument(
//         databaseId: APPWRITE_DATABASE_ID,
//         collectionId: APPWRITE_USERDB_COLLECTION_ID,
//         documentId: email.split("@")[0].split(".")[1]);
//     return userInfo.data['transactions'];
//   } catch (e) {
//     return [];
//   }
// }

// import 'package:csms/helper/config.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;

// Future updateBalance(String email, double value, String type) async {
//   var db = mongo.Db(MONGODB_URL);
//   db.databaseName = 'csms';

//   await db.open();

//   var collection = db.collection('users');

//   try {
//     var userInfo = await collection.findOne(mongo.where.eq('email', email));
//     if (userInfo != null) {
//       await collection.update(
//         mongo.where.eq('email', email),
//         mongo.modify
//             .set('balance', userInfo['balance'] + value)
//             .push('transactions', {
//           'type': type,
//           'amount': value,
//           'date': DateTime.now().toString(),
//         }),
//       );
//     } else {
//       await collection.insert({
//         'email': email,
//         'balance': value,
//         'transactions': [
//           {
//             'type': type,
//             'amount': value,
//             'date': DateTime.now().toString(),
//           }
//         ],
//       });
//     }
//   } catch (e) {
//     await collection.insert({
//       'email': email,
//       'balance': value,
//       'transactions': [
//         {
//           'type': type,
//           'amount': value,
//           'date': DateTime.now().toString(),
//         }
//       ],
//     });
//   } finally {
//     await db.close();
//   }
// }

// Future<int> getBalance(String email) async {
//   var db = mongo.Db(MONGODB_URL);
//   // db.databaseName = 'csms';

//   await db.open();

//   var collection = db.collection('users');

//   try {
//     var userInfo = await collection.findOne(mongo.where.eq('email', email));
//     print("userinfo: $userInfo");
//     if (userInfo == null) {
//       return 0;
//     }
//     return userInfo['balance'];
//   } catch (e) {
//     return 0;
//   } finally {
//     await db.close();
//   }
// }

// Future<List> getTransactions(String email) async {
//   var db = mongo.Db(MONGODB_URL);
//   db.databaseName = 'csms';

//   await db.open();

//   var collection = db.collection('users');

//   try {
//     var userInfo = await collection.findOne(mongo.where.eq('email', email));
//     if (userInfo == null) {
//       return [];
//     }
//     return userInfo['transactions'];
//   } catch (e) {
//     return [];
//   } finally {
//     await db.close();
//   }
// }