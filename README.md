# Library Management System (SQL - PostgreSQL)

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `LMS_db`

This project shows how to use SQL to construct a library management system.  It involves CRUD activities, complex SQL query execution, and table creation and management.  The objective is to demonstrate proficiency in database architecture, querying, and manipulation.
![Library_project](https://github.com/jemish123/Library_Management_System/blob/main/library.png)

## Objectives

 1. **Set-Up**: create and add tables for branches, staff, members, books, issued status, and return status to the Library Management System                          database.
 2. **CRUD Operations**: Work with the data to create, read, update, and delete it.
 3. **Create Table As Select (CTAS)**: Make use of CTAS to generate new tables according to query outcomes.
 4. **Advanced SQL Queries**: Create intricate queries to examine and obtain particular data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/jemish123/Library_Management_System/blob/main/ERD.png)

- **Database Creation**: Created a database named `LMS_db`.
- **Table Creation**: Created tables for Branch, Employee, Members, Books, Issue Status, and Return Status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

**Task 1. Create a new book with the following data:**
-- '978-1-60125-456-2', 'To Kill a Mockingbird', 'Calssic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'

```sql
insert into
	Books
(isbn, book_title, category, rental_price, status, author, publisher)
	values
('978-1-60125-456-2', 'To Kill a Mockingbird', 'Calssic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from Books;
```

**Task 2: Update an Existing Member's Address. (Pick any of your choice.)**

```sql
update Members set member_address='792 Oak St' where member_id='C103';
select * from Members;
```

**Task 3: Delete a record from the issued status table :** -- Objective (Delete record with issue_id = 'IS121' from the Issued_Status)

```sql
delete from Issue_Status where issue_id='IS121';
select * from Issue_Status;
```

**Task 4: List all books issued by employee with emp_id='E101'** -- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from Issue_Status where issued_emp_id='E101';
```


**Task 5: List all members who have issued more than 1 book.** -- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select 
            issued_member_id, count(*) as issued_books_count 
from issue_status 
	group by issued_member_id
	having count(*) > 1;

```

### 3. CTAS (Create Table As Select)

 **Task 6: Generate a new table which holds record of books and its respective issued_count**

```sql
Create Table book_issued_count as (
	select 
		b.isbn, b.book_title, count(i.issue_id) as Issue_Count
	from
		Books as b Left join Issue_Status as i
	on
		b.isbn=i.issued_book_isbn
	group by b.isbn, b.book_title
);
select * from book_issued_count;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Fetch all books in a category 'History'**:

```sql
select * from Books where category='History';
```

8. **Task 8: Find Total Rental Income By Category.**:

```sql
select 
	b.category as category, sum(b.rental_price) as total_revenue 
from 
	Issue_Status as i join Books as b 
	on i.issued_book_isbn=b.isbn
	group by category 
	order by total_revenue desc;
```

9. **List all members who registered in last 1080 days.**:
```sql
select * from Members where reg_date >= CURRENT_DATE - INTERVAL '1080 days';
```

10. **List Employees with their branch manager's name and branch details**:

```sql
select 
	e1.emp_id,
	e1.emp_name,
	e1.job_position,
	b.*,
	e2.emp_name
from 
	Employee as e1 join Branch as b on e1.branch_id=b.branch_id
	join Employee as e2 on b.manager_id=e2.emp_id;
```

Task 11. **Create a table which list all books which rental price is above 20.00**:
```sql
create table Books_Rental_Threshold as (
	select * from Books where rental_price > 4
);
select * from Books_Rental_Threshold;
```

Task 12: **Retrieve the list of books not yet returned**
```sql
select * from return_status;
select 
	distinct issued_book_name
from 
	issue_status as i left join return_status as r
	on i.issue_id=r.issued_id
	where r.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day period). Display the member's id, member's name, book title, issue_date and days overdue.

```sql
select 
	i.issued_member_id as Member_Id,
	m.member_name as Member_Name,
	b.book_title as Book_Title,
	i.issued_date as Issue_Date,
	(CURRENT_DATE - i.issued_date) as Days_Overdue
from 
	issue_status as i join members as m on m.member_id=i.issued_member_id
	join books as b on b.isbn=i.issued_book_isbn
	left join return_status as r on r.issued_id=i.issue_id
	where r.return_date IS NULL and (CURRENT_DATE - i.issued_date)>30
	order by Member_id;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of the book in the Books table to "Yes" when they are returned (based on entries in the return_status table.)


```sql

create or replace procedure add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
	language plpgsql
as $$
	declare 
		v_isbn VARCHAR(50);
		v_title VARCHAR(80);
	
	begin
		SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_title
			FROM issue_status where issue_id=p_issued_id;
		
		insert into Return_Status (return_id, issued_id, return_book_name, return_date, return_book_isbn, book_quality)
			VALUES
		(p_return_id, p_issued_id, v_title, CURRENT_DATE, v_isbn, p_book_quality);

		UPDATE books set status='Yes' 
			where isbn=v_isbn; 

		raise notice 'Thank you for returning the book:  %', v_title;
	end;
	$$;

-- calling function 
call add_return_record('RS119', 'IS122', 'Good');

```



**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_performance_report 
	as (
		SELECT 
			b.branch_id as "Branch", 
			b.manager_id as "Manager ID", 
			COUNT(i.issue_id) as "Total Issued", 
			COUNT(r.return_id) as "Total Returned", 
			SUM(bo.rental_price) as "Total Revenue"
		from issue_status as i join employee as e on i.issued_emp_id=e.emp_id
				join branch as b on b.branch_id = e.branch_id 
				left join return_status as r on r.issued_id=i.issue_id 
				join books as bo on bo.isbn=i.issued_book_isbn
			GROUP BY b.branch_id, b.manager_id
			ORDER BY b.branch_id, b.manager_id
	);

select * from branch_performance_report;
```

**Task 16: Create a Table of Active Members**  
Use CTAS (Create table as (Select----)) statement to create a new table "active_members" containing members who have issued at least one book in last 6 months.

```sql

CREATE TABLE active_members 
	AS (
		SELECT 
			m.*,
			i.issued_date as last_issued_date 
		FROM 
			members as m join issue_status as i
			on i.issued_member_id = m.member_id
		WHERE
			i.issued_date >= CURRENT_DATE - INTERVAL '6 months'
	);
SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have the most books issues. Display the employee name, number of books processed and their branch.

```sql
SELECT 
	e.emp_id as emp_id,
	e.emp_name as emp_name,
	b.branch_id as branch_id,
	COUNT(i.issue_id) as total_issues
FROM 
	employee as e join issue_status as i ON i.issued_emp_id = e.emp_id
	join branch as b ON b.branch_id = e.branch_id
	GROUP BY e.emp_id,e.emp_name,b.branch_id
	ORDER BY total_issues DESC
	LIMIT 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with status "damaged" in the books table. Display the member name, book title and number of times they've issued damaged books.    

```sql
-- This query identifies members who have issued damaged books more than twice.
SELECT 
	m.member_name as Members_Issued_Damage_Books
FROM members as m join 
	(SELECT 
		i.issued_member_id, COUNT(i.issue_id) as damaged_issue_count
	FROM 
		books as b right join issue_status as i
		ON i.issued_book_isbn = b.isbn
		where b.book_quality='Damaged'
		GROUP BY i.issued_member_id) as di
	ON m.member_id=di.issued_member_id
	WHERE damaged_issue_count > 2;

-- This query identifies members, book title and number of times they have issued damaged books.
SELECT 
	m.member_name as member_name,
	b.book_title as book_title,
	COUNT(i.issue_id) as damaged_book_issue_count
FROM 
	books as b join issue_status as i on i.issued_book_isbn = b.isbn
	join members as m on m.member_id = i.issued_member_id
	WHERE b.book_quality='Damaged'
	GROUP BY m.member_name,b.book_title;
```

**Task 19: Stored Procedure**
Stored Procedure objective: Create a stored procedure to manage the status of books in LMS.

Description: 

Write a stored procedure which update the status of the book on its issuance. The procedure should functions as follows:

 1. The stored procedure should take the book_id as an input parameter.
	
 2. The procedure should look for whether the book is available or not. (i.e., status='Yes').

 3. If the book is available, it should be issued, and the status in the books table should be updated to 'No'. 

 4. If the book is not available (status = 'No'), the procedure should return an error message indicating that the book is currently not                  available.

```sql

CREATE OR REPLACE PROCEDURE 
	issue_book(
		p_issue_id VARCHAR(10), 
		p_issued_member_id VARCHAR(30), 
		p_issued_book_isbn VARCHAR(50), 
		p_issued_emp_id VARCHAR(10)
) LANGUAGE plpgsql 
AS $$
	-- declare all variables
	DECLARE
	is_available VARCHAR(50);
	requested_book_name VARCHAR(100);
	
	-- starts the process of book issuance
	BEGIN
		-- Check whether the book is available or not
		SELECT status, book_title into is_available, requested_book_name
		FROM books where isbn=p_issued_book_isbn;

		IF is_available = 'yes' 
			THEN
				INSERT INTO issue_status (issue_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
					VALUES (p_issue_id, p_issued_member_id, requested_book_name, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
				
				-- Raise a notice that book is issued.
				RAISE NOTICE 'Books isbn %s has been issued to %s.', p_issued_book_isbn, p_issued_member_id;

				-- Update the status to 'No' for the issued_book.
				UPDATE books SET status='no' WHERE isbn=p_issued_book_isbn;
		ELSE
			RAISE NOTICE 'Sorry for the inconvinience. Book isbn %s is not available at this time.', p_issued_book_isbn;
		END IF;
	END;
$$

CALL issue_book('IS41', 'C110', '978-0-7432-4722-4', 'E105');

```



**Task 20: Create Table As Select (CTAS)**

Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: 

Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.

The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 

The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines.

```sql
CREATE TABLE overdue_calculations 
AS (SELECT 
		m.member_id as member_id,
		m.member_name as member_name,
		COUNT(i.issued_book_isbn) as Overdue_Books,
		SUM((CURRENT_DATE - (i.issued_date + INTERVAL '30 Days')::DATE)* 0.5) as Total_Fines
	FROM
		members as m join issue_status as i ON i.issued_member_id = m.member_id
		LEFT JOIN return_status as r ON i.issue_id=r.issued_id
		JOIN books as b ON b.isbn = i.issued_book_isbn
	WHERE 
		r.return_date IS NULl AND CURRENT_DATE - (i.issued_date + INTERVAL '30 Days')::DATE > 0
	GROUP BY
		m.member_id, m.member_name
);
SELECT * FROM overdue_calculations;
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/jemish123/Library_Management_System.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `query.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Jemish Mangukiya (We-Build Infotech)

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/jemish005/)

Thank you for your interest in this project!
