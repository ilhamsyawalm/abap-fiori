managed;
strict ( 2 );
with draft;

define behavior for ZYUPI_SD_R_EXCEL_05 alias XL05
implementation in class zbp_yupi_sd_r_excel_05 unique
persistent table zyupi_sd_t_excl5
lock master
total etag last_changed_at
draft table zyupi_sd_d_excl5
early numbering
authorization master ( instance )
etag master local_last_changed_at
{
  create ( authorization : global );
  update;
  delete;
  field ( readonly ) end_user, file_id;
  association _XL06 { create; with draft; }

  action uploadExcelData result [1] $self;

  determination FillFileStatus on modify { field end_user; }

  determination FillSelectedStatus on modify { field attachment; }

  side effects
  {
    field attachment affects field file_status;
    action uploadExcelData affects $self, messages  ;

  }

  draft action Activate optimized;
  draft action Edit;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;
}

define behavior for ZYUPI_SD_R_EXCEL_06 alias XL06
implementation in class zbp_yupi_sd_r_excel_06 unique
persistent table zyupi_sd_t_excl6
draft table zyupi_sd_d_excl6
lock dependent by _XL05
authorization dependent by _XL05
//etag master <field_name>
{
  update;
  delete;
  field ( readonly ) end_user, file_id, line_no;

  field ( readonly, numbering : managed ) line_id;
  association _XL05 { with draft; }

  action ( features : instance ) processData result [1] $self;

}