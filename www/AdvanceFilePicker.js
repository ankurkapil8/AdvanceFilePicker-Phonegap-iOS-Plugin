(function(window) {
 
    var AdvanceFilePicker = function() {};
  
    AdvanceFilePicker.prototype = {
  
        isAvailable: function(success) {
            cordova.exec(success, null, "AdvanceFilePicker", "isAvailable", []);
        },
  
        pickFile: function(success, fail,utis, position) {
            cordova.exec(success, fail, "AdvanceFilePicker", "pickFile", [utis, position]);
        }

    };
  
    cordova.addConstructor(function() {
                         
        window.AdvanceFilePicker = new AdvanceFilePicker();
                         
    });
  
})(window);
