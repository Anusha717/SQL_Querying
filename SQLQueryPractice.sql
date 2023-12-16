--DDL: CREATE,ALTER,TRUNCATE,DROP,SP_RENAME
create database sai
use sai;
create table laptop(companyname varchar(20), RAM int, Storage varchar(5), color char(10) );
--structure of table
sp_help laptop;
sp_help pc;
--change column datatype & size
alter table  laptop alter column cname char(10);
-- add column to table
alter table laptop add os varchar(10);
--change column name ,table name using sp_rename
SP_RENAME'laptop.companyname','brandname';
sp_rename 'pc','laptop'
--drop columns from table 
alter table laptop drop column os ;
--insert data to table
--insert into laptop values('lenovo',8,'1TB','silver'),('MAC',16,'5TB','Black');
select * from laptop
--truncate table -where clause not allowed
truncate table laptop;
--drop table 
drop table laptop


--DML: INSERT,DELETE,UPDATE
--insert data to table
insert into laptop values('lenovo',8,'1TB','silver'),('MAC',16,'5TB','Black');
--Update values 
update laptop set storage='4TB'  where RAM=16;
--delete specific values 
delete from laptop where color='Grey';
delete from laptop -- same as truncate

--Identity function default 1 value for seed,increment
--IDENTITY(SEED,INCREMENT)
create table tab1(id int identity, name char(20))--default increments 1
create table tab11(id int identity(15,5), name char(20))
select * from tab11
drop table tab11
insert into tab11 values('a'),('b'),('c')--allowed
insert into tab11 values(15,'a'),(20,'b'),(25,'c')--not allowed because identity_insert is off by deafult
create table tab121(id int identity(15,5), name char(20))
set identity_insert tab121 on
insert into tab121 (id,name) values(1,'n')
insert into tab121 (id,name) values(35,'a')
select * from tab121
--SET Operators- combine more select stmts:
--rules->no of columns,order,datatype must be same for both select stmts
--UNION-without duplicates,UNION-with duplicates ALL,INTERSECT,EXCEPT

create table emp_hyd(eid int,ename char(10),sal int)
create table emp_chennai(eid int,ename char(10),sal int)

select * from emp_chennai;
select * from emp_hyd;

select * from emp_chennai 
union
select * from emp_hyd

select * from emp_chennai 
union all
select * from emp_hyd

select * from emp_chennai 
intersect
select * from emp_hyd
--except :shows left table data 
select * from emp_chennai 
except
select * from emp_hyd

insert into emp_chennai values (2,'s',30000)
insert into emp_chennai values (14,'manu',30000)
delete  from emp_hyd where sal='50000'

select eid,sal from emp_chennai 
union
select  eid,sal  from emp_hyd

select eid from emp_chennai 
union
select  sal  from emp_hyd

--constraints
--PRIMARY KEY & FOREIGN KEY 
USE anu
CREATE TABLE STUDENT(SID INTEGER PRIMARY KEY, SNAME VARCHAR(20), DOB DATE ) 
CREATE TABLE MARKS(SUB VARCHAR(20),MRKS INTEGER,SID INTEGER REFERENCES STUDENT(SID)) 
SELECT * FROM STUDENT--PARENT TABLE
SELECT * FROM MARKS--CHILD TABLE
INSERT STUDENT VALUES (1,'ANU','1999-07-17'),
(2,'JANU','1989-01-09'),
(3,'KAVYA','1799-09-03'),
(4,'SAILU','2001-06-07'),
(5,'POOJI','2003-07-13'),
(6,'SAI','1998-07-01')
--1-6 VALUES ARE REFERENCE VALUES ONLY THAT WILL BE INSERTED INTO CHILD TABLE
--SID IS REFERENCE COLUMN IN PARENT TABLE
INSERT MARKS VALUES ('MATHS',77,4),('MATHS',83,2),
('MATHS',88,1),('MATHS',79,3),
('MATHS',87,6),('MATHS',97,5)
SP_HELP MARKS
INSERT MARKS VALUES ('MATHS',98,7)--FOREIGN KEY CONTRAINT VIOLATION
INSERT STUDENT VALUES (null ,'ANU','1999-07-17')

--JOINS
--ANSI FORMAT JOINS: WITH "ON" CONDITION INNNER,OUTER[FULL OUTER,LEFT OUTER,RIGHT OUTER],CROSS JOIN,NATURAL(SUPPORTED IN ORACLE SAME LIKE INNER JOIN BUT WITHOUT DUPLCATES)
--INNER JOIN  BASED ON EQUALITY CONDITION
--NON ANSI FORMAT JOINS: WITH "WHERE"::;EQUI JOIN NON-EQUI JOIN, SELF JOIN

CREATE TABLE STD(SID INTEGER PRIMARY KEY,SNAME VARCHAR(20),AGE INTEGER)
CREATE TABLE COURSE(CID INTEGER,SID INTEGER,CNAME CHAR(10), TUTOR VARCHAR(20),PRIMARY KEY (CID,SID))

SELECT * FROM STD
SELECT * FROM COURSE
INSERT COURSE VALUES(71,1,'N','A')--NOT ALLOWED BECAUSE OF PRIMARY KEY VIOLATION
DELETE FROM COURSE WHERE CNAME='N' AND CID=7

SELECT S.SID,S.SNAME,C.CID,C.CNAME,C.TUTOR
FROM STD S INNER JOIN COURSE C
ON S.SID=C.SID 

SELECT S.SID,S.SNAME,C.CID,C.CNAME,C.TUTOR
FROM STD S LEFT /*RIGHT*/ OUTER JOIN COURSE C
ON S.SID=C.SID 

SELECT S.SID,S.SNAME,C.CID,C.CNAME,C.TUTOR
FROM STD S RIGHT OUTER JOIN COURSE C
ON S.SID=C.SID

SELECT S.SID,S.SNAME,C.CID,C.CNAME,C.TUTOR
FROM STD S FULL OUTER JOIN COURSE C
ON S.SID=C.SID 


CREATE TABLE EMP(EID INTEGER,ENAME VARCHAR(20),JOB VARCHAR(20),
DOJ DATE,SAL INTEGER, DEPT INTEGER)
SELECT * FROM EMP
--clauses:GROUP BY,HAVING
SELECT JOB,COUNT(EID) FROM EMP
GROUP BY JOB;

SELECT JOB,SUM(SAL) SALRY ,COUNT(EID) FROM EMP
GROUP BY JOB HAVING SUM(SAL) > 100000

--TCL-BEGIN TRANSACTION,COMMIT,ROLLBACK,SAVEPOINT
--DML Operations are by default AUTO COMMIT OPERATIONS(permanent cant be rollback)
--explicity transactions can be rollback,commit using tcl commands
--1.BEGIN TRANSACTION=start transaction- to make dml operations explicitly save,undo using commit,rollback
--2.COMMIT=permanently save by user explicilty
--3.ROLLBACK=UNDO Operation by user explicilty
--4.SAVEPOINT=temporary memory to save/store rejected rows separate  
create table Bank(Bname varchar(20),branch varchar(20),manager varchar(20))
ex:
insert into Bank values ('Union Bank of India','Moulali','Anusha')
BEGIN TRANSACTION
ROLLBACK--cannot rollback because dml operations are auto commit operations by default(implictly)
select * from Bank

BEGIN TRANSACTION 
--insert into Bank values ('Union Bank of India','Moulali','Anusha')
--update Bank set branch='nacharam' where manager='Anusha'
delete from Bank where manager='Anusha'
commit
BEGIN TRANSACTION
ROLLBACK
select * from Bank
--3.SAVEPOINT SYNTAX:
--SAVE TRANSACTION POINTER_NAME
--<WRITE STMTS>
--BEGIN TRANSACTION
--ROLLBACK TRANSACTION POINTER_NAME
select * from Bank
BEGIN TRANSACTION 
--UPDATE BANK SET branch='RADHIKA' WHERE Bname='HDFC'
DELETE FROM BANK WHERE Bname='HDFC'
--COMMIT  -- ONE BUFFER
SAVE TRANSACTION S1
DELETE FROM BANK WHERE Bname='UBOI'

BEGIN TRANSACTION
ROLLBACK
SELECT * FROM BANK
BEGIN TRANSACTION
ROLLBACK TRANSACTION S1

--CHAR(SIZE)(FIXED LENGTH DATA TYPE) VS VARCHAR(SIZE)(VARIABLE LENGTH DATA TYPE)
--ROLLUP  & CUBE CLAUSE=USED TO CALCULATE SUB, GRAND TOTAL USED ALONG WITH GROUP BY CLAUSE
--CUBE CLAUSE=USED TO CALCULATE SUB, GRAND TOTAL ON MULTIPLE COLUMN
--ROLLUP CLAUSE=USED TO CALCULATE SUB, GRAND TOTAL ON SINGLE COLUMN
--SELECT COL1,COL2,.. FROM TABLE GROUP BY ROLLUP/CUBE(COL1,COL2,..)

--STORED FUNCTIONS=USER DEFINED FUNCTIONS
/*1. SCALAR VALUED FUNC -RETURNS SINGLE VALUE AS O/P

create [alter] function fnname(@dparameter datatype(size),..)
returns returntype paramater/attribute
as
begin
function function body
return(select query )
end
frunc call: select func(paramter)*/
create function svf1(@eid varchar(20))
returns money
as 
begin
declare @basic money,@hra money,@da money,@pf money,@gross money
select @basic=salary from employee where eid=@eid
set @hra=@basic*0.1
set @da=@basic*0.2
set @pf=@basic*0.3
set @gross=@hra+@da+@pf+@basic
return @gross
end

select dbo.svf1('7Z2')

select * from employee


/*
2. TABLE VALUED FUNC-RETURNS table as o/p */

create function tvf1(@deptno integer)
returns table
as
return(select * from employee where deptno=@deptno )

select  * from tvf1(10)

/*
Ranking func- ROW_NUMBER,RANK,DENSE_RANK

select row_number()/rank()/dense_rank() over (partition by col order by col [asc|desc]) from table

*/
create table employee(eid varchar(20),salary integer, deptno int)
select * from employee

insert into employee values('7Z6',60000,20),('7Z2',60000,10),('7Z3',50000,10),('7Z4',70000,20),('7Z5',50000,20)
select eid,salary,deptno, row_number() over(partition by deptno order by salary asc) from employee
select eid,salary,deptno, ranK() over(partition by deptno order by salary asc) from employee
select eid,salary,deptno, dense_ranK() over(partition by deptno order by salary asc) from employee

--stored procedures with parameters,without parameters
create [alter] procedure procedure_nam
as 
begin 
procedure body
end

--calling: execute/exec procedure_nam
 eg: 
 create procedure p1
 as
 begin 
 select * from employee
 end

 exec p1

-- procedure with paramters

create procedure p2(@eid varchar(20),@pf int out , @pt int out)
as
begin
declare @sal money
select @sal=salary from employee where eid=@eid
set @pf=@sal*0.1
set @pt=@sal*0.2
end

call:
declare @bpf int,@bpt int
execute p2 '7Z1',@bpf out,@bpt out
print @bpf
print @bpt



--constraints-Primary Key,Unique Key,Foreign Key,Not NUll, check
--without cascade rules :FK,PK .insertion in child table not ok but parent table ok,deletion in parent table not ok, updation in parent table not ok
--with cascade rules: on update cascade ,on delete cascade applied on child table to update or delete from parent table along with child table without any violation


create table student(sid integer primary key, sname varchar(10),age int)
create table dept(deptid int,dname char(5),sid integer foreign key references student(sid))
select * from dept
select * from student
--without cascade
--insertion new row in parent table allowed,new row on child table not allowed
insert into student values(26,'janu',20)--allowed:insert new row to parent table 
insert into dept values(226,'cse',10)--not allowed:insert new row to child table 
insert into dept values(226,'cse',26)--allowed:insert existing row in parent table  to child table
--deletion refernece col in parent table not allowed,
delete from student where sid=26
delete from dept where sid=26--ok
--updation reference col in parent table not allowed,
update student set sname='FALTOO' where sid=2--ok because updating non reference column
update student set sid=65 where sname='FALTOO'
update dept set dname='eee' where sid=1--ok
--with cascade rules
drop table dept1
create table student1(sid integer primary key, sname varchar(10),age int)
create table dept1(deptid int,dname char(5),sid integer foreign key
references student1(sid) on update cascade on delete cascade)
select * from dept1
select * from student1

--insertion new row in parent table allowed,new row on child table not allowed(fixed)
insert into student1 values(99,'ram',27)--allowed:insert new row to parent table 
insert into dept1 values(226,'cse',10)--not allowed:insert new row to child table 
insert into dept1 values(222,'cse',99)--allowed:insert existing row in parent table  to child table
--deletion refernece col in parent table  allowed,
delete from student1 where sid=799
delete from dept1 where sid=26--ok
--updation reference col in parent table allowed,
update student1 set sname='FALTOO' where sid=2--ok because updating non reference column
update student1 set sid=799 where sid=99
update dept1 set dname='eee' where sid=1--ok

--cursors in T/SQL: implicit & explicit cursors
--temporary memory for storing db tables
--declare,open,fetch,close,deallocate cursor
--without cursor variables
declare  c1 cursor for select * from employee
open c1
--fetch next from c1
fetch next/*/first/last/prior/absolute n/relative n*/ from c1 --[into variables]
close c1
deallocate c1
--with cursor variables
declare c2 cursor scroll for select eid, salary from employee
open c2
declare @id varchar(20),@salry varchar(20)
fetch relative -1 from c2 into @id,@salry
print 'ID '+ cast(@id as varchar(20))
print 'salary '+cast(@salry as varchar(20))
close c2
deallocate c2
--sub queries: 1.non corelated sub query=inner query 1st executed next outer query[1.single row sb(=),2.multiple row sb(IN)],
--2. co-related sub query=1st executed outer query next inner query executes.
select * from employee
select top 1 * from employee order by salary desc 
select * from employee where salary in (select max(salary) from employee)-- employee with highest salry
select * from employee where salary =(select max(salary) from employee where salary < (select max(salary) from employee where salary < (select max(salary) from employee)))-- employee with 2nd highest salry
select * from employee where salary  in   (select max(salary) from employee where salary not in (select max(salary) from employee))-- employee with 2nd highest salry
--corelated subquery
select * from employee e1 where /*n-1*/1=(select count(salary) from employee e2 where e2.salary > e1.salary)


select * from employee where deptno in(select deptno from employee where eid='7Z1')

--views-logical/virtual table::: 1.simple view=updatable view.acess single table 2. complex view=non updatable view.acess multiple table
--simple view 
--syntax: create view view_name as select query
create view v1 as select * from employee
select * from v1
insert into v1 values('7Z7',90000,70)
update v1 set salary=80000 where eid='7Z5'
delete from v1 where eid='7Z3'

--complex view - cannot perform DML Operations. only select i.e read
create view v2 as 
select * from employee
union 
select * from emp1

create table emp1(eid varchar(20),salary int,deptno int)
insert emp1 values ('b12',70000,16), ('b13',80000,20), ('b14',60000,40), ('b15',50000,35), ('b16',40000,46)
select * from v2

insert into v2 values('7Z9',90000,30)
update v2 set salary=80000 where eid='7Z1'
delete from v2 where eid='7Z4'




