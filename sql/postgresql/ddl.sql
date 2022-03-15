CREATE SCHEMA IF NOT EXISTS saas;

CREATE TABLE IF NOT EXISTS saas.venue
(
    venueid    smallint not null
        constraint venue_pk
            primary key,
    venuename  varchar(100),
    venuecity  varchar(30),
    venuestate char(2),
    venueseats integer
);

alter table saas.venue
    owner to lakeformationpostgrestickit;

CREATE TABLE IF NOT EXISTS saas.category
(
    catid    smallint not null
        constraint category_pk
            primary key,
    catgroup varchar(10),
    catname  varchar(10),
    catdesc  varchar(50)
);

alter table saas.category
    owner to lakeformationpostgrestickit;

CREATE TABLE IF NOT EXISTS saas.event
(
    eventid   integer  not null
        constraint event_pk
            primary key,
    venueid   smallint not null
        constraint event_venue_venueid_fk
            references saas.venue,
    catid     smallint not null
        constraint event_category_catid_fk
            references saas.category,
    dateid    smallint not null,
    eventname varchar(200),
    starttime timestamp
);

alter table saas.event
    owner to lakeformationpostgrestickit;

CREATE TABLE IF NOT EXISTS saas.users
(
    userid        integer not null
        constraint users_pk
            primary key,
    username      char(8),
    firstname     varchar(30),
    lastname      varchar(30),
    city          varchar(30),
    state         char(2),
    email         varchar(100),
    phone         char(14),
    likesports    boolean,
    liketheatre   boolean,
    likeconcerts  boolean,
    likejazz      boolean,
    likeclassical boolean,
    likeopera     boolean,
    likerock      boolean,
    likevegas     boolean,
    likebroadway  boolean,
    likemusicals  boolean
);

alter table saas.users
    owner to lakeformationpostgrestickit;

