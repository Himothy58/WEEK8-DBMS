# 📚 Library Management System

## 📝 Description
The **Library Management System** is a relational database designed to streamline the management of books, authors, publishers, library members, and staff.
It ensures efficient book lending operations, tracking availability, and maintaining historical records of borrowed and returned books.

## 🚀 How to Run / Setup the Project

### Prerequisites
Before you begin, ensure you have:
- **MySQL Server** installed and running.
- A database management tool like **MySQL Workbench**, **phpMyAdmin**, or any SQL-compatible editor.

### Steps to Import the Database
1. **Clone the Repository** (if applicable):
   
   git clone https://github.com/Himothy58/WEEK8-DBMS.git
   cd WEEK8-DBMS
   
# Open MySQL and Create the Database:
CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

### Import the SQL Schema:
Using MySQL Workbench:
- Open the Administration tab and navigate to the Data Import section.
- Select the .sql file containing the database schema.
- Click Execute to import the database.
# Using Command Line:
mysql -u root -p library_management < library_management.sql

## Verify the Setup:
SHOW TABLES;

### USAGE
- This database schema is optimized for tracking book loans, member registrations, and staff management

- The schema supports categories, publishers, and book authors, allowing flexible book inventory management

- Future extensions could include loan tracking, fine calculations, and automated reminders for due books.
