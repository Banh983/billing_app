import 'employee.dart';

class EmployeePageResult {
  final List<Employee> employees;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool last;

  EmployeePageResult({
    required this.employees,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory EmployeePageResult.fromJson(Map<String, dynamic> json) {
    final pageData = json["data"] ?? json;

    final content = pageData["content"] ?? [];

    return EmployeePageResult(
      employees: content.map<Employee>((e) => Employee.fromJson(e)).toList(),
      currentPage: pageData["number"] ?? 0,
      pageSize: pageData["size"] ?? 10,
      totalPages: pageData["totalPages"] ?? 1,
      totalElements: pageData["totalElements"] ?? 0,
      last: pageData["last"] ?? true,
    );
  }
}
