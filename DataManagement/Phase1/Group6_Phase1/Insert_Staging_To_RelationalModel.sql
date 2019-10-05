/*
 * Group 6 - Phase 1.
 * Script written on: Microsoft SQL Server.
 * Insert scripts for loading the data from staging database to the relational model.
 * The script assumes a staging database (imdb_staging, created using SQL Server import tool) equivalent to the data files that contains the data in text format.
 * It performs the necessary clean-up and loads data into the IMDb schema.
 **/

use imdb;
go

-- title parent table
insert into imdb.dbo.title (primaryTitle, originalTitle, isAdult, startYear, runtimeInMinutes, averageRating, numVotes)
select
b.primaryTitle
,b.originalTitle
,max(case when b.isAdult = '1' then 1 else 0 end)
,max(convert(smallint, b.startYear))
,max(case when b.runtimeMinutes = 'null' or b.runtimeMinutes = '\n' then NULL else convert(int, b.runtimeMinutes) end)
,max(case when r.averageRating = 'null' or r.averageRating = '\n' then NULL else convert(float, r.averageRating) end)
,max(case when r.numVotes = 'null' or r.numVotes = '\n' then NULL else convert(int, r.numVotes) end)
from imdb_staging.dbo.title_basics b
left outer join imdb_staging.dbo.title_ratings r on b.tconst = r.tconst
where startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and originalTitle is not null
group by b.primaryTitle, originalTitle, startYear;
go

-- title-genre mapping
insert into imdb.dbo.titleGenres (primaryTitle, originalTitle, startYear, genre)
select t.primaryTitle, t.originalTitle, t.startYear, g.value
from imdb_staging.dbo.title_basics b
inner join imdb.dbo.title t on t.primaryTitle = b.primaryTitle and t.originalTitle = b.originalTitle and t.startYear = b.startYear
cross apply string_split(b.genres, ',') g
where b.genres is not null and b.genres <> 'null' and b.genres <> '\n' and b.startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and b.originalTitle is not null
group by t.primaryTitle, t.originalTitle, t.startYear, g.value;
go

-- title child table - tvSeries
insert into imdb.dbo.tvSeries (primaryTitle, originalTitle, startYear, endYear)
select t.primaryTitle, t.originalTitle, t.startYear
, max(case when endYear = 'null' or endYear = '\n' then NULL else convert(int, endYear) end)
from imdb_staging.dbo.title_basics b
inner join imdb.dbo.title t on t.primaryTitle = b.primaryTitle and t.originalTitle = b.originalTitle and t.startYear = b.startYear
where titleType in ('tvSeries', 'tvMiniSeries') and b.startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and b.originalTitle is not null
group by t.primaryTitle, t.originalTitle, t.startYear;
go

-- title child table - movie
insert into imdb.dbo.movie (primaryTitle, originalTitle, startYear, movieType)
select t.primaryTitle, t.originalTitle, t.startYear, b.titleType
from imdb_staging.dbo.title_basics b
inner join imdb.dbo.title t on t.primaryTitle = b.primaryTitle and t.originalTitle = b.originalTitle and t.startYear = b.startYear
where titleType not in ('tvSeries', 'tvMiniSeries', 'tvEpisode') and b.startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and b.originalTitle is not null
group by t.primaryTitle, t.originalTitle, t.startYear, b.titleType;
go

-- title child table - tvEpisode
insert into imdb.dbo.tvEpisode (primaryTitle, originalTitle, startYear, seriesPrimaryTitle, seriesOriginalTitle, seriesStartYear, seasonNumber, episodeNumber)
select top 100 t1.primaryTitle, t1.originalTitle, t1.startYear, t2.primaryTitle, t2.originalTitle, t2.startYear
, max(case when e.seasonNumber = 'null' or e.seasonNumber = '\n' then NULL else convert(int, e.seasonNumber) end)
, max(case when e.episodeNumber = 'null' or e.seasonNumber = '\n' then NULL else convert(int, e.episodeNumber) end)
from imdb_staging.dbo.title_episode e
inner join imdb_staging.dbo.title_basics b1 on b1.tconst = e.tconst
inner join imdb.dbo.title t1 on t1.primaryTitle = b1.primaryTitle and t1.originalTitle = b1.originalTitle and t1.startYear = b1.startYear
inner join imdb_staging.dbo.title_basics b2 on b2.tconst = e.parentTconst
inner join imdb.dbo.tvSeries t2 on t2.primaryTitle = b2.primaryTitle and t2.originalTitle = b2.originalTitle and t2.startYear = b2.startYear
where b1.startYear is not null and b1.startYear <> 'null' and b1.startYear <> '\n' and b1.primaryTitle is not null and b1.originalTitle is not null and
b2.startYear is not null and b2.startYear <> 'null' and b2.startYear <> '\n' and b2.primaryTitle is not null and b2.originalTitle is not null
group by t1.primaryTitle, t1.originalTitle, t1.startYear, t2.primaryTitle, t2.originalTitle, t2.startYear
go

-- title - alternate title mapping
insert into alternateTitle (primaryTitle, originalTitle, startYear, language, title, region)
select t.primaryTitle, t.originalTitle, t.startYear, a.language, a.title, a.region
from imdb_staging.dbo.title_akas a
inner join imdb_staging.dbo.title_basics b on b.tconst = a.titleId
inner join imdb.dbo.title t on t.primaryTitle = b.primaryTitle and t.originalTitle = b.originalTitle and t.startYear = b.startYear
where b.startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and b.originalTitle is not null
group by t.primaryTitle, t.originalTitle, t.startYear, a.language, a.title, a.region;
go

-- alternate title - title type mapping
insert into imdb.dbo.alternateTitleTypes (primaryTitle, originalTitle, startYear, language, title, region, type)
select t.primaryTitle, t.originalTitle, t.startYear, t.language, t.title, t.region, s.value
from imdb_staging.dbo.title_akas a
inner join imdb_staging.dbo.title_basics b on b.tconst = a.titleId
inner join imdb.dbo.alternateTitle t on t.primaryTitle = b.primaryTitle and t.originalTitle = b.originalTitle and t.startYear = b.startYear
cross apply string_split(a.types, ',') s
where b.startYear is not null and b.startYear <> 'null' and b.startYear <> '\n' and b.primaryTitle is not null and b.originalTitle is not null;
go

-- name master table
insert into imdb.dbo.name (primaryName, birthYear, deathYear)
select n.primaryName
, max(convert(int, birthYear))
, max(case when n.deathYear = 'null' or deathYear = '\n' then NULL else convert(int, deathYear) end)
from imdb_staging.dbo.name_basics n
where n.primaryName is not null and n.primaryName <> 'null' and n.primaryName <> '\n' and
n.birthYear is not null and n.birthYear <> 'null' and n.birthYear <> '\n'
group by n.primaryName;
go

-- name - profession map
insert into imdb.dbo.namePrimaryProfession (primaryName, birthYear, primaryProfession)
select n.primaryName, n.birthYear, s.value
from imdb_staging.dbo.name_basics b
inner join imdb.dbo.name n on n.primaryName = b.primaryName and n.birthYear = b.birthYear
cross apply string_split(b.primaryProfession, ',') s
where n.primaryName is not null and n.primaryName <> 'null' and n.primaryName <> '\n' and
b.birthYear is not null and b.birthYear <> 'null' and b.birthYear <> '\n' and s.value is not null and s.value <> ''
group by n.primaryName, n.birthYear, s.value;
go

-- writers: name - title mapping
insert into imdb.dbo.writers (primaryName, birthYear, primaryTitle, originalTitle, startYear)
select n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
from ( select c.tconst, s.value
       from imdb_staging.dbo.title_crew c
       cross apply string_split(c.writers, ',') s ) s
inner join imdb_staging.dbo.name_basics nb on nb.nconst = s.value
inner join imdb.dbo.name n on nb.primaryName = nb.primaryName and nb.birthYear = n.birthYear
inner join imdb_staging.dbo.title_basics tb on tb.tconst = s.tconst
inner join imdb.dbo.title t on t.primaryTitle = tb.primaryTitle and t.originalTitle = tb.originalTitle and t.startYear = tb.startYear
where nb.birthYear is not null and nb.birthYear <> 'null' and nb.birthYear <> '\n' and
tb.startYear is not null and tb.startYear <> 'null' and tb.startYear <> '\n'
group by n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
go

-- directors: name - title mapping
insert into imdb.dbo.directors(primaryName, birthYear, primaryTitle, originalTitle, startYear)
select n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
from ( select c.tconst, s.value
       from imdb_staging.dbo.title_crew c
       cross apply string_split(c.directors, ',') s ) s
inner join imdb_staging.dbo.name_basics nb on nb.nconst = s.value
inner join imdb.dbo.name n on nb.primaryName = nb.primaryName and nb.birthYear = n.birthYear
inner join imdb_staging.dbo.title_basics tb on tb.tconst = s.tconst
inner join imdb.dbo.title t on t.primaryTitle = tb.primaryTitle and t.originalTitle = tb.originalTitle and t.startYear = tb.startYear
where nb.birthYear is not null and nb.birthYear <> 'null' and nb.birthYear <> '\n' and
tb.startYear is not null and tb.startYear <> 'null' and tb.startYear <> '\n'
group by n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
go

-- popularTitles: name - title mapping
insert into imdb.dbo.popularTitles(primaryName, birthYear, primaryTitle, originalTitle, startYear)
select n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
from ( select nb.nconst, s.value
       from imdb_staging.dbo.name_basics nb
       cross apply string_split(nb.knownForTitles, ',') s ) s
inner join imdb_staging.dbo.name_basics nb on nb.nconst = s.nconst
inner join imdb.dbo.name n on nb.primaryName = nb.primaryName and nb.birthYear = n.birthYear
inner join imdb_staging.dbo.title_basics tb on tb.tconst = s.value
inner join imdb.dbo.title t on t.primaryTitle = tb.primaryTitle and t.originalTitle = tb.originalTitle and t.startYear = tb.startYear
where nb.birthYear is not null and nb.birthYear <> 'null' and nb.birthYear <> '\n' and
tb.startYear is not null and tb.startYear <> 'null' and tb.startYear <> '\n'
group by n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear
go

-- principalCast: name - title mapping
insert into imdb.dbo.principalCast (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job)
select top 10 n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear, p.category, p.job
from imdb_staging.dbo.title_principals p
inner join imdb_staging.dbo.name_basics nb on nb.nconst = p.nconst
inner join imdb.dbo.name n on n.primaryName = nb.primaryName and n.birthYear = nb.birthYear
inner join imdb_staging.dbo.title_basics tb on tb.tconst = p.tconst
inner join imdb.dbo.title t on t.primaryTitle = tb.primaryTitle and t.originalTitle = tb.originalTitle and t.startYear = tb.startYear
where nb.birthYear is not null and nb.birthYear <> 'null' and nb.birthYear <> '\n' and
tb.startYear is not null and tb.startYear <> 'null' and tb.startYear <> '\n'
group by n.primaryName, n.birthYear, t.primaryTitle, t.originalTitle, t.startYear, p.category, p.job;
go

-- principalCastCharacters: principalCast - character mapping
insert into imdb.dbo.principalCastCharacters (primaryName, birthYear, primaryTitle, originalTitle, startYear, category, job, character)
select pc.primaryName, pc.birthYear, pc.primaryTitle, pc.originalTitle, pc.startYear, pc.category, pc.job, s.value
from ( select p.nconst, p.tconst, s.value
       from imdb_staging.dbo.title_principals p
       cross apply string_split(p.characters, ',') s ) s
inner join imdb_staging.dbo.name_basics nb on nb.nconst = s.nconst
inner join imdb.dbo.name n on nb.primaryName = nb.primaryName and nb.birthYear = n.birthYear
inner join imdb_staging.dbo.title_basics tb on tb.tconst = s.value
inner join imdb.dbo.title t on t.primaryTitle = tb.primaryTitle and t.originalTitle = tb.originalTitle and t.startYear = tb.startYear
inner join imdb.dbo.principalCast pc on pc.primaryName = n.primaryName and pc.birthYear = n.birthYear and pc.primaryTitle = t.primaryTitle and pc.originalTitle = t.originalTitle and pc.startYear = t.startYear
where nb.birthYear is not null and nb.birthYear <> 'null' and nb.birthYear <> '\n' and
tb.startYear is not null and tb.startYear <> 'null' and tb.startYear <> '\n'
group by pc.primaryName, pc.birthYear, pc.primaryTitle, pc.originalTitle, pc.startYear, pc.category, pc.job, s.value;
go