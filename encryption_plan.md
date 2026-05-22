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
- [ ] Add storage repository support for `data.bin`.
- [ ] Add startup unlock and plaintext fallback behavior.
- [ ] Add plaintext-to-encrypted migration prompt.
- [ ] Add import-save behavior for encrypted local storage.
- [x] Add focused tests.
- [ ] Run targeted checks.

## Step 1 - Storage Format Contract

- [ ] Define `data.bin` as LibreOTP local vault storage, separate from the 2FAS
  encrypted backup format.
- [ ] Keep the decrypted `data.bin` plaintext exactly equivalent to the current
  `data.json` contents.
- [ ] Reuse the same app data serializer for plaintext `data.json` writes and
  encrypted `data.bin` plaintext generation.
- [ ] Ensure the plaintext JSON object contains `services` and `groups` at the
  top level, with the same model `toJson()` output used today.
- [ ] Do not add wrapper metadata inside the decrypted app data payload.
- [ ] Store encryption metadata outside the decrypted app data payload in the
  `data.bin` envelope.
- [ ] Version the `data.bin` envelope so future KDF or cipher changes can be
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

- [ ] Add `_encryptedDataFileName = 'data.bin'` in
  `lib/data/repositories/storage_repository.dart`.
- [ ] Add `getEncryptedLocalFile()` beside `getLocalFile()`.
- [ ] Keep `getLocalFile()` returning the plaintext `data.json` path for
  compatibility and diagnostics.
- [ ] Add helper methods for reading and writing the shared app data JSON
  payload.
- [ ] Add helper methods for checking whether `data.bin` and `data.json` exist.
- [ ] Ensure app support directory creation remains centralized.

## Step 5 - Startup Load Order

- [ ] On startup, check for `data.bin` first.
- [ ] If `data.bin` exists, attempt to load only `data.bin`.
- [ ] If `data.bin` requires a password, show the local vault password prompt.
- [ ] If `data.bin` fails because the password is wrong or the vault is
  corrupted, do not silently fall back to `data.json`.
- [ ] After successful `data.bin` decrypt, parse the decrypted JSON exactly as
  `data.json` is parsed today.
- [ ] If no `data.bin` exists, check for `data.json`.
- [ ] If `data.json` exists, load it using the existing plaintext path.
- [ ] If neither file exists, return empty services and groups.
- [ ] Update state flags so the UI can distinguish encrypted vault unlock from
  encrypted 2FAS import unlock.

## Step 6 - Password Dialog Updates

- [ ] Make `PasswordDialog` configurable for local vault unlock, 2FAS import
  decrypt, and new vault password creation.
- [ ] For local vault unlock, use vault-specific text instead of encrypted
  backup wording.
- [ ] For new vault creation, prompt for password and confirmation.
- [ ] Reject empty passwords.
- [ ] Show a mismatch error when confirmation does not match.
- [ ] Consider adding minimum password guidance without enforcing a surprising
  rule.
- [ ] Keep password values out of logs and debug output.

## Step 7 - Plaintext Migration Prompt

- [ ] When startup successfully loads plaintext `data.json`, set a state flag
  indicating plaintext local data is available for encryption.
- [ ] Prompt the user with an option to encrypt local data.
- [ ] If accepted, ask for a new local vault password.
- [ ] Serialize current app data using the same serializer used for
  `data.json`.
- [ ] Encrypt that exact JSON string into `data.bin`.
- [ ] Verify the newly written vault by decrypting it and parsing the app data.
- [ ] After verification, remove plaintext secrets from `data.json`.
- [ ] Prefer deleting `data.json`; if a marker is kept, it must not include
  service names, accounts, secrets, groups, or other sensitive app data.
- [ ] If encryption or verification fails, leave the original `data.json`
  untouched and report the error.

## Step 8 - Save Behavior After Encryption

- [ ] Track current local storage mode as plaintext JSON or encrypted vault.
- [ ] When mode is plaintext JSON, `saveData()` writes `data.json` as it does
  today.
- [ ] When mode is encrypted vault, `saveData()` writes only `data.bin`.
- [ ] Ensure debounced usage-count saves do not recreate plaintext `data.json`
  after migration.
- [ ] Keep the local vault password in memory only for the current app session
  unless an explicit remember-password option is added later.
- [ ] Write encrypted saves to a temporary file first.
- [ ] Verify or atomically replace the final `data.bin` where practical.
- [ ] Avoid logging serialized app data, passwords, derived keys, nonces, or
  ciphertext.

## Step 9 - 2FAS Import Integration

- [ ] Keep 2FAS import parsing and decryption behavior separate from local
  vault encryption.
- [ ] Continue accepting unencrypted 2FAS JSON exports.
- [ ] Continue accepting encrypted 2FAS exports through
  `TwoFasDecryptionService`.
- [ ] After a successful import, merge data using the existing merge behavior.
- [ ] If current storage mode is encrypted vault, save the merged app data only
  to `data.bin`.
- [ ] If current storage mode is plaintext JSON, offer the same encrypt local
  data prompt after importing.
- [ ] Do not store imported plaintext secrets in `data.json` when the local
  storage mode is encrypted vault.

## Step 10 - User Actions and Settings

- [ ] Add a dashboard menu or settings action for `Encrypt Local Data` when
  plaintext storage is active.
- [ ] Add `Change Vault Password` when encrypted storage is active.
- [ ] For password changes, decrypt with the old password and re-encrypt the
  exact same app data JSON payload with the new password.
- [ ] Consider `Disable Encryption` only with clear confirmation that plaintext
  `data.json` will be written.
- [ ] Update the data directory dialog or related help text to mention both
  `data.bin` and `data.json`.

## Step 11 - Repository and State Tests

- [ ] Add tests proving `data.bin` is preferred over `data.json` when both
  exist.
- [ ] Add tests proving no fallback to `data.json` occurs after a failed
  `data.bin` decrypt.
- [ ] Add tests proving decrypted `data.bin` app data parses identically to
  `data.json`.
- [ ] Add tests proving plaintext migration creates `data.bin`.
- [ ] Add tests proving plaintext migration deletes or sanitizes `data.json`.
- [ ] Add tests proving encrypted-mode saves do not recreate `data.json`.
- [ ] Add tests proving imports save to the active storage mode.
- [ ] Update existing `OtpState` test fakes for the new storage-mode behavior.

## Step 12 - Documentation Updates

- [ ] Update `README.md` storage-path documentation to describe `data.bin`.
- [ ] Document that `data.bin` decrypts to the same app data JSON schema as
  `data.json`.
- [ ] Document that `data.bin` is loaded before `data.json`.
- [ ] Document that losing the local vault password makes encrypted local data
  unrecoverable unless the user has another backup.
- [ ] Update troubleshooting text for wrong password, corrupted vault, and
  plaintext migration failures.

## Step 13 - Test Pass

- [ ] Run local vault encryption service tests:
  `F:\tools\flutter\bin\flutter.bat test test/services`
- [ ] Run repository tests:
  `F:\tools\flutter\bin\flutter.bat test test/data/repositories`
- [ ] Run state tests:
  `F:\tools\flutter\bin\flutter.bat test test/presentation/state`
- [ ] Run the full Flutter test suite:
  `F:\tools\flutter\bin\flutter.bat test`
- [ ] Run static analysis:
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

- [ ] Should the app offer a remember-password option for the local vault, or
  keep vault passwords memory-only for a stricter at-rest threat model?
- [ ] Should password-strength guidance be advisory only, or should the app
  enforce a minimum length?
- [ ] Should `Disable Encryption` be included in the first release of this
  feature, or deferred until encrypted storage is stable?
