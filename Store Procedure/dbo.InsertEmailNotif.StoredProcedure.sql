USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[InsertEmailNotif]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--begin tran 
--rollback
--exec [dbo].[InsertEmailNotif]
--select * from TblEmailNotification where branch = 'makasar'
CREATE PROCEDURE [dbo].[InsertEmailNotif]
AS
BEGIN
	Declare @EmailPeriod int, @lastNotif int, @createemail int, @fromNotif int, @todate int
	Declare @AreaID int, @BranchID int, @BranchDesc nvarchar(50), @Supervisor nvarchar(100), @PicArea nvarchar(100), @Auditor nvarchar(100)
	declare @date2 int; set @date2 = day(GETDATE())
	select @EmailPeriod = ResultVal, @todate = ToVal from Setting where TypeConfig = 'AuditPeriodSchedule'
	and @date2 between fromval and toval

	select @fromNotif = FromVal, @lastNotif = ToVal from Setting
	where TypeConfig = 'EmailNotif' and ResultVal = @EmailPeriod
	--and (day(GETDATE() - 10) = FromVal or day(GETDATE() - 10) = ToVal)

	select @EmailPeriod, @lastNotif,@fromNotif, @todate, @date2 thisdate, 
				iif(@date2 = @fromNotif,
					 '1',
					 Iif(@date2 >= @lastnotif and @date2 <= @todate,
						 '2',
						 '0'))

	select * from Setting where TypeConfig = 'AuditPeriodSchedule' and ResultVal = @EmailPeriod and ToVal >= @date2
	IF @EmailPeriod = 2
		BEGIN
			DECLARE Email2_cursor CURSOR FOR
			Select a.AreaID, a.ID, a.BranchDesc, a.PICBranch, a.PICArea, vmu.Username from 
					( select b.AreaID, b.ID, b.BranchDesc, b.PICBranch, ma.PICArea, sa.[Status], sa.AuditPeriod, Replace(sa.dateaudit,'-','') DateAudit from 
						(select * from MasterBranch) b
						join MasterArea ma on b.AreaID = ma.ID
						left join ScoreAudit sa on b.ID = sa.branch
					) a left join vEmployeeMaster em on a.PICBranch = em.Employee_xupj
					left join [dbo].[vMasterUserEmail] vmu on vmu.branch = a.ID
					where (dateaudit = LEFT(CONVERT(varchar, getdate(),112),6) or dateaudit is null) --'201901'
						and ([status] <> 'Submit' or [status] is null)
						and (AuditPeriod = 2 or AuditPeriod is null)
		
				OPEN Email2_cursor
				FETCH NEXT FROM Email2_cursor
				INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor

				WHILE @@FETCH_STATUS = 0
				BEGIN	
					  INSERT INTO [dbo].[TblEmailNotification]
						   ([To] ,[CC] ,[Branch] ,[Auditor] ,[PeriodAudit] ,[Notifperiod], [IsDelete], [AlreadySending]
						   ,[CreatedOn] ,[CreatedBy])
					  VALUES(@Auditor, @Supervisor, @BranchDesc, @Auditor, @EmailPeriod, DATEADD(month, DATEDIFF(month, 0, getdate()), @todate), 0, 0, Getdate(), 1)
				FETCH NEXT FROM Email2_cursor
					INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor
				END
			CLOSE Email2_cursor
			DEALLOCATE Email2_cursor;
		END
	ELSE IF @EmailPeriod = 1
		BEGIN
			DECLARE Email1_cursor CURSOR FOR
			Select a.AreaID, a.ID, a.BranchDesc, a.PICBranch, a.PICArea, vmu.Username from 
					( select b.AreaID, b.ID, b.BranchDesc, b.PICBranch, ma.PICArea, sa.[Status], sa.AuditPeriod, Replace(sa.dateaudit,'-','') DateAudit from 
						(select * from MasterBranch) b
						join MasterArea ma on b.AreaID = ma.ID
						left join ScoreAudit sa on b.ID = sa.branch
					) a left join vEmployeeMaster em on a.PICBranch = em.Employee_xupj
					left join [dbo].[vMasterUserEmail] vmu on vmu.branch = a.ID
					where (dateaudit = LEFT(CONVERT(varchar, getdate(),112),6) or dateaudit is null) --'201901'
						and ([status] <> 'Submit' or [status] is null)
						and (AuditPeriod = 1 or AuditPeriod is null)
		
				OPEN Email1_cursor
				FETCH NEXT FROM Email1_cursor
				INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor

				WHILE @@FETCH_STATUS = 0
				BEGIN	
					  INSERT INTO [dbo].[TblEmailNotification]
						   ([To] ,[CC] ,[Branch] ,[Auditor] ,[PeriodAudit] ,[Notifperiod], [IsDelete], [AlreadySending]
						   ,[CreatedOn] ,[CreatedBy])
					  VALUES(@Auditor, @Supervisor, @BranchDesc, @Auditor, @EmailPeriod, DATEADD(month, DATEDIFF(month, 0, getdate()), @todate), 0, 0, GETDATE(), 1)
				FETCH NEXT FROM Email1_cursor
					INTO @AreaID, @BranchID, @BranchDesc, @Supervisor, @PicArea, @Auditor
				END

			CLOSE Email1_cursor
			DEALLOCATE Email1_cursor;
		END
	ELSE
		BEGIN
			select 'tidak ada email'
		END
END
GO
