BEGIN TRANSACTION [INSERT_SHIPPING_FLEET_ITEM]
BEGIN TRY
	--DELETE FROM ShippingFleetRefrence

	INSERT INTO ShippingFleetRefrence([IdShippingFleet], [IdGr], [IdCipl], [DoNo], [CreateDate])
	SELECT	sf.Id, grItem.IdGr, grItem.IdCipl, grItem.DoNo, grItem.CreateDate
	FROM	GoodsReceive gr
			JOIN GoodsReceiveItem grItem ON gr.Id = grItem.IdGr
			JOIN ShippingFleet sf ON gr.Id = sf.IdGr
	/*Where condition depend on insert new data on shipping fleet from good receive item*/
	--WHERE	sf.Id BETWEEN 10031 AND 10903

	COMMIT TRANSACTION [INSERT_SHIPPING_FLEET_ITEM]
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [INSERT_SHIPPING_FLEET_ITEM]
END CATCH