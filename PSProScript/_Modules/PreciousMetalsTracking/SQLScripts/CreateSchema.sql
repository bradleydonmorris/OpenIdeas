CREATE TABLE IF NOT EXISTS "MetalType" (
    "MetalTypeId" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    CONSTRAINT "PK_MetalType" PRIMARY KEY ("MetalTypeId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_MetalType_MetalTypeId" ON "MetalType"("MetalTypeId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_MetalType_Name" ON "MetalType"("Name" ASC);

CREATE TABLE IF NOT EXISTS "Vendor" (
    "VendorId" INTEGER NOT NULL,
    "VendorGUID" TEXT NOT NULL,
    "Name" TEXT NOT NULL,
    "WebSite" TEXT,
    CONSTRAINT "PK_Vendor" PRIMARY KEY ("VendorId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Vendor_VendorId" ON "Vendor"("VendorId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Vendor_VendorGUID" ON "Vendor"("VendorGUID" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Vendor_Name" ON "Vendor"("Name" ASC);

CREATE TABLE IF NOT EXISTS "Transaction" (
    "TransactionId" INTEGER NOT NULL,
    "VendorId" INTEGER NOT NULL,
    "TransactionGUID" TEXT NOT NULL,
    "PurchaseDate" TEXT NOT NULL,
    "ReceiveDate" TEXT NOT NULL,
    "OrderNumber" TEXT NULL,
    CONSTRAINT "PK_Transaction" PRIMARY KEY ("TransactionId"),
    CONSTRAINT "FK_Transaction_Vendor" FOREIGN KEY("VendorId") REFERENCES "Vendor"("VendorId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Transaction_TransactionId" ON "Transaction"("TransactionId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Transaction_TransactionGUID" ON "Transaction"("TransactionGUID" ASC);
CREATE INDEX IF NOT EXISTS "IX_Transaction_VendorId" ON "Transaction"("VendorId" ASC);

CREATE TABLE IF NOT EXISTS "Item" (
    "ItemId" INTEGER NOT NULL,
    "MetalTypeId" INTEGER NOT NULL,
    "ItemGUID" TEXT NOT NULL,
    "Name" TEXT NOT NULL,
    "Purity" NUMERIC NOT NULL,
    "Ounces" NUMERIC NOT NULL,
    CONSTRAINT "PK_Item" PRIMARY KEY ("ItemId"),
    CONSTRAINT "FK_Item_MetalType" FOREIGN KEY("MetalTypeId") REFERENCES "MetalType"("MetalTypeId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Item_ItemId" ON "Item"("ItemId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Item_ItemGUID" ON "Item"("ItemGUID" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_Item_Name" ON "Item"("Name" ASC);
CREATE INDEX IF NOT EXISTS "IX_Item_MetalTypeId" ON "Item"("MetalTypeId" ASC);

CREATE TABLE IF NOT EXISTS "ItemVendor" (
    "ItemVendorId" INTEGER NOT NULL,
    "ItemId" INTEGER NOT NULL,
    "VendorId" INTEGER NOT NULL,
    "SKU" TEXT NOT NULL,
    "Description" TEXT NOT NULL,
    CONSTRAINT "PK_ItemVendor" PRIMARY KEY ("ItemVendorId"),
    CONSTRAINT "FK_ItemVendor_Item" FOREIGN KEY("ItemId") REFERENCES "Item"("ItemId"),
    CONSTRAINT "FK_ItemVendor_Vendor" FOREIGN KEY("VendorId") REFERENCES "Vendor"("VendorId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_ItemVendor_ItemVendorId" ON "ItemVendor"("ItemVendorId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_ItemVendor_Key" ON "ItemVendor"("ItemId" ASC, "VendorId" ASC);

CREATE TABLE IF NOT EXISTS "ItemTransaction" (
    "ItemTransactionId" INTEGER NOT NULL,
    "ItemId" INTEGER NOT NULL,
    "TransactionId" INTEGER NOT NULL,
    "Price" NUMERIC NOT NULL,
    CONSTRAINT "PK_ItemTransaction" PRIMARY KEY ("ItemTransactionId"),
    CONSTRAINT "FK_ItemTransaction_Item" FOREIGN KEY("ItemId") REFERENCES "Item"("ItemId"),
    CONSTRAINT "FK_ItemTransaction_Transaction" FOREIGN KEY("TransactionId") REFERENCES "Transaction"("TransactionId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_ItemTransaction_ItemTransactionId" ON "ItemTransaction"("ItemTransactionId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_ItemTransaction_Key" ON "ItemTransaction"("ItemId" ASC, "TransactionId" ASC);


CREATE TABLE IF NOT EXISTS "TransactionSpotPrice" (
    "TransactionSpotPriceId" INTEGER NOT NULL,
    "TransactionId" INTEGER NOT NULL,
    "MetalTypeId" INTEGER NOT NULL,
    "Price" NUMERIC NOT NULL,
    CONSTRAINT "PK_TransactionSpotPrice" PRIMARY KEY ("TransactionSpotPriceId"),
    CONSTRAINT "FK_TransactionSpotPrice_Transaction" FOREIGN KEY("TransactionId") REFERENCES "Transaction"("TransactionId"),
    CONSTRAINT "FK_TransactionSpotPrice_MetalType" FOREIGN KEY("MetalTypeId") REFERENCES "MetalType"("MetalTypeId")
);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_TransactionSpotPrice_TransactionSpotPriceId" ON "TransactionSpotPrice"("TransactionSpotPriceId" ASC);
CREATE UNIQUE INDEX IF NOT EXISTS "UX_TransactionSpotPrice_Key" ON "TransactionSpotPrice"("TransactionId" ASC, "MetalTypeId" ASC);
