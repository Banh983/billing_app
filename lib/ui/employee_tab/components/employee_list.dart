import 'package:billing_app/models/employee.dart';
import 'package:flutter/material.dart';

import 'employee_card.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;

  final Function(Employee employee) onEdit;

  final Function(Employee employee) onDelete;

  const EmployeeList({
    super.key,
    required this.employees,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: employees.length,
      itemBuilder: (_, i) {
        final e = employees[i];

        return EmployeeCard(
          employee: e,
          onEdit: () => onEdit(e),
          onDelete: () => onDelete(e),
        );
      },
    );
  }
}
