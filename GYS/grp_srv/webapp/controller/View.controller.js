sap.ui.define(
  ["sap/ui/core/mvc/Controller"],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (Controller) {
    "use strict";

    return Controller.extend("grpsrv.grpsrv.controller.View", {
      onInit: function () {
        let oModel = this.getOwnerComponent().getModel();

        //Mengambil data dari OData service dengan filter tertentu
        oModel.read("/getMtsStocksSet", {
          filters: [
            new sap.ui.model.Filter(
              "Material",
              sap.ui.model.FilterOperator.EQ,
              "RBFF"
            ),
            new sap.ui.model.Filter(
              "Sloc",
              sap.ui.model.FilterOperator.EQ,
              "*"
            ),
            new sap.ui.model.Filter(
              "Plant",
              sap.ui.model.FilterOperator.EQ,
              "CBTG"
            ),
          ],
          success: function (data) {
            console.log("Data berhasil diambil:", data);
          },
          error: function (err) {
            console.error("Gagal mengambil data:", err);
          },
        });

        //Mengambil data dari OData service tanpa filter
        oModel.read("/wbmsWgtDataSet", {
          success: function (data) {
            console.log("Data tanpa filter berhasil diambil:", data);
          },
          error: function (err) {
            console.error("Gagal mengambil data tanpa filter:", err);
          },
        });

        //Memanggil function import OData service dengan parameter tertentu
        oModel.callFunction("/getBonOrder", {
          method: "GET",
          urlParameters: {
            BonOrdNo: "231211BON001",
          },
          success: function (data) {
            console.log("Data getBonOrder berhasil diambil:", data);
          },
          error: function (err) {
            console.error("Gagal mengambil data getBonOrder:", err);
          },
        });
      },
    });
  }
);
