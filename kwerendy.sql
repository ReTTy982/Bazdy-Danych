-- id maszyn ktore sa zuzyte bardziej niz 50 procent


select id_maszyny
from maszyny
where stopien_zuzycia < '50';


-- pracownicy bez przydzielonej maszyny
select id_pracownika, imie, nazwisko
from pracownicy
where id_maszyny  is null; 


--pracownicy przypisani do poszcegolenj maszyny
select id_pracownika, imie, nazwisko
from pracownicy
where id_maszyny = '6';

--widok pracownikow z poszczegolnej roli
select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Magazynier';


select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Technik';


select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Zarzad';

--suma wszytskich pensji
select sum(pensja)
from pracownicy;

--ktorzy zwykli pracownicy zarabiaja ponad srednia pensje
select id_pracownika, imie, nazwisko, pensja
from pracownicy 
where pensja > (select avg(pensja) 
                from pracownicy
                where id_roli = '0'
                ) and id_roli = '0';


-- transkacje zsumowane, kupna, sprzedarzy, roznica 
select sum(CASE WHEN rodzaj_transakcji = 'S' THEN cena else 0 end) as "Suma sprzedazy",
sum(CASE WHEN rodzaj_transakcji = 'K' THEN cena else 0 end) as "Suma kupna",
sum(CASE WHEN rodzaj_transakcji = 'S' THEN cena else 0 end) - sum(CASE WHEN rodzaj_transakcji = 'K' THEN cena else 0 end)as "Zysk"
from transakcje;

-- ustawienie pracownikowi o id 115 przypisnaia do maszyny 
-- i sprawdzenie czy jest technikiem czy zwyklym szarakiem
update pracownicy
set id_maszyny = 5
where id_pracownika = 115 and (id_roli = 0 or id_roli= 2);

--ustawineie sprawnosci na 100 procent 
--tam gdzie sa przypsiani technicy
update maszyny
set stopien_zuzycia = '100'
where id_maszyny = any(select id_maszyny
                        from pracownicy
                        where id_roli = 2);



--usuwanie pracownika o id 5
update magazyn
set logistyk  = NULL
where logistyk = '5';

delete from pracownicy
where id_pracownika = '5';

--usuwanie maszyny o id 2
update pracownicy
set id_maszyny = NULL
where id_maszyny = '2';

delete from stan_produktow
where id_maszyny = '2';

delete from maszyny
where id_maszyny = '2';


-- usuwanie maki z maszyny o id 4
delete from stan_produktow
where id_produktu = any (select id_produktu
from produkt 
where nazwa like 'Maka') and id_maszyny = '4';


-- zapotrzebowanie maszyny o id 5

select p.nazwa, p.ilosc
from produkt p join stan_produktow s
using (id_produktu)
where id_maszyny = '5' and rodzaj_stanu = 'Z';


-- obecne produkty maszyny o id 5

select p.nazwa, p.ilosc
from produkt p join stan_produktow s
using (id_produktu)
where id_maszyny = '5' and rodzaj_stanu = 'o';