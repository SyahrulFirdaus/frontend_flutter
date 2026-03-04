import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/lokasi_controller.dart';
import 'lokasi_delete_dialog.dart';
import 'lokasi_empty_widget.dart';

class LokasiTableWidget extends GetView<LokasiController> {
  const LokasiTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.lokasis.isEmpty) {
      return const LokasiEmptyWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildTable(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Daftar Lokasi Tersimpan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Total: ${controller.lokasis.length}',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildDesktopTable();
        } else {
          return _buildMobileList();
        }
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Lokasi')),
          DataColumn(label: Text('Koordinat')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: List.generate(controller.lokasis.length, (i) {
          final item = controller.lokasis[i];
          return DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(item.user)),
              DataCell(
                Tooltip(
                  message: item.lokasi,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(item.lokasi, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              DataCell(
                Tooltip(
                  message: item.koordinat,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      item.koordinat,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => LokasiDeleteDialog.show(
                    context: Get.context!,
                    id: item.id,
                    lokasi: item.lokasi,
                    controller: controller,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.lokasis.length,
      itemBuilder: (context, i) {
        final item = controller.lokasis[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${i + 1}'),
            ),
            title: Text(item.lokasi),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${item.user}'),
                Text('Koordinat: ${item.koordinat}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => LokasiDeleteDialog.show(
                context: Get.context!,
                id: item.id,
                lokasi: item.lokasi,
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
