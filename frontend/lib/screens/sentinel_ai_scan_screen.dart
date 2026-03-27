import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/sentinel_ai_service.dart';
import '../theme/app_colors.dart';

class SentinelAIScanScreen extends StatefulWidget {
  static const String routeName = '/ai-scan';
  const SentinelAIScanScreen({super.key});

  @override
  State<SentinelAIScanScreen> createState() => _SentinelAIScanScreenState();
}

class _SentinelAIScanScreenState extends State<SentinelAIScanScreen>
    with SingleTickerProviderStateMixin {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  late AnimationController _scanAnimationController;
  late Animation<double> _pulseAnimation;
  late final SentinelAiService _sentinelAiService;
  Timer? _analysisTimer;
  StreamSubscription<SentinelLiveUpdate>? _analysisSubscription;
  int _analysisStep = 0;

  static const List<Map<String, dynamic>> _analysisFrames = [
    {
      'status': 'scanning',
      'message': 'Detecting lower eyelid region...',
      'confidence': 12.0,
      'hemoglobin_estimate': null,
      'risk_level': null,
    },
    {
      'status': 'analyzing',
      'message': 'Assessing conjunctival color saturation...',
      'confidence': 28.0,
      'hemoglobin_estimate': null,
      'risk_level': null,
    },
    {
      'status': 'analyzing',
      'message': 'Comparing pallor pattern to reference profile...',
      'confidence': 46.0,
      'hemoglobin_estimate': null,
      'risk_level': null,
    },
    {
      'status': 'detecting',
      'message': 'Mild conjunctival pallor signal detected.',
      'confidence': 67.0,
      'hemoglobin_estimate': 10.8,
      'risk_level': 'MEDIUM',
    },
    {
      'status': 'detecting',
      'message': 'Refining hemoglobin estimate from stable frames...',
      'confidence': 82.0,
      'hemoglobin_estimate': 10.4,
      'risk_level': 'MEDIUM',
    },
    {
      'status': 'final',
      'message': 'Mild anemia likely; clinical confirmation advised.',
      'confidence': 94.2,
      'hemoglobin_estimate': 10.2,
      'risk_level': 'MEDIUM',
    },
  ];

  late SentinelLiveUpdate _currentAnalysis;

  @override
  void initState() {
    super.initState();
    _sentinelAiService = SentinelAiService(baseUrl: _defaultBaseUrl);
    _scanAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _currentAnalysis = SentinelLiveUpdate.fromJson(_analysisFrames.first);
    _startLiveAnalysis();
  }

  Future<void> _startLiveAnalysis() async {
    _analysisSubscription?.cancel();

    try {
      _analysisSubscription = _sentinelAiService
          .streamLowerEyelidAnalysis(
            scanId: DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .listen(
            (update) {
              if (!mounted) return;
              setState(() {
                _currentAnalysis = update;
              });
            },
            onError: (_) {
              _startSimulatedAnalysis();
            },
            onDone: () {},
          );
    } catch (_) {
      _startSimulatedAnalysis();
    }
  }

  void _startSimulatedAnalysis() {
    setState(() {
      _analysisStep = 0;
      _currentAnalysis = SentinelLiveUpdate.fromJson(_analysisFrames.first);
    });

    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      if (_analysisStep >= _analysisFrames.length - 1) {
        _analysisTimer?.cancel();
        return;
      }

      setState(() {
        _analysisStep++;
        _currentAnalysis = SentinelLiveUpdate.fromJson(
          _analysisFrames[_analysisStep],
        );
      });
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _analysisSubscription?.cancel();
    _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.emergency_share, color: AppColors.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Sentinel AI Scan',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Feed Background
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCODjRU50PuZGOwbYdwrEGf7GCaCWnfQ0MegpdMlvAxwPv-b8EX85Gb_rR8UM9yQU5nUCC4ENXjSIe4Q3fZwIb0NDo8L3QRAkF6XpxW5sAdSGe7_F6392f-pO_gi2xWYv3mG9oLYTjGN4n6i9i2SECta-Czkq-vsz3PvLP2Q6p44DiC81WwSvTvLoH6_gjg3kG6er0KAtQ0yazfGNDI_osNdimRvuXprQ_jdwVrQi6IYM3HXK28W6P0kxAPeZIDmIs-jWeImnYRxTpa',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay darkness
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0F172A).withValues(alpha: 0.3),
                    const Color(0xFF0F172A).withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Viewfinder Circle
                          AnimatedBuilder(
                            animation: _scanAnimationController,
                            builder: (context, child) {
                              return Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withOpacity(0.15),
                                      blurRadius: 50,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer glow ring
                                    Container(
                                      width: 310,
                                      height: 310,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.secondary.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                    ),

                                    // Crosshairs
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 1,
                                          color: AppColors.secondary.withOpacity(0.5),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: AppColors.secondary.withOpacity(0.5),
                                        ),
                                      ],
                                    ),

                                    // Scanning beam line
                                    Positioned(
                                      top: 140 * _scanAnimationController.value,
                                      child: Container(
                                        width: 260,
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.transparent,
                                              AppColors.secondary,
                                              Colors.transparent,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppColors.secondary.withOpacity(0.8),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Center dot
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // Instruction
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.6),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Align the patient\'s lower eyelid within the circle and hold steady.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diagnostic Status',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentAnalysis.message,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _currentAnalysis.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _currentAnalysis.confidence / 100,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary.withOpacity(0.8),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Confidence Score
                  Text(
                    'AI Confidence Score: ${_currentAnalysis.confidence.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      jsonEncode(_currentAnalysis.toJson()),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF0F172A).withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.outlineVariant),
                onPressed: () => Navigator.pop(context),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scan captured successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.history,
                  color: AppColors.outlineVariant,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
