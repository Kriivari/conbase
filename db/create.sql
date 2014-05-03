create table statusnames (status serial primary key, name text, persongroup boolean, program boolean, orders boolean);
insert into statusnames values (-2,'Pyyntö', true, true, true);
insert into statusnames values (-1,'Vahvistettu', true, true, true);
insert into statusnames values (-3,'Vanha', true, false, false);
insert into statusnames values (-4,'Peruutettu', true, true, false);
insert into statusnames values (-5,'Coniitti', false, true, false);
insert into statusnames values (-6,'Pääjärjestäjä', false, true, false);
insert into statusnames values (-7,'Järjestäjä', false, true, false);

create table events (id serial primary key, name varchar(50), year integer, 
starttime timestamp, endtime timestamp, ispublic boolean, footer text, 
registration text, ticketprice integer, tableprice integer, 
shirtorder boolean);
insert into events (name, year, starttime, endtime, ispublic, shirtorder) 
values
('Ropecon', 2007, '2007-08-10 15:00:00', '2007-08-12 19:00:00', true, false);

create table people (id serial primary key, firstname varchar(30),
lastname varchar(30), nickname varchar(30), street varchar(50),
zipcode varchar(10), city varchar(30), country varchar(30),
primary_phone varchar(20), cv text, notes text, shirttext varchar(30),
primary_email varchar(50) unique, password varchar(30), 
birthyear integer, photo_url varchar(255), created_at timestamp,
changed_at timestamp);
insert into people (firstname, lastname, primary_email, password)
values ('Ylläpito','root','tuki@ropecon.fi','P4451t0rn1');

create table contacts (id serial primary key, 
person_id integer references people(id) on delete cascade,
contact_type integer, contact_value varchar(50));

create table mailinglists (id serial primary key, 
parent_id integer references mailinglists(id), name varchar(50),
address varchar(100), autoadd boolean, autodelete boolean,
autoupdate boolean, notes text, template text);
insert into mailinglists (id, name, address, autoadd, autodelete, autoupdate)
values (-1, 'Conitea', 'conitea@ropecon.fi', true, false, false);
insert into mailinglists (id, name, address, autoadd, autodelete, autoupdate)
values (-2, 'Työnsankarit', 'tyonsankarit@ropecon.fi', true, false, false);
insert into mailinglists (id, name, address, autoadd, autodelete, autoupdate)
values (-3, 'GM:ien infolista', 'gm-tiedotus@ropecon.fi', true, false, false);
insert into mailinglists (id, name, address, autoadd, autodelete, autoupdate)
values (-4, 'Ohjelman tiedotuslista', 'ohjelma-tiedotus@ropecon.fi', true,
false, false);

create table persongroups (id serial primary key, 
event_id integer references events(id) on delete cascade, name varchar(50),
description text,
mailinglist_id integer references mailinglists(id), days integer, food integer,
visible boolean, continues boolean, admin boolean, insurance boolean, 
nonstaff boolean, notes text, welcomesubject text, adminemail text, footer text);
insert into persongroups (event_id, name, days, food, visible, continues, admin, insurance, mailinglist_id)
values (1, 'Conitea', 3, 2, false, true, true, true, -1);
insert into persongroups (event_id, name, days, food, visible, continues, mailinglist_id)
values (1, 'GM', 3, 0, false, false, -3);
insert into persongroups (event_id, name, days, food, visible, continues, insurance, mailinglist_id)
values (1, 'Narikka', 3, 0, true, false, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues, insurance, mailinglist_id)
values (1, 'Majoitus', 3, 0, true, false, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues, insurance, mailinglist_id)
values (1, 'Kaubamaja', 3, 0, true, false, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues, insurance, mailinglist_id)
values (1, 'Lipunmyynti', 3, 0, true, false, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues, admin, insurance, mailinglist_id)
values (1, 'TS-Info', 3, 0, true, false, true, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues, insurance, mailinglist_id)
values (1, 'Varatyövoima', 3, 2, false, false, true, -2);
insert into persongroups (event_id, name, days, food, visible, continues)
values (1, 'Peruneet', 0, 0, false, false);
insert into persongroups (event_id, name, days, food, visible, continues)
values (1, 'Jono', 0, 0, false, false);

create table people_persongroups (id serial primary key,
person_id integer references people(id) on delete cascade,
persongroup_id integer references persongroups(id) on delete cascade,
status integer references statusnames(status) on delete cascade,
created_at timestamp);
insert into people_persongroups (person_id, persongroup_id, status)
values (1, 1, -1);

create table attributes (id serial primary key, name varchar(50),
visible boolean, person boolean, program boolean, orders boolean);
insert into attributes (name, visible, program) values ('Genre', true, false, true, false);
insert into attributes (name, visible, person) values ('Staff-paita', true, true, false, false);
insert into attributes (name, visible, person) values ('JV-kortti', true, true, false, false);
insert into attributes (name, visible, orders) values ('Esitystekniikka', true, false, false, true);
insert into attributes (name, visible, orders) values ('IT-tekniikka', true, false, false, true);

create table attribute_values (id serial primary key, 
attribute_id integer references attributes(id) on delete cascade,
value varchar(100), defaultvalue boolean, visible boolean);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'Kauhu', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'Sci-fi', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'Uuskumma', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'World of Darkness', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'Fantasia', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (1, 'Muu', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'En halua paitaa', true);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen XXXL', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen XXL', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen XL', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen L', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen M', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Tavallinen S', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Ladyfit XS', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Ladyfit S', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Ladyfit M', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Ladyfit L', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (2, 'Ladyfit XL', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (3, 'K', false);
insert into attribute_values (attribute_id, value, defaultvalue)
values (3, 'E', true);

create table people_events_attributes (id serial primary key,
person_id integer references people(id) on delete cascade,
event_id integer references events(id) on delete cascade, 
attribute_id integer references attributes(id) on delete cascade,
value varchar(100), notes text);

create table locations (id serial primary key, 
event_id integer references events(id) on delete cascade, name varchar(100),
notes text, start_time timestamp, end_time timestamp, multiple boolean);
insert into locations (event_id, name) values (1, 'Smökki');
insert into locations (event_id, name) values (1, 'Rantasauna');
insert into locations (event_id, name) values (1, 'Gorsu');
insert into locations (event_id, name) values (1, 'Alvarin aukio');
insert into locations (event_id, name) values (1, 'Klondyke');
insert into locations (event_id, name) values (1, 'Takka');
insert into locations (event_id, name) values (1, 'Poli');
insert into locations (event_id, name) values (1, 'Palaver');
insert into locations (event_id, name) values (1, 'Luolamies');
insert into locations (event_id, name) values (1, '1-sali');
insert into locations (event_id, name) values (1, '2-sali');
insert into locations (event_id, name) values (1, '3-sali');
insert into locations (event_id, name) values (1, 'Auditorio');

create table programs (id serial primary key, 
event_id integer references events(id) on delete cascade, name text,
description text, publicnotes text, privatenotes text, url text, 
attendance integer, status integer, changed_at timestamp);

create table programs_events_attributes (id serial primary key,
program_id integer references programs(id) on delete cascade,
event_id integer references events(id) on delete cascade, 
attribute_id integer references attributes(id) on delete cascade,
value varchar(100));

create table programs_organizers (id serial primary key, program_id integer references programs(id)
on delete cascade, person_id integer references people(id) on delete cascade,
orgtype integer references statusnames(status));

create table programitems (id serial primary key,
program_id integer references programs(id) on delete cascade,
name varchar(100), description text,
location_id integer references locations(id) on delete cascade,
start_time timestamp, end_time timestamp);

create table programgroups (id serial primary key, name varchar(50),
visible boolean, primarygroup boolean, mailinglist_id integer references mailinglists(id));

create table programs_programgroups (program_id integer references
programs(id) on delete cascade,
programgroup_id integer references programgroups(id) on delete cascade);

create table program_languages (id serial primary key, program_id integer references programs(id)
on delete cascade, language varchar(20), name text, description text,
publicnotes text);

create table programitem_languages (id serial primary key, programitem_id integer references
programitems(id) on delete cascade, language varchar(20), name text,
description text);

create table schedules (id serial primary key,
people_persongroup_id integer references people_persongroups(id) on delete cascade,
starttime timestamp, endtime timestamp);

create table orders (id serial primary key,
event_id integer references events(id),
person_id integer references people(id) on delete cascade, 
owner_id integer references people(id) on delete cascade, name text,
destination text, notes text, needed timestamp, released timestamp,
status integer references statusnames(status), commentlog text);

create table orderitems (id serial primary key,
order_id integer references orders(id) on delete cascade, name text, 
location text, notes text, deliverydate timestamp,
cost float, maxcost float, actualcost float,
status integer references statusnames(status));

create table orders_attributes (id serial primary key,
order_id integer references orders(id) on delete cascade,
attribute_id integer references attributes(id), value text, notes text);

create table note (id serial primary key, title text, body text,
starttime timestamp, endtime timestamp, important boolean,
event_id integer references events(id));

create table exhibitors (id serial primary key, 
person_id integer references people(id) on delete cascade,
companyname text, publicname text, description text, tables integer, 
tickets integer, tablesize text, travelpasses integer, notes text);
