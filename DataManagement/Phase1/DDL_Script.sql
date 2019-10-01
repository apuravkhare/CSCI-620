-- create database imdb;
use imdb;

-- title (tconst, titleType, primaryTitle, originalTitle, isAdult, startYear, endYear, averageRating, numVotes)
create table title (
  tconst varchar(20) primary key,
  title_type varchar(20) not null,
  primary_title nvarchar(500) not null,
  original_title nvarchar(500) not null,
  is_adult bool not null,
  start_year int not null,
  end_year int,
  average_rating float,
  num_votes int
);

-- genres (genre)
create table genres (
  genre nvarchar(100) primary key
);

-- title_genre (tconst, genre)
create table title_genre (
  tconst varchar(20) references title(tconst),
  genre nvarchar(100) references genres(genre),
  primary key (tconst, genre)
);

-- episode (tconst, parent_tconst, seasonNumber, episodeNumber)
create table episode (
  tconst varchar(20) primary key,
  parent_tconst varchar(20) references title(tconst),
  season_number int,
  episode_number int
);

-- alternate_title (tconst, language, title, region, isOriginal)
create table alternate_title (
  tconst varchar(20) references title(tconst),
  language varchar(10),
  title nvarchar(500),
  region varchar(10),
  is_original bool,
  primary key (tconst, language, title, region)
);

-- alternate_title_types (tconst, language, title, region, type)
create table alternate_title_types (
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
  primary_name nvarchar(200) not null,
  birth_year int,
  death_year int
);

-- name_primary_profession (nconst, primary_profession)
create table name_primary_profession (
  nconst varchar(20) references name(nconst),
  primary_profession nvarchar(200),
  primary key (nconst, primary_profession)
);

create table crew_role_type (
  role_type varchar(20) primary key
);

-- crew (nconst, tconst, role)
create table crew (
  nconst varchar(20) references name(nconst),
  tconst varchar(20) references title(tconst),
  role varchar(20) references crew_role_type(role_type),
  primary key (nconst, tconst, role)
);

-- popular_titles (tconst, nconst)
create table popular_titles (
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
create table principal_characters (
  tconst varchar(20) references principal(tconst),
  nconst varchar(20) references principal(nconst),
  category varchar(100) references principal(category),
  job varchar(200) references principal(job),
  `character` nvarchar(200),
  primary key (tconst, nconst, category, job, `character`)
);