zdt_inv_type_02 @EndUserText.label : 'Database Type Category Inovasi 02'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_inv_type_02 {

  key client  : abap.clnt not null;
  key type_id : abap.char(1) not null;
  type_name   : abap.char(100);

}