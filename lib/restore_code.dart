// route1() {
//     User? user = FirebaseAuth.instance.currentUser;
//     var kk = FirebaseFirestore.instance
//         .collection('users')
//         .doc(user!.uid)
//         .get()
//         .then((DocumentSnapshot documentSnapshot) {
//       if (documentSnapshot.exists) {
//         if (documentSnapshot.get('rool') == "admin") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AdminHomePage(),
//             ),
//           );
//         } else if (documentSnapshot.get('rool') == "admin") {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const StudentHomePage(),
//             ),
//           );
//         }
//       } else {
//         print('Document does not exist on the database');
//       }
//     });
//   }

//   void signIn(String email, String password) async {
//     if (formKey.currentState!.validate()) {
//       try {
//         UserCredential userCredential =
//             await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         route1();
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'user-not-found') {
//           print('No user found for that email.');
//         } else if (e.code == 'wrong-password') {
//           print('Wrong password provided for that user.');
//         }
//       }
//     }
//   }

  // Future signUp() async {
  //   final isValid = formKey.currentState!.validate();
  //   if (!isValid) return;
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(
  //             child: CircularProgressIndicator(),
  //           ));
  //   try {
  //     FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //     //create custom claim
  //     Map<String, dynamic> customClaims = {
  //       'role': _selectedRole,
  //     };

  //     //set custom claim
  //     //await FirebaseAuth.instance.setCustomUserClaims(user.uid, customClaims);

  //     // await FirebaseFirestore.instance.collection('users').add({
  //     //   'email': emailController,
  //     //   'first_name': firstNameController,
  //     //   'last_name': lastNameController,
  //     //   'phone': phoneController,
  //     //   'role': _selectedRole,
  //     // });

  //     // .then((value) {
  //     //   if (_selectedRole == 'admin') {
  //     //     Navigator.of(context).push(
  //     //         MaterialPageRoute(builder: (context) => const AdminHomePage()));
  //     //   } else {
  //     //     Navigator.of(context).push(
  //     //         MaterialPageRoute(builder: (context) => const StudentHomePage()));
  //     //   }
  //     // });
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //     //err.showSnackBar(e.message);
  //   }
  //   navigatorKey.currentState!.popUntil((route) => route.isFirst);
  // }

