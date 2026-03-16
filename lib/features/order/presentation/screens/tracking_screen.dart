import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../shared/models/models.dart';

// ═══════════════════════════════════════════════
// ORDER CONFIRMATION SCREEN
// ═══════════════════════════════════════════════
class OrderConfirmScreen extends StatefulWidget {
  final String orderId;
  const OrderConfirmScreen({super.key, required this.orderId});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.3, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 110, height: 110,
                          decoration: BoxDecoration(
                            color: WajbaColors.successBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: WajbaColors.success.withOpacity(0.3), width: 3),
                          ),
                          child: const Center(child: Text('✅', style: TextStyle(fontSize: 52))),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Commande confirmée !',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: WajbaColors.grey900, fontFamily: 'Cairo'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Votre commande a été envoyée au restaurant.\nPréparation en cours...',
                        style: const TextStyle(fontSize: 15, color: WajbaColors.grey500, height: 1.5, fontFamily: 'Cairo'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Order ID card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: WajbaColors.bgSecondary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: WajbaColors.grey200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Numéro de commande', style: TextStyle(fontSize: 12, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                                Text(widget.orderId.length > 8 ? widget.orderId.substring(widget.orderId.length - 8).toUpperCase() : widget.orderId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: WajbaColors.primary, fontFamily: 'Cairo')),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Temps estimé', style: TextStyle(fontSize: 12, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                                Row(children: [
                                  const Icon(Icons.access_time, size: 14, color: WajbaColors.primary),
                                  const SizedBox(width: 4),
                                  const Text('25–35 min', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo')),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Steps
                      _OrderStepRow(steps: [
                        _Step('📋', 'Confirmée'),
                        _Step('👨‍🍳', 'Préparation'),
                        _Step('🛵', 'En route'),
                        _Step('🎉', 'Livrée'),
                      ], currentStep: 0),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/tracking/${widget.orderId}'),
                      icon: const Icon(Icons.location_on),
                      label: const Text('Suivre en temps réel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.main),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text('Retour à l\'accueil', style: TextStyle(fontSize: 15, fontFamily: 'Cairo')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  final String emoji, label;
  const _Step(this.emoji, this.label);
}

class _OrderStepRow extends StatelessWidget {
  final List<_Step> steps;
  final int currentStep;
  const _OrderStepRow({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) => Row(
    children: steps.asMap().entries.map((e) {
      final i = e.key;
      final s = e.value;
      final done = i <= currentStep;
      return Expanded(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: done ? WajbaColors.primary : WajbaColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 16))),
                ),
                const SizedBox(height: 4),
                Text(s.label, style: TextStyle(fontSize: 9, color: done ? WajbaColors.primary : WajbaColors.grey400, fontWeight: done ? FontWeight.w700 : FontWeight.w400, fontFamily: 'Cairo')),
              ],
            ),
            if (i < steps.length - 1)
              Expanded(child: Container(height: 2, color: done && i < currentStep ? WajbaColors.primary : WajbaColors.grey200, margin: const EdgeInsets.only(bottom: 18))),
          ],
        ),
      );
    }).toList(),
  );
}

// ═══════════════════════════════════════════════
// ORDER TRACKING SCREEN
// ═══════════════════════════════════════════════
class TrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapCtrl;
  Timer? _timer;
  LatLng _driverPos = const LatLng(36.8950, 7.7450);
  final LatLng _destPos = const LatLng(36.9065, 7.7335);
  OrderStatus _status = OrderStatus.preparing;
  int _eta = 22;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _mapReady = false;
  bool _sheetExpanded = false;

  // Simulated driver name
  final String _driverName = 'Karim Bensalem';
  final String _driverPhone = '0770123456';
  final String _driverRating = '4.8';
  final String _vehicle = 'Yamaha NMAX • 123 TNN 23';

  static const _statusSteps = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.picked_up,
    OrderStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    _buildMarkers();
    _startSimulation();
  }

  @override
  void dispose() { _timer?.cancel(); _mapCtrl?.dispose(); super.dispose(); }

  void _buildMarkers() {
    _markers
      ..clear()
      ..add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverPos,
        infoWindow: InfoWindow(title: _driverName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ))
      ..add(Marker(
        markerId: const MarkerId('dest'),
        position: _destPos,
        infoWindow: const InfoWindow(title: 'Votre adresse'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));

    _polylines
      ..clear()
      ..add(Polyline(
        polylineId: const PolylineId('route'),
        points: [_driverPos, _destPos],
        color: WajbaColors.primary,
        width: 4,
        patterns: [],
      ));
  }

  void _startSimulation() {
    int tick = 0;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      tick++;

      // Move driver closer
      final latDiff = (_destPos.latitude - _driverPos.latitude) * 0.12;
      final lngDiff = (_destPos.longitude - _driverPos.longitude) * 0.12;
      setState(() {
        _driverPos = LatLng(_driverPos.latitude + latDiff, _driverPos.longitude + lngDiff);
        _eta = max(0, _eta - 1);

        // Update status
        if (tick == 3) _status = OrderStatus.ready;
        if (tick == 6) _status = OrderStatus.picked_up;
        if (tick == 14) { _status = OrderStatus.delivered; _timer?.cancel(); }

        _buildMarkers();
      });

      _mapCtrl?.animateCamera(CameraUpdate.newLatLng(_driverPos));
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _statusSteps.indexOf(_status);

    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (_driverPos.latitude + _destPos.latitude) / 2,
                (_driverPos.longitude + _destPos.longitude) / 2,
              ),
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (c) { setState(() { _mapCtrl = c; _mapReady = true; }); },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Top bar ───────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: WajbaColors.grey900),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
                        child: Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: WajbaColors.success, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(_status.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Cairo')),
                            const Spacer(),
                            if (_eta > 0) ...[
                              const Icon(Icons.access_time, size: 14, color: WajbaColors.primary),
                              const SizedBox(width: 4),
                              Text('~$_eta min', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: WajbaColors.primary, fontFamily: 'Cairo')),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Sheet ──────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (d) { if (d.delta.dy < -6) setState(() => _sheetExpanded = true); if (d.delta.dy > 6) setState(() => _sheetExpanded = false); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                height: _sheetExpanded ? 420 : 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))],
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(child: Container(margin: const EdgeInsets.only(top: 10, bottom: 16), width: 40, height: 4, decoration: BoxDecoration(color: WajbaColors.grey200, borderRadius: BorderRadius.circular(2)))),

                    // Status steps
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _OrderStepRow(
                        steps: const [_Step('✅', 'Confirmée'), _Step('👨‍🍳', 'Préparation'), _Step('📦', 'Prête'), _Step('🛵', 'En route'), _Step('🎉', 'Livrée')],
                        currentStep: currentStep,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_status == OrderStatus.delivered) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: WajbaColors.successBg, borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Text('🎉', style: TextStyle(fontSize: 28)),
                              SizedBox(width: 12),
                              Expanded(child: Text('Commande livrée avec succès !', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WajbaColors.success, fontFamily: 'Cairo'))),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Driver card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: WajbaColors.bgSecondary, borderRadius: BorderRadius.circular(14)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24, backgroundColor: WajbaColors.primaryBg,
                                child: Text(_driverName[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: WajbaColors.primary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_driverName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                                    Text(_vehicle, style: const TextStyle(fontSize: 11, color: WajbaColors.grey500, fontFamily: 'Cairo')),
                                    Row(children: [
                                      const Icon(Icons.star_rounded, color: WajbaColors.star, size: 13),
                                      const SizedBox(width: 2),
                                      Text(_driverRating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Cairo')),
                                    ]),
                                  ],
                                ),
                              ),
                              // Call button
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(color: WajbaColors.successBg, shape: BoxShape.circle, border: Border.all(color: WajbaColors.success.withOpacity(0.3))),
                                  child: const Icon(Icons.phone_rounded, color: WajbaColors.success, size: 20),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Chat button
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(color: WajbaColors.primaryBg, shape: BoxShape.circle, border: Border.all(color: WajbaColors.primary.withOpacity(0.3))),
                                child: const Icon(Icons.chat_bubble_outline_rounded, color: WajbaColors.primary, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (_sheetExpanded) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _InfoRow(icon: Icons.receipt_long, label: 'Commande', value: '#${widget.orderId.substring(widget.orderId.length > 8 ? widget.orderId.length - 8 : 0)}'),
                            _InfoRow(icon: Icons.location_on_outlined, label: 'Destination', value: 'Annaba Centre, Rue Principale'),
                            _InfoRow(icon: Icons.payments_outlined, label: 'Paiement', value: 'Espèces à la livraison'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_status == OrderStatus.delivered)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity, height: 48,
                            child: ElevatedButton(
                              onPressed: () => context.go(AppRoutes.orders),
                              child: const Text('Voir mes commandes', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 16, color: WajbaColors.grey400),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: WajbaColors.grey500, fontFamily: 'Cairo')),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WajbaColors.grey800, fontFamily: 'Cairo')),
      ],
    ),
  );
}
