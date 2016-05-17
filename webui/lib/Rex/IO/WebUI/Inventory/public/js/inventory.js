var inventory = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
    this.asset_id = 0;
  },

  load: function(force) {
    var self = this;

    /*
    self.ui.register_route(new RegExp('^inventory/asset/(\\d+)'), function(idx) {
      console.log("requesting inventory idx: " + idx[0]);
      self.asset_id = idx[0];

      self.ui.load_page(
        {
          "link" : "/inventory/asset/" + idx[0],
          "cb"   : function() {
            self.load_tabs(function() {
              prepare_tab();
              activate_tab($(".tab-pane:first"));
              console.log("inventory/asset page loaded!");
            });
          }
        }
      );
    });

    self.ui.load_page(
      {
        "link" : "/inventory",
        "cb"   : function() {
          prepare_tab();
          activate_tab($(".tab-pane:first"));

          console.log("Inventory page loaded!");
        }
      }
    ); 
    */
  },
  
  open_tree_node: function(node) {
    console.log("inventory.js: open_tree_node");
    console.log(node);
  },
  
  clicked_tree_node: function(event, node) {
    console.log("inventory.js: clicked_tree_node");
    console.log(node);

    self.ui.load_page(
        {
          "link" : "/inventory/" + node.id,
          "cb"   : function() {
            prepare_tab();
            activate_tab($(".tab-pane:first"));

            console.log("Inventory page loaded!");
          }
        }
      ); 
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

    rexio.call("POST",
      "1.0",
      "inventory",
      [
        "inventory", null,
        "ref", {
          "name": $("#asset_name").val(),
          "type": $("#asset_type").val()
        }
      ],
      function(data) {
        if(data['ok']) {
          $.pnotify({
            "title" : "New asset created",
            "text"  : "New asset "
                        + "<b>" + $("#asset_name").val() + "</b>"
                        + " created. ",
            "type"  : "info"
          });

          self.ui.redirect_to("inventory");
        }
        else {
          $.pnotify({
            "title" : "Error "
                        + " creating "
                        + " asset",
            "text"  : "Can't "
                        + " create new "
                        + " asset "
                        + "<b>" + $("#asset_name").val() + "</b>"
                        + "<br /><br /><b>Error</b>: " + data['error'],
            "type"  : "error"
          });
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
  
  onload: function() {},

  __END__: ""

});

ui.register_plugin(
  {
    "object" : "inventory"
  }
);
