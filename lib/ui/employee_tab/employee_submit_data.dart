import '../../models/employee.dart';

class EmployeeSubmitData {

  final Employee employee;
  final String? password;

  EmployeeSubmitData({
    required this.employee,
    this.password,
  });
}