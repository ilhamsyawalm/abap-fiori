managed implementation in class zbp_yupi_sd_i_instruction unique;
strict(2);

define behavior for ZYUPI_SD_I_INSTRUCTION //alias <alias_name>
persistent table zyupi_sd_t_insth
etag master LastChangedAt
lock master
authorization master ( instance )
{
  create ( authorization : global );
  update;
  delete;

//  field ( mandatory : create )
//  CustMat;

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

  mapping for zyupi_sd_t_insth
    {
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
    }
}