use AdventureWorks2022OLTP
select * from sys.tables--get all tables in db
--tables start eith id column
select tbl.name as tablename,col.name as columnname
from sys.tables tbl join sys.all_columns col
on tbl.object_id=col.object_id
where col.name like '%date%'
--------------------------------
--Analytical Functions
FIRST_VALUE (Column) OVER(), LAST_VALUE(Column) OVER(),
LEAD(Column) over (),LAG(column) over()
CUME_DIST() OVER(): cumulative distribution

-------------------------------------------
ASCII('A') CHAR(90)
DATEADD(),DATEPART(),DATEDIFF(),DATENAME()

select * from FactCallCenter

/* Index is used to retreive data from table quickly than others
2 types
1.clustered index: Sorts/ orders the table : automatically created when primary key constraint used on table. B-Tree
2. non-clustered index:dont Sorts/ orders the table: automatically created when unique key constraint used on table
clustered index is faster than non clustered index incase of select statement
non-clustered index is faster than clustered index incase of update,insert statements
only one clustered index per table allowed
syntax : create clustered index/nonclustered index index_name on table(column)
clustered index -physically/permenently sorts table where as non clustered index doesnot sort it has unique row id

when bulk inserting data-> first drop indexes->load data-> then create indexes
Filtered index=> applying filter that is where condition like NOT NULL on column filters result set improves index performance
Index Seek=>Clusterd index: if table have index and applying where condition -> will fetch condition met roe that is =>index seek
Index Scan=> if table have index and not applying any filter/ where condition -> will scan whole index=> index scan
Table scan=> if table do not have index . whole table will be scaned that is table scan
*/
--link server : when we want to retreive data from multiple servers we use link servers. alternative way some type of link with dba team
select * from DimEmployee where FirstName='Guy'  -- clustered index scan : full index scanned
select * from DimEmployee where EmployeeKey=1 -- clustered index seek: filter on primary key
select * from employee -- table scan

------------------------------------------
--how many 'K' Characters repeated in word given
declare @b varchar(20)='ANUSHAJAKKULA'
select len(@b) as totallen,len(REPLACE(@b,'K','')) as removingk,len(@b)-len(REPLACE(@b,'K','')) as krepeatedcount

--CHARINDEX(),SUBSTRING(),LEFT(),like

--display name start with 'J'
select FirstName from DimEmployee where FirstName like 'A%'

select FirstName from DimEmployee where LEFT( FirstName,1)='A'

select FirstName from DimEmployee where SUBSTRING( FirstName,1,1)='A'

select FirstName from DimEmployee where CHARINDEX('A',FirstName)=1


----------------------
--joins
select * from a

select * from b

select *
 from a inner
join b on a.id=b.id

select *
 from a left outer
join b on a.id=b.id


select *
 from a right outer
join b on a.id=b.id

-- output difference ??
select *
 from a left
join b on a.id=b.id

select *
 from b right
join a on a.id=b.id

select *
 from a full outer
join b on a.id=b.id

select *
 from a  full
join b on a.id=b.id

select * from a union select * from b



--@@IDENTITY=> automatically inserts/generates numbers.  returns the last identity of table in current session ,across all scope
--Scope_Identity()=> returns the last identity of table in current session and current scope
--IDENT_CURRENT()=>returns the last identity value geneated for specific table in any session and any scope
--select @@IDENTITY , Scope_Identity(),IDENT_CURRENT(.)

--char=>utilize 1 bytes of space for 1 character. total size will be used even data length is small ; eg a char(10)='abc', data length is 3 but total size 10 will be used
--Varchar=>utilize 1 bytes of space for 1 character. eg a  varchar(10)='abc', data length is 3 but total size 10 .only 3 bytes of space utilized, remaining 7 bytes not utilized 
--NVarchar=> same like varchar. differenece is => It  utilize 2 bytes of space for 1 character.


select 1

select null + 1

select 1 from dimemployee

select count(1) from dimemployee

--reseed the identity column
sp_help dimemployee
select * from dimemployee
DBCC CHECKIDENT('tablename',RESEED,1)
DBCC CHECKIDENT('n',RESEED,0)
create table n (id int identity,name varchar(10))
insert into n values ('anu'),('sailu'),('Pooji'),('sai')
select * from n
drop table n

--COLUMN STORE INDEX:=> we can read the values of specific column of table without reading other values columns of table:=> improves query performance
--sql server 2012 feature-> column store index
--syntax: CREATE NONCLUSTERED COLUMNSTORE INDEX index_name on Tablename(columnnames)
select * from FactCallCenter

create columnstore index colstoreind on FactCallCenter(FactCallCenterID,calls)
 
select FactCallCenterID,sum(calls) as calls from FactCallCenter group by FactCallCenterID  order by  calls 
--reduces cost optimization of query


--commit	: DML statements - insert,update etc  are auto commit. to make it rollback we use begin transaction
select * from dimcustomer
BEGIN TRANSACTION
update dimcustomer 
set firstname='SAM' where customerkey=11000
rollback--  errror: The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.then use BEGIN TRANSACTION

--savepoint : saves the transaction upto some point
--save transaction savepoint_name
--rollback transaction savepoint_name

select * from dimcustomer order by FirstName

BEGIN TRANSACTION

update dimcustomer 
set firstname='SAM' where customerkey=11000

update dimcustomer 
set firstname='SAM' where customerkey=11002

save transaction sp1 --creates savepoint

update dimcustomer 
set firstname='SAM' where customerkey=11003

--rollback : rollback whole changes
rollback transaction sp1

-----------------------------------------------------------
--Trigger 
select * from sys.objects where type='TR'
select type,type_desc from sys.objects  
--enable triggers
ALTER TABLE table_name enable trigger trigger_name
ALTER TABLE table_name enable trigger ALL
--disable triggers
ALTER TABLE table_name disable trigger trigger_name
ALTER TABLE table_name disable trigger ALL

--DDL triggers
--create trigger trigger_name on database|all servers  FOR {create_table|drop_table|alter_table}  trigger body

--DML triggers
--create trigger trigger_name on table_name  FOR {INSERT|UPDATE|DELETE}  trigger body
--create trigger trigger_name AFTER|BEFORE  {INSERT|UPDATE|DELETE} on table_name  trigger body


--given a date .print total days in that month
declare @date date, @min int,@max int,@date1 date  
set @min=1
set @date ='2024-03-18'--getdate()
set @date1=replace(@date,right(@date,2),01)
set @max=right(EOMONTH(@date),2)
while @min<=@max
begin
select @date1
select  @date1=dateadd(day,1,@date1)
set @min=@min+1
end


----how many weekend there after the given date
--'08-04-2024'
declare @dt date ='04-20-2024' 
--select convert(date,@dt)
declare @maxx as int,@minn as int
select @maxx=right(EOMONTH(@dt),2)
select @minn=DAY(@dt)
--select datename(dw,@dt)
declare @cnt int =0
while @minn<=@maxx
	begin
	declare @dayy as varchar(10)
	select @dt=dateadd(day,1,@dt)
	set @dayy=datename(dw,@dt)
	if @dayy in ('saturday','sunday')
		set @cnt=@cnt+1
	--select @dayy
	set @minn=@minn+1
	end
print @cnt


use Practicedb
create table Dept ( deptno int , dname varchar(10))
insert into Dept values (10,'CSE'),(15,'IT'),(20,'ECE'),(25,'EEE'),(30,'MECH'),(40,'CIVIL'),(35,'MBA')
delete from Dept where deptno=20
select * from Dept
select * from employee

select  e.eid,e.salary,e.deptno,coalesce(cast (d.deptno as varchar),'NA') as deptno,isnull(d.dname,'NA')
from employee e left join Dept d
on e.deptno=d.deptno

select  e.eid,e.salary,coalesce(cast (e.deptno as varchar),'NA') as deptno,d.deptno,d.dname
from employee e right join Dept d
on e.deptno=d.deptno

--same salry employees
select * from Employee
select  e.eid,e.salary,e.deptno
from employee e join employee em
on e.eid<>em.eid  and e.salary=em.salary

--duplicate records using count ()
select * from dup_data
insert into dup_data values (1,'anu',24),(1,'anu',24),(1,'anu',24),(1,'anu',24),(1,'anu',24)
select id,fname,age,count(1) as cnt
from dup_data
group by id,fname,age
having count(1)>1

--customers whose dob between 17/07/1999 , 1/07/1998
--select * from DimCustomer where year(birthdate) in (1919,1929,1920) order by	BirthDate
sp_help Dimcustomer
select CustomerKey,FirstName,LastName,BirthDate,MaritalStatus,EmailAddress
from DimCustomer
where BirthDate  between '1970-01-01' and  '1979-01-01' order by BirthDate
--convert(varchar,BirthDate,103)

--date formats in sql.convert(): convert date format function in sql. format numbers 
--https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/
select convert (varchar,BirthDate,103) from DimCustomer

--max baserate from each dept
select DepartmentName,baserate  from DimEmployee order by DepartmentName,baserate 
select DepartmentName,count(1) deptcount,max(baserate) as baserate
from DimEmployee
group by DepartmentName


--Joins
select * from DimCustomer
select * from DimGeography

select  distinct  * 
from DimCustomer dc join DimGeography dg
on dc.GeographyKey = dg.GeographyKey

select * 
from DimEmployee 













