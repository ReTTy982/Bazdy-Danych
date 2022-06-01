-- tworzenie tabel
-- nwm co wpisac w tablespace
--rola


--==========================================
--                DROPY
--==========================================


drop table  magazyn CASCADE CONSTRAINTS;
drop table  maszyny CASCADE CONSTRAINTS;
drop table  produkt CASCADE CONSTRAINTS;
drop table  stan_produktow CASCADE CONSTRAINTS;
drop table  tabela_zapisu CASCADE CONSTRAINTS;
drop table  transakcje CASCADE CONSTRAINTS;
drop table  rola CASCADE CONSTRAINTS;
drop table  pracownicy CASCADE CONSTRAINTS;
drop table  pracownicy_logtable CASCADE CONSTRAINTS;
drop SEQUENCE PRACOWNICY_SEQ ;
drop SEQUENCE MASZYNY_SEQ ;
drop SEQUENCE PRODUKT_SEQ ;
drop SEQUENCE pracownicy_log_seq;
drop SEQUENCE TRANSAKCJE_SEQ ;
drop SEQUENCE tabela_zapisu_seq;
drop SEQUENCE stan_produktow_seq;
drop view  bilans ;








--==========================================
--                TABELE
--==========================================




Create table produkt(
id_produktu number(10,0) primary key,
nazwa varchar(64) not null,
ilosc number(24,8) default '0'
) tablespace "USERS";


CREATE TABLE rola
(
    ID_roli Number(2,0) Primary KEY,
    nazwa_roli varchar(64) not null,
    Pensja_minimalna number(10,2),
    Pensja_maksymalna number(16,2)
) Tablespace "USERS"; 



create table maszyny
(
    id_maszyny number(4,0) primary key,
    nazwa_maszyny VARCHAR2(64),
    stopien_zuzycia number(6,2) 
) tablespace "USERS";




CREATE TABLE pracownicy
(
    id_pracownika number(4,0) primary key,
    imie varchar(64),
    nazwisko varchar(64) not null,
    data_zatrudnienia date not null,
    pensja number(16,2),
    ID_roli number(2,0),
    dni_urlopu number(2,0),
    obecny char(1)
        check(obecny = 'O'
        or obecny = 'W'),
    Foreign key (id_roli) references rola(id_roli),
    id_maszyny number(4,0),
    Foreign key (id_maszyny) references maszyny(id_maszyny)
)tablespace "USERS";



Create table transakcje(
id_transakcji number(10,0) primary key,
cena number(16,4) not null,
data_zawarcia date not null,
rodzaj_transakcji char(1) 
                check (rodzaj_transakcji = 'K' 
                or rodzaj_transakcji = 'S')
) tablespace "USERS";

Create table tabela_zapisu(
    id_zapisu number(10,0) primary key,
    id_produktu number(10,0), 
    Foreign key(id_produktu) references produkt(id_produktu),
    id_transakcji number(10,0),
    foreign key (id_transakcji) references transakcje(id_transakcji)
) tablespace "USERS";



create table magazyn(
sektor VARCHAR2(32) primary key,
logistyk number(10,0),
foreign key (logistyk) references pracownicy(id_pracownika),
id_produktu number(10,0), 
foreign key (id_produktu) references produkt(id_produktu)
) tablespace "USERS";

create table stan_produktow (
    id_tabeli number(4,0) primary key,
    id_produktu number(10,0),
    id_maszyny number(10,0),
    rodzaj_stanu char(1) 
                check (rodzaj_stanu = 'Z' 
                or rodzaj_stanu = 'O'),
    foreign key (id_produktu) references produkt(id_produktu),
    foreign key (id_maszyny) references maszyny(id_maszyny)
);

create table pracownicy_logtable(
    id_action NUMBER(10,0) primary key,
    action VARCHAR2(32) not null,
    action_date date,
    id_pracownika number(4,0),
    imie varchar(64),
    nazwisko varchar(64) ,
    data_zatrudnienia date ,
    pensja number(16,2),
    id_roli number(2,0),
    dni_urlopu number(2,0),
    obecny char(1),
    id_maszyny number(4,0)
);


--==========================================
--                SEKWENCJE
--==========================================
create SEQUENCE pracownicy_seq 
start WITH 1
INCREMENT BY 1
NOCACHE;

create SEQUENCE maszyny_seq
start WITH 1
INCREMENT BY 1
NOCACHE;

create SEQUENCE produkt_seq
start WITH 1
INCREMENT BY 1
NOCACHE;

create SEQUENCE transakcje_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

create SEQUENCE tabela_zapisu_seq
START WITH 1
INCREMENT BY 1
NOCACHE;


create SEQUENCE stan_produktow_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

create SEQUENCE pracownicy_log_seq
start with 1 
INCREMENT by 1 
NOCACHE;


--==========================================
--                TRIGGERY
--==========================================

create or replace TRIGGER pracownicy_on_insert
BEFORE INSERT ON PRACOWNICY
FOR each ROW
BEGIN
SELECT PRACOWNICY_SEQ.NEXTVAL
INTO :NEW.id_pracownika
from dual;
END;
/


create or replace TRIGGER maszyny_on_insert
BEFORE INSERT ON maszyny
FOR each ROW
BEGIN
SELECT MASZYNY_SEQ.NEXTVAL
INTO :NEW.id_maszyny
from dual;
END;
/

create or replace TRIGGER produkt_on_insert
BEFORE INSERT ON produkt
FOR each ROW
BEGIN
SELECT PRODUKT_SEQ.NEXTVAL
INTO :NEW.id_produktu
from dual;
END;
/

create or replace TRIGGER transakcje_on_insert
BEFORE INSERT ON transakcje
FOR each ROW
BEGIN
SELECT TRANSAKCJE_SEQ.NEXTVAL
INTO :NEW.id_transakcji
from dual;
END;
/

create or replace TRIGGER pracownicy_logger_on_insert
BEFORE INSERT ON pracownicy_logtable
FOR each ROW
BEGIN
SELECT pracownicy_log_seq.NEXTVAL
INTO :NEW.id_action
from dual;
END;
/


create or replace TRIGGER tabela_zapisu_on_insert
BEFORE INSERT ON tabela_zapisu
FOR each ROW
BEGIN
SELECT tabela_zapisu_seq.NEXTVAL
INTO :NEW.id_zapisu
from dual;
END;
/

create or replace TRIGGER stan_produktu_on_insert
BEFORE INSERT ON stan_produktow
FOR each ROW
BEGIN
SELECT stan_produktow_seq.NEXTVAL
INTO :NEW.id_tabeli
from dual;
END;
/

create or replace TRIGGER pracownicy_logger
AFTER INSERT OR DELETE OR UPDATE ON pracownicy
for each ROW
DECLARE action varchar2(32);
BEGIN
IF INSERTING THEN
action:='Insert';

INSERT into pracownicy_logtable(
    action,
    action_date ,
    id_pracownika,
    imie ,
    nazwisko,
    data_zatrudnienia  ,
    pensja ,
    dni_urlopu ,
    obecny ,
    id_roli ,
    id_maszyny
)
VALUES (
    action,
    SYSDATE,
    :new.id_pracownika,
    :new.imie,
    :new.nazwisko,
    :new.data_zatrudnienia,
    :new.pensja,
    :new.dni_urlopu,
    :new.obecny,
    :new.id_roli,
    :new.id_maszyny
);
ELSIF UPDATING THEN
action:='Update';

INSERT into pracownicy_logtable(
    action,
    action_date ,
    id_pracownika,
    imie ,
    nazwisko,
    data_zatrudnienia  ,
    pensja ,
    dni_urlopu ,
    obecny ,
    id_roli ,
    id_maszyny
)
VALUES (
    action,
    SYSDATE,
    :new.id_pracownika,
    :new.imie,
    :new.nazwisko,
    :new.data_zatrudnienia,
    :new.pensja,
    :new.dni_urlopu,
    :new.obecny,
    :new.id_roli,
    :new.id_maszyny
);
ELSIF DELETING THEN
action:='Delete';

INSERT into pracownicy_logtable(
    action,
    action_date ,
    id_pracownika,
    imie ,
    nazwisko,
    data_zatrudnienia  ,
    pensja ,
    dni_urlopu ,
    obecny ,
    id_roli ,
    id_maszyny
)
VALUES (
    action,
    SYSDATE,
    :old.id_pracownika,
    :old.imie,
    :old.nazwisko,
    :old.data_zatrudnienia,
    :old.pensja,
    :old.dni_urlopu,
    :old.obecny,
    :old.id_roli,
    :old.id_maszyny
);
END IF;

END;
/


--==========================================
--                WIDOKI
--==========================================

create or replace view pracownicy_bez_maszyn as 
select id_pracownika, imie, nazwisko
from pracownicy
where id_maszyny  is null; 

--widok pracownikow z poszczegolnej roli
create or replace view magazynier_list as
select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Magazynier';

create or replace view technik_list as
select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Technik';

create or replace view zarzad_list as
select id_pracownika, imie, nazwisko
from pracownicy p join rola r
using (id_roli)
where r.nazwa_roli = 'Zarzad';

create or replace view naprawa_maszyny as
update maszyny
set stopien_zuzycia = '100'
where id_maszyny = any(select id_maszyny
                        from pracownicy
                        where id_roli = 3);

create or replace view sprawdz_zapotrzebowanie as
select p.nazwa, p.ilosc
from produkt p join stan_produktow s
using (id_produktu)
where &id_maszyny  and rodzaj_stanu = 'Z';


create or replace view sprawdz_stan_produktow as
select p.nazwa, p.ilosc
from produkt p join stan_produktow s
using (id_produktu) 
where id_maszyny=&id_maszyny  and rodzaj_stanu = 'o';



create or replace view  bilans as
select sum(CASE WHEN rodzaj_transakcji = 'S' THEN cena else 0 end) as "Suma sprzedazy",
sum(CASE WHEN rodzaj_transakcji = 'K' THEN cena else 0 end) as "Suma kupna",
sum(CASE WHEN rodzaj_transakcji = 'S' THEN cena else 0 end) - sum(CASE WHEN rodzaj_transakcji = 'K' THEN cena else 0 end)as "Zysk"
from transakcje;









--==========================================
--                INSERTY
--==========================================





insert into rola(ID_roli,nazwa_roli,pensja_minimalna,Pensja_maksymalna) values(1,'Pracownik',3000,9000);
insert into rola(ID_roli,nazwa_roli,pensja_minimalna,Pensja_maksymalna) values(2,'Magazynier',4500,12000);
insert into rola(ID_roli,nazwa_roli,pensja_minimalna,Pensja_maksymalna) values(3,'Technik',9000,20000);
insert into rola(ID_roli,nazwa_roli) values(4,'Zarzad');



INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny ) values (6, 'maszyna 1');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny ) values (5, 'maszyna 2');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny) values (45, 'maszyna 3');
INSERT INTO maszyny (stopien_zuzycia,nazwa_maszyny) values (56, 'maszyna 4');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny ) values (78, 'maszyna 5');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny) values (12, 'maszyna 6');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny) values (56, 'maszyna 7');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny) values (89, 'maszyna 8');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny ) values (78, 'maszyna 9');
INSERT INTO maszyny (stopien_zuzycia,nazwa_maszyny) values (54, 'maszyna 10');
INSERT INTO maszyny ( stopien_zuzycia,nazwa_maszyny ) values (64, 'maszyna 11');




insert into produkt( nazwa,ilosc) values ( 'kukurydza', 70);
insert into produkt( nazwa,ilosc) values ( 'kukurydza', 10);
insert into produkt( nazwa,ilosc) values ( 'kukurydza', 15);
insert into produkt( nazwa,ilosc) values ( 'kukurydza', 30);
insert into produkt( nazwa,ilosc) values ( 'kukurydza', 25);

insert into produkt( nazwa,ilosc) values ( 'maka', 150);
insert into produkt( nazwa,ilosc) values ( 'maka', 90);
insert into produkt( nazwa,ilosc) values ( 'maka', 40);
insert into produkt( nazwa,ilosc) values ( 'maka', 20);
insert into produkt( nazwa,ilosc) values ( 'maka', 30);

insert into produkt( nazwa,ilosc) values ( 'kakao', 20);
insert into produkt( nazwa,ilosc) values ( 'kakao', 30);

insert into produkt( nazwa,ilosc) values ( 'miod',10);
insert into produkt( nazwa,ilosc) values ( 'miod', 25);

insert into produkt( nazwa,ilosc) values (  'cukier', 900);
insert into produkt( nazwa,ilosc) values (  'cukier', 450);
insert into produkt( nazwa,ilosc) values (  'cukier', 1000);

insert into produkt( nazwa,ilosc) values (  'syrop',100);
insert into produkt( nazwa,ilosc) values (  'syrop',50);

insert into produkt( nazwa,ilosc) values ( 'sol',1);
insert into produkt( nazwa,ilosc) values ( 'sol',2);

insert into produkt( nazwa,ilosc) values ( 'aromaty',5);
insert into produkt( nazwa,ilosc) values ( 'aromaty',9);

insert into produkt( nazwa,ilosc) values ( 'witaminy',10);
insert into produkt( nazwa,ilosc) values ( 'witaminy',15);

insert into produkt( nazwa,ilosc) values ( 'zelazo',1);
insert into produkt( nazwa,ilosc) values ( 'zelazo',2);


insert into produkt(  nazwa, ilosc) values(  'Kukurydza',2);
insert into produkt(  nazwa, ilosc) values( 'Aromaty',3);
insert into produkt(  nazwa, ilosc) values( 'Witaminy',6);
insert into produkt(  nazwa, ilosc) values( 'zelazo',6);
insert into produkt(  nazwa, ilosc) values(  'Maka',12);
insert into produkt(  nazwa, ilosc) values( 'zelazo',11);
insert into produkt(  nazwa, ilosc) values(  'Maka',12);
insert into produkt(  nazwa, ilosc) values( 'Aromaty',4);
insert into produkt(  nazwa, ilosc) values(  'Cukier',3);
insert into produkt(  nazwa, ilosc) values( 'Sol',8);
insert into produkt(  nazwa, ilosc) values( 'Miod',19);
insert into produkt(  nazwa, ilosc) values( 'Sol',16);
insert into produkt(  nazwa, ilosc) values(  'Kakao',15);
insert into produkt(  nazwa, ilosc) values( 'zelazo',6);
insert into produkt(  nazwa, ilosc) values(  'Cukier',14);
insert into produkt(  nazwa, ilosc) values( 'Sol',16);
insert into produkt(  nazwa, ilosc) values( 'Cukier',6);
insert into produkt(  nazwa, ilosc) values(  'Aromaty',1);
insert into produkt(  nazwa, ilosc) values(  'Aromaty',2);
insert into produkt(  nazwa, ilosc) values( 'Witaminy',18);
insert into produkt(  nazwa, ilosc) values( 'Aromaty',6);
insert into produkt(  nazwa, ilosc) values(  'Aromaty',6);
insert into produkt(  nazwa, ilosc) values(  'zelazo',11);
insert into produkt(  nazwa, ilosc) values(  'Witaminy',3);
insert into produkt(  nazwa, ilosc) values( 'Syrop',8);
insert into produkt(  nazwa, ilosc) values( 'Maka',5);
insert into produkt(  nazwa, ilosc) values( 'zelazo',6);
insert into produkt(  nazwa, ilosc) values( 'Maka',12);
insert into produkt(  nazwa, ilosc) values(  'Witaminy',15);
insert into produkt(  nazwa, ilosc) values( 'Miod',15);

insert into stan_produktow( id_maszyny,rodzaj_stanu)values(1,11,'Z');
insert into stan_produktow( id_maszyny,rodzaj_stanu)values(2,11,'O');
insert into stan_produktow( id_maszyny,rodzaj_stanu)values(6,11,'O');
insert into stan_produktow( id_maszyny,rodzaj_stanu)values(7,11,'Z');


insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(4020,to_date('93/10/13','RR/MM/DD'), 'S' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(4398,to_date('90/7/6','RR/MM/DD'), 'S' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(1993,to_date('97/8/8','RR/MM/DD'), 'S' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(1010,to_date('88/5/19','RR/MM/DD'), 'K' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(5720,to_date('80/5/18','RR/MM/DD'), 'K' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(8281,to_date('87/3/4','RR/MM/DD'), 'S' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(7022,to_date('12/1/24','RR/MM/DD'), 'K' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(4067,to_date('82/11/14','RR/MM/DD'), 'S' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(1385,to_date('90/12/4','RR/MM/DD'), 'K' );
insert into transakcje(  cena,data_zawarcia,rodzaj_transakcji)values(2000,to_date('18/1/24','RR/MM/DD'), 'K' );




insert into tabela_zapisu(id_transakcji,id_produktu)values(4,28);
insert into tabela_zapisu(id_transakcji,id_produktu)values(5,29);
insert into tabela_zapisu(id_transakcji,id_produktu)values(6,30);
insert into tabela_zapisu(id_transakcji,id_produktu)values(7,31);
insert into tabela_zapisu(id_transakcji,id_produktu)values(8,32);
insert into tabela_zapisu(id_transakcji,id_produktu)values(9,33);
insert into tabela_zapisu(id_transakcji,id_produktu)values(2,34);
insert into tabela_zapisu(id_transakcji,id_produktu)values(1,35);
insert into tabela_zapisu(id_transakcji,id_produktu)values(2,36);
insert into tabela_zapisu(id_transakcji,id_produktu)values(3,37);
insert into tabela_zapisu(id_transakcji,id_produktu)values(4,38);
insert into tabela_zapisu(id_transakcji,id_produktu)values(5,39);
insert into tabela_zapisu(id_transakcji,id_produktu)values(6,40);
insert into tabela_zapisu(id_transakcji,id_produktu)values(7,41);
insert into tabela_zapisu(id_transakcji,id_produktu)values(8,42);
insert into tabela_zapisu(id_transakcji,id_produktu)values(9,43);
insert into tabela_zapisu(id_transakcji,id_produktu)values(6,44);
insert into tabela_zapisu(id_transakcji,id_produktu)values(1,45);
insert into tabela_zapisu(id_transakcji,id_produktu)values(2,46);
insert into tabela_zapisu(id_transakcji,id_produktu)values(3,47);
insert into tabela_zapisu(id_transakcji,id_produktu)values(4,48);
insert into tabela_zapisu(id_transakcji,id_produktu)values(5,49);
insert into tabela_zapisu(id_transakcji,id_produktu)values(6,50);
insert into tabela_zapisu(id_transakcji,id_produktu)values(7,51);
insert into tabela_zapisu(id_transakcji,id_produktu)values(8,52);
insert into tabela_zapisu(id_transakcji,id_produktu)values(9,53);
insert into tabela_zapisu(id_transakcji,id_produktu)values(4,54);
insert into tabela_zapisu(id_transakcji,id_produktu)values(1,55);
insert into tabela_zapisu(id_transakcji,id_produktu)values(2,56);






-- brakujace kwerendy

-- usuwanie sprzetu

update pracownicy
set id_maszyny = null
where &id_maszyny = id;

update stan_produktow
set id_maszyny = null
where &id_maszyny = id_maszyny;

delete maszyny
where &id_maszyny = id_maszyny;


--ustawianie pensji pracownika
update pracownicy 
set &pensja
where &id_pracownika;

-- przydzial pracownikow
update pracownicy 
set &id_maszyny
where &id_pracownika;



--dodaj transakcje
create or replace view name as dodaj_transakcje 
insert into transakcje(cena,data_transakcji,rodzaj_transakcji)
values(&cena,todate(&rok,&miesiac,&dzien,'YYYY\MM\DD'),&rodzaj_transakcji);

--usuwanie transakcji
create or replace view name as usun_transakcjce

delete from produkty
where id_produktu = any(select id_produktu 
                        from tabela_zapisu 
                        where &id_transakcji= id_transakcji);
delete from tabela_zapisu 
where &id_transakcji = id_transakcji;

delete from transakcje
where &id_transakcji= id_transakcji;


-- dodawanie produktu

create or replace view name as usuwanie_zapotrzebowania

delete from produkty
where id_produktu = (select id_produktu 
                    from stan_produktow
                    where &id_tabeli);
delete from stan_produktow
where &id_tabeli;

-- dodawanie produktow
create or replace view name as dodwanie_produktow
insert into produkt(nazwa,ilosc)values(&nazwa,&ilosc);

--dodawanie maszyn 
create or replace view name as dodwanie maszyn
insert into maszyny(nazwa_maszyny,stopien_zuzycia) values(&nazwa_maszyny,&stopien_zuzycia);

--dodwanie pracownikow

create or replace view name as dodwanie_pracownikow
