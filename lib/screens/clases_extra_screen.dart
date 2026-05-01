import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mano_entonada/data/material_base.dart';

class ClasesExtraScreen extends StatefulWidget {
  final List<dynamic> material;
  final int nivelUsuario;
  final VoidCallback onClose;

  const ClasesExtraScreen({
    super.key,
    required this.material,
    required this.nivelUsuario,
    required this.onClose,
  });

  @override
  State<ClasesExtraScreen> createState() => _ClasesExtraScreenState();
}

class _ClasesExtraScreenState extends State<ClasesExtraScreen> {
  YoutubePlayerController? _controller;

  List<Map<String, dynamic>> get clasesFiltradas => clasesBase
      .where((c) => (c['categoria'] ?? 0) <= widget.nivelUsuario)
      .toList();

  void abrirClase(Map<String, dynamic> clase) {
    if (clase['tipo'] == 'pdf') {
      _abrirModalPDF(clase);
    } else {
      _abrirVideo(clase['video']);
    }
  }

  void _abrirVideo(String videoId) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
      ),
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cerrar",
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _controller?.dispose();
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  void _abrirModalPDF(Map<String, dynamic> clase) {
    int imagenIndex = 0;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Cerrar",
      barrierColor: Colors.black,
      pageBuilder: (dialogContext, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,

          body: Stack(
            children: [
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Stack(
                    children: [
                      Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.asset(
                            'assets/imgsuscriptores/${clase['pdf'][imagenIndex]}',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      if ((clase['pdf'] as List).length > 1) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white54,
                              size: 50,
                            ),
                            onPressed: () => setModalState(
                              () => imagenIndex =
                                  (imagenIndex -
                                      1 +
                                      (clase['pdf'] as List).length) %
                                  (clase['pdf'] as List).length,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                              size: 50,
                            ),
                            onPressed: () => setModalState(
                              () => imagenIndex =
                                  (imagenIndex + 1) %
                                  (clase['pdf'] as List).length,
                            ),
                          ),
                        ),
                      ],

                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            "${imagenIndex + 1} / ${(clase['pdf'] as List).length}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              Positioned(
                top: 50,
                right: 20,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB4A1C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar clases extra'),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: clasesFiltradas.length,
            itemBuilder: (context, index) {
              final clase = clasesFiltradas[index];
              final bool esPDF = clase['tipo'] == 'pdf';
              final String? videoId = !esPDF ? clase['video'] : null;
              final String? thumbnailUrl = clase['portada'] != null
                  ? 'assets/imgminis/${clase['portada']}'
                  : (videoId != null
                        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
                        : null);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: GestureDetector(
                    onTap: () => abrirClase(clase),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (thumbnailUrl != null)
                            thumbnailUrl.startsWith('assets')
                                ? Image.asset(thumbnailUrl, fit: BoxFit.cover)
                                : Image.network(thumbnailUrl, fit: BoxFit.cover)
                          else
                            Container(color: Colors.grey[300]),
                          Container(color: Colors.black.withOpacity(0.35)),
                          Center(
                            child: Icon(
                              esPDF
                                  ? Icons.picture_as_pdf
                                  : Icons.play_circle_fill,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
