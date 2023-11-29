create directory priecinok as '/media/Obelix.Bloby_sutdent/mitala1/obr';

create directory mitala111 as 'C:\Bloby_student\mitala1\obr';

create table blob_table (id integer,
    nazov varchar2(50),
    subor blob,
    pripona varchar2(5));


DECLARE
    v_source_blob BFILE := BFILENAME('MITALA111', 'stiahnut.png');
    v_size_blob integer;
    v_blob BLOB := EMPTY_BLOB();
BEGIN
    DBMS_LOB.OPEN(v_source_blob, DBMS_LOB.LOB_READONLY);
    v_size_blob := DBMS_LOB.GETLENGTH(v_source_blob);
    INSERT INTO mitala1.BLOB_TABLE(id, nazov, subor, pripona)
        values(100, 'stiahnut', empty_blob(), '.jpg')
            returning SUBOR into v_blob;
    DBMS_LOB.LOADFROMFILE(v_blob, v_source_blob, v_size_blob);
    DBMS_LOB.CLOSE(v_source_blob);
    UPDATE mitala1.BLOB_TABLE
        SET subor=v_blob
            WHERE ID=100;
END;
/

select *
    from BLOB_TABLE;