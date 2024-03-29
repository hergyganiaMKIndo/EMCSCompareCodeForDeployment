USE [EMCS]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_proccess_email_template_20210218]    Script Date: 10/03/2023 11:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:                            Ali Mutasal
-- ALTER date: 09 Des 2019
-- Description:    Function untuk melakukan proses email
-- =============================================
CREATE FUNCTION [dbo].[fn_proccess_email_template_20210218]
(
                -- Add the parameters for the function here
                @requestType nvarchar(100) = 'CIPL',
                @requestId nvarchar(100) = '',
                @template nvarchar(max) = '',
				@typeDoc nvarchar(max) = ''
)
RETURNS nvarchar(max)
AS
BEGIN
                ------------------------------------------------------------------
                -- 1. Melakukan Declare semua variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
                                -- ini hanya sample silahkan comment jika akan digunakan
                                --SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';
                                DECLARE @variable_table TABLE (
                                    key_data VARCHAR(MAX) NULL,
                                    val_data VARCHAR(MAX) NULL
                                );

                                DECLARE 
                                                @key NVARCHAR(MAX), 
                                                @flow NVARCHAR(MAX), 
                                                @val NVARCHAR(MAX),
                                                @requestor_name NVARCHAR(MAX),
                                                @requestor_id NVARCHAR(MAX),
                                                @requestor_username NVARCHAR(MAX),
                                                @last_pic_name NVARCHAR(MAX),
                                                @last_pic_id NVARCHAR(MAX),
                                                @last_pic_username NVARCHAR(MAX),
                                                @next_pic_name NVARCHAR(MAX),
                                                @next_pic_id NVARCHAR(MAX),
                                                @next_pic_username NVARCHAR(MAX),
                                                @si_number NVARCHAR(MAX) = '',
                                                @ss_number NVARCHAR(MAX) = '',
                                                @req_number NVARCHAR(MAX) = '',
                                                @npe_number NVARCHAR(MAX) = '',
                                                @peb_number NVARCHAR(MAX) = '',
                                                @bl_awb_number NVARCHAR(MAX) = '',
                                                @req_date NVARCHAR(MAX) = '',
                                                @superior_req_name nvarchar(max) = '',
                                                @superior_req_id nvarchar(max) = ''
                END
                
                ------------------------------------------------------------------
                -- 2. Query untuk mengisi data ke variable variable yang dibutuhkan
                ------------------------------------------------------------------
                BEGIN
                                -- Mengambil data dari fn request per flow
                                BEGIN
                                                IF (@requestType = 'CIPL')
                                                BEGIN
                                                                SET @flow = 'CIPL';
                   SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
																				@superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                                @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = 
                                                                                                CASE
                                                                                                                WHEN t0.Status = 'Revise' OR t0.Status = 'Reject' OR (t0.Status = 'Approve' AND t0.NextAssignType IS NULL) THEN t5.Employee_Name
                                                                                                                WHEN t0.NextAssignType = 'Group' THEN t0.NextAssignTo
                                                                                                                ELSE t3.Employee_Name
                                                                                                END,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = IIF(@typeDoc = 'CKB', ISNULL(t4.EdoNo,''), t4.CiplNo),
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cipl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.UpdateBy
                                                                WHERE 
                                                                                t0.IdCipl = @requestId;
                                                END

                                                --IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))
												IF (@requestType = 'CL') OR (@requestType = 'BLAWB') OR (@requestType = 'PEB_NPE') 
                                                BEGIN
                                                                SET @flow = @requestType;
                                                                SELECT 
                                                                                @requestor_id = t5.Employee_ID,
                                                                                @requestor_name = t5.Employee_Name,
                                                                                @superior_req_name = t5.Superior_Name,
                                                                       @superior_req_id = t5.Superior_ID,
                                                                                @requestor_username = t5.AD_User,
                                                                                @last_pic_id = t6.Employee_ID,
                                                                                @last_pic_name = t6.Employee_Name,
                                                                                @last_pic_username = t6.AD_User,
                                                                                @next_pic_id = t7.Employee_ID,
                                                                                @next_pic_name = t7.Employee_Name,
                                                                                @next_pic_username = t7.AD_User,
                                                                                @req_number = t1.ClNo,
                                                                                @ss_number = t1.SsNo,
                                                                                @si_number = t2.SlNo,
                                                                                @npe_number = t3.NpeNumber,
                                                                                @peb_number = t3.PebNumber,
                                                                                @bl_awb_number = t4.Number,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_cl_request_list_all() t0 
                                                                                INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl
                                                                                INNER JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl
                                                                                INNER JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdCl = @requestId;                                                                     
                                                END

                                                IF (@requestType = 'RG')
                                                BEGIN
                                                                SET @flow = 'Receive Goods';
                                                                SELECT 
                                                                                @requestor_id = t1.Employee_ID,
                                                                                @requestor_name = t1.Employee_Name,
                                                                                @superior_req_name = t1.Superior_Name,
                                                                                @superior_req_id = t1.Superior_ID,
                                                                          @requestor_username = t1.AD_User,
                                                                                @last_pic_id = t2.Employee_ID,
                                                                                @last_pic_name = t2.Employee_Name,
                                                                                @last_pic_username = t2.AD_User,
                                                                                @next_pic_id = t3.Employee_ID,
                                                                                @next_pic_name = t3.Employee_Name,
                                                                                @next_pic_username = t3.AD_User,
                                                                                @req_number = t4.GrNo,
                                                                                @req_date = RIGHT('0' + DATENAME(DAY, t0.CreateDate), 2) + ' ' + DATENAME(MONTH, t0.CreateDate)+ ' ' + DATENAME(YEAR, t0.CreateDate)
                                                                FROM 
                                                                                dbo.fn_get_gr_request_list_all() t0 
                                                                                INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t2.AD_User = t0.Pic
                                                                                LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t3.AD_User = t0.NextAssignTo
                                                                WHERE 
                                                                                t0.IdGr = @requestId;
                                                END

                                                IF (@requestType = 'DELEGATION')
                                                BEGIN
                                                                SET @flow = 'Delegation';
                                                                --SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;
                                                END

                                                INSERT 
                                                                INTO 
                                                                                @variable_table 
                                                                VALUES 
                                                                                 ('@RequestorName', ISNULL(@requestor_name, '-'))
                                                                                ,('@RequestNo', ISNULL(@req_number, '-'))
                                                                                ,('@CreatedDate', ISNULL(@req_date, '-'))
                                                                                ,('@SuperiorEmpID', ISNULL(@superior_req_id, '-'))
                                                                                ,('@SuperiorName', ISNULL(@superior_req_name, '-'))
                                                                                ,('@MobileLink', 'http://pis.trakindo.co.id')
                                                                                ,('@DesktopLink', 'http://pis.trakindo.co.id')
                                                                                ,('@ApproverPosition', ISNULL(@flow, '-'))
                                                                                ,('@ApproverName', ISNULL(@next_pic_name, '-'))
                                                                                ,('@RequestorEmpID', ISNULL(@requestor_id, '-'))
                                                                                ,('@flow', ISNULL(@flow, '-'))
                                                                                ,('@requestor_name', ISNULL(@requestor_name, '-'))
                                                                                ,('@requestor_id', ISNULL(@requestor_id, '-'))
                                                                                ,('@last_pic_name', ISNULL(@last_pic_name, '-'))
                                                                                ,('@last_pic_id', ISNULL(@last_pic_id, '-'))
                                                                                ,('@next_pic_name', ISNULL(@next_pic_name, '-'))
                                                                                ,('@next_pic_id', ISNULL(@next_pic_id, '-'))
                                                                                ,('@si_number', ISNULL(@si_number, '-'))
                                                                                ,('@ss_number', ISNULL(@ss_number, '-'))
                                                                                ,('@req_number', ISNULL(@req_number, '-'))
                                                                                ,('@npe_number', ISNULL(@npe_number, '-'))
                                                                                ,('@peb_number', ISNULL(@peb_number, '-'))
                                                                                ,('@bl_awb_number', ISNULL(@bl_awb_number, '-'))
                                                                                ,('@req_date', ISNULL(@req_date, '-'))
                                                                                ,('@superior_req_name', ISNULL(@superior_req_name, '-'))
                                                                                ,('@superior_req_id', ISNULL(@superior_req_id, '-'))
                                END
                END
                
                ------------------------------------------------------------------
                -- 3. Melakukan Replace terhadap data yang di petakan di template dgn menggunakan perulangan
                ------------------------------------------------------------------
                BEGIN
                                DECLARE cursor_variable CURSOR
                                FOR 
                                                SELECT 
                                                                key_data, 
                                                                val_data 
                                                FROM 
                                                                @variable_table;
                                                                                                
                                OPEN cursor_variable; 
                                FETCH NEXT FROM cursor_variable INTO @key, @val; 
                                WHILE @@FETCH_STATUS = 0
                                    BEGIN
                                                                -- Melakukan Replace terhadap variable di template dengan value dari hasil pencarian data diata.
                                                                IF ISNULL(@key, '') <> ''
                                                                BEGIN
                                                                                SET @template = REPLACE(@template, @key, @val);
                                                                END

                                                                FETCH NEXT FROM cursor_variable INTO 
                                            @key, 
                                           @val;
                                    END;
                                
                                CLOSE cursor_variable; 
                                DEALLOCATE cursor_variable;
                END
                
                ------------------------------------------------------------------
                -- 4. Menampilkan hasil dari proses replace
                ------------------------------------------------------------------
                BEGIN
                                RETURN @template;
                END
END
GO
