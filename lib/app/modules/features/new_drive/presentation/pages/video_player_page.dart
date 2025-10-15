import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';

import '../../../../../../config/api_config.dart';
import '../../domain/entities/drive_item.dart';

/// Página de reprodução de vídeo com Chewie
///
/// Features:
/// - Streaming progressivo com Range Requests
/// - Controles completos (play, pause, seek, volume, fullscreen)
/// - Fullscreen com rotação automática
/// - Auto-hide dos controles
/// - Loading states e error handling
class VideoPlayerPage extends StatefulWidget {
  final DriveItem item;

  const VideoPlayerPage({
    super.key,
    required this.item,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Inicializa o player de vídeo com Chewie
  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });

      // URL de streaming (usa Range Requests automaticamente)
      final streamUrl =
          '${ApiConfig.baseUrl}/api/files/${widget.item.id}/stream';

      // Obter token de autenticação
      final token = await _secureStorage.read(key: 'auth_token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Usuário não autenticado. Faça login novamente.';
        });
        return;
      }

      debugPrint('✅ Inicializando VideoPlayer com URL: $streamUrl');

      // 1. Criar VideoPlayerController
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        httpHeaders: {
          'Authorization': 'Bearer $token',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // 2. Inicializar VideoPlayerController
      await _videoController!.initialize();

      // 3. Criar ChewieController com controles completos
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,

        // Configurações de reprodução
        autoPlay: true,
        looping: false,

        // Configurações de UI
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: true,
        hideControlsTimer: const Duration(seconds: 3),

        // Placeholder durante loading
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF2196F3),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Carregando vídeo...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.item.name,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Cores personalizadas (Material Design)
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF2196F3),
          handleColor: const Color(0xFF1976D2),
          backgroundColor: Colors.grey.shade800,
          bufferedColor: Colors.grey.shade600,
        ),

        // Orientações após sair do fullscreen
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],

        // Overlays do sistema após fullscreen
        systemOverlaysAfterFullScreen: [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom,
        ],
      );

      setState(() {
        _isInitialized = true;
      });

      debugPrint('✅ Chewie inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar player: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar vídeo: $e';
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();

    // Restaurar orientação ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.item.name,
          style: TextStyle(fontSize: 16.sp),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Estado de erro
    if (_hasError) {
      return _buildErrorState();
    }

    // Estado de loading (antes de inicializar)
    if (!_isInitialized || _chewieController == null) {
      return _buildLoadingState();
    }

    // Player Chewie (com todos os controles)
    return Center(
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }

  /// Estado de loading inicial
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2196F3),
          ),
          SizedBox(height: 16.h),
          Text(
            'Preparando player...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de erro com retry
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Erro ao carregar vídeo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              _errorMessage ?? 'Ocorreu um erro desconhecido',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
