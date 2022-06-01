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


INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Honorata','Hrycyk',to_date('3/1/11','RR/MM/DD'),4744,1,13,'W' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Fabian','Klimek',to_date('5/7/15','RR/MM/DD'),4890,1,4,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Magdalena','Kmiecik',to_date('88/5/4','RR/MM/DD'),8422,1,9,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Magdalena','Rataj',to_date('87/11/16','RR/MM/DD'),3343,1,8,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Edyta','Kulas',to_date('3/5/6','RR/MM/DD'),7300,1,17,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Danielak',to_date('91/4/7','RR/MM/DD'),5538,1,2,'W' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Edyta','Klimek',to_date('2/4/6','RR/MM/DD'),3143,1,8,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Cecylia','Kirchner',to_date('87/4/18','RR/MM/DD'),5258,1,9,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Arkadiusz','Ryba',to_date('99/7/5','RR/MM/DD'),3042,1,6,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Czeslaw','Ryba',to_date('94/8/19','RR/MM/DD'),3737,1,0,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Ludwik','Gancarczyk',to_date('12/3/7','RR/MM/DD'),4593,1,3,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Ludwik','Dabek',to_date('7/1/3','RR/MM/DD'),6237,1,15,'W' , 4);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Fabian','Blaszczykowski',to_date('8/2/2','RR/MM/DD'),4483,1,13,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Beata','Stoch',to_date('82/1/24','RR/MM/DD'),8774,1,18,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Paszek',to_date('92/5/4','RR/MM/DD'),8959,1,8,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grzegorz','Michalak',to_date('83/2/21','RR/MM/DD'),8896,1,15,'W' , 4);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Honorata','Kaczor',to_date('87/5/11','RR/MM/DD'),7651,1,3,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Andrzej','Czachor',to_date('12/1/8','RR/MM/DD'),7416,1,7,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Agnieszka','Aleksandrowicz',to_date('18/6/15','RR/MM/DD'),140912,4,6,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Konrad','Jank',to_date('95/2/13','RR/MM/DD'),8534,1,15,'W' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Jagalla',to_date('93/8/11','RR/MM/DD'),5733,1,0,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Ludwik','Rys',to_date('88/5/12','RR/MM/DD'),7437,1,18,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Bartek','Korona',to_date('95/1/10','RR/MM/DD'),8974,1,16,'W' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Agnieszka','Kulas',to_date('97/6/12','RR/MM/DD'),4965,1,18,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Mackiewicz',to_date('99/1/4','RR/MM/DD'),7096,1,0,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Magdalena','Skrok',to_date('94/10/24','RR/MM/DD'),4874,1,15,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jan','Kandefer',to_date('94/1/15','RR/MM/DD'),3366,1,7,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Magdalena','Baran',to_date('17/7/3','RR/MM/DD'),5272,1,1,'W' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Gucwa',to_date('86/8/20','RR/MM/DD'),5767,1,1,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Iwona','Stoch',to_date('91/8/12','RR/MM/DD'),8799,1,3,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Dariusz','Sulej',to_date('80/2/9','RR/MM/DD'),5369,1,14,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jan','Masny',to_date('6/2/4','RR/MM/DD'),6468,2,9,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Edyta','Rys',to_date('19/2/3','RR/MM/DD'),10533,3,4,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Edyta','Kot',to_date('99/3/11','RR/MM/DD'),7576,1,20,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Cecylia','Klimek',to_date('0/2/5','RR/MM/DD'),7796,1,17,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Dariusz','Kowal',to_date('18/11/9','RR/MM/DD'),8913,1,2,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Damian','Jurczyk',to_date('92/6/3','RR/MM/DD'),7808,1,16,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jacek','Gancarczyk',to_date('11/10/6','RR/MM/DD'),4542,1,12,'W' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Karolina','Mackiewicz',to_date('95/4/13','RR/MM/DD'),19718,3,11,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Andrzej','Ochab',to_date('15/3/21','RR/MM/DD'),84486,4,0,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Edyta','Zielonko',to_date('91/3/13','RR/MM/DD'),4729,1,12,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Bartek','Kurtyka',to_date('1/9/10','RR/MM/DD'),4659,1,1,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Maciej','Gut',to_date('8/1/17','RR/MM/DD'),4146,1,7,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jacek','Pakusz',to_date('80/8/5','RR/MM/DD'),8494,1,14,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Fabian','Zielonko',to_date('97/5/17','RR/MM/DD'),5336,1,2,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Ludwik','Kot',to_date('83/1/15','RR/MM/DD'),8947,1,17,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Karolina','Bareja',to_date('98/4/23','RR/MM/DD'),7002,1,0,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jakub','Sulej',to_date('3/3/20','RR/MM/DD'),7958,1,17,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Czeslaw','Krupscy',to_date('1/4/10','RR/MM/DD'),6082,1,10,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Arkadiusz','Gucwa',to_date('89/10/2','RR/MM/DD'),4054,1,14,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jakub','Zarzecki',to_date('19/12/7','RR/MM/DD'),4170,1,8,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Magdalena','Gut',to_date('12/12/10','RR/MM/DD'),5266,1,8,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Iwona','Rusek',to_date('14/1/4','RR/MM/DD'),5017,1,16,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Arkadiusz','Tasior',to_date('0/3/12','RR/MM/DD'),4840,1,11,'W' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Konrad','Rusek',to_date('12/3/13','RR/MM/DD'),3121,1,10,'W' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Grzegorz','Zarzecki',to_date('94/6/15','RR/MM/DD'),6615,2,11,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Beata','Ochab',to_date('99/9/7','RR/MM/DD'),3690,1,13,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Fabian','Imielinski',to_date('88/6/23','RR/MM/DD'),3817,1,19,'O' , 4);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Cecylia','Hrycyk',to_date('1/11/25','RR/MM/DD'),3359,1,17,'W' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Pakusz',to_date('10/11/22','RR/MM/DD'),7664,2,20,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Beata','Orski',to_date('90/9/15','RR/MM/DD'),7474,1,17,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Bartek','Aleksandrowicz',to_date('5/2/18','RR/MM/DD'),4732,1,9,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Czeslaw','Fikus',to_date('81/3/21','RR/MM/DD'),3931,1,6,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Czeslaw','Dziuba',to_date('99/11/14','RR/MM/DD'),3716,1,9,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Dariusz','Piecha',to_date('2/12/2','RR/MM/DD'),3255,1,19,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Agnieszka','Gorka',to_date('93/5/18','RR/MM/DD'),5508,1,3,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Konrad','Rys',to_date('18/4/21','RR/MM/DD'),5287,1,9,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Fabian','Gucwa',to_date('13/2/19','RR/MM/DD'),4615,1,9,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Honorata','Aleksandrowicz',to_date('98/10/1','RR/MM/DD'),6070,1,1,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Kulas',to_date('4/5/3','RR/MM/DD'),3609,1,11,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Bareja',to_date('98/3/11','RR/MM/DD'),7707,1,0,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Arkadiusz','Rys',to_date('83/10/7','RR/MM/DD'),5108,1,15,'W' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Beata','Rusek',to_date('12/2/7','RR/MM/DD'),8918,1,12,'W' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Damian','Kurtyka',to_date('91/11/13','RR/MM/DD'),5449,1,17,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Iwona','Wilk',to_date('14/12/13','RR/MM/DD'),8057,1,17,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Dariusz','Kicki',to_date('81/10/24','RR/MM/DD'),3000,1,20,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Czeslaw','Ryba',to_date('95/6/4','RR/MM/DD'),4957,1,9,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Magdalena','Kozubek',to_date('8/7/20','RR/MM/DD'),10386,2,20,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Ludwik','Tasior',to_date('1/5/4','RR/MM/DD'),6656,1,0,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Maciej','Wilk',to_date('4/3/6','RR/MM/DD'),6216,1,7,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Leja',to_date('13/12/15','RR/MM/DD'),4016,1,17,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Ludwik','Wolny',to_date('14/7/20','RR/MM/DD'),5763,1,10,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Iwona','Kirchner',to_date('82/11/6','RR/MM/DD'),5044,1,9,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Czeslaw','Kubicz',to_date('89/10/13','RR/MM/DD'),3687,1,16,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jakub','Michalak',to_date('99/8/1','RR/MM/DD'),8576,1,15,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Konrad','Gawron',to_date('7/5/19','RR/MM/DD'),3476,1,6,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Czeslaw','Czachor',to_date('89/8/25','RR/MM/DD'),7809,1,3,'W' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Kirchner',to_date('17/12/9','RR/MM/DD'),11074,2,8,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jan','Dziuba',to_date('9/12/25','RR/MM/DD'),8787,1,16,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Dabek',to_date('0/1/8','RR/MM/DD'),3207,1,10,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Grazyna','Hejmo',to_date('81/11/1','RR/MM/DD'),7582,2,17,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Stoch',to_date('98/10/2','RR/MM/DD'),8416,1,9,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Beata','Larek',to_date('95/4/2','RR/MM/DD'),3754,1,5,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Honorata','Masny',to_date('99/3/24','RR/MM/DD'),6111,1,13,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Karolina','Hrycyk',to_date('92/5/20','RR/MM/DD'),7850,1,4,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Paliwoda',to_date('89/4/8','RR/MM/DD'),8283,1,4,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Klimek',to_date('5/5/6','RR/MM/DD'),8790,1,16,'O' , 9);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Czeslaw','Hejmo',to_date('15/11/6','RR/MM/DD'),5557,1,14,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Beata','Hejmo',to_date('82/7/6','RR/MM/DD'),14288,3,15,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grzegorz','Piecha',to_date('85/1/7','RR/MM/DD'),7060,1,19,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Damian','Otys',to_date('81/6/12','RR/MM/DD'),5425,1,4,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Konrad','Hrycyk',to_date('80/10/14','RR/MM/DD'),3799,1,4,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Iwona','Kwiek',to_date('93/6/10','RR/MM/DD'),3877,1,6,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Dariusz','Fikus',to_date('93/12/12','RR/MM/DD'),3987,1,5,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Damian','Rys',to_date('8/10/9','RR/MM/DD'),7771,1,12,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Jakub','Rataj',to_date('12/11/19','RR/MM/DD'),5853,1,16,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Fikus',to_date('80/4/20','RR/MM/DD'),3363,1,4,'O' , 4);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Edyta','Chmiel',to_date('86/8/23','RR/MM/DD'),5022,1,17,'O' , 7);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grazyna','Gut',to_date('1/1/19','RR/MM/DD'),5838,1,8,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jan','Larek',to_date('92/9/9','RR/MM/DD'),7616,1,6,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Beata','Gasienica',to_date('92/7/9','RR/MM/DD'),12227,3,13,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Jan','Gancarczyk',to_date('11/3/21','RR/MM/DD'),4254,1,11,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Bartek','Pakusz',to_date('82/7/3','RR/MM/DD'),6933,1,13,'O' , 4);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Dariusz','Baran',to_date('13/4/11','RR/MM/DD'),6096,1,18,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jacek','Gucwa',to_date('11/4/4','RR/MM/DD'),6147,1,1,'O' , 10);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Ludwik','Tarczynski',to_date('90/8/18','RR/MM/DD'),8037,1,11,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jakub','Gradzik',to_date('10/7/17','RR/MM/DD'),6471,1,3,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Agnieszka','Pawlak',to_date('12/1/23','RR/MM/DD'),4918,1,1,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Grzegorz','Panus',to_date('16/11/11','RR/MM/DD'),4757,1,9,'O' , 2);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Iwona','Stoch',to_date('91/12/15','RR/MM/DD'),5748,1,12,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Andrzej','Gancarczyk',to_date('91/11/20','RR/MM/DD'),6741,1,12,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jakub','Hernik',to_date('0/5/22','RR/MM/DD'),8528,1,4,'O' , 1);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Konrad','Ryba',to_date('87/7/2','RR/MM/DD'),3282,1,14,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Konrad','Borys',to_date('16/2/6','RR/MM/DD'),4283,1,13,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Magdalena','Wasiak',to_date('92/9/2','RR/MM/DD'),4190,1,0,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Cecylia','Tyszka',to_date('15/5/23','RR/MM/DD'),3352,1,19,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Fabian','Kmiecik',to_date('9/5/25','RR/MM/DD'),4179,1,3,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Ignacy','Antos',to_date('4/5/8','RR/MM/DD'),5300,1,9,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Magdalena','Sulej',to_date('15/8/25','RR/MM/DD'),4438,1,16,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Agnieszka','Redyk',to_date('7/4/20','RR/MM/DD'),5089,1,17,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Larek',to_date('11/1/6','RR/MM/DD'),7772,1,11,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Bartek','Kandefer',to_date('20/6/8','RR/MM/DD'),3194,1,15,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Jakub','Imielinski',to_date('96/11/3','RR/MM/DD'),5210,2,6,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Jan','Leja',to_date('89/11/14','RR/MM/DD'),8966,1,13,'O' , 8);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Stoch',to_date('6/7/1','RR/MM/DD'),3212,1,2,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Daniel','Kaczor',to_date('14/12/8','RR/MM/DD'),5166,1,3,'O' , 3);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Edyta','Pawlak',to_date('82/2/11','RR/MM/DD'),7547,1,8,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Hubert','Bury',to_date('87/9/4','RR/MM/DD'),6964,1,8,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Fabian','Obrebscy',to_date('20/12/3','RR/MM/DD'),18473,3,13,'W');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Jacek','Rys',to_date('17/1/12','RR/MM/DD'),4458,1,12,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Ludwik','Obrebscy',to_date('15/7/11','RR/MM/DD'),4905,1,11,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Ignacy','Orski',to_date('5/9/22','RR/MM/DD'),7725,1,2,'O' , 5);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Bartek','Fogiel',to_date('90/3/15','RR/MM/DD'),8655,1,15,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Edyta','Otys',to_date('16/10/8','RR/MM/DD'),3993,1,6,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Hubert','Ryba',to_date('14/9/20','RR/MM/DD'),6679,1,0,'O' , 11);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Honorata','Gradzik',to_date('93/12/25','RR/MM/DD'),5630,1,4,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Beata','Kaczor',to_date('1/9/8','RR/MM/DD'),4690,1,11,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Daniel','Tasior',to_date('18/12/13','RR/MM/DD'),4428,1,6,'O');
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny, id_maszyny  ) values( 'Fabian','Adamiak',to_date('97/12/6','RR/MM/DD'),6411,1,6,'O' , 6);
INSERT INTO pracownicy (  imie ,nazwisko, data_zatrudnienia , pensja , ID_roli, dni_urlopu, obecny ) values( 'Jakub','Gancarczyk',to_date('96/2/24','RR/MM/DD'),7035,1,6,'O');




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

insert into produkt( nazwa,ilosc) values ( 'kukurydza', 7900);
insert into produkt( nazwa,ilosc) values ( 'maka', 1350);
insert into produkt( nazwa,ilosc) values ( 'kakao', 2890);
insert into produkt( nazwa,ilosc) values ( 'miod',180);
insert into produkt( nazwa,ilosc) values (  'cukier', 6900);
insert into produkt( nazwa,ilosc) values (  'syrop',8100);
insert into produkt( nazwa,ilosc) values ( 'sol',190);
insert into produkt( nazwa,ilosc) values ( 'aromaty',75);
insert into produkt( nazwa,ilosc) values ( 'witaminy',310);
insert into produkt( nazwa,ilosc) values ( 'zelazo',18);

insert into magazyn(sektor,id_produktu) values ( 'kukurydza',58 );
insert into magazyn(sektor,id_produktu) values ( 'maka', 59);
insert into magazyn(sektor,id_produktu) values ( 'kakao', 60);
insert into magazyn(sektor,id_produktu) values ( 'miod',61);
insert into magazyn(sektor,id_produktu) values (  'cukier',62 );
insert into magazyn(sektor,id_produktu)values (  'syrop',63);
insert into magazyn(sektor,id_produktu)values ( 'sol',64);
insert into magazyn(sektor,id_produktu)values ( 'aromaty',65);
insert into magazyn(sektor,id_produktu)values ( 'witaminy',66);
insert into magazyn(sektor,id_produktu)values ( 'zelazo',67);


insert into stan_produktow( id_produktu,id_maszyny,rodzaj_stanu)values(1,11,'Z');
insert into stan_produktow( id_produktu,id_maszyny,rodzaj_stanu)values(2,11,'O');
insert into stan_produktow(id_produktu, id_maszyny,rodzaj_stanu)values(6,11,'O');
insert into stan_produktow(id_produktu, id_maszyny,rodzaj_stanu)values(7,11,'Z');


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


