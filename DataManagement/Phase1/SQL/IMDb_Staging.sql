-- 10/02/2019:
-- Creates a staging database for the IMDb dataset.
-- It is an exact replica of the tsv files, and will be used only temporarily to transfer the data to the actual schema.
-- All tables here are popuated with Python scripts.

create database if not exists imdb_staging;

use imdb_staging;

create table if not exists title_akas(
    titleId text,
    ordering text,
    title text,
    region text,
    language text,
    types text,
    attributes text,
    isOriginalTitle text
);

create table if not exists title_basics(
    tconst text,
    titleType text,
    primaryTitle text,
    originalTitle text,
    isAdult text,
    startYear text,
    endYear text,
    runtimeMinutes text,
    genres text
);

create table if not exists title_crew (
    tconst text,
    directors text,
    writers text
);

create table if not exists title_episode (
    tconst text,
    parentTconst text,
    seasonNumber text,
    episodeNumber text
);

create table if not exists title_principals (
    tconst text,
    ordering text,
    nconst text,
    category text,
    job text,
    characters text
);

create table if not exists title_ratings (
    tconst text,
    averageRating text,
    numVotes text
);

create table if not exists name_basics (
    nconst text,
    primaryName text,
    birthYear text,
    deathYear text,
    primaryProfession text,
    knownForTitles text
);

create table if not exists genres ( genre nvarchar(100) );
create table if not exists alternateTitleTypes( titleType nvarchar(500) );
create table if not exists principalCharacters (principalCharacter nvarchar(200));
/*insert into genres values
('Short'), ('Documentary'), ('Family'), ('Crime'), ('Drama'), ('Biography'), ('News'), ('Talk-Show'), ('nan'), ('Music'), ('Romance'), ('Comedy'),
('Sci-Fi'), ('Thriller'), ('War'), ('Fantasy'), ('Western'), ('Animation'), ('Action'), ('Reality-TV'), ('History'), ('Horror'), ('Sport'), ('Musical'),
('Adult'), ('Game-Show'), ('Mystery'), ('Adventure'), ('Film-Noir');
*/


