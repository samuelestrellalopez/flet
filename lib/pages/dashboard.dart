import 'package:users_app/pages/ActivityPage%20.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/pages/payment_methods.dart';
import 'package:users_app/pages/profile_page.dart';

import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  late TabController controller;
  int indexSelected = 0;

  onBarItemClicked(int i) {
    setState(() {
      indexSelected = i;
      controller.index = indexSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          HomePage(),
          PaymentMethodsPage(),
          ActivityPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: "Pagos",
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            label: "Actividad",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
        currentIndex: indexSelected,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.orange,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,
      ),
    );
  }
}