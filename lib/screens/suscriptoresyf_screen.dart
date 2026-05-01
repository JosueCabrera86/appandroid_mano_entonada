import 'package:flutter/material.dart';
import 'package:mano_entonada/screens/modales_yoga.dart';
import 'package:mano_entonada/data/material_base.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SuscriptoresYFScreen extends StatefulWidget {
  const SuscriptoresYFScreen({super.key});

  @override
  State<SuscriptoresYFScreen> createState() => _SuscriptoresYFScreenState();
}

class _SuscriptoresYFScreenState extends State<SuscriptoresYFScreen> {
  int nivelUsuario = 0;
  String? modalAbierto;
  String? error;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    fetchMaterial();
  }

  Future<void> fetchMaterial() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1️⃣ Verificar sesión activa
      final session = supabase.auth.currentSession;

      if (session == null) {
        setState(() {
          error = "Sesión no válida. Cierra e inicia sesión nuevamente.";
          cargando = false;
        });
        return;
      }

      // 2️⃣ Obtener email del usuario
      final email = session.user.email!;

      final response = await supabase
          .from('users')
          .select('categoria')
          .eq('email', email)
          .single();

      setState(() {
        nivelUsuario = response['categoria'] ?? 0;
        cargando = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        error = e.message;
        cargando = false;
      });
    } catch (e, stack) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('STACK: $stack');

      setState(() {
        error = e.toString();
      });
    }
  }

  void abrirModal(String tipo) => setState(() => modalAbierto = tipo);
  void cerrarModal() => setState(() => modalAbierto = null);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isLandscape = size.width > size.height;

    final portadaHeight = isLandscape ? size.height * 0.6 : size.height * 0.4;

    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rutinasPermitidas = rutinasBase
        .where((item) => item['categoria'] <= nivelUsuario)
        .map((e) => e['title'].toString())
        .toList();
    final masajesPermitidos = masajesBase
        .where((item) => item['categoria'] <= nivelUsuario)
        .map((e) => e['title'].toString())
        .toList();
    final clasesPermitidas = clasesBase
        .where((item) => item['categoria'] <= nivelUsuario)
        .map((e) => e['title'].toString())
        .toList();

    final secciones = [
      if (rutinasPermitidas.isNotEmpty)
        {
          'titulo': 'Rutinas de Yoga Facial',
          'tipo': 'rutinas',
          'imagen': 'assets/images/rutinas.jpg',
          'alignment': const Alignment(0, -0.5),
        },
      if (masajesPermitidos.isNotEmpty)
        {
          'titulo': 'Masajes previos a tu rutina',
          'tipo': 'masajes',
          'imagen': 'assets/images/masajes.jpg',
          'alignment': const Alignment(0, -0.5),
        },
      if (clasesPermitidas.isNotEmpty)
        {
          'titulo': 'Clases extra',
          'tipo': 'clases',
          'imagen': 'assets/images/clases.jpg',
          'alignment': const Alignment(0, -0.4),
        },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF5F2F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/face_yoga_portada.jpg',
                  width: double.infinity,
                  height: portadaHeight,
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.7),
                ),
                Container(
                  width: double.infinity,
                  height: portadaHeight,
                  color: Colors.black.withOpacity(0.5),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Material Adicional',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white70,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Yoga Facial',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.figtree(
                              color: Colors.pinkAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '¡Hola! Este espacio ha sido creado para \n continuar con tus sesiones de Yoga Facial \n y profundizar en tu práctica.',

                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5E72),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),

            if (modalAbierto == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: secciones.map((sec) {
                    final titulo = sec['titulo'] as String;
                    final tipo = sec['tipo'] as String;
                    final imagen = sec['imagen'] as String;
                    final alignment = sec['alignment'] as Alignment;

                    final cardWidth = isLandscape ? width * 0.7 : width * 0.9;
                    final cardHeight = isLandscape ? 180.0 : 140.0;

                    return AnimatedScale(
                      scale: 1,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTapUp: (_) => abrirModal(tipo),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          width: cardWidth,
                          height: cardHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            image: DecorationImage(
                              image: AssetImage(imagen),
                              fit: BoxFit.cover,
                              alignment: alignment,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.45),
                                BlendMode.darken,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (modalAbierto == 'rutinas')
              RutinasScreen(
                material: rutinasPermitidas,
                nivelUsuario: nivelUsuario,
                onClose: cerrarModal,
              ),
            if (modalAbierto == 'masajes')
              MasajesScreen(
                material: masajesPermitidos,
                nivelUsuario: nivelUsuario,
                onClose: cerrarModal,
              ),
            if (modalAbierto == 'clases')
              ClasesExtraScreen(
                material: clasesPermitidas,
                nivelUsuario: nivelUsuario,
                onClose: cerrarModal,
              ),
          ],
        ),
      ),
    );
  }
}
