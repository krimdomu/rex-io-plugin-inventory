var inventory_asset_server = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  load: function(force) {
    var self = this;
  },

  add: function() {
    var self = this;
    ui.load_page(
        {
          "link" : "/inventory/asset/server/new",
          "cb"   : function() {
            prepare_tab();
            activate_tab($(".tab-pane:first"));
            
            $("#asset_name").val(rexio.stash("name"));
            $("#save_server").click(function() {
              self.save();
            });
  
            console.log("Server new page loaded!");
          }
        }
      );
  },
  
  save: function() {
    var group_id = rexio.stash("group_id");
    rexio.call("POST",
        "1.0",
        "inventory",
        [
          "inventory", null,
          "ref", {
            "name": $("#asset_name").val(),
          }
        ],
        function(data) {
          if(data['ok']) {
            $.pnotify({
              "title" : "New server created",
              "text"  : "New server "
                          + "<b>" + $("#asset_name").val() + "</b>"
                          + " created. ",
              "type"  : "info"
            });

            self.ui.load_page({
              "link": "/inventory/" + group_id
            });
          }
          else {
            $.pnotify({
              "title" : "Error "
                          + " creating "
                          + " server",
              "text"  : "Can't "
                          + " create new "
                          + " server "
                          + "<b>" + $("#asset_name").val() + "</b>"
                          + "<br /><br /><b>Error</b>: " + data['error'],
              "type"  : "error"
            });
          }
        });
  },
  
  __END__: ""
});

ui.register_plugin(
  {
    "object" : "inventory/asset/server"
  }
);
