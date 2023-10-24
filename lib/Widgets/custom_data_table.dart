import 'package:flutter/material.dart';
class CustomDataTable extends StatefulWidget {
  final FocusNode searchFocusNode;
  final TextEditingController searchController;
  final String columntitle;
  final List<dynamic> employeedetails;

  CustomDataTable({
    required this.searchFocusNode,
    required this.searchController,
    required this.columntitle,
    required this.employeedetails,
  });

  @override
  State<CustomDataTable> createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  List<dynamic> filteredEmployeeDetails = [];
  bool isNameAscending = true;
  bool isAllocationAscending = false;

  String searchText = "";
  bool dataLoaded = false;


  @override
  void initState() {
    //print(widget.employeedetails);


    super.initState();
    searchText = widget.searchController.text;
    filteredEmployeeDetails = widget.employeedetails;
    dataLoaded = true;
    // print(filteredEmployeeDetails);
    // print(widget.employeedetails);
    //fetchData();

  }
  int compareFirstLetter(dynamic a, dynamic b) {
    String nameA = getFormattedEmployeeInfo(a).split('\n')[0];
    String nameB = getFormattedEmployeeInfo(b).split('\n')[0];
    String firstLetterA = nameA.isNotEmpty ? nameA[0] : '';
    String firstLetterB = nameB.isNotEmpty ? nameB[0] : '';

    int result = firstLetterA.compareTo(firstLetterB);

    return isNameAscending ? result : -result; // Adjust the result for descending order.
  }

  int compareAllocations(dynamic a, dynamic b) {
    String allocationA = a['allocation']; // Assuming "allocation" is the key in your data
    String allocationB = b['allocation'];

    // Remove '%' and convert to int
    int intAllocationA = int.parse(allocationA.replaceAll('%', ''));
    int intAllocationB = int.parse(allocationB.replaceAll('%', ''));

    return isAllocationAscending ? intAllocationB.compareTo(intAllocationA) : intAllocationA.compareTo(intAllocationB);
  }

  void fetchData() {
    if (!dataLoaded) {
      return; // Do not proceed if data is not loaded
    }

    String query =widget.searchController.text;

    if (query.isNotEmpty) {
      filteredEmployeeDetails = widget.employeedetails.where((employee) {
        return getFormattedEmployeeInfo(employee).toLowerCase().contains(query);
      }).toList();
      //print(filteredEmployeeDetails);
    } else {
      filteredEmployeeDetails = widget.employeedetails;
      //print(filteredEmployeeDetails);
    }
    filteredEmployeeDetails.sort(compareFirstLetter);

    setState(() {

    });
  }




  Widget customRow(
      BuildContext context,
      String text,
      Color bgColor,
      double height,
      FontWeight fontWeight,
      double fontSize,
      Color fontColor,
      [IconData? trailingIcon, Function()? onTrailingIconPressed]) {
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: text == "Fixed Row 3" ? null : () {},
        child: Container(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (text == "Search") // Search row
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      focusNode: widget.searchFocusNode,
                      controller: widget.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      style: TextStyle(
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
              if (trailingIcon != null && text == "Search") // Search icon
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                      icon: Icon(trailingIcon, color: fontColor),
                      onPressed: ()  {
                        if (dataLoaded) {
                          fetchData();
                          //print(filteredEmployeeDetails);
                        }
                      }
                  ),
                ),

              if (text == "Fixed Row 3")
                ...[
                  Expanded(

                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          filteredEmployeeDetails.sort(compareFirstLetter);
                          isNameAscending = !isNameAscending;
                        });
                      },
                      child: Center(
                        child: Text(
                          "User/Project",
                          style: TextStyle(
                            fontWeight: fontWeight,
                            fontSize: fontSize,
                            color: fontColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          filteredEmployeeDetails.sort(compareAllocations);
                          isAllocationAscending = !isAllocationAscending;
                        });
                      },
                      child: Center(
                        child: Text(
                          "${widget.columntitle}",
                          style: TextStyle(
                            fontWeight: fontWeight,
                            fontSize: fontSize,
                            color: fontColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              // For other rows
              if (text != "Search" && text != "Fixed Row 3")
                Expanded(
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontWeight: fontWeight,
                        fontSize: fontSize,
                        color: fontColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    fetchData();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFDEEBFE)),
        ),
        child: Column(
          children: [
            customRow(
              context,
              "Search",
              Colors.white,
              30,
              FontWeight.bold,
              14,
              Colors.black,
              Icons.search,
                  () {

              },
            ),
            Divider(color: Color(0xFFDEEBFE), height: 2),
            customRow(
              context,
              "Fixed Row 3",
              Color(0xFFDEEBFE),
              30,
              FontWeight.w300,
              12,
              Colors.black,
            ),
            Divider(color: Color(0xFFDEEBFE), height: 2),
            Expanded(
              child: ListView.builder(

                itemCount: filteredEmployeeDetails.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MultiLineCell(
                            name: getFormattedEmployeeInfo(filteredEmployeeDetails[index]).split('\n')[0],
                            project: getFormattedEmployeeInfo(filteredEmployeeDetails[index]).split('\n')[1],
                          ),
                        ),
                        Expanded(
                          child: customRow(
                            context,
                            filteredEmployeeDetails.isEmpty
                                ? widget.employeedetails[index]['allocation']
                                : filteredEmployeeDetails[index]['allocation'],
                            Colors.white,
                            30,
                            FontWeight.normal,
                            12,
                            Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Color(0xFFDEEBFE), thickness: 1),
                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );

  }
}
String getFormattedEmployeeInfo(dynamic employee) {
  String firstName = employee["firstName"];
  var lastName = employee["lastName"];
  var project = employee["project"];
  var projectTask = employee["projectTask"];


  return '$firstName $lastName\n$project-$projectTask';
}


class MultiLineCell extends StatelessWidget {
  final String name;
  final String project;

  MultiLineCell({required this.name, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0E142E),decoration: TextDecoration.none), // Adjust font size and color
        ),
        Text(
          project,
          style: TextStyle(fontSize: 12, color: Colors.black45,decoration: TextDecoration.none), // Adjust font size and color
        ),
      ],
    );
  }
}