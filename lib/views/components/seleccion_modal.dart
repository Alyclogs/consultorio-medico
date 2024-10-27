import 'package:flutter/material.dart';
import '../../models/sede.dart';
import '../../models/seleccionable.dart';

class SeleccionModal<T extends Seleccionable> {
  Future<List<T>> Function() getRegistros;
  String titulo;
  String seleccionado = '';

  SeleccionModal({required this.getRegistros, required this.titulo});

  void mostrar(BuildContext context, Function(String) onSeleccionado) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<List<Seleccionable>>(
          future: getRegistros(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay datos disponibles'));
            }
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 20)),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Color(0xFFBDBDBD))),
                            leading: item.foto.isNotEmpty
                                ? Image.network(
                                    item.foto,
                                    width: 40,
                                    height: 40,
                                  )
                                : Image.asset(
                                    item is Sede
                                        ? 'assets/images/hospital.png'
                                        : 'assets/images/doctor.png',
                                    width: 40,
                                    height: 40,
                                  ),
                            title: Text(item.nombre),
                            subtitle: item is Sede
                                ? Text(item.direccion)
                                : Text(item.titulo),
                            onTap: () {
                              onSeleccionado(item.nombre);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
