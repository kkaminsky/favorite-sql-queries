
create table team(
	id INT IDENTITY PRIMARY KEY,
	team_name  NVARCHAR(50) NOT NULL
);

CREATE TABLE developer
(
    id INT IDENTITY PRIMARY KEY,
    full_name NVARCHAR(50) NOT NULL,
	team int NOT NULL
	constraint fk_developer_team foreign key (team)
	references team(id) 
		on update no action
		on delete no action
);

CREATE TABLE project
(
	id INT IDENTITY PRIMARY KEY,
	project_name NVARCHAR(50) NOT NULL,
	team int NOT NULL,
	city NVARCHAR(50) NOT NULL
	constraint fk_project_team foreign key (team)
	references team(id) 
		on update no action
		on delete no action
);


insert team values
('logistics_team'),
('adapters_team');

insert developer values 
('Denis',1),
('Akmal',1),
('Ekaterina',1),
('Ruslan',2),
('Rustam',2),
('Nick',2);

insert project values 
('logistics_tyumen',1,'tyumen'),
('logistics_moscow',1,'moscow'),
('adapters_tyumen',2,'tyumen');


use lab02;
go
create procedure pr_create_ved
	@team NVARCHAR(50),
	@city NVARCHAR(50)
as
begin

	declare @table_name nvarchar(500);

	declare @DynamicSQL nvarchar(1000);

	set @table_name = '#tb_'+@team+'_'+@city;

	declare @DynamicSQL2 nvarchar(1000);
	set @DynamicSQL2 = N' select d.id as "developer_id",p.id as "project_id",null as "work_type",null as "success" into '+ @table_name + ' from developer as d  join project as p  ON d.team = p.team 
	join team as t ON d.team = t.id where t.team_name = ''' + @team + ''' and p.city = '''+ @city + ''';
	select * from ' + @table_name

	if OBJECT_ID('tempdb..'+@table_name) IS NULL EXEC( @DynamicSQL2);

end;


go
create procedure pr_drop_ved
	@team NVARCHAR(50)
as
begin

	declare @sql nvarchar(max)
	select @sql = isnull(@sql+';', '') + 'drop table ' + quotename(name)
	from tempdb..sysobjects
	where name like '#tb_' + @team + '_%'
	exec (@sql)

end;


exec pr_create_ved @team = 'logistics_team', @city='tyumen'

exec pr_drop_ved @team = 'logistics_team'




declare @team_name nvarchar(500);

declare cur CURSOR LOCAL for
    select team_name from team;

open cur

fetch next from cur into @team_name

while @@FETCH_STATUS = 0 BEGIN

    --execute your sproc on each row
    exec pr_create_ved @team = @team_name, @city='tyumen'

    fetch next from cur into @team_name
END

close cur
deallocate cur


create function top_developers (@city nvarchar(500))
returns table
as 
return
(
	select top(5) d.full_name, count(*) as 'total' from developer as d join project as p on d.team = p.team where city = @city group by d.full_name 
)

SELECT * FROM top_developers ('tyumen');

create view DeveloperProjectTown
WITH SCHEMABINDING
as
select d.full_name,p.project_name,t.team_name,p.city as ddd from dbo.developer as d join dbo.project as p on p.team = d.team join dbo.team as t on t.id = d.team;


CREATE UNIQUE CLUSTERED INDEX
    ix_d_full_name_d_project_name ON DeveloperProjectTown ( ddd, full_name);


EXEC sp_spaceused 'DeveloperProjectTown';


SELECT view_name, Table_Name
FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE
WHERE View_Name = 'DeveloperProjectTown'
ORDER BY view_name, table_name

UPDATE DeveloperProjectTown
SET full_name = 'denis20110203'
WHERE full_name = 'Denis'   


select * from DeveloperProjectTown