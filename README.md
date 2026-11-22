# Sklauncher-Offline-Account-Creator

After Sklauncher v4.0.58 and v3.2.18 the option to create an offline mode account is gone.
This allows you to make an offline mode account by editing the accounts.json file that sklauncher uses.

This tool asks you a few questions and builds the `accounts.json` file for you, so you don't have to edit it by hand. You can make one account or several. The UUID is worked out from your username automatically.

**Requires:** Windows 10 or 11. Nothing to install. This makes the `accounts.json` file used by Sklauncher 4.0.

## How to use it

1. Download `make_accounts.bat` and `make_accounts.ps1` and put them in the same folder.
2. Close Sklauncher.
3. Double-click `make_accounts.bat`.
4. Answer the questions:
   - **Sklauncher Folder**: the folder where Sklauncher keeps its `accounts.json`. On Windows this is usually `%APPDATA%\.sklauncher`. If an `accounts.json` is already there, the tool asks if you want to replace it, so make a backup first if you need one.
   - **How many accounts**: type a number, or press Enter for 1.
   - **Username**: make sure to type your actual username.
5. Open Sklauncher. Your accounts are there.

If you made more than one account, the tool also asks which one should be selected when you open the launcher. You can switch accounts any time from inside Sklauncher, so this choice isn't permanent.

## Troubleshooting

- **"Windows protected your PC"**: click **More info**, then **Run anyway**.
- **"Running scripts is disabled"**: open PowerShell in the folder and run `powershell -ExecutionPolicy Bypass -File .\make_accounts.ps1`
- **Account doesn't show up**: make sure you picked the folder Sklauncher actually uses, then restart Sklauncher.
