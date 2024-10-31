sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/vbm/Spot",
    "sap/m/MessageToast",
  ],
  function (
    Controller,
    JSONModel,
    ChartContainer,
    ChartContainerContent,
    AnalyticMap,
    Spot,
    MessageToast
  ) {
    "use strict";

    var oModel;

    return Controller.extend("geomapindo.controller.Geomap2", {
      onInit: function () {
        // Mengambil model yang sudah diatur secara global

        var oView = this.getView();

        this.adjustMyChartBox(oView, "idVizFrame1", "idCell1");
      },

      adjustMyChartBox: function (oView, sChartId, sBlockId) {
        oModel = sap.ui.getCore().getModel("productModel");
        if (oModel) {
          // Mendapatkan data dari model
          var oData = oModel.getData();
          this.getView().setModel(oModel, "productModel");
          // console.log("Data yang diambil:", oData);
        } else {
          console.log("Model tidak ditemukan.");
        }

        var oVizFrame = oView.byId(sChartId);
        if (oVizFrame) {
          var oChartContainerContent = new ChartContainerContent({
            content: [oVizFrame],
          });
          var oChartContainer = new ChartContainer({
            content: [oChartContainerContent],
          });
          oChartContainer.setShowFullScreen(true);
          oChartContainer.setAutoAdjustHeight(true);
          oView.byId(sBlockId).addContent(oChartContainer);
        } else {
          console.log("VizFrame tidak ditemukan.");
        }
      },
      
      onNavigateBack: function () {
        oModel = sap.ui.getCore().getModel("productModel");
        var oData = oModel.getData();
        console.log(oData);
        var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
        oRouter.navTo("RouteGeomap");
        location.reload();
      },
    });
  }
);
