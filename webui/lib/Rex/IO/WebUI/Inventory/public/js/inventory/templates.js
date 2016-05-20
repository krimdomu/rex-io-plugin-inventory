var inventory_templates = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
    this.templates_id = 0;
  },

  load: function(force) {
    var self = this;
    
    var self = this;
    ui.load_page(
        {
          "link" : "/inventory/template",
          "cb"   : function() {
            prepare_tab();
            activate_tab($(".tab-pane:first"));
            
            console.log("Templates page loaded!");
          }
        }
      );
  },

  add_templates_dialog: function() {
    $("#templates_name").val("");
    $("#templates_type").val("");
    $("#add_templates").dialog("option", "title", "New Template");
    $("#add_templates").dialog("open");
  },

  click_add_templates_cancel: function() {
    $("#templates_name").val("");
    $("#templates_type").val("");
    $("#add_templates").dialog("close");
  },

  click_add_templates: function() {
    var self = this;
    
    rexio.stash("name", $("#templates_name").val());
    rexio.stash("type", $("#templates_type").val());

    var plugin = $("#templates_type").val();
    
    self.ui.load_plugin({
      "obj": plugin,
      "cb": function() {
        self.ui.call_plugin_method(plugin, "add");
      }
    });

  },

  list_templates_row_cb: function(data, idx, data_ref) {
    if(idx == 1) {
      return "<td><a href=\"#/inventory/templates/" + data_ref[0] + "\">" + data + "</a></td>";
    }
    else {
      return "<td>" + data + "</td>";
    }
  },

  __END__: ""
});

ui.register_plugin(
    {
      "object" : "inventory/templates"
    }
  );
