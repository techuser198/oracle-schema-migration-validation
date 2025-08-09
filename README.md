# Migration Validation Scripts

This project provides automated validation tools for Oracle database migrations using Ansible.

## Features

- **Table Count Comparison**: Compare row counts between source and target databases
- **Comprehensive Schema Validation**: Validate complete schema structure and objects
  - Tables, Columns, Sequences, Indexes, Constraints
  - Triggers, Views, Synonyms, Privileges
  - Object counts and database structure
- **Template-based Comparison**: Dynamic script generation using Jinja2 templates
- **Automated Cleanup**: Removes old comparison files before new runs
- **Async Processing**: Parallel execution for improved performance
- **Detailed Reporting**: Generate comprehensive comparison reports with diff analysis
- **Oracle IOT Support**: Handle Index-Organized Tables properly

## Quick Start

### Prerequisites

- Linux/Unix environment (tested on Ubuntu 22.04)
- Python 3.8+
- Oracle Instant Client with SQL*Plus
- Sudo access for system package installation

### Installation

1. **Clone/Download** this repository
2. **Run the setup script**:
   ```bash
   ./setup.sh
   ```
3. **Activate the environment**:
   ```bash
   source activate.sh
   ```

### Configuration

1. **Edit the configuration file** `roles/migration-validation/vars/migration-cm.yml`:
   ```yaml
   source:
     db_schema: YOUR_SOURCE_SCHEMA
     db_schema_password: YOUR_PASSWORD
     db_host: your-source-host.com
     db_port: 1521
     db_name: YOUR_DB_NAME
     db_service: YOUR_SERVICE
     masteruser:
       m_user: MASTER_USER
       m_password: MASTER_PASSWORD

   target:
     db_schema: YOUR_TARGET_SCHEMA
     db_schema_password: YOUR_PASSWORD
     db_host: your-target-host.com
     db_port: 1521
     db_name: YOUR_DB_NAME
     db_service: YOUR_SERVICE
     masteruser:
       m_user: MASTER_USER
       m_password: MASTER_PASSWORD
   ```

### Usage

#### Compare Table Counts
```bash
./schema-migration-validation.sh compare-counts migration-cm
```

#### Validate Schema (comprehensive)
```bash
./schema-migration-validation.sh validate-schema migration-cm
```

This operation performs comprehensive schema validation by:
- Extracting schema objects from both source and target databases
- Comparing 11 different object types (tables, columns, sequences, etc.)
- Generating detailed diff reports for any differences found
- Creating a summary log with overall comparison results

## Project Structure

```
.
├── schema-migration-validation.sh          # Main entry point
├── schema-migration-validation.yml         # Ansible playbook
├── roles/migration-validation/              # Ansible role
│   ├── tasks/
│   │   ├── main.yml                        # Role entry point
│   │   ├── compare-counts-task.yml         # Table count comparison logic
│   │   ├── get-counts.yml                  # SQL execution for counting
│   │   ├── compare-counts.sh               # File comparison script
│   │   ├── execute-sql-file-oracle.yml     # Oracle SQL executor
│   │   ├── validate-schema-task.yml        # Comprehensive schema validation
│   │   └── files/                          # SQL scripts for schema extraction
│   │       ├── dump-oracle-schema-tables.sql
│   │       ├── dump-oracle-schema-columns.sql
│   │       ├── dump-oracle-schema-sequences.sql
│   │       ├── dump-oracle-schema-indexes.sql
│   │       ├── dump-oracle-schema-constraints.sql
│   │       ├── dump-oracle-schema-triggers.sql
│   │       ├── dump-oracle-schema-views.sql
│   │       ├── dump-oracle-schema-synonyms.sql
│   │       ├── dump-oracle-schema-privileges.sql
│   │       ├── dump-oracle-object-count.sql
│   │       └── schema-comp-structure.sql
│   ├── templates/
│   │   └── validate-schema-script.sh.j2   # Dynamic comparison script template
│   ├── vars/
│   │   └── migration-cm.yml                # Database configuration
│   ├── defaults/
│   └── files/
├── requirements.txt                         # Python dependencies
├── setup.sh                               # Environment setup script
├── activate.sh                            # Environment activation script
└── SYSTEM_REQUIREMENTS.md                 # Detailed requirements
```

## Output Files

The scripts generate several output files in `/tmp/`:

### Table Count Comparison
- `source_<schema>_table_counts.csv` - Source database table counts
- `target_<schema>_table_counts.csv` - Target database table counts  
- `compare_table_counts.txt` - Detailed differences
- `diff_count_comparison_summary.log` - Summary report

### Schema Validation
- `source_<service>_<schema>-<object_type>.csv` - Source schema objects (11 types)
- `target_<service>_<schema>-<object_type>.csv` - Target schema objects (11 types)
- `diff_<source_service>-<source_schema>_<target_service>-<target_schema>-<object_type>.txt` - Object differences
- `diff_comparison_summary.log` - Comprehensive schema comparison summary
- `validate-schema-script.sh` - Generated comparison script

Object types include: tables, columns, sequences, indexes, constraints, triggers, views, synonyms, privileges, count, structure

## Configuration Files

### Database Configuration (`migration-cm.yml`)

Configure your source and target database connections:

```yaml
source:
  db_schema: SCHEMA_NAME           # Database schema to validate
  db_schema_password: PASSWORD     # Schema password
  db_host: hostname.domain.com     # Database host
  db_port: 1521                   # Database port
  db_name: DATABASE_NAME          # Database name
  db_service: SERVICE_NAME        # TNS service name
  masteruser:                     # Master user for operations
    m_user: MASTER_USERNAME
    m_password: MASTER_PASSWORD

target:
  # Same structure as source
```

## Advanced Usage

### Custom SQL Execution

Use the `execute-sql-file-oracle.yml` task for custom Oracle SQL operations:

```yaml
- include_tasks: roles/migration-validation/tasks/execute-sql-file-oracle.yml
  vars:
    db_user: "{{ source.db_schema }}"
    db_password: "{{ source.db_schema_password }}"
    db_host: "{{ source.db_host }}"
    db_service: "{{ source.db_service }}"
    db_schema: "{{ source.db_schema }}"
    sql_file: "roles/migration-validation/tasks/files/your-script.sql"
    output_file: "/tmp/output.csv"
    sql_parameters: '"PARAMETER_VALUE"'
```

### Adding New Schema Object Types

1. Create a new SQL script in `roles/migration-validation/tasks/files/`
2. Add the object type to the loop in `validate-schema-task.yml`
3. Update the `SUFFIXES_SCHEMA_OBJ` array in `validate-schema-script.sh.j2`
4. Test with your specific Oracle schema

### Template Customization

The schema comparison script is generated from `validate-schema-script.sh.j2`. You can customize:
- Comparison logic in the `compare_files()` function
- Output formatting and logging
- File naming patterns and diff options

## Troubleshooting

### Common Issues

**Oracle Connection Errors**:
- Verify Oracle Instant Client installation
- Check TNS names resolution
- Validate database credentials
- Ensure network connectivity

**Ansible Errors**:
- Check Python virtual environment activation
- Verify Ansible installation: `ansible --version`
- Check YAML syntax in configuration files
- Verify Jinja2 template syntax: `ansible-playbook --syntax-check`

**Template Rendering Issues**:
- Check variable names match between template and vars files
- Verify Jinja2 syntax in `.j2` files
- Test template rendering manually if needed
- Ensure proper escaping of special characters

**Schema Comparison Issues**:
- Verify all 11 SQL scripts exist in `files/` directory
- Check Oracle schema permissions for metadata queries
- Ensure sufficient disk space in `/tmp/` for output files
- Verify diff utility supports `--side-by-side` option

**Permission Errors**:
- Ensure execute permissions: `chmod +x schema-migration-validation.sh`
- Check `/tmp/` directory permissions
- Verify database user privileges

### Debug Mode

Enable detailed logging by uncommenting `#no_log: true` lines in the task files.

### Log Files

Check these locations for detailed information:
- `setup.log` - Setup script output
- `/tmp/diff_comparison_summary.log` - Schema validation results
- `/tmp/diff_count_comparison_summary.log` - Table count comparison results
- `/tmp/diff_*-*.txt` - Individual object type differences
- Ansible verbose output: Add `-v` flag to ansible-playbook commands

## Security Considerations

- Database passwords are handled securely through Ansible variables
- Sensitive tasks use `no_log: true` to prevent credential exposure
- Temporary files are created with appropriate permissions
- Consider using Ansible Vault for production environments

## Performance Tuning

- Async timeout can be adjusted in `get-counts.yml` (default: 1800 seconds)
- Parallel execution is used for source/target comparisons
- Large result sets are handled via SQL*Plus spooling

## Contributing

### SQL Script Library

The project includes a comprehensive set of Oracle SQL scripts for schema extraction:

| SQL Script | Purpose | Output Format |
|------------|---------|---------------|
| `dump-oracle-schema-tables.sql` | Extract table metadata | CSV |
| `dump-oracle-schema-columns.sql` | Extract column definitions | CSV |
| `dump-oracle-schema-sequences.sql` | Extract sequence objects | CSV |
| `dump-oracle-schema-indexes.sql` | Extract index definitions | CSV |
| `dump-oracle-schema-constraints.sql` | Extract constraint definitions | CSV |
| `dump-oracle-schema-triggers.sql` | Extract trigger definitions | CSV |
| `dump-oracle-schema-views.sql` | Extract view definitions | CSV |
| `dump-oracle-schema-synonyms.sql` | Extract synonym definitions | CSV |
| `dump-oracle-schema-privileges.sql` | Extract privilege grants | CSV |
| `dump-oracle-object-count.sql` | Extract object counts by type | CSV |
| `schema-comp-structure.sql` | Extract overall schema structure | CSV |

### Template System

The schema validation uses Jinja2 templates for dynamic script generation:

- **Template File**: `roles/migration-validation/templates/validate-schema-script.sh.j2`
- **Generated Script**: `/tmp/validate-schema-script.sh`
- **Variables Available**: 
  - `{{ source.db_service }}`, `{{ source.db_schema }}`
  - `{{ target.db_service }}`, `{{ target.db_schema }}`
- **Customization**: Modify template to change comparison logic or output format

### Development Guidelines

1. Follow the existing code structure and patterns
2. Add appropriate error handling and logging
3. Update documentation for new features
4. Test with various Oracle database versions
5. Use `no_log: true` for sensitive operations
6. Maintain template compatibility with existing variable structure

## License

[Add your license information here]

## Support

[Add support contact information here]
