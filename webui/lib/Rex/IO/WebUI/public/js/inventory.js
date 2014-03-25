var inventory = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  load: function(obj) {

  },

  /**
   * ---------------------------------------------------------------------------
   * Bridge Adapter functions
   * ---------------------------------------------------------------------------
   */
  add_bridge_dialog: function(event) {
    $("#configure_bridge_device").dialog('open');
  },

  close_configure_bridge_device_dialog: function() {
    $("#br_name").val("");
    $("#br_ip").val("");
    $("#br_netmask").val("");
    $("#br_network").val("");
    $("#br_broadcast").val("");
    $("#br_gateway").val("");
    $("#br_proto").val("");
    $("#br_bridge").val("");
    $("#br_boot").prop('checked', false);
  },

  /**
   * save bridge adapter information to the backend.
   */
  click_configure_bridge_device_save: function() {
    var self    = this;
    var sel_row =
      self.ui.data_table_get_selected_item("table_server_network_bridges");
    var br_id  = $(sel_row).attr("dev_id");

    var what   = "updated";
    var what_2 = "updating";

    if(! br_id) {
      console.log("No device selected. Creating new device.");
      br_id = "new";
      what   = "added";
      what_2 = "adding";
    }

    var ref = {
      "name"              : $("#br_name").val(),
      "ip"                : $("#br_ip").val(),
      "netmask"           : $("#br_netmask").val(),
      "network"           : $("#br_network").val(),
      "broadcast"         : $("#br_broadcast").val(),
      "gateway"           : $("#br_gateway").val(),
      "proto"             : $("#br_proto").val(),
    };

    if($("br_boot").is(":checked")) {
      ref['boot'] = 1;
    }
    else {
      ref['boot'] = 0;
    }

    var success_func = function(data) {
      if(data.ok == true) {
        $.pnotify({
          "title" : "Bridge adapter  "+ what + ".",
          "text"  : "Bridge adapter "
                      + "<b>" + ref.name + "</b>"
                      + " " + what + ".",
          "type"  : "info"
        });
      }
      else {
        $.pnotify({
          "title" : "Failed " + what_2 + " bridge adapter.",
          "text"  : "Failed " + what_2 + " bridge adapter "
                      + "<b>" + ref.name + "</b>"
                      + "<br />Error message: " + data["error"],
          "type"  : "error"
        });
      }
    };

    if(br_id == "new") {
      rexio.call(
        "POST",
        "1.0",
        "inventory",
        ["host", server_id, "bridge", null, "ref", ref],
        success_func
      );
    }
    else {
      rexio.call(
        "POST",
        "1.0",
        "inventory",
        ["host", server_id, "bridge", br_id, "ref", ref],
        success_func
      );
    }
  },

  del_bridge_dialog: function(event) {
    var self = this;
    var sel_row =
      self.ui.data_table_get_selected_item("table_server_network_bridges");
    var br_id  = $(sel_row).attr("dev_id");
    var br     = $(sel_row).attr("dev");
    var srv_id = server_id;

    if(! br_id) {
      self.ui.dialog_msgbox({
        "title": "No Bridge-Adapter selected.",
        "text": "You have to select a Bridge-Adapter."
      });
      return;
    }

    self.ui.dialog_confirm({
      "id"     : "server_network_delete_bridge",
      "title"  : "Really delete network bridge " + br + "?",
      "text"   : "This entry will be permanently deleted " + br,
      "button" : "Delete",
        "ok": function() {
          self.del_bridge(srv_id, br_id, br);
        },
      "cancel": function() {}
    });
  },

  del_bridge: function(srv_id, br_id, br_name) {
    rexio.call(
      "DELETE",
      "1.0",
      "inventory",
      ["host", srv_id, "bridge", br_id],
      function(data) {
        if(data.ok == true) {
          $.pnotify({
            "title" : "Bridge adapter deleted.",
            "text"  : "Bridge adapter "
                        + "<b>" + br_name + "</b>"
                        + " deleted.",
            "type"  : "info"
          });

        }
        else {
          $.pnotify({
            "title" : "Error deleting bridge adapter.",
            "text"  : "Error deleting bridge adapter "
                        + "<b>" + br_name + "</b>"
                        + "<br /><div class=\"error_message\">Error message: "
                        + data["error"] + "</div>",
            "type"  : "error"
          });
        }
      }
    );
  },

  configure_bridge_dialog: function(event) {
    var self = this;
    var itm  =
      self.ui.data_table_get_selected_item("table_server_network_bridges");

    console.log("Got selected item: ");
    console.log(itm);

    var dev_id = $(itm).attr("dev_id");
    console.log("Got bridge device id: " + dev_id);

    if(! dev_id) {
      return;
    }

    self.get_bridge_adapter_configuration(dev_id, function() {
      $("#configure_bridge_device").dialog('open');
    });
  },

  get_bridge_adapter_configuration: function(dev_id) {
    rexio.call(
      "GET",
      "1.0",
      "inventory",
      ["host", server_id, "bridge", dev_id],
      function(data) {
        console.log("Got bridge data.")
        console.log(data);

        $("#configure_bridge_device").dialog('open');
        $("#br_name").val(data.name != 0 ? data.name : "");
        $("#br_ip").val(data.ip != 0 ? data.ip : "");
        $("#br_netmask").val(data.netmask != 0 ? data.netmask : "");
        $("#br_broadcast").val(data.broadcast != 0 ? data.broadcast : "");
        $("#br_network").val(data.network != 0 ? data.network : "");
        $("#br_gateway").val(data.gateway != 0 ? data.gateway : "");

        if(data.boot == 1) {
          $("#br_boot").prop('checked', true);
        }
        else {
          $("#br_boot").prop('checked', false);
        }

        $("#br_proto option[value=" + data.proto + "]").attr("selected", true);

      }
    );
  },

  click_configure_bridge_device_cancel: function() {
    var self = this;
    self.close_configure_bridge_device_dialog();
  },

  /**
   * ---------------------------------------------------------------------------
   * Network Adapter functions
   * ---------------------------------------------------------------------------
   */
  add_adapter_dialog: function(event) {
    $("#configure_network_device").dialog('open');
  },

  click_configure_network_device_cancel: function() {
    var self = this;
    self.close_configure_network_device_dialog();
  },

  close_configure_network_device_dialog: function() {
    $("#nwa_name").val("");
    $("#nwa_ip").val("");
    $("#nwa_mac").val("");
    $("#nwa_netmask").val("");
    $("#nwa_network").val("");
    $("#nwa_broadcast").val("");
    $("#nwa_gateway").val("");
    $("#nwa_proto").val("");
    $("#nwa_bridge").val("");
    $("#nwa_boot").prop('checked', false);
  },

  /**
   * save network adapter information to the backend.
   */
  click_configure_network_device_save: function() {
    var self    = this;
    var sel_row =
      self.ui.data_table_get_selected_item("table_server_network_devices");
    var nwa_id  = $(sel_row).attr("dev_id");

    var what   = "updated";
    var what_2 = "updating";

    if(! nwa_id) {
      console.log("No device selected. Creating new device.");
      nwa_id = "new";
      what   = "added";
      what_2 = "adding";
    }

    var ref = {
      "dev"               : $("#nwa_name").val(),
      "ip"                : $("#nwa_ip").val(),
      "mac"               : $("#nwa_mac").val(),
      "netmask"           : $("#nwa_netmask").val(),
      "network"           : $("#nwa_network").val(),
      "broadcast"         : $("#nwa_broadcast").val(),
      "gateway"           : $("#nwa_gateway").val(),
      "proto"             : $("#nwa_proto").val(),
      "network_bridge_id" : $("#nwa_bridge").val()
    };

    if($("#nwa_boot").is(":checked")) {
      ref['boot'] = 1;
    }
    else {
      ref['boot'] = 0;
    }

    var success_func = function(data) {
      if(data.ok == true) {
        $.pnotify({
          "title" : "Network adapter  "+ what + ".",
          "text"  : "Network adapter "
                      + "<b>" + ref.dev + "</b>"
                      + " " + what + ".",
          "type"  : "info"
        });
      }
      else {
        $.pnotify({
          "title" : "Failed " + what_2 + " network adapter.",
          "text"  : "Failed " + what_2 + " network adapter "
                      + "<b>" + ref.dev + "</b>"
                      + "<br />Error message: " + data["error"],
          "type"  : "error"
        });
      }
    };

    if(nwa_id == "new") {
      rexio.call(
        "POST",
        "1.0",
        "inventory",
        ["host", server_id, "network_adapter", null, "ref", ref],
        success_func
      );
    }
    else {
      rexio.call(
        "POST",
        "1.0",
        "inventory",
        ["host", server_id, "network_adapter", nwa_id, "ref", ref],
        success_func
      );
    }
  },

  del_adapter_dialog: function(event) {
    var self = this;
    var sel_row =
      self.ui.data_table_get_selected_item("table_server_network_devices");
    var nwa_id = $(sel_row).attr("dev_id");
    var nwa    = $(sel_row).attr("dev");
    var srv_id = server_id;

    if(! nwa_id) {
      self.ui.dialog_msgbox({
        "title": "No Network-Adapter selected.",
        "text": "You have to select a Network-Adapter."
      });
      return;
    }

    self.ui.dialog_confirm({
      "id"     : "server_network_delete_adapter",
      "title"  : "Really delete network adapter " + nwa + "?",
      "text"   : "This entry will be permanently deleted " + nwa,
      "button" : "Delete",
        "ok": function() {
          self.del_adapter(srv_id, nwa_id, nwa);
        },
      "cancel": function() {}
    });
  },

  del_adapter: function(srv_id, nwa_id, nwa_name) {
    rexio.call(
      "DELETE",
      "1.0",
      "inventory",
      ["host", srv_id, "network_adapter", nwa_id],
      function(data) {
        if(data.ok == true) {
          $.pnotify({
            "title" : "Network adapter deleted.",
            "text"  : "Network adapter "
                        + "<b>" + nwa_name + "</b>"
                        + " deleted.",
            "type"  : "info"
          });

        }
        else {
          $.pnotify({
            "title" : "Error deleting network adapter.",
            "text"  : "Error deleting network adapter "
                        + "<b>" + nwa_name + "</b>"
                        + "<br /><div class=\"error_message\">Error message: "
                        + data["error"] + "</div>",
            "type"  : "error"
          });
        }
      }
    );
  },

  configure_adapter_dialog: function(event) {
    var self = this;
    var itm  =
      self.ui.data_table_get_selected_item("table_server_network_devices");

    console.log("Got selected item: ");
    console.log(itm);

    var dev_id = $(itm).attr("dev_id");
    console.log("Got network device id: " + dev_id);

    if(! dev_id) {
      return;
    }

    self.get_network_adapter_configuration(dev_id, function() {
      $("#configure_network_device").dialog('open');
    });
  },

  get_network_adapter_configuration: function(dev_id) {
    rexio.call(
      "GET",
      "1.0",
      "inventory",
      ["host", server_id, "network_adapter", dev_id],
      function(data) {
        $("#tr_mac").show();
        $("#tr_bridge").show();
        $("#configure_network_device").dialog('open');
        $("#nwa_name").val(data.dev != 0 ? data.dev : "");
        $("#nwa_ip").val(data.ip != 0 ? data.ip : "");
        $("#nwa_mac").val(data.mac != 0 ? data.mac : "");
        $("#nwa_netmask").val(data.netmask != 0 ? data.netmask : "");
        $("#nwa_broadcast").val(data.broadcast != 0 ? data.broadcast : "");
        $("#nwa_network").val(data.network != 0 ? data.network : "");
        $("#nwa_gateway").val(data.gateway != 0 ? data.gateway : "");

        if(data.boot == 1) {
          $("#nwa_boot").prop('checked', true);
        }
        else {
          $("#nwa_boot").prop('checked', false);
        }

        $("#nwa_proto option[value=" + data.proto + "]").attr("selected", true);

        if(typeof data["bridge"] != "undefined"
        && typeof data["bridge"]["name"] != "undefined") {
          $("#nwa_bridge option[value=" + data.bridge.id + "]").prop("selected", true);
        }
        else {
          $("#nwa_bridge option").prop("selected", false);
          $("#nwa_bridge")[0].selectedIndex = 0;
        }
      }
    );
  }
});

ui.register_plugin(
  {
    "object" : "inventory"
  }
);
