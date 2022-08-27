/*

1.    Create a package specification and body called LOC_PKG, containing a copy of your ADD_LOC and Query_LOC, procedures as well as your GET_LOC function.

2.    Copy and modify the code for the LOC_PKG package that you created and overload the ADD_LOC procedure.  As you can insert only location_id , city only.

3.    Create a package specification and body called DEPT_PKG, be creating ADD_DEPT, UPD_DEPT, and DEL_DEPT procedures as well as your GET_DEPT function.

4.    Modify DEPT_PKG by adding GET_DEPT function that accepts the parameter called Dept_id and a second GET_DEPT function that accepts the parameter called DEPT_name.
        Both functions should return an DEPARTMENTS%ROWTYPE. Save and compile the changes.
        
*/

--------1.
------------------------------------------ loc_pkg specifications
create or replace package loc_pkg
is

procedure add_loc (v_location_id number , v_street_address varchar2 , v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char );

procedure query_loc ( v_location_id number );

function get_loc ( v_city out varchar2 , v_location_id number )
return varchar2;

end;

------------------------------------------ loc_pkg body
create or replace package body loc_pkg
is

procedure add_loc (v_location_id number , v_street_address varchar2 , v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char )
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

procedure query_loc ( v_location_id number )
is
v_region_name varchar2(30);
v_country_name varchar2(40);
v_street_address varchar2(40);
v_postal_code varchar2(30);
v_city varchar2(30);
begin
    select loc.street_address , loc.postal_code , loc.city , coun.country_name , reg.region_name
    into v_street_address , v_postal_code , v_city , v_country_name , v_region_name
    from locations loc , countries coun , regions reg
    where loc.country_id = coun.country_id and coun.region_id = reg.region_id and loc.location_id = v_location_id;

dbms_output.put_line('Region Name = ' || v_region_name || ' , Country Name = ' || v_country_name || ' , Location Id = ' || v_location_id ||
                                        ' , Street Address = ' || v_street_address || ' , Postal Code = ' || v_postal_code || ' , City = ' || v_city );
end;

function get_loc ( v_city out varchar2 , v_location_id number )
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

end;


--------2.
------------------------------------------ modify loc_pkg specifications
create or replace package loc_pkg
is

procedure add_loc (v_location_id number , v_street_address varchar2 , v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char );

procedure add_loc (v_location_id number , v_city varchar2 );

procedure query_loc ( v_location_id number );

function get_loc ( v_city out varchar2 , v_location_id number )
return varchar2;

end;
------------------------------------------ modify loc_pkg body
create or replace package body loc_pkg
is

procedure add_loc (v_location_id number , v_street_address varchar2 , v_postal_code varchar2 , v_city varchar2 , v_state_province varchar2 , v_country_id char )
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

procedure add_loc (v_location_id number , v_city varchar2 )
is
begin

insert into locations ( location_id , city )
values ( v_location_id , v_city );

end;

procedure query_loc ( v_location_id number )
is
v_region_name varchar2(30);
v_country_name varchar2(40);
v_street_address varchar2(40);
v_postal_code varchar2(30);
v_city varchar2(30);
begin
    select loc.street_address , loc.postal_code , loc.city , coun.country_name , reg.region_name
    into v_street_address , v_postal_code , v_city , v_country_name , v_region_name
    from locations loc , countries coun , regions reg
    where loc.country_id = coun.country_id and coun.region_id = reg.region_id and loc.location_id = v_location_id;

dbms_output.put_line('Region Name = ' || v_region_name || ' , Country Name = ' || v_country_name || ' , Location Id = ' || v_location_id ||
                                        ' , Street Address = ' || v_street_address || ' , Postal Code = ' || v_postal_code || ' , City = ' || v_city );
end;

function get_loc ( v_city out varchar2 , v_location_id number )
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

end;

---------3.
------------------------------------------ dept_pkg specifications
create or replace package dept_pkg
is

procedure add_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number );

procedure upd_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number );

procedure del_dept ( v_department_id number );

function get_dept ( v_department_id in out number , v_manager_id out number , v_location_id out number)
return varchar2;

end;

------------------------------------------ dept_pkg body
create or replace package body dept_pkg
is

procedure add_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number )
is
begin

insert into departments
values ( v_department_id , v_department_name , v_manager_id , v_location_id );

end;

procedure upd_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number )
is
begin

update departments
set department_name = v_department_name , manager_id = v_manager_id , location_id = v_location_id
where department_id = v_department_id;

end;

procedure del_dept ( v_department_id number )
is
begin

delete from departments
where department_id = v_department_id;

end;

function get_dept ( v_department_id in out number , v_manager_id out number , v_location_id out number)
return varchar2
is
    v_department_name varchar2(30);
begin

select department_name , manager_id , location_id
into v_department_name , v_manager_id , v_location_id
from departments
where department_id = v_department_id;

return v_department_name;

end;

end;

---------4.
------------------------------------------ modify dept_pkg specifications
create or replace package dept_pkg
is

procedure add_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number );

procedure upd_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number );

procedure del_dept ( v_department_id number );

function get_dept ( v_department_id number )
return departments%rowtype;

function get_dept ( v_department_name varchar2 )
return departments%rowtype;

end;

------------------------------------------ modify dept_pkg body
create or replace package body dept_pkg
is

procedure add_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number )
is
begin

insert into departments
values ( v_department_id , v_department_name , v_manager_id , v_location_id );

end;

procedure upd_dept ( v_department_id number , v_department_name varchar2 , v_manager_id number , v_location_id number )
is
begin

update departments
set department_name = v_department_name , manager_id = v_manager_id , location_id = v_location_id
where department_id = v_department_id;

end;

procedure del_dept ( v_department_id number )
is
begin

delete from departments
where department_id = v_department_id;

end;

function get_dept ( v_department_id number )
return departments%rowtype
is
    v_dep_record departments%rowtype;
begin

select *
into v_dep_record
from departments
where department_id = v_department_id;

return v_dep_record;

end;

function get_dept ( v_department_name varchar2 )
return departments%rowtype
is
    v_dep_record departments%rowtype;
begin

select *
into v_dep_record
from departments
where upper (department_name) = upper (v_department_name);

return v_dep_record;

end;

end;