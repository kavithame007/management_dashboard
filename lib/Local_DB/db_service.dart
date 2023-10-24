import 'package:management_dashboard/Pages/Employement_Productivity/EmployeeProductivity_Model.dart';
import 'package:management_dashboard/Local_DB/repository.dart';
import 'package:management_dashboard/Pages/Project_Allocation/Project_Allocation_Model.dart';

import '../Pages/TimeSheet_Approval/Timesheet_Model.dart';

class FilterService{

  late Repository _repository;
  FilterService(){
    _repository = Repository();
  }

  saveEmployeeFilter(EmployeeProductivityFilter employeeProductivityFilter) async {
    return await _repository.insertData("EmployeeProductivityFilter", employeeProductivityFilter.employeeProductivityFilterMap());
  }

  readEmployeeFilter() async {
    return await _repository.readData("EmployeeProductivityFilter");
  }

  saveProjectFilter(TeamAllocationFilter teamAllocationFilter) async {
    return await _repository.insertData("ProjectAllocationFilter", teamAllocationFilter.teamAllocationFilterMap());
  }

  readProjectFilter() async {
    return await _repository.readData("ProjectAllocationFilter");
  }

  saveTimesheetFilter(TimesheetApprovalFilter timesheetFilter) async {
    return await _repository.insertData("TimeSheetFilter", timesheetFilter.timesheetapprovalFilterMap());
  }

  readTimesheetFilter() async {
    return await _repository.readData("TimeSheetFilter");
  }

}