import 'package:billing_app/models/employee.dart';
import 'package:billing_app/ui/dialog/confirm_delete_dialog.dart';
import 'package:flutter/material.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  final VoidCallback onEdit;

  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final isActive = employee.status == "ACTIVE";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ======================
            // AVATAR
            // ======================
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                ),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Center(
                child: Text(
                  employee.fullName.isNotEmpty
                      ? employee.fullName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ======================
            // INFO
            // ======================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // FULL NAME
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // USERNAME
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          employee.username,
                          style: TextStyle(color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // PHONE
                  Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.grey.shade600),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          employee.phone ?? "Không có SĐT",
                          style: TextStyle(color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ROLE + STATUS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.1),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Text(
                          employee.role,
                          style: const TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.12)
                              : Colors.red.withOpacity(0.12),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: Text(
                          employee.status ?? "",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ======================
            // ACTIONS
            // ======================
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,

                  icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                ),

                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => ConfirmDeleteDialog(
                        title: "Xóa nhân viên",
                        message:
                            'Bạn có chắc chắn muốn xóa nhân viên "${employee.fullName}" không?',
                      ),
                    );

                    if (confirm == true) {
                      onDelete();
                    }
                  },

                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
