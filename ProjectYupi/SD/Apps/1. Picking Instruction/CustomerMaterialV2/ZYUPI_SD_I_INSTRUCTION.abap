@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds View For Table ZYUPI_SD_T_INSTH'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZYUPI_SD_I_INSTRUCTION
  as select from zyupi_sd_t_insth
{
  key cust_mat        as CustMat,
      sales_org       as SalesOrganization,
      dist_channel    as DistributionChannel,
      cust_country    as CustomerCountry,
      sold_end        as SoldToEndCustomer,
      ship_end        as ShipToEndCustomer,
      material        as Material,
      cust_matdesc    as CustMatDesc,
      special_instr   as SpecialInstr,
      packing         as Packing,
      expired         as Expired,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.createdBy: true      
      created_by      as CreatedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy
}
