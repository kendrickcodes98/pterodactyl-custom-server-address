# Pterodactyl Custom Server Address

A simple installer that adds custom public server addresses to your Pterodactyl Panel.

Set a custom address for each server and display it directly in the server console without changing its actual allocation.

## Features

- 🎨 Interactive and colorful CLI installer
- ⚡ Animated installation interface
- 🔐 Automatic root permission detection
- 💾 Automatic backup of modified files
- 🗄️ Automatic database modification
- 🛠️ Backend and frontend integration
- 🔄 Automatic frontend production build
- 🧹 Laravel cache cleanup
- ✅ Installation verification
- 🖥️ Custom address displayed in the server console
- 🔙 Falls back to the default allocation when no custom address is set

## Requirements

Before installing, make sure you have:

- A working Pterodactyl Panel installation
- Root or sudo access
- PHP and Composer dependencies installed
- Node.js and Yarn
- Python 3
- A supported Pterodactyl codebase matching the installer's expected structure

**Default panel directory:** `/var/www/pterodactyl`

## Installation

### Quick Installation

Run the following command:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/kendrickcodes98/pterodactyl-custom-server-address/refs/heads/main/install.sh)
```



### Manual Installation

Clone the repository:

```bash
git clone https://github.com/kendrickcodes98/pterodactyl-custom-server-address.git
```

Enter the directory:

```bash
cd pterodactyl-custom-server-address
```

Give the installer execution permission:

```bash
chmod +x install.sh
```

Run it:

```bash
sudo ./install.sh
```

The installer will automatically request root permissions if needed.

## How to Use

Once the installation finishes:

1. Open your Pterodactyl Admin Panel.
2. Navigate to **Servers**.
3. Select the server you want to configure.
4. Open the **Details** section.
5. Find the **Public Address** field.
6. Enter your custom address.

Example:

```text
play.example.com:25565
```

7. Save your changes.

Your custom address will now appear in the server console.

## How It Works

The installer modifies the Pterodactyl Panel to support a new `public_address` field.

It integrates this field into:

- Database (`servers` table)
- Server model
- Server modification service
- Admin server controller
- Server validation request
- Admin server details page
- Client API transformer
- Frontend server API types
- Server console display component

If no custom address is configured, the panel falls back to the server's default allocation.

**Note:** This modification only changes the address displayed in the panel. It does not modify actual server allocations, networking, ports, DNS records, or connectivity.

## Backups

Before modifying files, the installer creates a backup directory inside:

```text
/var/www/pterodactyl/
```

The directory will look similar to:

```text
kendrick-codes-backup-YYYYMMDD_HHMMSS
```

Keep this backup safe. It contains copies of the original files modified by the installer.

The database change is not included in this file backup.

## Compatibility

This installer expects a Pterodactyl Panel codebase with the file structure and code sections used by the installer.

Different panel versions or heavily modified forks may require manual adjustments.

Always take a full panel and database backup before applying modifications to a production installation.

## Troubleshooting

**Installation stops because a file or code section is missing**

Your panel may use a different version or modified source code. Check compatibility before continuing.

**Frontend build fails**

Check your Node.js and Yarn versions and install the panel's required frontend dependencies.

**Custom address does not appear**

Try clearing the Laravel cache:

```bash
cd /var/www/pterodactyl
php artisan optimize:clear
```

Then refresh the panel in your browser.

**Installation was interrupted**

Check the backup directory printed by the installer before attempting manual recovery.

## Credits

**Developed by Kendrick Codes**

GitHub: [https://github.com/kendrickcodes98](https://github.com/kendrickcodes98)

If you find this project useful, consider giving the repository a ⭐.

Contributions, suggestions, and improvements are welcome!

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
