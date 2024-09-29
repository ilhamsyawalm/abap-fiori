sap.ui.define(
  [
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/ui/Device",
    "sap/m/MessageToast",
  ],
  function (AnalyticMap, Controller, JSONModel, Device, MessageToast) {
    "use strict";

    AnalyticMap.GeoJSONURL = "../model/indonesia.json";
    let Isi = [];

    return Controller.extend("geomapindo.controller.Geomap", {
      onInit: function () {
        this.getOwnerComponent()
          .getRouter()
          .attachRoutePatternMatched(this.geoMapCollection, this);
      },

      geoMapCollection: function () {
        let oData = this.getView().getModel();
        let x = this;
        // console.log(oData);

        oData.read("/Zilham_001_idn", {
          success: function (data) {
            //  console.log(data);

            for (let i = 0; i < data.results.length; i++) {
              let isian = [];
              let baru = [];
              isian = data.results[i];

              console.log(isian);
              //Pecah tiap data (per Field) cek dari chatGPT

              //Otak atik datanya

              //Masukin tiap pecahan data satu satu ke Object baru 
              

              //Baru masukin ke array yg sudah di siapkan
              Isi.push(isian);
              console.log(Isi);
            }
            console.log(Isi);
            var oModel = new sap.ui.model.json.JSONModel();

            // Set array data ke model
            oModel.setData({ products: Isi });

            // Mengikat model ke view
            x.getView().setModel(oModel, "productModel");
          },
        });
      },
    });
  }
);
