/* Project No.1 Requirements:
    Create an anonymous block using dynamic SQL to create triggers / sequences pairs using to put them for each table in your HR schema dynamically.
*/

declare
    cursor trg_seq_cursor is
        select ucc.constraint_name , ucc.table_name , ucc.column_name
        from user_constraints  uc , user_cons_columns ucc , user_objects uo , user_tab_columns utc
        where ucc.constraint_name = uc.constraint_name and
        ucc.table_name = uc.table_name and
        ucc.table_name = uo.object_name and
        ucc.table_name = utc.table_name and
        utc.column_name = ucc.column_name and
        uc.constraint_type = 'P' and uo.object_type = 'TABLE' and utc.data_type = 'NUMBER';              
 
begin

    for trg_seq_record in trg_seq_cursor loop
        execute immediate
            'CREATE SEQUENCE '||trg_seq_record.TABLE_NAME||'_SEQ
            START WITH   600
            INCREMENT BY  1
            MAXVALUE 99999999
            MINVALUE 1
            NOCYCLE
            CACHE 20
            NOORDER';

        execute immediate
            'CREATE OR REPLACE TRIGGER '||trg_seq_record.TABLE_NAME||'_TRG
            BEFORE INSERT OR UPDATE
            ON '||trg_seq_record.TABLE_NAME||'
            REFERENCING NEW AS NEW OLD AS OLD
            FOR EACH ROW
            BEGIN
                :new.'||trg_seq_record.COLUMN_NAME||' := '||trg_seq_record.TABLE_NAME||'_SEQ.nextval;
                end;';
                
    end loop;
    
end;