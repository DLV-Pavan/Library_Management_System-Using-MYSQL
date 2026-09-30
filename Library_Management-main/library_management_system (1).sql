/* ---------------------------------------------------------------
   Project      : Library Management System (MySQL)
   Developed by : Battula Koteswararao
   Database     : MySQL 8.0.31+ (INTERSECT / EXCEPT need this version)
   Concepts     : DDL, DML, DQL, Joins, Subqueries, Correlated Subqueries,
                 Set Operators, Views, Procedures, Function, Trigger, TCL
   Run          : mysql -u root -p < library_management_system.sql
   --------------------------------------------------------------- */

-- ===== 1. DDL (Data Definition Language) =====
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE authors (
    author_id   INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL,
    country     VARCHAR(50)
);

CREATE TABLE books (
    book_id          INT AUTO_INCREMENT PRIMARY KEY,
    title            VARCHAR(150) NOT NULL,
    author_id        INT NOT NULL,
    category_id      INT NOT NULL,
    price            DECIMAL(8,2) NOT NULL,
    published_year   INT,
    total_copies     INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_books_author   FOREIGN KEY (author_id)   REFERENCES authors(author_id),
    CONSTRAINT fk_books_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT chk_price  CHECK (price > 0),
    CONSTRAINT chk_copies CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

CREATE TABLE members (
    member_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15),
    join_date       DATE NOT NULL,
    membership_type ENUM('Student','Staff','Public') NOT NULL DEFAULT 'Student',
    status          ENUM('Active','Inactive') NOT NULL DEFAULT 'Active'
);

CREATE TABLE issues (
    issue_id    INT AUTO_INCREMENT PRIMARY KEY,
    book_id     INT NOT NULL,
    member_id   INT NOT NULL,
    issue_date  DATE NOT NULL,
    due_date    DATE NOT NULL,
    return_date DATE NULL,
    status      ENUM('Issued','Returned') NOT NULL DEFAULT 'Issued',
    CONSTRAINT fk_issues_book   FOREIGN KEY (book_id)   REFERENCES books(book_id),
    CONSTRAINT fk_issues_member FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE fines (
    fine_id  INT AUTO_INCREMENT PRIMARY KEY,
    issue_id INT NOT NULL UNIQUE,
    amount   DECIMAL(8,2) NOT NULL,
    paid     ENUM('Yes','No') NOT NULL DEFAULT 'No',
    CONSTRAINT fk_fines_issue FOREIGN KEY (issue_id) REFERENCES issues(issue_id)
);

CREATE TABLE archived_members (
    archive_id  INT AUTO_INCREMENT PRIMARY KEY,
    member_id   INT,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL,
    archived_on DATE NOT NULL
);

ALTER TABLE members ADD COLUMN city VARCHAR(50) AFTER phone;
ALTER TABLE members MODIFY COLUMN phone VARCHAR(20);
ALTER TABLE authors ADD COLUMN birth_year INT;
ALTER TABLE authors DROP COLUMN birth_year;
CREATE INDEX idx_books_title  ON books(title);
CREATE INDEX idx_issues_dates ON issues(issue_date, due_date);

CREATE TABLE temp_log (log_id INT AUTO_INCREMENT PRIMARY KEY, note VARCHAR(100));
INSERT INTO temp_log (note) VALUES ('test 1'), ('test 2');
TRUNCATE TABLE temp_log;
DROP TABLE temp_log;

-- ===== 2. DML (Data Manipulation Language) =====
INSERT INTO categories (category_name) VALUES
('Programming'), ('Databases'), ('Biography'), ('Fiction'), ('Computer Science'), ('History');

INSERT INTO authors (author_name, country) VALUES
('Herbert Schildt',        'USA'),
('Kathy Sierra',           'USA'),
('Abraham Silberschatz',   'USA'),
('Seyed Tahaghoghi',       'Australia'),
('A.P.J. Abdul Kalam',     'India'),
('Paulo Coelho',           'Brazil'),
('Robert C. Martin',       'USA'),
('Craig Walls',            'USA'),
('Bill Karwin',            'USA'),
('Thomas H. Cormen',       'USA'),
('Chetan Bhagat',          'India');

INSERT INTO books (title, author_id, category_id, price, published_year, total_copies, available_copies) VALUES
('Java: The Complete Reference', 1, 1,  799.00, 2022, 5, 4),
('Head First Java',              2, 1,  650.00, 2005, 4, 4),
('Database System Concepts',     3, 2,  899.00, 2019, 3, 2),
('Learning MySQL',               4, 2,  550.00, 2007, 3, 2),
('Wings of Fire',                5, 3,  300.00, 1999, 4, 3),
('Ignited Minds',                5, 3,  280.00, 2002, 2, 2),
('The Alchemist',                6, 4,  250.00, 1988, 5, 4),
('Clean Code',                   7, 1,  720.00, 2008, 3, 2),
('Spring in Action',             8, 1,  780.00, 2022, 2, 1),
('SQL Antipatterns',             9, 2,  600.00, 2010, 2, 2),
('Eleven Minutes',               6, 4,  270.00, 2003, 3, 3),
('Introduction to Algorithms',  10, 5, 1200.00, 2009, 2, 2);

INSERT INTO members (full_name, email, phone, city, join_date, membership_type, status) VALUES
('Ravi Kumar',    'ravi.kumar@mail.com',    '9000000001', 'Rajamahendravaram', '2026-01-10', 'Student', 'Active'),
('Sneha Reddy',   'sneha.reddy@mail.com',   '9000000002', 'Hyderabad',         '2026-02-15', 'Student', 'Active'),
('Anil Varma',    'anil.varma@mail.com',    '9000000003', 'Kakinada',          '2026-03-05', 'Staff',   'Active'),
('Priya Sharma',  'priya.sharma@mail.com',  '9000000004', 'Vijayawada',        '2026-03-20', 'Student', 'Active'),
('Kiran Babu',    'kiran.babu@mail.com',    '9000000005', 'Ongole',            '2026-04-11', 'Public',  'Active'),
('Lakshmi Devi',  'lakshmi.devi@mail.com',  '9000000006', 'Guntur',            '2026-05-02', 'Staff',   'Active'),
('Suresh Naidu',  'suresh.naidu@mail.com',  '9000000007', 'Rajamahendravaram', '2026-05-18', 'Student', 'Active'),
('Meena Kumari',  'meena.kumari@mail.com',  '9000000008', 'Vizag',             '2026-06-01', 'Public',  'Inactive');

INSERT INTO issues (book_id, member_id, issue_date, due_date, return_date, status) VALUES
(1,  1, '2026-08-01', '2026-08-15', '2026-08-14', 'Returned'),
(3,  1, '2026-09-01', '2026-09-15', NULL,         'Issued'),
(2,  2, '2026-08-10', '2026-08-24', '2026-08-30', 'Returned'),
(5,  2, '2026-09-10', '2026-09-24', NULL,         'Issued'),
(7,  3, '2026-09-15', '2026-09-29', NULL,         'Issued'),
(8,  4, '2026-09-20', '2026-10-04', NULL,         'Issued'),
(1,  4, '2026-07-01', '2026-07-15', '2026-07-20', 'Returned'),
(4,  5, '2026-09-25', '2026-10-09', NULL,         'Issued'),
(12, 5, '2026-08-05', '2026-08-19', '2026-08-18', 'Returned'),
(9,  6, '2026-09-27', '2026-10-11', NULL,         'Issued'),
(7,  6, '2026-08-20', '2026-09-03', '2026-09-01', 'Returned'),
(1,  7, '2026-09-05', '2026-09-19', NULL,         'Issued');

INSERT INTO fines (issue_id, amount, paid) VALUES
(3, 12.00, 'Yes'),
(7, 10.00, 'No');

INSERT INTO archived_members (member_id, full_name, email, archived_on) VALUES
(101, 'Rahul Verma',  'rahul.verma@mail.com',  '2025-12-01'),
(102, 'Sneha Reddy',  'sneha.reddy@mail.com',  '2025-11-15'),
(103, 'Divya Rao',    'divya.rao@mail.com',    '2025-10-20');

UPDATE books   SET price = price * 1.10 WHERE published_year >= 2022;
UPDATE members SET membership_type = 'Staff' WHERE member_id = 5;
UPDATE members SET status = 'Active' WHERE member_id = 8;
UPDATE books   SET price = ROUND(price, 2);

INSERT INTO members (full_name, email, join_date) VALUES ('Dummy User', 'dummy@mail.com', CURDATE());
DELETE FROM members WHERE email = 'dummy@mail.com';

-- ===== 3. DQL (Data Query Language) =====
SELECT title, price FROM books WHERE price BETWEEN 300 AND 800 ORDER BY price DESC LIMIT 5;

SELECT title FROM books WHERE title LIKE '%Java%';
SELECT DISTINCT membership_type FROM members;
SELECT full_name, city FROM members WHERE city IN ('Hyderabad', 'Ongole', 'Guntur');

SELECT category_id,
       COUNT(*)              AS total_titles,
       SUM(total_copies)     AS total_copies,
       ROUND(AVG(price), 2)  AS avg_price
FROM books
GROUP BY category_id
HAVING COUNT(*) >= 2
ORDER BY total_titles DESC;

SELECT title, price,
       CASE
           WHEN price < 300  THEN 'Budget'
           WHEN price <= 700 THEN 'Standard'
           ELSE 'Premium'
       END AS price_band
FROM books
ORDER BY price;

SELECT issue_id, member_id, due_date, DATEDIFF(CURDATE(), due_date) AS days_late
FROM issues
WHERE status = 'Issued' AND due_date < CURDATE();

-- ===== 4. JOINS =====
-- 4.1 INNER JOIN : book catalog
SELECT b.book_id, b.title, a.author_name, c.category_name, b.price
FROM books b
INNER JOIN authors    a ON b.author_id   = a.author_id
INNER JOIN categories c ON b.category_id = c.category_id
ORDER BY c.category_name, b.title;

-- 4.2 LEFT JOIN : authors who have no books in the library
SELECT a.author_name, b.title
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
WHERE b.book_id IS NULL;

-- 4.3 RIGHT JOIN : every category with its book count (including empty ones)
SELECT c.category_name, COUNT(b.book_id) AS books_count
FROM books b
RIGHT JOIN categories c ON b.category_id = c.category_id
GROUP BY c.category_id, c.category_name;

-- 4.4 SELF JOIN : pairs of books written by the same author
SELECT a.author_name, b1.title AS book_1, b2.title AS book_2
FROM books b1
JOIN books b2   ON b1.author_id = b2.author_id AND b1.book_id < b2.book_id
JOIN authors a  ON a.author_id  = b1.author_id;

-- 4.5 CROSS JOIN : every membership type with every category (report skeleton)
SELECT t.membership_type, c.category_name
FROM (SELECT DISTINCT membership_type FROM members) t
CROSS JOIN categories c
ORDER BY t.membership_type, c.category_name;

-- 4.6 Multi-table JOIN : full issue report with fines
SELECT i.issue_id, m.full_name, b.title, i.issue_date, i.due_date, i.return_date,
       IFNULL(f.amount, 0) AS fine
FROM issues i
JOIN members m    ON i.member_id = m.member_id
JOIN books b      ON i.book_id   = b.book_id
LEFT JOIN fines f ON f.issue_id  = i.issue_id
ORDER BY i.issue_id;

-- 4.7 FULL OUTER JOIN (MySQL has none, so emulate: LEFT JOIN UNION RIGHT JOIN)
SELECT a.author_name, b.title
FROM authors a LEFT JOIN books b ON a.author_id = b.author_id
UNION
SELECT a.author_name, b.title
FROM authors a RIGHT JOIN books b ON a.author_id = b.author_id;

-- ===== 5. SUBQUERIES =====
-- 5.1 Scalar subquery : books costlier than the average price
SELECT title, price FROM books
WHERE price > (SELECT AVG(price) FROM books);

-- 5.2 IN subquery : members who have borrowed at least one Programming book
SELECT full_name FROM members
WHERE member_id IN (
    SELECT i.member_id
    FROM issues i
    JOIN books b ON i.book_id = b.book_id
    JOIN categories c ON b.category_id = c.category_id
    WHERE c.category_name = 'Programming'
);

-- 5.3 NOT IN subquery : books that were never issued
SELECT title FROM books
WHERE book_id NOT IN (SELECT DISTINCT book_id FROM issues);

-- 5.4 Subquery in FROM (derived table) : most active borrowers
SELECT m.full_name, t.total_issues
FROM (SELECT member_id, COUNT(*) AS total_issues FROM issues GROUP BY member_id) t
JOIN members m ON m.member_id = t.member_id
WHERE t.total_issues = (SELECT MAX(cnt) FROM (SELECT COUNT(*) AS cnt FROM issues GROUP BY member_id) x);

-- 5.5 ALL / ANY : the most expensive book
SELECT title, price FROM books
WHERE price >= ALL (SELECT price FROM books);

-- 5.6 Second highest priced book
SELECT title, price FROM books
WHERE price = (SELECT MAX(price) FROM books WHERE price < (SELECT MAX(price) FROM books));

-- ===== 6. CORRELATED SUBQUERIES (inner query depends on the outer row) =====
-- 6.1 Books priced above the average of THEIR OWN category
SELECT b1.title, b1.price, b1.category_id
FROM books b1
WHERE b1.price > (SELECT AVG(b2.price) FROM books b2 WHERE b2.category_id = b1.category_id);

-- 6.2 Latest issue made by each member
SELECT i1.member_id, i1.book_id, i1.issue_date
FROM issues i1
WHERE i1.issue_date = (SELECT MAX(i2.issue_date) FROM issues i2 WHERE i2.member_id = i1.member_id);

-- 6.3 EXISTS : members who currently hold an unreturned book
SELECT m.full_name FROM members m
WHERE EXISTS (SELECT 1 FROM issues i WHERE i.member_id = m.member_id AND i.status = 'Issued');

-- 6.4 NOT EXISTS : members who have never borrowed anything
SELECT m.full_name FROM members m
WHERE NOT EXISTS (SELECT 1 FROM issues i WHERE i.member_id = m.member_id);

-- 6.5 Correlated subquery in SELECT list : times each book was issued
SELECT b.title,
       (SELECT COUNT(*) FROM issues i WHERE i.book_id = b.book_id) AS times_issued
FROM books b
ORDER BY times_issued DESC;

-- 6.6 Members who paid more fine than the average fine of their membership type
SELECT m.full_name, m.membership_type, SUM(f.amount) AS total_fine
FROM members m
JOIN issues i ON i.member_id = m.member_id
JOIN fines f  ON f.issue_id  = i.issue_id
GROUP BY m.member_id, m.full_name, m.membership_type
HAVING SUM(f.amount) > (SELECT AVG(f2.amount)
                        FROM fines f2
                        JOIN issues i2  ON i2.issue_id  = f2.issue_id
                        JOIN members m2 ON m2.member_id = i2.member_id
                        WHERE m2.membership_type = m.membership_type);

-- ===== 7. SET OPERATORS =====
-- 7.1 UNION : all distinct people (current + archived) by name and email
SELECT full_name, email FROM members
UNION
SELECT full_name, email FROM archived_members;

-- 7.2 UNION ALL : keeps duplicates (Sneha appears twice)
SELECT full_name, email FROM members
UNION ALL
SELECT full_name, email FROM archived_members;

-- 7.3 INTERSECT : people present in BOTH current and archived lists
SELECT email FROM members
INTERSECT
SELECT email FROM archived_members;

-- 7.4 EXCEPT : members who never issued a book
SELECT member_id FROM members
EXCEPT
SELECT member_id FROM issues;

-- 7.5 INTERSECT : members who borrowed BOTH Programming (1) and Databases (2) books
SELECT i.member_id FROM issues i JOIN books b ON i.book_id = b.book_id WHERE b.category_id = 1
INTERSECT
SELECT i.member_id FROM issues i JOIN books b ON i.book_id = b.book_id WHERE b.category_id = 2;

-- 7.6 EXCEPT : categories that have no books
SELECT category_name FROM categories
EXCEPT
SELECT c.category_name FROM categories c JOIN books b ON b.category_id = c.category_id;

-- ===== 8. VIEWS =====
-- 8.1 Book catalog view (hides the joins)
CREATE OR REPLACE VIEW vw_book_catalog AS
SELECT b.book_id, b.title, a.author_name, c.category_name,
       b.price, b.available_copies, b.total_copies
FROM books b
JOIN authors a    ON b.author_id   = a.author_id
JOIN categories c ON b.category_id = c.category_id;

-- 8.2 Currently issued books
CREATE OR REPLACE VIEW vw_active_issues AS
SELECT i.issue_id, m.member_id, m.full_name, b.title, i.issue_date, i.due_date,
       GREATEST(DATEDIFF(CURDATE(), i.due_date), 0) AS days_overdue
FROM issues i
JOIN members m ON i.member_id = m.member_id
JOIN books b   ON i.book_id   = b.book_id
WHERE i.status = 'Issued';

-- 8.3 View built on another view : overdue books with estimated fine (Rs. 2 per day)
CREATE OR REPLACE VIEW vw_overdue_books AS
SELECT issue_id, full_name, title, due_date, days_overdue, days_overdue * 2 AS estimated_fine
FROM vw_active_issues
WHERE days_overdue > 0;

-- 8.4 Member activity summary (aggregate view)
CREATE OR REPLACE VIEW vw_member_summary AS
SELECT m.member_id, m.full_name, m.membership_type,
       COUNT(DISTINCT i.issue_id)  AS total_issues,
       SUM(i.status = 'Issued')    AS books_on_hand,
       IFNULL(SUM(f.amount), 0)    AS total_fines
FROM members m
LEFT JOIN issues i ON i.member_id = m.member_id
LEFT JOIN fines f  ON f.issue_id  = i.issue_id
GROUP BY m.member_id, m.full_name, m.membership_type;

-- 8.5 Updatable view with WITH CHECK OPTION
CREATE OR REPLACE VIEW vw_active_members AS
SELECT member_id, full_name, email, phone, membership_type, status
FROM members
WHERE status = 'Active'
WITH CHECK OPTION;

-- Using the views
SELECT * FROM vw_book_catalog WHERE category_name = 'Programming';
SELECT * FROM vw_active_issues;
SELECT * FROM vw_overdue_books ORDER BY days_overdue DESC;
SELECT * FROM vw_member_summary ORDER BY total_issues DESC;
UPDATE vw_active_members SET phone = '9111111111' WHERE member_id = 1;
-- UPDATE vw_active_members SET status = 'Inactive' WHERE member_id = 1; -- would FAIL (check option)

-- ===== 9. FUNCTION, STORED PROCEDURES and TRIGGER =====
DELIMITER $$

-- 9.1 Function : fine = Rs. 2 for every late day
CREATE FUNCTION fn_calc_fine(p_due DATE, p_return DATE)
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    RETURN GREATEST(DATEDIFF(p_return, p_due), 0) * 2;
END$$

-- 9.2 Procedure : register a new member (IN + OUT parameters, SIGNAL for errors)
CREATE PROCEDURE sp_add_member(
    IN  p_name  VARCHAR(100),
    IN  p_email VARCHAR(100),
    IN  p_phone VARCHAR(20),
    IN  p_type  VARCHAR(10),
    OUT p_new_id INT
)
BEGIN
    IF EXISTS (SELECT 1 FROM members WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already registered';
    END IF;

    INSERT INTO members (full_name, email, phone, join_date, membership_type)
    VALUES (p_name, p_email, p_phone, CURDATE(), p_type);

    SET p_new_id = LAST_INSERT_ID();
END$$

-- 9.3 Procedure : issue a book (business rules + TRANSACTION + error handler)
CREATE PROCEDURE sp_issue_book(
    IN  p_book_id   INT,
    IN  p_member_id INT,
    OUT p_message   VARCHAR(100)
)
proc: BEGIN
    DECLARE v_status    VARCHAR(10);
    DECLARE v_available INT DEFAULT 0;
    DECLARE v_loans     INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Error: transaction rolled back';
    END;

    SELECT status INTO v_status FROM members WHERE member_id = p_member_id;
    IF v_status IS NULL THEN
        SET p_message = 'Member not found';
        LEAVE proc;
    END IF;
    IF v_status <> 'Active' THEN
        SET p_message = 'Member is inactive';
        LEAVE proc;
    END IF;

    SELECT COUNT(*) INTO v_loans FROM issues
    WHERE member_id = p_member_id AND status = 'Issued';
    IF v_loans >= 3 THEN
        SET p_message = 'Limit reached: max 3 books at a time';
        LEAVE proc;
    END IF;

    START TRANSACTION;

    SELECT available_copies INTO v_available
    FROM books WHERE book_id = p_book_id FOR UPDATE;      -- lock the row

    IF v_available <= 0 THEN
        ROLLBACK;
        SET p_message = 'Book not available';
        LEAVE proc;
    END IF;

    INSERT INTO issues (book_id, member_id, issue_date, due_date)
    VALUES (p_book_id, p_member_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

    UPDATE books SET available_copies = available_copies - 1 WHERE book_id = p_book_id;

    COMMIT;
    SET p_message = 'Book issued successfully';
END$$

-- 9.4 Procedure : return a book, calculate fine, update stock (TRANSACTION)
CREATE PROCEDURE sp_return_book(
    IN  p_issue_id INT,
    OUT p_fine     DECIMAL(8,2)      -- -1 means invalid / already returned
)
proc: BEGIN
    DECLARE v_book_id INT;
    DECLARE v_due     DATE;
    DECLARE v_status  VARCHAR(10);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_fine = -1;
    END;

    SET p_fine = 0;
    SELECT book_id, due_date, status INTO v_book_id, v_due, v_status
    FROM issues WHERE issue_id = p_issue_id;

    IF v_status IS NULL OR v_status = 'Returned' THEN
        SET p_fine = -1;
        LEAVE proc;
    END IF;

    START TRANSACTION;
        SET p_fine = fn_calc_fine(v_due, CURDATE());

        UPDATE issues SET return_date = CURDATE(), status = 'Returned'
        WHERE issue_id = p_issue_id;

        UPDATE books SET available_copies = available_copies + 1
        WHERE book_id = v_book_id;

        IF p_fine > 0 THEN
            INSERT INTO fines (issue_id, amount) VALUES (p_issue_id, p_fine);
        END IF;
    COMMIT;
END$$

-- 9.5 Procedure : full borrowing history of a member (returns a result set)
CREATE PROCEDURE sp_member_history(IN p_member_id INT)
BEGIN
    SELECT i.issue_id, b.title, i.issue_date, i.due_date, i.return_date, i.status,
           IFNULL(f.amount, 0) AS fine
    FROM issues i
    JOIN books b      ON b.book_id  = i.book_id
    LEFT JOIN fines f ON f.issue_id = i.issue_id
    WHERE i.member_id = p_member_id
    ORDER BY i.issue_date DESC;
END$$

-- 9.6 Trigger : archive a member automatically when the row is deleted
CREATE TRIGGER trg_archive_member
BEFORE DELETE ON members
FOR EACH ROW
BEGIN
    INSERT INTO archived_members (member_id, full_name, email, archived_on)
    VALUES (OLD.member_id, OLD.full_name, OLD.email, CURDATE());
END$$

DELIMITER ;

-- ===== 10. TCL (Transaction Control Language) =====
-- 10.1 COMMIT : make changes permanent
START TRANSACTION;
    INSERT INTO issues (book_id, member_id, issue_date, due_date)
    VALUES (6, 3, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));
    UPDATE books SET available_copies = available_copies - 1 WHERE book_id = 6;
COMMIT;

-- 10.2 ROLLBACK : undo everything since START TRANSACTION
START TRANSACTION;
    UPDATE books SET price = 0.01 WHERE book_id = 1;
    SELECT book_id, title, price FROM books WHERE book_id = 1;
ROLLBACK;
SELECT book_id, title, price FROM books WHERE book_id = 1;

-- 10.3 SAVEPOINT : partial rollback
START TRANSACTION;
    UPDATE members SET city = 'Chennai' WHERE member_id = 1;
    SAVEPOINT after_city_update;

    UPDATE members SET status = 'Inactive' WHERE member_id = 2;
    SAVEPOINT after_status_update;

    DELETE FROM fines WHERE fine_id = 2;

    ROLLBACK TO after_status_update;
    ROLLBACK TO after_city_update;
COMMIT;

-- 10.4 Money-transfer style consistency : settle a fine and mark it paid atomically
START TRANSACTION;
    UPDATE fines SET paid = 'Yes' WHERE issue_id = 7;
    -- if any later step failed we would ROLLBACK; here everything is fine
COMMIT;

-- 10.5 autocommit control
SET autocommit = 0;
    UPDATE books SET available_copies = available_copies WHERE book_id = 2;
ROLLBACK;
SET autocommit = 1;

-- ===== 11. PROCEDURE CALL DEMO =====
-- Add a new member
CALL sp_add_member('Test Student', 'test.student@mail.com', '9222222222', 'Student', @new_id);
SELECT @new_id AS new_member_id;

-- Issue a book to the new member
CALL sp_issue_book(2, @new_id, @msg);
SELECT @msg AS result;

-- Try to issue a book with zero stock (set stock to 0 first to see the failure)
-- UPDATE books SET available_copies = 0 WHERE book_id = 6;
-- CALL sp_issue_book(6, @new_id, @msg); SELECT @msg;

-- Return an overdue loan (issue 5 was due on 2026-09-29) : fine depends on today's date
CALL sp_return_book(5, @fine);
SELECT @fine AS fine_charged;

-- Member history
CALL sp_member_history(1);

-- Trigger demo : deleting the new member archives them automatically
-- (first return their book so the foreign key allows the delete)
DELETE FROM issues WHERE member_id = @new_id;
UPDATE books SET available_copies = available_copies + 1 WHERE book_id = 2;
DELETE FROM members WHERE member_id = @new_id;
SELECT * FROM archived_members ORDER BY archive_id DESC LIMIT 3;

-- Final check using views
SELECT * FROM vw_member_summary;
SELECT * FROM vw_overdue_books;
