CLASS zcl_generate_dummy_inv_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_generate_dummy_inv_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA lt_category TYPE TABLE OF zdt_inv_ctgry_02.
    DATA ls_category TYPE zdt_inv_ctgry_02.

    " Menambahkan data secara manual
    ls_category-category_id = 'R'.
    ls_category-category_name = 'Reports'.
    ls_category-description = 'Program custom untuk menampilkan data, biasanya dalam bentuk list atau summary'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'I'.
    ls_category-category_name = 'Interfaces'.
    ls_category-description = 'Integrasi antara SAP dan sistem eksternal (misalnya API, IDoc, RFC, BAPI)'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'C'.
    ls_category-category_name = 'Conversions'.
    ls_category-description = 'Proses migrasi data dari sistem lama ke SAP'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'E'.
    ls_category-category_name = 'Enhancements'.
    ls_category-description = 'Modifikasi atau penambahan fungsi pada standar SAP tanpa mengubah core code (misalnya user-exit, BADI)'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'F'.
    ls_category-category_name = 'Forms'.
    ls_category-description = 'Output dokumen seperti invoice, PO, delivery note, biasanya menggunakan SmartForms atau Adobe Forms'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'W'.
    ls_category-category_name = 'Workflows'.
    ls_category-description = 'Otomatisasi proses bisnis, seperti approval PO, leave request, dll'.
    APPEND ls_category TO lt_category.

    ls_category-category_id = 'A'.
    ls_category-category_name = 'Applications'.
    ls_category-description = 'Program custom untuk menjalankan proses bisnis tertentu'.
    APPEND ls_category TO lt_category.

*    " Insert ke database
    INSERT zdt_inv_ctgry_02 FROM TABLE lt_category.

    " Commit perubahan
    COMMIT WORK.

    out->write( 'Data berhasil dimasukkan ke tabel' ).

  ENDMETHOD.
ENDCLASS.