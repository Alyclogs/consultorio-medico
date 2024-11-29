import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSelector {
  void mostrar(BuildContext context, Function(ImageSource) onSeleccionado) {
    Widget buildIcon(String filePath, String title) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              filePath,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cambiar foto de perfil",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => onSeleccionado(ImageSource.camera),
                    child:
                        buildIcon('assets/images/camara.png', 'Tomar una foto'),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  GestureDetector(
                    onTap: () => onSeleccionado(ImageSource.gallery),
                    child: buildIcon('assets/images/galeria.png',
                        'Seleccionar desde galería'),
                  )
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
