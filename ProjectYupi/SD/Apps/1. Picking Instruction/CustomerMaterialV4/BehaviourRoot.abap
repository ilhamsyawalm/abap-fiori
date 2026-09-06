managed implementation in class zbp_yupi_sd_i_instruction unique;
strict(2);
with draft;                                       // " <-- tambah

define behavior for ZYUPI_SD_I_INSTRUCTION alias insth
persistent table zyupi_sd_t_insth
lock master
total etag LastChangedAt
draft table zyupi_sd_d_insth                      // " <-- tambah
authorization master ( instance )
etag master LocalChangedAt
//early numbering
{
  create ( authorization : global );
  update;
  delete;

//  field ( readonly )
//  draftuuid;


  field ( readonly : update )
  CustMat;

  field ( readonly )
  CreatedAt,
  CreatedBy,
  LastChangedAt,
  LastChangedBy;

  validation validateMandatory on save {
    create;
    update;
    field CustMat,
          SalesOrganization,
          DistributionChannel,
          CustomerCountry,
          SoldToEndCustomer,
          ShipToEndCustomer,
          Material;
  }

  draft action Activate optimized;                // " <-- tambah
  draft action Edit;                              // " <-- tambah
  draft action Discard;                           // " <-- tambah
  draft action Resume;                            // " <-- tambah
  draft determine action Prepare;                 // " <-- tambah

  mapping for zyupi_sd_t_insth
    {
//      draftuuid           = draftuuid;
      CustMat             = cust_mat;
      SalesOrganization   = sales_org;
      DistributionChannel = dist_channel;
      CustomerCountry     = cust_country;
      SoldToEndCustomer   = sold_end;
      ShipToEndCustomer   = ship_end;
      Material            = material;
      CustMatDesc         = cust_matdesc;
      SpecialInstr        = special_instr;
      Packing             = packing;
      Expired             = expired;
      CreatedAt           = created_at;
      CreatedBy           = created_by;
      LastChangedAt       = last_changed_at;
      LastChangedBy       = last_changed_by;
      LocalChangedBy      = local_last_changed_by;
      LocalChangedAt      = local_last_changed_at;
    }
}