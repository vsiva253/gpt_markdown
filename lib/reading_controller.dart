import 'package:flutter/foundation.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

/// Controller for managing TTS reading with block-by-block highlighting.
/// 
/// This controller reads markdown content block-by-block using flutter_tts
/// and notifies the UI which block is currently being read for highlighting.
/// 
/// **Note:** This requires `flutter_tts` package to be added to your dependencies.
/// Pass a FlutterTts instance to the constructor.
/// 
/// Example usage:
/// ```dart
/// import 'package:flutter_tts/flutter_tts.dart' as tts;
/// 
/// final flutterTts = tts.FlutterTts();
/// final blocks = gptMarkdownToSpeechBlocks(markdown, useDollarSignsForLatex: true);
/// final controller = ReadingController(blocks, flutterTts);
/// 
/// // Use with ValueListenableBuilder
/// ValueListenableBuilder<int?>(
///   valueListenable: controller.currentReadingBlockIndex,
///   builder: (context, index, _) {
///     return GptMarkdown(
///       markdown,
///       currentReadingBlockIndex: index,
///     );
///   },
/// )
/// 
/// // Start reading
/// await controller.start();
/// ```
class ReadingController {
  /// The TTS engine instance (FlutterTts from flutter_tts package)
  final dynamic _tts;
  
  final List<SpeechBlock> _blocks;
  int _currentIndex = 0;
  bool _isPaused = false;

  /// Notifies UI (GptMarkdown) which sentence is active for highlighting
  /// 
  /// This contains the SENTENCE index (global across all paragraphs).
  /// Each sentence gets highlighted individually for precise tracking.
  /// 
  /// Use this with ValueListenableBuilder to update the highlight:
  /// ```dart
  /// ValueListenableBuilder<int?>(
  ///   valueListenable: controller.currentReadingBlockIndex,
  ///   builder: (context, index, _) {
  ///     return GptMarkdown(
  ///       markdown,
  ///       currentReadingBlockIndex: index,
  ///     );
  ///   },
  /// )
  /// ```
  final ValueNotifier<int?> currentReadingBlockIndex = ValueNotifier<int?>(null);
  
  /// Notifies UI about pause state for icon updates
  /// 
  /// Use this with ValueListenableBuilder to update the play/pause icon:
  /// ```dart
  /// ValueListenableBuilder<bool>(
  ///   valueListenable: controller.isPausedNotifier,
  ///   builder: (context, isPaused, _) {
  ///     return Icon(isPaused ? Icons.play_circle : Icons.pause_circle);
  ///   },
  /// )
  /// ```
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);

  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Creates a reading controller with the given speech blocks and TTS instance
  /// 
  /// [blocks] - List of speech blocks to read
  /// [flutterTts] - FlutterTts instance from flutter_tts package
  /// [language] - Language code for TTS (default: 'en-IN' for Indian English, fallback: 'en-US')
  /// [speechRate] - Speech rate (0.0 to 1.0, default: 0.4 for teaching-friendly)
  /// [pitch] - Voice pitch (0.5 to 2.0, default: 1.15 for friendlier sound)
  ReadingController(
    this._blocks,
    this._tts, {
    String? language,
    double speechRate = 0.4,
    double pitch = 1.15,
  }) : _speechRate = speechRate,
       _pitch = pitch {
    _init(language: language);
  }
  
  double _speechRate;
  final double _pitch;
  
  /// Current voice identifier (null = default)
  String? _currentVoice;
  
  /// Available voices list
  List<dynamic>? _availableVoices;

  /// Initializes the TTS engine with proper language setup
  Future<void> _init({String? language}) async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;

    try {
      // Try to get available languages for debugging
      try {
        final availableLanguages = await _tts.getLanguages;
        if (kDebugMode) {
          debugPrint('[ReadingController] Available TTS languages: $availableLanguages');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ReadingController] Could not get available languages: $e');
        }
      }
      
      // Try to get available voices
      try {
        _availableVoices = await _tts.getVoices;
        if (kDebugMode) {
          debugPrint('[ReadingController] Available TTS voices: $_availableVoices');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ReadingController] Could not get available voices: $e');
        }
      }

      // Set language with fallback
      String targetLanguage = language ?? 'en-IN'; // Default to Indian English
      
      // Try to set the target language
      try {
        final result = await _tts.setLanguage(targetLanguage);
        if (kDebugMode) {
          debugPrint('[ReadingController] Set language to $targetLanguage: $result');
        }
      } catch (e) {
        // Fallback chain based on target language
        List<String> fallbacks = [];
        
        if (targetLanguage == 'te-IN') {
          // Telugu fallbacks: try en-IN, then en-US
          fallbacks = ['en-IN', 'en-US'];
        } else if (targetLanguage == 'hi-IN') {
          // Hindi fallbacks: try en-IN, then en-US
          fallbacks = ['en-IN', 'en-US'];
        } else {
          // English fallbacks: try en-US
          fallbacks = ['en-US'];
        }
        
        bool languageSet = false;
        for (final fallback in fallbacks) {
          if (kDebugMode) {
            debugPrint('[ReadingController] Failed to set $targetLanguage, trying $fallback: $e');
          }
          try {
            await _tts.setLanguage(fallback);
            targetLanguage = fallback;
            languageSet = true;
            if (kDebugMode) {
              debugPrint('[ReadingController] Successfully set fallback language: $fallback');
            }
            break;
          } catch (e2) {
            if (kDebugMode) {
              debugPrint('[ReadingController] Failed to set $fallback: $e2');
            }
          }
        }
        
        if (!languageSet && kDebugMode) {
          debugPrint('[ReadingController] Warning: Could not set any language, TTS may not work correctly');
        }
      }

      // Set TTS parameters for cute, teaching-friendly voice
      // Slower rate for teaching (0.4 = slower, more deliberate)
      // Higher pitch for friendlier/cuter sound (1.15 = slightly higher)
      // Full volume for clarity
      await _tts.setSpeechRate(_speechRate);  // Customizable rate (default: 0.4 for teaching)
      await _tts.setPitch(_pitch);            // Customizable pitch (default: 1.15 for friendlier)
      await _tts.setVolume(1.0);               // Full volume
      await _tts.awaitSpeakCompletion(true);

      // Set completion handler
      _tts.setCompletionHandler(() {
        _currentIndex++;
        if (_currentIndex < _blocks.length) {
          // Use sentence index (current index) for precise sentence-level highlighting
          currentReadingBlockIndex.value = _currentIndex;
          _speakCurrent();
        } else {
          currentReadingBlockIndex.value = null; // finished
          isPausedNotifier.value = false; // Reset pause state when finished
        }
      });

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('[ReadingController] TTS initialized successfully with language: $targetLanguage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReadingController] Error initializing TTS: $e');
      }
      // Mark as initialized anyway to prevent infinite retries
      _isInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  /// Starts reading from the beginning
  /// Ensures TTS is initialized before starting
  Future<void> start() async {
    if (_blocks.isEmpty) return;
    
    // Ensure initialization is complete
    if (!_isInitialized && !_isInitializing) {
      await _init();
    }
    
    // Wait for initialization if in progress
    while (_isInitializing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    _currentIndex = 0;
    // Set to sentence index (0) for precise sentence-level highlighting
    currentReadingBlockIndex.value = 0;
    isPausedNotifier.value = false; // Not paused when starting
    await _speakCurrent();
  }

  /// Speaks the current block with a small pause for natural flow
  Future<void> _speakCurrent() async {
    await _tts.stop();
    
    // Add a small pause before speaking for more natural, teaching-like flow
    // This makes the reading feel more deliberate and friendly
    await Future.delayed(const Duration(milliseconds: 150));
    
    await _tts.speak(_blocks[_currentIndex].text);
  }

  /// Pauses the current reading
  Future<void> pause() async {
    _isPaused = true;
    isPausedNotifier.value = true;
    await _tts.pause();
  }

  /// Resumes reading from where it was paused
  Future<void> resume() async {
    if (!_isPaused) return;
    
    _isPaused = false;
    isPausedNotifier.value = false;
    // Resume from the current block
    if (_currentIndex < _blocks.length) {
      await _speakCurrent();
    }
  }

  /// Stops reading and resets
  Future<void> stop() async {
    _isPaused = false;
    isPausedNotifier.value = false;
    await _tts.stop();
    currentReadingBlockIndex.value = null;
    _currentIndex = 0;
  }
  
  /// Returns whether the reading is currently paused
  bool get isPaused => _isPaused;
  
  /// Returns whether the reading is currently active (playing or paused)
  bool get isActive => _isPaused || currentReadingBlockIndex.value != null;
  
  /// Gets available voices
  Future<List<dynamic>> getAvailableVoices() async {
    if (_availableVoices != null) {
      return _availableVoices!;
    }
    try {
      _availableVoices = await _tts.getVoices;
      return _availableVoices ?? [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReadingController] Error getting voices: $e');
      }
      return [];
    }
  }
  
  /// Sets the speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (rate < 0.0 || rate > 1.0) {
      if (kDebugMode) {
        debugPrint('[ReadingController] Speech rate must be between 0.0 and 1.0');
      }
      return;
    }
    _speechRate = rate;
    try {
      await _tts.setSpeechRate(rate);
      if (kDebugMode) {
        debugPrint('[ReadingController] Speech rate set to: $rate');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ReadingController] Error setting speech rate: $e');
      }
    }
  }
  
  /// Gets current speech rate
  double get speechRate => _speechRate;
  
  /// Sets the voice by identifier
  Future<void> setVoice(String? voiceId) async {
    if (voiceId == null) {
      _currentVoice = null;
      return;
    }
    
    try {
      await _tts.setVoice({'name': voiceId, 'locale': ''});
      _currentVoice = voiceId;
      if (kDebugMode) {
        debugPrint('[ReadingController] Voice set to: $voiceId');
      }
    } catch (e) {
      // Try alternative format
      try {
        await _tts.setVoice({'name': voiceId});
        _currentVoice = voiceId;
        if (kDebugMode) {
          debugPrint('[ReadingController] Voice set to: $voiceId (alternative format)');
        }
      } catch (e2) {
        if (kDebugMode) {
          debugPrint('[ReadingController] Error setting voice: $e2');
        }
      }
    }
  }
  
  /// Gets current voice identifier
  String? get currentVoice => _currentVoice;

  /// Disposes the controller and cleans up resources
  void dispose() {
    _tts.stop();
    currentReadingBlockIndex.dispose();
    isPausedNotifier.dispose();
  }
}

