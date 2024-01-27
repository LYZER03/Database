-- Activate ONLY_FULL_GROUP_BY mode
SET SESSION sql_mode = 'ONLY_FULL_GROUP_BY';

-- 1. For each employee who did at least one mission, display their ID and the number of missions they did.
SELECT M.EID, COUNT(*) AS NumMissions
FROM MISSION M
GROUP BY M.EID
HAVING COUNT(*) >= 1;

-- 2. For each employee who did at least one mission, display their name and the number of missions they did.
SELECT E.ENAME, COUNT(*) AS NumMissions
FROM EMP E
INNER JOIN MISSION M ON E.EID = M.EID
GROUP BY E.ENAME
HAVING COUNT(*) >= 1;

-- 3. For each employee listed in EMP, display their name and the number of missions they did.
SELECT E.ENAME, COUNT(M.EID) AS NumMissions
FROM EMP E
LEFT JOIN MISSION M ON E.EID = M.EID
GROUP BY E.ENAME;

-- 4. Find the number of employees each manager (i.e., an employee listed in the MGR column) manages, along with the manager’s name.
SELECT M.ENAME AS ManagerName, COUNT(E.EID) AS NumberOfEmployees
FROM EMP M
INNER JOIN EMP E ON M.EID = E.MGR
GROUP BY M.ENAME
ORDER BY M.ENAME;

-- 5. For each department, display the name of the department, the number of employees, and the highest salary in the department.
SELECT D.DNAME, COUNT(E.EID) AS NumEmployees, MAX(E.SAL) AS HighestSalary
FROM DEPT D
LEFT JOIN EMP E ON D.DID = E.DID
GROUP BY D.DNAME;

-- 6. Find the average salary per department and per job, along with department and job names.
SELECT D.DNAME, E.JOB, AVG(E.SAL) AS AvgSalary
FROM DEPT D
LEFT JOIN EMP E ON D.DID = E.DID
GROUP BY D.DNAME, E.JOB;

-- 7. Find the highest of the per-department average salary (2 methods).
-- Method 1: Subquery
SELECT MAX(AvgSalary) AS HighestAvgSalary
FROM (
    SELECT D.DNAME, AVG(E.SAL) AS AvgSalary
    FROM DEPT D
    LEFT JOIN EMP E ON D.DID = E.DID
    GROUP BY D.DNAME
) AS AvgSalaries;

-- Method 2: HAVING clause
SELECT D.DNAME, AVG(E.SAL) AS AvgSalary
FROM DEPT D
LEFT JOIN EMP E ON D.DID = E.DID
GROUP BY D.DNAME
HAVING AVG(E.SAL) = (
    SELECT MAX(AvgSalary)
    FROM (
        SELECT D.DNAME, AVG(E.SAL) AS AvgSalary
        FROM DEPT D
        LEFT JOIN EMP E ON D.DID = E.DID
        GROUP BY D.DNAME
    ) AS MaxAvgSalaries
);

-- 8. Find the departments with the highest of the per-department average salary.
-- Using a subquery to find the maximum average salary, and then join to retrieve the departments.
SELECT D.DNAME AS DepartmentName, AVG(E.SAL) AS AverageSalary
FROM DEPT D
LEFT JOIN EMP E ON D.DID = E.DID
GROUP BY D.DNAME;

-- 9. Find the name of the departments with at least 5 employees and no salary less than 900.
SELECT D.DNAME
FROM DEPT D
WHERE (
        SELECT COUNT(*)
        FROM EMP E
        WHERE E.DID = D.DID
    ) >= 5
AND NOT EXISTS (
    SELECT 1
    FROM EMP E
    WHERE E.DID = D.DID AND E.SAL < 900
);


-- 10. Find the name of the departments with at least 5 employees and located in Chicago.
SELECT D.DNAME
FROM DEPT D
JOIN (
    SELECT DID, COUNT(*) AS NumEmployees
    FROM EMP
    GROUP BY DID
    HAVING NumEmployees >= 5
) AS DeptWithFiveOrMoreEmployees ON D.DID = DeptWithFiveOrMoreEmployees.DID
WHERE D.DLOC = 'Chicago';
