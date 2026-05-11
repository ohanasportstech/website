import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Kai blue color - matching the app branding
const Color kaiBlue = Color.fromARGB(255, 0, 119, 200);

class LoginModal extends StatefulWidget {
  final VoidCallback? onSuccess;

  const LoginModal({super.key, this.onSuccess});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: kaiBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 375,
        height: isMobile ? double.infinity : 667,
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 667),
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _showEmailForm
                    ? _buildEmailForm()
                    : _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App icon placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/icons/AppIcon.png',
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: 24),
        // Headline
        const Text(
          'Welcome back!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Google Sign In button
        _buildAuthButton(
          label: 'Sign in with Google',
          icon: Image.asset('assets/images/google_logo.png', height: 26),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          onPressed: _signInWithGoogle,
        ),
        const SizedBox(height: 12),
        // Apple Sign In button
        _buildAuthButton(
          label: 'Sign in with Apple',
          icon: const Icon(Icons.apple, size: 26, color: Colors.white),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          onPressed: _signInWithApple,
        ),
        const SizedBox(height: 24),
        // Divider
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.white54)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            Expanded(child: Divider(color: Colors.white54)),
          ],
        ),
        const SizedBox(height: 24),
        // Email button
        _buildAuthButton(
          label: 'Sign in with email',
          backgroundColor: kaiBlue,
          foregroundColor: Colors.white,
          borderColor: Colors.white,
          onPressed: () => setState(() => _showEmailForm = true),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _showEmailForm = false),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text('Back', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 32),
        // Email input
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 16),
        // Password input
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          obscureText: true,
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 24),
        // Sign in button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _loading ? null : _signInWithEmail,
            style: FilledButton.styleFrom(
              backgroundColor: kaiBlue,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton({
    required String label,
    Widget? icon,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${Uri.base.origin}/auth/callback',
      );
    } catch (e) {
      _showError('Google sign in failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: '${Uri.base.origin}/auth/callback',
      );
    } catch (e) {
      _showError('Apple sign in failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        widget.onSuccess?.call();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Sign in failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

// Helper function to show the login modal
void showLoginModal(BuildContext context, {VoidCallback? onSuccess}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => LoginModal(onSuccess: onSuccess),
  );
}
