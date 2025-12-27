sap.ui.define(
  ["sap/ui/core/mvc/Controller"],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (Controller) {
    "use strict";

    return Controller.extend("podata.controller.POData", {
      onInit: function () {
        let oModel = this.getOwnerComponent().getModel();
        let oData = this;

        oModel.callFunction("/getPoData", {
          method: "GET",
          urlParameters: {
            PONumber: "",
            material: "",
            orderType: "",
            createOn: "",
          },
          success: function (data) {
            console.log("Data getPoData berhasil diambil:", data);
            let result = data.results;

            let oModelNew = new sap.ui.model.json.JSONModel();
            oModelNew.setData(result);
            oData.getView().setModel(oModelNew, "output");

            if (result.length === 0) {
              sap.m.MessageToast.show("Data tidak ditemukan");
            } else {
              sap.m.MessageToast.show("Data berhasil diambil");
            }
          },
          error: function (err) {
            console.error("Gagal mengambil data getPoData:", err);
          },
        });
      },

      onPress: function () {
        let poNumber = this.getView().byId("PONumber").getValue();
        let material = this.getView().byId("Material").getValue().toUpperCase();
        let orderType = this.getView()
          .byId("OrderType")
          .getValue()
          .toUpperCase();
        let createOn = this.getView().byId("CreateOn").getValue();

        let formattedDate = createOn.split("-").join("");

        let oModel = this.getOwnerComponent().getModel();
        let oData = this;

        oModel.callFunction("/getPoData", {
          method: "GET",
          urlParameters: {
            PONumber: poNumber,
            material: material,
            orderType: orderType,
            createOn: formattedDate,
          },
          success: function (data) {
            console.log("Data getPoData berhasil diambil:", data);
            let result = data.results;

            let oModelNew = new sap.ui.model.json.JSONModel();
            oModelNew.setData(result);
            oData.getView().setModel(oModelNew, "output");

            if (result.length === 0) {
              sap.m.MessageToast.show("Data tidak ditemukan");
            } else {
              sap.m.MessageToast.show("Data berhasil diambil");
            }
          },
          error: function (err) {
            console.error("Gagal mengambil data getPoData:", err);
          },
        });
      },
    });
  }
);
