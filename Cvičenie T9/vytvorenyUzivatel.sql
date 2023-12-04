create table moj_tabulka(id integer);

begin
    for i in 1.. 100
    loop
        insert into moj_tabulka values(i);
    end loop;
end;

select * from moj_tabulka;

grant select on moj_tabulka to student09;