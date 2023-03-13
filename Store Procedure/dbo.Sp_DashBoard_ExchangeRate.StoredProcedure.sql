USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[Sp_DashBoard_ExchangeRate]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Sp_DashBoard_ExchangeRate] -- exec Sp_DashBoard_ExchangeRate '2020-03-17','2020-03-23'  
(  
@date1 Date,  
@date2 Date  
)  
as  
begin  
select * from masterkurs   
where StartDate <= @date1 AND EndDate >= @date2
order by StartDate Desc  
end


GO
