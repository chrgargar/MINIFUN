import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'pantalla_registro.dart';
import 'pantalla_principal.dart';

// Pantalla de inicio de sesión
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Guarda lo que escribe el usuario
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isCheckingSession = true;

  // Para almacenar los mensajes de error
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
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu usuario o email';
    }
    return null;
  }

  // Validar contraseña
  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Entrar como invitado
  Future<void> _jugarComoInvitado() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.continueAsGuest();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al crear sesión de invitado'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se verifica la sesión
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7B68B8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera con el icono del usuario
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF7B68B8), // Morado
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle, // Círculo
                    border: Border.all(color: const Color(0xFF5B4A8B), width: 3),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 60,
                    color: Color(0xFF7B68B8),
                  ),
                ),
              ),
            ),

            // Formulario de login
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Campo de usuario o email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Usuario o email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          // Borde cuando no está enfocado
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          // Borde cuando está enfocado
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? const Color(0xFF7B68B8) : Colors.red,
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
                            style: const TextStyle(
                              color: Colors.red,
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
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
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
                              color: _passwordError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null ? const Color(0xFF7B68B8) : Colors.red,
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
                            style: const TextStyle(
                              color: Colors.red,
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
                      child: const Text(
                        '¿Has olvidado la contraseña?',
                        style: TextStyle(
                          color: Colors.blue,
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
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
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
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
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
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
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
                      icon: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.blue,
                        size: 32,
                      ),
                      label: const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
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
                    child: const Text(
                      'Jugar como invitado',
                      style: TextStyle(
                        color: Colors.black,
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(text: 'Al hacer clic en continuar, aceptas nuestros '),
                        TextSpan(
                          text: 'Términos de servicio',
                          style: TextStyle(color: Colors.blue),
                        ),
                        const TextSpan(text: ' y '),
                        TextSpan(
                          text: 'Política de privacidad',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
