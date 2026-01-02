# Data Warehouse and Analytics Project

## Welcome to the Data Warehouse and Anakytics Project Repository
This projects ingests data from CRM and ERP Systems to create Datawarehousignproject for analytic Repprting

## Objective
Build a SQL Server-based mini data warehouse for sales analytics using raw CSV extracts. The project demonstrates:

- Ingesting raw files into staging tables

- Transforming and standardising keys (customer/product)

- Modelling a simple star schema (Fact Sales + Dimensions)

- Producing repeatable reporting views for BI/dashboarding (Power BI / Excel / SSRS)


## Specification
| File                | Purpose                          | Key Columns (examples)                                                                                               |
| ------------------- | -------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `sales_details.csv` | Sales transactions (order lines) | `sls_ord_num`, `sls_prd_key`, `sls_cust_id`, `sls_order_dt`, `sls_ship_dt`, `sls_sales`, `sls_quantity`, `sls_price` |
| `prd_info.csv`      | Product master data              | `prd_key`, `prd_nm`, `prd_cost`, `prd_line`, `prd_start_dt`, `prd_end_dt`                                            |
| `cust_info.csv`     | Customer master data             | `cst_id`, `cst_key`, `cst_firstname`, `cst_lastname`, `cst_marital_status`, `cst_gndr`, `cst_create_date`            |
| `CUST_AZ12.csv`     | Customer enrichment              | `CID`, `BDATE`, `GEN`                                                                                                |
| `LOC_A101.csv`      | Customer location                | `CID`, `CNTRY`                                                                                                       |
| `PX_CAT_G1V2.csv`   | Product category reference       | `ID`, `CAT`, `SUBCAT`, `MAINTENANCE`                                                                                 |


## Analytic Reporting Requirements

Create reporting views (or stored procedures) that support the following simple dashboard outputs.

1) Sales Overview (KPI Tiles)

- Total Sales (£)

- Total Orders (distinct sls_ord_num)

- Total Units Sold (sum sls_quantity)

- Average Order Value = Total Sales / Total Orders

- Gross Margin (£) and Margin %

2) Time Series Trends

- Monthly Sales trend

- Monthly Orders trend

- Monthly Gross Margin trend

- (Use dw.DimDate to group by Month/Year)

3) Product Performance

- Top 10 products by Sales

- Top 10 products by Gross Margin

- Sales by Product Line (prd_line)

4) Customer Analytics

- Top 10 customers by Sales

- New customers over time (based on cst_create_date)

- Customer sales distribution by country (from LOC_A101)

5) Fulfilment / Delivery (Simple Ops View)

- Average days to ship = ShipDate - OrderDate

- Late shipment count (% where ShipDate > DueDate)

- Orders shipped vs not shipped (null ship date)


## About me
Hi there! I'm a lead Data Engineer with over 15 years data Experience. I am passionate about Data
