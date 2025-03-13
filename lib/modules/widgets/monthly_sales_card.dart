import 'package:flutter/material.dart';

class MonthlySalesCard extends StatefulWidget {
  final List<Map<String, dynamic>> salesData;
  const MonthlySalesCard({super.key, required this.salesData});

  @override
  State<MonthlySalesCard> createState() => _MonthlySalesCardState();
}

class _MonthlySalesCardState extends State<MonthlySalesCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:50.0),
      child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16),
          itemCount: widget.salesData.length,
          itemBuilder: (context, index) {
            return _buildExpandableMonthCard(widget.salesData[index], index);
          },
        ),
    );
  }
    Widget _buildExpandableMonthCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFF34B4FF).withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Text(
                      data['month'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(16, 58, 97, 1),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      data['isExpanded'] = !data['isExpanded'];
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Icon(
                        data['isExpanded']
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sales: \₹${formatAmount(data['totalSP'])}',
                      style: TextStyle(
                        color: const Color.fromRGBO(16, 58, 97, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Profit: \₹${formatAmount(data['profit'])}',
                      style: TextStyle(
                        color: const Color.fromRGBO(16, 58, 97, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildChannelTabs(data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelTabs(Map<String, dynamic> data) {
    double height = 0;
    if (data['home'].isNotEmpty) {
      height += 233;
    }
    if (data['shop'].isNotEmpty) {
      height += 233;
    }
    if (!data['isExpanded']) {
      height = 0;
    }
    return data['isExpanded']
        ? Column(
            children: [
              SizedBox(
                  height: height, // Adjust height as needed
                  child: Column(
                    children: [
                      if (data['shop'].isNotEmpty)
                        _buildChannelDetails(data['shop'], 'Shop'),
                      if (data['home'].isNotEmpty)
                        _buildChannelDetails(data['home'], 'Home'),
                    ],
                  )),
            ],
          )
        : Container();
  }

  Widget _buildChannelDetails(
      Map<String, dynamic> channelData, String channelName) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChannelStats(channelData, channelName),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelStats(
      Map<String, dynamic> channelData, String channelName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      color: channelName == "Home"
          ? const Color.fromRGBO(16, 58, 97, 1)
          : const Color.fromRGBO(52, 180, 255, 1),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              channelName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            _buildStatRow('Total Sales Price',
                '\₹${formatAmount(channelData['totalSP'])}'),
            _buildStatRow('Profit', '\₹${formatAmount(channelData['profit'])}'),
            _buildStatRow('Daily Avg Sales',
                '\₹${formatAmount(channelData['dailyAvgSales'])}'),
            _buildStatRow('Total Invoices', '${channelData['totalInvoices']}'),
            _buildStatRow(
                'Avg Invoices/Day', '${channelData['avgInvoicesPerDay']}'),
            _buildStatRow(
                'Returned Invoices', '${channelData['returnedInvoices']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
