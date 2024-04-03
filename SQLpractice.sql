-- how many tables have same column name
select tbl.name as tablename , col.name as column_name
from sys.tables as tbl join 
sys.all_columns as col
on tbl.object_id=col.object_id
where col.name like '%name%'


--string functions:left(),right(),substring() 
select * from DimDate;
select left(EnglishMonthName,3) as month_name,EnglishMonthName, right(DateKey,2) as datekey,DateKey, EnglishDayNameOfWeek,substring(EnglishDayNameOfWeek ,1,3) as day_name,* from DimDate;

--age:datediff(interval,date1,date2)-string function,abs(int-int)
select  DATEDIFF(Year,'2017','2020') as tenure;
sp_help dimdate ;
select  CalendarYear,GETDATE() today,
DATEDIFF(YEAR,'2005',cast(year(GETDATE()) as varchar)) as dif,
DATEDIFF(YEAR,calendaryear,cast(datepart(yyyy,GETDATE()) as varchar)) as diff ,ABS(2005-2024) as yerdiff from DimDate;

--Stored Procedure and function calling function inside sp
use Practicedb;
create function multiply1(@n1 int,@n2 int)
returns int 
as
	begin
		declare @product as int
		set @product=@n1*@n2
		return @product
	end;

select Practicedb.dbo.multiply1(2,3)	

create procedure p_multiply
@num1 as int,
@num2 as int
 as 
 begin 
 print 'sum is :'+ cast(@num1+@num2 as varchar);
 declare @product as int
 set @product=dbo.multiply1(@num1,@num2);
 print 'product is :'+ cast(@product as varchar);
 end

 exec dbo.p_multiply 5,6



----------------------------------------------------------------------------------------------------------------------------------------
select * from DimEmployee;
--duplicate records
select firstname ,count(firstname) as cnt from DimEmployee group by FirstName having count(firstname)>1 ;
--alternate records
select * from (select ROW_NUMBER() over(order by employeekey ) as rnk,* from DimEmployee) as tbl1 where rnk%2<>0 --where rnk %2=0
--last record from table
select top 1 ROW_NUMBER() over(order by employeekey desc ) as rnk,* from DimEmployee ;
select top 1 * from DimEmployee order by EmployeeKey desc ;
select LAST_VALUE(ParentEmployeeKey) over(order by parentemployeekey)  as lastvalue, EmployeeKey from DimEmployee;

--nth record 5th record from table
select * from(select ROW_NUMBER() over(order by employeekey  ) as rnk,* from DimEmployee ) as tbl2 where rnk=5 ;
--age:datediff()
select * from DimCustomer;
select CustomerKey,BirthDate,DATEDIFF(YEAR,BirthDate,GETDATE()) as age from DimCustomer;
--copy from 1 tbl to another tbl with & wihtout data
select CustomerKey,BirthDate,DATEDIFF(YEAR,BirthDate,GETDATE()) as age into customerage from DimCustomer where 1=1;
select * from customerage;
select CustomerKey,DATEDIFF(YEAR,BirthDate,GETDATE()) as age into customerage1 from DimCustomer where 1=2;
select * from customerage1;
--highest salry,nth highest salry
select top 1 * from dimreseller order by annualrevenue desc ;
select top 1 * from(select resellerkey,businesstype,numberemployees,annualsales,annualrevenue,minpaymentamount,
dense_rank() over( partition by businesstype order by annualrevenue desc)  as highestannualrankk
from practicedb.dbo.DimReseller ) as tbl1 where highestannualrankk=2;

select top 10 * from  DimReseller
--delete duplicate records except 1-using row_number(),with cte
select * from dimcustomer;
select distinct englisheducation,count(englisheducation) as countt  from dimcustomer group by englisheducation;
select firstname,count(firstname) from dimcustomer group by firstname;

begin transaction
delete d from dimcustomer d inner  join (select row_number() over(partition by firstname order by customerkey asc) as rk ,* from dimcustomer) as tbl2
on d.customerkey=tbl2.customerkey where rk>1;
begin transaction
rollback


;with CTE as  
   (  
     select firstname,customerkey,emailaddress,birthdate,
		ROW_NUMBER() over(partition by firstname order by customerkey) as rnk
		 from DimCustomer
    )  
 select * from cte
delete FROM CTE where rnk>1

--mask the imp data :substring
select firstname,customerkey,emailaddress, concat('*****',substring(emailaddress,charindex('@',emailaddress), len(emailaddress))) as maskemail,
concat('********',substring(emailaddress,6, len(emailaddress)-5)) as masked5letters,
substring(emailaddress,charindex('@',emailaddress)+1,len(emailaddress)) as domain ,birthdate from DimCustomer

--lead(column) over():get next row data

--lag(column) over() :get previous row data
select customerkey,customeralternatekey, lead(customeralternatekey) over(order by customerkey) as nextvalue,
lag(customeralternatekey) over(order by customerkey) as previousvalue from dimcustomer

--ntile(n) over(): divides result set into n equal groups{10 records ntile(5) 5groups 2 records in each group}
select *, ntile(3) over (order by customerkey) as ntile_group from (select top 20 customerkey,customeralternatekey from dimcustomer) as tbl3

--trigger
select * from bank
insert into bank values ('rbl','uppal','sasha')
create table audit_table (id int identity,name varchar(50))
drop table audit_table
select * from audit_table
drop trigger trg_insert

create trigger trg_insert
on bank
for insert
as
begin
	declare @bn varchar(50)
	select @bn=bname from inserted
	insert into audit_table values ('inserted: '+ @bn+ '  on '+cast(getdate() as varchar))
end

create table delete_history(id int identity,  [Bname] nvarchar(10)
      ,[branch]  nvarchar(10)
      ,[manager]  nvarchar(10))

drop table delete_history
select * from delete_history
delete from bank where manager='sasha'

create trigger delete_trg
on bank
after delete
as
begin
	insert into delete_history(bname,branch,manager)
	select bname,branch,manager from deleted
end

--cte recursive: factorial

with factcte(num,res) as (
select 1,1--anchor member

union all

select num+1, (num+1)*res from factcte -- recursive member
where num<10
)
select * from factcte

--datediff(),lead(),lag() -> 2 consecutive employes orderdate,3 consecutive employes orderdate
select wagetype,replace(wagetype,'day','DAYY') as colm from factcallcenter

--common records-intersect
use practicedb
select * from dimemployee
intersect
select stmt

--sql
use practicedb
select * from factinternetsales
select max(TaxAmt),min(TaxAmt),avg(TaxAmt) from factinternetsales
select orderdate,max(UnitPrice) as maxprice,min(UnitPrice) as minprice from factinternetsales group by orderdate
select * from dimcustomer
select avg(yearlyincome),englisheducation from dimcustomer group by englisheducation having EnglishEducation='High School'
select * from factcallcenter
select sum(issuesraised) totalissues from factcallcenter where WageType='holiday'
select wagetype,issuesraised  from factcallcenter  where WageType='holiday'
--list all object names & types
select distinct type,type_desc from sys.objects order by 10

------------------------------------------------------------------------------------
select * from dimemployee
select (birthdate),year(birthdate),month(birthdate),day(birthdate),datename(dw,birthdate) from dimemployee
select employeekey,firstname,hiredate,enddate,datediff(year, startdate,coalesce(enddate, GETDATE())) 
from dimemployee where datediff(year, startdate,coalesce(enddate, GETDATE())) >5
select birthdate , datediff(year,birthdate,getdate()) as age from dimemployee where datediff(year,birthdate,getdate())>30

--firstpurchase by customers on firstdate 
select top 5 * from dimcustomer order by datefirstpurchase asc 
-- customers firstpurchase  on firstdate 
declare @dateofpurchase as datetime
select @dateofpurchase=Min(datefirstpurchase) from dimcustomer
select * from dimcustomer where DateFirstPurchase= @dateofpurchase
--split column value bfore + symbol
select frencheducation , substring(frencheducation,1,charindex('+',frencheducation)-1) as new_column from dimcustomer where frencheducation like '%+%'
--add new column and update fullname for males only
select concat(FirstName,' ',LastName)as full_name,* from dimcustomer where Gender='M'
alter table dimcustomer add full_name varchar(30)
update dimcustomer set full_name= concat(FirstName,' ',LastName) where Gender='M'
--find monthly income from yearly income column
select (YearlyIncome/12) as monthly_income , YearlyIncome from dimcustomer
--query to find age of employee when joined organization
select * from dimemployee
select hiredate,birthdate,datediff(year,birthdate,hiredate) as age from dimemployee
--first 10 letters from address,length of address
select addressline1,left(addressline1,10) ,len(addressline1) as lengthh from dimcustomer
select * from dimcustomer;
select max(YearlyIncome) as maximum, min(YearlyIncome) as minimum from dimcustomer where englishoccupation='Management';

select * from dimcustomer;
---avg yearly income of customer 
select avg(YearlyIncome) as avg_yearly_income,spanishOccupation from dimcustomer group by spanishOccupation having spanishOccupation = 'Gestión'
--total bachelors in EnglishEducation
select count(1) as total_bachelors,EnglishEducation from dimcustomer group by EnglishEducation having EnglishEducation='Bachelors';
--7th highest yearly income
select YearlyIncome,income_ranking,* from ( select *,dense_rank() over(order by YearlyIncome desc) as income_ranking
from dimcustomer ) as tb7 where income_ranking=7 ;
--6th highest yearly income for bachelors customers
select YearlyIncome,income_ranking,EnglishEducation,* from ( select *,dense_rank() over(partition by EnglishEducation order by YearlyIncome desc) as income_ranking
from dimcustomer ) as tb8 where income_ranking=6 and EnglishEducation= 'Bachelors' ;
--list customers dont have middle name
select Firstname,LastName,MiddleName from dimcustomer where ISNULL (MiddleName,'')=''
--set9: stored procedure

create procedure s_p
as 
begin
	select * from dimcustomer;
end;

exec s_p

create procedure s_p_with_parameters
@firstnme as varchar(20),
@lastnme as varchar(20)
as 
begin
	select * from dimcustomer where firstname=@firstnme and lastname=@lastnme;
end;
drop procedure s_p_with_parameters

declare @fname as varchar(20),@lname as varchar(20)
select @fname=firstname,@lname=lastname from dimcustomer where customerkey=11000
exec s_p_with_parameters @fname,@lname

--validate parameters in stored procedure
select * from dimcustomer

create procedure s_p_validation(@occupation varchar(40))
as
begin
set nocount on
if (charindex(',',@occupation)>0)
--begin
print 'error provide single value'
--return
--end

if not exists (select 1 from dimcustomer where englishoccupation=@occupation)
--begin 
print 'provide correct values like  Management,Skilled Manual ,Clerical ,Professional '
--return
--end

select englishoccupation,count(1) as total
from dimcustomer group by englishoccupation having englishoccupation=@occupation
end

exec s_p_validation 'Professional'
exec s_p_validation 'Professionall'
exec s_p_validation 'Professional, Management'
drop proc s_p_validation
select 1,* from dimcustomer where englishoccupation='professional'
--exception handling
begin try  end try
begin catch end catch
--optional parameters . assigning null or default value so that passing parameters while calling is optional

create procedure s_p1(@param1 varchar(10)=Null,@param2 int =0,@param3 varchar(5)='N/A')
as 
begin
	select @param1 as name,@param2 as dob ,@param3 as available
end
drop proc s_p1
exec s_p1 --optional 
exec s_p1 'anu',17,'yes'--providing all values
exec s_p1 'anu',17



/*Develop a stored procedure based on the below requirements.
1. Input parameter is Gender and must pass single value if the user passes
multiple values than will pre-validate the SP and throw an error.
2. If TotalChildren column value is greater than or equal to 3 than update
YearlyIncome with double */

if exists (Select null from dbo.SysObjects where name = N'UpdatebyGender' and
type = N'P')
Begin
Drop Proc dbo.UpdatebyGender
End
Go
Create Proc dbo.UpdatebyGender(
                @Gender varchar(10)
				)
As
Begin

if CHARINDEX(',',@Gender)>0
Begin
    Print'Invalid Parameter'
	return
end

Create table #dimcustomer_dup (id int identity, Customerkey int, Yearlyincome money , Totalchildren int )
Insert into #dimcustomer_dup (Customerkey,Yearlyincome,Totalchildren)
Select Customerkey,Yearlyincome,Totalchildren
from dimcustomer_dup Where Gender = @Gender

create index IX_#dimcustomer_dup on #dimcustomer_dup(Customerkey)

--Create table #dimcustomer_Result (Customerkey int, Yearlyincome_OLD money ,Yearlyincome_new money, Totalchildren int )


Declare @min int, @max int,@Yearlyincome money, @Totalchildren int, @Customerkey int

Select @min = min(ID), @max = max(ID) from #dimcustomer_dup

While @max >= @min
  Begin 
   --set @Customerkey = null
   Set @Yearlyincome  = null
   set @Totalchildren = null
   Select @Customerkey = Customerkey,@Yearlyincome = Yearlyincome,@Totalchildren = Totalchildren from #dimcustomer_dup where id = @min

  If @Totalchildren >=3
    Begin
	     BEGIN TRY
		   BEGIN TRANSACTION 
		  --  SELECT 1/0
		   ----update statement
	     Update dimcustomer_dup Set Yearlyincome = 2*@Yearlyincome  Where Customerkey = @Customerkey

  commit transaction
  
  Print'Script updated seccessfully'

 End Try
    Begin Catch
	  Rollback Tran
	        Print '   ERNumber: ' + CAST(ERROR_NUMBER() as varchar)
			Print '   Error_Severity: ' + CAST(ERROR_SEVERITY() as varchar)
			Print '   Error_State : ' + CAST(ERROR_STATE() as varchar)
			Print '   Error_Procedure: ' + CAST(ERROR_PROCEDURE() as varchar(500))
			Print '   Error_Line : ' + CAST(ERROR_LINE() as varchar)
			Print '   Error_Message:' + CAST(ERROR_MESSAGE()as varchar(500))
	End Catch


	end
	Else
	  begin
	     Print'Customer having less than three children. And number of children having' + cast( @Totalchildren as varchar(100))
		 End
    
	Set @min = @min+1

  end
         --Insert into #dimcustomer_Result(Customerkey,Yearlyincome_OLD,Yearlyincome_new,Totalchildren)
		  select d.CustomerKey,t.Yearlyincome,d.YearlyIncome,d.TotalChildren
		  from dimcustomer_dup d
		  Join #dimcustomer_dup t on t.Customerkey = d.CustomerKey


  end
  Go
  use practicedb
Select * from dimcustomer_dup
select * into dimcustomer_dup from dimcustomer
drop proc UpdatebyGender
Exec UpdatebyGender 'M'
Exec UpdatebyGender 'M,f'

-------------------------------

-- Update table using file

if exists (Select null from dbo.SysObjects where name = N'UpdateTable_UsingFile' and type = N'P')
Begin
	Drop Proc UpdateTable_UsingFile
End
Go

Create Procedure dbo.UpdateTable_UsingFile(
                     @SourcePath Nvarchar(4000))
As
Begin

Declare @SQL NVARCHAR(4000)

--declare @SourcePath Nvarchar(4000)
--Set @SourcePath = 'D:\SQLTrainingDataBase\Test.csv'


if object_id('tempdb..#tmpFileData') is not null drop table #tmpFileData
Create table #tmpFileData(EmployeeKey int,FirstName Varchar(400), LastName Varchar(400),Phone bigint)

Set @sql = 'BULK INSERT #tmpFileData FROM ''' + @SourcePath + ''' WITH ( FIRSTROW = 2,DATAFILETYPE = ''char'',FIELDTERMINATOR = '','', ROWTERMINATOR =''\n'' )'  
EXEC(@sql) 

 --select * from #tmpFileData

 BEGIN TRY
	BEGIN TRAN

			 Update e
			 set e.Phone = t.Phone
			 from dimemployee e
			 Join #tmpFileData t on t.EmployeeKey = e.EmployeeKey

Commit Tran

End Try
Begin Catch 
			Rollback Tran
			Print '   ERNumber: ' + CAST(ERROR_NUMBER() as varchar)
			Print '   Error_Severity: ' + CAST(ERROR_SEVERITY() as varchar)
			Print '   Error_State : ' + CAST(ERROR_STATE() as varchar)
			Print '   Error_Procedure: ' + CAST(ERROR_PROCEDURE() as varchar(500))
			Print '   Error_Line : ' + CAST(ERROR_LINE() as varchar)
			Print '   Error_Message:' + CAST(ERROR_MESSAGE()as varchar(500))
		End Catch

--Output
Select  *
from DimEmployee e
Join #tmpFileData t on t.EmployeeKey = e.EmployeeKey

End
go

Exec UpdateTable_UsingFile @SourcePath = 'D:\SQLTrainingDataBase\Test.csv'

--bulk load csv file to table


if exists(select null from sys.objects where name='csvfileloadtable') 
--print'there'
drop table csvfileloadtable
create table csvfileloadtable(Employeekey int,FirstName varchar(50), LastName varchar(50),Phone bigint)

declare @sourcepath varchar(4000)
set @sourcepath='D:\SQLTrainingDataBase\csvfileloadtotable.csv'

declare @sql varchar(4000)--dynamic sql
set @sql='BULK INSERT csvfileloadtable FROM '''+@sourcepath+''' with (FIRSTROW=2,DATAFILETYPE=''char'',FIELDTERMINATOR='','',ROWTERMINATOR=''\n'')'
exec(@sql)

select * from csvfileloadtable  
sp_help csvfileloadtable 

=====================================================================================================================================================
--Tricky questions



 













====================================================================================================================================


--TCL-BEGIN TRANSACTION,COMMIT,ROLLBACK,SAVEPOINT
--DML Operations are by default AUTO COMMIT OPERATIONS(permanent cant be rollback)
--explicity transactions can be rollback,commit using tcl commands
--1.BEGIN TRANSACTION=start transaction- to make dml operations explicitly save,undo using commit,rollback
--2.COMMIT=permanently save by user explicilty
--3.ROLLBACK=UNDO Operation by user explicilty
--4.SAVEPOINT=temporary memory to save/store rejected rows separate  
create table Bank(Bname varchar(20),branch varchar(20),manager varchar(20))
sp_help Bank
ex:
insert into Bank values ('Union Bank of India','Moulali','Anusha')
BEGIN TRANSACTION
ROLLBACK--no error & also cannot rollback because dml operations are auto commit operations by default(implictly)
  

BEGIN TRANSACTION 
insert into Bank values ('Union Bank of India','Moulali','Anusha')
--update Bank set branch='nacharam' where manager='Anusha'
--delete from Bank where manager='Anusha'
--commit--:if commit uncommented cant rollback
select * from Bank
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
--insert into Bank values ('Union Bank of India','Moulali','Anusha')
--update Bank set Bname='HDFC' where manager='Anusha'
UPDATE BANK SET branch='RADHIKA' WHERE Bname='HDFC'
DELETE FROM BANK WHERE Bname='HDFC'
--COMMIT  -- ONE BUFFER
SAVE TRANSACTION S1n
insert into Bank values ('UBOI','Mysore','sasha')
DELETE FROM BANK WHERE Bname='UBOI'
		
BEGIN TRANSACTION
ROLLBACK
SELECT * FROM BANK
BEGIN TRANSACTION
ROLLBACK TRANSACTION S1n

------------------------------
SELECT * FROM BANK
insert into Bank values ('rbl','Mysore','sasha')
delete from bank where manager='sasha'
BEGIN TRANSACTION
insert into Bank values ('rbl','Mysore','sasha')
select @@trancount
ROLLBACK TRANSACTION
select @@trancount

BEGIN TRANSACTION
insert into Bank values ('rbl','Mysore','sasha')
select @@trancount
COMMIT TRANSACTION
select @@trancount
---------------------------

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
create function svsalary(@eid varchar(20))
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

select dbo.svsalary('7Z2')

select * from employee


/*
2. TABLE VALUED FUNC-RETURNS table as o/p */

create function tvemp(@deptno integer)
returns table
as
return(select * from employee where deptno=@deptno )

select  * from tvemp(10)

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
create --[alter] procedure procedure_nam
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
drop procedure p2
call:
declare @bpf int ,@bpt int
exec p2 '7Z1',@bpf out,@bpt out
print @bpf
print @bpt


