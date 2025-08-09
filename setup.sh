#!/bin/bash

# Setup Script for Migration Validation Environment
# =================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        log "✓ $1 is installed"
        return 0
    else
        log "✗ $1 is not installed"
        return 1
    fi
}

install_system_dependencies() {
    log "Installing system dependencies..."
    
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y bash diffutils python3 python3-pip python3-venv
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS/Fedora
        sudo yum install -y bash diffutils python3 python3-pip
    else
        log "Unsupported OS. Please install bash, diffutils, python3, and pip manually."
        exit 1
    fi
}

setup_python_environment() {
    log "Setting up Python virtual environment..."
    
    if [[ ! -d "$SCRIPT_DIR/venv" ]]; then
        python3 -m venv "$SCRIPT_DIR/venv"
    fi
    
    source "$SCRIPT_DIR/venv/bin/activate"
    pip install --upgrade pip
    
    if [[ -f "$SCRIPT_DIR/requirements.txt" ]]; then
        pip install -r "$SCRIPT_DIR/requirements.txt"
    else
        log "requirements.txt not found, installing basic dependencies..."
        pip install ansible-core PyYAML Jinja2
    fi
}

install_ansible_collections() {
    log "Installing Ansible collections..."
    source "$SCRIPT_DIR/venv/bin/activate"
    
    ansible-galaxy collection install ansible.posix community.general --force
}

check_oracle_client() {
    log "Checking Oracle client installation..."
    
    if check_command "sqlplus"; then
        sqlplus -v 2>&1 | head -n 1 | tee -a "$LOG_FILE"
    else
        log "WARNING: Oracle SQL*Plus not found!"
        log "Please install Oracle Instant Client and SQL*Plus:"
        log "1. Download from: https://www.oracle.com/database/technologies/instant-client.html"
        log "2. Install the basic and sqlplus packages"
        log "3. Ensure sqlplus is in your PATH"
        return 1
    fi
}

verify_installation() {
    log "Verifying installation..."
    
    source "$SCRIPT_DIR/venv/bin/activate"
    
    # Check Python dependencies
    python3 -c "import ansible; print(f'Ansible version: {ansible.__version__}')" 2>&1 | tee -a "$LOG_FILE"
    python3 -c "import jinja2; print(f'Jinja2 version: {jinja2.__version__}')" 2>&1 | tee -a "$LOG_FILE"
    
    # Check Ansible
    ansible --version | head -n 1 | tee -a "$LOG_FILE"
    
    # Check Ansible collections
    ansible-galaxy collection list | grep -E "(ansible.posix|community.general)" | tee -a "$LOG_FILE"
    
    # Check system tools
    check_command "bash"
    check_command "diff"
    
    # Verify template functionality
    log "Testing Jinja2 template functionality..."
    python3 -c "
from jinja2 import Template
template = Template('Test: {{ test_var }}')
result = template.render(test_var='OK')
print(f'Template test: {result}')
" 2>&1 | tee -a "$LOG_FILE"
    
    # Check Oracle
    check_oracle_client
}

create_activation_script() {
    log "Creating activation script..."
    
    cat > "$SCRIPT_DIR/activate.sh" << 'EOF'
#!/bin/bash
# Activation script for migration validation environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/venv/bin/activate" ]]; then
    source "$SCRIPT_DIR/venv/bin/activate"
    echo "✓ Python virtual environment activated"
    echo "✓ Ready to run migration validation scripts"
    echo ""
    echo "Usage:"
    echo "  ./schema-migration-validation.sh compare-counts migration-cm"
    echo "  ./schema-migration-validation.sh validate-schema migration-cm"
    echo ""
    echo "Features:"
    echo "  - Table count comparison between source and target databases"
    echo "  - Comprehensive schema validation (11 object types)"
    echo "  - Template-based comparison script generation"
    echo "  - Automatic cleanup of old comparison files"
else
    echo "✗ Virtual environment not found. Please run setup.sh first."
    exit 1
fi
EOF
    
    chmod +x "$SCRIPT_DIR/activate.sh"
}

main() {
    log "Starting migration validation environment setup..."
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        log "WARNING: Running as root is not recommended"
    fi
    
    # Install system dependencies
    install_system_dependencies
    
    # Setup Python environment
    setup_python_environment
    
    # Install Ansible collections
    install_ansible_collections
    
    # Check Oracle client
    check_oracle_client
    
    # Verify installation
    verify_installation
    
    # Create activation script
    create_activation_script
    
    log "Setup completed successfully!"
    log "To activate the environment, run: source activate.sh"
    log "Setup log saved to: $LOG_FILE"
}

# Run main function
main "$@"
