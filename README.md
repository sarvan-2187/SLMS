# Smart Library Management System (SLMS)

A comprehensive MySQL-based library management system with 30+ stored procedures for complete library operations including student management, book inventory, issue/return processes, and advanced analytics.

## Features

### Core Functionality
- **Admin Management**: Secure authentication and multi-admin support
- **Student Records**: Complete CRUD operations with search capabilities
- **Book Inventory**: Track books with author, genre, and availability status
- **Issue & Return System**: Automated due date calculation and fine management
- **Transaction Logging**: Comprehensive audit trail of all system activities

### Advanced Features
- **Analytics Dashboard**: System summary with key metrics
- **Smart Search**: Search by title, author, or student name
- **Automated Fines**: ₹10/day late fee calculation
- **Reports**: Top borrowed books and most active students
- **Book Renewal**: Extend due dates by 7 days
- **Stock Management**: Genre-based inventory grouping

## Quick Start

### Prerequisites
- MySQL Server 8.0 or higher
- MySQL Workbench (recommended) or MySQL CLI

### Installation

**Step 1: Clone the repository**
```bash
git clone https://github.com/sarvan-2187/SLMS.git
cd SLMS
```

**Step 2: Import the database**
```bash
mysql -u root -p < smart_library_script.sql
```

Or using MySQL Workbench:
- Open MySQL Workbench
- File → Open SQL Script
- Select `smart_library_script.sql`
- Execute the script

**Step 3: Verify installation**
```sql
USE SmartLibraryDB;
SHOW TABLES;
SHOW PROCEDURE STATUS WHERE Db = 'SmartLibraryDB';
```

## Usage Examples

### Basic Workflow

```sql
-- 1. Create admin account
CALL add_admin('AdminName', 'securePassword');

-- 2. Register a student
CALL add_student('John Doe', 'Computer Science', 2);

-- 3. Add books to catalog
CALL add_book('Database Systems', 'Silberschatz', 'Technology', 10);

-- 4. Issue book to student
CALL issue_book(1, 1);  -- student_id, book_id

-- 5. View all issued books
CALL view_issued_books();

-- 6. Return book (with automatic fine calculation)
CALL return_book(1);  -- issue_id

-- 7. Check system summary
CALL system_summary();
```

### Search Operations

```sql
-- Search students by name
CALL search_student('John');

-- Find books by title
CALL search_book_by_title('Database');

-- Search by author
CALL search_book_by_author('Silberschatz');

-- View only available books
CALL available_books();
```

### Reports & Analytics

```sql
-- Get top 5 borrowed books
CALL top_borrowed_books();

-- Find most active students
CALL top_students();

-- View stock by genre
CALL stock_summary();

-- Calculate total fines collected
CALL total_fines();

-- Check overdue books
CALL overdue_books();
```

## Database Schema

### Tables

| Table | Description | Key Fields |
|-------|-------------|------------|
| `admins` | Administrator credentials | admin_id, admin_name, password |
| `students` | Student registry | student_id, student_name, course, year |
| `books` | Book inventory | book_id, title, author, genre, total_copies, available_copies |
| `issued_books` | Transaction records | issue_id, student_id, book_id, issue_date, due_date, return_date, fine |
| `transactions` | Activity logs | transaction_id, type, ref_id, date_time |

### Relationships
- `issued_books` references `students` via Foreign Key: student_id
- `issued_books` references `books` via Foreign Key: book_id

## Complete Procedure Reference

### Admin Management (5 procedures)
- `add_admin` - Create new admin account
- `check_admin_login` - Validate admin credentials
- `view_admins` - List all administrators
- `update_admin_pass` - Change admin password
- `delete_admin` - Remove admin account

### Student Management (6 procedures)
- `add_student` - Register new student
- `view_students` - List all students
- `search_student` - Search by name
- `update_student` - Modify student details
- `delete_student` - Remove student record
- `count_students` - Get total student count

### Book Management (8 procedures)
- `add_book` - Add book to catalog
- `view_books` - List all books
- `search_book_by_title` - Search by title
- `search_book_by_author` - Search by author
- `available_books` - Show available books only
- `update_book` - Modify book details
- `delete_book` - Remove book from catalog
- `count_books` - Get total book count

### Issue & Return (7 procedures)
- `issue_book` - Issue book to student
- `return_book` - Process book return
- `renew_book` - Extend due date by 7 days
- `view_issued_books` - Show all issued books
- `overdue_books` - List overdue books
- `total_fines` - Calculate total fines collected
- `student_fines` - Get fines for specific student

### Transaction Management (4 procedures)
- `view_transactions` - View all transaction logs
- `latest_transaction` - Get most recent transaction
- `count_transactions` - Total transaction count
- `delete_transactions` - Clear transaction logs

### Reports & Analytics (4 procedures)
- `system_summary` - Overall system statistics
- `top_borrowed_books` - Most popular books
- `top_students` - Most active borrowers
- `stock_summary` - Inventory grouped by genre

## Key Features Explained

### Automated Fine Calculation
Books have a 15-day borrowing period. Late returns incur a fine of ₹10 per day. Fines are automatically calculated when books are returned and can be tracked by individual student or system-wide.

### Transaction Logging
Every operation is automatically logged with transaction type (ADD, UPDATE, DELETE, ISSUE, RETURN), reference ID, and timestamp for complete audit trail.

### Book Availability Management
The system automatically tracks book copies, decrementing available copies when issued and incrementing when returned. This prevents over-issuing of books beyond available inventory.

## Sample Output

```
mysql> CALL system_summary();
+----------------+-------------+--------------+-------------+
| Total_Students | Total_Books | Active_Issues| Total_Fines |
+----------------+-------------+--------------+-------------+
|             25 |          50 |           12 |        450  |
+----------------+-------------+--------------+-------------+
```

## Important Notes

- Running the installation script will DROP the existing `SmartLibraryDB` database if it exists
- Always backup your data before reinstalling or making major changes
- Default admin credentials should be changed immediately after installation
- The system uses `ON DELETE CASCADE` for maintaining referential integrity
- All stored procedures include proper error handling and transaction logging

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Open a Pull Request

## Author

**NAGARAMPALLI SARVAN KUMAR**

- GitHub: [@sarvan-2187](https://github.com/sarvan-2187)
- Project Link: [https://github.com/sarvan-2187/SLMS](https://github.com/sarvan-2187/SLMS)

## Acknowledgments

- Inspired by real-world library management requirements
- Built with MySQL stored procedures for optimal performance
- Designed for educational institutions and small to medium libraries

---

Star this repository if you find it helpful.
