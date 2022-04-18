use[Playlist]
go

--
SELECT t."Name"
FROM "PlaylistTrack" plt
JOIN "Playlist" pl 
	ON pl."PlaylistId"=plt."PlaylistId"
	AND LEN (pl."Name") > 12
JOIN "Track" t 
	ON t."TrackId"=plt."TrackId"
ORDER BY t."Name"

-- list of songs with name of album
select p.[PlaylistId], p.[Name], pt.[TrackId]
from [dbo].[Playlist] P
join [dbo].[PlaylistTrack] PT
on p.[PlaylistId]= pt.PlaylistId
-- list of number count trackId
select distinct [GenreId], count (TrackId) as TrackId
from[dbo].[Track]
group by [GenreId]
order by [GenreId]
--count songs in playlists 
SELECT [PlaylistId], count ([TrackId]) as count_songs
FROM "PlaylistTrack"
group by [PlaylistId]
--count songs in playlists upon by author
SELECT Composer, count ([TrackId])
FROM "Track"
group by Composer
order by count ([TrackId]) DESC

-- list of authors
SELECT t."Name" 
FROM "PlaylistTrack" plt
JOIN "Playlist" pl 
	ON pl."PlaylistId"=plt."PlaylistId"
	AND LEN (pl."Name") > 12
JOIN "Track" t 
	ON t."TrackId"=plt."TrackId"
ORDER BY t."Name"
--procedure
create procedure Songs_without_composer
as
begin 
select *
FROM "Track"
where composer is null
end
exec Songs_without_composer


--procedure money from composer album

alter procedure priceoncomposer
@Composer as varchar(220)
as 
begin
select distinct [Composer], sum ([UnitPrice])
from [dbo].[Track]
where [Composer] = @Composer
and [Composer] is not null
and [Composer] like '%'+[Composer]+'%'
group by [Composer], [UnitPrice]
end
exec priceoncomposer 'Angus Young, Malcolm Young, Brian Johnson'

--Delete possible duplicates
with CTE_Track as

(SELECT *, ROW_NUMBER () OVER (PARTITION BY [TrackId] ORDER BY [TrackId]) AS Rownumber
FROM [dbo].[Track]
)
delete 
from CTE_Track
where Rownumber >1


--searcing 5 singers than next 5 singers
select [Composer], count([TrackId]) as counting
from track
where [Composer] is not null
group by [Composer]
order by count([TrackId]) Desc
offset 0 ROWS
fetch next 5 rows only

select [Composer], count([TrackId]) as counting
from track
where [Composer] is not null
group by [Composer]
order by count([TrackId]) Desc
offset 5 ROWS
fetch next 5 rows only

--index
create index test_index
on [dbo].[Track] ([TrackId], [Name],[AlbumId],[GenreId])

select [TrackId], [AlbumId]
from [dbo].[Track] with(index( test_index))

SELECT *


