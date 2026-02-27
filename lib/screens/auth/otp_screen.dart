import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const OtpScreen({super.key, required this.phone, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp      = '';
  int    _countdown = 60;
  bool   _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
          _startCountdown();
        } else {
          _canResend = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kPaddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text('📱', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text('Code de vérification',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                                 color: WajbaColors.dark)),
              const SizedBox(height: 8),
              Text('Code envoyé au ${widget.phone}',
                style: const TextStyle(color: WajbaColors.grey600, fontSize: 14)),
              const SizedBox(height: 40),

              // ── PIN CODE ──────────────────────────────────────
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (v) => _otp = v,
                onCompleted: (_) => _verify(auth),
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 56,
                  fieldWidth: 46,
                  activeFillColor: WajbaColors.white,
                  inactiveFillColor: WajbaColors.grey100,
                  selectedFillColor: WajbaColors.white,
                  activeColor: WajbaColors.primary,
                  inactiveColor: WajbaColors.grey200,
                  selectedColor: WajbaColors.primary,
                ),
                enableActiveFill: true,
                animationType: AnimationType.fade,
                cursorColor: WajbaColors.primary,
              ),

              if (auth.error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WajbaColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(auth.error,
                    style: const TextStyle(color: WajbaColors.error, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 24),

              // ── Renvoyer ──────────────────────────────────────
              Center(
                child: _canResend
                  ? TextButton.icon(
                      onPressed: () async {
                        setState(() { _countdown = 60; _canResend = false; });
                        _startCountdown();
                        await auth.sendOtp(widget.phone);
                      },
                      icon: const Icon(Icons.refresh, color: WajbaColors.primary),
                      label: const Text('Renvoyer le code',
                        style: TextStyle(color: WajbaColors.primary,
                                         fontWeight: FontWeight.w600)),
                    )
                  : Text('Renvoyer dans $_countdown s',
                      style: const TextStyle(color: WajbaColors.grey600)),
              ),

              const Spacer(),
              WajbaButton(
                label: 'Vérifier',
                isLoading: auth.isLoading,
                onTap: () => _verify(auth),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify(AuthProvider auth) async {
    if (_otp.length < 6) return;
    auth.clearError();
    final ok = await auth.verifyOtp(_otp);
    if (!mounted) return;
    if (ok) {
      // Nouveau utilisateur → compléter profil
      if (auth.user == null) {
        context.go('/auth/profile');
      } else {
        context.go('/home');
      }
    }
  }
}
