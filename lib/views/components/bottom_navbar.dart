import 'package:consultorio_medico/views/appointments_screen.dart';
import 'package:consultorio_medico/views/home_screen.dart';
import 'package:consultorio_medico/views/medics_screen.dart';
import 'package:consultorio_medico/views/profile_screen.dart';
import 'package:flutter/material.dart';

import '../sedes_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.index = widget.initialIndex;
    _tabController.animation!.addListener(
      () {
        final value = _tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 36),
          child: Text('MedicArt'),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 30),
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: TabBarView(
                controller: _tabController,
                children: [
                  HomeScreen(),
                  AppointmentsScreen(),
                  MedicsScreen(),
                  SedesScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 36, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 70,
          child: TabBar(
            dividerColor: Colors.transparent,
            controller: _tabController,
            labelStyle: TextStyle(color: Color(0xFF5494a3)),
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: Colors.transparent,
            ),
            tabs: [
              Tab(icon: Icon(Icons.home_outlined, size: 28)),
              Tab(icon: Icon(Icons.pending_actions, size: 28)),
              Tab(icon: Icon(Icons.medical_services_outlined, size: 28)),
              Tab(icon: Icon(Icons.business_rounded, size: 28)),
              Tab(icon: Icon(Icons.person_outline_outlined, size: 28)),
            ],
          ),
        ),
      ),
    );
  }
}
