USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_send_email_for_single]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_send_email_for_single](          
                @subject nvarchar(max),          
                @to nvarchar(max),          
                @content nvarchar(max),          
    @Email nvarchar(max) = ''          
)          
AS          
BEGIN          
                SET NOCOUNT ON          
          
                -- Send Email to User Here          
                IF (@to <> '' AND @Email = '')          
    BEGIN          
     SELECT @Email = Email           
     FROM dbo.fn_get_employee_internal_ckb()           
     WHERE AD_User = @to;          
    END          
                          
                EXEC msdb.dbo.sp_send_dbmail           
                                @recipients = 'ict.bpm02@trakindo.co.id', @copy_recipients = 'projectsupport@mkindo.com',          
                                @subject = @subject,          
                                @body = @content,          
                                @body_format = 'HTML',          
                                @profile_name = 'EMCS';          
          
                insert into dbo.Test_Email_Log ([To], Content, [Subject], CreateDate) values (@Email, @Content, @subject, GETDATE());          
          
END
GO
