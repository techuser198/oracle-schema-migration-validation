# Migration Validation Role - System Requirements

## Overview
The migration-validation role is an Ansible role designed to validate Oracle database migrations by:
- Comparing table counts between source and target databases
- Validating schema consistency
- Generating detailed comparison reports

## Architecture Analysis

### Core Components:
1. **Shell Script Entry Point**: `schema-migration-validation.sh`
2. **Ansible Playbook**: `schema-migration-validation.yml`
3. **Ansible Role**: `roles/migration-validation/`
4. **Task Files**:
   - `main.yml` - Entry point that loads variables and delegates to operation-specific tasks
   - `compare-counts-task.yml` - Orchestrates table count comparison
   - `get-counts.yml` - Executes SQL queries to count table rows
   - `execute-sql-file.yml` - Generic SQL file execution
   - `validate-schema-task.yml` - Schema validation (currently empty)
5. **Shell Scripts**:
   - `compare-counts.sh` - Compares CSV files and generates reports

### Dependencies Identified:

#### System Dependencies:
- **Linux/Unix Environment** (tested on Ubuntu 22.04)
- **Bash Shell** (v4.0+)
- **Oracle Instant Client + SQL*Plus** (for database connectivity)
- **GNU diffutils** (for file comparison)
- **Ansible** (v2.10+)

#### Ansible Modules Used:
- `include_vars` - Loading YAML configuration files
- `include_tasks` - Task inclusion and orchestration
- `set_fact` - Variable manipulation
- `file` - File operations (create/delete)
- `shell` - Execute shell commands (SQL*Plus)
- `command` - Execute system commands
- `async_status` - Async task monitoring
- `replace` - Text replacement in files
- `debug` - Output display
- `fail` - Conditional failure

#### Oracle Database Features Used:
- SQL*Plus command-line interface
- Oracle system views: `all_tables`
- Oracle SQL functions: `extractvalue`, `xmltype`, `dbms_xmlgen.getxml`
- Oracle table attributes: `IOT_NAME` (Index-Organized Tables)

### Configuration Structure:
- Variables defined in `vars/migration-cm.yml`
- Support for source and target database configurations
- Database connection parameters (host, port, service, schema, credentials)

### Output Files:
- `/tmp/source_<schema>_table_counts.csv`
- `/tmp/target_<schema>_table_counts.csv`
- `/tmp/compare_table_counts.txt`
- `/tmp/diff_count_comparison_summary.log`

### Security Considerations:
- Database passwords handled via Ansible variables
- `no_log: true` used for sensitive tasks
- Temporary files created in `/tmp/`

### Scalability Features:
- Async task execution for database queries
- Configurable timeout (1800 seconds)
- Retry logic for task completion checking

### Error Handling:
- Graceful handling of missing files
- Oracle-specific error handling for IOT tables
- Conditional failure based on comparison results

This role is specifically designed for Oracle database migration validation workflows and requires a properly configured Oracle client environment.
