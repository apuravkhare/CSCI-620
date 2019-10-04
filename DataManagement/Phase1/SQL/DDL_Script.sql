create database if not exists imdb;
use imdb;

-- title (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, averageRating, numVotes)
create table if not exists title (
  tconst varchar(20) primary key,
  primaryTitle nvarchar(500) not null,
  originalTitle nvarchar(500) not null,
  isAdult bool not null,
  startYear int,
  runtimeInMinutes integer,
  averageRating float,
  numVotes int
);

-- title_genre (tconst, genre)
create table title_genre (
  tconst varchar(20) references title(tconst),
  genre nvarchar(100),
  primary key (tconst, genre)
);

-- tvSeries (tconst, endYear)
create table tvSeries (
  tconst varchar(20) references title(tconst),
  endYear int,
  primary key (tconst)
);

/*
tvSeries, tvMiniSeries
tvEpisode

videoGame,video,tvSpecial,tvShort,tvMovie,short,movie
*/
-- movie (tconst, movieType)
create table movie (
  tconst varchar(20) references title(tconst),
  movieType varchar(20),
  primary key (tconst)
);

-- tvEpisode (tconst, parentTconst, seasonNumber, episodeNumber)
create table tvEpisode (
  tconst varchar(20) references title(tconst),
  parentTconst varchar(20) references tvSeries(tconst),
  seasonNumber integer,
  episodeNumber integer,
  primary key (tconst, parentTconst)
);

-- alternate_title (tconst, language, title, region, isOriginal)
create table alternateTitle (
  tconst varchar(20) references title(tconst),
  language varchar(10),
  title nvarchar(500),
  region varchar(10),
  isOriginal bool,
  primary key (tconst, language, title, region)
);

-- alternate_title_types (tconst, language, title, region, type)
create table alternateTitleTypes (
  tconst varchar(20) references title(tconst),
  language varchar(10),
  title nvarchar(500),
  region varchar(10),
  type varchar(50),
  primary key (tconst, language, title, region, type)
);

-- name (nconst, primaryName, birthYear, deathYear)
create table name (
  nconst varchar(20) primary key,
  primaryName nvarchar(200) not null,
  birthYear int,
  deathYear int
);

-- namePrimaryProfession (nconst, primaryProfession)
create table namePrimaryProfession (
  nconst varchar(20) references name(nconst),
  primaryProfession nvarchar(200),
  primary key (nconst, primaryProfession)
);

-- crew (nconst, tconst, role)
create table crew (
  nconst varchar(20) references name(nconst),
  tconst varchar(20) references title(tconst),
  role varchar(20),
  primary key (nconst, tconst, role)
);

-- popular_titles (tconst, nconst)
create table popularTitles (
  tconst varchar(20) references title(tconst),
  nconst varchar(20) references name(nconst),
  primary key (nconst, tconst)
);

-- principal (tconst, nconst, category, job)
create table principal (
  tconst varchar(20) references title(tconst),
  nconst varchar(20) references name(nconst),
  category varchar(100) not null,
  job varchar(200),
  primary key (tconst, nconst, category, job)
);

-- principal_characters (tconst, nconst, category, job, characters)
create table principalCharacters (
  tconst varchar(20) references principal(tconst),
  nconst varchar(20) references principal(nconst),
  category varchar(100) references principal(category),
  job varchar(200) references principal(job),
  `character` nvarchar(200),
  primary key (tconst, nconst, category, job, `character`)
);