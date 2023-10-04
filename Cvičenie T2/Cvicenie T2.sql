-- premedy ktoré si nikto nikdy nezapísal
select *
    from PREDMET
         where CIS_PREDM not in (select CIS_PREDM from ZAP_PREDMETY);

select *
    from PREDMET
         where not exists(select * from ZAP_PREDMETY where ZAP_PREDMETY.CIS_PREDM = PREDMET.CIS_PREDM);

-- zoznam predmetov ktoré mali zapísane max 4 študenti
select pr.CIS_PREDM, NAZOV
    from PREDMET pr
        left join ZAP_PREDMETY ZP on pr.CIS_PREDM = ZP.CIS_PREDM
            group by CIS_PREDM, NAZOV
                having count(OS_CISLO) <= 4
                    order by 2;

select CIS_PREDM, NAZOV
    from PREDMET
        where CIS_PREDM not in (select CIS_PREDM
                                from ZAP_PREDMETY
                                    group by CIS_PREDM
                                        having count(OS_CISLO) > 4)
            order by 2;


-- chcem grant pre všetky moje tabuľky pre public
-- GRAND SELECT ON "NAZOV TABUĽKY" TO PUBLIC
-- select table_name from tabs; všetky tabuľky a napísať k tomu cursor

select 'grant select on ' || table_name || ' to public' from tabs;

set serveroutput on; -- iba cez grid settings enabled

grant select on STUDENT to public;

declare
    cursor grant_public is (
        select 'grant select on ' || table_name || ' to public' from tabs
    );

    data varchar(100);
begin
    open grant_public;

    loop
        fetch grant_public into data;
        exit when grant_public%notfound;
        dbms_output.put_line(data);
        execute immediate data;

    end loop;

    close grant_public;

end;
/
-- TODO HWK revoke SELECT ON "TAB" FROM PUBLIC

-- rebildovať všetky indexi
-- alter index "nazov" rebuild

select 'alter index ' || INDEX_NAME || ' rebuild'
    from USER_INDEXES;

alter index SYS_C00709020 rebuild;


declare
    cursor alter_index is (
            select 'alter index ' || INDEX_NAME || ' rebuild'
                from USER_INDEXES
        );

    data varchar2(100);

begin
    open alter_index;

    loop
        fetch alter_index into data;
        exit when alter_index%notfound;
        dbms_output.put_line(data);
        execute immediate data;

    end loop;

    close alter_index;
end;
/

-- chcem ku každému študentovy vypísať os_cislo
-- pracuje iba v SQL developera, neefektívne
select meno, priezvisko, cursor(select OS_CISLO
                                        from STUDENT s
                                            where s.ROD_CISLO = o.ROD_CISLO
                                        )
    from os_udaje o;

-- použite agregačnej funkcie
select MENO, PRIEZVISKO,
       listagg(OS_CISLO, ',') within group (order by OS_CISLO) -- takto to musí byť
            from OS_UDAJE left join STUDENT using(rod_cislo)
                group by MENO, PRIEZVISKO, ROD_CISLO;

--
declare
    i integer;
begin
    i:=1; -- ak nemám inicializáciu tak tam hodí null v iných DS to skončí chybou
    DBMS_OUTPUT.PUT_LINE('hodnota: '||i);
end;

declare
    i integer;
begin
    i:='1'; -- zafunguje atomaticka konveria späť na čislo
    DBMS_OUTPUT.PUT_LINE('hodnota: '||i);
end;

-- exception vlastny
declare
    i integer;
    chyba exception;
    PRAGMA EXCEPTION_INIT ( chyba, -6502 );
begin
    i:='x'; -- teraz to už spadne
    DBMS_OUTPUT.PUT_LINE('hodnota: '||i);

    if i > 0 then raise_application_error(-2000, 'moja chyba'); -- od -2000 až do 2999
    end if;
    exception
        when chyba then DBMS_OUTPUT.PUT_LINE('chyba konverzie');
        when others then DBMS_OUTPUT.PUT_LINE('iná chyba');
end;


-- chyba už v deklarácií
begin
    declare
        i integer:='x';
        chyba exception;
        PRAGMA EXCEPTION_INIT ( chyba, -6502 );
    begin
        --i:='x'; -- teraz to už spadne
        DBMS_OUTPUT.PUT_LINE('hodnota: '||i);

        if i > 0 then raise_application_error(-2000, 'moja chyba'); -- od -2000 až do 2999
        end if;
        exception
            when chyba then DBMS_OUTPUT.PUT_LINE('chyba konverzie');
            when others then DBMS_OUTPUT.PUT_LINE('iná chyba');
    end;

    exception
        when others then DBMS_OUTPUT.PUT_LINE('vonkajšia chyba');
end;
/

-- viem pomenovať boky pomocou "<<NAZOV>>"
-- využitie napr keď potrebujem pristupovať var s rovnakým názvom vo vnorenom bloku

-- meno osoby s najdlhším priezviskom
select meno, PRIEZVISKO
    from OS_UDAJE
        where LENGTH(PRIEZVISKO) in (select max(length(PRIEZVISKO)) from OS_UDAJE);

-- osoba, ktorá mala najviac zapísaných premdetova
select meno, priezvisko, count( distinct cis_predm) as pocet
    from os_udaje left join student using (rod_cislo)
        left join zap_predmety using (os_cislo)
            group by meno, priezvisko, rod_cislo
                having count( distinct cis_predm) = ( select max(predmet) from (select count( distinct cis_predm) as predmet
                                                            from os_udaje left join student using (rod_cislo)
                                                                left join zap_predmety using (os_cislo)
                                                                     group by meno, priezvisko, rod_cislo ));

-- ku každej osobe vypýšte ročník

select MENO, PRIEZVISKO, st.ROCNIK
    from OS_UDAJE os left join  STUDENT st on os.ROD_CISLO = st.ROD_CISLO
        where st.ROCNIK = 2;

select MENO, PRIEZVISKO, st.ROCNIK
    from OS_UDAJE os left join  STUDENT st on (os.ROD_CISLO = st.ROD_CISLO and st.rocnik =2); -- týmto spôsobom mi tovypíše aj null hodnoty

