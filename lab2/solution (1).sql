-- 
-- EXERCISE 1
-- 

-- 1. Find the employees whose commission is specified (i.e. including 0.0 commissions).
select *
from EMP
where COMM is not null;

-- 2. Find the number of employees whose commission is specified (2 methods).
select count(*)
from EMP
where COMM is not null;

select count(COMM)
from EMP;

-- 3. Find the number of employees whose commission is not specified (2 methods).
select count(*)
from EMP
where COMM is null;

select count(*) - count(COMM)
from EMP;

-- 4. Find the lowest, average and highest commission over all the employees (nulls ignored).
select min(COMM), avg(COMM), max(COMM)
from EMP;

-- 5. Find the average commission over all the employees (nulls counted as 0.0).
select sum(COMM) / count(*)
from EMP;

select avg(coalesce(COMM, 0.0))
from EMP;

-- 6. Find the name and commission, expressed in Euro (1 € = $ 1.2) of all the employees.
select ENAME, COMM / 1.2 as COMM_IN_EURO
from EMP;

-- 7. Find the name and total salary (including commission) of all the employees.
select SAL + coalesce(COMM, 0.0) as TOTAL_SALARY
from EMP;

-- 8. Find the name of the company’s top managers (i.e. who don’t have a manager).
select ENAME
from EMP
where MGR is null;

-- 9. Find the employees whose commission is less than 25% (nulls excluded).
select *
from EMP
where COMM / SAL < 0.25;

-- 10. Find the employees whose commission is less than 25% (nulls counted as 0.0).
select *
from EMP
where coalesce(COMM, 0.0) / SAL < 0.25;

-- 
-- EXERCISE 2
-- 

-- 1. Display (a) the product of tables EMP and DEPT, (b) the theta-join of EMP and DEPT on DID, and (c) the natural join of EMP and DEPT. Compare the schema and the population of the resulting tables.
-- (a) product
select *
from EMP cross join DEPT;

-- (b) theta-join
select *
from EMP join DEPT on EMP.DID = DEPT.DID;

-- (c) natural join
select *
from EMP natural join DEPT;

-- Comparison:
-- (a) Schema: product and theta-join have the same schema; natural join has one less DID column
-- (b) Instance: natural and theta-join have the same instance; product contains all possible (employee, departement) combinations

-- 2. Find the name and the department of the employees who work in New-York.
select ENAME, DNAME
from EMP natural join DEPT
where DLOC = 'NEW-YORK';

-- 3. Find the name of the employees who did a mission in the city they work in.
select ENAME
from EMP natural join DEPT natural join MISSION
where MLOC = DLOC;

-- 4. Find the name of the employees along with the name of their manager.
select e.ENAME as EMPLOYEE, m.ENAME as MANAGER
from EMP e join EMP m on e.MGR = m.EID;

-- to include employees with no manager:
select e.ENAME as EMPLOYEE, m.ENAME as MANAGER
from EMP e left outer join EMP m on e.MGR = m.EID;

-- 5. Find the name of the employees who have the same manager as Allen.
select e.ENAME
from EMP e join EMP a on e.MGR = a.MGR
where a.ENAME = 'ALLEN';

-- 6. Find the name and hire date of the employees who were hired before their manager; also display the manager’s hire date.
select e.ENAME, e.HIRED as E_HIREDATE, m.HIRED as M_HIRED
from EMP e join EMP m on e.MGR = m.EID and e.HIRED < m.HIRED;

-- 7. Find the name of the employees in the Sales department who were hired the same day as an employee in the Research department.
select es.ENAME
from (EMP es natural join DEPT ds) join (EMP er natural join DEPT dr) on es.HIRED = er.HIRED
where ds.DNAME = 'SALES' and dr.DNAME = 'RESEARCH';

-- 8. Find the departments that do not have any employee.
select DEPT.*
from DEPT natural left outer join EMP
where EID is null;

-- 9. Find the name of the employees with the highest salary.
select m.ENAME
from EMP m left outer join EMP e on m.SAL < e.SAL
where e.EID is null;

-- 10. Find the name of the employees who were hired before all the employees of the Sales department.
select e.EID, e.ENAME
from EMP e left outer join (EMP es natural join DEPT ds) on e.HIRED >= es.HIRED and ds.DNAME = 'SALES'
where es.EID is null;

-- 
-- EXERCISE 3
-- 

-- 1. Find the employees with the highest salary (2 methods).
select *
from EMP
where SAL = (select max(SAL) from EMP);

select *
from EMP
where SAL >= all (select SAL from EMP);

-- 2. Find the employees who earn less than all managers (2 methods).
select *
from EMP
where SAL < (select min(SAL) from EMP where JOB = 'MANAGER');

select *
from EMP
where SAL < all (select SAL from EMP where JOB = 'MANAGER');
-- Notice that the solutions are not equivalent if some SAL are null

-- 3. Find the employees who earn more than some analyst (2 methods).
select *
from EMP
where SAL > (select min(SAL) from EMP where JOB = 'ANALYST');

select *
from EMP
where SAL > some (select SAL from EMP where JOB = 'ANALYST');

select *
from EMP
where SAL > any (select SAL from EMP where JOB = 'ANALYST');

-- 4. Find the employees who work in the Research or Sales departments.
select *
from EMP
where DID in (select DID from DEPT where DNAME = 'RESEARCH' or DNAME = 'SALES');

-- 5. Find the departments without any employee (3 methods).
select *
from DEPT
where DID not in (select DID from EMP where DID is not null); -- beware of employees with no department

select *
from DEPT
where (select count(*) from EMP where DID = DEPT.DID) = 0;

select *
from DEPT
where not exists (select * from EMP where DID = DEPT.DID);

-- 6. Find the departments with at least 4 employees.
select *
from DEPT
where (select count(*) from EMP where DID = DEPT.DID) >= 4;

-- 7. Find the name of the employees who did a mission.
select ENAME
from EMP
where EID in (select EID from MISSION);
-- We don't need to use distinct in "select ENAME" since table EMP is traversed only once.
-- Notice that SMITH is listed twice because we have two employees named SMITH, and they
-- both did a mission.

-- Contrast this with:
select distinct ENAME
from EMP natural join MISSION;
-- Here we need distinct because the join produces duplicate employees, e.g BLAKE is
-- listed twice because he did 2 missions. Problem: distinct will also eliminate one
-- of the two SMITH, which is wrong.

-- 8. Find the employees who did a mission in the city they work in.
select *
from EMP
where (select DLOC from DEPT where DID = EMP.DID) in
      (select MLOC from MISSION where EID = EMP.EID);
      
-- 9. Find the employees who did a mission in the same city Blake did a mission.
select *
from EMP
where exists (select MLOC 
              from MISSION 
              where EID = EMP.EID and 
                    MLOC in (select MLOC
                             from MISSION
                             where EID in (select EID from EMP where ENAME = 'BLAKE')
                            )
             );

-- 10. Find the employees who did a mission in all the cities listed in MISSION (2 methods).
select *
from EMP
where (select count(distinct MLOC) from MISSION where EID = EMP.EID) =
      (select count(distinct MLOC) from MISSION);

select *
from EMP
where not exists
      (select MLOC 
       from MISSION
       where MLOC not in (select MLOC from MISSION where EID = EMP.EID)
      );

-- 
-- EXERCISE 4
-- 

-- 1. For each employee who did at least one mission, display their ID and the number of missions they did.
select EID, count(*)
from MISSION
group by EID;

-- 2. For each employee who did at least one mission, display their name and the number of missions they did.
select ENAME, count(*)
from MISSION natural join EMP
group by EID, ENAME;
-- Note: do not group by ENAME alone: we might have several employees with the same name.

select ENAME, MISSION_COUNT
from (select EID, count(*) as MISSION_COUNT from MISSION group by EID) as core_query natural join EMP;

-- 3. For each employee listed in EMP, display their name and the number of missions they did.
select ENAME, count(MID) as MISSION_COUNT
from MISSION natural right outer join EMP
group by EID, ENAME;

select ENAME, coalesce(MISSION_COUNT, 0) as MISSION_COUNT
from (select EID, count(*) as MISSION_COUNT from MISSION group by EID) as core_query 
     natural right outer join EMP;

-- 4. Find the number of employees each manager (i.e. an employee listed in the MGR column) manages, along with the manager’s name.
select m.ENAME, count(*)
from EMP e join EMP m on e.MGR = m.EID
group by m.EID, m.ENAME;

select ENAME, COUNT
from (select m.EID, count(*) as COUNT from EMP e join EMP m on e.MGR = m.EID group by m.EID) as core_query natural join EMP;

-- 5. For each department, display the name of the department, the number of employees and the highest salary in the department.
select DNAME, count(EID), max(SAL)
from DEPT natural left outer join EMP
group by DID, DNAME;

select DNAME, coalesce(COUNT, 0), MAX
from (select DID, count(EID) as COUNT, max(SAL) as MAX from EMP group by DID) as core_query
     natural right outer join DEPT;

-- 6. Find the average salary per department and per job, along with department and job names.
select avg(SAL), DNAME, JOB
from DEPT natural join EMP
group by DID, DNAME, JOB;

-- 7. Find the highest of the per-department average salary (2 methods).
select max(AVG_SAL)
from (select avg(SAL) as AVG_SAL from EMP where DID is not null group by DID) as temp;
-- Notice that (1) we need to give a name to the give the subquery"s result, (2) we need to
-- rename the "avg(SAL) column of the subquery's result because "max(avg(SAL))" won't work
-- in the main query.

select AVG_SAL
from (select avg(SAL) as AVG_SAL from EMP where DID is not null group by DID) as temp
where AVG_SAL >= all (select avg(SAL) as AVG_SAL from EMP where DID is not null group by DID);

-- 8. Find the departments with the highest of the per-department average salary.
select DNAME
from (select DNAME, avg(SAL) as AVG_SAL from EMP natural join DEPT group by DID, DNAME) as temp
where AVG_SAL >= all (select avg(SAL) as AVG_SAL from EMP where DID is not null group by DID);

-- 9. Find the name of the departments with at least 5 employees and no salary less than 900.
select DNAME
from DEPT natural join EMP
group by DID, DNAME
having count(*) >= 5 and min(SAL) > 900;

-- Notice that the following query does not answer the question correctly in the general case:
select DNAME
from DEPT natural join EMP
where SAL > 900
group by DID, DNAME
having count(*) >= 5;

-- 10. Find the name of the departments with at least 5 employees and located in Chicago.
select DNAME
from DEPT natural join EMP
where DLOC = 'CHICAGO'
group by DID, DNAME
having count(*) >= 5;

select DNAME
from DEPT natural join EMP
group by DID, DNAME, DLOC
having count(*) >= 5 and DLOC = 'CHICAGO';
-- Notice that the first solution is far better than the second one: filtering - when possible - before grouping
-- is more efficient than filtering after grouping. 
 
-- 
-- EXERCISE 5
-- 

-- In question 1-4 we assume that departments with no employee satisfy conditions like "with no employee earning less than...".
-- If we want to exclude such departments, we need to add the following condition in the where clause: 
-- DID not in (select DID from EMP)

-- 1. Find the departments with no employee earning less than 1,000.
select *
from DEPT
where DID not in (select DID from EMP where SAL < 1000);

select *
from DEPT
where not exists (select * from EMP where DID = DEPT.DID and SAL < 1000);

-- 2. Find the departments with some employees earning less than 1,000.
select distinct DEPT.*
from DEPT natural join EMP 
where SAL < 1000;

select *
from DEPT
where DID in (select DID from EMP where SAL < 1000);

select *
from DEPT
where exists (select * from EMP where DID = DEPT.DID and SAL < 1000);

-- 3. Find the departments with only employees earning less than 1,000.
select *
from DEPT
where DID not in (select DID from EMP where SAL >= 1000);

select *
from DEPT
where not exists (select * from EMP where DID = DEPT.DID and SAL >= 1000);

-- 4. Find the departments with all of the employees (inclusive) earning less than 1,000.
select *
from DEPT
where (select count(*) from EMP where DID = DEPT.DID and SAL < 1000) =
      (select count(*) from EMP where SAL < 1000);

select *
from DEPT
where not exists (select * from EMP where SAL < 1000 and DID <> DEPT.DID);


-- 5. Find (a) the cities listed in tables DEPT or MISSION, (b) the cities listed in both DEPT and MISSION and (c) the cities listed in DEPT but not in MISSION.
-- (a)
(select DLOC from DEPT) 
union
(select MLOC from MISSION);

-- (b) Note: MySQL does not implement "intersect". We need a workaround.
select distinct DLOC 
from DEPT
where DLOC in (select MLOC from MISSION);

-- (c) Note: MySQL does not implement "except". We need a workaround.
select distinct DLOC 
from DEPT
where DLOC not in (select MLOC from MISSION);

-- 6. For each city listed in DEPT or MISSION, display the city, the number of employees working in the city (DLOC), the number of employees who did a mission in the city (MLOC).
select *
from ((select DLOC as CITY from DEPT) union (select MLOC as CITY from MISSION)) as temp ;

select CITY, count(distinct EMP.EID) as EMPLOYEE_COUNT, count(distinct MID) as MISSION_COUNT
from ((select DLOC as CITY from DEPT) union (select MLOC as CITY from MISSION)) as temp 
     left outer join (DEPT natural join EMP) on CITY = DLOC
     left outer join MISSION on CITY = MLOC
group by CITY;

-- 7. For each department and for each job listed in EMP, display the department’s name, the job, and the number of employees in that department with that job.
select DNAME, JOB, count(EID)
from ((select DID, DNAME from DEPT) as ds cross join (select distinct JOB from EMP) as js)
     natural left outer join EMP
group by DID, DNAME, JOB;

