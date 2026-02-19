import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import 'master_drawer.dart';

class ListAkunPage extends GetView<AuthController> {
  const ListAkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.fetchUsers();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Akun'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi Logout',
                middleText: 'Yakin ingin logout?',
                textCancel: 'Batal',
                textConfirm: 'Logout',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
          ),
        ],
      ),
      drawer: const MasterDrawer(currentPage: 'admin'),

      body: Obx(() {
        if (userController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: userController.users.isEmpty
                    ? const Center(child: Text('Data user kosong'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade100,
                          ),
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Nama')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: List.generate(userController.users.length, (
                            index,
                          ) {
                            final user = userController.users[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text(user.name)),
                                DataCell(Text(user.email)),
                                DataCell(Text(user.role)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: 'Hapus User',
                                        middleText:
                                            'Yakin hapus user ${user.name}?',
                                        textCancel: 'Batal',
                                        textConfirm: 'Hapus',
                                        confirmTextColor: Colors.white,
                                        buttonColor: Colors.red,
                                        onConfirm: () async {
                                          Get.back();
                                          await userController.deleteUser(
                                            user.id,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  onPressed: userController.fetchUsers,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Tambah User'),
                  onPressed: () {
                    _showAddUserModal(userController);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ================= MODAL TAMBAH USER =================
  void _showAddUserModal(UserController userController) {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    String role = 'user';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Form ini digunakan untuk mendaftarkan akun USER atau ADMIN',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameC,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama lengkap',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailC,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'contoh@email.com',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passC,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Minimal 6 karakter',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Daftarkan User'),
                  onPressed: () {
                    if (nameC.text.isEmpty ||
                        emailC.text.isEmpty ||
                        passC.text.isEmpty) {
                      Get.snackbar('Error', 'Semua field wajib diisi');
                      return;
                    }
                    userController.registerUser(
                      name: nameC.text,
                      email: emailC.text,
                      password: passC.text,
                      role: role,
                    );
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
