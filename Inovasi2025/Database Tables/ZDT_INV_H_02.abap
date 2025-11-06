@EndUserText.label : 'Database Header Inovasi Issue List 02'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_inv_h_02 {

  key client            : abap.clnt not null;
  key issueid           : abap.numc(10) not null;
  category              : abap.char(100);
  type                  : abap.char(100);
  tittle                : abap.char(100);
  description           : abap.sstring(1333);
  createdby             : abp_creation_user;
  createdat             : abp_creation_tstmpl;
  attachment            : abap.rawstring(0);
  mime_type             : abap.char(255);
  file_name             : abap.char(255);
  source                : abap.sstring(1333);
  local_last_changed_by : abp_locinst_lastchange_user;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
  lastchangedat         : abp_lastchange_tstmpl;
  hidefield             : abap_boolean;

}