-- Create a Database for LMS.
CREATE DATABASE LMS_db;

-- -------------------- CREATE TABLES ----------------------
CREATE TABLE IF NOT EXISTS Branch (
	branch_id varchar(10) PRIMARY KEY,
	manager_id varchar(10),
	branch_address varchar(50),
	contact_no varchar(15)

	foreign key (manager_id) references Employee(emp_id)
);

CREATE TABLE IF NOT EXISTS Employee (
	emp_id varchar(10) PRIMARY KEY,
	emp_name varchar(30),
	job_position varchar(30),
	salary numeric(10,2),
	branch_id varchar(10),
	
	foreign key (branch_id) references Branch(branch_id)
);

CREATE TABLE IF NOT EXISTS Members (
	member_id varchar(10) PRIMARY KEY,
	member_name varchar(30),
	member_address varchar(50),
	reg_date date
);

CREATE TABLE IF NOT EXISTS Books (
	isbn varchar(50) primary key,
	book_title varchar(80),
	category varchar(30),
	rental_price numeric(10,2),
	status varchar(10),
	author varchar(30),
	publisher varchar(30)
);

CREATE TABLE IF NOT EXISTS Issue_Status(
	issue_id varchar(10) PRIMARY KEY,
	issued_member_id varchar(30),
	issued_book_name varchar(50),
	issued_date date,
	issued_book_isbn varchar(50),
	issued_emp_id varchar(10),

	foreign key (issued_member_id) references Members(member_id),
	foreign key (issued_book_isbn) references Books(isbn),
	foreign key (issued_emp_id) references Employee(emp_id)
);

CREATE TABLE IF NOT EXISTS Return_Status (
	return_id varchar(10) PRIMARY KEY,
	issue_id varchar(10),
	return_book_name varchar(30),
	return_date date,
	return_book_isbn varchar(50),

	foreign key (return_book_isbn) references Books(isbn)
);


-- -------------------- INSERT DATA into TABLES ----------------------
COPY Branch (branch_id,	manager_id,	branch_address,	contact_no) FROM '/tmp/branch.csv' DELIMITER ',' CSV HEADER;
select * from Branch;

COPY Employee (emp_id,	emp_name, job_position,	salary, branch_id) FROM '/tmp/employees.csv' DELIMITER ',' CSV HEADER;
select * from Employee;

COPY Members (member_id, member_name, member_address, reg_date) FROM '/tmp/members.csv' DELIMITER ',' CSV HEADER;
select * from Members;

COPY Books (isbn, book_title, category,	rental_price, status, author, publisher) FROM '/tmp/books.csv' DELIMITER ',' CSV HEADER;
select * from Books;

COPY Issue_Status (issue_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id) FROM '/tmp/issued_status.csv' DELIMITER ',' CSV HEADER;
select * from Issue_Status;

COPY Return_Status (return_id, issued_id, return_date) FROM '/tmp/return_status.csv' DELIMITER ',' CSV HEADER;
select * from Return_Status;

-- Modified Some Content
alter table return_status add column book_quality varchar(15) default('Good');

update return_status set book_quality='Damaged' where issued_id in ('IS106', 'IS110', 'IS113');


-- This will update all books's status to 'No' if book is not returned.
update books set status='No' 
	where isbn in (select issued_book_isbn from issue_status 
						where issue_id NOT IN (SELECT issued_id FROM return_status)); 


