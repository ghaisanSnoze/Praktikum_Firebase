import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_color.dart';
import '../custom_dialog.dart';
import 'add_transaction_screen.dart';
import 'detail_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String formatRupiah(int nominal) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(nominal);
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile stream and sign-out action.
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Could not load your profile: ${snapshot.error}",
                    style: const TextStyle(color: AppColor.error),
                  );
                }
                if (!snapshot.hasData) return const SizedBox();
                var userData = snapshot.data?.data();
                String name = userData?['name'] ?? 'User';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome back,",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.secondarySoft,
                          ),
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColor.error),
                      onPressed: () {
                        CustomDialog.showConfirmation(
                          context: context,
                          title: "Sign out",
                          message: "Are you sure you want to sign out?",
                          onConfirm: () => FirebaseAuth.instance.signOut(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Live balance summary and transaction history.
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("transactions")
                  .orderBy("created_at", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Could not load transactions: ${snapshot.error}",
                    style: const TextStyle(color: AppColor.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data?.docs ?? [];
                int totalTransaksi = docs.length;
                int totalPemasukan = 0;
                int totalPengeluaran = 0;

                // Calculate income and expenses from the user's transactions.
                for (var doc in docs) {
                  var data = doc.data();
                  int amount = (data['amount'] ?? 0) as int;
                  if (data['type'] == 'Pemasukan') {
                    totalPemasukan += amount;
                  } else {
                    totalPengeluaran += amount;
                  }
                }
                int saldoAkhir = totalPemasukan - totalPengeluaran;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance summary card.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColor.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total balance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$totalTransaksi transactions",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatRupiah(saldoAkhir),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Income",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "+ ${formatRupiah(totalPemasukan)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Expenses",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "- ${formatRupiah(totalPengeluaran)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "Recent transactions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Transaction history.
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text("No transactions yet")),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          var trx = docs[index].data();
                          bool isIncome = trx['type'] == 'Pemasukan';
                          int amount = (trx['amount'] ?? 0) as int;

                          return ListTile(
                            tileColor: AppColor.primaryExtraSoft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? AppColor.success.withValues(alpha: 0.15)
                                  : AppColor.error.withValues(alpha: 0.15),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome
                                    ? AppColor.success
                                    : AppColor.error,
                              ),
                            ),
                            title: Text(
                              trx['title'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${isIncome ? 'Income' : 'Expense'} • ${trx['created_at'].toString().substring(0, 10)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              "${isIncome ? '+' : '-'} ${formatRupiah(amount)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome
                                    ? AppColor.success
                                    : AppColor.error,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailTransactionScreen(trxData: trx),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
