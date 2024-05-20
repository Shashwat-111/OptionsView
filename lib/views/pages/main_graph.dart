import 'package:flutter/material.dart';
import 'package:fno_view/models/graph_data_calss.dart';
import 'package:fno_view/services/remote_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainChart extends StatefulWidget {
  const MainChart({
    super.key,
  });
  @override
  State<MainChart> createState() => _MainChartState();
}

class _MainChartState extends State<MainChart> {
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late CrosshairBehavior _crosshairBehavior;
  List<OhlcDatum>? _ohlcDataList;
  

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getData();
      setState(() {});
    });
    
    _crosshairBehavior = CrosshairBehavior(
                enable: true,
                shouldAlwaysShow: true,
                lineType: CrosshairLineType.horizontal,
                activationMode: ActivationMode.singleTap);
    _trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    _zoomPanBehavior = ZoomPanBehavior(
      maximumZoomLevel: 0.001,
      enableMouseWheelZooming: true,
      enablePanning: true,
      enableSelectionZooming: true,
      selectionRectBorderColor: Colors.red,
      zoomMode: ZoomMode.x,
    );
    super.initState();
  }

  getData() async {
    var response = await RemoteService().getData("/options/2");
    _ohlcDataList = response!.ohlcData;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Stack(alignment: Alignment.center, children: [
          _ohlcDataList == null
              ? const CircularProgressIndicator()
              : Container(),
          SfCartesianChart(
            crosshairBehavior: _crosshairBehavior,
            title: const ChartTitle(text: "Demo Chart For Ruddu"),
            trackballBehavior: _trackballBehavior,
            zoomPanBehavior: _zoomPanBehavior,
            series: <CandleSeries>[
              CandleSeries<OhlcDatum, DateTime>(
                  enableSolidCandles: true,
                  animationDuration: 0,
                  dataSource: _ohlcDataList,
                  name: 'AAPL',
                  xValueMapper: (OhlcDatum sales, _) => sales.datetime,
                  lowValueMapper: (OhlcDatum sales, _) =>
                      double.parse(sales.low),
                  highValueMapper: (OhlcDatum sales, _) =>
                      double.parse(sales.high),
                  openValueMapper: (OhlcDatum sales, _) =>
                      double.parse(sales.open),
                  closeValueMapper: (OhlcDatum sales, _) =>
                      double.parse(sales.close))
            ],
            primaryXAxis: const DateTimeCategoryAxis(
              initialZoomPosition: 1,
              interactiveTooltip: InteractiveTooltip(),
              initialZoomFactor: 0.05,
              intervalType: DateTimeIntervalType.auto,
              //dateFormat: DateFormat.MMM(),
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              // minimum: 70,
              // maximum: 140,
              //interval:1,
              numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
            ),
          ),
        ]),
      ),
    );
  }
}