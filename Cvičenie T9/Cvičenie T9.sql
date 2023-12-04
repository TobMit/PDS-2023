-- sqlplus student01/student01@"(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = obelix.fri.uniza.sk)(PORT = 1522))(CONNECT_DATA =(SERVER = DEDICATED)      (SERVICE_NAME = orcladm.fri.uniza.sk)  ) )


-- sqlplus kvet3@"(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = obelix.fri.uniza.sk)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)      (SERVICE_NAME = orcl.fri.uniza.sk)  ) )

-- student01/student01@"obelix.fri.uniza.sk:1522/orcladm.fri.uniza.sk"

-- student01@"obelix.fri.uniza.sk:1522/orcladm.fri.uniza.sk"

-- kvet3@"obelix.fri.uniza.sk:1521/orcl.fri.uniza.sk"

-- kvet3@orcl_obelix


-- purge recyclebin bin zmaže kôš, má obmedzenú kapacitu, funguje first in first out, čiže sa to mení,
-- má obmedzenú kapacitu (defaultne 1% z celkového počtu)

-- na obnovu cez kôš za nepoužíva žiaden logický žurlnál
--Cviko T9

--transakcie

--sqlplus -> chce to prihlasovanie

--Prve dva ->  su fullConnect

-- druhe Tri su ktory host, ktory port (1522) a ptm sluzba orcl,...

--posledny cez identifikator tnsnames ora -> iba zadame nazov connect identifikatora z tns ora

--standardne pred @ je login, za lomitkom je heslo


--Moja tabulka po zavolani Drop sa len presunie do recycleBin

--objectName je nazov ako ho system premenoval

--ak je tabulka v kosi, neviem nad nou robit zmenove operacie -> ci uz na urovni struktury alebo zmeny dat

--viem ju tiez obnovit pomocou flashback table

--- Kapacita kosa je 100gb na kazdu instanciu

--oracle ma nastavenu hodnotu, kt vieme menit

--show recyclebin; -> zobrazi obsah kosa


--purge recyclebin; -> vyprazdni obsah kosa

--v kosi mozu byt viacere tabulky s rovnakym nazvom -> po pouziti flashback sa obnovi posledne odstranena tabulka

--na zap moze byt v kosi 2 tabulky -> chcem obnovit tu 2. -> kod k tomu

--ako sa mi zmenili zaznamy za poslednych 10 minut

--na obnovu cez kos sa nepouziva logicky zurnal



create table moja_zaloha (id integer);

create or replace procedure vloz (id integer)
is
begin
    insert into moja_zaloha values (id);
end;
/


begin
    for i in 1.. 5
        loop
            insert into moja_zaloha values(i);
            vloz(-i);
        end loop;
end;

-- 10 záznamov
delete from moja_zaloha;

begin
    for i in 1.. 5
        loop
            insert into moja_zaloha values(i);
            rollback;
            vloz(-i);
            commit;
        end loop;
end;

-- 5 záznamov

begin
    for i in 1.. 5
        loop
            insert into moja_zaloha values(i);
            rollback;
        end loop;
end;
/

-- vypýše 0


-- autonomná transakcia, žije si vojím životom

create or replace procedure vloz (id integer)
is
    pragma autonomous_transaction; -- na konci tejto proceduri sa musí transakcia ukončiť komitom alebo rollbackom, preto je rollbacknutá
    -- jednoducho povedané, vždy ju musím na konci ukončiť
begin
    insert into moja_zaloha values (id);
    rollback;
end;
/

begin
    for i in 1.. 5
        loop
            insert into moja_zaloha values(i);
            vloz(-i);
            --rollback;
            commit;
        end loop;
end;
/

commit;
select * from moja_zaloha;

-- vytvorenie nejakého používateľa

create user originalTobias identified by oracle; -- oracle je heslo
grant connect to originalTobias; -- aby som sa vedel pripojiť
grant resource to originalTobias with admin  option; -- ešte stále neviem vytvoťiť tabuľku, lebo nemáme priestor ukladanie tabuľky (hdd)
grant unlimited tablespace to originalTobias; -- zmeny sa prejavia až po znovu prihlásení
drop user originalTobias; -- viem ho zrušiť iba ak nie je pripojený

alter session kill session ....; -- killnuť session viem pomocou tabulky aktývnich sessions a tam sú 2 čisla

-- na servery orcl adm
    -- dám prislušné práva
    -- dám tabuľku
    -- naplnim datami
    -- asterix
    -- database link  --> student - 10

create table nejakaTabulka (rod_cislo varchar2(11));
drop table nejakaTabulka;

select * from originalTobias.moj_tabulka;

