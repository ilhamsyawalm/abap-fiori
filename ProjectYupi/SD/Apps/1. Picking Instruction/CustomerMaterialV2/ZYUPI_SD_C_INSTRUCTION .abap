@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View ZYUPI_SD_I_INSTRUCTION'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZYUPI_SD_C_INSTRUCTION 
 provider contract transactional_query
 as projection on ZYUPI_SD_I_INSTRUCTION
{
    key CustMat,
    SalesOrganization,
    DistributionChannel,
    CustomerCountry,
    SoldToEndCustomer,
    ShipToEndCustomer,
    Material,
    CustMatDesc,
    SpecialInstr,
    Packing,
    Expired,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy    
}
