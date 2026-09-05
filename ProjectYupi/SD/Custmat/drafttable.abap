@EndUserText.label : 'Draft Table for Instruction Header'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zyupi_sd_d_insth {

  key client          : abap.clnt not null;
  key custmat         : abap.char(60) not null;
  salesorganization   : abap.char(5) not null;
  distributionchannel : abap.char(5) not null;
  customercountry     : abap.char(10) not null;
  soldtoendcustomer   : abap.char(10) not null;
  shiptoendcustomer   : abap.char(10) not null;
  material            : abap.char(10) not null;
  custmatdesc         : abap.char(60);
  specialinstr        : abap.char(1333);
  packing             : abap.char(1333);
  expired             : abap.char(40);
  createdat           : abp_creation_tstmpl;
  createdby           : abp_creation_user;
  lastchangedat       : abp_lastchange_tstmpl;
  lastchangedby       : abp_lastchange_user;
  localchangedby      : abp_locinst_lastchange_user;
  localchangedat      : abp_locinst_lastchange_tstmpl;
  "%admin"            : include sych_bdl_draft_admin_inc;

}