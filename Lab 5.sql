/*
1. Create plsql block that loop over employees table and 
    Increase only those working in ‘IT’ department by 10% of their salary.
2. Create plsql block and to check for all employees using loops; and update their commission_pct based on the salary.
    SALARY < 7000  :                    COMM = 0.1
    7000 <= SALARY < 10000      COMM = 0.15
    10000 <= SALARY < 15000    COMM = 0.2
    15000 <= SALARY                 COMM = 0.25
3. Alter table employees then add column retired_bonus
    Create plsql block to calculate the retired salary for all employees using loops and update retired_bonus column
    Retired bonus = no of working months * 10 % of his current salary
    Only for those employees have passed 18 years of their hired date.
4. Create plsql block using loops to print last name, department name, city, country name for all employees employee ( without using join | sub query)
*/
--------1.
set serveroutput on
declare
v_salary number(8);
v_department_id number(4);
v_dep_id number(4);
v_max number(4); v_min number(4);
begin           
        select min(employee_id) , max(employee_id)
                into v_min , v_max from employees;
                
            select department_id into v_department_id
            from departments where department_name ='IT';
                     
         for i in v_min .. v_max loop
             select department_id  into v_dep_id
             from employees  where employee_id = i;
                  if v_dep_id = v_department_id then
                         update employees
                         set salary = salary + salary*0.1
                         where employee_id = i;                         
                 end if;                         
         end loop;
end;
--------2.
declare
v_salary number(8);
v_comm number(8);
v_employee_id number(5);
v_min number(8);
v_max number(8);
begin
        select min(employee_id) , max(employee_id)
                into v_min , v_max from employees;        
        for i in v_min .. v_max loop
            select salary into v_salary
            from employees where employee_id = i;            
            if v_salary < 7000 then
                 update employees
                 set commission_pct = 0.1
                 where employee_id = i;
            elsif v_salary < 10000 then
                 update employees
                 set commission_pct = 0.15
                 where employee_id = i;
            elsif v_salary < 15000 then
                 update employees
                 set commission_pct = 0.20
                 where employee_id = i;
            else 
                 update employees
                 set commission_pct = 0.25
                 where employee_id = i;
            end if;              
        end loop;
end;
--------3.

declare
v_salary number(8);
v_hire_date date;
v_working_years number (8);
v_min number (8);
v_max number (8);
begin
        select min(employee_id) , max(employee_id)
        into v_min , v_max from employees;
        
        for i in v_min .. v_max loop
        
            select salary , hire_date into v_salary , v_hire_date
            from employees where employee_id = i;
            
            v_working_years := months_between ( sysdate , v_hire_date ) / 12;
            
            if v_working_years >= 18 then
                update employees
                set retired_bonus = months_between ( sysdate , v_hire_date ) * 0.1 * v_salary
                where employee_id = i;
                
            end if;            
        end loop;
end;
--------4.
set serveroutput on
declare
v_last_name varchar2(30);
v_department_name varchar2(30);
v_city varchar2(30);
v_country_name varchar2(30);
 v_min number(8);
 v_max number(8);
 v_department_id number(8);
v_location_id number(8);
v_country_id char(2);
begin
   select min(employee_id) , max(employee_id)
        into v_min , v_max from employees;
        
       for i in v_min .. v_max loop
       
              select last_name , department_id
              into v_last_name , v_department_id
              from employees where employee_id = i;
              
           if v_department_id is not null then              
          
              select department_name , location_id
              into v_department_name , v_location_id
              from departments where department_id = v_department_id;
              
              select city , country_id
              into v_city , v_country_id
              from locations where location_id = v_location_id;
              
              select country_name into v_country_name
              from countries where country_id = v_country_id;
              
           dbms_output.put_line('Employee with the id: ' || i || ' , Last name: '|| v_last_name ||
                                           ' , Department name: ' || v_department_name || ' , City : ' || v_city ||
                                           ' , Country name: ' || v_country_name );
          end if;                                         
       end loop;   
end;