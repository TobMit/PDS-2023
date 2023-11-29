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

select *
from OBJEDNAVKY;

select *
from SKLADOVE_ZASOBY;

-- o kotrý produkt ide jedno durhé monožtvo a pozície

select PRODUKT_ID, NAZOV, obj.MNOZSTVO, zas.MNOZSTVO, SKLAD, REGAL, POZICIA, DATUM_NAKUPU
    from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
        order by PRODUKT_ID, DATUM_NAKUPU;

-- sum analytická funckia (sum over)

select PRODUKT_ID, NAZOV, obj.MNOZSTVO as obj_mnozstvo, zas.MNOZSTVO as na_sklade,
       sum(zas.MNOZSTVO) over (partition by PRODUKT_ID order by DATUM_NAKUPU
           rows between unbounded preceding and current row ) as sumaNakupAgr,
            SKLAD, REGAL, POZICIA, DATUM_NAKUPU
    from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
        order by PRODUKT_ID, DATUM_NAKUPU;

select *
    from (
        select PRODUKT_ID, NAZOV, obj.MNOZSTVO as obj_mnozstvo, zas.MNOZSTVO as na_sklade,
       sum(zas.MNOZSTVO) over (partition by PRODUKT_ID order by DATUM_NAKUPU
           rows between unbounded preceding and current row ) as sumaNakupAgr,
            SKLAD, REGAL, POZICIA, DATUM_NAKUPU
            from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
                order by PRODUKT_ID, DATUM_NAKUPU
         )
            where sumaNakupAgr <= obj_mnozstvo;

-- potrebujem brať predhcázajúci záznam aby sme s current rown nebrali všetky, pri analytickej to nejde, čo dosiahneme že zoberieme z toho len to čo potrebujeme

select PRODUKT_ID, NAZOV, obj_mnozstvo, na_sklade, sumaNakupAgr + least(na_sklade, obj_mnozstvo - sumaNakupAgr), SKLAD, REGAL, POZICIA, DATUM_NAKUPU
    from (
        select PRODUKT_ID, NAZOV, obj.MNOZSTVO as obj_mnozstvo, zas.MNOZSTVO as na_sklade,
       sum(zas.MNOZSTVO) over (partition by PRODUKT_ID order by DATUM_NAKUPU
           rows between unbounded preceding and 1 preceding) as sumaNakupAgr,
            SKLAD, REGAL, POZICIA, DATUM_NAKUPU
            from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
                order by PRODUKT_ID, DATUM_NAKUPU
         )
            where sumaNakupAgr <= obj_mnozstvo;

-- teba nájsť opitmálnu trasu

select PRODUKT_ID, NAZOV, obj_mnozstvo, na_sklade, sumaNakupAgr + least(na_sklade, obj_mnozstvo - sumaNakupAgr) as sumaAgregovana,
       SKLAD, REGAL, POZICIA, DATUM_NAKUPU, dense_rank() over (order by SKLAD, REGAL) as drank
    from (
        select PRODUKT_ID, NAZOV, obj.MNOZSTVO as obj_mnozstvo, zas.MNOZSTVO as na_sklade,
       sum(zas.MNOZSTVO) over (partition by PRODUKT_ID order by DATUM_NAKUPU
           rows between unbounded preceding and 1 preceding) as sumaNakupAgr,
            SKLAD, REGAL, POZICIA, DATUM_NAKUPU
            from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
                order by PRODUKT_ID, DATUM_NAKUPU
         )
            where sumaNakupAgr <= obj_mnozstvo
                order by SKLAD, REGAL, case when mod(drank, 2) = 1  then POZICIA else -POZICIA end;

-- čo by sa stalo že sú horné dvere zatvorené
select PRODUKT_ID, NAZOV, obj_mnozstvo, na_sklade, sumaNakupAgr + least(na_sklade, obj_mnozstvo - sumaNakupAgr) as sumaAgregovana,
       SKLAD, REGAL, POZICIA, DATUM_NAKUPU, dense_rank() over (partition by SKLAD order by SKLAD, REGAL) as drank
    from (
        select PRODUKT_ID, NAZOV, obj.MNOZSTVO as obj_mnozstvo, zas.MNOZSTVO as na_sklade,
       sum(zas.MNOZSTVO) over (partition by PRODUKT_ID order by DATUM_NAKUPU
           rows between unbounded preceding and 1 preceding) as sumaNakupAgr,
            SKLAD, REGAL, POZICIA, DATUM_NAKUPU
            from SKLADOVE_ZASOBY zas join OBJEDNAVKY obj on zas.PRODUKT_ID = obj.ID_PROD
                order by PRODUKT_ID, DATUM_NAKUPU
         )
            where sumaNakupAgr <= obj_mnozstvo
                order by SKLAD, REGAL, case when mod(drank, 2) = 1  then POZICIA else -POZICIA end;


-- skúste toto rozšíriť tak aby išlo cez 2 objednávky, potrebujem si nasčítavať koľko si beriem celkovo toho istého tovaru
-- malo by to byť tak že 5.. 5/0, potom 7.. 12/0, potom 6.. 15/3
-- todo na bónusové body

-- tabuľka študent a chcem ich rozdeliť po 10 na jednotivé termíny, (1.10 na jendom termíne, 2 10 na druhom termíne ...)
-- čiže rozdelenie množiny po 10

select meno, priezvisko, rod_cislo, row_number() over (order by rod_cislo) as poradie
    from STUDENT join OS_UDAJE using (rod_cislo);


-- zoberiem poradie, vydelím max počtom v skupine a potom to ceil (ktorá to zaorkúhli do hora

select meno, priezvisko, rod_cislo, ceil(poradie/10) as termin --toto sa rozhodne objaví na teste
    from (
        select meno, priezvisko, rod_cislo, row_number() over (order by rod_cislo) as poradie
            from STUDENT join OS_UDAJE using (rod_cislo)
         );

-- skúsime to upraviť tak aby bol rozdiel medzi skupinami max 1
select meno, priezvisko, rod_cislo, ceil(poradie/((select count(*) from STUDENT)/4)) as termin --toto sa rozhodne objaví na teste
    from (
        select meno, priezvisko, rod_cislo, row_number() over (order by rod_cislo) as poradie
            from STUDENT join OS_UDAJE using (rod_cislo)
         );