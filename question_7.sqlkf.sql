--7A:116
SELECT yearid,teamid,w,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
AND wswin = 'N' 
AND wswin IS NOT NULL 
ORDER BY w DESC;

--7B:63
SELECT yearid,teamid,w,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
AND wswin = 'Y' 
AND wswin IS NOT NULL 
ORDER BY w;

--7C:
SELECT yearid,teamid,w,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 
AND wswin = 'Y' 
AND yearid <> 1981
AND wswin IS NOT NULL 
ORDER BY w;