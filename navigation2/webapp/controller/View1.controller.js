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
    ChartContainer,
    ChartContainerContent
  ) {
    "use strict";

    var ButtonType = library.ButtonType,
      PlacementType = library.PlacementType,
      NavigationListItemDesign = tntLibrary.NavigationListItemDesign;

    return Controller.extend("navigation2.controller.View1", {
      onInit: function () {
        // var oModel = new JSONModel(sap.ui.require.toUrl("sap/tnt/sample/ToolPage/model/data.json"));
        var oModel = new JSONModel("../model/Data.json");
        this.getView().setModel(oModel, "data1");

        var oModel2 = new JSONModel("../model/products.json");
        this.getView().setModel(oModel2, "data2");

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

      onItemSelect: function (oEvent) {
        var oItem = oEvent.getParameter("item");
        this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
      },

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

      onSideNavButtonPress: function () {
        var oToolPage = this.byId("toolPage");
        var bSideExpanded = oToolPage.getSideExpanded();

        this._setToggleButtonTooltip(bSideExpanded);

        oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
      },

      onQuickActionPress: function (oEvent) {
        if (oEvent.oSource.getDesign() !== NavigationListItemDesign.Action) {
          return;
        }
        if (!this.oDefaultDialog) {
          this.oDefaultDialog = new Dialog({
            title: "Create Item",
            type: "Message",
            content: new Text({ text: "Create New Navigation List Item" }),
            beginButton: new Button({
              type: ButtonType.Emphasized,
              text: "Create",
              press: function () {
                this.oDefaultDialog.close();
              }.bind(this),
            }),
            endButton: new Button({
              text: "Cancel",
              press: function () {
                this.oDefaultDialog.close();
              }.bind(this),
            }),
          });

          // to get access to the controller's model
          this.getView().addDependent(this.oDefaultDialog);
        }

        this.oDefaultDialog.open();
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
