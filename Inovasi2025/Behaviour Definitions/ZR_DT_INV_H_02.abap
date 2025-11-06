managed implementation in class ZBP_DT_INV_H_02 unique;
strict ( 2 );
with draft;

define behavior for ZR_DT_INV_H_02 alias Issue
persistent table zdt_inv_h_02
draft table zdt_inv_h_02_d
etag master LocalLastChangedAt
lock master total etag Lastchangedat
authorization master ( global )
//authorization master ( instance )
late numbering

{

  field ( readonly )
  IssueID,
  Createdat,
  Createdby,
  Lastchangedat,
  LocalLastChangedAt,
  LocalLastChangedBy;

  field ( mandatory )
  Category;

//  field ( features : instance ) hideField;

  action ( features : instance ) checkPassword parameter ZRA_POPUP result [1] $self; // misalnya action untuk validasi password

  create;
  update;
  delete;

  determination setDescription on modify { create; }

//  determination setHideFieldTrue on modify { create; }

  draft action Edit;
  draft action Activate optimized;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  mapping for zdt_inv_h_02
    {
      IssueID            = issueid;
      Category           = category;
      Type               = type;
      Tittle             = tittle;
      Description        = description;
      Createdby          = createdby;
      Createdat          = createdat;
      Attachment         = attachment;
      MimeType           = mime_type;
      FileName           = file_name;
      Source             = source;
      LocalLastChangedBy = local_last_changed_by;
      LocalLastChangedAt = local_last_changed_at;
      Lastchangedat      = lastchangedat;
      hideField          = hidefield;
      //      Password           = password;
    }
}