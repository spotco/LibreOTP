import 'package:flutter/material.dart';

class EditServiceDialog extends StatefulWidget {
  final String initialName;
  final String initialAccount;

  const EditServiceDialog({
    super.key,
    required this.initialName,
    required this.initialAccount,
  });

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _accountController = TextEditingController(text: widget.initialAccount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit entry'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Account',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(
      EditServiceResult(
        name: _nameController.text,
        account: _accountController.text,
      ),
    );
  }
}

class EditServiceResult {
  final String name;
  final String account;

  const EditServiceResult({
    required this.name,
    required this.account,
  });
}
