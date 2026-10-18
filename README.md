# General Principles
- Naming Conventions: Use snake_case, with lowercase letters and underscores(_) to separate words.
- Language: Use English for all names.
- Avoid Reserved Words: not use SQL reserved words as object names.

# Table Naming Convention
## Bronze Rules
- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**:
    - `<sourcesystem>`: Name of the source system (e.g: crm, erp)
    - `<entity>`: Exact table name of the source system.
    - Example: `crm_customer_info` -> Customer information from the CRM system

 ## Silver Rules
- All names must start with the source system name, and table names must match their original names without renaming.
- **`<sourcesystem>_<entity>`**:
    - `<sourcesystem>`: Name of the source system (e.g: crm, erp)
    - `<entity>`: Exact table name of the source system.
    - Example: `crm_customer_info` -> Customer information from the CRM system
 
## Gold Rules
- All names should use meaningful, business-aligned names for tables, starting with the category prefix.
- **`<category>_<entity>`**:
    - `<category>`: Describes the role of the table, such as `dim` (dimension) or `fact` (fact table).
    - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g. customers, products and sales).
    - Examples:
        - `dim_customers`: Dimension table for customer data.
        -  `fact_sales`: Fact table containing sale transactions.
          
Glossary of Category Pattern
|Pattern|Meaning|Examples|
|-|-|-|
|`dim_`|Dimension table|`dim_customer`, `dim_product`|
|`fact_`|Fact table|`fact_sales`|
|`agg_`|Aggregated table|`aggregate_customers`, `aggregate_sales_monthly`|

# Column Naming Convention
## Surrogate Keys
- All primary keys in dimensions tables must followed by a suffix `_key`
- **`<table_name>_key`**:
    - `<table_name>`: Refers to the name of the table or the entity the key belongs to.
    - `key`: A suffix indicating that this column is a surrogate key.
    - Example: `customer_key` -> Surrogate key in the `dim_customers` table.
 
## Technical Columns
- All technical columns must start with the prefix `dwh_`, followed by a descriptive name, indicating the column's purpose.
- **`dwh_<column_name>`**:
    - `dwh`: Prefix exclusive system-generated metadata.
    - `<column_name>`: Descriptive name indicating the column's purpose.
    - Example: `dwh_load_date` -> System-generated columns used to store the date when record was loaded.
 
## Stored Procedure
- All stored procedure used for loading the data must follow the naming pattern.
- **`load_<layer>`**:
    - `<layer>`: Represent the layer being loaded, such as `bronze`, `silver`, `gold`.
    - Example:
        - `load-bronze` -> Stored procedure for loading the data into Bronze layer.
        - `load-silver` -> Stored procedure for loading the data into Silver layer.
