USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_sendmailnotification]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: EMCS
-- Create date	: 23 Jan 2019
-- Description	: SP Untuk mengirimkan Email
-- =============================================
-- exec [dbo].[SP_SendMailNotification]
CREATE PROCEDURE [dbo].[sp_sendmailnotification]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @id bigint, @to nvarchar(max), @cc nvarchar(max), @auditor nvarchar(max), @periodaudit nvarchar(max), @branch nvarchar(max), @notifperiod datetime;
	DECLARE @body nvarchar(max), @subject nvarchar(max)
	SET NOCOUNT ON;
	
	DECLARE db_cursor CURSOR FOR 
    
	-- Insert statements for procedure here
	SELECT ID, [To], [CC], [Branch], [Auditor], iif([PeriodAudit] = 2, 'Final Audit', 'First Audit') PeriodAudit, [Notifperiod] FROM dbo.TblEmailNotification
	WHERE AlreadySending = 0

	--select @body = TemplateEmail from Setting where TypeConfig = 'TemplateEmail'

	-- Declare Cursor to Looping the PIP data

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @id, @to, @cc, @branch, @auditor, @periodaudit, @notifperiod

	WHILE @@FETCH_STATUS = 0
	BEGIN 
	
		BEGIN TRY
			select 
				@body = REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
												TemplateEmail,
												'{Auditor}',@auditor),
											'{PeriodAudit}',@periodaudit),
										 '{Branch}',@branch),
									'{NotifPeriod}',day(@notifperiod)),
								'{Link}','<a href="http://pis.trakindo.co.id/"> Contamination Control Portal </a>')
			from Setting where TypeConfig = 'TemplateEmail'
			
			select @subject = REPLACE(REPLACE(templateemail,'{Branch}',@branch),'{PeriodAudit}',@periodaudit) from Setting where TypeConfig = 'SubjectEmail'
			
			EXEC msdb.dbo.sp_send_dbmail  
			    @profile_name = 'CCPMail',  
			    @recipients = @to,  
			    @body = @body,  
			    @subject = @subject,
				@body_format = 'HTML';  

			UPDATE [dbo].[tblEmailNotification] SET AlreadySending = 1, UpdatedBy = 1, UpdatedOn = GETDATE() WHERE ID = @id;
		END TRY
		BEGIN CATCH
			--select @id;
			SELECT  
    ERROR_NUMBER() AS ErrorNumber  
    ,ERROR_SEVERITY() AS ErrorSeverity  
    ,ERROR_STATE() AS ErrorState  
    ,ERROR_PROCEDURE() AS ErrorProcedure  
    ,ERROR_LINE() AS ErrorLine  
    ,ERROR_MESSAGE() AS ErrorMessage;  
		END CATCH

		FETCH NEXT FROM db_cursor INTO @id, @to, @cc, @branch, @auditor, @periodaudit, @notifperiod
	END	  
	CLOSE db_cursor
	DEALLOCATE db_cursor	
END
GO
