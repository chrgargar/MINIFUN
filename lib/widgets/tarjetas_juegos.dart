import 'package:flutter/material.dart';
import '../screens/seleccion_modo.dart';

class TarjetasJuegos extends StatelessWidget {
  final String title;
  final String? imagePath;
  final VoidCallback? onTap; // 👈 nuevo parámetro

  const TarjetasJuegos({
    super.key,
    required this.title,
    this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeleccionModo(
                        gameTitle: title,
                        gameImagePath: imagePath ?? '',
                      ),
                    ),
                  );
                },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: imagePath != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePath!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
