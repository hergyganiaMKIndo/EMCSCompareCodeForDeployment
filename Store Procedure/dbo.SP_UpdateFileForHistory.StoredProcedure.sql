USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateFileForHistory]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[SP_UpdateFileForHistory]
(
@IdShippingFleet bigint,
@FileName nvarchar(max) = ''
)
as
begin
declare @Id  bigint 
insert  into ShippingFleetDocumentHistory(IdShippingFleet,FileName,CreateDate)
values (@IdShippingFleet,@FileName,GETDATE())
set @Id = SCOPE_IDENTITY()
select @Id As Id
end

GO
