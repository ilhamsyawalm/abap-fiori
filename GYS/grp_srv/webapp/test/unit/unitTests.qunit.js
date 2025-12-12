/* global QUnit */
QUnit.config.autostart = false;

sap.ui.getCore().attachInit(function () {
	"use strict";

	sap.ui.require([
		"grp_srv/grp_srv/test/unit/AllTests"
	], function () {
		QUnit.start();
	});
});
