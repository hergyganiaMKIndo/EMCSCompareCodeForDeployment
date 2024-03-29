USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_proccess_template]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_proccess_template]
(
	@requestType nvarchar(100) = 'CIPL',
	@requestId nvarchar(100) = '',
	@template nvarchar(max) = ''
)
AS
BEGIN
	------------------------------------------------------------------
	-- 1. Melakukan Declare semua variable yang dibutuhkan
	------------------------------------------------------------------
	BEGIN
		-- ini hanya sample silahkan comment jika akan digunakan
		SET @template = 'Ini adalah email dari [requestor_name], dan ini adalah email untuk [last_pic_name]. selanjutnya akan dikirim ke [next_pic_name]';
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
			@bl_awb_number NVARCHAR(MAX) = ''
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
					@requestor_username = t1.AD_User,
					@last_pic_id = t2.Employee_ID,
					@last_pic_name = t2.Employee_Name,
					@last_pic_username = t2.AD_User,
					@next_pic_id = t3.Employee_ID,
					@next_pic_name = t3.Employee_Name,
					@next_pic_username = t3.AD_User,
					@req_number = t4.CiplNo
				FROM 
					dbo.fn_get_cipl_request_list_all() t0 
					INNER JOIN dbo.Cipl t4 on t4.id = t0.IdCipl
					INNER JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t1.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t1.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
			END

			IF (@requestType IN ('CL', 'BLAWB', 'PEB_NPE'))
			BEGIN
				SET @flow = @requestType;
				SELECT 
					@requestor_id = t5.Employee_ID,
					@requestor_name = t5.Employee_Name,
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
					@bl_awb_number = t4.Number
				FROM 
					dbo.fn_get_cl_request_list_all() t0 
					INNER JOIN dbo.Cargo t1 on t1.id = t0.IdCl
					INNER JOIN dbo.ShippingInstruction t2 on t2.IdCL = t0.IdCl
					INNER JOIN dbo.NpePeb t3 on t3.IdCL = t0.IdCl
					INNER JOIN dbo.BlAwb t4 on t4.IdCL = t0.IdCl
					INNER JOIN dbo.fn_get_employee_internal_ckb() t5 on t5.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t6 on t6.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t7 on t7.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
				SELECT * FROM dbo.fn_get_cl_request_list_all() t0 where t0.Id = @requestId;
			END

			IF (@requestType = 'RG')
			BEGIN
				SET @flow = 'Receive Goods';
				SELECT 
					@requestor_id = t1.Employee_ID,
					@requestor_name = t1.Employee_Name,
					@requestor_username = t1.AD_User,
					@last_pic_id = t2.Employee_ID,
					@last_pic_name = t2.Employee_Name,
					@last_pic_username = t2.AD_User,
					@next_pic_id = t3.Employee_ID,
					@next_pic_name = t3.Employee_Name,
					@next_pic_username = t3.AD_User,
					@req_number = t4.GrNo
				FROM 
					dbo.fn_get_gr_request_list_all() t0 
					INNER JOIN dbo.GoodsReceive t4 on t4.id = t0.IdGr
					INNER JOIN dbo.fn_get_employee_internal_ckb() t1 on t1.AD_User = t0.CreateBy
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t2 on t1.AD_User = t0.Pic
					LEFT JOIN dbo.fn_get_employee_internal_ckb() t3 on t1.AD_User = t0.NextAssignTo
				WHERE 
					t0.Id = @requestId;
			END

			IF (@requestType = 'DELEGATION')
			BEGIN
				SET @flow = 'Delegation';
				SELECT * FROM dbo.fn_get_gr_request_list_all() t0 where t0.Id = @requestId;
			END

			INSERT 
				INTO 
					@variable_table 
				VALUES 
					('[flow]', @flow)
					,('[requestor_name]', @requestor_name)
					,('[requestor_id]', @requestor_id)
					,('[last_pic_name]', @last_pic_name)
					,('[last_pic_id]', @last_pic_id)
					,('[next_pic_name]', @next_pic_name)
					,('[next_pic_id]', @next_pic_id)
					,('[si_number]', @si_number)
					,('[ss_number]', @ss_number)
					,('[req_number]', @req_number)
					,('[npe_number]', @npe_number)
					,('[peb_number]', @peb_number)
					,('[bl_awb_number]', @bl_awb_number)
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
		SELECT @template AS result;
	END
END
GO
