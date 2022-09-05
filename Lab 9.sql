/*
1. Create trigger to audit the user updates in the employees table and tracing the salary changes.
    Table columns:
        employee_id , user_name , upd_time , old_sal , new_sal

2. Prevent employees from deleting the employee data after  business hours.

3. The rows in the JOBS table store a minimum and maximum salary allowed for different JOB_ID values.
    You are asked to write code to ensure that employees’ salaries fall in the range allowed for their job type.

4. Create trigger depts._trg to auto increment department_id in departments table and 
    Create deptseq to use sequence it  in this trigger – increment seq by 5
    
5. Create instead of trigger on  view “employees_vu”  to store employees data and store Min/Max Salary into Jobs table after each insert.

6. Create trigger to track logon / log off actions for users.
*/

---------1.
create table emp_audit
(
employee_id number(6),
user_name varchar2(25),
upd_time date,
old_sal number(8,2),
new_sal number(8,2)
);
---------------------------------
create or replace trigger emp_upd_sal
after update of salary
on employees
for each row
begin

insert into emp_audit
values ( :old.employee_id , :old.first_name || ' ' || :old.last_name , sysdate ,
                :old.salary , :new.salary );

end;

---------2.
create or replace function prev_del
return boolean
is
begin

    if to_char ( sysdate , 'day' ) in ( 'friday' , 'saturday' ) or
        to_char ( sysdate , 'hh24:mi:ss' ) not between '09:00:00' and '17:00:00' then
        raise_application_error (-20005 , 'Out of business hours') ;
   end if;

end;
---------------------------
create or replace trigger prev_del_trg
before delete
on employees
declare
    v_prev_del boolean;
begin
    v_prev_del := prev_del;
end;

---------3.
create or replace function ens_sal ( v_job_id varchar2 , v_salary number )
return boolean
is
    v_min_sal number(6);
    v_max_sal number(6);
begin

select min_salary , max_salary
into v_min_sal , v_max_sal
from jobs
where job_id = v_job_id;

if v_salary between v_min_sal and v_max_sal then
    return true;
    else
    return false;
end if;

end;
----------------------------------
create or replace trigger emp_Sal_trg
before update or insert of salary
on employees
for each row
declare

    v_ens_sal boolean;

begin

v_ens_sal := ens_sal ( :new.job_id , :new.salary );

    if v_ens_sal = false then
        raise_application_error( -20002, ' Out of range ');
    end if;

end;

---------4.
create sequence deptseq
start with 280
maxvalue 1000000
increment by 5;
----------------------------------
create or replace trigger depts_trg
before insert
on departments
for each row
begin

    :new.department_id := deptseq.nextval;
end;

----------5.
create or replace view employee_vu
as
select employee_id , first_name , last_name , email , hire_date , job_id , salary , department_id
from employees;
-------------------------------------------------
create or replace trigger emp_vu_trg
instead of insert or update
on employee_vu
for each row

declare 
    v_max_salary number (8,2);
    v_min_salary number (8,2);
begin

    if inserting then
        insert into employees ( employee_id , first_name , last_name , email , hire_date , job_id , salary , department_id )
        values ( :new.employee_id , :new.first_name , :new.last_name , :new.email , :new.hire_date , :new.salary , :new.department_id);
    end if;
    
    if :new.salary > v_max_salary then
        update jobs
        set max_salary = :new.salary
        where job_id = :new.job_id;
        
    elsif :new.salary < min_salary then
        update jobs
        set min_salary = :new.salary
        where job_id = :new.job_id;
        
    end if;        
     end;
     
-----------6.
create table sys.log_table
(
    log_id number(8,2),
    log_date date,
    user_name varchar2(25),
    action varchar2(25),
);
----------------
create or replace trigger logon_trg
after logon on database
declare

    v_log_id number;
    
begin

    select nvl ( max ( log_id ) , 0 ) + 1
    into v_log_id
    from log_table;
    
    insert into sys.log_table
  values (  v_log_id , sysdate , user , 'Logged on' );
  
end;
----------------------
create or replace trigger logoff_trg
before logoff on database
declare

    v_log_id number;
    
begin

    select nvl ( max ( log_id ) , 0 ) + 1
    into v_log_id
    from log_table;
    
    insert into sys.log_table
    values  ( v_log_id , sysdate , user , 'Logged off' );
 
end;