import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../custom_input.dart';
import '../custom_snackbar.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    final email = emailC.text.trim();
    final password = passwordC.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Please enter your email and password.');
      }
      return;
    }

    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final message = switch (e.code) {
          'operation-not-allowed' =>
            'Email/password sign-in is disabled. Enable it in Firebase Console under Authentication > Sign-in method.',
          'invalid-credential' || 'user-not-found' || 'wrong-password' =>
            'Incorrect email or password. If you have not created an account yet, choose Create account.',
          'invalid-email' => 'Enter a valid email address.',
          'user-disabled' => 'This account has been disabled. Contact the project administrator.',
          'too-many-requests' =>
            'Too many attempts. Wait a little while and try again.',
          'network-request-failed' =>
            'Could not reach Firebase. Check your internet connection and try again.',
          _ => e.message ?? 'Sign-in failed. Please try again.',
        };
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
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColor.primaryExtraSoft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 48,
                      color: AppColor.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pocketwise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColor.primarySoft,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  CustomInput(
                    controller: emailC,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomInput(
                    controller: passwordC,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
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
                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign in',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Create account'),
                      ),
                    ],
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
