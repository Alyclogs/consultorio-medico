import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Nombre de Usuario'),
            accountEmail: Text('Bienvenido'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historial de reservas'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configuración de la app'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contacto'),
            onTap: () {},
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
