var inventory_asset = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
    this.asset_id = 0;
  },

  load: function(force) {
    var self = this;
  },

  load_tabs: function(cb) {
    var self = this;
    $.ajax(
      {
        "type": "GET",
        "url": "/inventory/asset/" + self.asset_id + "/tabs"
      }
    ).done(function(data) {
      if(data['ok']) {
        $("#tab_list").html("");
        $("#tab_content").html("");

        for(var i = 0; i < data['data']['tabs'].length; i++) {
          var tab_id = data['data']['tabs'][i]['id'];
          var tab_title = data['data']['tabs'][i]['title'];
          var tab_content = data['data']['content'][tab_id];

          $("#tab_list").append(
            '<li id="li-tab-' + tab_id + '" tab_id="' + tab_id + '"><a id="link-tab-' + tab_id + '" tab_id="' + tab_id + '" href="#">' + tab_title + '</a></li>');

          $("#tab_content").append('<div id="tab-' + tab_id + '" class="tab-pane" tab_id="' + tab_id + '">' + tab_content + '</div>');
        }

        cb();
      }
      else {
        $.pnotify({
          "title" : "Error "
                      + " loading "
                      + " tabs",
          "text"  : "Can't "
                      + " load "
                      + " tabs for this asset. "
                      + "<br /><br /><b>Error</b>: " + data['error'],
          "type"  : "error"
        });
      }
    });
  },

  add_asset_dialog: function() {
    $("#asset_name").val("");
    $("#asset_type").val("");
    $("#add_asset").dialog("option", "title", "New Asset");
    $("#add_asset").dialog("open");
  },

  click_add_asset_cancel: function() {
    $("#asset_name").val("");
    $("#asset_type").val("");
    $("#add_asset").dialog("close");
  },

  click_add_asset: function() {
    var self = this;
    
    rexio.stash("name", $("#asset_name").val());
    rexio.stash("type", $("#asset_type").val());
    rexio.stash("group_id", $("#current_group_id").val());

    var plugin = $("#asset_type").val();
    
    self.ui.load_plugin({
      "obj": plugin,
      "cb": function() {
        self.ui.call_plugin_method(plugin, "add");
      }
    });

  },

  list_assets_row_cb: function(data, idx, data_ref) {
    if(idx == 1) {
      return "<td><a href=\"#/inventory/asset/" + data_ref[0] + "\">" + data + "</a></td>";
    }
    else {
      return "<td>" + data + "</td>";
    }
  },

  __END__: ""
});

ui.register_plugin(
    {
      "object" : "inventory/asset"
    }
  );
