USE [EMCS]
GO
/****** Object:  StoredProcedure [dbo].[sp_CiplItemChange]    Script Date: 10/03/2023 11:40:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[sp_CiplItemChange]
(
@Id nvarchar(50),
@IdCipl nvarchar(50),
@Status nvarchar(50),
@CreateDate nvarchar(50)
)
as 
begin
if @Status = 'Created'
begin
	INSERT INTO [dbo].[CiplItem]([IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]
		   ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber])
   select [IdCipl],[IdReference],[ReferenceNo],[IdCustomer],[Name],[Uom],[PartNumber],[Sn],[JCode],[Ccr],[CaseNumber],[Type],[IdNo],[YearMade],[Quantity]
           ,[UnitPrice],[ExtendedValue],[Length],[Width],[Height],[Volume],[GrossWeight],[NetWeight],[Currency],[CoO],[CreateBy],[CreateDate],[UpdateBy],[UpdateDate],[IsDelete]
		   ,[IdParent],[SIBNumber],[WONumber],[Claim],[ASNNumber] from CiplItem_Change where Id = @id and CreateDate = @CreateDate  
		   delete From CiplItem_Change where Id = @id and CreateDate = @CreateDate  and IdCipl = @IdCipl

end
else if @Status = 'Updated'
begin
Update CiplItem
set [IdCipl]	= (select [IdCipl] from CiplItem_Change where Id = @Id and IdCipl = @IdCipl),
[IdReference]	= (select  [IdReference] from CiplItem_Change where Id = @Id and IdCipl = @IdCipl),
[ReferenceNo]	= (select [ReferenceNo]  from CiplItem_Change where Id = @Id and IdCipl = @IdCipl),
[IdCustomer]	= (select [IdCustomer]  from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Name]			= (select  [Name] from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Uom]			= (select [Uom]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[PartNumber]	= (select [PartNumber]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Sn]			= (select [Sn]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[JCode]			= (select [JCode]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Ccr]			= (select [Ccr]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[CaseNumber]	= (select [CaseNumber]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Type]			= (select [Type]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[IdNo]			= (select [IdNo]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[YearMade]		= (select [YearMade]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Quantity]		= (select [Quantity]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[UnitPrice]		= (select [UnitPrice]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[ExtendedValue]	= (select [ExtendedValue]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Length]		= (select [Length]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Width]			= (select [Width]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Height]		= (select [Height]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Volume]		= (select [Volume]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[GrossWeight]	= (select [GrossWeight]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[NetWeight]		= (select [NetWeight]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Currency]		= (select [Currency]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[CoO]			= (select [CoO]			from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[CreateBy]		= (select [CreateBy]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[CreateDate]	= (select [CreateDate]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[UpdateBy]		= (select [UpdateBy]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[UpdateDate]	= (select [UpdateDate]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[IsDelete]		= (select [IsDelete]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[IdParent]		= (select [IdParent]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[SIBNumber]		= (select [SIBNumber]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[WONumber]		= (select [WONumber]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[Claim]			= (select [Claim]		from CiplItem_Change where Id = @Id and Idcipl = @IdCipl),
[ASNNumber]		= (select [ASNNumber]	from CiplItem_Change where Id = @Id and Idcipl = @IdCipl)
where Id = @Id and IdCipl = @IdCipl
delete From CiplItem_Change where Id = @id   and IdCipl = @IdCipl
end
else
begin
 
update CiplItem
set [IsDelete]	= (select [IsDelete] from CiplItem_Change where Id = @Id and Idcipl = @IdCipl)
where Id = (select IdCiplItem from CiplItem_Change where Id = @Id) and IdCipl = @IdCipl
delete From CiplItem_Change where Id = @id and IdCipl = @IdCipl
end



end
GO
