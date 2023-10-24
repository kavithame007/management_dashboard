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
  final ScrollController _scrollController = ScrollController();

  bool _loading = false;
  int _currentPage = 0;
  int _itemsPerPage = 1; // Number of items to load per page

  @override
  void initState() {
    //print(widget.employeedetails);


    super.initState();
    searchText = widget.searchController.text;
    filteredEmployeeDetails = widget.employeedetails;
    dataLoaded = true;
    fetchData("Submitted For Approval");
    // print(filteredEmployeeDetails);
    // print(widget.employeedetails);
    //fetchData();

  }


  // Function to load more data when the user reaches the end of the list.
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_loading) {
      // User has reached the end of the list.
      setState(() {
        _loading = true;
      });

      // Load more data here (e.g., increment _currentPage, fetch more data, and append it to the existing list).

      // Simulate loading for 2 seconds (you should replace this with your data loading logic).
      Future.delayed(Duration(seconds: 15), () {
        fetchData("Submitted For Approval");
        setState(() {
          _loading = false;
        });
      });
    }
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
    String allocationA = a['status']; // Assuming "allocation" is the key in your data
    String allocationB = b['status'];

    // Remove '%' and convert to int
    int intAllocationA = int.parse(allocationA.replaceAll('%', ''));
    int intAllocationB = int.parse(allocationB.replaceAll('%', ''));

    return isAllocationAscending ? intAllocationB.compareTo(intAllocationA) : intAllocationA.compareTo(intAllocationB);
  }

  void fetchData(String statusFilter) {
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
    // Filter the list to include only "Submitted" status employees
    //filteredEmployeeDetails = filteredEmployeeDetails
        //.where((employee) => employee["status"] == statusFilter)
       // .toList();

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
                          fetchData("Submitted For Approval");
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

    fetchData("Submitted For Approval");
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
                  () {},
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
                controller: _scrollController,
                itemCount: filteredEmployeeDetails.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < filteredEmployeeDetails.length) {
                    return Column(
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
                                    ? widget.employeedetails[index]['status']
                                    : (filteredEmployeeDetails[index]['status'] == "Submitted" ? "Not Submitted for Approval": filteredEmployeeDetails[index]['status']),
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
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


String getFormattedEmployeeInfo(dynamic employee) {
  String firstName = employee["name"];
  var project = employee["project"];
  var projectTask = employee["projectTask"];


  return '$firstName \n$project-$projectTask';
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