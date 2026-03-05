import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tema/language_provider.dart';
import '../constants/app_strings.dart';

class PantallaTerminos extends StatelessWidget {
  const PantallaTerminos({super.key});

  // Secciones del documento por idioma
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
      'title': '1. Aceptación de los Términos',
      'content':
          'Al descargar, instalar o usar MINIFUN, confirmas que has leído, comprendido y aceptado estos Términos y Condiciones. Si no estás de acuerdo con alguno de ellos, te pedimos que no uses la aplicación.',
    },
    {
      'title': '2. Descripción del Servicio',
      'content':
          'MINIFUN es una aplicación de entretenimiento móvil que ofrece una colección de juegos clásicos: Snake, Water Sort, Sopa de Letras, Ahorcado, Buscaminas y Sudoku. La aplicación está disponible en versión gratuita y en versión PRO con contenido adicional.',
    },
    {
      'title': '3. Cuentas de Usuario',
      'content':
          '• Puedes usar MINIFUN como invitado sin necesidad de registrarte.\n'
          '• Al crear una cuenta, debes proporcionar información verídica y mantenerla actualizada.\n'
          '• Eres responsable de la confidencialidad de tu contraseña.\n'
          '• Puedes iniciar sesión con tu cuenta de Google.\n'
          '• Nos reservamos el derecho de suspender o eliminar cuentas que incumplan estos términos.',
    },
    {
      'title': '4. MINIFUN PRO',
      'content':
          '• La versión PRO está disponible por un pago único de 4,99 €.\n'
          '• El pago desbloquea de forma permanente modos de juego y contenidos adicionales.\n'
          '• No se trata de una suscripción periódica.\n'
          '• No se realizarán reembolsos salvo en los casos previstos por la legislación vigente.',
    },
    {
      'title': '5. Propiedad Intelectual',
      'content':
          'Todo el contenido de MINIFUN —incluidos diseños, gráficos, música, código fuente y marcas comerciales— es propiedad exclusiva de sus creadores y está protegido por las leyes de propiedad intelectual aplicables. Queda expresamente prohibida su reproducción, distribución o modificación sin autorización previa y por escrito.',
    },
    {
      'title': '6. Privacidad y Datos',
      'content':
          '• Recopilamos únicamente los datos necesarios para el funcionamiento de la app: nombre de usuario, correo electrónico y datos de sesión.\n'
          '• No vendemos ni cedemos tus datos personales a terceros con fines comerciales.\n'
          '• Los datos de proveedores externos (como Google) se rigen por sus propias políticas de privacidad.\n'
          '• Para más detalles, consulta nuestra Política de Privacidad completa.',
    },
    {
      'title': '7. Conducta del Usuario',
      'content':
          'Al usar MINIFUN te comprometes a:\n'
          '• Utilizar la aplicación de manera legal y respetuosa.\n'
          '• No intentar acceder de forma no autorizada a los sistemas o datos de la aplicación.\n'
          '• No modificar, copiar, distribuir ni comercializar contenido de la aplicación.',
    },
    {
      'title': '8. Limitación de Responsabilidad',
      'content':
          'MINIFUN se proporciona "tal cual", sin garantías de ningún tipo. No somos responsables de ningún daño directo, indirecto o incidental que pueda derivarse del uso o de la imposibilidad de uso de la aplicación, incluyendo pérdida de datos o interrupciones del servicio.',
    },
    {
      'title': '9. Modificaciones de los Términos',
      'content':
          'Nos reservamos el derecho de modificar estos Términos y Condiciones en cualquier momento. Los cambios importantes serán comunicados mediante una notificación en la aplicación. El uso continuado de MINIFUN tras la publicación de los cambios implica la aceptación de los nuevos términos.',
    },
    {
      'title': '10. Contacto',
      'content':
          '¿Tienes alguna pregunta sobre estos términos? Puedes ponerte en contacto con nosotros en:\n\nsoporte@minifun.app',
    },
  ];

  // ── ENGLISH ───────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _sectionsEn = [
    {
      'title': '1. Acceptance of Terms',
      'content':
          'By downloading, installing or using MINIFUN, you confirm that you have read, understood and accepted these Terms and Conditions. If you do not agree with any of them, please do not use the app.',
    },
    {
      'title': '2. Description of Service',
      'content':
          'MINIFUN is a mobile entertainment application offering a collection of classic games: Snake, Water Sort, Word Search, Hangman, Minesweeper and Sudoku. The app is available in a free version and a PRO version with additional content.',
    },
    {
      'title': '3. User Accounts',
      'content':
          '• You can use MINIFUN as a guest without registering.\n'
          '• When creating an account, you must provide truthful and up-to-date information.\n'
          '• You are responsible for keeping your password confidential.\n'
          '• You can sign in with your Google account.\n'
          '• We reserve the right to suspend or delete accounts that violate these terms.',
    },
    {
      'title': '4. MINIFUN PRO',
      'content':
          '• The PRO version is available for a one-time payment of €4.99.\n'
          '• The payment permanently unlocks additional game modes and content.\n'
          '• This is not a recurring subscription.\n'
          '• Refunds will not be issued except as required by applicable law.',
    },
    {
      'title': '5. Intellectual Property',
      'content':
          'All content in MINIFUN —including designs, graphics, music, source code and trademarks— is the exclusive property of its creators and is protected by applicable intellectual property laws. Reproduction, distribution or modification without prior written authorization is expressly prohibited.',
    },
    {
      'title': '6. Privacy and Data',
      'content':
          '• We collect only the data necessary for the app to function: username, email and session data.\n'
          '• We do not sell or transfer your personal data to third parties for commercial purposes.\n'
          '• Data from third-party providers (such as Google) is governed by their own privacy policies.\n'
          '• For more details, see our full Privacy Policy.',
    },
    {
      'title': '7. User Conduct',
      'content':
          'By using MINIFUN you agree to:\n'
          '• Use the app in a lawful and respectful manner.\n'
          '• Not attempt to gain unauthorized access to the app\'s systems or data.\n'
          '• Not modify, copy, distribute or sell app content.',
    },
    {
      'title': '8. Limitation of Liability',
      'content':
          'MINIFUN is provided "as is", without warranties of any kind. We are not responsible for any direct, indirect or incidental damages arising from the use or inability to use the app, including data loss or service interruptions.',
    },
    {
      'title': '9. Changes to Terms',
      'content':
          'We reserve the right to modify these Terms and Conditions at any time. Important changes will be communicated via an in-app notification. Continued use of MINIFUN after changes are published implies acceptance of the new terms.',
    },
    {
      'title': '10. Contact',
      'content':
          'Have a question about these terms? You can reach us at:\n\nsoporte@minifun.app',
    },
  ];

  // ── CATALÀ ────────────────────────────────────────────────────────────────
  static const List<Map<String, String>> _sectionsCa = [
    {
      'title': '1. Acceptació dels Termes',
      'content':
          'En descarregar, instal·lar o usar MINIFUN, confirmes que has llegit, comprés i acceptat estos Termes i Condicions. Si no estàs d\'acord amb algun d\'ells, et demanem que no uses l\'aplicació.',
    },
    {
      'title': '2. Descripció del Servei',
      'content':
          'MINIFUN és una aplicació d\'entreteniment mòbil que oferix una col·lecció de jocs clàssics: Snake, Water Sort, Sopa de Lletres, Penjat, Buscamines i Sudoku. L\'aplicació està disponible en versió gratuïta i en versió PRO amb contingut addicional.',
    },
    {
      'title': '3. Comptes d\'Usuari',
      'content':
          '• Pots usar MINIFUN com a convidat sense necessitat de registrar-te.\n'
          '• En crear un compte, has de proporcionar informació verídica i mantindre-la actualitzada.\n'
          '• Ets responsable de la confidencialitat de la teua contrasenya.\n'
          '• Pots iniciar sessió amb el teu compte de Google.\n'
          '• Ens reservem el dret de suspendre o eliminar comptes que incomplesquen estos termes.',
    },
    {
      'title': '4. MINIFUN PRO',
      'content':
          '• La versió PRO està disponible per un pagament únic de 4,99 €.\n'
          '• El pagament desbloqueja de manera permanent modes de joc i continguts addicionals.\n'
          '• No es tracta d\'una subscripció periòdica.\n'
          '• No es realitzaran reembossaments llevat dels casos previstos per la legislació vigent.',
    },
    {
      'title': '5. Propietat Intel·lectual',
      'content':
          'Tot el contingut de MINIFUN —inclosos dissenys, gràfics, música, codi font i marques comercials— és propietat exclusiva dels seus creadors i està protegit per les lleis de propietat intel·lectual aplicables. Queda expressament prohibida la seua reproducció, distribució o modificació sense autorització prèvia i per escrit.',
    },
    {
      'title': '6. Privacitat i Dades',
      'content':
          '• Recopilem únicament les dades necessàries per al funcionament de l\'app: nom d\'usuari, correu electrònic i dades de sessió.\n'
          '• No venem ni cedim les teues dades personals a tercers amb fins comercials.\n'
          '• Les dades de proveïdors externs (com Google) es regixen per les seues pròpies polítiques de privacitat.\n'
          '• Per a més detalls, consulta la nostra Política de Privacitat completa.',
    },
    {
      'title': '7. Conducta de l\'Usuari',
      'content':
          'En usar MINIFUN et compromets a:\n'
          '• Utilitzar l\'aplicació de manera legal i respectuosa.\n'
          '• No intentar accedir de forma no autoritzada als sistemes o dades de l\'aplicació.\n'
          '• No modificar, copiar, distribuir ni comercialitzar contingut de l\'aplicació.',
    },
    {
      'title': '8. Limitació de Responsabilitat',
      'content':
          'MINIFUN es proporciona "tal com és", sense garanties de cap tipus. No som responsables de cap dany directe, indirecte o incidental que puga derivar-se de l\'ús o de la impossibilitat d\'ús de l\'aplicació, incloent pèrdua de dades o interrupcions del servei.',
    },
    {
      'title': '9. Modificacions dels Termes',
      'content':
          'Ens reservem el dret de modificar estos Termes i Condicions en qualsevol moment. Els canvis importants seran comunicats mitjançant una notificació a l\'aplicació. L\'ús continuat de MINIFUN després de la publicació dels canvis implica l\'acceptació dels nous termes.',
    },
    {
      'title': '10. Contacte',
      'content':
          'Tens alguna pregunta sobre estos termes? Pots posar-te en contacte amb nosaltres en:\n\nsoporte@minifun.app',
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
          AppStrings.get('terms_and_conditions', currentLang),
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
                        Icons.shield_outlined,
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
