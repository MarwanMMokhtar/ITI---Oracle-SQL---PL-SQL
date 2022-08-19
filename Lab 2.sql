/*
1.    Display all employees whose emp id is odd.
2.    Write a query that print only now time in 24 Hours 
Ex : 18:20:33 PM.
3.    Write a Query that get number of years, months between today date and employees hire date.
4.    Write a query that displays the grade of all employees based on the value of the column JOB ID, as per the table shown below:
        JOB_ID    GRADE
        AD_ASST    A
        IT_PROG    B
        SA_REP    C
        FI_MGR    D
        None of above    F
5.    Display the employees names and commissions for all employees, if no commission, displays (no commission). Hint : use to_char function.
6.    Write a Query that get the date of the First Sun day in the next month
       Print it in format   like 14-december-2020.
7.    Write a Query that get the last day date after 3 months from today
       Print it in format   like 14-december-2020.
8.    Display the employee’s name, hire date and salary review date, which is the first Monday after six months of service.
       Label the column Review. Format the dates to appear in the format similar to “Sunday, the Seventh of September, 1981 “.
9.    Write a query that will display the difference between the highest and lowest salaries in each department.
10.    write a query that will display the department name, location name, number of employees 
        and the average salary for all employee in that department, round the average salary to two decimal places.
11.    Display the employee number, name and salary for all employee who earn more than the average salary.
12.    Display the employee name and employee number along with their manager’s name and manager number.
        Label the columns Employee, Emp #, Manager, and Mgr #, respectively.
13.   Display the manager number and the salary of the lowest paid employee for the manager.
       Exclude any one whose manager is not known.
      Exclude any groups where the minimum salary is less than $1000. Sort the output in descending order of salary.
*/
------1.
select * from employees
where mod (employee_id , 2 ) != 0;
-------2.
    select to_char (sysdate , 'hh:mm:ss AM')
from dual;
-------3.
select  trunc ( months_between ( sysdate , hire_date ) / 12 ) as years ,
          trunc ( mod(months_between ( sysdate , hire_date),12 )) as Months
from employees;
--------4.
select job_id , decode ( job_id , 'AD_ASST' , 'A' , 'IT_PROG' , 'B' , 'SA_REP' , 'C' , 'FI_MGR' , 'D' , 'F') as Grade
from employees
order by grade;
--------5.
select first_name || ' ' || last_name as Employee_Name ,
            case  when   to_char(commission_pct)   is  null             then  'No Commission'
                                            
            else to_char( Commission_pct)
            end as Commission
from employees;
-- OR
select first_name || ' ' || last_name as Employee_Name ,
   nvl (  to_char(commission_pct) , 'No Commission' ) as Commissions
from employees;
---------6.
select to_char (next_day(  last_day (sysdate) , 'Sun') , 'dd-month-yyyy' )      
from dual;
-------7.
select to_char ( last_day( add_months( sysdate , 3 ) ) , 'dd-month-yyyy' )
from dual;
--------8.
select  first_name || ' ' || last_name as Employee_Name , hire_date , salary ,
      to_char( next_day( add_months( hire_date , 6 ), 'Mon') , ' Day , "the" ddspth " of " Month, yyyy') as Review
from employees;
---------9.
Select department_id , Max(salary) - Min(salary) as Difference
from employees
group by department_id;
-------10.
select dep.department_name, loc.street_address as "Location Name" , count(*) , round( avg(emp.salary) , 2 )
from departments dep ,  employees emp , locations loc
where emp.department_id = dep.department_id and dep.location_id = loc.location_id
group by dep.department_name , loc.street_address;
--------11.
select employee_id , first_name || ' ' || last_name as Employee_Name , salary
from employees
where salary > (select avg(salary ) from employees) ;
-------12.
select emp.first_name || ' ' || emp.last_name as Employee_Name , emp.employee_id , mgr.first_name || ' ' || mgr.last_name as Manager_Name , mgr.employee_id as Manager_id
from employees emp , employees mgr
where MGR.EMPLOYEE_ID = EMP.MANAGER_ID;
--------13.
select manager_id , min(salary) as Minimum_Salary
from employees
where manager_id is not null
group by manager_id
having min(salary)>= 1000
order by min(salary) desc;