USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_send_email_for_ckb]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_send_email_for_ckb](
                @subject nvarchar(max),
                @to nvarchar(max),
                @content nvarchar(max)
)
AS
BEGIN
                SET NOCOUNT ON
                
                EXEC msdb.dbo.sp_send_dbmail 
                                @recipients = @to,
                                @copy_recipients = 'ict.bpm@trakindo.co.id',
                                @subject = @subject,
                                @body = @content,
                                @body_format = 'HTML',
                                @profile_name = 'EMCS';

                insert into dbo.Test_Email_Log ([To], Content, [Subject], CreateDate) values (@to, @Content, @subject, GETDATE());

END
GO
