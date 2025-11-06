sap.ui.define(["sap/m/MessageToast"], function (MessageToast) {
  "use strict";

  return {
    Button: function (oEvent) {
      let x = prompt("Masukan valuenya");
      MessageToast.show("Custom handler invoked.");
      alert("Hasil inputannya adalah " + x);
      console.log(oEvent);

      // let oBindingParams = oEvent.getParameter("hideField");
      // console.log(oBindingParams);

      let oModel = this.getModel();
      console.log(oModel);

      //   let oData = this.getModel();
      //   console.log(oData);
      //   oData.read("/Issue", {
      //     success: function (data) {
      //       console.log(data);
      //     },
      //   });
    },
  };
});
