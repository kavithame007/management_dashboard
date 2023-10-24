class TeamAllocationFilter {
  int? id;
  String? userID;
  String? filterName;
  String?  selectedManagerID;
  String? selectedManagerName;
  String? selectedStartMonth;
  int? selectedStartYear;
  String? selectedEndMonth;
  int? selectedEndYear;

  teamAllocationFilterMap(){
    var mapping = <String, dynamic>{};
    mapping['id'] = id;
    mapping['FilterName'] = filterName!;
    mapping['selectedManagerID'] = selectedManagerID!;
    mapping['SelectedManagerName'] = selectedManagerName!;
    mapping['SelectedStartMonth'] = selectedStartMonth!;
    mapping['SelectedStartYear'] = selectedStartYear!;
    mapping['SelectedEndMonth'] = selectedEndMonth!;
    mapping['SelectedEndYear'] = selectedEndYear!;
    mapping["UserID"] = userID;
    return mapping;
  }
}