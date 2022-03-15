
USE tickit;

CREATE TABLE IF NOT EXISTS tickit.date
(
    dateid  smallint             not null
        primary key,
    caldate date                 not null,
    day     char(3)              not null,
    week    smallint             not null,
    month   char(5)              not null,
    qtr     char(5)              not null,
    year    smallint             not null,
    holiday tinyint(1) default 0 not null
)
    comment 'TICKIT transaction date details';

CREATE TABLE IF NOT EXISTS tickit.listing
(
    listid         int           not null
        primary key,
    sellerid       int           not null,
    eventid        int           not null,
    dateid         smallint      not null,
    numtickets     smallint      not null,
    priceperticket decimal(8, 2) not null,
    totalprice     decimal(8, 2) not null,
    listtime       timestamp     not null,
    constraint listing_date_dateid_fk
        foreign key (dateid) references date (dateid)
)
    comment 'TICKIT event listings for sale';

CREATE TABLE IF NOT EXISTS tickit.sales
(
    salesid    int           not null
        primary key,
    listid     int           not null,
    sellerid   int           not null,
    buyerid    int           not null,
    eventid    int           not null,
    dateid     smallint      not null,
    qtysold    smallint      not null,
    pricepaid  decimal(8, 2) not null,
    commission decimal(8, 2) not null,
    saletime   varchar(20)   not null,
    constraint sales_listing_listid_fk
        foreign key (listid) references listing (listid)
)
    comment 'TICKIT sales transactions';