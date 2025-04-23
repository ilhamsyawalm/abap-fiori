sap.ui.define(
  [
    "sap/ui/Device",
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel",
    "sap/m/Popover",
    "sap/m/Button",
    "sap/m/Dialog",
    "sap/m/Text",
    "sap/m/library",
    "sap/tnt/library",
    "sap/m/MessageToast",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
  ],
  function (
    Device,
    Controller,
    JSONModel,
    Popover,
    Button,
    Dialog,
    Text,
    library,
    tntLibrary,
    MessageToast,
    ChartContainer,
    ChartContainerContent
  ) {
    "use strict";

    let aMapData = [];

    var ButtonType = library.ButtonType,
      PlacementType = library.PlacementType,
      NavigationListItemDesign = tntLibrary.NavigationListItemDesign;

    return Controller.extend("navigation3.controller.dashboard", {
      onInit: function () {
        var oModel = new sap.ui.model.json.JSONModel(
          "https://ilhamsyawalm.github.io/Data_publish/Data.json"
        );
        this.getView().setModel(oModel, "jsonModel"); //menambahkan array baru pada Odata global
        //   this.getView().setModel(oModel);            //Menimpa Odata global
        this._setToggleButtonTooltip(!Device.system.desktop);

        var oView = this.getView();
        this.adjustMyChartBox(oView, "idVizFrame1", "idCell1");
        this.adjustMyChartBox(oView, "idVizFrame2", "idCell2");
        this.adjustMyChartBox(oView, "idVizFrame3", "idCell3");
        this.adjustMyChartBox(oView, "idVizFrame4", "idCell4");
        this.adjustMyChartBox(oView, "idVizFrame5", "idCell5");
        this.adjustMyChartBox(oView, "idVizFrame6", "idCell6");
      },

      adjustMyChartBox: function (oView, sChartId, sBlockId) {
        var oVizFrame = oView.byId(sChartId);
        var oChartContainerContent = new ChartContainerContent({
          content: [oVizFrame],
        });
        var oChartContainer = new ChartContainer({
          content: [oChartContainerContent],
        });

        oChartContainer.setShowFullScreen(true);
        oChartContainer.setAutoAdjustHeight(true);
        oView.byId(sBlockId).addContent(oChartContainer);
      },

      // Saat side navigation digunakan
      onItemSelect: function (oEvent) {
        var oItem = oEvent.getParameter("item");
        this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
      },

      // Memasukan button baru saat nama di click
      handleUserNamePress: function (event) {
        var oPopover = new Popover({
          showHeader: false,
          placement: PlacementType.Bottom,
          content: [
            new Button({
              text: "Feedback",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Help",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Logout",
              type: ButtonType.Transparent,
            }),
          ],
        }).addStyleClass("sapMOTAPopover sapTntToolHeaderPopover");

        oPopover.openBy(event.getSource());
      },

      // Alert saat user di click
      onAvatarPressed: function () {
        MessageToast.show("Hello everyone! :)");
      },

      onFixedPressed: function () {
        MessageToast.show("Fixed navigation got press! :)");
      },

      // Untuk hamburger side navigation
      onSideNavButtonPress: function () {
        var oToolPage = this.byId("toolPage");
        var bSideExpanded = oToolPage.getSideExpanded();

        this._setToggleButtonTooltip(bSideExpanded);

        oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
      },

      _setToggleButtonTooltip: function (bLarge) {
        var oToggleButton = this.byId("sideNavigationToggleButton");
        if (bLarge) {
          oToggleButton.setTooltip("Large Size Navigation");
        } else {
          oToggleButton.setTooltip("Small Size Navigation");
        }
      },
    });
  }
);
