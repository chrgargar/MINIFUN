import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../tema/app_colors.dart';
import '../utils/validators.dart';
import 'pantalla_registro.dart';
import 'pantalla_principal.dart';

// Pantalla de inicio de sesión
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Controladores de texto para los campos de entrada
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Estados de UI
  bool _obscurePassword = true; // Controla si la contraseña está oculta
  bool _isCheckingSession = true; // Indica si se está verificando sesión existente

  // Mensajes de error de validación
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para ejecutar después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  // Verificar si hay una sesión existente
  Future<void> _checkExistingSession() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Usar initSilent para no interferir con la UI
      await authProvider.initSilent();

      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });

        // Si ya está logueado, ir directo a la pantalla principal
        if (authProvider.isLoggedIn) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
          );
        }
      }
    } catch (e) {
      // En caso de error, mostrar la pantalla de login
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
        print('Error al verificar sesión: $e');
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validar usuario o email
  String? _validarUsername(String? value) {
    return Validators.validateUsernameOrEmail(value);
  }

  // Validar contraseña
  String? _validarPassword(String? value) {
    return Validators.validatePassword(value);
  }

  // Función para iniciar sesión
  Future<void> _iniciarSesion() async {
    setState(() {
      _usernameError = _validarUsername(_usernameController.text);
      _passwordError = _validarPassword(_passwordController.text);
    });

    if (_usernameError != null || _passwordError != null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      usernameOrEmail: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: ColoresApp.rojoError,
        ),
      );
    }
  }

  // Entrar como invitado
  Future<void> _jugarComoInvitado() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = false;
    try {
      success = await authProvider.continueAsGuest();
    } catch (e) {
      // If DB/auth fails, allow continuing as guest locally so user can try games
      success = false;
      print('Warning: continueAsGuest failed: $e');
    }

    // Always allow navigation to the main screen so games can be tried offline.
    if (mounted) {
      if (!success) {
        // Inform the user but don't block navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo crear sesión de invitado en el servidor. Continuando en modo local.'),
            backgroundColor: ColoresApp.naranjaAdvertencia,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se verifica la sesión
    if (_isCheckingSession) {
      return Scaffold(
        backgroundColor: ColoresApp.blanco,
        body: Center(
          child: CircularProgressIndicator(
            color: ColoresApp.moradoLogin,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Distribución porcentual de la altura
          double availableHeight = constraints.maxHeight;
          double headerHeight = availableHeight * 0.25; // 25% para header
          double formHeight = availableHeight * 0.75; // 75% para formulario

          // Tamaños adaptativos
          double iconSize = (headerHeight * 0.35).clamp(80.0, 100.0);
          double padding = constraints.maxWidth * 0.06;

          return Column(
            children: [
              // Cabecera con el icono del usuario
              Container(
                width: double.infinity,
                height: headerHeight,
                decoration: BoxDecoration(
                  color: ColoresApp.moradoLogin,
                ),
                child: Center(
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: ColoresApp.blanco,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColoresApp.moradoLoginOscuro, width: 3),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: iconSize * 0.6,
                      color: ColoresApp.moradoLogin,
                    ),
                  ),
                ),
              ),

              // Formulario de login
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      SizedBox(height: formHeight * 0.03),

                      // Campo de usuario o email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Usuario o email',
                              hintStyle: TextStyle(color: ColoresApp.gris400),
                              // Borde cuando no está enfocado
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _usernameError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                                ),
                              ),
                              // Borde cuando está enfocado
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _usernameError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            // Revalidar mientras el usuario escribe
                            onChanged: (value) {
                              if (_usernameError != null) {
                                setState(() {
                                  _usernameError = _validarUsername(value);
                                });
                              }
                            },
                          ),
                          // Mostrar mensaje de error si existe
                          if (_usernameError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                _usernameError!,
                                style: TextStyle(
                                  color: ColoresApp.rojoError,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Campo de contraseña
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword, // Ocultar texto con puntos
                            decoration: InputDecoration(
                              hintText: 'Contraseña',
                              hintStyle: TextStyle(color: ColoresApp.gris400),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: ColoresApp.gris600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _passwordError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _passwordError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            // Revalidar mientras el usuario escribe
                            onChanged: (value) {
                              if (_passwordError != null) {
                                setState(() {
                                  _passwordError = _validarPassword(value);
                                });
                              }
                            },
                          ),
                          // Mostrar mensaje de error si ya existe
                          if (_passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                _passwordError!,
                                style: TextStyle(
                                  color: ColoresApp.rojoError,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Botón de has olvidado la contraseña
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {}, // Lo que hará al pulsarlo
                          child: Text(
                            '¿Has olvidado la contraseña?',
                            style: TextStyle(
                              color: ColoresApp.azulInfo,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón Iniciar Sesión
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.negro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: ColoresApp.blanco,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón Registrarse
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navegar a la página de registro
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PantallaRegistro(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColoresApp.negro,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Registrarse',
                            style: TextStyle(
                              color: ColoresApp.blanco,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // "o" para dividir
                      Row(
                        children: [
                          Expanded(child: Divider(color: ColoresApp.gris300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'o',
                              style: TextStyle(color: ColoresApp.gris600),
                            ),
                          ),
                          Expanded(child: Divider(color: ColoresApp.gris300)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Botón Continuar con Google
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Ir directo a la página principal
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                            );
                          },
                          icon: Icon(
                            Icons.g_mobiledata,
                            color: ColoresApp.azulInfo,
                            size: 32,
                          ),
                          label: Text(
                            'Continuar con Google',
                            style: TextStyle(
                              color: ColoresApp.negro,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ColoresApp.gris300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón Jugar como invitado
                      TextButton(
                        onPressed: _jugarComoInvitado,
                        child: Text(
                          'Jugar como invitado',
                          style: TextStyle(
                            color: ColoresApp.negro,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Términos y condiciones
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: ColoresApp.negro,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'Al hacer clic en continuar, aceptas nuestros '),
                            TextSpan(
                              text: 'Términos de servicio',
                              style: TextStyle(color: ColoresApp.azulInfo),
                            ),
                            const TextSpan(text: ' y '),
                            TextSpan(
                              text: 'Política de privacidad',
                              style: TextStyle(color: ColoresApp.azulInfo),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
