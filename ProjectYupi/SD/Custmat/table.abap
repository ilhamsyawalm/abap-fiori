@EndUserText.label : 'Instruction Header'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zyupi_sd_t_insth {

  key client            : abap.clnt not null;
  key cust_mat          : abap.char(60) not null;
  sales_org             : abap.char(5) not null;
  dist_channel          : abap.char(5) not null;
  cust_country          : abap.char(10) not null;
  sold_end              : abap.char(10) not null;
  ship_end              : abap.char(10) not null;
  material              : abap.char(10) not null;
  cust_matdesc          : abap.char(60);
  special_instr         : abap.char(1333);
  packing               : abap.char(1333);
  expired               : abap.char(40);
  created_at            : abp_creation_tstmpl;
  created_by            : abp_creation_user;
  last_changed_at       : abp_lastchange_tstmpl;
  last_changed_by       : abp_lastchange_user;
  local_last_changed_by : abp_locinst_lastchange_user;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;

}