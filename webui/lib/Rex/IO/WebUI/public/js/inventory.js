(function() {

  $(document).ready(function() {

    server_init_hook(function(server_id) {

      prepare_server_bridge_list();
      prepare_server_nwa_list();

      prepare_network_dialogs(server_id);

    });

  })

})();


var tbl_nwa_list;
function prepare_server_nwa_list() {

  tbl_nwa_list = $("#table_server_network_devices").dataTable({
    //"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "bJQueryUI": true,
    "bPaginate": false,
    "sPaginationType": "full_numbers",
    "bFilter": false,
    "bInfo": false
  });

  $("#table_server_network_devices tbody tr").click( function( e ) {
    if ( $(this).hasClass('row_selected') ) {
      $(this).removeClass('row_selected');
    }
    else {
      tbl_nwa_list.$('tr.row_selected').removeClass('row_selected');
      $(this).addClass('row_selected');
    }
  });

  prepare_data_tables();
}

var tbl_bridge_list;
function prepare_server_bridge_list() {

  tbl_bridge_list = $("#table_server_network_bridges").dataTable({
    //"sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",
    "bJQueryUI": true,
    "bPaginate": false,
    "sPaginationType": "full_numbers",
    "bFilter": false,
    "bInfo": false
  });

  $("#table_server_network_bridges tbody tr").click( function( e ) {
    if ( $(this).hasClass('row_selected') ) {
      $(this).removeClass('row_selected');
    }
    else {
      tbl_bridge_list.$('tr.row_selected').removeClass('row_selected');
      $(this).addClass('row_selected');
    }
  });

  prepare_data_tables();

}

function server_delete_bridge(srv_id, br_id) {

  rexio.call(
    "DELETE",
    "1.0",
    "inventory",
    ["host", srv_id, "bridge", br_id],
    function(data) {
      if(data.ok == true) {
        $.pnotify({
          text: "Bridge deleted.",
          type: "info"
        });

        load_server(server_id, function() {
          activate_tab($("#li-tab-network"));
        });
      }
      else {
        $.pnotify({
          text: "Error deleting bridge.",
          type: "error"
        });
      }
    }
  );

}

function server_delete_network_adapter(srv_id, nwa_id) {

  rexio.call(
    "DELETE",
    "1.0",
    "inventory",
    ["host", srv_id, "network_adapter", nwa_id],
    function(data) {
      if(data.ok == true) {
        $.pnotify({
          text: "Network adapter deleted.",
          type: "info"
        });

        load_server(server_id, function() {
          activate_tab($("#li-tab-network"));
        });
      }
      else {
        $.pnotify({
          text: "Error deleting network adapter.",
          type: "error"
        });
      }
    }
  );

}

var __func_network_device_save = function() {};

function prepare_network_dialogs(srv_id) {

  $("#lnk_server_network_add_bridge").click(function(event) {
    open_add_new_bridge_dialog();
    return cancel_events(event);
  });

  $("#lnk_server_network_add_adapter").click(function(event) {
    open_add_new_network_dialog();
    return cancel_events(event);
  });

  $("#lnk_server_network_delete_bridge").click(function(event) {
    var sel_row = fnGetSelected(tbl_bridge_list);
    var br_id = $(sel_row).attr("dev_id");
    var br = $(sel_row).attr("dev");

    if(! br_id) {
      dialog_msgbox({
        "title": "No bridge selected.",
        "text": "You have to select a bridge."
      });
      return cancel_events(event);
    }

    dialog_confirm({
      id: "server_network_delete_bridge",
      title: "Really delete bridge " + br + "?",
      text: "This entry will be permanently deleted " + br,
      button: "Delete",
      ok: function() {
        server_delete_bridge(srv_id, br_id);
      },
      cancel: function() {}
    });

    return cancel_events(event);

  });

  $("#lnk_server_network_delete_adapter").click(function(event) {
    var sel_row = fnGetSelected(tbl_nwa_list);
    var nwa_id = $(sel_row).attr("dev_id");
    var nwa = $(sel_row).attr("dev");

    if(! nwa_id) {
      dialog_msgbox({
        "title": "No Network-Adapter selected.",
        "text": "You have to select a Network-Adapter."
      });
      return cancel_events(event);
    }

    dialog_confirm({
      id: "server_network_delete_adapter",
      title: "Really delete network adapter " + nwa + "?",
      text: "This entry will be permanently deleted " + nwa,
      button: "Delete",
      ok: function() {
        server_delete_network_adapter(srv_id, nwa_id);
      },
      cancel: function() {}
    });

    return cancel_events(event);
  });

  $("#lnk_server_network_configure_bridge").click(function(event) {
    var sel_row = fnGetSelected(tbl_bridge_list);
    var br_id = $(sel_row).attr("dev_id");

    if(! br_id) {
      dialog_msgbox({
        "title": "No bridge selected.",
        "text": "You have to select a bridge."
      });
      return cancel_events(event);
    }

    __func_network_device_save = function() {
        var sel_row = fnGetSelected(tbl_bridge_list);
        var br_id = $(sel_row).attr("dev_id");

        var ref = {
          "name": $("#nwa_name").val(),
          "ip": $("#nwa_ip").val(),
          "netmask": $("#nwa_netmask").val(),
          "network": $("#nwa_network").val(),
          "broadcast": $("#nwa_broadcast").val(),
          "gateway": $("#nwa_gateway").val(),
          "proto": $("#nwa_proto").val()
        };

        if($("#nwa_boot").is(":checked")) {
          ref['boot'] = 1;
        }
        else {
          ref['boot'] = 0;
        }

        save_bridge_configuration(br_id, ref);

      };

    open_configure_bridge_dialog(br_id);

    return cancel_events(event);
  });



  $("#lnk_server_network_configure_adapter").click(function(event) {
    var sel_row = fnGetSelected(tbl_nwa_list);
    var nwa_id = $(sel_row).attr("dev_id");

    if(! nwa_id) {
      dialog_msgbox({
        "title": "No Network-Adapter selected.",
        "text": "You have to select a Network-Adapter."
      });

      return cancel_events(event);
    }

    __func_network_device_save = function() {
        var sel_row = fnGetSelected(tbl_nwa_list);
        var nwa_id = $(sel_row).attr("dev_id");

        var ref = {
          "dev": $("#nwa_name").val(),
          "ip": $("#nwa_ip").val(),
          "mac": $("#nwa_mac").val(),
          "netmask": $("#nwa_netmask").val(),
          "network": $("#nwa_network").val(),
          "broadcast": $("#nwa_broadcast").val(),
          "gateway": $("#nwa_gateway").val(),
          "proto": $("#nwa_proto").val(),
          "network_bridge_id": $("#nwa_bridge").val()
        };

        if($("#nwa_boot").is(":checked")) {
          ref['boot'] = 1;
        }
        else {
          ref['boot'] = 0;
        }

        save_network_adapter_configuration(nwa_id, ref);

      };

    open_configure_network_dialog(nwa_id);

    return cancel_events(event);
  });

  $("#configure_network_device").dialog({
    autoOpen: false,
    height: 500,
    width: 350,
    modal: true,
    buttons: {
      "Save": function() {
        __func_network_device_save();
        $(this).dialog("close");
      },
      Cancel: function() {
        $(this).dialog("close");
      }
    },
    close: function() {
    }
  });

}


function save_bridge_configuration(br_id, ref) {

  var success_func = function(data) {
    if(data.ok == true) {
      $.pnotify({
        text: "Bridge updated.",
        type: "info"
      });

      load_server(server_id, function() {
        activate_tab($("#li-tab-network"));
      });

    }
    else {
      $.pnotify({
        text: "Failed updating bridge.",
        type: "error"
      });
    }

    $("#tr_mac").show();
    $("#tr_bridge").show();
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
}

function save_network_adapter_configuration(nwa_id, ref) {

  var success_func = function(data) {
    if(data.ok == true) {
      $.pnotify({
        text: "Network adapter updated.",
        type: "info"
      });

      load_server(server_id, function() {
        activate_tab($("#li-tab-network"));
      });

    }
    else {
      $.pnotify({
        text: "Failed updating network adapter.",
        type: "error"
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

}

function open_add_new_bridge_dialog() {

  __func_network_device_save = function() {

      var ref = {
        "name": $("#nwa_name").val(),
        "ip": $("#nwa_ip").val(),
        "netmask": $("#nwa_netmask").val(),
        "network": $("#nwa_network").val(),
        "broadcast": $("#nwa_broadcast").val(),
        "gateway": $("#nwa_gateway").val(),
        "proto": $("#nwa_proto").val()
      };

      if($("#nwa_boot").is(":checked")) {
        ref['boot'] = 1;
      }
      else {
        ref['boot'] = 0;
      }

      save_bridge_configuration("new", ref);

    };


  $("#tr_mac").hide();
  $("#tr_bridge").hide();

  $("#configure_network_device").dialog('open');
  $("#nwa_name").val("");
}

function open_add_new_network_dialog() {

  $("#tr_bridge").show();
  $("#tr_mac").show();

  __func_network_device_save = function() {

      var ref = {
        "dev": $("#nwa_name").val(),
        "ip": $("#nwa_ip").val(),
        "mac": $("#nwa_mac").val(),
        "netmask": $("#nwa_netmask").val(),
        "network": $("#nwa_network").val(),
        "broadcast": $("#nwa_broadcast").val(),
        "gateway": $("#nwa_gateway").val(),
        "proto": $("#nwa_proto").val(),
        "network_bridge_id": $("#nwa_bridge").val()
      };

      if($("#nwa_boot").is(":checked")) {
        ref['boot'] = 1;
      }
      else {
        ref['boot'] = 0;
      }

      save_network_adapter_configuration("new", ref);

    };


  $("#configure_network_device").dialog('open');
  $("#nwa_name").val("");
}

function open_configure_bridge_dialog(br_id) {

  rexio.call(
    "GET",
    "1.0",
    "inventory",
    ["host", server_id, "bridge", br_id],
    function(data) {
      $("#tr_mac").hide();
      $("#tr_bridge").hide();

      $("#configure_network_device").dialog('open');
      $("#nwa_name").val(data.name != 0 ? data.name : "");
      $("#nwa_ip").val(data.ip != 0 ? data.ip : "");
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
    }
  )

}

function open_configure_network_dialog(nwa_id) {

  rexio.call(
    "GET",
    "1.0",
    "inventory",
    ["host", server_id, "network_adapter", nwa_id],
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

      if(typeof data["bridge"] != "undefined" && typeof data["bridge"]["name"] != "undefined") {
        $("#nwa_bridge option[value=" + data.bridge.id + "]").prop("selected", true);
      }
      else {
        $("#nwa_bridge option").prop("selected", false);
        $("#nwa_bridge")[0].selectedIndex = 0;
      }
    }
  );

}
