class TimesheetApprovalFilter {
  int? id;
  String? userID;
  String? filterName;
  String? selectedManagerID;
  String? selectedManagerName;
  String? selectedWeek;

  timesheetapprovalFilterMap(){
    var mapping = <String, dynamic>{};
    mapping['id'] = id;
    mapping['userId'] = userID;
    mapping['FilterName'] = filterName!;
    mapping['selectedManagerID'] = selectedManagerID!;
    mapping['selectedManagerName'] = selectedManagerName!;
    mapping['selectedWeek'] =selectedWeek!;//.toIso8601String()!;

    return mapping;
  }
}