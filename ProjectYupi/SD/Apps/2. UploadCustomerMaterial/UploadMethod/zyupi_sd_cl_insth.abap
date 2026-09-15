CLASS zyupi_sd_cl_insth DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS modify_table IMPORTING is_table TYPE zyupi_sd_t_insth
                               RAISING
                                         cx_uuid_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zyupi_sd_cl_insth IMPLEMENTATION.

  METHOD modify_table.
    DATA :           lt_create   TYPE TABLE FOR CREATE zyupi_sd_i_instruction.
    DATA(lv_cid) = cl_system_uuid=>create_uuid_x16_static( ).
    IF is_table IS NOT INITIAL.
      APPEND VALUE #(
          %cid                = lv_cid
          custmat             = is_table-cust_mat
          salesorganization   = is_table-sales_org
          distributionchannel = is_table-dist_channel
          customercountry     = is_table-cust_country
          soldtoendcustomer   = is_table-sold_end
          shiptoendcustomer   = is_table-ship_end
          material            = is_table-material
          custmatdesc         = is_table-cust_matdesc
          specialinstr        = is_table-special_instr
          packing             = is_table-packing
          expired             = is_table-expired
          %control            = VALUE #(
            custmat             = if_abap_behv=>mk-on
            salesorganization   = if_abap_behv=>mk-on
            distributionchannel = if_abap_behv=>mk-on
            customercountry     = if_abap_behv=>mk-on
            soldtoendcustomer   = if_abap_behv=>mk-on
            shiptoendcustomer   = if_abap_behv=>mk-on
            material            = if_abap_behv=>mk-on
            custmatdesc         = if_abap_behv=>mk-on
            specialinstr        = if_abap_behv=>mk-on
            packing             = if_abap_behv=>mk-on
            expired             = if_abap_behv=>mk-on
          )
        ) TO lt_create.

      " 3. Eksekusi CREATE EML
      MODIFY ENTITIES OF zyupi_sd_i_instruction
        ENTITY insth
*        CREATE SET FIELDS WITH lt_create
        CREATE FROM lt_create
        MAPPED DATA(ls_mapped)
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

*      APPEND VALUE #(
*        %cid                = |CID_{ sy-tabix }|
*        custmat             = is_table-cust_mat
*        salesorganization   = is_table-sales_org
*        distributionchannel = is_table-dist_channel
*        customercountry     = is_table-cust_country
*        soldtoendcustomer   = is_table-sold_end
*        shiptoendcustomer   = is_table-ship_end
*        material            = is_table-material
*        custmatdesc         = is_table-cust_matdesc
*        specialinstr        = is_table-special_instr
*        packing             = is_table-packing
*        expired             = is_table-expired
*      ) TO lt_create.
*
*    " Execute CREATE secara sekaligus di luar LOOP
*
*    MODIFY ENTITIES OF zyupi_sd_i_instruction
*      ENTITY insth
*      CREATE FROM lt_create
*      MAPPED DATA(ls_mapped)
*      FAILED DATA(ls_failed)
*      REPORTED DATA(ls_reported).

*      MODIFY zyupi_sd_t_insth FROM @is_table.
*      INSERT zyupi_sd_t_insth FROM @is_table.
    ENDIF.
  ENDMETHOD.

ENDCLASS.