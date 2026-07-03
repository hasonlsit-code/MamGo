import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/presentation/viewmodels/auth_provider.dart';
import 'package:mamgo/presentation/viewmodels/user_preference_provider.dart';
import 'package:mamgo/presentation/pages/home_screen.dart';
import 'package:mamgo/presentation/pages/onboarding_screen.dart';
import 'package:mamgo/presentation/pages/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;

  // Ảnh món ăn thật trang trí hai bên logo
  static const _leftDishUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop&q=80';
  static const _rightDishUrl =
      'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=400&fit=crop&q=80';

  @override
  void initState() {
    super.initState();
    _prefillEmail();
  }

  Future<void> _prefillEmail() async {
    final email = await context.read<AuthProvider>().rememberedEmail();
    if (email != null && mounted) {
      _emailCtrl.text = email;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập email và mật khẩu!');
      return;
    }
    setState(() => _loading = true);
    final error = await context
        .read<AuthProvider>()
        .login(email, password, remember: _remember);
    if (!mounted) return;
    if (error != null) {
      setState(() => _loading = false);
      _showMessage(error);
      return;
    }
    final prefProv = context.read<UserPreferenceProvider>();
    await prefProv.load();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => prefProv.hasPreference
          ? const HomeScreen()
          : const OnboardingScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHero(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLoginCard(),
              ),
              const SizedBox(height: 20),
              _buildTermsFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Khu vực logo + tagline + ảnh món ăn thật ──────────────────────────────
  Widget _buildHero() {
    return SizedBox(
      height: 270,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -55,
            top: 110,
            child: _dishPhoto(_leftDishUrl, 130),
          ),
          Positioned(
            right: -55,
            top: 130,
            child: _dishPhoto(_rightDishUrl, 120),
          ),
          Column(
            children: [
              const SizedBox(height: 30),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                        child: Text('🍽️', style: TextStyle(fontSize: 52))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                  children: [
                    TextSpan(
                        text: 'Mam',
                        style: TextStyle(color: AppTheme.primary)),
                    TextSpan(
                        text: 'Go',
                        style: TextStyle(color: AppTheme.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ăn đúng giờ. Chọn món đúng tâm trạng.',
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dishPhoto(String url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: const Color(0xFFEFF5FD)),
          errorWidget: (_, _, _) =>
              Container(color: const Color(0xFFEFF5FD)),
        ),
      ),
    );
  }

  // ── Card đăng nhập ─────────────────────────────────────────────────────────
  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email',
              prefixIcon:
                  Icon(Icons.mail_outline_rounded, color: AppTheme.textMedium),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              hintText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppTheme.textMedium),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textMedium,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showMessage(
                  'Tính năng khôi phục mật khẩu đang được phát triển!'),
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: Checkbox(
                  value: _remember,
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  onChanged: (v) => setState(() => _remember = v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ghi nhớ đăng nhập',
                style: TextStyle(color: AppTheme.textDark, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _gradientButton(
            label: 'Đăng nhập',
            loading: _loading,
            onTap: _login,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Tạo tài khoản',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2EAF4))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Hoặc đăng nhập với',
                  style: TextStyle(
                      color: AppTheme.textMedium.withValues(alpha: 0.9),
                      fontSize: 13),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2EAF4))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _socialButton('G', 'Google', Colors.red)),
              const SizedBox(width: 12),
              Expanded(child: _socialButton('', 'Apple', Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required VoidCallback onTap,
    bool loading = false,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.brandGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.orange.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _socialButton(String iconText, String label, Color iconColor) {
    return OutlinedButton(
      onPressed: () =>
          _showMessage('Đăng nhập với $label đang được phát triển!'),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE2EAF4)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconText.isEmpty
              ? Icon(Icons.apple, color: iconColor, size: 22)
              : Text(
                  iconText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.verified_user_outlined,
                color: AppTheme.success, size: 18),
            SizedBox(width: 6),
            Text(
              'Bằng việc đăng nhập, bạn đồng ý với',
              style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Điều khoản sử dụng và Chính sách bảo mật',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
