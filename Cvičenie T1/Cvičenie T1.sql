desc os_udaje;
select table_name from tabs;

select table_name from user_tables;
select table_name from user_constraints;
select table_name from user_indexes;

select table_name from all_tables;

-- osoby, ktoré nikdy neboli študentami
select priezvisko, meno
    from os_udaje os
        where not exists (select 'x'
                            from student st
                                where os.rod_cislo = st.rod_cislo);
                                
-- osob, ktoré nikdy neboli študentami pomocou not in
select priezvisko, meno
    from os_udaje os -- nemalo by tu byť null v os_udaje lebo by to nefungovalo dobre
        where rod_cislo not in (select rod_cislo
                            from student);
                            
-- vypýsať študijný odbor ktorý nemá žiadného študenta
-- kompozitny PK neviem zapísať pomocou not in
select *
    from st_odbory so
        where not exists(select 'x'
                            from student st
                                where so.st_odbor = st.st_odbor);
                                
-- ku každej osobe vypýsať koľko má predmetov
-- keď tam je hviezdička tak sa to pozerá na existenciu riadku ale ak má počítať niečo konkrétne tak sa do count nepočíta s null
select meno, priezvisko, count(cis_predm)
    from os_udaje left join student using (rod_cislo)
        left join zap_predmety using (os_cislo)
            group by meno, priezvisko, rod_cislo;
            
-- počet koľko má osoba zapísaných unikátnych predmetov
select meno, priezvisko, count( distinct cis_predm)
    from os_udaje left join student using (rod_cislo)
        left join zap_predmety using (os_cislo)
            group by meno, priezvisko, rod_cislo;
            
-- osoba ktorá má najviac predmetov
select meno, priezvisko, count( distinct cis_predm) as pocet
    from os_udaje left join student using (rod_cislo)
        left join zap_predmety using (os_cislo)
            group by meno, priezvisko, rod_cislo
                having count( distinct cis_predm) = ( select max(count( distinct cis_predm))
                                                            from os_udaje left join student using (rod_cislo)
                                                                left join zap_predmety using (os_cislo)
                                                                     group by meno, priezvisko, rod_cislo );
                                                        
 -- osoba ktorá má najviac predmetov predmetov pomocou docasnej tabulky
select meno, priezvisko, count( distinct cis_predm) as pocet
    from os_udaje left join student using (rod_cislo)
        left join zap_predmety using (os_cislo)
            group by meno, priezvisko, rod_cislo
                having count( distinct cis_predm) = ( select max(predmet) from (select count( distinct cis_predm) as predmet
                                                            from os_udaje left join student using (rod_cislo)
                                                                left join zap_predmety using (os_cislo)
                                                                     group by meno, priezvisko, rod_cislo )); 
                                           
-- priklad od ucitela
select meno, priezvisko, ou.rod_cislo, count(os_cislo) as pocet
    from os_udaje ou
        left join student st on (ou.rod_cislo = st.rod_cislo)
            group by meno, priezvisko, ou.rod_cislo
                having count (os_cislo) >= 2;
                
-- DATE --
select sysdate from dual;

-- chcem vidie� aj �as
alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS';

set serveroutput on;

select sysdate from dual;

-- pridanie d�a
select sysdate + 1 from dual; 

-- pridanie hodiny
select sysdate + 1/24 from dual;

-- pridanie pmocou intervalu
select sysdate + interval '2:05:16' hour to second from dual;

-- zo sysdate iba datumova cast
select trunc(sysdate, 'DD') from dual;

-- vypýsať iba rok
select extract(year from sysdate) from dual;
select extract(month from sysdate) from dual;
select extract(day from sysdate) from dual;
select to_char(sysdate, 'DD.MM') from dual;


declare
    cursor cur_osoba is (
        select meno, priezvisko, rod_cislo
            from os_udaje);
    v_meno varchar2(30);
    v_priezvisko os_udaje.priezvisko%type;
    v_rod_cislo os_udaje.rod_cislo%type;
begin
    open cur_osoba;
    
    loop
    
        fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
         -- ak je koniec kurzora, na porad� z�le��
        exit when cur_osoba%notfound;
        dbms_output.put_line(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
    end loop;
    close cur_osoba;
end;
/

declare
    cursor cur_osoba is (select meno, priezvisko, rod_cislo from os_udaje);
    v_meno varchar2(30);
    v_priezvisko os_udaje.priezvisko%type;
    v_rod_cislo os_udaje.rod_cislo%type;

    cursor cur_student(p_rod_cislo varchar2) is (
        select os_cislo from student where rod_cislo=p_rod_cislo);
    student_row cur_student%rowtype;
begin
    open cur_osoba;
    loop
        fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
        exit when cur_osoba%notfound;
        dbms_output.put_line(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        open cur_student(v_rod_cislo);
        loop
            fetch cur_student into student_row;
            exit when cur_student%notfound;
            dbms_output.put_line('     ' || student_row.os_cislo);
        end loop;
        close cur_student;
    end loop;
    close cur_osoba;
end;
/



declare
begin
for osoba in (select meno, priezvisko, rod_cislo from os_udaje)
loop
    dbms_output.put_line(osoba.meno || ' ' || osoba.priezvisko || ' ' || osoba.rod_cislo);
    for student in (select os_cislo from student where rod_cislo = osoba.rod_cislo)
        loop
            dbms_output.put_line('    ' || student.os_cislo);
        end loop;
end loop;
end;
/

for prikaz in (
select 'drop table '|| table_name as prikaz from tabs)
loop
    execute immediate prikaz.prikaz;
end loop;

select 'drop table ' || table_name as prikaz from tabs;

