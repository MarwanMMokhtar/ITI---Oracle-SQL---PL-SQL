/* 1-Display the last name concatenated with the job id, separated by a comma and space and name the column [Employee and Title]  as alias

2-Display the last name and salary for all employees whose salary is not in the range of $1500 and $7000.

3-Display the last name, salary and commission for all employees who earn commissions, Sort data in descending order of salary and commissions.

4- Display the last name, job id and salary for all employees whose job id is SA_REP or PU_MAN and their salary is not equal to $9500, $9000 or $8000 

5-Display all information about employees whose last name begin with letter 'S’ or letter ‘s’

6-Display all employees whose first name contains letter before last ‘e’ or ‘E’
*/
select * from employees;
-- 1.
select last_name || ', ' || job_id as " Employee and Title "
from employees;
-- 2.
select last_name , salary
from employees
where salary not between 1500 and 7000;
-- 3.
select last_name , salary , commission_pct
from employees
where commission_pct is not null
order by salary desc , commission_pct desc;
-- 4.
select last_name , job_id , salary
from employees
where job_id in ( 'SA_REP' , 'PU_MAN' ) and salary not in ( 9500 , 9000 , 8000 );
-- 5.
select * from employees
where upper (last_name) like upper ('s%');
-- 6.
select * from employees
where upper(first_name) like upper('%e_');
