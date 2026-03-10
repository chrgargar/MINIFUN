import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/language_provider.dart';
import '../constants/app_strings.dart';

class PantallaPrivacidad extends StatelessWidget {
  const PantallaPrivacidad({super.key});

  static List<Map<String, String>> _getSections(String lang) {
    switch (lang) {
      case 'en':
        return _sectionsEn;
      case 'ca':
        return _sectionsCa;
      default:
        return _sectionsEs;
    }
  }

  static String _getLastUpdated(String lang) {
    switch (lang) {
      case 'en':
        return 'Last updated: March 2, 2026';
      case 'ca':
        return 'Última actualització: 2 de març de 2026';
      default:
        return 'Última actualización: 2 de marzo de 2026';
    }
  }

  // ── ESPAÑOL ──────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _sectionsEs = [
    {
      'title': '1. Responsable del Tratamiento',
      'content':
          'El responsable del tratamiento de los datos personales recogidos a través de MINIFUN es el equipo de desarrollo de MINIFUN.\n\nContacto: soporte@minifun.app',
    },
    {
      'title': '2. Datos que Recopilamos',
      'content':
          'Podemos recopilar los siguientes tipos de datos:\n\n'
          '• Datos de cuenta: nombre de usuario y correo electrónico (opcionales al registrarse).\n'
          '• Datos de sesión: token de sesión almacenado localmente en el dispositivo.\n'
          '• Datos de Google: si inicias sesión con Google, recibimos tu nombre, correo electrónico e identificador de Google. Estos datos se rigen por la política de privacidad de Google.\n'
          '• Datos de uso: progreso en juegos y preferencias de la app, almacenados únicamente en el dispositivo.\n\n'
          'No recopilamos datos de ubicación, contactos ni ningún otro dato sensible.',
    },
    {
      'title': '3. Finalidad del Tratamiento',
      'content':
          'Utilizamos tus datos exclusivamente para:\n\n'
          '• Permitir el acceso a tu cuenta y mantener la sesión activa.\n'
          '• Guardar tus preferencias y progreso de juego.\n'
          '• Mejorar la experiencia de usuario dentro de la aplicación.',
    },
    {
      'title': '4. Base Legal',
      'content':
          'El tratamiento de tus datos se basa en:\n\n'
          '• Tu consentimiento, otorgado al crear una cuenta o al iniciar sesión con Google.\n'
          '• La ejecución del contrato, en los casos en que el tratamiento sea necesario para prestarte el servicio.\n\n'
          'Puedes retirar tu consentimiento en cualquier momento eliminando tu cuenta.',
    },
    {
      'title': '5. Almacenamiento y Seguridad',
      'content':
          '• Los datos de sesión y preferencias se almacenan localmente en tu dispositivo.\n'
          '• Las contraseñas se almacenan cifradas y nunca en texto plano.\n'
          '• Aplicamos medidas técnicas y organizativas razonables para proteger tus datos frente a accesos no autorizados, pérdidas o alteraciones.',
    },
    {
      'title': '6. Compartición de Datos',
      'content':
          'No vendemos, alquilamos ni cedemos tus datos personales a terceros con fines comerciales.\n\n'
          'Los únicos terceros que pueden acceder a determinados datos son:\n\n'
          '• Google LLC: si usas la autenticación con Google, sujeto a su propia política de privacidad (policies.google.com).\n'
          '• Proveedores de servicios técnicos que nos ayudan a operar la aplicación, siempre bajo acuerdos de confidencialidad.',
    },
    {
      'title': '7. Retención de Datos',
      'content':
          '• Los datos de sesión se eliminan al cerrar sesión o desinstalar la app.\n'
          '• Los datos de cuenta (si existe) se conservan mientras la cuenta esté activa.\n'
          '• Puedes solicitar la eliminación de tu cuenta y todos tus datos en cualquier momento contactando con soporte@minifun.app.',
    },
    {
      'title': '8. Tus Derechos',
      'content':
          'De acuerdo con la normativa vigente (RGPD), tienes derecho a:\n\n'
          '• Acceder a tus datos personales.\n'
          '• Rectificar datos inexactos o incompletos.\n'
          '• Solicitar la eliminación de tus datos.\n'
          '• Oponerte al tratamiento de tus datos.\n'
          '• Solicitar la portabilidad de tus datos.\n\n'
          'Para ejercer cualquiera de estos derechos, escríbenos a soporte@minifun.app.',
    },
    {
      'title': '9. Menores de Edad',
      'content':
          'MINIFUN no está dirigida a menores de 13 años. No recopilamos conscientemente datos personales de menores. Si eres padre o tutor y crees que tu hijo ha proporcionado datos personales, contáctanos para eliminarlos.',
    },
    {
      'title': '10. Cambios en esta Política',
      'content':
          'Podemos actualizar esta Política de Privacidad ocasionalmente. Los cambios importantes se comunicarán mediante una notificación en la aplicación. Te recomendamos revisar esta política periódicamente.\n\nContacto: soporte@minifun.app',
    },
  ];

  // ── ENGLISH ───────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _sectionsEn = [
    {
      'title': '1. Data Controller',
      'content':
          'The controller responsible for processing personal data collected through MINIFUN is the MINIFUN development team.\n\nContact: soporte@minifun.app',
    },
    {
      'title': '2. Data We Collect',
      'content':
          'We may collect the following types of data:\n\n'
          '• Account data: username and email address (optional at registration).\n'
          '• Session data: session token stored locally on your device.\n'
          '• Google data: if you sign in with Google, we receive your name, email and Google identifier. This data is governed by Google\'s privacy policy.\n'
          '• Usage data: in-game progress and app preferences, stored only on your device.\n\n'
          'We do not collect location, contacts or any other sensitive data.',
    },
    {
      'title': '3. Purpose of Processing',
      'content':
          'We use your data exclusively to:\n\n'
          '• Allow access to your account and maintain an active session.\n'
          '• Save your preferences and game progress.\n'
          '• Improve the user experience within the app.',
    },
    {
      'title': '4. Legal Basis',
      'content':
          'Processing of your data is based on:\n\n'
          '• Your consent, given when creating an account or signing in with Google.\n'
          '• Performance of a contract, where processing is necessary to provide the service.\n\n'
          'You may withdraw your consent at any time by deleting your account.',
    },
    {
      'title': '5. Storage and Security',
      'content':
          '• Session data and preferences are stored locally on your device.\n'
          '• Passwords are stored encrypted and never in plain text.\n'
          '• We apply reasonable technical and organizational measures to protect your data against unauthorized access, loss or alteration.',
    },
    {
      'title': '6. Data Sharing',
      'content':
          'We do not sell, rent or transfer your personal data to third parties for commercial purposes.\n\n'
          'The only third parties that may access certain data are:\n\n'
          '• Google LLC: if you use Google authentication, subject to their own privacy policy (policies.google.com).\n'
          '• Technical service providers who help us operate the app, always under confidentiality agreements.',
    },
    {
      'title': '7. Data Retention',
      'content':
          '• Session data is deleted when you log out or uninstall the app.\n'
          '• Account data (if any) is retained while the account is active.\n'
          '• You may request deletion of your account and all your data at any time by contacting soporte@minifun.app.',
    },
    {
      'title': '8. Your Rights',
      'content':
          'Under applicable law (GDPR), you have the right to:\n\n'
          '• Access your personal data.\n'
          '• Rectify inaccurate or incomplete data.\n'
          '• Request erasure of your data.\n'
          '• Object to the processing of your data.\n'
          '• Request portability of your data.\n\n'
          'To exercise any of these rights, write to us at soporte@minifun.app.',
    },
    {
      'title': '9. Minors',
      'content':
          'MINIFUN is not directed at children under 13. We do not knowingly collect personal data from minors. If you are a parent or guardian and believe your child has provided personal data, please contact us to have it removed.',
    },
    {
      'title': '10. Changes to this Policy',
      'content':
          'We may update this Privacy Policy from time to time. Important changes will be communicated via an in-app notification. We recommend reviewing this policy periodically.\n\nContact: soporte@minifun.app',
    },
  ];

  // ── CATALÀ ────────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _sectionsCa = [
    {
      'title': '1. Responsable del Tractament',
      'content':
          'El responsable del tractament de les dades personals recollides a través de MINIFUN és l\'equip de desenvolupament de MINIFUN.\n\nContacte: soporte@minifun.app',
    },
    {
      'title': '2. Dades que Recopilem',
      'content':
          'Podem recopilar els tipus de dades següents:\n\n'
          '• Dades de compte: nom d\'usuari i correu electrònic (opcionals en registrar-se).\n'
          '• Dades de sessió: token de sessió emmagatzemat localment al dispositiu.\n'
          '• Dades de Google: si inicies sessió amb Google, rebem el teu nom, correu electrònic i identificador de Google. Estes dades es regixen per la política de privacitat de Google.\n'
          '• Dades d\'ús: progrés en jocs i preferències de l\'app, emmagatzemades únicament al dispositiu.\n\n'
          'No recopilem dades de localització, contactes ni cap altre dada sensible.',
    },
    {
      'title': '3. Finalitat del Tractament',
      'content':
          'Usem les teues dades exclusivament per a:\n\n'
          '• Permetre l\'accés al teu compte i mantindre la sessió activa.\n'
          '• Guardar les teues preferències i progrés de joc.\n'
          '• Millorar l\'experiència d\'usuari dins de l\'aplicació.',
    },
    {
      'title': '4. Base Legal',
      'content':
          'El tractament de les teues dades es basa en:\n\n'
          '• El teu consentiment, atorgat en crear un compte o en iniciar sessió amb Google.\n'
          '• L\'execució del contracte, en els casos en què el tractament siga necessari per a prestar-te el servei.\n\n'
          'Pots retirar el teu consentiment en qualsevol moment eliminant el teu compte.',
    },
    {
      'title': '5. Emmagatzematge i Seguretat',
      'content':
          '• Les dades de sessió i preferències s\'emmagatzemen localment al teu dispositiu.\n'
          '• Les contrasenyes s\'emmagatzemen xifrades i mai en text pla.\n'
          '• Apliquem mesures tècniques i organitzatives raonables per a protegir les teues dades enfront d\'accessos no autoritzats, pèrdues o alteracions.',
    },
    {
      'title': '6. Compartició de Dades',
      'content':
          'No venem, llogem ni cedim les teues dades personals a tercers amb fins comercials.\n\n'
          'Els únics tercers que poden accedir a determinades dades són:\n\n'
          '• Google LLC: si uses l\'autenticació amb Google, subjecte a la seua pròpia política de privacitat (policies.google.com).\n'
          '• Proveïdors de serveis tècnics que ens ajuden a operar l\'aplicació, sempre baix acords de confidencialitat.',
    },
    {
      'title': '7. Retenció de Dades',
      'content':
          '• Les dades de sessió s\'eliminen en tancar sessió o desinstal·lar l\'app.\n'
          '• Les dades de compte (si n\'hi ha) es conserven mentre el compte estiga actiu.\n'
          '• Pots sol·licitar l\'eliminació del teu compte i totes les teues dades en qualsevol moment contactant amb soporte@minifun.app.',
    },
    {
      'title': '8. Els Teus Drets',
      'content':
          'D\'acord amb la normativa vigent (RGPD), tens dret a:\n\n'
          '• Accedir a les teues dades personals.\n'
          '• Rectificar dades inexactes o incompletes.\n'
          '• Sol·licitar l\'eliminació de les teues dades.\n'
          '• Oposar-te al tractament de les teues dades.\n'
          '• Sol·licitar la portabilitat de les teues dades.\n\n'
          'Per a exercir qualsevol d\'estos drets, escriu-nos a soporte@minifun.app.',
    },
    {
      'title': '9. Menors d\'Edat',
      'content':
          'MINIFUN no està dirigida a menors de 13 anys. No recopilem conscientment dades personals de menors. Si ets pare o tutor i creus que el teu fill ha proporcionat dades personals, contacta\'ns per a eliminar-les.',
    },
    {
      'title': '10. Canvis en esta Política',
      'content':
          'Podem actualitzar esta Política de Privacitat ocasionalment. Els canvis importants es comunicaran mitjançant una notificació a l\'aplicació. Et recomanem revisar esta política periòdicament.\n\nContacte: soporte@minifun.app',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentLang = Provider.of<LanguageProvider>(context).currentLanguage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sections = _getSections(currentLang);
    final lastUpdated = _getLastUpdated(currentLang);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B3FF2),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppStrings.get('privacy_policy', currentLang),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7B3FF2).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7B3FF2).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip_outlined,
                        color: Color(0xFF7B3FF2),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'MINIFUN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lastUpdated,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Secciones
            ...sections.map((section) => _buildSection(
                  context: context,
                  title: section['title']!,
                  content: section['content']!,
                  isDark: isDark,
                )),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7B3FF2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const Divider(height: 32, thickness: 0.5),
        ],
      ),
    );
  }
}
