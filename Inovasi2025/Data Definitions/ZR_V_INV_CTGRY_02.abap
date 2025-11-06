@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Define View Type Name for Inovasi 02'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_V_INV_CTGRY_02
  as select from zdt_inv_ctgry_02
{
      //      @UI.textArrangement: #TEXT_ONLY
      //      @ObjectModel.text.element: ['CategoryName']
      @UI.hidden: true
  key category_id   as CategoryId,
      category_name as CategoryName,
      description   as Description
}
