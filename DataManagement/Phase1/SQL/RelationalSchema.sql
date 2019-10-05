/*
 * Group 6 - Phase 1.
 * Script written on: Microsoft SQL Server.
 * The script creates a relational schema for the IMDb dataset.
 **/
create database imdb;
go

use imdb;
go

-- title (primaryTitle, originalTitle, startYear, isAdult, averageRating, numVotes)
create table title (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  isAdult bit not null,
  startYear smallint,
  runtimeInMinutes smallint,
  averageRating float,
  numVotes int,
  primary key (primaryTitle, originalTitle, startYear)
);
go

-- titleGenre (primaryTitle, originalTitle, startYear, genre)
create table titleGenres (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  genre varchar(50),
  primary key (primaryTitle, originalTitle, startYear, genre),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- alternateTitle (primaryTitle, originalTitle, startYear, language, title, region)
create table alternateTitle (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  language varchar(10) not null,
  title varchar(410) not null,
  region varchar(10) not null,
  primary key (primaryTitle, originalTitle, startYear, language, title, region),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- alternateTitleTypes (primaryTitle, originalTitle, startYear, language, title, region, type)
create table alternateTitleTypes (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  language varchar(10) not null,
  title varchar(410) not null,
  region varchar(10) not null,
  type varchar(50) not null,
  primary key (primaryTitle, originalTitle, startYear, language, title, region, type),
  foreign key (primaryTitle, originalTitle, startYear, language, title, region) references alternateTitle(primaryTitle, originalTitle, startYear, language, title, region)
);
go

-- tvSeries (tconst, endYear)
create table tvSeries (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  endYear int,
  primary key (primaryTitle, originalTitle, startYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- tvEpisode (primaryTitle, originalTitle, startYear, seriesPrimaryTitle, seriesOriginalTitle, seriesStartYear, seasonNumber, episodeNumber)
create table tvEpisode (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  seriesPrimaryTitle varchar(410) not null,
  seriesOriginalTitle varchar(410) not null,
  seriesstartYear smallint not null,
  seasonNumber integer not null,
  episodeNumber integer not null,
  primary key (primaryTitle, originalTitle, startYear, seriesPrimaryTitle, seriesOriginalTitle, seriesStartYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear),
  foreign key (seriesPrimaryTitle, seriesOriginalTitle, seriesStartYear) references tvSeries(primaryTitle, originalTitle, startYear)
);
go

-- movie (primaryTitle, originalTitle, startYear, movieType)
create table movie (
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  movieType varchar(20),
  primary key (primaryTitle, originalTitle, startYear, movieType),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- name (primaryName, birthYear, deathYear)
create table name (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  deathYear int,
  primary key (primaryName, birthYear)
);
go

-- namePrimaryProfession (primaryName, birthYear, primaryProfession)
create table namePrimaryProfession (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryProfession nvarchar(200),
  primary key (primaryName, birthYear, primaryProfession),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear)
);
go

-- writers (primaryName, birthYear, primaryTitle, originalTitle, startYear)
create table writers (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  primary key (primaryName, birthYear, primaryTitle, originalTitle, startYear),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- directors (primaryName, birthYear, primaryTitle, originalTitle, startYear)
create table directors (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  primary key (primaryName, birthYear, primaryTitle, originalTitle, startYear),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- popularTitles (primaryName, birthYear, primaryTitle, originalTitle, startYear)
create table popularTitles (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  primary key (primaryName, birthYear, primaryTitle, originalTitle, startYear),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- principalCast (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job)
create table principalCast (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  category varchar(100) not null,
  job varchar(200),
  primary key (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go

-- principalCastCharacters (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job, character)
create table principalCastCharacters (
  primaryName nvarchar(200) not null,
  birthYear int not null,
  primaryTitle varchar(410) not null,
  originalTitle varchar(410) not null,
  startYear smallint not null,
  category varchar(100) not null,
  job varchar(200),
  [character] nvarchar(200),
  primary key (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job, [character]),
  foreign key (primaryName, birthYear) references name (primaryName, birthYear),
  foreign key (primaryTitle, originalTitle, startYear) references title(primaryTitle, originalTitle, startYear)
);
go
