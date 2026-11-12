import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/app_color.dart';
import '../custom_dialog.dart';
import '../custom_input.dart';
import '../custom_snackbar.dart';
import 'edit_transaction_screen.dart';

class DetailTransactionScreen extends StatelessWidget {
  final Map<String, dynamic> trxData;
  const DetailTransactionScreen({super.key, required this.trxData});

  Future<void> deleteTransaction(BuildContext context) async {
    CustomDialog.showConfirmation(
      context: context,
      title: "Delete transaction",
      message: "Are you sure you want to delete this transaction?",
      onConfirm: () async {
        try {
          String uid = FirebaseAuth.instance.currentUser!.uid;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("transactions")
              .doc(trxData['transaction_id'])
              .delete();

          if (context.mounted) {
            CustomSnackBar.showSuccess(
              context,
              "Transaction deleted successfully.",
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (context.mounted) {
            CustomSnackBar.showError(context, e.toString());
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleC = TextEditingController(text: trxData['title']);
    final amountC = TextEditingController(text: trxData['amount'].toString());
    final typeC = TextEditingController(
      text: trxData['type'] == 'Pemasukan' ? 'Income' : 'Expense',
    );
    final dateC = TextEditingController(text: trxData['created_at']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction details"),
        backgroundColor: Colors.white,
        foregroundColor: AppColor.secondary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(trxData: trxData),
                ),
              );
            },
            child: const Text("Edit"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CustomInput(
            controller: titleC,
            label: "Title / note",
            hint: "",
            disabled: true,
          ),
          CustomInput(
            controller: amountC,
            label: "Amount (IDR)",
            hint: "",
            disabled: true,
          ),
          CustomInput(
            controller: typeC,
            label: "Transaction type",
            hint: "",
            disabled: true,
          ),
          CustomInput(
            controller: dateC,
            label: "Recorded at",
            hint: "",
            disabled: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.warning,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => deleteTransaction(context),
              child: const Text(
                "Delete transaction",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
