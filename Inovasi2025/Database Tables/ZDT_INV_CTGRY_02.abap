@EndUserText.label : 'Database Type Inovasi 02'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_inv_ctgry_02 {

  key client      : abap.clnt not null;
  key category_id : abap.char(1) not null;
  category_name   : abap.char(100);
  description     : abap.sstring(500);

}