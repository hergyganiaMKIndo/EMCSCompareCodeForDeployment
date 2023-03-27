BEGIN TRANSACTION [INSERT_SHIPPING_FLEET]
BEGIN TRY
	--DELETE FROM ShippingFleet

	INSERT INTO ShippingFleet ([IdGr], [IdCipl], [DoNo], [DaNo], [PicName], [PhoneNumber], [KtpNumber], [SimNumber], [SimExpiryDate], [StnkNumber], [KirNumber], [KirExpire], [NopolNumber], [EstimationTimePickup], [Apar], [Apd], [FileName], [Bast])
	SELECT	gr.Id, gritem.IdCipl, grItem.DoNo, grItem.DaNo, gr.PicName, gr.PhoneNumber, gr.KtpNumber, gr.SimNumber, gr.SimExpiryDate, gr.StnkNumber, gr.KirNumber, gr.KirExpire, gr.NopolNumber, gr.EstimationTimePickup, gr.Apar, gr.Apd, grItem.[FileName], '' [Bast]
	FROM	GoodsReceive gr
			JOIN GoodsReceiveItem grItem ON gr.Id = grItem.IdGr

	COMMIT TRANSACTION [INSERT_SHIPPING_FLEET]
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [INSERT_SHIPPING_FLEET]
END CATCH