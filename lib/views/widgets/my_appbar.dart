import "dart:isolate";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:fno_view/controllers/option_controller.dart";
import "package:get/get.dart";

class MyAppBar extends StatefulWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  OptionDataController odController = Get.put(OptionDataController());
  String? currentExpiry;
  String? currentStrike;
  List<String> indicators = [
    "Atrr",
    "BollingerBand",
    "EMA",
    "Macd",
    "Momentum",
    "RSI",
    "SMA",
    "Stochastic",
    "Technical",
    "TMA"
  ];
  String? currentIndicator;

  @override
  Widget build(BuildContext context) {
    return Obx(
      ()=> SizedBox(
        height: 50,
        //width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
                backgroundColor: Colors.transparent,
                maxRadius: 15,
                child: Icon(Icons.person)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            const Text("BANKNIFTY"),
            const SizedBox(
              width: 20,
            ),
            SegmentedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          0), // This makes the shape rectangular
                      side:
                          const BorderSide(), // Optional: Add a border color
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
                    odController.updateCandleTimeFrame(value);
                    int timeFrame = convertTimeFrameToMinutes(odController.selectedCandleTimeFrame.first);
                    odController.aggregateOHLC(odController.ohlcDataListOriginal, timeFrame);
                  }),

            const SizedBox(
              width: 20,
            ),
            DropdownButton(
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
                  }),
            const SizedBox(
              width: 20,
            ),
            SegmentedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          0), // This makes the shape rectangular
                      side:
                          const BorderSide(), // Optional: Add a border color
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
                  }),
            const SizedBox(
              width: 20,
            ),
            DropdownButton(
                  focusColor: Colors.transparent,
                  hint: const Text("Strike Price"),
                  value: currentStrike,
                  items: odController.strikePriceList
                      .map(buildMenuItems)
                      .toList(),
                  onChanged: (item) {
                    setState(() {
                      currentStrike = item;
                      if (currentStrike != null) {
                        odController.setStrikeprice(item!);
                      }
                    });
                  }),
            const SizedBox(
              width: 20,
            ),
           TextButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          0), // This makes the shape rectangular
                      side: const BorderSide(
                          color:
                              Colors.white), // Optional: Add a border color
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
                    children: [
                      const Icon(Icons.refresh),
                      const SizedBox(
                        width: 5,
                      ),
                      Text("Refresh${odController.temp}"),
                    ],
                  )),
             const Spacer(),
            Text("Dark Mode"),
            SizedBox(width: 10,),
            CupertinoSwitch(
                value: odController.isDarkMode.value,
                onChanged: (bool newValue) {
                  odController.switchDarkMode(newValue);
                }
            )
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItems(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(fontSize: 12),
        ),
      );
}

int convertTimeFrameToMinutes(String timeFrame) {
  switch (timeFrame) {
    case '1m':
      return 1;
    case '5m':
      return 5;
    case '15m':
      return 15;
    default:
      throw ArgumentError('Unsupported time frame: $timeFrame');
  }
}