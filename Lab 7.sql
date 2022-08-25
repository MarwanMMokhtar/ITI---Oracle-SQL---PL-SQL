/*

1.    Create and invoke the ADD_LOC procedure and consider the results.
    a)    Create a procedure called ADD_LOC to insert a new Location into the LOCATIONS Provide the LOCATION_ID
                , STREET_ADDRESS, POSTAL_CODE    , CITY, STATE_PROVINCE, COUNTRY_ID   parameters.
    b)    Compile the code; invoke the procedure. Query the Locations table to view the results.
    c)    Handle Error for the Invalid Country IDs.

2. Create and Invoke the Query_loc Procedure to display the data for a certain region from Locations, Countries, regions tables in the following format :
      " Region Name , Country Name , LOCATION_ID  , STREET_ADDRESS  , POSTAL_CODE , CITY  "   Pass Location ID as an input parameter.

3.    Create and invoke the GET_LOC function to return the street address, city for a specified LOCATION_ID.

4.    Create a function called GET_ANNUAL_COMP to return the annual salary computed from an employee’s monthly salary and commission passed as parameters.
            Use the following basic formula to calculate the annual salary: 
                (Salary*12) + (commission_pct*salary*12).

5.    a- add RETIRED NUMBER(1), RETIRED_BONUS NUMBER(8,2) columns to employees table.
       b- Create and call
            CHECK_RETIRED FUNCTION(V_EMP_ID NUMBER, V_MAX_HIRE_YEAR NUMBER) RETURN BOOLEAN;
            that will return true if employee has passed no of years >=  V_MAX_HIRE_YEAR
       c- Create and call
        CALC_RETIRED_BONUS  FUNCTION (V_EMP_ID NUMBER, V_PERCENT NUMBER) RETURN NUMBER;
        that will return RETIRED BONUS value
        calculated from 
        no of working months * salary* v_percent / 100
        d- create anonymous block to update the emp with retired bonus and set retired = 1  if this employee will retired      

*/

-------1.a.

create or replace procedure add_loc (v_location_id number , v_street_address varchar2 , v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char )
is
begin
insert into locations
values ( v_location_id , v_street_address , v_postal_code , v_city , v_state_province , v_country_id );
end;

--------1.b.
begin
add_loc ( v_location_id => 3500 , v_street_address => '45 Street' , v_postal_code => '141424' , v_city => 'New Giza' , v_state_province => 'Giza' , v_country_id => 'EG' );
end;

-------1.c.
create or replace procedure add_loc (v_location_id number , v_street_address varchar2,  v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char)
is 
invalid_country_id exception;
pragma exception_init ( invalid_country_id , -02291 );
large_id_size exception;
pragma exception_init ( large_id_size , -12899 );
begin
insert into locations
values ( v_location_id , v_street_address , v_postal_code , v_city , v_state_province , v_country_id );
exception
when invalid_country_id then
dbms_output.put_line(' Invalid country ID ');
when large_id_size then
dbms_output.put_line(' Country ID is too large ');
end;

-------2.
create or replace procedure query_loc ( v_location_id number )
is
v_region_name varchar2(30);
v_country_name varchar2(40);
v_street_address varchar2(40);
v_postal_code varchar2(30);
v_city varchar2(30);
begin
select loc.street_address , loc.postal_code , loc.city , coun.country_name ,   reg.region_name
into v_street_address , v_postal_code , v_city , v_country_name , v_region_name
from locations loc , countries coun , regions reg
where loc.country_id = coun.country_id and coun.region_id = reg.region_id
and loc.location_id = v_location_id;
dbms_output.put_line( 'Region Name = ' || v_region_name ||
' , Country Name = ' || v_country_name || ' , Location Id = ' || v_location_id ||
' , Street Address = ' || v_street_address || ' , Postal Code = ' || v_postal_code ||
' , City = ' || v_city );
end;

--------3.
create or replace function get_loc ( v_city out varchar2 , v_location_id number )
return varchar2
is
    v_street_address varchar2 (30);
begin
    select street_address , city
    into v_street_address , v_city
    from locations
    where location_id = v_location_id;
return v_street_address;
end;

-------------------- invoke the GET_LOC function
set serveroutput on size 100000
declare
v_street_address varchar2(30);
v_city varchar2(30);
begin
v_street_address := get_loc(v_city , v_location_id => 2900 );
dbms_output.put_line( ' Street adress = ' || v_street_address || ' , City = ' || v_city );
end;

-------4.
create or replace function get_annual_comp ( v_salary number , v_commission_pct number )
return number
is
    v_annual_salary number (10,2);
begin
    v_annual_salary := v_salary*12 + v_commission_pct*v_salary*12;
return v_annual_salary;
end;
    
Use the function in a SELECT statement against the EMPLOYEES table for Employees in department 80.

select e.* , get_annual_comp( salary , commission_pct ) as "Annual Salary"
from employees e
where department_id = 80;

------5.a.
alter table employees
add retired number(1)
add retired_bonus number(8,2);

-------5.b.
create or replace function check_retired( v_emp_id number , v_max_hire_year number)
return boolean
is
    v_salary number (10,2);
    v_hire_date date;
    v_hire_years number(10,2);
begin
    select salary , hire_date
    into v_salary , v_hire_date
    from employees
    where employee_id = v_emp_id;
v_hire_years := trunc ( months_between ( sysdate , v_hire_date ) / 12 );
    if v_hire_years >= v_max_hire_year then
        return true;
    else
        return false;
    end if;
end;
------------------------- invoke the check_retired function
set serveroutput on
declare
    v_check_retired boolean;
begin
    v_check_retired := check_retired ( v_emp_id => 120 , v_max_hire_year => 17 );

    if v_check_retired = true then
        dbms_output.put_line(' Retired ');
    else
        dbms_output.put_line(' Not Retired ');
    end if;    
end;

-------5.c.
create or replace function calc_retired_bonus ( v_emp_id number , v_percent number )
return number
is
    v_retired_bonus number(10,2);
    v_salary number(10,2);
    v_hire_date date;
begin
    select salary , hire_date
    into v_salary , v_hire_date
    from employees
    where employee_id = v_emp_id;
    
    v_retired_bonus := trunc ( months_between( sysdate , v_hire_date ) * v_salary * v_percent / 100 );

return v_retired_bonus;
end;
--------------------------  invoke the calc_retired_bonus function
set serveroutput on
declare
    v_retired_bonus number(10,2);
begin
    v_retired_bonus := calc_retired_bonus( v_emp_id => 135 , v_percent => 15 );
    dbms_output.put_line( ' Retired bonus = ' || v_retired_bonus );
end;

-------5.d.
set serveroutput on size 100000;
declare
cursor emp_cursor is
            select * from employees;
v_max_hire_year number (10 , 2 );
v_percent number (10 , 2 );
v_retired_bonus number(10,2);
begin

    for v_emp_record in emp_cursor loop
    
        v_retired_bonus := calc_retired_bonus( v_emp_record.employee_id , v_percent => 10 );
    
        update employees
        set retired_bonus = v_retired_bonus
        where employee_id = v_emp_record.employee_id;
        
        if check_retired ( v_emp_record.employee_id , v_max_hire_year => 17 ) = true then
            update employees
            set retired = 1
            where employee_id = v_emp_record.employee_id;
        end if;
    
    end loop;
end;