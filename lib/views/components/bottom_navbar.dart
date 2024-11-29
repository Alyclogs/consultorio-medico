import 'package:consultorio_medico/controllers/net_controller.dart';
import 'package:consultorio_medico/views/appointments_screen.dart';
import 'package:consultorio_medico/views/home_screen.dart';
import 'package:consultorio_medico/views/medics_screen.dart';
import 'package:consultorio_medico/views/profile_screen.dart';
import 'package:consultorio_medico/views/splash_screen.dart';
import 'package:flutter/material.dart';
import '../notifications_screen.dart';
import '../sedes_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int currentPage = 0;
  final netController = NetworkController();

  @override
  void initState() {
    super.initState();
    netController.checkInternetConnection(
        onInternetConnected: _onInternetConnected,
        onInternetDisconnected: _onInternetDisconnected);
    _initTabController();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    netController.listener.cancel();
  }

  void _initTabController() {
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

  void _onInternetConnected() {
    setState(() {});
  }

  void _onInternetDisconnected() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SplashScreen(action: 'checkInternet')));
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  Widget _noConnectionMessage() {
    return Padding(padding: EdgeInsets.all(32),
    child: Center(
        child: Text(
            "Parece que no tienes conexión a internet. Verifica tu conexión y vuelve a intentarlo")));
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
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsScreen())),
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
                  !netController.hasInternet
                      ? _noConnectionMessage()
                      : HomeScreen(),
                  !netController.hasInternet
                      ? _noConnectionMessage()
                      : AppointmentsScreen(),
                  !netController.hasInternet
                      ? _noConnectionMessage()
                      : MedicsScreen(),
                  !netController.hasInternet
                      ? _noConnectionMessage()
                      : SedesScreen(),
                  !netController.hasInternet
                      ? _noConnectionMessage()
                      : ProfileScreen(),
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
