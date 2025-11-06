@Metadata.layer: #CORE
@UI: {
  headerInfo: {
    typeName: 'Soltius - Technical Issue List',
    typeNamePlural: 'Soltius - Technical Issues List'
//    title : { type: #STANDARD, value: 'Tittle' },
//    description : { type: #STANDARD, value: 'Tittle' }
  }
}
annotate view ZC_DT_INV_H_02 with
{
  @UI.facet: [ {
    id: 'idIdentification',
    type: #IDENTIFICATION_REFERENCE,
    label: 'Technical Issue',
    position: 10
  } ]
  //  @UI.lineItem: [ { position: 100, importance: #MEDIUM, label: 'No' } ]
  //  @UI.identification: [ { position: 10 , label: 'IssueID' } ]
  IssueID;


  //  @UI.facet: [
  //      {
  //        id: 'idTechnicalIssue',
  //        type: #FIELDGROUP_REFERENCE,
  //        label: 'Technical Issue',
  //        position: 20,
  //        targetQualifier: 'TechnicalIssueGroup'
  //      },
  //      {
  //        id: 'idRequirement',
  //        type: #FIELDGROUP_REFERENCE,
  //        label: 'Requirement',
  //        position: 30,
  //        targetQualifier: 'RequirementGroup'
  //      },
  //      {
  //        id: 'idMetadata',
  //        type: #FIELDGROUP_REFERENCE,
  //        label: 'Information Content',
  //        position: 40,
  //        targetQualifier: 'MetadataGroup'
  //      }
  //    ]

  //  @UI.fieldGroup: [{ qualifier: 'TechnicalIssueGroup', label: 'Category', position: 10 }]
  @UI.lineItem: [ { position: 10, importance: #HIGH, label: 'Category' } ]
  @UI.identification: [ { position: 10, label: 'Category' } ]
  //  @UI.selectionField: [ { position: 20, element: '_Category' } ]
  @UI.textArrangement: #TEXT_ONLY
  @Consumption.valueHelpDefinition: [{
      entity: {
        name: 'ZR_V_INV_TYPE_02',
        element:'TypeName'
      }
    }]
  Category;

  //  @UI.fieldGroup: [{ qualifier: 'TechnicalIssueGroup', label: 'Type', position: 20 }]
  @UI.lineItem: [ { position: 20, importance: #HIGH, label: 'Type' } ]
  @UI.identification: [ { position: 20 , label: 'Type' } ]
  @UI.selectionField: [ { position: 20, element: 'Type' } ]
  @Consumption.valueHelpDefinition: [{
      entity: {
        name: 'ZR_V_INV_CTGRY_02',
        element:'CategoryName'
      }
    }]
  Type;

  //  @UI.fieldGroup: [{ qualifier: 'RequirementGroup', label: 'Title', position: 10 }]
  //  @UI.lineItem: [ { position: 30 , importance: #HIGH, label: 'Title' } ]
  @UI.identification: [ { position: 40, label: 'Title' } ]
  Tittle;

  //  @UI.fieldGroup: [{ qualifier: 'RequirementGroup', label: 'Content Requirement', position: 20 }]
  @UI.lineItem: [ { position: 30 , importance: #HIGH, label: 'Content Requirement' } ]
  @UI.identification: [ { position: 30 , label: 'Content Requirement' } ]
  @UI.multiLineText: true
  //  @UI.hidden: #( hideField )
  Description;

  //  @UI.fieldGroup: [{ qualifier: 'RequirementGroup', label: 'Attachment', position: 30 }]
  //  @UI.lineItem: [ { position: 40 , importance: #MEDIUM, label: 'Attachment' } ]
  @UI.identification: [ { position: 40 , label: 'Attachment' } ]
  //  @Consumption.hidden: true
  Attachment;

  @UI: { identification: [ { url: 'Source',
                           label: 'Source',
                           type: #WITH_URL,
                           importance: #MEDIUM,
                           position: 50 } ] }
  //  @UI.hidden: true
  Source;

  @UI.lineItem: [ { position: 40 , importance: #MEDIUM, label: 'Created By' } ]
  //  @UI.fieldGroup: [{ qualifier: 'MetadataGroup', label: 'Created By', position: 10 }]
  @UI.identification: [ { position: 60 , label: 'Created By' } ]
  Createdby;

  @UI.lineItem: [ { position: 50 , importance: #MEDIUM, label: 'Created At' } ]
  //  @UI.fieldGroup: [{ qualifier: 'MetadataGroup', label: 'Created At', position: 20 }]
  @UI.identification: [ { position: 70 , label: 'Created At' } ]
  Createdat;

  @UI.lineItem: [ { position: 60 , importance: #MEDIUM, label: 'Changed By' } ]
  //  @UI.fieldGroup: [{ qualifier: 'MetadataGroup', label: 'Changed By', position: 30 }]
  @UI.identification: [ { position: 80 , label: 'Changed By' } ]
  LocalLastChangedBy;

  @UI.lineItem: [ { position: 70 , importance: #MEDIUM, label: 'Changed At' } ]
  //  @UI.fieldGroup: [{ qualifier: 'MetadataGroup', label: 'Changed At', position: 40 }]
  @UI.identification: [ { position: 90 , label: 'Changed At' } ]
  LocalLastChangedAt;

//  @UI.lineItem: [ { position: 70 , importance: #MEDIUM, label: 'Changed At' } ]
  //  @UI.fieldGroup: [{ qualifier: 'MetadataGroup', label: 'Changed At', position: 40 }]
  @UI.identification: [ { position: 100 , label: 'Hide' } ]
  hideField;

  @UI.lineItem: [
    {
    type: #FOR_ACTION,
    dataAction: 'checkPassword',
    label: 'Unlock attachment'
    }
    ]
  @UI.identification: [
    {
    type: #FOR_ACTION,
    dataAction: 'checkPassword',
    label: 'Unlock attachment'
    }
    ]

  @UI.hidden: true
  MimeType;
  @UI.hidden: true
  FileName;
  @UI.hidden: true
  Lastchangedat;
}