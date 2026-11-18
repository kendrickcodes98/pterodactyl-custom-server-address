
#!/usr/bin/env bash

# ============================================================
# KENDRICK CODES
# Custom Server Display Address Installer
# Author: https://github.com/kendrickcodes98
# ============================================================

set -Eeuo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
RESET='\033[0m'
BOLD='\033[1m'

APP_NAME="KENDRICK CODES"
PANEL_DIR="/var/www/pterodactyl"
BACKUP_DIR=""

# ------------------------------------------------------------
# Utilities
# ------------------------------------------------------------

line() {
    echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

success() {
    echo -e "  ${GREEN}✔${RESET} $1"
}

error() {
    echo -e "  ${RED}✖${RESET} $1"
}

info() {
    echo -e "  ${CYAN}➜${RESET} $1"
}

warning() {
    echo -e "  ${YELLOW}⚠${RESET} $1"
}

step() {
    echo
    echo -e "${MAGENTA}[$1]${RESET} ${WHITE}$2${RESET}"
    line
}

pause() {
    echo
    read -r -p "  Press ENTER to continue..."
}

# ------------------------------------------------------------
# Animated banner
# ------------------------------------------------------------

banner() {
    clear || true

    echo -e "${CYAN}"
    echo '  ██╗  ██╗███████╗███╗   ██╗██████╗ ██████╗ ██╗ ██████╗██╗  ██╗'
    echo '  ██║ ██╔╝██╔════╝████╗  ██║██╔══██╗██╔══██╗██║██╔════╝██║ ██╔╝'
    echo '  █████╔╝ █████╗  ██╔██╗ ██║██║  ██║██████╔╝██║██║     █████╔╝'
    echo '  ██╔═██╗ ██╔══╝  ██║╚██╗██║██║  ██║██╔══██╗██║██║     ██╔═██╗'
    echo '  ██║  ██╗███████╗██║ ╚████║██████╔╝██║  ██║██║╚██████╗██║  ██╗'
    echo '  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝'
    echo -e "${RESET}"

    line

    echo -e "  ${WHITE}${BOLD}CUSTOM SERVER DISPLAY ADDRESS${RESET}"
    echo -e "  ${GRAY}Pterodactyl Panel Modification Installer${RESET}"
    echo
    echo -e "  ${CYAN}Developer:${RESET} Kendrick Codes"
    echo -e "  ${CYAN}GitHub:${RESET}    github.com/kendrickcodes98"
    echo -e "  ${CYAN}Version:${RESET}   1.0.0"

    line
}

loading() {
    local message="$1"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

    echo -ne "  ${CYAN}${message} ${RESET}"

    for i in {1..20}; do
        echo -ne "\r  ${CYAN}${frames[$((i % 10))]} ${message}${RESET}"
        sleep 0.06
    done

    echo -e "\r  ${GREEN}✔ ${message}${RESET}       "
}

# ------------------------------------------------------------
# Error handler
# ------------------------------------------------------------

cleanup_error() {
    local code=$?

    echo
    error "Installation stopped unexpectedly."
    warning "Exit code: $code"

    if [[ -n "${BACKUP_DIR:-}" && -d "$BACKUP_DIR" ]]; then
        info "Your file backups are located at:"
        echo -e "  ${YELLOW}$BACKUP_DIR${RESET}"
    fi

    echo
    warning "Review the error above before trying again."
    exit "$code"
}

trap cleanup_error ERR

# ------------------------------------------------------------
# Root permission
# ------------------------------------------------------------

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo
        warning "Root permissions are required."

        if ! command -v sudo >/dev/null 2>&1; then
            error "sudo is not installed."
            exit 1
        fi

        info "Requesting sudo permission..."

        sudo -v

        SCRIPT_PATH="$(readlink -f "$0")"

        exec sudo -E bash "$SCRIPT_PATH" "$@"
    fi

    success "Root permissions verified."
}

# ------------------------------------------------------------
# Installation menu
# ------------------------------------------------------------

menu() {
    echo
    echo -e "${WHITE}${BOLD}  SELECT AN ACTION${RESET}"
    line

    echo -e "  ${GREEN}1.${RESET} Install Custom Server Display Address"
    echo -e "  ${RED}2.${RESET} Exit installer"

    line
    echo

    read -r -p "  Select an option [1/2]: " choice

    case "$choice" in
        1)
            echo
            success "Installation selected."
            ;;
        2)
            echo
            warning "Installation cancelled."
            exit 0
            ;;
        *)
            error "Invalid selection."
            menu
            ;;
    esac
}

# ------------------------------------------------------------
# Check panel
# ------------------------------------------------------------

check_panel() {
    step "01/13" "Checking Pterodactyl installation"

    if [[ ! -d "$PANEL_DIR" ]]; then
        error "Pterodactyl directory not found: $PANEL_DIR"
        echo
        warning "This installer expects the panel at /var/www/pterodactyl."
        exit 1
    fi

    cd "$PANEL_DIR"

    if [[ ! -f artisan || ! -f composer.json ]]; then
        error "This does not appear to be a Pterodactyl panel."
        exit 1
    fi

    success "Pterodactyl installation detected."
    info "Panel directory: $PANEL_DIR"
}

# ------------------------------------------------------------
# Check dependencies
# ------------------------------------------------------------

check_dependencies() {
    step "02/13" "Checking required dependencies"

    local missing=0

    for cmd in php python3 node yarn systemctl; do
        if command -v "$cmd" >/dev/null 2>&1; then
            success "$cmd detected."
        else
            error "$cmd is missing."
            missing=1
        fi
    done

    if [[ "$missing" -ne 0 ]]; then
        error "Install the missing dependencies before continuing."
        exit 1
    fi
}

# ------------------------------------------------------------
# Backup
# ------------------------------------------------------------

create_backup() {
    step "03/13" "Creating backup"

    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"

    BACKUP_DIR="$PANEL_DIR/kendrick-codes-backup-$timestamp"

    mkdir -p "$BACKUP_DIR"

    local files=(
        "app/Models/Server.php"
        "app/Services/Servers/DetailsModificationService.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Requests/Admin/ServerDetailsFormRequest.php"
        "resources/views/admin/servers/view/details.blade.php"
        "app/Transformers/Api/Client/ServerTransformer.php"
        "resources/scripts/api/server/getServer.ts"
        "resources/scripts/components/server/console/ServerDetailsBlock.tsx"
    )

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            error "Required file missing: $file"
            exit 1
        fi

        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp -a "$file" "$BACKUP_DIR/$file"
    done

    success "All target files backed up."
    info "Backup location: $BACKUP_DIR"
}

# ------------------------------------------------------------
# Database modification
# ------------------------------------------------------------

database_update() {
    step "04/13" "Updating database structure"

    local php_code

    php_code=$(cat <<'PHP'
$schema = Illuminate\Support\Facades\Schema::connection(config("database.default"));

if (!$schema->hasColumn("servers", "public_address")) {
    $schema->table("servers", function ($table) {
        $table->string("public_address")->nullable()->after("description");
    });

    echo "Column created successfully.\n";
} else {
    echo "Column already exists. Skipping.\n";
}
PHP
)

    php artisan tinker --execute="$php_code"

    local verify
    verify=$(php artisan tinker --execute='dump(Illuminate\Support\Facades\Schema::hasColumn("servers", "public_address"));' 2>&1)

    if ! grep -q "true" <<< "$verify"; then
        error "Database column verification failed."
        exit 1
    fi

    success "Database updated successfully."
}

# ------------------------------------------------------------
# Patch panel files
# ------------------------------------------------------------

patch_files() {
    step "05/13" "Applying Pterodactyl modifications"

    python3 - <<'PY'
from pathlib import Path
import sys

def patch(path, marker, old, new):
    p = Path(path)
    s = p.read_text()

    if marker in s:
        print(f"  [SKIP] {path}")
        return

    if old not in s:
        raise RuntimeError(f"Could not find expected code in {path}")

    s = s.replace(old, new, 1)
    p.write_text(s)
    print(f"  [OK]   {path}")


# 1. Server model
patch(
    "app/Models/Server.php",
    "@property string|null $public_address",
    " * @property string $description\n",
    " * @property string $description\n * @property string|null $public_address\n"
)

# 2. DetailsModificationService
patch(
    "app/Services/Servers/DetailsModificationService.php",
    "'public_address' => Arr::get($data, 'public_address')",
    """                'name' => Arr::get($data, 'name'),
                'description' => Arr::get($data, 'description') ?? '',
""",
    """                'name' => Arr::get($data, 'name'),
                'description' => Arr::get($data, 'description') ?? '',
                'public_address' => Arr::get($data, 'public_address'),
"""
)

# 3. ServersController
patch(
    "app/Http/Controllers/Admin/ServersController.php",
    "'owner_id', 'external_id', 'name', 'description', 'public_address'",
    "'owner_id', 'external_id', 'name', 'description',",
    "'owner_id', 'external_id', 'name', 'description', 'public_address',"
)

# 4. ServerDetailsFormRequest - accepted fields
patch(
    "app/Http/Requests/Admin/ServerDetailsFormRequest.php",
    "            'public_address',",
    """            'name',
            'description',
""",
    """            'name',
            'description',
            'public_address',
"""
)

# 5. ServerDetailsFormRequest - validation rules
patch(
    "app/Http/Requests/Admin/ServerDetailsFormRequest.php",
    "$rules['public_address'][] = 'max:255';",
    "        $rules['description'][] = 'nullable';",
    """        $rules['description'][] = 'nullable';
        $rules['public_address'][] = 'nullable';
        $rules['public_address'][] = 'string';
        $rules['public_address'][] = 'max:255';"""
)

# 6. Admin details page
patch(
    "resources/views/admin/servers/view/details.blade.php",
    'name="public_address"',
    """                    <div class="form-group">
                        <label for="description" class="control-label">Server Description</label>
                        <textarea name="description" rows="3" class="form-control">{{ old('description', $server->description) }}</textarea>
                        <p class="text-muted small">A brief description of this server.</p>
                    </div>
""",
    """                    <div class="form-group">
                        <label for="description" class="control-label">Server Description</label>
                        <textarea name="description" rows="3" class="form-control">{{ old('description', $server->description) }}</textarea>
                        <p class="text-muted small">A brief description of this server.</p>
                    </div>

                    <div class="form-group">
                        <label for="public_address" class="control-label">Public Address</label>
                        <input
                            type="text"
                            name="public_address"
                            id="public_address"
                            value="{{ old('public_address', $server->public_address) }}"
                            class="form-control"
                            placeholder="play.example.com:25565"
                        />
                        <p class="text-muted small">
                            Address displayed to the server user. This does not change the actual Pterodactyl allocation.
                        </p>
                    </div>
"""
)

# 7. ServerTransformer
patch(
    "app/Transformers/Api/Client/ServerTransformer.php",
    "'public_address' => $server->public_address",
    """            'description' => $server->description,
            'limits' => [
""",
    """            'description' => $server->description,
            'public_address' => $server->public_address,
            'limits' => [
"""
)

# 8. Frontend Server type
patch(
    "resources/scripts/api/server/getServer.ts",
    "  publicAddress: string | null;",
    "  description: string;\n",
    "  description: string;\n  publicAddress: string | null;\n"
)

# 9. Frontend API mapping
patch(
    "resources/scripts/api/server/getServer.ts",
    "publicAddress: data.public_address || null,",
    "  description: data.description ? (data.description.length > 0 ? data.description : null) : null,\n",
    """  description: data.description ? (data.description.length > 0 ? data.description : null) : null,
  publicAddress: data.public_address || null,
"""
)

# 10. Console display
patch(
    "resources/scripts/components/server/console/ServerDetailsBlock.tsx",
    "state.server.data!.publicAddress",
    """    const allocation = ServerContext.useStoreState((state) => {
        const match = state.server.data!.allocations.find((allocation) => allocation.isDefault);

        return !match ? 'n/a' : `${match.alias || ip(match.ip)}:${match.port}`;
    });
""",
    """    const allocation = ServerContext.useStoreState((state) => {
        if (state.server.data!.publicAddress) {
            return state.server.data!.publicAddress;
        }

        const match = state.server.data!.allocations.find((allocation) => allocation.isDefault);

        return !match ? 'n/a' : `${match.alias || ip(match.ip)}:${match.port}`;
    });
"""
)

print("\nAll source modifications completed.")
PY

    success "Panel source files updated."
}

# ------------------------------------------------------------
# Build frontend
# ------------------------------------------------------------

build_frontend() {
    step "06/13" "Building frontend assets"

    cd "$PANEL_DIR"

    info "Running production build..."
    echo

    NODE_OPTIONS=--openssl-legacy-provider yarn build:production

    success "Frontend compiled successfully."
}

# ------------------------------------------------------------
# Clear cache
# ------------------------------------------------------------

clear_cache() {
    step "07/13" "Clearing Laravel cache"

    cd "$PANEL_DIR"

    php artisan optimize:clear

    success "Laravel cache cleared."
}

# ------------------------------------------------------------
# Restart PHP-FPM
# ------------------------------------------------------------

restart_php() {
    step "08/13" "Restarting PHP-FPM"

    local services=()

    while IFS= read -r service; do
        [[ -n "$service" ]] && services+=("$service")
    done < <(
        systemctl list-unit-files --type=service --no-legend 'php*-fpm.service' |
        awk '{print $1}'
    )

    if [[ ${#services[@]} -eq 0 ]]; then
        warning "No PHP-FPM service found automatically."
        warning "Please restart your PHP-FPM service manually."
        return
    fi

    local restarted=0

    for service in "${services[@]}"; do
        if systemctl restart "$service"; then
            success "Restarted $service"
            restarted=1
        fi
    done

    if [[ "$restarted" -eq 0 ]]; then
        error "PHP-FPM could not be restarted."
        exit 1
    fi
}

# ------------------------------------------------------------
# Verify modifications
# ------------------------------------------------------------

verify_installation() {
    step "09/13" "Verifying modifications"

    local files=(
        "app/Models/Server.php"
        "app/Services/Servers/DetailsModificationService.php"
        "app/Http/Controllers/Admin/ServersController.php"
        "app/Http/Requests/Admin/ServerDetailsFormRequest.php"
        "resources/views/admin/servers/view/details.blade.php"
        "app/Transformers/Api/Client/ServerTransformer.php"
        "resources/scripts/api/server/getServer.ts"
        "resources/scripts/components/server/console/ServerDetailsBlock.tsx"
    )

    for file in "${files[@]}"; do
        if grep -q "public_address\|publicAddress" "$file"; then
            success "$(basename "$file")"
        else
            error "Verification failed: $file"
            exit 1
        fi
    done
}

# ------------------------------------------------------------
# Final information
# ------------------------------------------------------------

finish() {
    step "10/13" "Installation completed"

    echo
    echo -e "${GREEN}"
    echo '  ██████╗  ██████╗ ███╗   ██╗███████╗'
    echo '  ██╔══██╗██╔═══██╗████╗  ██║██╔════╝'
    echo '  ██║  ██║██║   ██║██╔██╗ ██║█████╗'
    echo '  ██║  ██║██║   ██║██║╚██╗██║██╔══╝'
    echo '  ██████╔╝╚██████╔╝██║ ╚████║███████╗'
    echo '  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝'
    echo -e "${RESET}"

    line

    echo -e "  ${GREEN}${BOLD}CUSTOM SERVER DISPLAY ADDRESS INSTALLED!${RESET}"
    echo
    echo -e "  ${WHITE}HOW TO USE:${RESET}"
    echo
    echo -e "  ${CYAN}1.${RESET} Open your Pterodactyl Admin Panel."
    echo -e "  ${CYAN}2.${RESET} Navigate to ${WHITE}Servers${RESET}."
    echo -e "  ${CYAN}3.${RESET} Select the server you want to modify."
    echo -e "  ${CYAN}4.${RESET} Open the ${WHITE}Details${RESET} section."
    echo -e "  ${CYAN}5.${RESET} Find the ${WHITE}Public Address${RESET} field."
    echo -e "  ${CYAN}6.${RESET} Enter your custom server address."
    echo -e "  ${CYAN}7.${RESET} Save your changes."
    echo
    line

    echo -e "  ${YELLOW}Example address:${RESET}"
    echo -e "  play.example.com:25565"
    echo
    echo -e "  ${GRAY}This changes the displayed address only.${RESET}"
    echo -e "  ${GRAY}It does not change the actual server allocation.${RESET}"

    line

    echo -e "  ${WHITE}BACKUP:${RESET} $BACKUP_DIR"
    echo
    echo -e "  ${MAGENTA}Script by Kendrick Codes${RESET}"
    echo -e "  ${CYAN}https://github.com/kendrickcodes98${RESET}"
    echo
    echo -e "  ${YELLOW}Give the repository a star ⭐ or contribute improvements!${RESET}"

    line

    echo
    success "Thank you for using Kendrick Codes!"
    echo
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

main() {
    banner

    loading "Initializing Kendrick Codes Installer"

    check_root "$@"

    menu

    check_panel
    check_dependencies
    create_backup
    database_update
    patch_files
    build_frontend
    clear_cache
    restart_php
    verify_installation

    finish
}

main "$@"
