@Metadata.layer: #CORE
@EndUserText.label: 'MetadataExtension ZYUPI_SD_C_INSTRUCTION'
  
@UI: {
  headerInfo: {
    typeName: 'Instruction',
    typeNamePlural: 'Instructions',
    title: {
      type: #STANDARD,
      value: 'CustMat'
    },
    description: {
      value: 'CustMatDesc'
    }
  }
}

annotate view ZYUPI_SD_C_INSTRUCTION with
{
  @UI.facet: [
    {
      id: 'GeneralInformation',
      type: #COLLECTION,
      label: 'General Information',
      position: 10
    },
    {
      id: 'BasicData',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Key Data',
      parentId: 'GeneralInformation',
      targetQualifier: 'BasicData',
      position: 10
    },
    {
      id: 'InstructionDetails',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Instruction & Details',
      parentId: 'GeneralInformation',
      targetQualifier: 'InstructionDetails',
      position: 20
    },
    {
      id: 'AdminData',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Administrative Data',
      parentId: 'GeneralInformation',
      targetQualifier: 'AdminData',
      position: 30
    }
  ]

// @UI.hidden: true
// draftuuid;

  @UI.lineItem: [
    {
      position: 10,
      importance: #HIGH,
      label: 'Customer Material'
    }
  ]
  @UI.selectionField: [{ position: 10 }]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 10,
    label: 'Customer Material'
  }]

  CustMat;

  @UI.lineItem: [
    {
      position: 20,
            importance: #MEDIUM,
      label: 'Sales Organization'
    }
  ]
  @UI.selectionField: [{ position: 20 }]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 20,
    label: 'Sales Organization'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
        name: 'I_SalesOrganizationText',
        element: 'SalesOrganization'
    }
   }]
  SalesOrganization;

  @UI.lineItem: [
    {
      position: 30,
      label: 'Distribution Channel'
    }
  ]
  @UI.selectionField: [{ position: 30 }]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 30,
    label: 'Distribution Channel'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
       name: 'I_CnsldtnDistributionChannel',
       element: 'DistributionChannel'
    }
   }]
  DistributionChannel;

  @UI.lineItem: [
    {
      position: 40,
      label: 'Customer Country'
    }
  ]
  @UI.selectionField: [{ position: 40 }]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 40,
    label: 'Customer Country'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
       name: 'I_BusinessPartner',
       element: 'BusinessPartner'
    }
   }]  
  CustomerCountry;

  @UI.lineItem: [
    {
      position: 50,
      label: 'Sold-To End Customer'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 50,
    label: 'Sold-To End Customer'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
       name: 'I_BusinessPartner',
       element: 'BusinessPartner'
    }
   }]   
  SoldToEndCustomer;

  @UI.lineItem: [
    {
      position: 60,
      label: 'Ship-To End Customer'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 60,
    label: 'Ship-To End Customer'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
       name: 'I_BusinessPartner',
       element: 'BusinessPartner'
    }
   }]   
  ShipToEndCustomer;

  @UI.lineItem: [
    {
      position: 70,
      label: 'Material'
    }
  ]
  @UI.selectionField: [{ position: 50 }]
  @UI.fieldGroup: [{
    qualifier: 'BasicData',
    position: 70,
    label: 'Material'
  }]
  @Consumption.valueHelpDefinition: [{ 
    entity: { 
       name: 'I_ProductDescription',
       element: 'Product'
    }
   }]   
  Material;

  @UI.lineItem: [
    {
      position: 80,
      label: 'Customer Material Description'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'InstructionDetails',
    position: 10,
    label: 'Customer Material Description'
  }]
  CustMatDesc;


  @UI.lineItem: [
    {
      position: 90,
      label: 'Special Instruction'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'InstructionDetails',
    position: 20,
    label: 'Special Instruction'
  }]
  @UI.multiLineText: true  
  SpecialInstr;

  @UI.lineItem: [
    {
      position: 100,
      label: 'Packing'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'InstructionDetails',
    position: 30,
    label: 'Packing'
  }]
  @UI.multiLineText: true  
  Packing;

  @UI.lineItem: [
    {
      position: 110,
      label: 'Expired'
    }
  ]
  @UI.fieldGroup: [{
    qualifier: 'InstructionDetails',
    position: 40,
    label: 'Expired'
  }]
  @UI.multiLineText: true   
  Expired;


  @UI.fieldGroup: [{
    qualifier: 'AdminData',
    position: 10,
    label: 'Created At'
  }]
  CreatedAt;

  @UI.fieldGroup: [{
    qualifier: 'AdminData',
    position: 20,
    label: 'Created By'
  }]
  CreatedBy;

  @UI.fieldGroup: [{
    qualifier: 'AdminData',
    position: 30,
    label: 'Last Changed At'
  }]
  LastChangedAt;

  @UI.fieldGroup: [{
    qualifier: 'AdminData',
    position: 40,
    label: 'Last Changed By'
  }]
  LastChangedBy;
  
  @UI.hidden: true
  LocalChangedAt;
  
  @UI.hidden: true
  LocalChangedBy;
}