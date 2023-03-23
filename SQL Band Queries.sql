-- Query bands and their respective album's release dates in descending order

select b.bandname as 'Band Name', a.releasedate as 'Release Date'
from band_db.album a
join band_db.band b
on a.idband = b.idband
order by a.releasedate desc;

-- Query bands that have drummers. List full player name in one column

select concat(p.pfname, ' ',p.plname) as 'Player Name', b.bandname as 'Band Name', i.instrument as 'Instrument'
from band_db.band b 
join band_db.player p 
on b.idband = p.idband
join band_db.instrument i 
on i.instID = p.InstID
where i.instrument = 'Drums';

-- Query number of instruments used by each band

select b.bandname as 'Band Name', count(distinct i.instrument) as 'Number of Different Instruments in Band'
from band_db.band b 
join band_db.player p 
on b.idband = p.idband
join band_db.instrument i 
on i.instID = p.InstID
Group by b.bandname;

-- Query most popular instrument amongst the players

select count(i.instrument) as 'Number of Instrument',i.instrument as 'Instrument'
from band_db.band b 
join band_db.player p 
on b.idband = p.idband
join band_db.instrument i 
on i.instID = p.InstID

Group by i.instrument
order by i.instrument desc
limit 1

-- Query any albums that have missing name or release dates

select albumname,releasedate,idalbum
from band_db.album
where albumname is null or releasedate is null

/* What to do about these nulls? 
It depends on what the stakeholder is looking for, but I would likely delete the record missing both title and release date data, as it is missing a significant amount of data.
The record missing release date I would probably keep and filter it out if my query is regarding release date. Especially since this data set is not very large, I would likely want to keep it as a data point for other queries.
*/

-- Add bands to band table

insert into band_db.band (bandname,aid)
values ('Weezer',1),('TLC',1),('Paramore',1),('Blackpink',1),('Vampire Weekend',1)

-- Add players to newly added bands

select idband,bandname from band_db.band
where bandname IN('Weezer','Paramore','TLC','Blackpink','Vampire Weekend') -- Query to pull up band id's for bandnames

select instid,instrument from band_db.instrument --  Query to pull up instrument Id for instruments

insert into band_db.player (instid,idband,pfname,plname,homecity,homestate)
values (3,22,'Rivers','Cuomo','Rochester','New York'),
(1,22,'Brian','Bell','Iowa City','Iowa'),
(4,22,'Patrick','Wilson','Buffalo','New York'),
(2,22,'Scott','Shriner','Toledo','Ohio'),
(3,23,'Tionne','Watkins','Des Moines','Iowa'),
(3,23,'Rozonda','Thomas','Columbus','Georgia'),
(3,24,'Hayley','Williams','Franklin','Tennessee'),
(1,24,'Taylor','York','Nashville','Tennessee'),
(4,24,'Zac','Farro','Voorhees Township','New Jersey'),
(3,25,'Jisoo','Kim',null,'South Korea'),
(3,25,'Jennie','Kim',null,'South Korea'),
(3,25,'Roseanne','Park',null,'New Zealand'),
(3,25,'Lisa','Monaban',null,'Thailand'),
(3,26,'Ezra','Koenig','New York','New York'),
(2,26,'Chris','Baio','Broxville','New York'),
(4,26,'Chris','Tomson','Upper Freehold Township','New Jersey')

/* The idplayer was assigned automatically since the table was set up with the idplayer field being the primary key
 and having the idplayer set as auto-increment for new entries. Below is the end of the player table showing the
 new entries correctly entered.
*/

-- Query which state has the largest amount of seating available in their venues

select sum(seats), state
from band_db.venue
group by state
order by sum(seats) desc
limit 1

-- Query venues oversold

select v.seats,g.numattendees,v.vname
from band_db.venue v 
join band_db.gig g 
on v.idvenue = g.idvenue
where v.seats < g.numattendees

/* Create a view showing band, concert dates, concert venue, 
num of attendees, venue capacity, and % of venue capacity utilized
*/

create view band_db.vwgiginfo as
select b.bandname,g.gigdate,v.vname,g.numattendees,v.seats,round((g.numattendees/v.seats)*100) as 'Usage Percentage'
from band_db.band b 
join band_db.gig g 
on b.idband=g.idband
join band_db.venue v 
on v.idvenue=g.idvenue

/* Create Stored Procedure that lists all the players that come from a specific state. 
sproc should return band name, player full name and state that they are from
*/

delimiter //
Create Procedure band_db.Player_by_state (IN state varchar (50))
begin
	select concat(p.pfname,' ',p.plname)as 'Player Name',b.bandname as 'Band Name',p.homestate as 'Home State'
    from band_db.player p 
    join band_db.band b 
    on p.idband = b.idband
    where p.homestate like state;
END//

