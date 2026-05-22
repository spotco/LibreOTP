# Local Vault Encryption Implementation Plan

This plan tracks sequential implementation tasks for adding an encrypted
`data.bin` local vault while preserving the existing `data.json` app data
schema. The unencrypted payload inside `data.bin` must be exactly the same JSON
object currently stored in `data.json`:

```json
{
  "services": [],
  "groups": []
}
```

The app must load `data.bin` first when present, then fall back to `data.json`
when present. If neither file exists, startup continues with empty app data.

## Progress

- [x] Inspect current storage, import, password dialog, and 2FAS decryption
  paths.
- [x] Evaluate the encrypted local vault design.
- [x] Write this implementation plan.
- [x] Implement local vault encryption service.
- [x] Add storage repository support for `data.bin`.
- [x] Add startup unlock and plaintext fallback behavior.
- [x] Add plaintext-to-encrypted migration prompt.
- [x] Add import-save behavior for encrypted local storage.
- [x] Add focused tests.
- [x] Run targeted checks.

## Step 1 - Storage Format Contract

- [x] Define `data.bin` as LibreOTP local vault storage, separate from the 2FAS
  encrypted backup format.
- [x] Keep the decrypted `data.bin` plaintext exactly equivalent to the current
  `data.json` contents.
- [x] Reuse the same app data serializer for plaintext `data.json` writes and
  encrypted `data.bin` plaintext generation.
- [x] Ensure the plaintext JSON object contains `services` and `groups` at the
  top level, with the same model `toJson()` output used today.
- [x] Do not add wrapper metadata inside the decrypted app data payload.
- [x] Store encryption metadata outside the decrypted app data payload in the
  `data.bin` envelope.
- [x] Version the `data.bin` envelope so future KDF or cipher changes can be
  migrated.

## Step 2 - Encryption Algorithm and KDF

- [x] Use authenticated encryption so corrupted or tampered vault files fail
  before app data is accepted.
- [x] Prefer `AES-256-GCM` for the content cipher.
- [ ] Prefer `Argon2id` for password-based key derivation if a suitable Flutter
  desktop dependency is available and maintainable.
- [x] If Argon2id is not practical, use `PBKDF2-HMAC-SHA256` with a high
  iteration count and document the tradeoff in code comments and release notes.
- [x] Generate a fresh random salt for each new vault password.
- [x] Generate a fresh random 12-byte nonce for each encryption operation.
- [x] Use a 256-bit derived key.
- [x] Include KDF parameters, cipher name, salt, nonce, and envelope version in
  authenticated data or otherwise covered by authentication.

## Step 3 - Local Vault Encryption Service

- [x] Add `lib/services/local_vault_encryption_service.dart`.
- [x] Add an `encrypt(String plaintextJson, String password)` API.
- [x] Add a `decrypt(Uint8List vaultBytes, String password)` API.
- [x] Return the decrypted plaintext JSON string without parsing it in the
  encryption service.
- [x] Throw clear errors for missing password, invalid vault format, invalid
  password, authentication failure, and unsupported vault version.
- [x] Keep this service independent from `TwoFasDecryptionService`.
- [x] Add unit tests for round trip, wrong password, corrupted ciphertext,
  unsupported version, and malformed envelope.

## Step 4 - Storage Repository File Paths

- [x] Add `_encryptedDataFileName = 'data.bin'` in
  `lib/data/repositories/storage_repository.dart`.
- [x] Add `getEncryptedLocalFile()` beside `getLocalFile()`.
- [x] Keep `getLocalFile()` returning the plaintext `data.json` path for
  compatibility and diagnostics.
- [x] Add helper methods for reading and writing the shared app data JSON
  payload.
- [x] Add helper methods for checking whether `data.bin` and `data.json` exist.
- [x] Ensure app support directory creation remains centralized.

## Step 5 - Startup Load Order

- [x] On startup, check for `data.bin` first.
- [x] If `data.bin` exists, attempt to load only `data.bin`.
- [x] If `data.bin` requires a password, show the local vault password prompt.
- [x] If `data.bin` fails because the password is wrong or the vault is
  corrupted, do not silently fall back to `data.json`.
- [x] After successful `data.bin` decrypt, parse the decrypted JSON exactly as
  `data.json` is parsed today.
- [x] If no `data.bin` exists, check for `data.json`.
- [x] If `data.json` exists, load it using the existing plaintext path.
- [x] If neither file exists, return empty services and groups.
- [x] Update state flags so the UI can distinguish encrypted vault unlock from
  encrypted 2FAS import unlock.

## Step 6 - Password Dialog Updates

- [x] Make `PasswordDialog` configurable for local vault unlock, 2FAS import
  decrypt, and new vault password creation.
- [x] For local vault unlock, use vault-specific text instead of encrypted
  backup wording.
- [x] For new vault creation, prompt for password and confirmation.
- [x] Reject empty passwords.
- [x] Show a mismatch error when confirmation does not match.
- [x] Consider adding minimum password guidance without enforcing a surprising
  rule.
- [x] Keep password values out of logs and debug output.

## Step 7 - Plaintext Migration Prompt

- [x] When startup successfully loads plaintext `data.json`, set a state flag
  indicating plaintext local data is available for encryption.
- [x] Prompt the user with an option to encrypt local data.
- [x] If accepted, ask for a new local vault password.
- [x] Serialize current app data using the same serializer used for
  `data.json`.
- [x] Encrypt that exact JSON string into `data.bin`.
- [x] Verify the newly written vault by decrypting it and parsing the app data.
- [x] After verification, remove plaintext secrets from `data.json`.
- [x] Prefer deleting `data.json`; if a marker is kept, it must not include
  service names, accounts, secrets, groups, or other sensitive app data.
- [x] If encryption or verification fails, leave the original `data.json`
  untouched and report the error.

## Step 8 - Save Behavior After Encryption

- [x] Track current local storage mode as plaintext JSON or encrypted vault.
- [x] When mode is plaintext JSON, `saveData()` writes `data.json` as it does
  today.
- [x] When mode is encrypted vault, `saveData()` writes only `data.bin`.
- [x] Ensure debounced usage-count saves do not recreate plaintext `data.json`
  after migration.
- [x] Keep the local vault password in memory only for the current app session
  unless an explicit remember-password option is added later.
- [x] Write encrypted saves to a temporary file first.
- [x] Verify or atomically replace the final `data.bin` where practical.
- [x] Avoid logging serialized app data, passwords, derived keys, nonces, or
  ciphertext.

## Step 9 - 2FAS Import Integration

- [x] Keep 2FAS import parsing and decryption behavior separate from local
  vault encryption.
- [x] Continue accepting unencrypted 2FAS JSON exports.
- [x] Continue accepting encrypted 2FAS exports through
  `TwoFasDecryptionService`.
- [x] After a successful import, merge data using the existing merge behavior.
- [x] If current storage mode is encrypted vault, save the merged app data only
  to `data.bin`.
- [x] If current storage mode is plaintext JSON, offer the same encrypt local
  data prompt after importing.
- [x] Do not store imported plaintext secrets in `data.json` when the local
  storage mode is encrypted vault.

## Step 10 - User Actions and Settings

- [x] Add a dashboard menu or settings action for `Encrypt Local Data` when
  plaintext storage is active.
- [x] Add `Change Vault Password` when encrypted storage is active.
- [x] For password changes, decrypt with the old password and re-encrypt the
  exact same app data JSON payload with the new password.
- [x] Do not include `Disable Encryption` in the first release of this
  feature.
- [x] Update the data directory dialog or related help text to mention both
  `data.bin` and `data.json`.

## Step 11 - Repository and State Tests

- [x] Add tests proving `data.bin` is preferred over `data.json` when both
  exist.
- [x] Add tests proving no fallback to `data.json` occurs after a failed
  `data.bin` decrypt.
- [x] Add tests proving decrypted `data.bin` app data parses identically to
  `data.json`.
- [x] Add tests proving plaintext migration creates `data.bin`.
- [x] Add tests proving plaintext migration deletes or sanitizes `data.json`.
- [x] Add tests proving encrypted-mode saves do not recreate `data.json`.
- [x] Add tests proving imports save to the active storage mode.
- [x] Update existing `OtpState` test fakes for the new storage-mode behavior.

## Step 12 - Documentation Updates

- [x] Update `README.md` storage-path documentation to describe `data.bin`.
- [x] Document that `data.bin` decrypts to the same app data JSON schema as
  `data.json`.
- [x] Document that `data.bin` is loaded before `data.json`.
- [x] Document that losing the local vault password makes encrypted local data
  unrecoverable unless the user has another backup.
- [x] Update troubleshooting text for wrong password, corrupted vault, and
  plaintext migration failures.

## Step 13 - Test Pass

- [x] Run local vault encryption service tests:
  `F:\tools\flutter\bin\flutter.bat test test/services`
- [x] Run repository tests:
  `F:\tools\flutter\bin\flutter.bat test test/data/repositories`
- [x] Run state tests:
  `F:\tools\flutter\bin\flutter.bat test test/presentation/state`
- [x] Run the full Flutter test suite:
  `F:\tools\flutter\bin\flutter.bat test`
- [x] Run static analysis:
  `F:\tools\flutter\bin\flutter.bat analyze`

## Step 14 - Manual Verification

- [ ] Start with no `data.bin` and no `data.json`; confirm the app opens empty.
- [ ] Start with only plaintext `data.json`; confirm the app loads it.
- [ ] Accept the encrypt local data prompt.
- [ ] Enter and confirm a vault password.
- [ ] Confirm `data.bin` is created.
- [ ] Confirm plaintext `data.json` is deleted or sanitized.
- [ ] Restart the app and confirm it prompts for the vault password.
- [ ] Enter the correct password and confirm all services and groups load.
- [ ] Enter an incorrect password and confirm the app does not fall back to
  plaintext data.
- [ ] Put both `data.bin` and `data.json` in the data directory and confirm
  `data.bin` wins.
- [ ] Import an unencrypted 2FAS file while encrypted mode is active and confirm
  the merged result is saved only in `data.bin`.
- [ ] Import an encrypted 2FAS file while encrypted mode is active and confirm
  2FAS decrypt and local vault save remain separate flows.
- [ ] Generate OTPs and confirm usage updates persist after restart in encrypted
  mode.

## Open Questions

- [x] Keep local vault passwords memory-only for the current app session. Do
  not offer a remember-password option.
- [x] Keep password-strength guidance advisory only. Do not enforce a minimum
  length in the first release.
- [x] Do not include `Disable Encryption` in the first release of this
  feature.
