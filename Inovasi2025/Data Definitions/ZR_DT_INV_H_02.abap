@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Define View Inovasi Issue List'
define root view entity ZR_DT_INV_H_02
  as select from zdt_inv_h_02 as Issue

  association [0..1] to ZR_V_INV_TYPE_02  as _Category on $projection.Category = _Category.TypeId
  association [0..1] to ZR_V_INV_CTGRY_02 as _Type     on $projection.Type = _Type.CategoryId

{
  key issueid               as IssueID,
      category              as Category,
      type                  as Type,
      tittle                as Tittle,
      description           as Description,
      @Semantics.user.createdBy: true
      createdby             as Createdby,
      @Semantics.systemDateTime.createdAt: true
      createdat             as Createdat,
      @Semantics.largeObject: {
                                          mimeType: 'MimeType',
                                          fileName: 'FileName',
                                      contentDispositionPreference: #INLINE,
                                          acceptableMimeTypes: [
                      'video/mp4',
                      'video/webm',
                      'video/ogg',
                            'image/png',
                            'image/jpeg',
                            'application/pdf',
                            'application/msword',               // .doc
                            'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
                            'application/vnd.ms-excel',         // .xls
                            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // .xlsx
                            'application/vnd.ms-powerpoint',    // .ppt
                            'application/vnd.openxmlformats-officedocument.presentationml.presentation' // .pptx
                                          ]
      }
      attachment            as Attachment,
      @Semantics.mimeType: true
      mime_type             as MimeType,
      file_name             as FileName,
      source                as Source,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat         as Lastchangedat,
      hidefield             as hideField,
//      password              as Password,

      _Category,
      _Type

}
