/*
1.    Create plsql block and to check for all employees using cursor; and update their commission_pct based on the salary
SALARY < 7000  :                    COMM = 0.1
7000 <= SALARY < 10000      COMM = 0.15
10000 <= SALARY < 15000    COMM = 0.2
15000 <= SALARY                      COMM = 0.25

2.    Alter table employees then add column retired_bonus
Create plsql block to calculate the retired salary for all employees using cursor and update retired_bonus column
Retired bonus = no of working months * 10 % of his current salary
Only for those employees have passed 18 years of their hired date

3.    Create plsql block using cursor to print last name, department name,
        city, country name for all employees employee ( without using join | sub query )

4.    Create plsql block that loop over employees table and 
Increase only those working in ‘IT’ department by 10% of their salary using cursors

5.    Create plsql block that insert new Department
With these data 
Department_id = 350
Department name = Oracle Dept
Manager id = 103
Location Id = 17
Handle exception as needed

*/

-------1.
set serveroutput on size 1000000
declare 
cursor emp_cursor is
    select * from employees;
begin
    for v_emp_record in emp_cursor loop
        if v_emp_record.salary < 7000 then
            update employees
            set commission_pct = 0.1
            where employee_id = v_emp_record.employee_id;
        elsif v_emp_record.salary >= 7000 and v_emp_record.salary < 10000 then
            update employees
            set commission_pct = 0.15
            where employee_id = v_emp_record.employee_id;
        elsif v_emp_record.salary >= 10000 and v_emp_record.salary < 15000 then
            update employees
            set commission_pct = 0.2
            where employee_id = v_emp_record.employee_id;
        else 
            update employees
            set commission_pct = 0.25
            where employee_id = v_emp_record.employee_id;
        end if;
        
    end loop;

end;

----------2.
set serveroutput on size 1000000;
declare

cursor emp_cursor is 
    select * from employees
    order by employee_id;
    
v_working_years number(4);

begin
    
    for v_emp_record in emp_cursor loop
    
        v_working_years := trunc ( months_between (sysdate , v_emp_record.hire_date ) / 12 );
    
        if v_working_years > 18 then
            update employees
            set retired_bonus = trunc ( months_between (sysdate , v_emp_record.hire_date ) ) * 0.1 * v_emp_record.salary
            where employee_id = v_emp_record.employee_id;
        end if;
        
    end loop;
    
end;

-----------3.
set serveroutput on size 100000
declare 
   cursor emp_cursor is 
              select  last_name , department_id
                from employees;
    v_department_name varchar2(25);
    v_country_id varchar2(4);
    v_country_name varchar2(25);
    v_location_id number(4);
    v_city varchar2(25);
begin
   for v_emp_record in emp_cursor loop
                 if v_emp_record.department_id  is not null then
                 
                select department_name , location_id
                into v_department_name ,v_location_id
                from departments
                where department_id = v_emp_record.department_id;
                
                select city , country_id into v_city, v_country_id
                from locations
                where location_id = v_location_id;
                
                select  country_name into v_country_name
                from countries
                where country_id = v_country_id;
                
                dbms_output.put_line( v_emp_record.last_name || v_department_name||v_city|| v_country_name );
            end if;
    end loop;
end;

--------4.
    set serveroutput on
declare
cursor emp_cursor is
    select employee_id , salary    
    from employees;
v_department_id number(8);
v_dep_id number (8);
begin                            
            select department_id into v_department_id
            from departments where department_name ='IT';
                     
         for v_emp_record in emp_cursor loop
         
             select department_id  into v_dep_id
             from employees  where employee_id = v_emp_record.employee_id;
             
                  if v_dep_id = v_department_id then
                         update employees
                         set salary = salary + salary*0.1
                         where employee_id = v_emp_record.employee_id;                         
                 end if;                         
         end loop;
end;

--------5.
set serveroutput on
declare
        exception_integrity_constraint exception;
       pragma exception_init(exception_integrity_constraint, -02291);
        
        exception_null_dept  exception;
        pragma exception_init(  exception_null_dept, -01400 );

        begin
    insert into departments
            (department_id, department_name , manager_id , location_id)
     values
            ( 50 , 'IT' , 105 , 17 );
        
exception 
        when exception_integrity_constraint then
             dbms_output.put_line(' Insert parent record first '); 
        when exception_null_dept then
            dbms_output.put_line('Empty department name or location');
            
end;