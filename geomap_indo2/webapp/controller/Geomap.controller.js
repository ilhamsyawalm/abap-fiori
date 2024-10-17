sap.ui.define(
  [
    "sap/ui/vbm/AnalyticMap", // Mengimpor modul AnalyticMap untuk peta analitik
    "sap/ui/core/mvc/Controller", // Mengimpor Controller untuk mengelola logika aplikasi
    "sap/m/Text", // Mengimpor Text untuk menampilkan teks di dialog
    "sap/m/Button", // Mengimpor Button untuk tombol di dialog
    "sap/m/Dialog", // Mengimpor Dialog untuk membuat dialog pop-up
  ],
  function (AnalyticMap, Controller, Text, Button, Dialog) {
    "use strict";

    // Mengatur URL untuk GeoJSON peta Indonesia
    AnalyticMap.GeoJSONURL =
      "https://alenkarendra.github.io/idngeojson/idngeojson.json";

    // Variable untuk menyimpan data baru
    let Isi = [];

    return Controller.extend("geomapindo.controller.Geomap", {
      onInit: function () {
        // Inisialisasi ketika kontroler pertama kali dibuat
        this.getOwnerComponent()
          .getRouter()
          .attachRoutePatternMatched(this.geoMapCollection, this);
      },

      // Fungsi untuk mengumpulkan data peta geografis
      geoMapCollection: function () {
        let oData = this.getView().getModel(); // Mendapatkan odata dari SAP
        let x = this; // Disimpan dalam let x

        // Membuat array mengenai info & warna
        let legend = [
          { Info: "high", warna: "rgb(56, 163, 56)" },
          { Info: "medium", warna: "rgb(249,172,60)" },
          { Info: "low", warna: "rgb(243,0,0)" },
        ];

        // Membaca odata
        oData.read("/Zilham_001_idn", {
          success: function (data) {
            Isi.length = 0;
            // Melakukan loop untuk mengambil data satu - per satu
            for (let i = 0; i < data.results.length; i++) {
              let isian = []; // Array temp (seperti work area di SAP ABAP)
              let color = "";
              let type = "";
              isian = data.results[i]; // menyimpan satu data loop ke variable isian
              let pos = `${data.results[i].longtitude};${data.results[i].latitude};0`; //Membuat data untuk spot tertentu

              // Membuat if else untuk pengelompokan warna region & spot berdasarkan nilai sales
              if (data.results[i].sales >= 6600000000) {
                color = legend[0].warna;
                type = "Success";
              } else if (
                data.results[i].sales >= 3300000000 &&
                data.results[i].sales < 6600000000
              ) {
                color = legend[1].warna;
                type = "Warning";
              } else {
                color = legend[2].warna;
                type = "Error";
              }

              // Merubah nilai data sales berdasarkan nilai currency indonesia
              let convertSales = new Intl.NumberFormat("id-ID", {
                style: "currency",
                currency: "IDR",
              }).format(data.results[i].sales);

              // Memasukan perubahan data ke array isian
              isian.convert = convertSales;
              isian.type = type;
              isian.color = color;
              isian.pos = pos;

              // Memasukan value isian ke array Isi
              Isi.push(isian);
            }

            Isi.sort((dalem) => dalem.convert); // Melaukan sorting data berdasarkan nilai sales dari tertinggi
            // console.log(Isi);

            // Menyiapkan model baru dan mengatur data ke dalam model
            var oModel = new sap.ui.model.json.JSONModel();

            oModel.setData({
              // Membuat odata baru dengan 2 entity
              products: Isi, // product yang berisi dari array Isi
              legends: legend, // legends yang berisi dari array legend
            });

            // Mengatur model baru ke dalam view dengan nama 'productModel'
            x.getView().setModel(oModel, "productModel");
          },
          error: function (oError) {
            console.log("data ga dapet");
          },
        });
      },

      // Saat negaranya di klik
      onRegionClick: function (e) {
        let result = [];

        var oModel = new sap.ui.model.json.JSONModel();
        // Melakukan loop
        for (let i = 0; i < Isi.length; i++) {
          let id = Isi[i].id_code;
          let temp = [];

          if (id == e.getParameter("code")) {
            // Menyamakan nilai yg di dapat dari loop dengan parameter yg tersedia
            temp.length = 0;
            temp = Isi[i];
            console.log(temp);
            result.push(temp);
          } else if (id != e.getParameter("code")) {
            // Ambil data terendah & tertinggi
            if (i == 0) {
              temp.length = 0;
              temp = Isi[i];
              result.push(temp);
            } else if (i == Isi.length - 1) {
              temp.length = 0;
              temp = Isi[i];
              result.push(temp);
            }
          }
        }
        oModel.setData({
          click: result,
          gelongongan: Isi,
        });

        sap.ui.getCore().setModel(oModel, "productModel"); //Cara mendeklarasikan odata secara global agar dapat digunakan pada controller lain

        var gaje = oModel.getData(); //cara melihat odata yang telah dibuat
        // console.log(gaje);

        console.log("pindah");

        var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
        oRouter.navTo("RouteGeomap2");
      },

      // Fungsi untuk menangani klik pada titik tertentu (spot)
      onSpotClick: function (e) {
        let resultTitle;
        let resultDetail;
        let detail = e.getSource();
        let detailTooltip = detail.getText();

        for (let i = 0; i < Isi.length; i++) {
          if (Isi[i].tooltip == detailTooltip) {
            // Mengambil informasi kota dan detil berdasarkan tooltip
            resultTitle = Isi[i].city;
            resultDetail = `Memiliki id code : ${Isi[i].id_code} \n
            dengan titik spot : (${Isi[i].pos}) \n
            Nilai penjualan sebesar : ${Isi[i].convert}`;
          }
        }

        // Membuat dialog jika belum ada
        if (!this.popover) {
          this.popover = new Dialog({
            title: resultTitle,
            content: new Text({ text: resultDetail }),
            beginButton: new Button({
              text: "Close",
              press: function () {
                this.popover.close();
              }.bind(this),
            }),
          });
        }

        // Menambahkan dialog ke dalam view dan mengatur konten
        this.getView().addDependent(this.popover);
        this.popover.setTitle(resultTitle);
        this.popover.getContent()[0].setText(resultDetail);

        // Membuka dialog
        this.popover.open();
      },
    });
  }
);
