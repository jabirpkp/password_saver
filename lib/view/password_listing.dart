import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_saver/model/password.dart';

import '../controller/controller.dart';
import '../controller/cryptoHelper.dart';

class BeautifulList extends StatelessWidget {
  BeautifulList({super.key});

  final PasswordController controller = Get.put(PasswordController());
  final TextEditingController searchController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<_PasswordEntry>(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
    if (result == null || !context.mounted) return;

    final saved = await controller.addPassword(result.password, result.title);
    if (!context.mounted) return;
    _showResult(context, saved, 'Password saved');
  }

  Future<void> _authenticateAndShowPassword(
    BuildContext context,
    PasswordModel model,
  ) async {
    if (!kDebugMode) {
      try {
        final canAuthenticate =
            await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
        if (!canAuthenticate) {
          if (context.mounted) {
            _showMessage(
              context,
              'Biometric authentication is not available on this device.',
            );
          }
          return;
        }

        final authenticated = await _auth.authenticate(
          localizedReason: 'Authenticate to reveal this password',
          biometricOnly: true,
        );
        if (!authenticated) return;
      } catch (_) {
        if (context.mounted) {
          _showMessage(
            context,
            'Authentication was not completed. Please try again.',
          );
        }
        return;
      }
    }

    if (!context.mounted) return;
    String password;
    try {
      password = CryptoHelper.decryptText(model.password);
    } catch (_) {
      _showResult(context, false, 'Unable to decrypt this password');
      return;
    }

    if (!context.mounted) return;
    final result = await showDialog<_PasswordEntry>(
      context: context,
      builder: (_) => _PasswordDialog(
        initialTitle: model.title,
        initialPassword: password,
        isEditing: true,
      ),
    );
    if (result == null) return;

    final updatedModel = PasswordModel(
      id: model.id,
      title: result.title,
      password: result.password,
      value2: model.value2,
      value3: model.value3,
      created: model.created,
    );
    final updated = await controller.updatePassword(updatedModel);
    if (!context.mounted) return;
    _showResult(context, updated, 'Password updated');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF5A2428),
          content: Row(
            children: [
              const Icon(Icons.fingerprint_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _showResult(BuildContext context, bool success, String successMessage) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? const Color(0xFF164B44)
              : const Color(0xFF5A2428),
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(success ? successMessage : 'Something went wrong'),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101313),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My vault',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your encrypted passwords',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2423),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        '${controller.data.length} items',
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: searchController,
                onChanged: controller.searchPassword,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search your vault',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      searchController.clear();
                      controller.searchPassword('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.tealAccent,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final items = controller.filteredList;
                if (items.isEmpty) {
                  return _EmptyVault(
                    hasSearch: searchController.text.isNotEmpty,
                  );
                }

                return RefreshIndicator(
                  color: Colors.tealAccent,
                  backgroundColor: const Color(0xFF1E2424),
                  onRefresh: controller.loadPasswords,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _VaultCard(
                        item: item,
                        onTap: () =>
                            _authenticateAndShowPassword(context, item),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.black,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add password',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({required this.item, required this.onTap});

  final PasswordModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = item.title.trim().isEmpty
        ? '?'
        : item.title.trim().characters.first.toUpperCase();
    return Material(
      color: const Color(0xFF1A1E1E),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      '••••••••••••',
                      style: TextStyle(
                        color: Colors.white38,
                        letterSpacing: 2,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(
                color: Color(0xFF1B2423),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.lock_outline_rounded,
                color: Colors.tealAccent,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No passwords found' : 'Your vault is empty',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try another search term.'
                  : 'Tap “Add password” to securely save your first account.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({
    this.initialTitle = '',
    this.initialPassword = '',
    this.isEditing = false,
  });

  final String initialTitle;
  final String initialPassword;
  final bool isEditing;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _passwordController;
  bool _hidePassword = true;
  bool _canEdit = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _canEdit = !widget.isEditing;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _PasswordEntry(
        title: _titleController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      backgroundColor: const Color(0xFF191D1D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            18 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.isEditing
                            ? Icons.visibility_outlined
                            : Icons.add_moderator_outlined,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing
                                ? 'Password details'
                                : 'New password',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.isEditing
                                ? 'View or update this account'
                                : 'Add an account to your vault',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _titleController,
                  readOnly: !_canEdit,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration(
                    label: 'Account title',
                    hint: 'e.g. Personal email',
                    icon: Icons.label_outline_rounded,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter an account title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  readOnly: !_canEdit,
                  obscureText: _hidePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  onFieldSubmitted: (_) => _canEdit ? _submit() : null,
                  decoration: _fieldDecoration(
                    label: 'Password',
                    hint: 'At least 5 characters',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      tooltip: _hidePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 5
                      ? 'Use at least 5 characters'
                      : null,
                ),
                if (widget.isEditing) ...[
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: const Color(0xFF00BFA5),
                    title: const Text('Enable editing'),
                    subtitle: const Text(
                      'Keep fields locked to prevent accidental changes',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    value: _canEdit,
                    onChanged: (value) => setState(() => _canEdit = value),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    if (_canEdit) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            widget.isEditing ? 'Update' : 'Save password',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF111515),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.tealAccent, width: 1.4),
      ),
    );
  }
}

class _PasswordEntry {
  const _PasswordEntry({required this.title, required this.password});

  final String title;
  final String password;
}
