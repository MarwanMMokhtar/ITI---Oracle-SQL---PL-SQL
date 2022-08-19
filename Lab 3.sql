/*
1.    Display the employee number, name and salary for all employee who earn more than the average salary.
2.    Create a query to display the employees that earn salary that is higher than the salary of all the IT_PROG job id.
       Sort results on salary from highest to lowest.
Note: use Multi-row sub query.
3.    Create table with name of emp2 - populate the emp2 table using a select statement from the employees table for the employees in department 20.
4.    Create the DEPARTMENT table based on the following table instance chart.    Confirm that the table is created.
         COLUMN NAME     ID     NAME 
        Default value    1    Not available
       DATATYPE    Number    Varchar2
      LENGTH    7    25
         a)    Populate the DEPARTMENT table with data from dept table. Include only columns that you need.
        b)    Add column 'Location' to table department.
        c)    Truncate table department.
5.    Create table employee based on the structure of the EMPloyee table(Structure with data).
      Include only the employee_id, last_name,salary and department_id columns
    Employee_id Primary key 
    Last_name  unique
*/
------1.
select phone_number , first_name || ' ' || last_name as "Full Name" , salary
from employees
where salary > ( select avg(salary) from employees);
------2.
select *
from employees
where salary > all ( select salary from employees 
                             where job_id = 'IT_PROG' )
order by salary desc;
-------3.
create table emp2
as ( select * from employees where department_id = 20);
------4.
    create table department
(
id number(7) default 1,
name varchar2(25)
);
insert into department
(select department_id , department_name from departments);
alter table department
add location varchar2(25);
truncate table department;
-------5.
create table employee
as select employee_id, last_name, salary , department_id 
from employees
where 1=2;
alter table employee
drop constraint SYS_C007036;
alter table employee
add ( constraint emp_id_pk primary key (employee_id),
             constraint emp_name_unq unique (last_name));
insert into employee
                ( select employee_id, last_name, salary, department_id
   from employees);