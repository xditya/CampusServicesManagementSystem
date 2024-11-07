// import 'package:csms/presentation/screens/dashboard.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class GoogleOAuthLoginScreen extends StatefulWidget {
//   const GoogleOAuthLoginScreen({super.key});

//   @override
//   GoogleOAuthLoginScreenState createState() => GoogleOAuthLoginScreenState();
// }

// class GoogleOAuthLoginScreenState extends State<GoogleOAuthLoginScreen> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     clientId: dotenv.get('GOOGLE_CLIENT_ID'),
//     serverClientId: dotenv.get("GOOGLE_CLIENT_SECRET"),
//     scopes: [
//       'email',
//       'https://www.googleapis.com/auth/contacts.readonly',
//     ],
//   );

//   bool _isLoading = false;

//   Future<void> _handleGoogleSignIn() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _googleSignIn.signIn();
//       // Handle successful sign-in
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const Dashboard()));
//       }
//     } catch (error) {
//       // Handle sign-in error
//       print('Google sign-in error: $error');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Row(
//         children: [
//           Image(
//             image: AssetImage(
//               "assets/images/CSMS.png",
//             ),
//             color: Color.fromARGB(255, 3, 3, 3),
//             width: 25.0,
//             height: 25.0,
//           ),
//           SizedBox(width: 10.0),
//           Text(
//             "Welcome to CSMS!",
//           ),
//         ],
//       )),
//       body: Center(
//         child: _isLoading
//             ? const CircularProgressIndicator()
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                     ElevatedButton.icon(
//                       onPressed: _handleGoogleSignIn,
//                       icon: Image.asset(
//                         "assets/images/google_logo.png",
//                         width: 24.0,
//                         height: 24.0,
//                       ),
//                       label: const Text('Sign in with Google'),
//                     ),
//                   ]),
//       ),
//     );
//   }
// }
