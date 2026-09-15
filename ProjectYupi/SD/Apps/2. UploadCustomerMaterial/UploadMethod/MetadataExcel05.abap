@Metadata.layer: #CUSTOMER
@UI.headerInfo: {
    typeName: 'File Data',
    typeNamePlural: 'File Data',
    title: { type: #STANDARD, value: 'end_user' },
    description: { type: #STANDARD, value: 'file_id' }
}    
annotate entity ZYUPI_SD_C_EXCEL_06 with
{
//  @UI.hidden:true
  @UI.lineItem: [{  type: #FOR_ACTION, label: 'Process Data', dataAction:'processData' }]
  end_user;
  @UI.hidden : true
  file_id;
  @UI.lineItem: [{ position: 5, label: 'Line' }]
  @UI.identification: [{ position: 5, label: 'Line' }]
  line_id;
  @UI.lineItem: [{ position: 10, label: 'Number' }]
//  @UI.identification: [{ position: 10, label: 'Number' }]
  line_no;
 
  @UI.lineItem: [{ position:20, label: 'Customer Material' }]    
//  @UI.identification: [{ position: 40, label: 'Customer Material' }]
  cust_mat;
  @UI.lineItem: [{ position:30, label: 'Sales Organization' }]    
//  @UI.identification: [{ position: 50, label: 'Sales Organization' }]
  sales_org;
  @UI.lineItem: [{ position:40, label: 'Distribution Channel' }]    
//  @UI.identification: [{ position: 60, label: 'Distribution Channel' }]
  dist_channel;
  @UI.lineItem: [{ position:50, label: 'Customer Country' }]    
//  @UI.identification: [{ position: 70, label: 'Customer Country' }]
  cust_country;
  @UI.lineItem: [{ position:60, label: 'Sold To End Customer' }]    
//  @UI.identification: [{ position: 80, label: 'Sold To End Customer' }]
  sold_end;
  @UI.lineItem: [{ position:70, label: 'Ship To End Customer' }]    
//  @UI.identification: [{ position: 90, label: 'Ship To End Customer' }]
  ship_end;
  @UI.lineItem: [{ position:80, label: 'Material' }]    
//  @UI.identification: [{ position: 100, label: 'Material' }]
  material;
  @UI.lineItem: [{ position:90, label: 'Customer Material Description' }]    
//  @UI.identification: [{ position: 110, label: 'Customer Material Description' }]
  cust_matdesc;  
  @UI.lineItem: [{ position:100, label: 'Special Instruction' }]    
//  @UI.identification: [{ position: 120, label: 'Special Instruction' }]
  @UI.multiLineText: true  
  special_instr;
  @UI.lineItem: [{ position:110, label: 'Packing' }]    
//  @UI.identification: [{ position: 130, label: 'Packing' }]
  @UI.multiLineText: true  
  packing;
  @UI.lineItem: [{ position:120, label: 'Expired' }]    
//  @UI.identification: [{ position: 140, label: 'Expired' }]
  @UI.multiLineText: true  
  expired;  
}