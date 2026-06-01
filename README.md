#  Pharmacy Management System
A MySQL-based database project that simulates how a real pharmacy manages doctors, patients, prescriptions, medicines, sales, and inventory.
The goal of this project was to design a well-structured relational database and implement real-world database features such as triggers, stored procedures, constraints, and analytical reporting.

---

## What This Project Covers
* Normalized schema design to minimize redundancy
* Primary and foreign key relationships
* Cascading updates and deletes
* Triggers for automated inventory tracking
* Stored procedures for business operations
* Complex SQL queries for reporting and analysis
* CSV-based sample dataset for testing

---

## Database Overview
The system consists of 8 connected tables:
* **Doctors** – doctor details and specializations
* **Patients** – patient information and demographics
* **Medicines** – medicine inventory, pricing, and expiry tracking
* **Prescriptions** – doctor-patient prescription records
* **Prescription Details** – medicines included in each prescription
* **Sales** – medicine purchase transactions
* **Restock Alerts** – low-stock and inventory notifications
* **Suppliers** – supplier details linked to medicines

---

## Key Features

### Inventory Automation
A trigger automatically:
* Updates medicine stock after a sale
* Generates a restock alert when stock falls below the threshold

### Stored Procedures
* **Generate Bill** – calculates a patient's total purchase amount
* **Patient List** – returns patients treated by a specific doctor
* **Sales Summary** – generates category-wise sales reports for a selected date range

### Data Analysis
The project includes 17 business-focused SQL queries such as:
* Low-stock medicines
* Expired medicines
* Top-selling medicines
* Revenue by medicine
* Doctor performance analysis
* Prescription trends
* Medicines prescribed but never sold
* Patients purchasing medicines outside prescriptions

---

## Dataset
The database is populated with realistic sample data:

| Table                | Records |
| -------------------- | ------- |
| Doctors              | 500     |
| Patients             | 1,000   |
| Medicines            | 1,000   |
| Prescriptions        | 1,000   |
| Prescription Details | 1,500   |
| Sales                | 1,000   |
| Restock Alerts       | 300     |
| Suppliers            | 200     |

---

##  Tech Stack
* MySQL 8.0
* SQL (DDL, DML, Stored Procedures, Triggers)
* MySQL Workbench

---

##  Getting Started

### 1. Run the SQL Script
Open `Pharmacy_Management_System.sql` in MySQL Workbench and run it to create the database and all tables.

### 2. Import Sample Data
Import the CSV files from the `data/` folder into their respective tables using MySQL Workbench or `LOAD DATA INFILE`.

> **Important:** Import in this order to respect foreign key constraints:
> `medicines → doctors → patients → prescription → prescription_details → sales → restock_alerts → suppliers`

### 3. Explore Queries
Run the analytical queries included in the SQL script to generate reports and insights from the database.
