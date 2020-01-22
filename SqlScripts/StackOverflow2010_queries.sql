--https://data.stackexchange.com/stackoverflow/query/7521/how-unsung-am-i
DECLARE @UserId int = 26837

select
    count(a.Id) as [Accepted Answers],
    sum(case when a.Score = 0 then 0 else 1 end) as [Scored Answers],  
    sum(case when a.Score = 0 then 1 else 0 end) as [Unscored Answers],
    sum(CASE WHEN a.Score = 0 then 1 else 0 end)*1000 / count(a.Id) / 10.0 as [Percentage Unscored]
from
    Posts q
  inner join
    Posts a
  on a.Id = q.AcceptedAnswerId
where
      a.CommunityOwnedDate is null
  and a.OwnerUserId = @UserId
  and q.OwnerUserId != @UserId
  and a.postTypeId = 2
--Query
--https://data.stackexchange.com/stackoverflow/query/947/my-comment-score-distribution
DECLARE @UserId int = 26837
SELECT 
    Count(*) AS CommentCount,
    Score
FROM 
    Comments
WHERE 
    UserId = @UserId
GROUP BY 
    Score
ORDER BY 
    Score DESC
--Query
--https://data.stackexchange.com/stackoverflow/query/949/what-is-my-accepted-answer-percentage-rate
DECLARE @UserId int = 26837
SELECT 
    (CAST(Count(a.Id) AS float) / (SELECT Count(*) FROM Posts WHERE OwnerUserId = @UserId AND PostTypeId = 2) * 100) AS AcceptedPercentage
FROM
    Posts q
  INNER JOIN
    Posts a ON q.AcceptedAnswerId = a.Id
WHERE
    a.OwnerUserId = @UserId
  AND
    a.PostTypeId = 2
--Query
--https://data.stackexchange.com/stackoverflow/query/6772/stackoverflow-rank-and-percentile
DECLARE @UserId int = 26837
;WITH Rankings AS (
SELECT Id, Ranking = ROW_NUMBER() OVER(ORDER BY Reputation DESC)
FROM Users
),
Counts AS (
SELECT Count = COUNT(*)
FROM Users
WHERE Reputation > 100
)
SELECT Id, Ranking, CAST(Ranking AS decimal(20, 5)) / (SELECT Count FROM Counts) AS Percentile
FROM Rankings
WHERE Id = @UserId
--Query
--https://data.stackexchange.com/stackoverflow/query/8116/my-money-for-jam
declare @latestDate datetime
select @latestDate = max(CreationDate) from Posts
declare @ignoreDays numeric = 15
declare @minAgeDays numeric = @ignoreDays * 4
DECLARE @UserId int = 26837

declare @VoteStats table (PostId int, up int, down int, CreationDate datetime)
insert @VoteStats
select
    p.Id,
    up = sum(case when VoteTypeId = 2 then
        case when p.ParentId is null then 5 else 10 end
        else 0 end),
    down = sum(case when VoteTypeId = 3 then 2 else 0 end),
    p.CreationDate
from Votes v join posts p on v.postid = p.id
where v.VoteTypeId in (2,3)
and OwnerUserId = @UserId
and p.CommunityOwnedDate is null
and datediff(day, p.CreationDate, v.CreationDate) > @ignoreDays
and datediff(day, p.CreationDate, @latestDate) > @minAgeDays
group by p.Id, p.CreationDate, p.ParentId

set nocount off

select top 100 PostId as [Post Link],
  convert(decimal(10,2), up - down)/(datediff(day, vs.CreationDate, @latestDate) - @ignoreDays) as [Passive Rep Per Day],
  (up - down) as [Passive Rep],
  up as [Passive Up Reputation],
  down as [Passive Down Reputation],
  datediff(day, vs.CreationDate, @latestDate) - @ignoreDays as [Days Counted]
from @VoteStats vs
order by [Passive Rep Per Day] desc
--Query
--https://data.stackexchange.com/stackoverflow/query/466/most-controversial-posts-on-the-site
set nocount on 

declare @VoteStats table (PostId int, up int, down int) 

insert @VoteStats
select
    PostId, 
    up = sum(case when VoteTypeId = 2 then 1 else 0 end), 
    down = sum(case when VoteTypeId = 3 then 1 else 0 end)
from Votes
where VoteTypeId in (2,3)
group by PostId

set nocount off

select top 100 p.id as [Post Link] , up, down from @VoteStats 
join Posts p on PostId = p.Id
where down > (up * 0.5) and p.CommunityOwnedDate is null and p.ClosedDate is null
order by up desc
--Query
--https://data.stackexchange.com/stackoverflow/query/952/top-500-answerers-on-the-site
SELECT 
    TOP 500
    Users.Id as [User Link],
    Count(Posts.Id) AS Answers,
    CAST(AVG(CAST(Score AS float)) as numeric(6,2)) AS [Average Answer Score]
FROM
    Posts
  INNER JOIN
    Users ON Users.Id = OwnerUserId
WHERE 
    PostTypeId = 2 and CommunityOwnedDate is null and ClosedDate is null
GROUP BY
    Users.Id, DisplayName
HAVING
    Count(Posts.Id) > 10
ORDER BY
    [Average Answer Score] DESC
--Query
--https://data.stackexchange.com/stackoverflow/query/6856/high-standards-top-100-users-that-rarely-upvote
select top 100
  id as [User Link],
  round((100.0 * (Reputation/10)) / (Upvotes+1), 2) as [Ratio %],
  Reputation as Rep, 
  UpVotes as [+ Votes],
  DownVotes [- Votes]
from Users
where Reputation > 10
  and Upvotes > 10
order by [Ratio %] desc
--Query
--https://data.stackexchange.com/stackoverflow/query/1433/users-with-highest-accept-rate-of-their-answers
DECLARE @MinAnswers int = 10

SELECT TOP 100
  u.Id AS [User Link],
  count(*) AS NumAnswers,
  sum(case when q.AcceptedAnswerId = a.Id then 1 else 0 end) AS NumAccepted,
  (sum(case when q.AcceptedAnswerId = a.Id then 1 else 0 end)*100.0/count(*)) AS AcceptedPercent
FROM Posts a
INNER JOIN Users u ON u.Id = a.OwnerUserId
INNER JOIN Posts q ON a.ParentId = q.Id
WHERE 
  (q.OwnerUserId <> u.Id OR q.OwnerUserId IS NULL)   --no self answers
GROUP BY u.Id
HAVING count(*) >= @MinAnswers
ORDER BY AcceptedPercent DESC, NumAnswers DESC