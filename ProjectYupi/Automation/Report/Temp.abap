@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'report'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel: {
   representativeKey: 'PurchaseOrder',
   usageType: {
     dataClass:      #TRANSACTIONAL,
     serviceQuality: #B,
     sizeCategory:   #L
   },
   supportedCapabilities: [ #CDS_MODELING_ASSOCIATION_TARGET, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE, #EXTRACTION_DATA_SOURCE ],
   modelingPattern: #ANALYTICAL_DIMENSION
}

/*+[hideWarning] { "IDS" : [ "CALCULATED_FIELD_CHECK" ]  } */
define root view entity ZTEST_ORDERREPORT
  as select from    I_PurchaseOrderAPI01          as PO
    inner join      I_PurchaseOrderItemAPI01      as POItem      on POItem.PurchaseOrder = PO.PurchaseOrder
    left outer join I_SalesOrderItem              as SOItem      on  SOItem.YY1_ReferenceDocument_SDI  = POItem.PurchaseOrder
                                                                 and SOItem.YY1_ReferenceDocumentI_SDI = ltrim(
      POItem.PurchaseOrderItem, '0'
    )
    left outer join I_PurchaseOrderItemAPI01      as POInter     on  POInter.YY1_ReferenceDocument_PDI  = SOItem.YY1_ReferenceDocument_SDI
                                                                 and POInter.YY1_ReferenceDocumentI_PDI = SOItem.YY1_ReferenceDocumentI_SDI

    left outer join I_SalesOrderItem              as SOProd      on  SOProd.YY1_ReferenceDocument_SDI  = POInter.YY1_ReferenceDocument_PDI
                                                                 and SOProd.YY1_ReferenceDocumentI_SDI = POInter.YY1_ReferenceDocumentI_PDI

    left outer join I_DeliveryDocumentItem        as DelivItem   on  DelivItem.YY1_ReferenceDocument_DLI  = SOProd.YY1_ReferenceDocument_SDI
                                                                 and DelivItem.YY1_ReferenceDocumentI_DLI = SOProd.YY1_ReferenceDocumentI_SDI
                                                                 and DelivItem.ReferenceSDDocument        = SOProd.SalesOrder
                                                                 and DelivItem.ReferenceSDDocumentItem    = SOProd.ReferenceSDDocumentItem

    left outer join I_MaterialDocumentItem_2      as MatDocItem  on  MatDocItem.YY1_ReferenceDocument_MMI  = POItem.PurchaseOrder
                                                                 and MatDocItem.YY1_ReferenceDocumentI_MMI = ltrim(
      POItem.PurchaseOrderItem, '0'
    )
                                                                 and MatDocItem.PurchaseOrder              = POItem.PurchaseOrder
                                                                 and MatDocItem.PurchaseOrderItem          = POItem.PurchaseOrderItem

    left outer join I_SuplrInvcItemPurOrdRefAPI01 as SuppInvItem on  SuppInvItem.YY1_ReferenceDocument_ite  = POItem.PurchaseOrder
                                                                 and SuppInvItem.YY1_ReferenceDocumentI_ite = ltrim(
      POItem.PurchaseOrderItem, '0'
    )
                                                                 and SuppInvItem.PurchaseOrder              = POItem.PurchaseOrder
                                                                 and SuppInvItem.PurchaseOrderItem          = POItem.PurchaseOrderItem

    left outer join I_BillingDocumentItem         as BillItem    on  BillItem.YY1_ReferenceDocument_BDI  = DelivItem.YY1_ReferenceDocument_DLI
                                                                 and BillItem.YY1_ReferenceDocumentI_BDI = DelivItem.YY1_ReferenceDocumentI_DLI
                                                                 and BillItem.ReferenceSDDocument        = DelivItem.ReferenceSDDocument
                                                                 and BillItem.ReferenceSDDocumentItem    = DelivItem.ReferenceSDDocumentItem
  //
  //  -- Z-Tables Joins (Intercompany Logs)
  //    left outer join zyupi_t_interco               as Log1        on  Log1.ponumber = POItem.PurchaseOrder
  //                                                                 and Log1.poitem   = POItem.PurchaseOrderItem
  //    left outer join zyupi_t_interco2              as Log2        on  Log2.ponumber   = POItem.PurchaseOrder
  //                                                                 and Log2.poitem     = POItem.PurchaseOrderItem
  //                                                                 and Log2.outdlv     = DelivItem.DeliveryDocument
  //                                                                 and Log2.outdlvitem = DelivItem.DeliveryDocumentItem
  //    left outer join zyupi_t_interco3              as Log3        on  Log3.ponumber = POItem.PurchaseOrder
  //                                                                 and Log3.poitem   = POItem.PurchaseOrderItem
{
  key POItem.PurchaseOrder,
  key POItem.PurchaseOrderItem,
      POItem.CompanyCode,
      POItem.Material                       as ProductPO,

      -- Sales Order Item Fields
      SOItem.SalesOrder,
      SOItem.SalesOrganization,
      SOItem.SalesOrderItem,
      SOItem.Product                        as ProductSO,

      -- Delivery Document Item Fields
      DelivItem.DeliveryDocument,
      DelivItem.Plant                       as PlantDO,
      DelivItem.DeliveryDocumentItem,
      DelivItem.Product                     as ProductDO,

      -- Material Document Item Fields
      MatDocItem.MaterialDocument,
      MatDocItem.CompanyCode                as CompanyCodeMatDoc,
      MatDocItem.MaterialDocumentItem,
      MatDocItem.Material                   as ProductMatDoc,

      -- Billing Document Item Fields
      BillItem.BillingDocument,
      BillItem.CompanyCode                  as CompanyCodeBilling,
      BillItem.BillingDocumentItem,
      BillItem.Product                      as ProductBilling,

      -- Supplier Invoice Item Fields
      SuppInvItem.SupplierInvoice,
      SuppInvItem.Plant                     as PlantSupply,
      SuppInvItem.SupplierInvoiceItem,
      SuppInvItem.PurchaseOrderItemMaterial as ProductInvoice
      //
      //      -- Cascading Status Logic (Hierarchical Check Log1 -> Log2 -> Log3)
      //      case
      //        when Log1.status = 'S' then
      //          case
      //            when Log2.status = 'S' then Log3.status
      //            else Log2.status
      //          end
      //        else Log1.status
      //      end                                   as FinalStatus,
      //
      //      -- Cascading Message Logic (Sesuai level Status yang terpilih)
      //      case
      //        when Log1.status = 'S' then
      //          case
      //            when Log2.status = 'S' then Log3.message
      //            else Log2.message
      //          end
      //        else Log1.message
      //      end                                   as FinalMessage

}
where
      PO.PurchaseOrderType     =  'Z116'
  and PO.ReleaseIsNotCompleted =  ''
  and PO.CompanyCode           != '3000'
//  and PO.CompanyCode       != '1000'
//  and PO.CompanyCode       != '2000'
