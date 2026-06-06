import 'package:billing_app/models/employee.dart';
import 'package:billing_app/ui/dialog/confirm_delete_dialog.dart';
import 'package:billing_app/ui/helpers/format_helper.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 330;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EmployeeAvatar(fullName: employee.fullName),
                      const SizedBox(width: 12),
                      Expanded(child: _EmployeeInfo(employee: employee)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _EmployeeActions(
                      employee: employee,
                      onEdit: onEdit,
                      onDelete: onDelete,
                      horizontal: true,
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EmployeeAvatar(fullName: employee.fullName),
                const SizedBox(width: 14),
                Expanded(child: _EmployeeInfo(employee: employee)),
                const SizedBox(width: 8),
                _EmployeeActions(
                  employee: employee,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  final String fullName;

  const _EmployeeAvatar({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          fullName.isNotEmpty ? fullName[0].toUpperCase() : "?",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _EmployeeInfo extends StatelessWidget {
  final Employee employee;

  const _EmployeeInfo({required this.employee});

  static const primaryRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final isActive = employee.status == "ACTIVE";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          employee.fullName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        _InfoRow(icon: Icons.account_circle, text: employee.username),

        const SizedBox(height: 6),

        _InfoRow(icon: Icons.phone, text: employee.phone ?? "Không có SĐT"),

        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Tag(
              text: FormatHelper.formatRole(employee.role),
              backgroundColor: primaryRed.withOpacity(0.1),
              textColor: primaryRed,
            ),

            _Tag(
              text: FormatHelper.formatAccountStatus(employee.status),
              backgroundColor: isActive
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),
              textColor: isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _Tag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmployeeActions extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool horizontal;

  const _EmployeeActions({
    required this.employee,
    required this.onEdit,
    required this.onDelete,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final children = [
      IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined, color: Colors.orange),
      ),
      IconButton(
        visualDensity: VisualDensity.compact,
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
    ];

    if (horizontal) {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
