--  ---------------------------  Tasks for LMS  --------------------------
-- 1. Create a new book with the following data:
-- '978-1-60125-456-2', 'To Kill a Mockingbird', 'Calssic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
insert into
	Books
(isbn, book_title, category, rental_price, status, author, publisher)
	values
('978-1-60125-456-2', 'To Kill a Mockingbird', 'Calssic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

select * from Books;


--2. Update an Existing Member's Address. (Pick any of your choice.)
select * from Members;
update Members set member_address='792 Oak St' where member_id='C103';


-- 3. Delete a record from the issued status table : Objective (Delete record with issue_id = 'IS121' from the Issued_Status)
select * from Issue_Status;
delete from Issue_Status where issue_id='IS121';


-- 4. List all books issued by employee with emp_id='E101'
select * from issue_status;
select * from Issue_Status where issued_emp_id='E101';


--5. List all members who have issued more than 1 book.
select 
	issued_member_id, count(*) as issued_books_count 
from issue_status 
	group by issued_member_id
	having count(*) > 1;


-- 6. CTAS (Create Table As Select)
-- Generate a new table which holds record of books and its respective issued_count
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


-- 7. Fetch all books in a category 'History'
select * from Books where category='History';


-- 8. Find Total Rental Income By Category.
select 
	b.category as category, sum(b.rental_price) as total_revenue 
from 
	Issue_Status as i join Books as b 
	on i.issued_book_isbn=b.isbn
	group by category 
	order by total_revenue desc;


--9. List all members who registered in last 1080 days.
select 
	*
from Members
	where reg_date >= CURRENT_DATE - INTERVAL '1080 days';


-- 10. List Employees with their branch manager's name and branch details
select 
	e1.emp_id,
	e1.emp_name,
	e1.job_position,
	b.*,
	e2.emp_name
from 
	Employee as e1 join Branch as b on e1.branch_id=b.branch_id
	join Employee as e2 on b.manager_id=e2.emp_id;


-- 11. Create a table which list all books which rental price is above 20.00
create table Books_Rental_Threshold as (
	select * from Books where rental_price > 4
);
select * from Books_Rental_Threshold;


-- 12. Retrieve the list of books not yet returned
select * from return_status;
select 
	distinct issued_book_name
from 
	issue_status as i left join return_status as r
	on i.issue_id=r.issued_id
	where r.return_id IS NULL;



-- --------------------------------	 Advanced SQL Queries  ---------------------------------
/*
13. 	Identify Members with Overdue Books
 		Write a query to identify members who have overdue books (assume a 30-day period). Display the member's id, 
		member's name, book title, issue_date and days overdue.
*/

-- 	issued_status == members == books == return_status
-- 	filters books which are returned.
--	overdue > 30 days

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


/*
14.	Update Book status on return
	Write a query to update the status of the book in the Books table to "Yes" when they are returned (based on entries in the return_status table.)
*/
-- Stored Procedure
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

call add_return_record('RS119', 'IS122', 'Good');


/*
15.	Branch Performance Report
	Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned,
	and the total revenue generated from book rentals.
*/
select * from branch;
select * from issue_status;
select * from employee;
select * from return_status;
select * from books;

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


/*
16.	Create a Table of Active Members
	Use CTAS (Create table as (Select----)) statement to create a new table "active_members" containing members who have issued at least 
	one book in last 6 months.
*/
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



/*
17.	Find Employees with the most book issues processed
	Write a query to find the top 3 employees who have the most books issues. Display the employee name, number of books processed 
	and their branch.
*/
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


/*
18.	Identify Members issuing High-Risk Books
	Write a query to identify members who have issued books more than twice with status "damaged" in the books table.
	Display the member name, book title and number of times they've issued damaged books. 
*/
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


/*
19.	Stored Procedure objective: Create a stored procedure to manage the status of books in LMS.
	Description: 
		Write a stored procedure which update the status of the book on its issuance. The procedure should functions as follows:
		1.	The stored procedure should take the book_id as an input parameter.
		2.	The procedure should look for whether the book is available or not. (i.e., status='Yes').
		3.	If the book is available, it should be issued, and the status in the books table should be updated to 'No'. 
		4.	If the book is not available (status = 'No'), the procedure should return an error message indicating that the book is 
			currently not available.
*/
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



/*
20.	Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

	Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
	The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
	The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines.
*/
SELECT 
	*
FROM
	issue_status as i LEFT JOIN return_status as r
	ON i.issue_id!=r.issued_id AND i.issued_book_isbn=r.return_book_isbn;