import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';
import 'package:footwear/modules/repository/trader_finances.dart';
import 'package:footwear/modules/widgets/drawer.dart';
import '../../config/constants/app_constants.dart';
import '../../config/constants/drawer_options_list.dart';
import '../models/drawer_option.dart';
import '../models/trader_finances.dart';

class TraderFinanceScreen extends StatelessWidget {
  final DrawerOptionList list = DrawerOptionList();
  final TraderFinancesRepository traderFinancesRepository =
      TraderFinancesRepository();

  TraderFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<DrawerOption> drawerOptionList = list.drawerOptions;
    drawerOptionList = drawerOptionList.map((drawerOption) {
      if (drawerOption.name == AppBarTitle.traderFinances) {
        drawerOption.isActive = true;
        return drawerOption;
      } else {
        drawerOption.isActive = false;
        return drawerOption;
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trader Finances'),
      ),
      drawer: Drawer(child: MyDrawer('Sushil', drawerOptionList)),
      body: FutureBuilder<List<TraderFinance>>(
        future: traderFinancesRepository.getData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<TraderFinance>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Some error in retrieving trader finances'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trader finances available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final TraderFinance traderFinance = snapshot.data![index];
              return TraderFinanceCard(traderFinance: traderFinance);
            },
          );
        },
      ),
    );
  }
}

class TraderFinanceCard extends StatelessWidget {
  final TraderFinance traderFinance;

  TraderFinanceCard({required this.traderFinance});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              traderFinance.traderName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Profit: ₹${traderFinance.profit.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 200,
              child: DChartBarCustom(
                spaceDomainLabeltoChart: 10,
                spaceBetweenItem: 5,
                showDomainLabel: true,
                listData: [
                  DChartBarDataCustom(
                      valueStyle: TextStyle(color: Colors.white),
                      color: Colors.teal[300],
                      value: traderFinance.totalSellingPrice,
                      label: 'S.P.',
                      showValue: true),
                  DChartBarDataCustom(
                      valueStyle: TextStyle(color: Colors.white),
                      color: Color(0xFFFF7F50),
                      value: traderFinance.totalCostPriceSold,
                      label: 'C.P.',
                      showValue: true),
                  DChartBarDataCustom(
                      valueStyle: TextStyle(color: Colors.white),
                      color: Colors.purple[200],
                      value: traderFinance.totalCostPriceBought,
                      label: 'Total C.P.',
                      showValue: true),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
