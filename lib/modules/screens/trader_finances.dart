import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:footwear/modules/repository/trader_finances.dart';

import '../models/trader_finances.dart';

class TraderFinanceScreen extends StatefulWidget {
  @override
  _TraderFinanceScreenState createState() => _TraderFinanceScreenState();
}

class _TraderFinanceScreenState extends State<TraderFinanceScreen> {
  late Future<List<TraderFinance>> futureTraders;
  TraderFinancesRepository traderFinancesRepo = TraderFinancesRepository();

  @override
  void initState() {
    super.initState();
    futureTraders = traderFinancesRepo.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trader Finances'),
      ),
      body: FutureBuilder<List<TraderFinance>>(
        future: futureTraders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final traders = snapshot.data!;
            return ListView.builder(
              itemCount: traders.length,
              itemBuilder: (context, index) {
                final trader = traders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trader.traderName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: charts.BarChart(
                            _createSeries(trader),
                            animate: true,
                            vertical: false,
                            barGroupingType: charts.BarGroupingType.stacked,
                            barRendererDecorator: charts.BarLabelDecorator<String>(
                              insideLabelStyleSpec: charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white),
                              outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

List<charts.Series<ChartData, String>> _createSeries(TraderFinance trader) {
  return [
    charts.Series<ChartData, String>(
      id: 'Cost',
      data: [
        ChartData('Bought', trader.totalCostPriceBought),
        ChartData('Sold', trader.totalCostPriceSold),
      ],
      domainFn: (ChartData data, _) => data.label,
      measureFn: (ChartData data, _) => data.value,
      colorFn: (_, __) {
        return charts.MaterialPalette.blue.shadeDefault;
      },
      labelAccessorFn: (ChartData data, _) => data.label == 'Sold' ? '' : 'Bought: ${data.value.toStringAsFixed(2)}',
    ),
    charts.Series<ChartData, String>(
      id: 'Profit',
      data: [
        ChartData('Profit', trader.profit),
      ],
      domainFn: (ChartData data, _) => 'Sold',
      measureFn: (ChartData data, _) => data.value,
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      labelAccessorFn: (ChartData data, _) => data.value > 0 ? 'Profit: ${data.value.toStringAsFixed(2)}' : '',
    ),
    charts.Series<ChartData, String>(
      id: 'SoldTotal',
      data: [
        ChartData('SoldTotal', trader.totalCostPriceSold + trader.profit),
      ],
      domainFn: (ChartData data, _) => 'Sold',
      measureFn: (ChartData data, _) => data.value,
      colorFn: (_, __) => charts.MaterialPalette.transparent,
      labelAccessorFn: (ChartData data, _) => 'Sold: ${data.value.toStringAsFixed(2)}',
    )
  ];
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
