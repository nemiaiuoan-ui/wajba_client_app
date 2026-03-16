import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';

// ═══════════════════════════════════════════════
// PHONE INPUT SCREEN
// ═══════════════════════════════════════════════
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _phoneCtrl.dispose(); super.dispose(); }

  bool get _isValid => _phoneCtrl.text.length == 10 &&
      RegExp(r'^(05|06|07)\d{8}$').hasMatch(_phoneCtrl.text);

  Future<void> _submit() async {
    if (!_isValid || _loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).sendOtp(_phoneCtrl.text);
      if (mounted) {
        context.go('/otp', extra: {'phone': _phoneCtrl.text, 'isNew': false});
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Logo
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: WajbaColors.primaryBg, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 28),
              const Text('Bon retour !', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: WajbaColors.grey900, fontFamily: 'Cairo')),
              const SizedBox(height: 8),
              const Text('Entrez votre numéro de téléphone\npour continuer', style: TextStyle(fontSize: 15, color: WajbaColors.grey500, height: 1.5, fontFamily: 'Cairo')),
              const SizedBox(height: 40),

              // Phone field
              const Text('Numéro de téléphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WajbaColors.grey700, fontFamily: 'Cairo')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: WajbaColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: WajbaColors.grey200),
                    ),
                    child: const Row(
                      children: [
                        Text('🇩🇿', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 6),
                        Text('+213', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: WajbaColors.grey700, fontFamily: 'Cairo')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                      onChanged: (_) => setState(() => _error = null),
                      decoration: InputDecoration(
                        hintText: '0612 345 678',
                        errorText: _error,
                        filled: true, fillColor: WajbaColors.grey50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WajbaColors.grey200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WajbaColors.grey200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: WajbaColors.primary, width: 2)),
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1, fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: WajbaColors.error, fontSize: 12, fontFamily: 'Cairo')),
              ],

              const SizedBox(height: 12),
              Text(
                'Un code de vérification à 4 chiffres sera envoyé par SMS',
                style: TextStyle(fontSize: 12, color: WajbaColors.grey400, fontFamily: 'Cairo'),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isValid && !_loading ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WajbaColors.primary,
                    disabledBackgroundColor: WajbaColors.grey200,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Recevoir le code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// OTP VERIFICATION SCREEN
// ═══════════════════════════════════════════════
class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  int _countdown = AppConstants.otpExpiry;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) { _countdown--; } else { _canResend = true; }
      });
      return _countdown > 0 && mounted;
    });
  }

  Future<void> _verify(String otp) async {
    if (otp.length != AppConstants.otpLength || _loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).verifyOtp(phone: widget.phone, otp: otp);
      if (mounted) context.go(AppRoutes.main);
    } catch (e) {
      setState(() { _error = 'Code incorrect. Réessayez.'; _otpCtrl.clear(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    setState(() { _canResend = false; _countdown = AppConstants.otpExpiry; _error = null; });
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startCountdown();
  }

  @override
  void dispose() { _otpCtrl.dispose(); super.dispose(); }

  String get _formattedPhone {
    final p = widget.phone;
    if (p.length == 10) return '${p.substring(0,4)} ${p.substring(4,7)} ${p.substring(7)}';
    return p;
  }

  String get _countdownLabel {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 58, height: 62,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: WajbaColors.grey900, fontFamily: 'Cairo'),
      decoration: BoxDecoration(
        color: WajbaColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WajbaColors.grey200, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Vérification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: WajbaColors.grey900, fontFamily: 'Cairo')),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: WajbaColors.grey500, height: 1.5, fontFamily: 'Cairo'),
                children: [
                  const TextSpan(text: 'Code envoyé au '),
                  TextSpan(text: _formattedPhone, style: const TextStyle(fontWeight: FontWeight.w700, color: WajbaColors.grey900)),
                ],
              ),
            ),
            const SizedBox(height: 48),

            Center(
              child: Pinput(
                controller: _otpCtrl,
                length: AppConstants.otpLength,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: WajbaColors.primary, width: 2),
                    color: WajbaColors.primaryBg,
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: WajbaColors.error, width: 2),
                  ),
                ),
                onCompleted: _verify,
                autofocus: true,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Center(child: Text(_error!, style: const TextStyle(color: WajbaColors.error, fontSize: 13, fontFamily: 'Cairo'))),
            ],

            const SizedBox(height: 32),

            // Countdown / Resend
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: _resend,
                      child: const Text('Renvoyer le code', style: TextStyle(color: WajbaColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                    )
                  : RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: WajbaColors.grey500, fontFamily: 'Cairo'),
                        children: [
                          const TextSpan(text: 'Renvoyer dans '),
                          TextSpan(text: _countdownLabel, style: const TextStyle(fontWeight: FontWeight.w700, color: WajbaColors.primary)),
                        ],
                      ),
                    ),
            ),

            const Spacer(),

            if (_loading) const Center(child: CircularProgressIndicator(color: WajbaColors.primary)),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _otpCtrl.text.length == AppConstants.otpLength && !_loading
                    ? () => _verify(_otpCtrl.text) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WajbaColors.primary,
                  disabledBackgroundColor: WajbaColors.grey200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Vérifier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
