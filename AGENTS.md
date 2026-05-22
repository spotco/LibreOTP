## Windows Flutter setup

- Flutter must be installed on an **NTFS** drive for Windows desktop builds. exFAT does not support the symlink behavior Flutter uses for plugin builds.
- The local Flutter SDK for this machine is installed at `F:\tools\flutter`.
- Run Dart through the Flutter SDK on the F: drive:
  `F:\tools\flutter\bin\dart.bat <args>`.
- Run Flutter through the Flutter SDK on the F: drive:
  `F:\tools\flutter\bin\flutter.bat <args>`.
- Format Dart files with:
  `F:\tools\flutter\bin\dart.bat format <paths>`.
- Run targeted tests with:
  `F:\tools\flutter\bin\flutter.bat test <test-path>`.
- In Codex sandboxed runs, Flutter commands may hang or time out before any
  reporter output because the SDK needs access to its cache outside the
  workspace. If `flutter.bat --version` or `flutter.bat test ...` times out in
  the sandbox, rerun the same command with escalated permissions.
- The local vault service test was verified with:
  `F:\tools\flutter\bin\flutter.bat test test\services\local_vault_encryption_service_test.dart`.

## Plans

- Local vault encryption implementation plan: `encryption_plan.md`
