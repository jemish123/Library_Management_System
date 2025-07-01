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
	
--	