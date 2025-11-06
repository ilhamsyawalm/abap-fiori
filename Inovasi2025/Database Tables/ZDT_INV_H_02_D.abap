@EndUserText.label : 'Draft Database Table ZDT_INV_H_02'
@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zdt_inv_h_02_d {

  key mandt          : mandt not null;
  key issueid        : abap.numc(10) not null;
  key draftuuid      : sdraft_uuid not null;
  category           : abap.char(100);
  type               : abap.char(100);
  tittle             : abap.char(100);
  description        : abap.sstring(1333);
  createdby          : abp_creation_user;
  createdat          : abp_creation_tstmpl;
  attachment         : abap.rawstring(0);
  mimetype           : abap.char(255);
  filename           : abap.char(255);
  source             : abap.sstring(1333);
  locallastchangedby : abp_locinst_lastchange_user;
  locallastchangedat : abp_locinst_lastchange_tstmpl;
  lastchangedat      : abp_lastchange_tstmpl;
  hidefield          : abap_boolean;
  "%admin"           : include sych_bdl_draft_admin_inc;

}