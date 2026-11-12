import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/app_color.dart';
import '../custom_input.dart';
import '../custom_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  bool isLoading = false;

  Future<void> register() async {
    final name = nameC.text.trim();
    final email = emailC.text.trim();
    final password = passwordC.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Please complete all fields.');
      }
      return;
    }

    if (password.length < 6) {
      if (mounted) {
        CustomSnackBar.showError(
          context,
          'Password must be at least 6 characters.',
        );
      }
      return;
    }

    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          });

      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Account created successfully.');
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final message = switch (e.code) {
          'operation-not-allowed' => 'Email/password sign-up is disabled. Enable it in Firebase Console under Authentication > Sign-in method.',
          'email-already-in-use' =>
            'An account already exists for this email. Try signing in instead.',
          'invalid-email' => 'Enter a valid email address.',
          'weak-password' => 'Choose a stronger password.',
          'network-request-failed' => 'Could not reach Firebase. Check your internet connection and try again.',
          _ => e.message ?? 'Account creation failed.',
        };
        CustomSnackBar.showError(context, message);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        final message = e.code == 'permission-denied'
            ? 'Your account was created, but the profile could not be saved. Check your Cloud Firestore security rules.'
            : e.code == 'unavailable'
            ? 'Your account was created, but Firestore is unavailable. Check your connection and Firebase Console.'
            : 'Your account was created, but its profile could not be saved (${e.code}).';
        CustomSnackBar.showError(context, message);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Something went wrong: $e');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColor.primaryExtraSoft,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 42,
                      color: AppColor.primary,
                    ),
                  ),
                  CustomInput(
                    controller: nameC,
                    label: 'Full name',
                    hint: 'Enter your full name',
                  ),
                  CustomInput(
                    controller: emailC,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomInput(
                    controller: passwordC,
                    label: 'Password',
                    hint: 'At least 6 characters',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : register,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create account',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
