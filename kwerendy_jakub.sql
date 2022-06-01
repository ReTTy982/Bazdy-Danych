update pracownicy
set id_maszyny = null
where &id_maszyny = id_maszyny;

update stan_produktow
set id_maszyny = null
where &id_maszyny = id_maszyny;

delete maszyny
where &id_maszyny = id_maszyny;


--ustawianie pensji pracownika
update pracownicy 
set pensja = &pensja
where &id_pracownika;

-- przydzial pracownikow
update pracownicy 
set id_maszyny = &id_maszyny
where id_pracownika = &id_pracownika;



--dodaj transakcje
insert into transakcje(cena,data_transakcji,rodzaj_transakcji)
values(&cena,todate(&rok,&miesiac,&dzien,'YYYY\MM\DD'),&rodzaj_transakcji);

--usuwanie transakcji
delete from produkty
where id_produktu = any(select id_produktu 
                        from tabela_zapisu 
                        where &id_transakcji= id_transakcji);
delete from tabela_zapisu 
where &id_transakcji = id_transakcji;

delete from transakcje
where &id_transakcji= id_transakcji;


-- dodawanie produktu



delete from produkty
where id_produktu = (select id_produktu 
                    from stan_produktow
                    where &id_tabeli);
delete from stan_produktow
where &id_tabeli;

-- dodawanie produktow

insert into produkt(nazwa,ilosc)values(&nazwa,&ilosc);

--dodawanie maszyn 

insert into maszyny(nazwa_maszyny,stopien_zuzycia) values(&nazwa_maszyny,&stopien_zuzycia);

--dodwanie pracownikow


insert into pracownicy(imie,nazwisko,data_zatrudnienia,pensja,id_roli)
values (&imie,&naziwsko,todate(&rok,&miesiac,&dzien,'YYYY\MM\DD'),&pensja,&id_roli);

create or replace view sprawdz_zapotrzebowanie as
select p.nazwa, p.ilosc
from produkt p join stan_produktow s
using (id_produktu)
where &id_maszyny  and rodzaj_stanu = 'Z';