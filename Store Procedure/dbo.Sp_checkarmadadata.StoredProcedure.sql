USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[Sp_checkarmadadata]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Sp_checkarmadadata] --'40946'
(
@Id nvarchar(max)
)
as
begin

select Count(*) from CiplItem where IdCipl In (select distinct IdCipl from ShippingFleetItem where IdGr = @Id)
end
GO
