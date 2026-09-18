@EndUserText.label: 'View Entity Multiple Stock Custom'
@Search.searchable: false
@Metadata.allowExtensions: true
@AbapCatalog.dataMaintenance: #DISPLAY_ONLY
@Analytics.dataCategory: #CUBE
@Analytics.internalName: #LOCAL
@ObjectModel.modelingPattern: #ANALYTICAL_CUBE
@ObjectModel.supportedCapabilities: [ #ANALYTICAL_PROVIDER, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE ]

define view entity ZYUPI_GRC_I_MultiStockCustom 
//as select from I_MaterialStock_2 as I_MaterialStock_2
as select from I_MaterialStockTimeSeries(P_StartDate : '20260901' , P_EndDate : '20260901' , P_PeriodType : 'M') as I_MaterialStock_2
association[0..1] to I_SalesDocument as _I_SalesDocument on _I_SalesDocument.SalesDocument = I_MaterialStock_2.SDDocument
association[0..*] to I_ProductDescription_2 as _I_ProductDescription_2 on _I_ProductDescription_2.Product = I_MaterialStock_2.Material

{
@EndUserText.label: 'Material for Stock Mamangement'
//@ObjectModel.foreignKey.association: '_Material'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.Material as Material,

@EndUserText.label: 'Plant'
@ObjectModel.foreignKey.association: '_Plant'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.Plant as Plant,

@EndUserText.label: 'Storage Location'
@ObjectModel.foreignKey.association: '_StorageLocation'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.StorageLocation as StorageLocation,

@EndUserText.label: 'Batch SID'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.Batch as Batch,

@EndUserText.label: 'Supplier SID'
@ObjectModel.foreignKey.association: '_Supplier'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.Supplier as Supplier,

@EndUserText.label: 'Sales Order'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.SDDocument as SDDocument,

@EndUserText.label: 'Sales Order Item'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.SDDocumentItem as SDDocumentItem,

@EndUserText.label: 'WBS Internal ID'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.WBSElementInternalID as WBSElementInternalID,

@EndUserText.label: 'Customer SID'
@ObjectModel.foreignKey.association: '_Customer'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.Customer as Customer,

//@EndUserText.label: 'Add. Supplier for Special Stock'
//@ObjectModel.foreignKey.association: '_SpecialStockIdfgStockOwner'
//@ObjectModel.text.association: null
//@ObjectModel.text.element: null
//@Consumption.hidden: false
//@Analytics.excludeFromRuntimeExtensibility: false
//@Consumption.filter.mandatory: false
//@Consumption.filter.multipleSelections: false
//@Consumption.filter.selectionType: null
//@Aggregation.default: null
//key I_MaterialStock_2.SpecialStockIdfgStockOwner as SpecialStockIdfgStockOwner,

@EndUserText.label: 'Stock Type'
@ObjectModel.foreignKey.association: '_InventoryStockType'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.InventoryStockType as InventoryStockType,

@EndUserText.label: 'Special Stock Type'
@ObjectModel.foreignKey.association: '_InventorySpecialStockType'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.InventorySpecialStockType as InventorySpecialStockType,

@EndUserText.label: 'Fiscal Year Variant'
@Semantics.fiscal.yearVariant: true
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.FiscalYearVariant as FiscalYearVariant,

//@EndUserText.label: 'Posting Date'
//@Semantics.businessDate.at: true
//@ObjectModel.foreignKey.association: null
//@ObjectModel.text.association: null
//@ObjectModel.text.element: null
//@Consumption.hidden: false
//@Analytics.excludeFromRuntimeExtensibility: false
//@Consumption.filter.mandatory: false
//@Consumption.filter.multipleSelections: false
//@Consumption.filter.selectionType: null
//@Aggregation.default: null
//key I_MaterialStock_2.MatlDocLatestPostgDate as MatlDocLatestPostgDate,

@EndUserText.label: 'Base Unit of Measure'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.MaterialBaseUnit as MaterialBaseUnit,

@EndUserText.label: 'Cost Estimate Number'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key I_MaterialStock_2.CostEstimate as CostEstimate,

//@EndUserText.label: 'Resource Name'
//@ObjectModel.foreignKey.association: null
//@ObjectModel.text.association: null
//@ObjectModel.text.element: null
//@Consumption.hidden: false
//@Analytics.excludeFromRuntimeExtensibility: false
//@Consumption.filter.mandatory: false
//@Consumption.filter.multipleSelections: false
//@Consumption.filter.selectionType: null
//@Aggregation.default: null
//key I_MaterialStock_2.ResourceID as ResourceID,

@EndUserText.label: 'OF Number'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key _I_SalesDocument.YY1_OFNumber_SDH as YY1_OFNumber_SDH,

@EndUserText.label: 'Stock Quantity'
@Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: #SUM
key I_MaterialStock_2.MatlWrhsStkQtyInMatlBaseUnit as MatlWrhsStkQtyInMatlBaseUnit,

@EndUserText.label: 'Product Description'
@Semantics.text: true
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
key _I_ProductDescription_2.ProductDescription as ProductDescription,

@EndUserText.label: 'Language Key'
@Semantics.language: true
@ObjectModel.foreignKey.association: '_Language'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
_I_ProductDescription_2.Language as Language,

@EndUserText.label: 'Sold-to Party'
@ObjectModel.foreignKey.association: '_SoldToParty'
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: false
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
_I_SalesDocument.SoldToParty as SoldToParty,

@EndUserText.label: '_InventorySpecialStockType'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._InventorySpecialStockType as _InventorySpecialStockType,

@EndUserText.label: '_InventoryStockType'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._InventoryStockType as _InventoryStockType,

//@EndUserText.label: '_SpecialStockIdfgStockOwner'
//@ObjectModel.foreignKey.association: null
//@ObjectModel.text.association: null
//@ObjectModel.text.element: null
//@Consumption.filter.selectionType: null
//@Aggregation.default: null
//I_MaterialStock_2._SpecialStockIdfgStockOwner as _SpecialStockIdfgStockOwner,

@EndUserText.label: '_Customer'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._Customer as _Customer,

@EndUserText.label: '_Supplier'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._Supplier as _Supplier,

@EndUserText.label: '_StorageLocation'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._StorageLocation as _StorageLocation,

@EndUserText.label: '_Plant'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._Plant as _Plant,

@EndUserText.label: '_Material'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2._Material as _Material,

@EndUserText.label: '_Language'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
_I_ProductDescription_2._Language as _Language,

@EndUserText.label: '_SoldToParty'
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.filter.selectionType: null
@Aggregation.default: null
_I_SalesDocument._SoldToParty as _SoldToParty,

@Analytics.hidden: true
@ObjectModel.foreignKey.association: null
@ObjectModel.text.association: null
@ObjectModel.text.element: null
@Consumption.hidden: true
@Analytics.excludeFromRuntimeExtensibility: false
@Consumption.filter.mandatory: false
@Consumption.filter.multipleSelections: false
@Consumption.filter.selectionType: null
@Aggregation.default: null
I_MaterialStock_2.Plant as /SAP/1_PLANT
}
