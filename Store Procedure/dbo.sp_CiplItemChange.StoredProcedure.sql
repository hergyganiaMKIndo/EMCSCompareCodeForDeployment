USE [EMCS_Dev]
GO
/****** Object:  StoredProcedure [dbo].[sp_CiplItemChange]    Script Date: 10/03/2023 15:51:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_CiplItemChange]  
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

declare @IdReference nvarchar(max)
declare @ReferenceNo   nvarchar(max)
declare @IdCustomer    nvarchar(max)
declare @Name          nvarchar(max)
declare @Uom			  nvarchar(max)
declare @PartNumber	  nvarchar(max)
declare @Sn			  nvarchar(max)
declare @JCode		  nvarchar(max)
declare @Ccr			  nvarchar(max)
declare @CaseNumber	  nvarchar(max)
declare @Type		  nvarchar(max)
declare @IdNo		  nvarchar(max)
declare @YearMade	  nvarchar(max)
declare @Quantity	  int
declare @UnitPrice	  decimal(20,2)
declare @ExtendedValue decimal(20,2)
declare @Length		  decimal(20,2)
declare @Width		  decimal(20,2)
declare @Height		  decimal(20,2)
declare @Volume		  decimal(18,6)
declare @GrossWeight	  decimal(18,3)
declare @NetWeight	  decimal(18,3)
declare @Currency	  nvarchar(3)
declare @CoO		 	  nvarchar(max)
declare @CreateBy 	  nvarchar(max)
declare @UpdateBy 	  nvarchar(max)
declare @UpdateDate	  datetime
declare @IsDelete	  bit
declare @IdParent	  bigint
declare @SIBNumber	  nvarchar(max)
declare @WONumber	  nvarchar(max)
declare @Claim 		  nvarchar(max)
declare @ASNNumber	  nvarchar(max)
declare @IdCiplItem INT
select 
 @IdCiplItem = IdCiplItem,
 @IdReference = IdReference,
 @ReferenceNo  	= ReferenceNo, 
 @IdCustomer   	= IdCustomer , 
 @Name         	= Name       , 
 @Uom			= Uom		,
 @PartNumber	= PartNumber,
 @Sn			= Sn		,
 @JCode		 	= JCode		 ,
 @Ccr			= Ccr		,
 @CaseNumber	= CaseNumber,
 @Type		 	= Type		 ,
 @IdNo		 	= IdNo		 ,
 @YearMade	 	= YearMade	 ,
 @Quantity	 	= Quantity	 ,
 @UnitPrice	 	= UnitPrice	 ,
 @ExtendedValue	= ExtendedValue,
 @Length		= Length,
 @Width			= Width	,
 @Height		= Height,		
 @Volume		= Volume,		
 @GrossWeight	= GrossWeight,
 @NetWeight	 	= NetWeight	, 
 @Currency	 	= Currency,	 
 @CoO		 	= CoO,		 
 @CreateBy 		= CreateBy, 
 @CreateDate	= CreateDate,	
 @UpdateBy 		= UpdateBy, 
 @UpdateDate	= UpdateDate,	
 @IsDelete	 	= IsDelete,	 
 @IdParent	 	= IdParent,	 
 @SIBNumber	 	= SIBNumber,	 
 @WONumber	 	= WONumber,	 
 @Claim 		= Claim, 
 @ASNNumber	 	= ASNNumber 
 from CiplItem_Change where Id = @Id and IdCipl = @IdCipl

 Update CiplItem
set [IdCipl]	= @IdCipl,
[IdReference]	= @IdReference   ,
[ReferenceNo]	= @ReferenceNo   ,
[IdCustomer]	= @IdCustomer    ,
[Name]			= @Name         ,
[Uom]			= @Uom			  ,
[PartNumber]	= @PartNumber ,
[Sn]			= @Sn  ,
[JCode]			= @JCode  ,
[Ccr]			= @Ccr	 ,
[CaseNumber]	= @CaseNumber , 
[Type]			= @Type  ,
[IdNo]			= @IdNo  ,
[YearMade]		= @YearMade ,
[Quantity]		= @Quantity,
[UnitPrice]		= @UnitPrice ,
[ExtendedValue]	= @ExtendedValue,
[Length]		= @Length ,
[Width]			= @Width,	
[Height]		= @Height ,
[Volume]		= @Volume ,
[GrossWeight]	= @GrossWeight ,
[NetWeight]		= @NetWeight ,
[Currency]		= @Currency ,
[CoO]			= @CoO ,
[CreateBy]		= @CreateBy ,
[CreateDate]	= @CreateDate ,
[UpdateBy]		= @UpdateBy,
[UpdateDate]	= @UpdateDate ,
[IsDelete]		= @IsDelete ,
[IdParent]		= @IdParent ,
[SIBNumber]		= @SIBNumber ,
[WONumber]		= @WONumber,
[Claim]			= @Claim ,
[ASNNumber]		= @ASNNumber	  
where Id = @IdCiplItem and IdCipl = @IdCipl
  
delete From CiplItem_Change where Id = @id   and IdCipl = @IdCipl  
end  
else  
begin  
   
update CiplItem  
set [IsDelete] = 1  
where Id = (select IdCiplItem from CiplItem_Change where Id = @Id) and IdCipl = @IdCipl  
delete From CiplItem_Change where Id = @id and IdCipl = @IdCipl  
end  
  
  
  
end
GO
