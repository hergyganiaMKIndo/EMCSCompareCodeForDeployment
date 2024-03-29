USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_proccess_email_20210218]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- sp_proccess_email 10, 'CIPL'
CREATE PROCEDURE [dbo].[sp_proccess_email_20210218](
                @RequestID bigint,
                @TypeFlow nvarchar(100)
)
AS
BEGIN
                --DECLARE @RequestID bigint = 6
                DECLARE 
                @IdFlow bigint,
                @IdStep bigint,
                @Status nvarchar(100),
                @SendType nvarchar(100),
                @SendTo nvarchar(100),
                @Name nvarchar(100),
                @Subject nvarchar(max), 
                @Template nvarchar(max),
                @Requestor nvarchar(max),
                @NextPic nvarchar(max),
                @LastPic nvarchar(max),
                @NextAssignType nvarchar(max),
				@TypeDoc nvarchar(max)

                IF @TypeFlow = 'CIPL'
                BEGIN
                                
                                DECLARE csr CURSOR 
                FOR 
                                --DECLARE @RequestID bigint = 6;
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.Status, t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic 
                                FROM fn_get_cipl_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                WHERE t0.IdCipl = @RequestID
                                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @subject, @TypeDoc)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @Template, @TypeDoc)
                                                
                                                IF(@IdStep IN (10) AND @Status = 'Approve')
                                                BEGIN
                                                                DECLARE @CKB_TEAM nvarchar(max) = 'ict.bpm@trakindo.co.id'
                                                                                , @TemplateCKB nvarchar(max) = ''
                                                                                , @EmailSubject nvarchar(max) = ''
                                                                                , @EmailMessage nvarchar(max); 

                                                                SELECT @EmailSubject = E.Subject, @EmailMessage = E.Message, @TypeDoc = E.RecipientType FROM EmailTemplate E WHERE RecipientType = 'CKB'
                                                                
                                                                SELECT @EmailSubject= dbo.[fn_proccess_email_template]('CIPL', @RequestID, @EmailSubject, @TypeDoc)
   SELECT @EmailMessage = dbo.[fn_proccess_email_template]('CIPL', @RequestID, @EmailMessage, @TypeDoc)

                                                                SELECT @CKB_TEAM = CF.Email FROM CiplForwader CF WHERE IdCipl = @RequestID
                                                    exec [dbo].[sp_send_email_for_single] @EmailSubject, '', @EmailMessage, @CKB_TEAM                                                                
                                                                
                                                                --exec sp_send_email_for_ckb @EmailSubject, @CKB_TEAM, @EmailMessage
                                                END

                                                -- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END

                                                                IF (@SendType = 'LastApprover')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END
                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                                                END
                                                                                ELSE
                                                                                BEGIN
                                                                                                IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                                SET @NextPic = @LastPic;
                                                                                                END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                                                
                   END
                                                                END       
                                                END
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END

                IF @TypeFlow = 'CL'
                BEGIN
                
                DECLARE csr CURSOR 
            FOR 
                                --DECLARE @RequestID bigint = 6;
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.Status, t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic, t0.AssignmentType
                                FROM fn_get_cl_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                --WHERE t0.IdCl = 973
                                WHERE t0.IdCl = @RequestID
                                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('CL', @RequestID, @subject, @TypeDoc)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('CL', @RequestID, @Template, @TypeDoc)

                                                -- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                                                END
                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                        END
                                                                                ELSE
                                                                                BEGIN
                                                                                   IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                                SET @NextPic = @LastPic;
                                                                      END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                                                
                                                                                END
                                                                END
                
                                                END
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END

                IF @TypeFlow = 'RG'
                BEGIN
                
                DECLARE csr CURSOR 
                FOR 
                                SELECT 
                                                t0.IdFlow, t0.IdStep, t0.[Status], t1.SendType, t1.SendTo, t1.Name, t1.Subject, t1.Template,
                                                t0.CreateBy, t0.NextAssignTo, t0.Pic, t0.NextAssignType 
                                FROM fn_get_gr_request_list_all() t0
                                LEFT JOIN NotifikasiEmail t1 on t1.IdFlow = t0.idFlow and t1.idStep = t0.idStep and t1.Status like '%' + t0.Status + '%'
                                WHERE t0.IdGr = @RequestID
                                
                                OPEN csr
                                                FETCH NEXT FROM csr
                                                INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                
                                                WHILE @@FETCH_STATUS = 0
                                                BEGIN

                                                SELECT @subject = dbo.[fn_proccess_email_template]('RG', @RequestID, @subject, @TypeDoc)
                                                SELECT @Template = dbo.[fn_proccess_email_template]('RG', @RequestID, @Template, @TypeDoc)

                                                ---- Send email
                                                IF (@SendType = 'Group')
                                                BEGIN
                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                END
                                                ELSE
                                                BEGIN
                                                                IF (@SendType = 'Requestor')
                                                                BEGIN                                                   
                                                                                exec sp_send_email_for_single @subject, @Requestor, @Template
                                                                END
                
                                                                IF (@SendType = 'Thankyou')
                                          BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                    END

                                                                IF (@SendType = 'LastApprover')
                                                                BEGIN
                                                                                exec sp_send_email_for_single @subject, @LastPic, @Template
                                  END
                                                                                                
                                                                IF (@SendType = 'NextApprover')
                                                                BEGIN
                                                                                IF (@NextAssignType = 'Group')
                                                                                BEGIN
                                                                                                exec sp_send_email_for_group @subject, @SendTo, @Template
                                                                                END
                                                                                ELSE
                                                                                BEGIN
                                                                                                IF(@NextPic IS NULL)
                                                                                                BEGIN
                                                                                                                SET @NextPic = @LastPic;
                                                                                                END
                                                                                                exec sp_send_email_for_single @subject, @NextPic, @Template
                                                                
                                                                                END
                                                                END       
                                                END
                                                                                                                                                
                                                FETCH NEXT FROM csr INTO @IdFlow, @IdStep, @Status, @SendType, @SendTo, @Name, @Subject, @Template, @Requestor, @NextPic, @LastPic, @NextAssignType
                                END
                                CLOSE csr
                                DEALLOCATE csr
                END
END

GO
