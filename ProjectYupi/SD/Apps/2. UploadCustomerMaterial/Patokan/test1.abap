CLASS lhc_xl06 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR xl06 RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR xl06 RESULT result.

    METHODS processdata FOR MODIFY
       keys FOR ACTION xl06~processdata RESULT result.

ENDCLASS.

CLASS lhc_xl06 IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD processdata.

    DATA:
      lt_create   TYPE TABLE FOR CREATE zyupi_sd_i_instruction,
      lr_business TYPE RANGE OF i_businesspartner-businesspartner,
      lr_salesorg TYPE RANGE OF i_salesorganizationtext-salesorganization,
      lr_distchan TYPE RANGE OF i_cnsldtndistributionchannel-distributionchannel,
      lr_product  TYPE RANGE OF i_productdescription-product,

      lv_total    TYPE i,
      lv_valid    TYPE i.

    "========================================================
    " 1. Tidak ada data yang dipilih
    "========================================================
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    lv_total = lines( keys ).


    "========================================================
    " 2. Build RANGE dari semua selected rows
    "========================================================

    "Business Partner
    lr_business = VALUE #(
      FOR ls IN keys
      (
        sign   = 'I'
        option = 'EQ'
        low    = |{ ls-cust_country ALPHA = IN }|
      )
      (
        sign   = 'I'
        option = 'EQ'
        low    = |{ ls-sold_end ALPHA = IN }|
      )
      (
        sign   = 'I'
        option = 'EQ'
        low    = |{ ls-ship_end ALPHA = IN }|
      )
    ).

    "Sales Organization
    lr_salesorg = VALUE #(
      FOR ls IN keys
      (
        sign   = 'I'
        option = 'EQ'
        low    = ls-sales_org
      )
    ).

    "Distribution Channel
    lr_distchan = VALUE #(
      FOR ls IN keys
      (
        sign   = 'I'
        option = 'EQ'
        low    = ls-dist_channel
      )
    ).

    "Material
    lr_product = VALUE #(
      FOR ls IN keys
      (
        sign   = 'I'
        option = 'EQ'
        low    = ls-material
      )
    ).


    "========================================================
    " 3. SELECT MASTER DATA - SEKALI SAJA
    "========================================================

    SELECT salesorganization
      FROM i_salesorganizationtext
      WHERE salesorganization IN @lr_salesorg
      INTO TABLE @DATA(lt_salesorg).

    SELECT distributionchannel
      FROM i_cnsldtndistributionchannel
      WHERE distributionchannel IN @lr_distchan
      INTO TABLE @DATA(lt_distchannel).

    SELECT businesspartner
      FROM i_businesspartner
      WHERE businesspartner IN @lr_business
      INTO TABLE @DATA(lt_business).

    SELECT product
      FROM i_productdescription
      WHERE product IN @lr_product
      INTO TABLE @DATA(lt_product).


    "========================================================
    " 4. SELECT DATA YANG SUDAH ADA DI Z TABLE
    "========================================================
    SELECT cust_mat,
           sales_org,
           dist_channel,
           cust_country,
           sold_end,
           ship_end,
           material
      FROM zyupi_sd_t_insth
      FOR ALL ENTRIES IN @keys
      WHERE cust_mat     = @keys-cust_mat
        AND sales_org    = @keys-sales_org
        AND dist_channel = @keys-dist_channel
        AND cust_country = @keys-cust_country
        AND sold_end     = @keys-sold_end
        AND ship_end     = @keys-ship_end
        AND material     = @keys-material
      INTO TABLE @DATA(lt_insth).


    "========================================================
    " 5. VALIDASI SEMUA ROW
    "========================================================
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      DATA(lv_error) = abap_false.


      "------------------------------------------------------
      " Customer Material
      "------------------------------------------------------
      IF <fs_key>-cust_mat IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Customer Material cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ENDIF.


      "------------------------------------------------------
      " Sales Organization
      "------------------------------------------------------
      IF <fs_key>-sales_org IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Sales Organization cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_salesorg
          WITH KEY salesorganization = <fs_key>-sales_org
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Sales Organization { <fs_key>-sales_org } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Distribution Channel
      "------------------------------------------------------
      IF <fs_key>-dist_channel IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Distribution Channel cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_distchannel
          WITH KEY distributionchannel = <fs_key>-dist_channel
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Distribution Channel { <fs_key>-dist_channel } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Customer Country
      "------------------------------------------------------
      IF <fs_key>-cust_country IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Customer Country cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_business
          WITH KEY businesspartner =
            CONV i_businesspartner-businesspartner(
              |{ <fs_key>-cust_country ALPHA = IN }|
            )
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Customer Country { <fs_key>-cust_country } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Sold To End Customer
      "------------------------------------------------------
      IF <fs_key>-sold_end IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Sold To End Customer cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_business
          WITH KEY businesspartner =
            CONV i_businesspartner-businesspartner(
              |{ <fs_key>-sold_end ALPHA = IN }|
            )
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Sold To End Customer { <fs_key>-sold_end } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Ship To End Customer
      "------------------------------------------------------
      IF <fs_key>-ship_end IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Ship To End Customer cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_business
          WITH KEY businesspartner =
            CONV i_businesspartner-businesspartner(
              |{ <fs_key>-ship_end ALPHA = IN }|
            )
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Ship To End Customer { <fs_key>-ship_end } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Material
      "------------------------------------------------------
      IF <fs_key>-material IS INITIAL.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'Material cannot be empty!'
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ELSE.

        READ TABLE lt_product
          WITH KEY product = <fs_key>-material
          TRANSPORTING NO FIELDS.

        IF sy-subrc <> 0.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text = |Material { <fs_key>-material } not found!|
            )
          ) TO reported-xl06.

          APPEND VALUE #(
            %tky = <fs_key>-%tky
          ) TO failed-xl06.

          lv_error = abap_true.

        ENDIF.

      ENDIF.


      "------------------------------------------------------
      " Cek apakah data sudah ada
      "------------------------------------------------------
      READ TABLE lt_insth
        WITH KEY
          cust_mat     = <fs_key>-cust_mat
          sales_org    = <fs_key>-sales_org
          dist_channel = <fs_key>-dist_channel
          cust_country = <fs_key>-cust_country
          sold_end     = <fs_key>-sold_end
          ship_end     = <fs_key>-ship_end
          material     = <fs_key>-material
        TRANSPORTING NO FIELDS.

      IF sy-subrc = 0.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = |Customer Material { <fs_key>-cust_mat } already assigned!|
          )
        ) TO reported-xl06.

        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-xl06.

        lv_error = abap_true.

      ENDIF.


      "------------------------------------------------------
      " Kalau row valid → masukkan ke lt_create
      "------------------------------------------------------
      IF lv_error = abap_false.

        APPEND VALUE #(
          %cid                = <fs_key>-%cid_ref
          custmat             = <fs_key>-cust_mat
          salesorganization   = <fs_key>-sales_org
          distributionchannel = <fs_key>-dist_channel
          customercountry     = <fs_key>-cust_country
          soldtoendcustomer   = <fs_key>-sold_end
          shiptoendcustomer   = <fs_key>-ship_end
          material            = <fs_key>-material
          custmatdesc         = <fs_key>-cust_matdesc
          specialinstr        = <fs_key>-special_instr
          packing             = <fs_key>-packing
          expired             = <fs_key>-expired
        ) TO lt_create.

      ENDIF.

    ENDLOOP.


    "========================================================
    " 6. ALL OR NOTHING
    "
    " Hanya CREATE kalau semua row yang ditick valid
    "========================================================

    lv_valid = lines( lt_create ).

    IF lv_valid <> lv_total.

      "Ada minimal 1 row yang error.
      "Jangan create row apapun.
      RETURN.

    ENDIF.


    "========================================================
    " 7. BULK CREATE - SATU KALI SAJA
    "========================================================

    IF lt_create IS NOT INITIAL.

      MODIFY ENTITIES OF zyupi_sd_i_instruction
        ENTITY insth
        CREATE FROM lt_create
        MAPPED DATA(mapped1)
        FAILED DATA(failed1)
        REPORTED DATA(reported1).

    ENDIF.


    "========================================================
    " 8. ERROR HANDLING DARI TARGET BO
    "========================================================

    IF failed1-insth IS NOT INITIAL.

      LOOP AT failed1-insth ASSIGNING FIELD-SYMBOL(<fs_failed>).

        "Mapping error dari target BO
        "ke XL06 perlu dilakukan berdasarkan CID/key
        "sesuai struktur failed1 yang tersedia.

      ENDLOOP.

    ENDIF.


    "========================================================
    " 9. Forward reported message
    "========================================================

    IF reported1-insth IS NOT INITIAL.

      LOOP AT reported1-insth ASSIGNING FIELD-SYMBOL(<fs_reported>).

        "Forward message jika diperlukan

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.