# LibreOTP

LibreOTP is a cross-platform desktop OTP code generator that works with exported JSON files from [2FAS](https://2fas.com/). It supports Windows, Mac and Linux and 2FAS features like grouping. Both encrypted and unencrypted 2FAS exports are supported. Currently only TOTP keys are supported.

This project was borne from necessity. I needed a modern desktop application that would support 2FAS exports including grouping and search on Linux. It's rough, it's ready, but it does exactly what I needed it to do and might be what you need to!

Flutter means this app works on Windows, Mac and Linux.

Contributions and improvements are welcome, open an `RFC: ` issue if you'd like to discuss a plan before getting started.

## Preview
[Demo Video](https://github.com/user-attachments/assets/2e402b35-34ca-45a0-ab6f-e1dced7e2f6e)

## Installation

### Easy Installation (Recommended)

**📦 Debian/Ubuntu Linux**
```bash
# Download the .deb package from the latest release
wget https://github.com/henricook/LibreOTP/releases/latest/download/libreotp.deb
sudo dpkg -i libreotp.deb
```
The app will appear in your applications menu. Dependencies are automatically installed.

**🍎 macOS**
1. Download the `.dmg` file from the [latest release](https://github.com/henricook/LibreOTP/releases/latest)
2. Open the `.dmg` file and drag LibreOTP to your Applications folder
3. Launch from Applications or Spotlight

### Advanced Installation (Other Operating Systems)

**🐧 Other Linux Distributions**
1. Download `libreotp-linux.tar.gz` from the [releases page](https://github.com/henricook/LibreOTP/releases)
2. Extract: `tar -xzf libreotp-linux.tar.gz`
3. Install dependencies:
   ```bash
   # Ubuntu/Debian - try one of these libjsoncpp versions (varies by Ubuntu version):
   sudo apt install libsecret-1-0 libjsoncpp26  # Ubuntu 24.04+
   # OR
   sudo apt install libsecret-1-0 libjsoncpp25  # Ubuntu 22.04, 23.04
   # OR  
   sudo apt install libsecret-1-0 libjsoncpp1   # Older Ubuntu versions
   ```
4. Run: `chmod +x libreotp && ./libreotp`

**🪟 Windows**
1. Download `libreotp-windows.zip` from the [releases page](https://github.com/henricook/LibreOTP/releases)
2. Extract the zip file to a folder
3. Run `LibreOTP.exe`

## Getting Started

1. **Export your 2FAS data**: Generate an export from your 2FAS app and save it as `data.json`
   - Both encrypted and unencrypted exports are supported
   - For encrypted exports, you'll be prompted to enter your password when the app starts

2. **Import into LibreOTP**: Launch the app and use the import button to select your `data.json` file
   - The app will automatically detect if your export is encrypted
   - Imported data is stored locally on your device

3. **Start generating codes**: Click any service to copy its OTP code to your clipboard

4. **Enjoy!** And don't forget to :star: Star the repository to encourage further updates. 

## Local Storage

LibreOTP stores its local app data in the platform application support directory.
That directory can contain two local storage files:

- `data.json`: plaintext local app data
- `data.bin`: encrypted local vault

When `data.bin` exists, LibreOTP loads it first and does not fall back to
`data.json` if vault unlock fails. When `data.bin` is absent, LibreOTP falls
back to `data.json`.

The decrypted payload inside `data.bin` is the same JSON schema as `data.json`:

```json
{
  "services": [],
  "groups": []
}
```

LibreOTP can migrate plaintext local data from `data.json` into an encrypted
local vault in `data.bin`. The local vault password is requested when creating
the vault and each time the vault is unlocked after restart. LibreOTP does not
offer a remember-password option for the local vault.

## Troubleshooting

### Linux: "Unable to generate build files" or secure storage not working
- If using the deb package: Dependencies should be automatically installed
- If using source/binary releases: Try installing the libjsoncpp version for your Ubuntu:
  - `sudo apt install libsecret-1-0 libjsoncpp26` (Ubuntu 24.04+)
  - `sudo apt install libsecret-1-0 libjsoncpp25` (Ubuntu 22.04/23.04)  
  - `sudo apt install libsecret-1-0 libjsoncpp1` (older versions)
- For development/building: `sudo apt install libsecret-1-dev libjsoncpp-dev`
- **If secure storage compilation fails**: The app will automatically fall back to less secure storage and show a warning message

### "Password required for encrypted backup" error
- Your 2FAS export file is encrypted - this is normal and more secure
- Click "Enter Password" and provide the password you set when creating the export
- The password will be securely stored for future app launches

### "Password required for encrypted vault" error
- LibreOTP found a local `data.bin` vault and needs its password before it can load services
- The local vault password is not remembered between app launches
- If you enter the wrong password, LibreOTP will not fall back to plaintext `data.json`

### Wrong password or decryption errors
- Verify whether you are unlocking a 2FAS export or a local LibreOTP vault
- For 2FAS exports, verify you're using the correct export password
- For local `data.bin` vaults, verify you're using the password chosen when encryption was enabled
- If you've forgotten the local vault password, LibreOTP cannot recover the encrypted local data
- If the error mentions an invalid or corrupted encrypted vault, restore from another backup or migrate again from plaintext data if it still exists
- Click "Use Different Password" to clear any stored 2FAS backup password and try again

### Empty app or no services showing
- Check that the app support directory contains the expected local files
- If both `data.bin` and `data.json` exist, LibreOTP will use `data.bin`
- Verify `data.json` contains valid local app data or a valid 2FAS export
- For encrypted files, ensure you've entered the correct password

## Limitations
- Only supports 2FAS export format (not Google Authenticator, Authy, etc.)
- HOTP (counter-based) codes are not yet supported
- File location is hardcoded - no file picker UI
- Linux: secure password storage requires additional system packages (falls back to less secure storage if unavailable)

## Building Deb Packages
1. Run `flutter build linux`
2. Create the deb directory structure:
   - Copy `build/linux/x64/release/bundle` to `deb/libreotp_VERSION/opt/libreotp/bundle`
   - Copy `linux/deb-template/usr` to `deb/libreotp_VERSION/usr` (includes desktop file and icons)
3. Update the version in `deb/libreotp_VERSION/DEBIAN/control` if needed
4. cd to deb/
5. Run `dpkg-deb --build libreotp_VERSION`, the deb appears in the same directory
6. Install with `sudo dpkg -i libreotp_VERSION.deb`
   - Dependencies (libsecret-1-0, libjsoncpp1) will be automatically installed
   - The app will appear in your GNOME applications menu with an icon

## Credit

### [OTPClient](https://github.com/paolostivanin/OTPClient)

Core layout of the app is heavily inspired by `otpclient` which I liked but I found lacked grouping. Being written in C, I didn't find it particularly easy to contribute to either. 

### [Flutter](https://github.com/flutter/flutter) 

The Flutter docs are great and along with IntelliJ's starter project meant I got up and running really fast.

## Features

- ✅ Support for both encrypted and unencrypted 2FAS exports
- ✅ Encrypted local vault storage in `data.bin`
- ✅ Shared local app-data schema across plaintext `data.json` and encrypted `data.bin`
- ✅ Secure password storage for encrypted 2FAS exports
- ✅ Cross-platform support (Windows, macOS, Linux)
- ✅ 2FAS group support and search functionality
- ✅ TOTP code generation with copy-to-clipboard

## Roadmap / ideas

1. Support for HOTP (counter-based) codes
