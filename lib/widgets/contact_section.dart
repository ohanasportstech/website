import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:website/strings.dart';
import 'package:website/utils/turnstile.dart';

/// A reusable contact form used by the home page and about page.
class ContactSection extends StatefulWidget {
  final bool isMobile;

  const ContactSection({super.key, required this.isMobile});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  static const String _turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');

  final _nameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipController = TextEditingController();
  final _messageController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _zipController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final name = _nameController.text.trim();
    final organization = _organizationController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final zip = _zipController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() => _error = Strings.contactValidationNameEmail);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = Strings.contactValidationEmail);
      return;
    }

    if (_turnstileSiteKey.isEmpty) {
      setState(() => _error = Strings.contactNotConfigured);
      return;
    }

    setState(() => _loading = true);

    try {
      final token = await requestContactTurnstileToken(_turnstileSiteKey);

      final response = await Supabase.instance.client.functions.invoke(
        'contact-submission',
        body: {
          'name': name,
          'organization_name': organization,
          'email': email,
          'phone': phone,
          'zip_code': zip,
          'message': message,
          'turnstile_token': token,
        },
      );

      if (response.status != 200) {
        final data = response.data;
        final msg = data is Map<String, dynamic>
            ? data['error'] ?? Strings.contactSubmitError
            : Strings.contactSubmitError;
        throw Exception(msg);
      }

      setState(() {
        _sent = true;
        _nameController.clear();
        _organizationController.clear();
        _emailController.clear();
        _phoneController.clear();
        _zipController.clear();
        _messageController.clear();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isMobile = widget.isMobile;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: isMobile ? 24 : 60),
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.contactHeader,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              Strings.contactLead,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_sent) ...[
              Text(
                Strings.contactSubmitSuccess,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.primary),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      _buildField(_nameController, Strings.contactName, TextInputType.name, isMobile),
                      _buildField(
                        _organizationController,
                        Strings.contactOrganizationName,
                        TextInputType.text,
                        isMobile,
                      ),
                    ],
                  ),
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        _buildField(_emailController, Strings.contactEmail, TextInputType.emailAddress, isMobile),
                        _buildField(_phoneController, Strings.contactPhone, TextInputType.phone, isMobile),
                        _buildField(_zipController, Strings.contactZip, TextInputType.text, isMobile),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _emailController,
                            Strings.contactEmail,
                            TextInputType.emailAddress,
                            isMobile,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(_phoneController, Strings.contactPhone, TextInputType.phone, isMobile),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField(_zipController, Strings.contactZip, TextInputType.text, isMobile)),
                      ],
                    ),
                  _buildField(
                    _messageController,
                    Strings.contactMessage,
                    TextInputType.multiline,
                    isMobile,
                    maxLines: 5,
                    minLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[Text(_error!, style: TextStyle(color: color.error)), const SizedBox(height: 12)],
              SizedBox(
                width: isMobile ? double.infinity : 180,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(Strings.contactSend),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              Strings.contactAlt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    TextInputType type,
    bool isMobile, {
    int? maxLines,
    int? minLines,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        minLines: minLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
