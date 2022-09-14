/* Project No.2 Requirements:
    1- Fill PAYMENT_INSTALLMENTS_NO Column in CONTRACTS Table.
    2- Fill INSTALLMENTS_PAID Table.
*/

-- Calc_Insrallments_no Function
create or replace function calc_install_no ( v_contract_id number )
return number
is
    v_start_date date;
    v_end_date date;
    v_payment_type varchar2(30);
    v_installments_no number (8,2);
begin

    select contract_startdate , contract_enddate , contract_payment_type
    into v_start_date , v_end_date , v_payment_type
    from contracts
    where contract_id = v_contract_id;
    
    case v_payment_type
        when 'ANNUAL' then
            v_installments_no := months_between ( v_end_date , v_start_date ) / 12;
        when 'QUARTER' then
            v_installments_no := months_between ( v_end_date , v_start_date ) / 3;
        when 'MONTHLY' then
            v_installments_no := months_between ( v_end_date , v_start_date );
        when 'HALF_ANNUAL' then
            v_installments_no := months_between ( v_end_date , v_start_date ) / 6;
    end case;
    
return v_installments_no;
    
end;

-- Upt_installments_no Procedure
create or replace procedure upt_installments_no ( v_contract_id number )
is
    v_installments_no number (8,2);

begin

    v_installments_no := calc_install_no ( v_contract_id );
    
    update contracts
    set payments_installments_no = v_installments_no
    where contract_id = v_contract_id;
    
end;

-- Ins_installments_paid Procedure
create or replace procedure ins_installments_paid
is
    cursor contract_cursor is
        select * from contracts;
        
    installment_date date;
    installment_amount number (8,2);        
begin

    for v_contract_record in contract_cursor loop
    
        installment_date := v_contract_record.contract_startdate;
        installment_amount := ( v_contract_record.contract_total_fees - nvl ( v_contract_record.contract_deposit_fees , 0 ) ) / v_contract_record.payments_installments_no;
        
        case v_contract_record.contract_payment_type
        
        when 'ANNUAL' then
            while installment_date < v_contract_record.contract_enddate loop
                insert into installments_paid
                values ( installment_id_seq.nextval , v_contract_record.contract_id , installment_date , installment_amount , 0 );
                installment_date := add_months ( installment_date , 12 );
            end loop;
            
        when 'QUARTER' then
            while installment_date < v_contract_record.contract_enddate loop
                insert into installments_paid
                values ( installment_id_seq.nextval , v_contract_record.contract_id , installment_date , installment_amount , 0 );
                installment_date := add_months ( installment_date , 3 );
            end loop;            
            
        when 'MONTHLY' then
            while installment_date < v_contract_record.contract_enddate loop
                insert into installments_paid
                values ( installment_id_seq.nextval , v_contract_record.contract_id , installment_date , installment_amount , 0 );
                installment_date := add_months ( installment_date , 1 );
            end loop;
            
        when 'HALF_ANNUAL' then
            while installment_date < v_contract_record.contract_enddate loop
                insert into installments_paid
                values ( installment_id_seq.nextval , v_contract_record.contract_id , installment_date , installment_amount , 0 );
                installment_date := add_months ( installment_date , 6 );
            end loop;
            
        end case;
               
    end loop;
    
end;

-- Test Block
declare
    v_min_id number ( 8 , 2 );
    v_max_id number ( 8 , 2 );
    v_count number ( 8 , 2 );
begin

    select min ( contract_id ) , max ( contract_id )
    into v_min_id , v_max_id
    from contracts;

    for i in v_min_id .. v_max_id loop
        
        select count(*) into v_count from contracts where contract_id = i;
    
        if v_count = 1 then
        upt_installments_no ( i );
        end if;
        
    end loop;
    
    ins_installments_paid;
    
end;