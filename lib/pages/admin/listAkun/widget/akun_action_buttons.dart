import 'package:flutter/material.dart';
import 'package:frontend_flutter/controllers/user_controller.dart';
import 'package:frontend_flutter/pages/admin/listAkun/modals/tambah_user_modal.dart';

class AkunActionButtons extends StatelessWidget {
  final UserController userController;

  const AkunActionButtons({super.key, required this.userController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: userController.fetchUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: BorderSide(color: Colors.blue.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => TambahUserModal.show(context, userController),
            icon: const Icon(Icons.person_add),
            label: const Text('Tambah User'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }
}
