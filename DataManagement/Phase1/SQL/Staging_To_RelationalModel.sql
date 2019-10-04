-- Insert scripts for loading the data from staging database to the relational model.
-- The script assumes a staging database equivalent to the data files that contains the data in text format.
-- It performs the necessary clean-up and loads data into the IMDb schema.

insert into imdb.title (tconst, primaryTitle, originalTitle, isAdult, startYear, runtimeInMinutes, averageRating, numVotes)
select
b.tconst
,b.primaryTitle
,b.originalTitle
,case when b.isAdult = '1' then TRUE else FALSE end
,case when b.startYear = 'null' then NULL else convert(b.startYear, unsigned) end
,convert(b.runtimeMinutes, unsigned)
,convert(r.averageRating, float)
,convert(r.numVotes, unsigned)
from imdb_staging.title_basics b
left outer join imdb_staging.title_ratings r on b.tconst = r.tconst;

insert into imdb.title_genre (tconst, genre)
select tconst, genres.genre
from imdb_staging.title_basics, imdb_staging.genres
where FIND_IN_SET(genres.genre, imdb_staging.title_basics.genres);

insert into imdb.tvSeries (tconst, endYear)
select tconst
, case when e.endYear = 'null' then NULL else convert(endYear, unsigned) end
from imdb_staging.title_basics
where titleType in ('tvSeries', 'tvMiniSeries');

insert into imdb.movie (tconst, movieType)
select tconst, titleType
from imdb_staging.title_basics
where titleType not in ('tvSeries', 'tvMiniSeries', 'tvEpisode');

insert into imdb.tvEpisode (tconst, parentTconst, seasonNumber, episodeNumber)
select e.tconst, b.tconst
, case when e.seasonNumber = 'null' then NULL else convert(e.seasonNumber, unsigned) end
, case when e.episodeNumber = 'null' then NULL else convert(e.episodeNumber, unsigned) end
from imdb_staging.title_basics b
inner join imdb_staging.title_episode e on b.tconst = e.parentTconst
where b.titleType = 'tvEpisode';

insert into alternateTitle (tconst, language, title, region, isOriginal)
select tconst, language, title, region
, case when isOriginalTitle = '1' then TRUE else FALSE end
from imdb_staging.title_akas;

insert into imdb.alternateTitleTypes (tconst, language, title, region, isOriginal, type)
select tconst, language, title, region, isOriginalTitle, titleType
from imdb_staging.title_akas, imdb_staging.alternateTitleTypes
where find_in_set(imdb_staging.alternateTitleTypes.titleType, imdb_staging.title_akas.types);

insert into imdb.name (nconst, primaryName, birthYear, deathYear)
select nconst, primaryName
, case when birthYear = 'null' then NULL else convert(birthYear, unsigned) end
, case when deathYear = 'null' then NULL else convert(deathYear, unsigned) end
from imdb_staging.name_basics;

insert into imdb.namePrimaryProfession (nconst, primaryProfession)
select nconst, profession
from imdb_staging.name_basics, imdb_staging.primaryProfessions
where find_in_set(imdb_staging.name_basics.primaryProfession, imdb_staging.primaryProfessions.profession);

insert into imdb.crew (tconst, nconst, role)
select tconst, nconst, 'writer'
from imdb_staging.title_crew, imdb.name
where find_in_set(imdb.name.nconst, imdb_staging.title_crew.writers);

insert into imdb.crew (tconst, nconst, role)
select tconst, nconst, 'director'
from imdb_staging.title_crew, imdb.name
where find_in_set(imdb.name.nconst, imdb_staging.title_crew.directors);

insert into imdb.popularTitles (nconst, tconst)
select nconst, tconst
from imdb_staging.name_basics, imdb.title
where find_in_set(imdb.title.tconst, imdb_staging.name_basics.knownForTitles);

insert into imdb.principal (tconst, nconst, category, job)
select tconst, nconst, category, job
from imdb_staging.title_principals;

insert into imdb.principalCharacters (tconst, nconst, category, job, `character`)
select tconst, nconst, category, job
from imdb_staging.title_principals, imdb_staging.principalCharacters
where find_in_set(imdb_staging.principalCharacters.principalCharacter, imdb_staging.title_principals.`character`);