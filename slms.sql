-- Project: Smart Library Management System
-- Author: NAGARAMPALLI SARVAN KUMAR

-- =========================================================
-- Step 1: Create Database and Tables
-- =========================================================
DROP DATABASE IF EXISTS SmartLibraryDB;
CREATE DATABASE SmartLibraryDB;
USE SmartLibraryDB;

-- Admin Table
CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    admin_name VARCHAR(100),
    password VARCHAR(100)
);

-- Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100),
    course VARCHAR(50),
    year INT
);

-- Books Table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(50),
    total_copies INT,
    available_copies INT
);

-- Issued Books Table
CREATE TABLE issued_books (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    book_id INT,
    issue_date DATE,
    due_date DATE,
    return_date DATE,
    fine DECIMAL(8,2),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Transaction Log Table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    ref_id INT,
    date_time DATETIME
);

-- =========================================================
-- Step 2: Stored Procedures
-- =========================================================

DELIMITER //

-- Admin Procedures
CREATE PROCEDURE add_admin(IN p_name VARCHAR(100), IN p_pass VARCHAR(100))
BEGIN
    INSERT INTO admins(admin_name, password) VALUES(p_name, p_pass);
    INSERT INTO transactions(type, ref_id, date_time)
    VALUES('ADD_ADMIN', LAST_INSERT_ID(), NOW());
END //

CREATE PROCEDURE view_admins()
BEGIN
    SELECT * FROM admins;
END //

CREATE PROCEDURE check_admin_login(IN p_name VARCHAR(100), IN p_pass VARCHAR(100))
BEGIN
    IF EXISTS(SELECT * FROM admins WHERE admin_name=p_name AND password=p_pass) THEN
        SELECT 'Login Successful' AS Message;
    ELSE
        SELECT 'Invalid Credentials' AS Message;
    END IF;
END //

CREATE PROCEDURE delete_admin(IN p_id INT)
BEGIN
    DELETE FROM admins WHERE admin_id=p_id;
END //

CREATE PROCEDURE update_admin_pass(IN p_id INT, IN new_pass VARCHAR(100))
BEGIN
    UPDATE admins SET password=new_pass WHERE admin_id=p_id;
END //

-- 2️⃣ Student Procedures
CREATE PROCEDURE add_student(IN p_name VARCHAR(100), IN p_course VARCHAR(50), IN p_year INT)
BEGIN
    INSERT INTO students(student_name, course, year) VALUES(p_name, p_course, p_year);
END //

CREATE PROCEDURE view_students()
BEGIN
    SELECT * FROM students;
END //

CREATE PROCEDURE search_student(IN keyword VARCHAR(100))
BEGIN
    SELECT * FROM students WHERE student_name LIKE CONCAT('%', keyword, '%');
END //

CREATE PROCEDURE update_student(IN sid INT, IN cname VARCHAR(100), IN ccourse VARCHAR(50), IN cyear INT)
BEGIN
    UPDATE students SET student_name=cname, course=ccourse, year=cyear WHERE student_id=sid;
END //

CREATE PROCEDURE delete_student(IN sid INT)
BEGIN
    DELETE FROM students WHERE student_id=sid;
END //

CREATE PROCEDURE count_students()
BEGIN
    SELECT COUNT(*) AS Total_Students FROM students;
END //

-- Book Procedures
CREATE PROCEDURE add_book(IN p_title VARCHAR(100), IN p_author VARCHAR(100), IN p_genre VARCHAR(50), IN p_total INT)
BEGIN
    INSERT INTO books(title, author, genre, total_copies, available_copies)
    VALUES(p_title, p_author, p_genre, p_total, p_total);
END //

CREATE PROCEDURE view_books()
BEGIN
    SELECT * FROM books;
END //

CREATE PROCEDURE update_book(IN bid INT, IN new_title VARCHAR(100), IN new_author VARCHAR(100), IN new_genre VARCHAR(50))
BEGIN
    UPDATE books SET title=new_title, author=new_author, genre=new_genre WHERE book_id=bid;
END //

CREATE PROCEDURE delete_book(IN bid INT)
BEGIN
    DELETE FROM books WHERE book_id=bid;
END //

CREATE PROCEDURE search_book_by_title(IN keyword VARCHAR(100))
BEGIN
    SELECT * FROM books WHERE title LIKE CONCAT('%', keyword, '%');
END //

CREATE PROCEDURE search_book_by_author(IN keyword VARCHAR(100))
BEGIN
    SELECT * FROM books WHERE author LIKE CONCAT('%', keyword, '%');
END //

CREATE PROCEDURE count_books()
BEGIN
    SELECT COUNT(*) AS Total_Books FROM books;
END //

CREATE PROCEDURE available_books()
BEGIN
    SELECT * FROM books WHERE available_copies > 0;
END //

-- Issue and Return Procedures
CREATE PROCEDURE issue_book(IN sid INT, IN bid INT)
BEGIN
    DECLARE available INT;
    SELECT available_copies INTO available FROM books WHERE book_id=bid;

    IF available > 0 THEN
        INSERT INTO issued_books(student_id, book_id, issue_date, due_date, fine)
        VALUES(sid, bid, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 15 DAY), 0);
        UPDATE books SET available_copies = available_copies - 1 WHERE book_id = bid;
        INSERT INTO transactions(type, ref_id, date_time) VALUES('ISSUE_BOOK', LAST_INSERT_ID(), NOW());
        SELECT 'Book Issued Successfully' AS Message;
    ELSE
        SELECT 'Book not available' AS Message;
    END IF;
END //

CREATE PROCEDURE return_book(IN iid INT)
BEGIN
    DECLARE b_id INT;
    DECLARE d DATE;
    DECLARE fine_amt DECIMAL(8,2);

    SELECT book_id, due_date INTO b_id, d FROM issued_books WHERE issue_id=iid;

    IF DATEDIFF(CURDATE(), d) > 0 THEN
        SET fine_amt = DATEDIFF(CURDATE(), d) * 10;
    ELSE
        SET fine_amt = 0;
    END IF;

    UPDATE issued_books SET return_date=CURDATE(), fine=fine_amt WHERE issue_id=iid;
    UPDATE books SET available_copies=available_copies+1 WHERE book_id=b_id;
    INSERT INTO transactions(type, ref_id, date_time) VALUES('RETURN_BOOK', iid, NOW());
END //

CREATE PROCEDURE renew_book(IN iid INT)
BEGIN
    UPDATE issued_books SET due_date = DATE_ADD(due_date, INTERVAL 7 DAY) WHERE issue_id=iid;
END //

CREATE PROCEDURE view_issued_books()
BEGIN
    SELECT i.issue_id, s.student_name, b.title, i.issue_date, i.due_date, i.return_date, i.fine
    FROM issued_books i
    JOIN students s ON i.student_id = s.student_id
    JOIN books b ON i.book_id = b.book_id;
END //

CREATE PROCEDURE overdue_books()
BEGIN
    SELECT * FROM issued_books WHERE due_date < CURDATE() AND return_date IS NULL;
END //

CREATE PROCEDURE total_fines()
BEGIN
    SELECT SUM(fine) AS Total_Fine FROM issued_books;
END //

CREATE PROCEDURE student_fines(IN sid INT)
BEGIN
    SELECT SUM(fine) AS Student_Fine FROM issued_books WHERE student_id=sid;
END //

-- Transaction Procedures
CREATE PROCEDURE view_transactions()
BEGIN
    SELECT * FROM transactions ORDER BY date_time DESC;
END //

CREATE PROCEDURE delete_transactions()
BEGIN
    DELETE FROM transactions;
END //

CREATE PROCEDURE count_transactions()
BEGIN
    SELECT COUNT(*) AS Total_Transactions FROM transactions;
END //

CREATE PROCEDURE latest_transaction()
BEGIN
    SELECT * FROM transactions ORDER BY transaction_id DESC LIMIT 1;
END //

-- 6️⃣ Reports and Utilities
CREATE PROCEDURE top_borrowed_books()
BEGIN
    SELECT b.title, COUNT(i.book_id) AS Borrow_Count
    FROM issued_books i JOIN books b ON i.book_id=b.book_id
    GROUP BY b.book_id ORDER BY Borrow_Count DESC LIMIT 5;
END //

CREATE PROCEDURE top_students()
BEGIN
    SELECT s.student_name, COUNT(i.student_id) AS Books_Borrowed
    FROM issued_books i JOIN students s ON i.student_id=s.student_id
    GROUP BY s.student_id ORDER BY Books_Borrowed DESC LIMIT 5;
END //

CREATE PROCEDURE stock_summary()
BEGIN
    SELECT genre, SUM(available_copies) AS Available FROM books GROUP BY genre;
END //

CREATE PROCEDURE system_summary()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM students) AS Students,
        (SELECT COUNT(*) FROM books) AS Books,
        (SELECT COUNT(*) FROM issued_books WHERE return_date IS NULL) AS Active_Issues,
        (SELECT SUM(fine) FROM issued_books) AS Total_Fines;
END //

DELIMITER ;

-- =========================================================
-- Step 3: Test Queries (End User)
-- =========================================================
CALL add_admin('Sarvan', 'admin123');
CALL add_student('Sahil', 'CSE', 1);
CALL add_book('DBMS Concepts', 'Korth', 'Database', 5);
CALL issue_book(1,1);
CALL view_issued_books();
CALL return_book(1);
CALL system_summary();