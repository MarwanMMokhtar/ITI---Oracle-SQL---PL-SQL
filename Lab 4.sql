/*
1. Create a sequence to be used with the primary key column of the DEPARTMENTS table.
        The sequence should start at 400 and have a maximum value of 1000.
        Have your sequence increment by ten numbers. Name the sequence DEPT_ID_SEQ.
2. Create new user “accountant” grant this user two system roles with minimum privileges to access the system.
3. Create public synonyms for the view EMP_VU.
4. Create role to view and do DML operations on EMPLOYEES table in your schema, grant access on this role to all users.
5. Create plsql block to calculate the retired salary for the employee no = 105
        Retired salary = no of working months * 10 % of his current salary.
6. Create plsql block to print last name, department name, city, country name for employee whose id = 105 ( without using join | sub query )
*/

--------1.
create sequence DEPT_ID_SEQ
               start with 400
               increment by 10
      maxvalue 1000;
-------2.
conn sys/orcl as sysdba;
create user accountant identified by 111;
grant connect , resource to accountant;
-------3.
create view emp_vu
                as select employee_id , last_name , salary from employees;
conn sys/orcl as sysdba;
create public synonym my_emp_vu for hr.emp_vu;
-------4.
create role opr_role;
grant select , insert , update , delete on hr.employees to opr_role;
grant opr_role to public;
-------5.
set serveroutput on
declare
v_hire_date date;
v_salary number(8);
v_retired_salary number(8);
v_employee_id number(4);
begin
               select hire_date , salary , employee_id
               into v_hire_date , v_salary , v_employee_id
               from employees
               where employee_id = 105;
               v_retired_salary := trunc(months_between(sysdate,v_hire_date)) * v_salary * 0.1;
dbms_output.put_line('The retired salary for the employee whose id = ' ||    v_employee_id || ' is ' || v_retired_salary);
end;
-------6.
set serveroutput on
declare
v_last_name varchar2(30);
v_department_name varchar2(30);
v_city varchar2(25);
v_country_name varchar2(25);
v_department_id number(8);
v_location_id number(8);
v_country_id char(2);
begin
        select last_name,department_id 
        into v_last_name, v_department_id 
        from employees 
        where employee_id = 105;
        
        select department_name , location_id
        into v_department_name , v_location_id
        from departments
        where department_id = v_department_id;
        
        select city , country_id
        into v_city , v_country_id
        from locations
        where location_id = v_location_id;
        
        select country_name
        into v_country_name
        from countries
        where country_id = v_country_id ;        
dbms_output.put_line ('Last Name is ' || v_last_name || ', Department Name is ' || v_department_name || ', City is ' || v_city || ', Country Name is ' || v_country_name );
end;