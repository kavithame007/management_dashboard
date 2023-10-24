class EmployeeProductivityFilter {
  int? id;
  String? userID;
  String? filterName;
  String? selectedManagerID;
  String? selectedManagerName;
  String? selectedCustomerID;
  String? selectedCustomerName;
  bool? isWeekly;
  bool? isEmployee;
  int? selectedYear;
  int? selectedMonth;
  DateTime? selectedDate;

  employeeProductivityFilterMap(){
    var mapping = <String, dynamic>{};
    mapping['id'] = id;
    mapping['userId'] = userID;
    mapping['FilterName'] = filterName!;
    mapping['selectedManagerID'] = selectedManagerID!;
    mapping['selectedManagerName'] = selectedManagerName!;
    mapping['selectedCustomerID'] = selectedCustomerID ?? '';
    mapping['selectedCustomerName'] = selectedCustomerName ?? '';
    mapping['isWeekly'] = isWeekly! ? 1 : 0;
    mapping['isEmployee'] = isEmployee! ? 1 : 0;
    mapping['selectedYear'] = selectedYear!;
    mapping['selectedMonth'] = selectedMonth!;
    mapping['selectedDate'] = selectedDate!.toIso8601String()!;

    return mapping;
  }
}