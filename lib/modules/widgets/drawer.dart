import 'package:flutter/material.dart';
import '../models/drawer_option.dart';

class MyDrawer extends StatelessWidget {
  final String userid;
  const MyDrawer(this.userid, this.drawerOptions, {super.key});
  final List<DrawerOption> drawerOptions;
  _navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route, arguments: {'userid': userid});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          SizedBox(
              height: 200,
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(),
                  margin: EdgeInsets.zero,
                  currentAccountPicture: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2020/07/01/12/58/icon-5359553_1280.png'),
                  ),
                  accountName: Text(userid.split("@")[0],
                      style: const TextStyle(fontSize: 20)),
                  accountEmail:
                      Text(userid, style: const TextStyle(fontSize: 15)))),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 1.5,
            color: const Color.fromARGB(255, 143, 136, 136),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
                itemCount: drawerOptions.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: drawerOptions[index].isActive
                        ? Colors.white
                        : Colors.blue,
                    child: ListTile(
                      onTap: () {
                        _navigateTo(context, drawerOptions[index].route);
                      },
                      minVerticalPadding: 1,
                      leading: Text(drawerOptions[index].name,
                          style: TextStyle(
                              color: drawerOptions[index].isActive
                                  ? Colors.blue
                                  : Colors.white,
                              fontSize: 18)),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
