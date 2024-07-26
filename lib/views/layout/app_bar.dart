import "package:dropdown_button2/dropdown_button2.dart";
import "package:flutter/material.dart";
import "package:fno_view/controllers/option_controller.dart";
import "package:get/get.dart";

import "../../utils/convert_timeframe_to_minutes.dart";
import "../../utils/dropdown_menu_item.dart";
import "../widgets/custom_dropdown_button.dart";

class MyAppBar extends StatefulWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  OptionDataController odController = Get.put(OptionDataController());
  String? currentExpiry;
  String? currentStrike;
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    print("height appbar : ${MediaQuery.of(context).size.height}");
    print("width appbar : ${MediaQuery.of(context).size.width}");
    return Obx(() => buildFullSizeAppBar());
  }

  Widget buildFullSizeAppBar() {
    return Container(
      //color: Colors.blue,
      height: 52,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //buildCircleAvatar(),
          const SizedBox(width: 10),
          searchStock(),
          const SizedBox(width: 20),
          Divider(),
          timeFrameNew(),
          //buildCandleTimeSelector(),
          const SizedBox(width: 20),
          VerticalDivider(thickness: 2,color: Colors.green,width: 10,indent: 2,endIndent: 2,),
          // buildExpirySelectionDropdown(),
          testDropDown(),
          const SizedBox(width: 20),
          testDropDown(),
          //buildCallPutSegmentedButton(),
          const SizedBox(width: 20),
          CustomDropdownButton(labelText: "Select Expiry", hintText: "Select a Expiry", width: 200, menuItems: ["Hello","Help","What the"]),
          // buildStrikePriceSelectDropdownButton(),
          //testDropDown(),
          const SizedBox(width: 20),
          buildRefreshButton(),
          const SizedBox(width: 20),
          TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8), // This makes the shape rectangular
                      side: const BorderSide(color: Colors.white),
                    )),
              ),
              onPressed: (){},
              child: Row(children: [Icon(Icons.auto_graph_sharp),SizedBox(width: 5,),Text("Indicators")],
              )),
          // dropDownMenu(),
          const Spacer(),
          // const Text("Dark Mode"),
          darkModeIconButton(),
          const Tooltip(
              message: "Notification",
              child: Icon(Icons.notifications_none_sharp)),
          const SizedBox(width: 10),
        ],
      ),
    );
  }


  Widget buildDarkModeSwitch() {
    return Switch(
        value: odController.isDarkMode.value,
        onChanged: (bool newValue) {
          setState(() {
            odController.switchDarkMode(newValue);
          });
        });
  }

  Widget darkModeIconButton() {
    return Tooltip(
      message: 'Switch theme',
      child: IconButton(
          onPressed: () {
            setState(() {
              odController.switchDarkMode(!odController.isDarkMode.value);
            });
          },
          icon: odController.isDarkMode.value
              ? const Icon(Icons.dark_mode_outlined)
              : const Icon(Icons.light_mode)),
    );
  }

  TextButton buildRefreshButton() {
    return TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8), // This makes the shape rectangular
                side: const BorderSide(color: Colors.white),
              )),
        ),
        onPressed: () {
          if (currentExpiry != null && currentStrike != null) {
            odController.getData(
                expiry: currentExpiry!,
                right: odController.selectedRight.first,
                strike: currentStrike!);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh),
            const SizedBox(
              width: 5,
            ),
            Text("Refresh${odController.temp}"),
          ],
        ));
  }

  DropdownButton<String> buildStrikePriceSelectDropdownButton() {
    return DropdownButton(
        focusColor: Colors.transparent,
        hint: const Text("Strike Price"),
        value: currentStrike,
        items: odController.strikePriceList.map(buildMenuItems).toList(),
        onChanged: (item) {
          setState(() {
            currentStrike = item;
            if (currentStrike != null) {
              odController.setStrikeprice(item!);
            }
          });
        });
  }


// //todo
//   Widget dropDownMenu(){
//     return const DropdownMenu(
//         onSelected: ,
//         dropdownMenuEntries: [
//           DropdownMenuEntry(value: "28000", label: "123000"),
//           DropdownMenuEntry(value: "28001", label: "123001"),
//           DropdownMenuEntry(value: "28002", label: "123002"),
//     ]);
//   }
  SegmentedButton<String> buildCallPutSegmentedButton() {
    return SegmentedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(0), // This makes the shape rectangular
                side: const BorderSide(), // Optional: Add a border color
              )),
        ),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: "call", label: Text("call")),
          ButtonSegment(value: "put", label: Text("put")),
        ],
        selected: odController.selectedRight,
        onSelectionChanged: (value) {
          odController.updateRight(value);
          if (currentExpiry != null) {
            odController.getStrikePriceData(
                expiry: currentExpiry!,
                right: odController.selectedRight.first);
            setState(() {
              currentStrike = null;
            });
          }
        });
  }

  DropdownButton<String> buildExpirySelectionDropdown() {
    return DropdownButton(
        focusColor: Colors.transparent,
        hint: const Text("Select Expiry"),
        value: currentExpiry,
        items: odController.expiryDates.map(buildMenuItems).toList(),
        onChanged: (item) {
          //print(odController.expiryDates.map(buildMenuItems).toList());
          setState(() {
            currentExpiry = item;
            if (currentExpiry != null) {
              //print(odController.selectedRight.first);
              odController.getStrikePriceData(
                  expiry: currentExpiry!,
                  right: odController.selectedRight.first);
              currentStrike = null;
            }
          });
        });
  }

  Widget testDropDown(){
    final List<String> genderItems = [
      'Male',
      'Female',
    ];
    String? selectedValue;
    return Center(
      child:  Container(
        width: 150,
        height: 30,
        child: DropdownButtonFormField2<String>(
          decoration: const InputDecoration(
            labelText: "  Select Expiry",
            labelStyle: TextStyle(fontSize: 12),
            alignLabelWithHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            // Add Horizontal padding using menuItemStyleData.padding so it matches
            // the menu padding when button's width is not specified.
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            // Add more decoration..
          ),
          hint: const Text(
            "hi",
            style: TextStyle(fontSize: 14),
          ),
          items: genderItems
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ))
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select gender.';
            }
            return null;
          },
          onChanged: (value) {
            //Do something when selected item is changed.
          },
          onSaved: (value) {
            selectedValue = value.toString();
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.only(right: 8),
          ),
          iconStyleData: const IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
            ),
            iconSize: 24,
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
  //todo
  Widget testDropDown2(){
    return Center(
      child: Container(
        width: 120,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField<String>(
          alignment: Alignment.bottomCenter,
          value: 'Option 1',
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
          items: ['Option 1', 'Option 2', 'Option 3'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
            });
          },
        ),
      ),
    );
  }

  SegmentedButton<String> buildCandleTimeSelector() {
    return SegmentedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(0), // This makes the shape rectangular
                side: const BorderSide(), // Optional: Add a border color
              )),
        ),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: "1m", label: Text("1m")),
          ButtonSegment(value: "5m", label: Text("5m")),
          ButtonSegment(value: "15m", label: Text("15m"))
        ],
        selected: odController.selectedCandleTimeFrame,
        onSelectionChanged: (value) {
          setState(() {
            odController.updateCandleTimeFrame(value);
            int timeFrame = convertTimeFrameToMinutes(
                odController.selectedCandleTimeFrame.first);
            odController.aggregateOHLC(
                odController.ohlcDataListOriginal, timeFrame);
          });
        });
  }

  //trying to make a popup menu for time frome selection instead of segmented button
  Widget timeFrameNew(){
    return Container(
      child: PopupMenuButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8), // This makes the shape rectangular
                side: const BorderSide(color: Colors.white),
              )),
        ),
        tooltip: "Candle Timeframe",
        initialValue: "1",
        itemBuilder: (BuildContext context) {
          return const [
            PopupMenuItem(child: Text("1")),
            PopupMenuItem(child: Text("2")),
            PopupMenuItem(child: Text("3")),
          ];
        },
        child: Text("1m", style: TextStyle(fontWeight: FontWeight.w600),),

      ),);
  }
  Widget searchStock() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search),
        SizedBox(width: 5),
        Text(
          "BANK NIFTY",
          style: TextStyle(fontWeight: FontWeight.w500),
          textAlign:  TextAlign.center,
        ),
      ],
    );
  }

// Text buildStockName() => const Text(
//       "BANKNIFTY",
//       style: TextStyle(fontWeight: FontWeight.w500),
//     );
//
// IconButton buildSearchIcon() =>
//     IconButton(onPressed: () {}, icon: const Icon(Icons.search));

// CircleAvatar buildCircleAvatar() {
//   return const CircleAvatar(
//       backgroundColor: Colors.transparent,
//       maxRadius: 15,
//       child: Icon(Icons.person));
// }
}