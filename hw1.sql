DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
	SELECT MAX(era)
	FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
	SELECT namefirst, namelast, birthyear
	FROM people
	WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
	SELECT namefirst, namelast, birthyear
	FROM people
	WHERE namefirst ~ '\s';
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
	SELECT birthyear, AVG(height) as avgheight, count(*)
	FROM people
	GROUP BY birthyear
	ORDER BY birthyear;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
	SELECT birthyear, AVG(NULLIF(height, 0)) as avgheight, count(*)
	FROM people
	GROUP BY birthyear
	HAVING AVG(height) > 70
	ORDER BY birthyear;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
	SELECT p.namefirst, p.namelast, p.playerid, h.yearid
	FROM people p, halloffame h
	WHERE p.playerid = h.playerid AND h.inducted = 'Y'
	ORDER BY h.yearid DESC;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
	SELECT p.namefirst, p.namelast, p.playerid, c.schoolid, h.yearid
	FROM people p, collegeplaying c, halloffame h
	WHERE p.playerid = h.playerid AND h.inducted = 'Y' AND p.playerid = c.playerid AND c.schoolid IN
		(SELECT schoolid FROM schools WHERE schoolstate = 'CA')
	ORDER BY h.yearid DESC, c.schoolid, p.playerid;
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
	SELECT Q.playerid, namefirst, namelast, CP.schoolid
		FROM q2i AS Q
		LEFT OUTER JOIN collegeplaying AS CP
		ON Q.playerid = CP.playerid
		ORDER BY q.playerid DESC, CP.schoolid;
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS

	SELECT b.playerid, p.namefirst, p.namelast, b.yearid, (
			CAST((b.h2b * 2 + h3b * 3 + hr * 4 + (h - h2b - h3b - hr)) AS float) /
			CAST(ab AS float)
		) AS slg
	FROM batting b, people p
	WHERE b.playerid = p.playerid AND b.ab > 50
	ORDER BY slg DESC LIMIT 10;

;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
	SELECT b.playerid, p.namefirst, p.namelast, (
			CAST((SUM(b.h2b) * 2 + SUM(h3b) * 3 + SUM(hr) * 4 + (SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr))) AS float) /
			CAST(SUM(ab) AS float)
		) AS lslg
	FROM batting b, people p
	WHERE ab > 0 AND b.playerid = p.playerid
	GROUP BY b.playerid, p.playerid
	HAVING SUM(ab) >= 50
	ORDER BY lslg DESC, playerid LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
	WITH lifetimeslugging(playerid, namefirst, namelast, lslg) AS
		(SELECT b.playerid, p.namefirst, p.namelast, (
			CAST((SUM(b.h2b) * 2 + SUM(h3b) * 3 + SUM(hr) * 4 + (SUM(h) - SUM(h2b) - SUM(h3b) - SUM(hr))) AS float) /
			CAST(SUM(ab) AS float) ) AS lifeslug
		FROM batting b, people p
		WHERE ab > 0 AND b.playerid = p.playerid
		GROUP BY b.playerid, p.playerid
		HAVING SUM(ab) >= 50)

	SELECT namefirst, namelast, lslg
	FROM lifetimeslugging
	WHERE lslg > (
		SELECT lslg
		FROM lifetimeslugging
		WHERE playerid = 'mayswi01'
	)
	ORDER BY namefirst, namelast;
;
-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
	SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary) FROM Salaries GROUP BY yearid ORDER BY yearid;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS

WITH salaries_stat AS (
	SELECT min(salary) AS min_2016, max(salary) AS max_2016, (max(salary) - min(salary))/10 AS range_2016
	FROM salaries
	WHERE yearid = '2016'
	),
	bin AS (
	SELECT width_bucket(salary, min_2016, max_2016 + 1, 10) - 1 as binid, count(*) as count
	FROM salaries, salaries_stat
	WHERE yearid = '2016'
	GROUP BY binid
	)
SELECT binid, min_2016+range_2016*binid as min, min_2016+range_2016*(binid+1) as max, count
FROM bin, salaries_stat
ORDER BY binid;

;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS

SELECT cur.yearid, cur.min - pre.min, cur.max - pre.max, cur.avg - pre.avg
FROM q4i AS cur
INNER JOIN q4i AS pre
ON cur.yearid - 1 = pre.yearid
ORDER BY cur.yearid

;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS

SELECT p.playerid, namefirst, namelast, salary, yearid
FROM people AS p
INNER JOIN salaries AS s
ON p.playerid = s.playerid
WHERE (yearid BETWEEN 2000 AND 2001) AND (yearid, salary) IN (
	SELECT yearid, MAX(salary)
	FROM salaries
	GROUP BY yearid
)

;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS

SELECT a.teamid as team, MAX(salary) - MIN(salary)
FROM allstarfull a, salaries s
WHERE a.playerid = s.playerid AND a.yearid = s.yearid AND a.yearid='2016'
GROUP BY team
ORDER BY team;

;

