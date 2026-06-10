# 📚 Data Catalog

## Project Overview

This document provides metadata and business descriptions for all datasets used in the Data Warehouse project. It serves as a reference for developers, analysts, and stakeholders to understand the structure, purpose, and relationships of the data.

| Attribute | Details |
|-----------|---------|
| **Project Name** | SQL Data Warehouse |
| **Architecture** | Bronze → Silver → Gold |
| **Database** | Microsoft SQL Server |
| **Data Sources** | CRM & ERP CSV Files |
| **Purpose** | Build an analytics-ready data warehouse for business reporting |
| **Refresh Type** | Batch Processing |
| **Last Updated** | June 2026 |

---

# Bronze Layer

The Bronze layer stores raw data exactly as received from the source systems without applying business transformations.

---

## bronze.crm_cust_info

### Description

Stores raw customer information imported from the CRM system.

### Source

CRM System

### Primary Key

`cst_id`

| Column | Data Type | Description |
|----------|----------|-------------|
| cst_id | INT | Unique customer identifier |
| cst_key | VARCHAR | Customer business key |
| cst_firstname | VARCHAR | Customer first name |
| cst_lastname | VARCHAR | Customer last name |
| cst_marital_status | VARCHAR | Marital status |
| cst_gndr | VARCHAR | Gender |
| cst_create_date | DATE | Customer creation date |

---

## bronze.crm_prd_info

### Description

Stores raw product information from the CRM system.

### Primary Key

`prd_id`

| Column | Data Type | Description |
|----------|----------|-------------|
| prd_id | INT | Product identifier |
| prd_key | VARCHAR | Product business key |
| prd_nm | VARCHAR | Product name |
| prd_cost | DECIMAL | Product cost |
| prd_line | VARCHAR | Product line/category |
| prd_start_dt | DATE | Product start date |
| prd_end_dt | DATE | Product end date |

---

## bronze.crm_sales_details

### Description

Stores raw sales transaction records.

| Column | Description |
|----------|-------------|
| sls_ord_num | Sales order number |
| sls_prd_key | Product key |
| sls_cust_id | Customer ID |
| sls_order_dt | Order date |
| sls_ship_dt | Shipping date |
| sls_due_dt | Due date |
| sls_sales | Sales amount |
| sls_quantity | Quantity sold |
| sls_price | Unit price |

---

## bronze.erp_cust_az12

### Description

ERP customer demographic information.

| Column | Description |
|----------|-------------|
| cid | Customer identifier |
| bdate | Birth date |
| gen | Gender |

---

## bronze.erp_loc_a101

### Description

Customer location information.

| Column | Description |
|----------|-------------|
| cid | Customer identifier |
| cntry | Country |

---

## bronze.erp_px_cat_g1v2

### Description

Product category mapping.

| Column | Description |
|----------|-------------|
| id | Product category ID |
| cat | Category |
| subcat | Subcategory |
| maintenance | Maintenance type |

---

# Silver Layer

The Silver layer contains cleansed, standardized, and validated data ready for business integration.

---

## silver.crm_cust_info

### Transformations Applied

- Removed duplicate records
- Trimmed leading/trailing spaces
- Standardized gender values
- Standardized marital status values
- Removed invalid records
- Cleaned customer names

### Business Rule

One record per customer.

---

## silver.crm_prd_info

### Transformations Applied

- Removed duplicate products
- Standardized product names
- Fixed invalid product costs
- Generated valid effective date ranges

### Business Rule

One active version of each product.

---

## silver.crm_sales_details

### Transformations Applied

- Removed invalid dates
- Corrected negative sales values
- Validated quantities
- Standardized pricing

### Business Rule

One record per product sold.

---

## silver.erp_cust_az12

### Transformations Applied

- Standardized gender values
- Validated birth dates
- Removed duplicate records

---

## silver.erp_loc_a101

### Transformations Applied

- Standardized country names
- Removed invalid country values

---

## silver.erp_px_cat_g1v2

### Transformations Applied

- Standardized category names
- Removed duplicate mappings

---

# Gold Layer

The Gold layer contains business-ready dimension and fact tables optimized for analytics and reporting.

---

# gold.dim_customers

## Description

Dimension table containing enriched customer information.

### Grain

One row per customer.

### Primary Key

`customer_key`

| Column | Description |
|----------|-------------|
| customer_key | Surrogate key |
| customer_id | Source customer ID |
| customer_number | Customer business key |
| first_name | First name |
| last_name | Last name |
| country | Customer country |
| marital_status | Marital status |
| gender | Gender |
| birthdate | Birth date |

### Used For

- Customer Analytics
- Segmentation
- Dashboard Reporting

---

# gold.dim_products

## Description

Dimension table containing enriched product information.

### Grain

One row per product.

### Primary Key

`product_key`

| Column | Description |
|----------|-------------|
| product_key | Surrogate key |
| product_id | Source product ID |
| product_number | Product business key |
| product_name | Product name |
| category | Product category |
| subcategory | Product subcategory |
| maintenance | Maintenance classification |
| cost | Product cost |
| start_date | Effective start date |

### Used For

- Product Analytics
- Inventory Analysis
- Sales Reporting

---

# gold.fact_sales

## Description

Fact table storing sales transactions linked to customer and product dimensions.

### Grain

One row per product sold in an order.

### Foreign Keys

- customer_key → gold.dim_customers
- product_key → gold.dim_products

| Column | Description |
|----------|-------------|
| order_number | Sales order number |
| product_key | Product surrogate key |
| customer_key | Customer surrogate key |
| order_date | Date order was placed |
| shipping_date | Date shipped |
| due_date | Due date |
| sales_amount | Total sales amount |
| quantity | Quantity sold |
| price | Unit price |

### Measures

- Total Sales
- Total Quantity
- Average Selling Price

---

# Data Lineage

```
                CRM System
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
bronze.crm_cust_info      bronze.crm_prd_info
        │                         │
        ▼                         ▼
silver.crm_cust_info      silver.crm_prd_info
        │                         │
        └────────────┬────────────┘
                     ▼
             gold.dim_customers

             gold.dim_products


ERP System
     │
     ├───────────────┐
     ▼               ▼
erp_cust_az12   erp_loc_a101
     │               │
     ▼               ▼
silver.erp_cust silver.erp_loc
        │         │
        └────┬────┘
             ▼
     gold.dim_customers


Sales Details
      │
      ▼
bronze.crm_sales_details
      │
      ▼
silver.crm_sales_details
      │
      ▼
     gold.fact_sales
```

---

# Naming Conventions

| Prefix | Meaning |
|----------|----------|
| bronze | Raw source data |
| silver | Cleaned and transformed data |
| gold | Analytics-ready data |
| dim | Dimension table |
| fact | Fact table |
| id | Source identifier |
| key | Surrogate or business key |

---

# Data Quality Rules

- Duplicate records are removed.
- Null values are validated before loading.
- Gender values are standardized.
- Country names are normalized.
- Invalid dates are corrected or discarded.
- Product costs cannot be negative.
- Sales quantities must be greater than zero.
- Referential integrity is maintained between dimensions and facts.

---

# Refresh Schedule

| Layer | Frequency |
|----------|-----------|
| Bronze | Daily |
| Silver | Daily after Bronze load |
| Gold | Daily after Silver load |

---

# Intended Use

This data warehouse supports:

- Business Intelligence dashboards
- Sales performance reporting
- Customer segmentation
- Product performance analysis
- Executive reporting
- Data analytics and visualization
