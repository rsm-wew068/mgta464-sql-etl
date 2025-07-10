# MGTA464 SQL and ETL Project

A comprehensive data engineering and analytics project for the Master's in Business Analytics course (MGTA464). This project demonstrates SQL mastery, ETL processes, and business intelligence using real-world data scenarios.

## 📁 Project Structure

```
mgta464-sql-etl/
├── README.md                    # Project documentation
├── Assignment 2.pgsql           # SQL fundamentals
├── Assignment 3.pgsql           # Advanced SQL concepts
├── Assignment 4.pgsql           # Data engineering
├── snowflake_yellow12.ipynb     # ETL pipeline
├── ERD.pdf                      # Database schema diagram
└── Data/                        # All data files organized here
    ├── supplier_case.csv            # Core supplier data
    ├── supplier_case.pgsql          # Supplier database schema
    ├── Supplier Transactions XML.xml # Updated transaction data (2022)
    ├── 2021_Gaz_zcta_national.txt   # Geographic data
    └── Monthly PO Data/             # 41 monthly CSV files
```

## 🎯 Learning Objectives

### **SQL Fundamentals (Assignment 2)**
- DISTINCT operations and data deduplication
- Date functions (EXTRACT, DATE_TRUNC)
- Window functions and partitioning
- Advanced aggregation with FILTER clauses
- Set operations (UNION, INTERSECT, EXCEPT)

### **Advanced SQL (Assignment 3)**
- Recursive Common Table Expressions (CTEs)
- Employee hierarchy management
- Backorder chain analysis
- Subquery expressions (IN, EXISTS, ANY, ALL)
- Advanced GROUP BY options (GROUPING SETS, ROLLUP, CUBE)

### **Data Engineering (Assignment 4)**
- Window functions for time series analysis
- String processing and address standardization
- Fuzzy string matching algorithms
- Data quality validation and cleaning
- Geographic data integration

### **ETL Pipeline (Snowflake)**
- Multi-source data integration (CSV, XML, Database)
- Cloud data warehouse operations (Snowflake)
- Data transformation and type conversion
- Geographic and weather data correlation
- Business intelligence implementation

## 📂 Data Sources

### Assignment Data
These files are used in Assignment 2, 3, and 4 for SQL practice and database exercises:
- `Data/supplier_case.csv` — Core supplier master data for SQL queries and exercises
- `Data/supplier_case.pgsql` — SQL schema for loading supplier data into a database

### Snowflake ETL Project Data
These files are used in the `snowflake_yellow12.ipynb` notebook for the end-to-end ETL pipeline:
- `Data/Monthly PO Data/` — 41 monthly purchase order CSV files, combined and transformed in the ETL process
- `Data/Supplier Transactions XML.xml` — Supplier transaction data in XML format, used for advanced ETL and integration
- `Data/2021_Gaz_zcta_national.txt` — Geographic/ZIP code data for enrichment and analysis


## 🛠️ Technical Skills Demonstrated

### **SQL Mastery**
- Complex joins and subqueries
- Window functions and analytical queries
- Recursive queries for hierarchical data
- Data aggregation and pivoting
- String manipulation and pattern matching

### **Data Engineering**
- ETL pipeline design and implementation
- Multi-format data handling (CSV, XML, JSON)
- Data type conversion and validation
- Cloud data warehouse operations
- Geographic data processing

### **Business Intelligence**
- Sales analysis and performance metrics
- Supplier relationship management
- Order-to-cash cycle analysis
- Geographic and temporal data correlation
- Data quality and fuzzy matching

## 🚀 Key Features

### **Real-World Scenarios**
- Supplier performance analysis
- Purchase order variance tracking
- Weather impact on supply chain
- Customer payment analysis
- Address standardization and matching

### **Advanced Analytics**
- Time series analysis with window functions
- Hierarchical data processing
- Fuzzy string matching for data quality
- Geographic clustering and distance calculations
- Multi-dimensional data aggregation

## 📊 Business Applications

This project simulates real-world business scenarios:
- **Supply Chain Management**: Purchase order tracking and supplier analysis
- **Financial Analysis**: Order-to-cash cycles and payment processing
- **Data Quality**: Address standardization and duplicate detection
- **Geographic Intelligence**: Location-based supplier and weather analysis
- **Performance Analytics**: Sales and supplier performance metrics

## 🎓 Learning Outcomes

Students completing this project will be proficient in:
1. **Advanced SQL**: Complex queries, window functions, recursive CTEs
2. **Data Engineering**: ETL processes, data transformation, quality management
3. **Business Intelligence**: Analytics, reporting, performance measurement
4. **Cloud Platforms**: Snowflake operations and best practices
5. **Data Integration**: Multi-source data handling and correlation

## 📝 Usage

1. **SQL Assignments**: Run the `.pgsql` files in a PostgreSQL environment
2. **ETL Pipeline**: Execute the Jupyter notebook cells sequentially
3. **Data Analysis**: Use the created views and tables for business intelligence

## 🔧 Prerequisites

- PostgreSQL database
- Snowflake account (for notebook execution)
- Python with required packages (snowflake-connector, psycopg2)
- Jupyter notebook environment

## 📊 Entity-Relationship Diagram (ERD)

The [ERD.pdf](./ERD.pdf) file provides a high-level view of the database schema and pipeline logic for the assignments (Assignment 2, 3, and 4). It includes both Procure-to-Pay (PTP) and Order-to-Cash (OTC) workflows used in the SQL exercises.

---

*This project bridges academic training and practical skills for roles in data engineering, analytics, and business intelligence.*