sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
    "sap/ui/vbm/AnalyticMap",
    "sap/ui/vbm/Spot",
    "sap/m/MessageToast",
  ],
  function (
    Controller,
    ChartContainer,
    ChartContainerContent,
    AnalyticMap,
    Spot,
    MessageToast
  ) {
    "use strict";

    return Controller.extend("analytics.controller.View1", {
      onInit: function () {
        var oView = this.getView();

        this.adjustMyChartBox(oView, "idVizFrame1", "idCell1");
        this.adjustMyChartBox(oView, "idVizFrame2", "idCell2");
        this.adjustMyChartBox(oView, "idVizFrame3", "idCell3");
        this.adjustMyChartBox(oView, "idVizFrame4", "idCell4");

        this.getOwnerComponent()
          .getRouter()
          .attachRoutePatternMatched(this.geoMapCollection, this);
      },

      adjustMyChartBox: function (oView, sChartId, sBlockId) {
        var oVizFrame = oView.byId(sChartId);
        var oChartContainerContent = new ChartContainerContent({
          content: [oVizFrame],
        });
        console.log("hai semuanya");
        var oChartContainer = new ChartContainer({
          content: [oChartContainerContent],
        });

        oChartContainer.setShowFullScreen(true);
        oChartContainer.setAutoAdjustHeight(true);
        oView.byId(sBlockId).addContent(oChartContainer);
      },

      geoMapCollection: function () {
        var oDataModel = this.getView().getModel();
        var x = this;

        oDataModel.read("/geomapSet", {
          success: function (data) {
            var aMapData = [];

            for (var i = 0; i < data.results.length; i++) {
              var item = data.results[i];

              const r = Math.round(Math.random() * 255);
              const g = Math.round(Math.random() * 255);
              const b = Math.round(Math.random() * 255);

              var color = "rgb(" + r + "," + g + "," + b + ")";
              let color2 = "rgb(0,255,0)";
              item.color = color;
              aMapData.push(item);
              console.log(color2);
            }
            var oModel = new sap.ui.model.json.JSONModel();
            oModel.setData({
              mapData: aMapData,
            });
            x.getView().setModel(oModel, "viewModel");
          },
        });
      },
    });
  }
);
