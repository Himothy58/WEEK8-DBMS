-- Library Management System Database Schema
-- Created for comprehensive library operations management

-- Create database
CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

-- Drop tables if they exist (for clean setup)
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS book_copies;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS staff;

-- 1. Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Publishers Table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(200) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Authors Table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR(100),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_death_after_birth CHECK (death_date IS NULL OR death_date > birth_date)
);

-- 4. Books Table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(300) NOT NULL,
    subtitle VARCHAR(300),
    publication_year YEAR,
    edition VARCHAR(50),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    category_id INT,
    publisher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CONSTRAINT chk_pages_positive CHECK (pages > 0),
    CONSTRAINT chk_publication_year CHECK (publication_year &lt;= YEAR(CURDATE()))
);

-- 5. Book_Authors Junction Table (Many-to-Many relationship)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    author_role ENUM('Primary Author', 'Co-Author', 'Editor', 'Translator') DEFAULT 'Primary Author',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- 6. Book_Copies Table (Physical copies of books)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number VARCHAR(50) NOT NULL,
    condition_status ENUM('Excellent', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    location VARCHAR(100),
    acquisition_date DATE DEFAULT (CURDATE()),
    price DECIMAL(10,2),
    status ENUM('Available', 'Borrowed', 'Reserved', 'Maintenance', 'Lost') DEFAULT 'Available',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    UNIQUE KEY unique_book_copy (book_id, copy_number)
);

-- 7. Members Table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    member_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    membership_date DATE DEFAULT (CURDATE()),
    membership_type ENUM('Student', 'Faculty', 'Staff', 'Public', 'Senior') DEFAULT 'Public',
    status ENUM('Active', 'Suspended', 'Expired', 'Blocked') DEFAULT 'Active',
    max_books_allowed INT DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_max_books CHECK (max_books_allowed > 0 AND max_books_allowed &lt;= 20),
    CONSTRAINT chk_membership_date CHECK (membership_date &lt;= CURDATE())
);

-- 8. Staff Table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(100),
    department VARCHAR(100),
    hire_date DATE DEFAULT (CURDATE()),
    salary DECIMAL(10,2),
    status ENUM('Active', 'Inactive', 'On Leave') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 9. Loans Table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    staff_id INT,
    loan_date DATE DEFAULT (CURDATE()),
    due_date DATE NOT NULL,
    return_date DATE,
    renewal_count INT DEFAULT 0,
    fine_amount DECIMAL(8,2) DEFAULT 0.00,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CONSTRAINT chk_due_after_loan CHECK (due_date > loan_date),
    CONSTRAINT chk_return_after_loan CHECK (return_date IS NULL OR return_date >= loan_date),
    CONSTRAINT chk_renewal_count CHECK (renewal_count >= 0 AND renewal_count &lt;= 5),
    CONSTRAINT chk_fine_amount CHECK (fine_amount >= 0)
);

-- Create indexes for better performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_members_number ON members(member_number);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_copy ON loans(copy_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_book_copies_status ON book_copies(status);
CREATE INDEX idx_authors_name ON authors(last_name, first_name);

-- Insert sample data for testing

-- Categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Fictional literature including novels and short stories'),
('Non-Fiction', 'Factual books including biographies, history, and science'),
('Science', 'Scientific literature and research'),
('Technology', 'Computer science, engineering, and technology books'),
('History', 'Historical books and documentaries'),
('Biography', 'Life stories of notable people'),
('Children', 'Books for children and young adults'),
('Reference', 'Dictionaries, encyclopedias, and reference materials');

-- Publishers
INSERT INTO publishers (publisher_name, address, phone, email, established_year) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 1927),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 1989),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 1924),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 1843);

-- Authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography) VALUES
('George', 'Orwell', '1903-06-25', 'British', 'English novelist and journalist known for Animal Farm and 1984'),
('Jane', 'Austen', '1775-12-16', 'British', 'English novelist known for Pride and Prejudice and Sense and Sensibility'),
('Mark', 'Twain', '1835-11-30', 'American', 'American writer known for The Adventures of Tom Sawyer and Adventures of Huckleberry Finn'),
('Agatha', 'Christie', '1890-09-15', 'British', 'English writer known for detective novels featuring Hercule Poirot and Miss Marple');

-- Books
INSERT INTO books (isbn, title, publication_year, category_id, publisher_id, pages, description) VALUES
('978-0-452-28423-4', '1984', 1949, 1, 1, 328, 'Dystopian social science fiction novel'),
('978-0-14-143951-8', 'Pride and Prejudice', 1813, 1, 1, 432, 'Romantic novel of manners'),
('978-0-486-40077-6', 'The Adventures of Tom Sawyer', 1876, 7, 2, 274, 'Coming-of-age story set in Missouri'),
('978-0-06-207348-4', 'Murder on the Orient Express', 1934, 1, 2, 256, 'Detective novel featuring Hercule Poirot');

-- Book Authors relationships
INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(1, 1, 'Primary Author'),
(2, 2, 'Primary Author'),
(3, 3, 'Primary Author'),
(4, 4, 'Primary Author');

-- Book Copies
INSERT INTO book_copies (book_id, copy_number, condition_status, location, price) VALUES
(1, 'COPY-001', 'Excellent', 'Section A, Shelf 1', 15.99),
(1, 'COPY-002', 'Good', 'Section A, Shelf 1', 15.99),
(2, 'COPY-003', 'Excellent', 'Section B, Shelf 3', 12.99),
(3, 'COPY-004', 'Good', 'Section C, Shelf 2', 10.99),
(4, 'COPY-005', 'Excellent', 'Section A, Shelf 5', 14.99);

-- Members
INSERT INTO members (member_number, first_name, last_name, email, phone, membership_type) VALUES
('MEM001', 'John', 'Smith', 'john.smith@email.com', '555-0101', 'Public'),
('MEM002', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '555-0102', 'Student'),
('MEM003', 'Michael', 'Brown', 'michael.brown@email.com', '555-0103', 'Faculty'),
('MEM004', 'Emily', 'Davis', 'emily.davis@email.com', '555-0104', 'Public');

-- Staff
INSERT INTO staff (employee_id, first_name, last_name, email, phone, position, department) VALUES
('EMP001', 'Alice', 'Wilson', 'alice.wilson@library.com', '555-0201', 'Librarian', 'Circulation'),
('EMP002', 'Bob', 'Martinez', 'bob.martinez@library.com', '555-0202', 'Assistant Librarian', 'Reference'),
('EMP003', 'Carol', 'Anderson', 'carol.anderson@library.com', '555-0203', 'Library Manager', 'Administration');

-- Sample Loans
INSERT INTO loans (member_id, copy_id, staff_id, loan_date, due_date) VALUES
(1, 1, 1, '2024-01-15', '2024-02-15'),
(2, 3, 1, '2024-01-20', '2024-02-20'),
(3, 4, 2, '2024-01-25', '2024-02-25');

-- Display success message
SELECT 'Library Management System Database Created Successfully!' AS Status;