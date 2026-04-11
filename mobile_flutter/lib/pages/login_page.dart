import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_sizes.dart';
import '../services/auth_service.dart';
import '../utils/responsive_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool    _loading = false;
  bool    _hidePwd = true;
  String? _errorMsg;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await AuthService.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(phone: _buildPhone, web: _buildWeb);
  }

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppSizes.xxl),
            _buildLogo(),
            const SizedBox(height: AppSizes.xxl),
            _buildTitle(context),
            const SizedBox(height: AppSizes.xl),
            _buildForm(),
            const SizedBox(height: AppSizes.md),
            if (_errorMsg != null) _buildError(),
            const SizedBox(height: AppSizes.sm),
            _buildButton(),
          ]),
        ),
      ),
    );
  }

  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(AppSizes.xxl),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 56),
                SizedBox(height: AppSizes.lg),
                Text('ChatWave', style: TextStyle(color: Colors.white,
                    fontSize: 48, fontWeight: FontWeight.w800)),
                SizedBox(height: AppSizes.md),
                Text('Chat real-time dengan WebSocket',
                    style: TextStyle(color: Colors.white70,
                        fontSize: AppSizes.fontLg, height: 1.5)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(AppSizes.xxl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildTitle(context),
                  const SizedBox(height: AppSizes.xl),
                  _buildForm(),
                  const SizedBox(height: AppSizes.md),
                  if (_errorMsg != null) _buildError(),
                  const SizedBox(height: AppSizes.sm),
                  _buildButton(),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLogo() {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
      ),
      const SizedBox(width: AppSizes.md),
      const Text('ChatWave', style: TextStyle(fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildTitle(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Selamat Datang 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      const SizedBox(height: AppSizes.xs),
      const Text('Masuk untuk mulai mengobrol',
          style: TextStyle(color: AppColors.textSecondary, fontSize: AppSizes.fontMd)),
    ]);
  }

  Widget _buildForm() {
    return Form(key: _formKey, child: Column(children: [
      TextFormField(
        controller: _usernameCtrl,
        decoration: const InputDecoration(labelText: 'Username',
            prefixIcon: Icon(Icons.person_outline)),
        textInputAction: TextInputAction.next,
        validator: (v) => (v == null || v.trim().isEmpty)
            ? 'Username tidak boleh kosong' : null,
      ),
      const SizedBox(height: AppSizes.md),
      TextFormField(
        controller: _passwordCtrl,
        obscureText: _hidePwd,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_hidePwd ? Icons.visibility_off : Icons.visibility),
            color: AppColors.textSecondary,
            onPressed: () => setState(() => _hidePwd = !_hidePwd),
          ),
        ),
        onFieldSubmitted: (_) => _login(),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
          if (v.length < 6) return 'Password minimal 6 karakter';
          return null;
        },
      ),
    ]));
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
        const SizedBox(width: AppSizes.sm),
        Expanded(child: Text(_errorMsg!,
            style: const TextStyle(color: AppColors.error))),
      ]),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: _loading ? null : _login,
      child: _loading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Masuk'),
    );
  }
}
