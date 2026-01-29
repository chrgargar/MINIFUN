import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/app_colors.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

/// Pantalla para recuperar la contraseña
class PantallaRecuperarPassword extends StatefulWidget {
  const PantallaRecuperarPassword({super.key});

  @override
  State<PantallaRecuperarPassword> createState() => _PantallaRecuperarPasswordState();
}

class _PantallaRecuperarPasswordState extends State<PantallaRecuperarPassword> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? value) {
    return Validators.validateEmail(value);
  }

  Future<void> _enviarEnlace() async {
    setState(() {
      _emailError = _validarEmail(_emailController.text);
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.forgotPassword(email: _emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true; // Por seguridad, mostramos el mismo mensaje
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableHeight = constraints.maxHeight;
          double headerHeight = availableHeight * 0.25;
          double iconSize = (headerHeight * 0.35).clamp(80.0, 100.0);
          double padding = constraints.maxWidth * 0.06;

          return Column(
            children: [
              // Cabecera
              Container(
                width: double.infinity,
                height: headerHeight,
                decoration: BoxDecoration(
                  color: ColoresApp.moradoLogin,
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Botón volver
                      Positioned(
                        left: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: ColoresApp.blanco,
                            size: 28,
                          ),
                        ),
                      ),
                      // Icono central
                      Center(
                        child: Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: ColoresApp.blanco,
                            shape: BoxShape.circle,
                            border: Border.all(color: ColoresApp.moradoLoginOscuro, width: 3),
                          ),
                          child: Icon(
                            Icons.lock_reset,
                            size: iconSize * 0.5,
                            color: ColoresApp.moradoLogin,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: _emailSent ? _buildSuccessContent(currentLang) : _buildFormContent(currentLang),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormContent(String currentLang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Título
        Text(
          AppStrings.get('recover_password', currentLang),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColoresApp.negro,
          ),
        ),

        const SizedBox(height: 12),

        // Subtítulo
        Text(
          AppStrings.get('recover_password_subtitle', currentLang),
          style: TextStyle(
            fontSize: 14,
            color: ColoresApp.gris600,
          ),
        ),

        const SizedBox(height: 32),

        // Campo de email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: AppStrings.get('email', currentLang),
                hintStyle: TextStyle(color: ColoresApp.gris400),
                prefixIcon: Icon(Icons.email_outlined, color: ColoresApp.gris600),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _emailError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _emailError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                if (_emailError != null) {
                  setState(() {
                    _emailError = _validarEmail(value);
                  });
                }
              },
            ),
            if (_emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  _emailError!,
                  style: TextStyle(
                    color: ColoresApp.rojoError,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 32),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _enviarEnlace,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.negro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: ColoresApp.blanco,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppStrings.get('send_link', currentLang),
                    style: TextStyle(
                      color: ColoresApp.blanco,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(String currentLang) {
    return Column(
      children: [
        const SizedBox(height: 48),

        // Icono de éxito
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ColoresApp.verdeExito.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 50,
            color: ColoresApp.verdeExito,
          ),
        ),

        const SizedBox(height: 24),

        // Mensaje de éxito
        Text(
          AppStrings.get('email_sent', currentLang),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: ColoresApp.gris600,
          ),
        ),

        const SizedBox(height: 48),

        // Botón volver al login
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColoresApp.negro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppStrings.get('back_to_login', currentLang),
              style: TextStyle(
                color: ColoresApp.blanco,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
